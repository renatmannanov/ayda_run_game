# movement_controller.gd
# Бегун бежит на своём темпе. Игрок ускоряет (газ) или тормозит.
class_name MovementController
extends Node

signal speed_changed(current_speed: float)
signal jumped()

## Базовый темп бегуна (мин/км). Ставится из configure().
@export var base_pace_min_km: float = 6.0
## Множитель ускорения (газ)
@export var boost_multiplier: float = 1.5
## Множитель торможения
@export var brake_multiplier: float = 0.5
## Плавность изменения скорости (px/s²)
@export var speed_smoothing: float = 300.0
## Гравитация (px/s²)
@export var gravity: float = 980.0
## Перешагивание (px/s, вверх)
@export var jump_velocity: float = -160.0
## Coyote time (сек)
@export var coyote_time: float = 0.1

# Визуальная скорость (px/s) — та что двигает персонажа по экрану
var current_speed: float = 0.0
# Базовая визуальная скорость (px/s)
var base_speed: float = 0.0
# Состояние ввода
var is_boosting: bool = false
var is_braking: bool = false

var _coyote_timer: float = 0.0
var _was_on_floor: bool = true
var _just_jumped: bool = false

@onready var _body: CharacterBody2D = get_parent()


func _ready() -> void:
	base_speed = Constants.pace_to_speed(base_pace_min_km)
	current_speed = base_speed


func _physics_process(delta: float) -> void:
	_read_input()
	_update_coyote(delta)
	_update_speed(delta)
	_handle_jump()
	_apply_movement(delta)


func _read_input() -> void:
	is_boosting = Input.is_action_pressed("boost")
	is_braking = Input.is_action_pressed("brake")


func _update_coyote(delta: float) -> void:
	if _body.is_on_floor():
		_coyote_timer = coyote_time
		_was_on_floor = true
	else:
		if _was_on_floor:
			_was_on_floor = false
		_coyote_timer -= delta


func _update_speed(delta: float) -> void:
	var target_speed: float = base_speed

	if is_boosting:
		target_speed = base_speed * boost_multiplier
	elif is_braking:
		target_speed = base_speed * brake_multiplier

	current_speed = move_toward(current_speed, target_speed, speed_smoothing * delta)


func _handle_jump() -> void:
	_just_jumped = false
	if Input.is_action_just_pressed("jump") and _coyote_timer > 0.0:
		_body.velocity.y = jump_velocity
		_coyote_timer = 0.0
		_just_jumped = true
		jumped.emit()


func _apply_movement(delta: float) -> void:
	if _just_jumped:
		_body.velocity.x = current_speed
		_body.move_and_slide()
		speed_changed.emit(current_speed)
		return

	if not _body.is_on_floor():
		_body.velocity.y += gravity * delta
	else:
		_body.velocity.y = 10.0

	if _body.is_on_floor():
		var floor_normal := _body.get_floor_normal()
		var move_dir := Vector2(-floor_normal.y, floor_normal.x)
		if move_dir.x < 0.0:
			move_dir = -move_dir
		_body.velocity = move_dir * current_speed + Vector2(0, 10.0)
	else:
		_body.velocity.x = current_speed

	_body.move_and_slide()
	speed_changed.emit(current_speed)

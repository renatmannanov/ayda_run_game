# movement_controller.gd
# Компонент движения персонажа — автобег с газом, тормозом, прыжком и реакцией на рельеф
class_name MovementController
extends Node

signal speed_changed(current_speed: float)
signal slope_changed(slope_deg: float)
signal jumped()

## Базовая скорость по ровному (px/s)
@export var base_speed: float = 200.0
## Потолок скорости (px/s)
@export var max_speed: float = 400.0
## Ускорение при газе (px/s²)
@export var acceleration: float = 600.0
## Замедление без газа (px/s²)
@export var deceleration: float = 400.0
## Замедление при торможении (px/s²)
@export var brake_deceleration: float = 800.0
## Бонус скорости при газе (px/s)
@export var boost_speed_bonus: float = 150.0
## Гравитация (px/s²)
@export var gravity: float = 980.0
## Скорость прыжка (px/s, вверх)
@export var jump_velocity: float = -280.0
## Coyote time — можно прыгнуть после отрыва от пола (сек)
@export var coyote_time: float = 0.1

# Текущая горизонтальная скорость
var current_speed: float = 0.0
# Текущий угол наклона (градусы, + подъём, - спуск)
var current_slope_deg: float = 0.0
# Газ зажат
var is_boosting: bool = false
# Тормоз зажат
var is_braking: bool = false

# Таймер coyote time
var _coyote_timer: float = 0.0
# Был ли на полу в прошлом кадре
var _was_on_floor: bool = true
# Прыжок начат в этом кадре (чтобы не перезаписать velocity.y)
var _just_jumped: bool = false

# Ссылка на CharacterBody2D (родитель)
@onready var _body: CharacterBody2D = get_parent()


func _ready() -> void:
	current_speed = base_speed


func _physics_process(delta: float) -> void:
	_read_input()
	_update_coyote(delta)
	_update_slope()
	_update_speed(delta)
	_handle_jump()
	_apply_movement(delta)


## Считываем ввод игрока
func _read_input() -> void:
	is_boosting = Input.is_action_pressed("boost")
	is_braking = Input.is_action_pressed("brake")


## Coyote time — разрешаем прыжок чуть после отрыва от пола
func _update_coyote(delta: float) -> void:
	if _body.is_on_floor():
		_coyote_timer = coyote_time
		_was_on_floor = true
	else:
		if _was_on_floor:
			_was_on_floor = false
		_coyote_timer -= delta


## Определяем угол наклона поверхности под ногами
func _update_slope() -> void:
	if _body.is_on_floor():
		var floor_normal := _body.get_floor_normal()
		current_slope_deg = rad_to_deg(floor_normal.angle_to(Vector2.UP))
		# Знак: нормаль влево = подъём, вправо = спуск
		if floor_normal.x < 0.0:
			current_slope_deg = abs(current_slope_deg)
		else:
			current_slope_deg = -abs(current_slope_deg)
		slope_changed.emit(current_slope_deg)
	else:
		current_slope_deg = 0.0


## Меняем скорость: рельеф + газ/тормоз
func _update_speed(delta: float) -> void:
	var target_speed: float

	if current_slope_deg > 0.5:
		# Подъём: замедляемся пропорционально углу
		target_speed = base_speed * (1.0 - current_slope_deg / 90.0)
		target_speed = maxf(target_speed, 20.0)
	elif current_slope_deg < -0.5:
		# Спуск: ускоряемся
		target_speed = base_speed + abs(current_slope_deg) * 3.0
	else:
		# Ровный
		target_speed = base_speed

	# Газ — добавляет к целевой скорости
	if is_boosting:
		target_speed += boost_speed_bonus

	target_speed = clampf(target_speed, 0.0, max_speed)

	# Тормоз — снижаем целевую скорость
	if is_braking:
		if current_slope_deg < -0.5:
			# На спуске: ограничиваем до base_speed
			target_speed = minf(target_speed, base_speed)
		else:
			# На ровном/подъёме: тормозим до половины base_speed
			target_speed = minf(target_speed, base_speed * 0.5)

	# Переход к целевой скорости
	if is_braking:
		current_speed = move_toward(current_speed, target_speed, brake_deceleration * delta)
	elif current_speed < target_speed:
		current_speed = move_toward(current_speed, target_speed, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, target_speed, deceleration * delta)


## Прыжок
func _handle_jump() -> void:
	_just_jumped = false
	if Input.is_action_just_pressed("jump") and _coyote_timer > 0.0:
		_body.velocity.y = jump_velocity
		_coyote_timer = 0.0
		_just_jumped = true
		jumped.emit()


## Применяем движение к CharacterBody2D
func _apply_movement(delta: float) -> void:
	# Если только что прыгнули — не трогаем velocity.y
	if _just_jumped:
		_body.velocity.x = current_speed
		_body.move_and_slide()
		speed_changed.emit(current_speed)
		return

	# Гравитация
	if not _body.is_on_floor():
		_body.velocity.y += gravity * delta
	else:
		_body.velocity.y = 10.0

	# Движение вдоль поверхности
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

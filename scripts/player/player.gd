# player.gd
# Главный скрипт игрока — координирует компоненты
extends CharacterBody2D

signal player_died(cause: String)

@onready var _movement: Node = $MovementController
@onready var _stamina: Node = $StaminaSystem
@onready var _joints: Node = $JointsSystem

var _is_dead: bool = false
# HUD — подключается из main.gd через set_hud()
var _hud: Node = null


func _ready() -> void:
	_movement.jumped.connect(_on_jumped)
	_stamina.stamina_depleted.connect(_on_stamina_depleted)
	_joints.joint_broken.connect(_on_joint_broken)
	_stamina.stamina_changed.connect(_on_stamina_changed)
	_joints.joints_changed.connect(_on_joints_changed)
	_movement.speed_changed.connect(_on_speed_changed)


func _physics_process(_delta: float) -> void:
	if _is_dead:
		return
	_stamina.update(_delta, _movement.current_slope_deg, _movement.is_boosting)
	_joints.update(_delta, _movement.current_slope_deg, _movement.current_speed, _movement.is_braking)


## Подключить HUD снаружи
func set_hud(hud: Node) -> void:
	_hud = hud


func _on_jumped() -> void:
	_stamina.spend_jump()


func _on_stamina_depleted() -> void:
	if _is_dead:
		return
	_is_dead = true
	_movement.set_physics_process(false)
	player_died.emit("Закислился")


func _on_joint_broken() -> void:
	if _is_dead:
		return
	_is_dead = true
	_movement.set_physics_process(false)
	player_died.emit("Травма колена")


func _on_stamina_changed(current: float, maximum: float) -> void:
	if _hud:
		_hud.update_stamina(current, maximum)


func _on_joints_changed(current: float, maximum: float) -> void:
	if _hud:
		_hud.update_joints(current, maximum)


func _on_speed_changed(speed: float) -> void:
	if _hud:
		_hud.update_speed(speed)


# Белый прямоугольник как placeholder
func _draw() -> void:
	draw_rect(Rect2(-8, -24, 16, 24), Color.WHITE)

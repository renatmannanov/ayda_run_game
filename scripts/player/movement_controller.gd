# movement_controller.gd
# Компонент движения персонажа — автобег вправо
class_name MovementController
extends Node

signal speed_changed(current_speed: float)

## Базовая скорость по ровному (px/s)
@export var base_speed: float = 200.0
## Потолок скорости (px/s)
@export var max_speed: float = 400.0
## Гравитация (px/s²)
@export var gravity: float = 980.0

# Текущая скорость
var current_speed: float = 0.0

# Ссылка на CharacterBody2D (родитель)
@onready var _body: CharacterBody2D = get_parent()


func _ready() -> void:
	current_speed = base_speed


func _physics_process(delta: float) -> void:
	# Гравитация — только в воздухе, на полу обнуляем
	if _body.is_on_floor():
		_body.velocity.y = 0.0
	else:
		_body.velocity.y += gravity * delta

	# Автобег вправо с текущей скоростью
	current_speed = clampf(current_speed, 0.0, max_speed)
	_body.velocity.x = current_speed

	_body.move_and_slide()

	speed_changed.emit(current_speed)

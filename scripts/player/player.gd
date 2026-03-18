# player.gd
# Главный скрипт игрока — координирует компоненты
extends CharacterBody2D

signal player_died(cause: String)

@onready var _movement: Node = $MovementController
@onready var _stamina: Node = $StaminaSystem

var _is_dead: bool = false


func _ready() -> void:
	_movement.jumped.connect(_on_jumped)
	_stamina.stamina_depleted.connect(_on_stamina_depleted)


func _physics_process(_delta: float) -> void:
	if _is_dead:
		return
	# Передаём данные из MovementController в StaminaSystem
	_stamina.update(_delta, _movement.current_slope_deg, _movement.is_boosting)


func _on_jumped() -> void:
	_stamina.spend_jump()


func _on_stamina_depleted() -> void:
	if _is_dead:
		return
	_is_dead = true
	_movement.set_physics_process(false)
	player_died.emit("Закислился")
	print("СМЕРТЬ: Закислился!")


# Белый прямоугольник как placeholder
func _draw() -> void:
	draw_rect(Rect2(-8, -24, 16, 24), Color.WHITE)

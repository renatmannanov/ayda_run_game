# stamina_system.gd
# На базовом темпе: финишируешь с 10% stamina.
# Быстрее — тратится больше. Медленнее — восстанавливается.
class_name StaminaSystem
extends Node

signal stamina_depleted()
signal stamina_changed(current: float, maximum: float)

@export var max_stamina: float = 100.0
@export var jump_cost: float = 3.0

# Расход на базовом темпе (рассчитывается в configure)
var _base_drain_rate: float = 0.0
# Базовая скорость для сравнения
var _base_speed: float = 0.0

var current_stamina: float


func _ready() -> void:
	current_stamina = max_stamina


## Настроить: за время забега на базовом темпе потратить 90% stamina
func configure(distance_km: float, pace_min_km: float) -> void:
	_base_speed = Constants.pace_to_speed(pace_min_km)
	var game_time: float = Constants.race_game_time(distance_km, pace_min_km)
	_base_drain_rate = (max_stamina * 0.9) / game_time


func update(delta: float, current_speed: float) -> void:
	if _base_speed <= 0.0:
		return

	var speed_ratio: float = current_speed / _base_speed

	if speed_ratio > 1.05:
		# Быстрее базового — расход квадратично растёт
		var excess: float = speed_ratio - 1.0
		var drain: float = _base_drain_rate * (1.0 + excess * excess * 4.0)
		current_stamina -= drain * delta
	elif speed_ratio < 0.95:
		# Медленнее — восстановление
		var deficit: float = 1.0 - speed_ratio
		var recovery: float = _base_drain_rate * deficit * 2.0
		current_stamina += recovery * delta
	else:
		# На базовом — стандартный расход
		current_stamina -= _base_drain_rate * delta

	current_stamina = clampf(current_stamina, 0.0, max_stamina)
	stamina_changed.emit(current_stamina, max_stamina)

	if current_stamina <= 0.0:
		stamina_depleted.emit()


func spend_jump() -> void:
	current_stamina = maxf(0.0, current_stamina - jump_cost)
	stamina_changed.emit(current_stamina, max_stamina)
	if current_stamina <= 0.0:
		stamina_depleted.emit()

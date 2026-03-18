# stamina_system.gd
# Компонент выносливости — тратится на подъёмах и ускорении, восстанавливается на ровном
class_name StaminaSystem
extends Node

signal stamina_depleted()
signal stamina_changed(current: float, maximum: float)

@export var max_stamina: float = 100.0
## Расход при ускорении (в секунду)
@export var boost_drain_rate: float = 15.0
## Восстановление на ровном (в секунду)
@export var flat_recovery_rate: float = 5.0
## Восстановление на пологом спуске (в секунду)
@export var descent_recovery_rate: float = 3.0
## Расход на прыжок (за раз)
@export var jump_cost: float = 6.0

var current_stamina: float

# Получаем от MovementController через player.gd
var _slope_deg: float = 0.0
var _is_boosting: bool = false


func _ready() -> void:
	current_stamina = max_stamina


func update(delta: float, slope_deg: float, is_boosting: bool) -> void:
	_slope_deg = slope_deg
	_is_boosting = is_boosting

	var drain: float = 0.0
	var recovery: float = 0.0

	# Подъём — расход пропорционально углу
	if _slope_deg > 0.5:
		drain += _slope_deg / 90.0 * 20.0

	# Газ — дополнительный расход
	if _is_boosting:
		drain += boost_drain_rate

	# Восстановление (только если не тратим)
	if drain <= 0.0:
		if abs(_slope_deg) < 0.5:
			# Ровный участок
			recovery = flat_recovery_rate
		elif _slope_deg < -0.5 and abs(_slope_deg) < 15.0:
			# Пологий спуск
			recovery = descent_recovery_rate

	current_stamina -= drain * delta
	current_stamina += recovery * delta
	current_stamina = clampf(current_stamina, 0.0, max_stamina)

	stamina_changed.emit(current_stamina, max_stamina)

	if current_stamina <= 0.0:
		stamina_depleted.emit()


## Расход на прыжок — вызывается при прыжке
func spend_jump() -> void:
	current_stamina = maxf(0.0, current_stamina - jump_cost)
	stamina_changed.emit(current_stamina, max_stamina)
	if current_stamina <= 0.0:
		stamina_depleted.emit()

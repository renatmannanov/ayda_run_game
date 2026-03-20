# joints_system.gd
# Суставы — урон от ударной нагрузки на спусках.
# Основано на биомеханике: нагрузка на колени 2-10x веса тела в зависимости от уклона.
# Торможение снижает пиковые силы на 30-50% (реальные данные).
class_name JointsSystem
extends Node

signal joint_broken()
signal joints_changed(current: float, maximum: float)

@export var max_joints: float = 100.0
## Множитель снижения урона при торможении (0.4 = 60% снижение)
@export var brake_damage_multiplier: float = 0.4
## Общий множитель урона (для баланса)
@export var damage_scale: float = 15.0

var current_joints: float


func _ready() -> void:
	current_joints = max_joints


func update(delta: float, slope_deg: float, current_speed: float, is_braking: bool) -> void:
	# Урон только на спуске
	if slope_deg >= -1.0:
		return

	var abs_slope: float = abs(slope_deg)

	# Ударная нагрузка пропорциональна скорости² и углу
	# На ровном: 2-3x веса тела. На -30°: 7-10x.
	# Нормализуем: base_speed (200 px/s) на ровном = 0 урона
	var speed_factor: float = (current_speed / 200.0) * (current_speed / 200.0)
	var slope_factor: float = abs_slope / 15.0  # 15° = коэффициент 1.0

	var damage: float = speed_factor * slope_factor * damage_scale * delta

	# Торможение — короткие шаги, контролируемый спуск
	if is_braking:
		damage *= brake_damage_multiplier

	current_joints = maxf(0.0, current_joints - damage)
	joints_changed.emit(current_joints, max_joints)

	if current_joints <= 0.0:
		joint_broken.emit()

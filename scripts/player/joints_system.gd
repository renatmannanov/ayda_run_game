# joints_system.gd
# Компонент суставов — бьются на быстрых спусках без торможения
class_name JointsSystem
extends Node

signal joint_broken()
signal joints_changed(current: float, maximum: float)

@export var max_joints: float = 100.0
## Порог скорости для урона (px/s)
@export var damage_speed_threshold: float = 250.0
## Множитель снижения урона при торможении (0.2 = 80% снижение)
@export var brake_damage_multiplier: float = 0.2
## Общий множитель урона (для баланса)
@export var damage_multiplier: float = 40.0

var current_joints: float


func _ready() -> void:
	current_joints = max_joints


func update(delta: float, slope_deg: float, current_speed: float, is_braking: bool) -> void:
	# Урон только на спуске и при скорости выше порога
	if slope_deg >= -0.5 or current_speed <= damage_speed_threshold:
		return

	var abs_slope: float = abs(slope_deg)
	var damage: float = (current_speed - damage_speed_threshold) / 100.0 * abs_slope / 45.0 * damage_multiplier * delta

	# Торможение снижает урон на 80%
	if is_braking:
		damage *= brake_damage_multiplier

	current_joints = maxf(0.0, current_joints - damage)
	joints_changed.emit(current_joints, max_joints)

	if current_joints <= 0.0:
		joint_broken.emit()

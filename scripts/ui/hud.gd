# hud.gd
# HUD — stamina, темп, дистанция
extends CanvasLayer

@onready var _stamina_bar: ProgressBar = $StaminaBar
@onready var _joints_bar: ProgressBar = $JointsBar  # используем как прогресс дистанции
@onready var _speed_label: Label = $SpeedLabel


func _ready() -> void:
	_joints_bar.value = 0


func update_stamina(current: float, maximum: float) -> void:
	_stamina_bar.max_value = maximum
	_stamina_bar.value = current


func update_joints(_current: float, _maximum: float) -> void:
	pass


func update_speed(speed_pxs: float) -> void:
	var pace: float = Constants.speed_to_pace(speed_pxs)
	var mins: int = int(pace)
	var secs: int = int((pace - mins) * 60.0)
	_speed_label.text = "%d:%02d/км" % [mins, secs]


func update_distance(current_km: float, total_km: float) -> void:
	_joints_bar.max_value = total_km
	_joints_bar.value = current_km

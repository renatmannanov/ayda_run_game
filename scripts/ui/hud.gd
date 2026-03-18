# hud.gd
# HUD — полоски Stamina, Joints и скорость
extends CanvasLayer

@onready var _stamina_bar: ProgressBar = $StaminaBar
@onready var _joints_bar: ProgressBar = $JointsBar
@onready var _speed_label: Label = $SpeedLabel


func update_stamina(current: float, maximum: float) -> void:
	_stamina_bar.max_value = maximum
	_stamina_bar.value = current


func update_joints(current: float, maximum: float) -> void:
	_joints_bar.max_value = maximum
	_joints_bar.value = current


func update_speed(speed: float) -> void:
	_speed_label.text = str(int(speed))

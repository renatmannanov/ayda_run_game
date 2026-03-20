# route_select.gd
# Двухшаговый выбор: бегун → дистанция
extends CanvasLayer

signal route_selected(route_id: int)

@onready var _panel: Panel = $Panel
@onready var _title: Label = $Panel/Title

var _runner_buttons: Array[Button] = []
var _dist_buttons: Array[Button] = []
var _step: int = 0  # 0=выбор бегуна, 1=выбор дистанции


func _ready() -> void:
	# Создаём кнопки программно
	_create_runner_buttons()
	show_menu()


func show_menu() -> void:
	_step = 0
	_show_runner_step()
	visible = true
	get_tree().paused = true


func _show_runner_step() -> void:
	_title.text = "Выбери бегуна"
	_clear_buttons(_dist_buttons)
	for btn in _runner_buttons:
		btn.visible = true


func _show_dist_step() -> void:
	_title.text = "Выбери дистанцию"
	for btn in _runner_buttons:
		btn.visible = false
	_create_dist_buttons()


func _create_runner_buttons() -> void:
	var names := ["Мощный (3:00/км)", "Любитель (6:00/км)", "Немощный (9:00/км)"]
	for i in range(names.size()):
		var btn := Button.new()
		btn.text = names[i]
		btn.custom_minimum_size = Vector2(140, 20)
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_panel.add_child(btn)
		btn.position = Vector2(90, 50 + i * 28)
		var idx: int = i
		btn.pressed.connect(func() -> void: _on_runner_picked(idx))
		_runner_buttons.append(btn)


func _create_dist_buttons() -> void:
	var names: Array[String] = ["5K", "10K", "Полумарафон (21K)", "Марафон (42K)"]
	for i in range(names.size()):
		var btn := Button.new()
		btn.text = names[i]
		btn.custom_minimum_size = Vector2(140, 20)
		_panel.add_child(btn)
		btn.position = Vector2(90, 50 + i * 28)
		var idx: int = i
		btn.pressed.connect(func() -> void: _on_dist_picked(idx))
		_dist_buttons.append(btn)


func _clear_buttons(arr: Array[Button]) -> void:
	for btn in arr:
		btn.queue_free()
	arr.clear()


func _on_runner_picked(idx: int) -> void:
	GameState.selected_runner = idx
	_step = 1
	_show_dist_step()


func _on_dist_picked(idx: int) -> void:
	visible = false
	get_tree().paused = false
	route_selected.emit(idx)

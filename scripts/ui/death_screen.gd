# death_screen.gd
# Экран смерти — показывает причину, кнопки "Ещё раз" и "Выйти"
extends CanvasLayer

signal retry_pressed()
signal quit_pressed()

@onready var _cause_label: Label = $Panel/CauseLabel
@onready var _retry_button: Button = $Panel/RetryButton
@onready var _quit_button: Button = $Panel/QuitButton


func _ready() -> void:
	_retry_button.pressed.connect(_on_retry)
	_quit_button.pressed.connect(_on_quit)
	hide_screen()


func show_death(cause: String) -> void:
	_cause_label.text = cause
	visible = true
	# Пауза чтобы ничего не двигалось на фоне
	get_tree().paused = true


func hide_screen() -> void:
	visible = false


func _on_retry() -> void:
	get_tree().paused = false
	retry_pressed.emit()


func _on_quit() -> void:
	get_tree().paused = false
	quit_pressed.emit()

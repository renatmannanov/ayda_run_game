# main.gd
# Связывает Player, HUD, DeathScreen и Terrain
extends Node2D

@onready var _player: CharacterBody2D = $Player
@onready var _hud: CanvasLayer = $HUD
@onready var _death_screen: CanvasLayer = $DeathScreen
@onready var _terrain: Node2D = $Terrain


func _ready() -> void:
	_player.set_hud(_hud)
	_player.player_died.connect(_on_player_died)
	_death_screen.retry_pressed.connect(_on_retry)
	_death_screen.quit_pressed.connect(_on_quit)
	_terrain.player_finished.connect(_on_player_finished)


func _on_player_died(cause: String) -> void:
	_death_screen.show_death(cause)


func _on_player_finished() -> void:
	_player.set_physics_process(false)
	_death_screen.show_death("Вершина! Фурманова покорён")


func _on_retry() -> void:
	get_tree().reload_current_scene()


func _on_quit() -> void:
	get_tree().quit()

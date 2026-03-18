# main.gd
# Связывает Player и HUD
extends Node2D

@onready var _player: CharacterBody2D = $Player
@onready var _hud: CanvasLayer = $HUD


func _ready() -> void:
	_player.set_hud(_hud)
	_player.player_died.connect(_on_player_died)


func _on_player_died(cause: String) -> void:
	print("СМЕРТЬ: ", cause)

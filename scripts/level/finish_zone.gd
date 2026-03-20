# finish_zone.gd
# Зона финиша — игрок пересёк, забег окончен
class_name FinishZone
extends Area2D

signal player_finished()


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_finished.emit()

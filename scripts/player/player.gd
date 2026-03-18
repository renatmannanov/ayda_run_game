# player.gd
# Главный скрипт игрока — рисует placeholder и координирует компоненты
extends CharacterBody2D

# Белый прямоугольник как placeholder пока нет спрайтов
func _draw() -> void:
	draw_rect(Rect2(-8, -24, 16, 24), Color.WHITE)

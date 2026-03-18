# obstacle.gd
# Препятствие на трассе — камень или корень
# При столкновении: потеря скорости + урон по Joints
class_name Obstacle
extends Area2D

signal hit_by_player()

## Потеря скорости при столкновении (px/s)
@export var speed_penalty: float = 100.0
## Урон по Joints при столкновении
@export var joints_damage: float = 12.0

var _was_hit: bool = false


## Вызывается игроком при столкновении, возвращает данные урона
func take_hit() -> Dictionary:
	if _was_hit:
		return {}
	_was_hit = true
	hit_by_player.emit()
	# Мигаем красным
	var visual: ColorRect = $Visual
	visual.color = Color(1.0, 0.2, 0.2, 1.0)
	return {"speed_penalty": speed_penalty, "joints_damage": joints_damage}

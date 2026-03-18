# terrain_generator.gd
# Генерирует тестовый рельеф из сегментов с разным наклоном
# Создаёт StaticBody2D с CollisionPolygon2D + Polygon2D для визуала
class_name TerrainGenerator
extends Node2D

# Сегмент рельефа: длина по X и угол наклона в градусах (+ подъём, - спуск)
const SEGMENTS: Array[Dictionary] = [
	{"length": 300.0, "angle": 0.0},    # ровный старт
	{"length": 200.0, "angle": 15.0},   # пологий подъём
	{"length": 150.0, "angle": 0.0},    # отдых
	{"length": 200.0, "angle": 30.0},   # крутой подъём
	{"length": 200.0, "angle": 0.0},    # отдых
	{"length": 250.0, "angle": -20.0},  # пологий спуск
	{"length": 150.0, "angle": 0.0},    # отдых
	{"length": 250.0, "angle": -35.0},  # крутой спуск
	{"length": 150.0, "angle": 0.0},    # отдых
	{"length": 600.0, "angle": -40.0},  # длинный крутой спуск — тест Joints
	{"length": 300.0, "angle": 0.0},    # ровный финиш
]

# Глубина земли вниз от поверхности (для визуала)
const GROUND_DEPTH: float = 200.0

# Цвет земли
const GROUND_COLOR: Color = Color(0.3, 0.25, 0.2, 1.0)

var _surface_points: PackedVector2Array = PackedVector2Array()


func _ready() -> void:
	_generate_terrain()


func _generate_terrain() -> void:
	# Строим точки поверхности из сегментов
	_surface_points.clear()
	var current_pos := Vector2.ZERO
	_surface_points.append(current_pos)

	for seg in SEGMENTS:
		var angle_rad: float = deg_to_rad(-seg["angle"])  # минус т.к. Y вниз в Godot
		var dx: float = seg["length"]
		var dy: float = tan(angle_rad) * dx
		current_pos += Vector2(dx, dy)
		_surface_points.append(current_pos)

	# Создаём полигон коллизии (поверхность + дно)
	var collision_points := PackedVector2Array()
	# Верхние точки (поверхность)
	for point in _surface_points:
		collision_points.append(point)
	# Нижние точки (дно, справа налево)
	var last_x: float = _surface_points[_surface_points.size() - 1].x
	var max_y: float = 0.0
	for point in _surface_points:
		if point.y > max_y:
			max_y = point.y
	var bottom_y: float = max_y + GROUND_DEPTH
	collision_points.append(Vector2(last_x, bottom_y))
	collision_points.append(Vector2(0.0, bottom_y))

	# StaticBody2D с коллизией
	var body := StaticBody2D.new()
	body.name = "TerrainBody"
	add_child(body)

	var col_shape := CollisionPolygon2D.new()
	col_shape.polygon = collision_points
	body.add_child(col_shape)

	# Визуал — Polygon2D
	var visual := Polygon2D.new()
	visual.polygon = collision_points
	visual.color = GROUND_COLOR
	body.add_child(visual)


## Возвращает массив точек поверхности для других систем
func get_surface_points() -> PackedVector2Array:
	return _surface_points

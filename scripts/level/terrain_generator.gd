# terrain_generator.gd
# Генерирует тестовый рельеф из сегментов с разным наклоном
# Создаёт StaticBody2D с CollisionPolygon2D + Polygon2D для визуала
class_name TerrainGenerator
extends Node2D

# Маршрут Фурманова — старт внизу, финиш на вершине
# Реальность: ~12 км, набор ~1000м. Тут сжато до ~1 мин для тестирования
const SEGMENTS: Array[Dictionary] = [
	# === Старт (пос. Фурманова, ~1100м) ===
	{"length": 200.0, "angle": 0.0},     # разбег по ровному
	# === Подъём по тропе к гребню ===
	{"length": 200.0, "angle": 10.0},    # пологий заход, разогрев
	{"length": 250.0, "angle": 20.0},    # тропа набирает крутизну
	{"length": 100.0, "angle": 5.0},     # небольшая передышка
	{"length": 300.0, "angle": 25.0},    # основной подъём — тут жрёт stamina
	{"length": 150.0, "angle": 30.0},    # крутой участок перед гребнем
	# === Гребень (~1800м) — передышка ===
	{"length": 120.0, "angle": 0.0},     # ровный гребень, восстановление
	{"length": 100.0, "angle": -5.0},    # лёгкий спуск, ещё отдых
	# === Финальный подъём на вершину (~2050м) ===
	{"length": 200.0, "angle": 15.0},    # второе дыхание
	{"length": 250.0, "angle": 28.0},    # финальный рывок
	# === Вершина — финиш! ===
	{"length": 150.0, "angle": 0.0},     # вершина, финишная площадка
]

# Глубина земли вниз от поверхности (для визуала)
const GROUND_DEPTH: float = 200.0

# Цвет земли
const GROUND_COLOR: Color = Color(0.3, 0.25, 0.2, 1.0)

## Сцена препятствия
@export var obstacle_scene: PackedScene
## Сцена финишной зоны
@export var finish_scene: PackedScene
## Среднее расстояние между препятствиями (px)
@export var obstacle_spacing: float = 200.0

signal player_finished()

var _surface_points: PackedVector2Array = PackedVector2Array()


func _ready() -> void:
	_generate_terrain()
	_spawn_obstacles()
	_spawn_finish()


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


## Раскидываем препятствия по поверхности
func _spawn_obstacles() -> void:
	if obstacle_scene == null:
		return

	# Проходим по сегментам поверхности и ставим камни
	var x_cursor: float = 400.0  # не ставить на старте
	var total_x: float = _surface_points[_surface_points.size() - 1].x - 200.0  # не ставить у финиша

	while x_cursor < total_x:
		# Случайный разброс от среднего расстояния
		x_cursor += obstacle_spacing * randf_range(0.5, 1.5)
		if x_cursor >= total_x:
			break

		# Находим Y поверхности в этой точке (линейная интерполяция)
		var y_pos: float = _get_surface_y(x_cursor)

		var obs: Node = obstacle_scene.instantiate()
		obs.position = Vector2(x_cursor, y_pos)
		add_child(obs)


## Получить Y поверхности для заданного X
func _get_surface_y(x: float) -> float:
	for i in range(_surface_points.size() - 1):
		var p1: Vector2 = _surface_points[i]
		var p2: Vector2 = _surface_points[i + 1]
		if x >= p1.x and x <= p2.x:
			var t: float = (x - p1.x) / (p2.x - p1.x)
			return lerp(p1.y, p2.y, t)
	return 0.0


## Ставим финишный флаг в конце маршрута
func _spawn_finish() -> void:
	if finish_scene == null:
		return
	var finish_x: float = _surface_points[_surface_points.size() - 1].x - 100.0
	var finish_y: float = _get_surface_y(finish_x)
	var finish: Node2D = finish_scene.instantiate()
	finish.position = Vector2(finish_x, finish_y)
	add_child(finish)
	# Прокидываем сигнал финиша наверх
	if finish.has_signal("player_finished"):
		finish.player_finished.connect(func() -> void: player_finished.emit())


## Возвращает массив точек поверхности для других систем
func get_surface_points() -> PackedVector2Array:
	return _surface_points

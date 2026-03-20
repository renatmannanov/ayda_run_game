# terrain_generator.gd
# Генерирует плоский рельеф с км-отметками и финишем
class_name TerrainGenerator
extends Node2D

@export var route_id: int = 0

const GROUND_DEPTH: float = 200.0
const GRASS_COLOR := Color(0.3, 0.55, 0.2)
const DIRT_COLOR := Color(0.4, 0.3, 0.2)
const GRASS_THICKNESS: float = 4.0

# Дистанции в км
const DIST_KM: Array[float] = [5.0, 10.0, 21.0, 42.0]

var _surface_points: PackedVector2Array = PackedVector2Array()


func _ready() -> void:
	pass


func generate() -> void:
	var km: float = DIST_KM[route_id] if route_id < DIST_KM.size() else 5.0
	var total_px: float = Constants.km_to_terrain(km)
	_build_flat_terrain(total_px)
	_spawn_km_markers(km)
	_spawn_finish_line(total_px)


func _build_flat_terrain(length_px: float) -> void:
	_surface_points.clear()
	_surface_points.append(Vector2.ZERO)
	_surface_points.append(Vector2(length_px + 200.0, 0.0))  # +200 запас после финиша

	var collision_points := PackedVector2Array()
	for point in _surface_points:
		collision_points.append(point)
	collision_points.append(Vector2(length_px + 200.0, GROUND_DEPTH))
	collision_points.append(Vector2(0.0, GROUND_DEPTH))

	var body := StaticBody2D.new()
	body.name = "TerrainBody"
	add_child(body)

	var col_shape := CollisionPolygon2D.new()
	col_shape.polygon = collision_points
	body.add_child(col_shape)

	var dirt := Polygon2D.new()
	dirt.polygon = collision_points
	dirt.color = DIRT_COLOR
	body.add_child(dirt)

	var grass_points := PackedVector2Array()
	for point in _surface_points:
		grass_points.append(point)
	for i in range(_surface_points.size() - 1, -1, -1):
		grass_points.append(_surface_points[i] + Vector2(0, GRASS_THICKNESS))
	var grass := Polygon2D.new()
	grass.polygon = grass_points
	grass.color = GRASS_COLOR
	body.add_child(grass)


func _spawn_km_markers(total_km: float) -> void:
	var km_px: float = Constants.KM_TO_PX
	for km in range(1, int(total_km) + 1):
		var x: float = km * km_px
		var marker := Node2D.new()
		marker.position = Vector2(x, 0.0)
		add_child(marker)
		# Вертикальная линия
		var line := Line2D.new()
		line.add_point(Vector2(0, -40))
		line.add_point(Vector2(0, 0))
		line.width = 1.0
		line.default_color = Color(1, 1, 1, 0.4)
		marker.add_child(line)
		# Текст
		var label := Label.new()
		label.text = "%d" % km
		label.position = Vector2(-4, -52)
		label.add_theme_font_size_override("font_size", 8)
		label.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
		marker.add_child(label)


func _spawn_finish_line(total_px: float) -> void:
	var finish := Node2D.new()
	finish.position = Vector2(total_px, 0.0)
	add_child(finish)
	# Красная линия
	var line := Line2D.new()
	line.add_point(Vector2(0, -60))
	line.add_point(Vector2(0, 0))
	line.width = 3.0
	line.default_color = Color(1, 0.2, 0.2, 0.9)
	finish.add_child(line)
	# Текст
	var label := Label.new()
	label.text = "FINISH"
	label.position = Vector2(-14, -72)
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	finish.add_child(label)

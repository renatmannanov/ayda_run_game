# parallax_background.gd
# Параллакс-фон на CanvasLayer — никакого дрыгания
# Рисует небо + 3 слоя гор + деревья. Всё кодом.
class_name ParallaxBG
extends CanvasLayer

# Рисуем через Control чтобы покрыть весь экран
var _canvas: Control = null
var _camera: Camera2D = null

const SCREEN_W: float = 320.0
const SCREEN_H: float = 180.0

# Небо
const SKY_TOP := Color(0.35, 0.55, 0.85)
const SKY_BOTTOM := Color(0.65, 0.78, 0.92)

# Горы — 3 слоя
const MOUNTAIN_COLORS: Array[Color] = [
	Color(0.5, 0.55, 0.65),    # дальние — бледные
	Color(0.38, 0.45, 0.55),   # средние
	Color(0.28, 0.35, 0.45),   # ближние — тёмные
]
const MOUNTAIN_PARALLAX: Array[float] = [0.02, 0.06, 0.12]
const MOUNTAIN_BASE_Y: Array[float] = [100.0, 120.0, 145.0]
const MOUNTAIN_HEIGHT: Array[float] = [70.0, 55.0, 40.0]

# Деревья
const TREE_COLOR := Color(0.18, 0.32, 0.18)
const TREE_PARALLAX: float = 0.2
const TREE_BASE_Y: float = 155.0


func _ready() -> void:
	# Ставим слой ниже всего
	layer = -10
	# Control для рисования на весь экран
	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.size = Vector2(SCREEN_W, SCREEN_H)
	add_child(_canvas)
	_canvas.draw.connect(_on_draw)


func _process(_delta: float) -> void:
	if _camera == null:
		_camera = get_viewport().get_camera_2d()
	_canvas.queue_redraw()


func _on_draw() -> void:
	if _camera == null:
		return
	var cam_x: float = _camera.global_position.x

	# --- Небо на весь экран ---
	_draw_sky()

	# --- Горы ---
	for i in range(3):
		_draw_mountains(i, cam_x)

	# --- Деревья ---
	_draw_trees(cam_x)


func _draw_sky() -> void:
	var strips: int = 10
	var strip_h: float = SCREEN_H / strips
	for i in range(strips):
		var t: float = float(i) / float(strips)
		var color: Color = SKY_TOP.lerp(SKY_BOTTOM, t)
		_canvas.draw_rect(Rect2(0, i * strip_h, SCREEN_W, strip_h + 1), color)


func _draw_mountains(layer_idx: int, cam_x: float) -> void:
	var color: Color = MOUNTAIN_COLORS[layer_idx]
	var parallax: float = MOUNTAIN_PARALLAX[layer_idx]
	var base_y: float = MOUNTAIN_BASE_Y[layer_idx]
	var height: float = MOUNTAIN_HEIGHT[layer_idx]

	var offset_x: float = cam_x * parallax
	var spacing: float = 55.0 + layer_idx * 15.0

	# Начинаем за экраном слева
	var start_x: float = -fmod(offset_x, spacing) - spacing

	var points := PackedVector2Array()
	points.append(Vector2(-10, base_y))

	var x: float = start_x
	while x < SCREEN_W + spacing * 2:
		var h: float = height * (0.6 + 0.4 * _hash(x + layer_idx * 500.0))
		points.append(Vector2(x, base_y))
		points.append(Vector2(x + spacing * 0.5, base_y - h))
		points.append(Vector2(x + spacing, base_y))
		x += spacing

	points.append(Vector2(SCREEN_W + 10, base_y))
	# Замыкаем снизу
	points.append(Vector2(SCREEN_W + 10, SCREEN_H))
	points.append(Vector2(-10, SCREEN_H))

	if points.size() >= 3:
		_canvas.draw_colored_polygon(points, color)


func _draw_trees(cam_x: float) -> void:
	var offset_x: float = cam_x * TREE_PARALLAX
	var spacing: float = 20.0
	var start_x: float = -fmod(offset_x, spacing) - spacing

	var x: float = start_x
	while x < SCREEN_W + spacing * 2:
		var h: float = 12.0 + 10.0 * _hash(x * 3.1)
		var w: float = 5.0 + 3.0 * _hash(x * 7.3)

		# Ёлка-треугольник
		var tree := PackedVector2Array()
		tree.append(Vector2(x, TREE_BASE_Y))
		tree.append(Vector2(x - w / 2.0, TREE_BASE_Y))
		tree.append(Vector2(x, TREE_BASE_Y - h))
		tree.append(Vector2(x + w / 2.0, TREE_BASE_Y))
		_canvas.draw_colored_polygon(tree, TREE_COLOR)

		x += spacing


## Стабильный хеш от float — одни горы всегда одинаковые
func _hash(x: float) -> float:
	return fmod(abs(sin(x * 12.9898 + 78.233) * 43758.5453), 1.0)

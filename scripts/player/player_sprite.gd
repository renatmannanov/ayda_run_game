# player_sprite.gd
# Пиксельный бегун — рисуется кодом, анимация из кадров
class_name PlayerSprite
extends Node2D

# Цвета
const COLOR_SKIN := Color(0.9, 0.7, 0.55)
const COLOR_HAIR := Color(0.2, 0.15, 0.1)
const COLOR_SHIRT := Color(0.2, 0.5, 0.8)
const COLOR_SHORTS := Color(0.15, 0.15, 0.15)
const COLOR_SHOES := Color(0.8, 0.3, 0.2)
const COLOR_SOCK := Color(0.95, 0.95, 0.95)

# Кадры анимации бега — позиции ног (offset_x, offset_y для каждой ноги)
# Каждый кадр: [left_foot_x, left_foot_y, right_foot_x, right_foot_y, arm_phase]
const RUN_FRAMES := [
	[1, 0, -1, 0, 0],    # нейтральная
	[3, 0, -2, 1, 1],    # левая вперёд
	[1, 0, -1, 0, 2],    # нейтральная (проход)
	[-2, 1, 3, 0, 3],    # правая вперёд
]

var _frame: int = 0
var _frame_timer: float = 0.0
var _is_jumping: bool = false
var _is_dead: bool = false

## Скорость анимации зависит от скорости бега
var animation_speed: float = 8.0


func _process(delta: float) -> void:
	if _is_dead:
		return
	_frame_timer += delta * animation_speed
	if _frame_timer >= 1.0:
		_frame_timer -= 1.0
		_frame = (_frame + 1) % RUN_FRAMES.size()
	queue_redraw()


func set_jumping(jumping: bool) -> void:
	_is_jumping = jumping


func set_dead(dead: bool) -> void:
	_is_dead = dead
	queue_redraw()


func set_run_speed(speed: float) -> void:
	# Быстрее бежит — быстрее ноги мельтешат
	animation_speed = clampf(speed / 25.0, 4.0, 16.0)


func _draw() -> void:
	if _is_dead:
		_draw_dead()
		return
	if _is_jumping:
		_draw_jump()
		return
	_draw_run()


func _draw_run() -> void:
	var f: Array = RUN_FRAMES[_frame]
	var lf_x: int = f[0]  # left foot offset x
	var lf_y: int = f[1]  # left foot offset y
	var rf_x: int = f[2]  # right foot offset x
	var rf_y: int = f[3]  # right foot offset y
	var arm: int = f[4]   # arm phase

	# --- Голова ---
	# Волосы
	_px(-2, -23, 5, 2, COLOR_HAIR)
	# Лицо
	_px(-1, -21, 3, 3, COLOR_SKIN)
	# Повязка на лоб
	_px(-2, -22, 5, 1, COLOR_SHOES)

	# --- Тело (футболка) ---
	_px(-3, -18, 7, 7, COLOR_SHIRT)

	# --- Руки (двигаются в противофазе ногам) ---
	var la_x: int = -1 if arm < 2 else 1
	var ra_x: int = 1 if arm < 2 else -1
	_px(-4 + la_x, -17, 2, 4, COLOR_SKIN)  # левая рука
	_px(4 + ra_x, -17, 2, 4, COLOR_SKIN)   # правая рука

	# --- Шорты ---
	_px(-2, -11, 5, 3, COLOR_SHORTS)

	# --- Ноги ---
	# Левая нога
	_px(-2 + lf_x, -8 - lf_y, 2, 4, COLOR_SKIN)
	_px(-2 + lf_x, -4 - lf_y, 2, 1, COLOR_SOCK)
	_px(-2 + lf_x, -3 - lf_y, 2, 2, COLOR_SHOES)

	# Правая нога
	_px(1 + rf_x, -8 - rf_y, 2, 4, COLOR_SKIN)
	_px(1 + rf_x, -4 - rf_y, 2, 1, COLOR_SOCK)
	_px(1 + rf_x, -3 - rf_y, 2, 2, COLOR_SHOES)


func _draw_jump() -> void:
	# Ноги подняты, руки вверх
	# Голова
	_px(-2, -23, 5, 2, COLOR_HAIR)
	_px(-1, -21, 3, 3, COLOR_SKIN)
	_px(-2, -22, 5, 1, COLOR_SHOES)
	# Тело
	_px(-3, -18, 7, 7, COLOR_SHIRT)
	# Руки вверх
	_px(-5, -20, 2, 3, COLOR_SKIN)
	_px(5, -20, 2, 3, COLOR_SKIN)
	# Шорты
	_px(-2, -11, 5, 3, COLOR_SHORTS)
	# Ноги согнуты (подняты)
	_px(-2, -8, 2, 3, COLOR_SKIN)
	_px(1, -8, 2, 3, COLOR_SKIN)
	_px(-3, -5, 2, 2, COLOR_SHOES)
	_px(2, -5, 2, 2, COLOR_SHOES)


func _draw_dead() -> void:
	# Лежит на боку
	# Тело горизонтально
	_px(-8, -4, 14, 5, COLOR_SHIRT)
	# Голова
	_px(-10, -6, 3, 3, COLOR_SKIN)
	_px(-11, -7, 4, 2, COLOR_HAIR)
	# Ноги
	_px(5, -2, 5, 2, COLOR_SHORTS)
	_px(9, -2, 3, 2, COLOR_SKIN)
	_px(11, -2, 2, 2, COLOR_SHOES)


## Рисуем прямоугольник в пиксельных координатах
func _px(x: int, y: int, w: int, h: int, color: Color) -> void:
	draw_rect(Rect2(x, y, w, h), color)

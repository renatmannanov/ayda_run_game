# movement_controller.gd
# Компонент движения персонажа — автобег вправо с реакцией на рельеф
class_name MovementController
extends Node

signal speed_changed(current_speed: float)
signal slope_changed(slope_deg: float)

## Базовая скорость по ровному (px/s)
@export var base_speed: float = 200.0
## Потолок скорости (px/s)
@export var max_speed: float = 400.0
## Гравитация (px/s²)
@export var gravity: float = 980.0

# Текущая горизонтальная скорость
var current_speed: float = 0.0
# Текущий угол наклона (градусы, + подъём, - спуск)
var current_slope_deg: float = 0.0

# Ссылка на CharacterBody2D (родитель)
@onready var _body: CharacterBody2D = get_parent()


func _ready() -> void:
	current_speed = base_speed


func _physics_process(delta: float) -> void:
	_update_slope()
	_update_speed(delta)
	_apply_movement(delta)


## Определяем угол наклона поверхности под ногами
func _update_slope() -> void:
	if _body.is_on_floor():
		var floor_normal := _body.get_floor_normal()
		# Угол между нормалью пола и вертикалью
		# Положительный = подъём (бежим вверх), отрицательный = спуск
		current_slope_deg = rad_to_deg(floor_normal.angle_to(Vector2.UP))
		# Знак: если нормаль наклонена влево (мы бежим вправо вверх) — подъём
		if floor_normal.x < 0.0:
			current_slope_deg = abs(current_slope_deg)
		else:
			current_slope_deg = -abs(current_slope_deg)
		slope_changed.emit(current_slope_deg)
	else:
		current_slope_deg = 0.0


## Меняем скорость в зависимости от рельефа
func _update_speed(delta: float) -> void:
	var target_speed: float

	if current_slope_deg > 0.5:
		# Подъём: замедляемся пропорционально углу
		target_speed = base_speed * (1.0 - current_slope_deg / 90.0)
		target_speed = maxf(target_speed, 20.0)  # минимум чтобы не встать
	elif current_slope_deg < -0.5:
		# Спуск: ускоряемся
		target_speed = base_speed + abs(current_slope_deg) * 3.0
	else:
		# Ровный участок
		target_speed = base_speed

	target_speed = clampf(target_speed, 0.0, max_speed)

	# Плавный переход к целевой скорости
	if current_speed < target_speed:
		current_speed = move_toward(current_speed, target_speed, 300.0 * delta)
	else:
		current_speed = move_toward(current_speed, target_speed, 200.0 * delta)


## Применяем движение к CharacterBody2D
func _apply_movement(delta: float) -> void:
	# Гравитация
	if not _body.is_on_floor():
		_body.velocity.y += gravity * delta
	else:
		# Не обнуляем полностью — небольшое давление вниз для стабильного прилипания
		_body.velocity.y = 10.0

	# Движение вдоль поверхности
	if _body.is_on_floor():
		var floor_normal := _body.get_floor_normal()
		# Направление вдоль пола (перпендикулярно нормали, вправо)
		var move_dir := Vector2(-floor_normal.y, floor_normal.x)
		if move_dir.x < 0.0:
			move_dir = -move_dir
		_body.velocity = move_dir * current_speed + Vector2(0, 10.0)
	else:
		_body.velocity.x = current_speed

	_body.move_and_slide()
	speed_changed.emit(current_speed)

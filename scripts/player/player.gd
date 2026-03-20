# player.gd
# Координирует компоненты бегуна
extends CharacterBody2D

signal player_died(cause: String)
signal player_finished_race()

@onready var _movement: Node = $MovementController
@onready var _stamina: Node = $StaminaSystem
@onready var _sprite: Node2D = $PlayerSprite

var _is_dead: bool = false
var _hud: Node = null
var _start_x: float = 0.0
var _total_km: float = 0.0
var _terrain_length_px: float = 0.0


func _ready() -> void:
	_movement.jumped.connect(_on_jumped)
	_stamina.stamina_depleted.connect(_on_stamina_depleted)
	_stamina.stamina_changed.connect(_on_stamina_changed)
	_movement.speed_changed.connect(_on_speed_changed)
	_start_x = global_position.x


func configure(pace_min_km: float, distance_km: float) -> void:
	_total_km = distance_km
	_terrain_length_px = Constants.km_to_terrain(distance_km)
	# Настраиваем движение
	_movement.base_pace_min_km = pace_min_km
	_movement.base_speed = Constants.pace_to_speed(pace_min_km)
	_movement.current_speed = _movement.base_speed
	# Настраиваем stamina
	_stamina.configure(distance_km, pace_min_km)


func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	_stamina.update(delta, _movement.current_speed)
	_sprite.set_jumping(not is_on_floor())
	_sprite.set_run_speed(_movement.current_speed)

	# Дистанция по позиции на terrain
	var progress_px: float = global_position.x - _start_x
	var progress_km: float = clampf(progress_px / _terrain_length_px * _total_km, 0.0, _total_km)
	if _hud and _hud.has_method("update_distance"):
		_hud.update_distance(progress_km, _total_km)

	# Финиш
	if progress_px >= _terrain_length_px:
		_finish()


func set_hud(hud: Node) -> void:
	_hud = hud


func _finish() -> void:
	if _is_dead:
		return
	_is_dead = true
	_movement.set_physics_process(false)
	player_finished_race.emit()


func _on_jumped() -> void:
	_stamina.spend_jump()


func _on_stamina_depleted() -> void:
	if _is_dead:
		return
	_is_dead = true
	_movement.set_physics_process(false)
	_sprite.set_dead(true)
	player_died.emit("Закислился")


func _on_stamina_changed(current: float, maximum: float) -> void:
	if _hud:
		_hud.update_stamina(current, maximum)


func _on_speed_changed(speed: float) -> void:
	if _hud:
		# Конвертируем визуальную скорость обратно в темп
		_hud.update_speed(speed)

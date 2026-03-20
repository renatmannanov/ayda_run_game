# main.gd
# Связывает Player, HUD, DeathScreen, RouteSelect и Terrain
extends Node2D

@onready var _player: CharacterBody2D = $Player
@onready var _hud: CanvasLayer = $HUD
@onready var _death_screen: CanvasLayer = $DeathScreen
@onready var _terrain: Node2D = $Terrain
@onready var _route_select: CanvasLayer = $RouteSelect


func _ready() -> void:
	if GameState.selected_route >= 0 and GameState.selected_runner >= 0:
		# Настраиваем бегуна
		var pace: float = GameState.get_pace()
		var dist_km: float = GameState.get_distance_km()
		_player.configure(pace, dist_km)
		# Генерируем terrain
		_terrain.route_id = GameState.selected_route
		_terrain.generate()
		_route_select.visible = false
		get_tree().paused = false
	else:
		_route_select.show_menu()

	_player.set_hud(_hud)
	_player.player_died.connect(_on_player_died)
	_player.player_finished_race.connect(_on_player_finished)
	_death_screen.retry_pressed.connect(_on_retry)
	_death_screen.quit_pressed.connect(_on_quit)
	_route_select.route_selected.connect(_on_route_selected)


func _on_route_selected(route_id: int) -> void:
	GameState.selected_route = route_id
	get_tree().reload_current_scene()


func _on_player_died(cause: String) -> void:
	var dist_km: float = GameState.get_distance_km()
	var runner_name: String = GameState.RUNNER_NAMES[GameState.selected_runner]
	_death_screen.show_death("%s\n%s на %s" % [cause, runner_name, GameState.DISTANCE_NAMES[GameState.selected_route]])


func _on_player_finished() -> void:
	var runner_name: String = GameState.RUNNER_NAMES[GameState.selected_runner]
	var dist_name: String = GameState.DISTANCE_NAMES[GameState.selected_route]
	_death_screen.show_death("Финиш!\n%s пробежал %s" % [runner_name, dist_name])


func _on_retry() -> void:
	get_tree().reload_current_scene()


func _on_quit() -> void:
	GameState.selected_route = -1
	GameState.selected_runner = -1
	get_tree().reload_current_scene()

# game_state.gd
# Глобальное состояние — сохраняется между reload_current_scene
extends Node

## Выбранная дистанция: 0=5K, 1=10K, 2=21K, 3=42K. -1=не выбрано
var selected_route: int = -1
## Тип бегуна: 0=Мощный, 1=Любитель, 2=Немощный
var selected_runner: int = -1

# Темпы бегунов (мин/км)
const RUNNER_PACES: Array[float] = [3.0, 6.0, 9.0]
const RUNNER_NAMES: Array[String] = ["Мощный", "Любитель", "Немощный"]
# Дистанции
const DISTANCE_NAMES: Array[String] = ["5K", "10K", "Полумарафон", "Марафон"]
const DISTANCE_KM: Array[float] = [5.0, 10.0, 21.0, 42.0]

func get_pace() -> float:
	if selected_runner < 0 or selected_runner >= RUNNER_PACES.size():
		return 6.0
	return RUNNER_PACES[selected_runner]

func get_distance_km() -> float:
	if selected_route < 0 or selected_route >= DISTANCE_KM.size():
		return 5.0
	return DISTANCE_KM[selected_route]

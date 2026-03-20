# constants.gd
# Единственный источник правды для масштабов и констант.
# Все скрипты берут значения отсюда.
class_name Constants

## 1 км реальный = 600 пикселей на экране
const KM_TO_PX: float = 600.0

## Ускорение времени: 1 реальная минута = 1 игровая секунда
const TIME_SCALE: float = 60.0

## Конвертация темпа (мин/км) в визуальную скорость (px/s)
## Формула: KM_TO_PX / (pace * 60) * TIME_SCALE
## Мощный 3:00/км → 200 px/s
## Любитель 6:00/км → 100 px/s
## Немощный 9:00/км → 66.7 px/s
static func pace_to_speed(pace_min_km: float) -> float:
	return KM_TO_PX / (pace_min_km * 60.0) * TIME_SCALE

## Конвертация скорости (px/s) в темп (мин/км) для HUD
static func speed_to_pace(speed_pxs: float) -> float:
	if speed_pxs <= 0.0:
		return 99.0
	return KM_TO_PX * TIME_SCALE / (speed_pxs * 60.0)

## Дистанция км → пиксели terrain
static func km_to_terrain(km: float) -> float:
	return km * KM_TO_PX

## Время забега в игровых секундах
static func race_game_time(distance_km: float, pace_min_km: float) -> float:
	var real_time_sec: float = distance_km * pace_min_km * 60.0
	return real_time_sec / TIME_SCALE

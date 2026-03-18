# CLAUDE.md — Almaty Vertical

Этот файл читается Claude Code автоматически при каждой сессии.
Расположение: корень проекта `ayda-run-game/CLAUDE.md`

---

## Проект

Trail running roguelite side-scroller на Godot 4.
Бегун бежит автоматически, игрок управляет усилием (газ/тормоз) и прыжком.
Две шкалы: Силы (Stamina) и Суставы (Joints). Неправильно распределил — умер.

GDD: см. `docs/GDD_almaty_vertical.md`

---

## Технический стек

- **Движок:** Godot 4.x (GDScript)
- **Разрешение:** 320x180, pixel-perfect scaling
- **Физика:** CharacterBody2D для игрока, тайловые уровни через TileMap

---

## Архитектура — строго следовать

### Разделение файлов
- Логика → `.gd` файлы
- Данные → `.tres` файлы (Resources)
- Структура сцен → `.tscn` файлы

### Структура проекта
```
almaty-vertical/
├── scenes/
│   ├── player/          # Player.tscn + Player.gd
│   ├── levels/          # Level_furmanovo.tscn и т.д.
│   ├── ui/              # HUD.tscn, DeathScreen.tscn
│   └── main.tscn
├── scripts/
│   ├── player/
│   │   ├── player_movement.gd
│   │   ├── stamina_system.gd
│   │   └── joints_system.gd
│   ├── level/
│   │   └── obstacle_spawner.gd
│   └── data/
│       ├── character_data.tres
│       └── route_data.tres
├── assets/
│   ├── sprites/
│   ├── backgrounds/
│   └── ui/
└── docs/
```

### Компонентная архитектура (обязательно)
```
Player (CharacterBody2D)
├── StaminaSystem (Node)      # компонент выносливости
├── JointsSystem (Node)       # компонент суставов
├── MovementController (Node) # физика движения
└── AnimationTree
```

### Сигналы вместо прямых вызовов
```gdscript
# ✅ Правильно
signal stamina_depleted()
signal joint_damaged(amount: float)
stamina_depleted.emit()

# ❌ Неправильно
get_parent().get_parent().game_over()
```

---

## Ключевые механики (как они должны работать)

### Stamina (Силы)
- Максимум: 100.0
- Деградация на подъёме: `slope_deg / 90.0 * 20.0` в секунду (slope_deg — угол наклона в градусах, 0°=ровно, 90°=стена)
- Деградация при ускорении: +15.0 в секунду (суммируется с подъёмом)
- Восстановление на ровном участке: 5.0 в секунду (только если не ускоряется)
- Восстановление на пологом спуске (<15°): 3.0 в секунду
- При 0 → emit `stamina_depleted` → смерть "Закислился"

### Joints (Суставы)
- Максимум: 100.0
- Урон только при спуске БЕЗ торможения и скорости выше порога:
  - Порог: speed > 250 px/s
  - Формула: `(speed - 250.0) / 100.0 * slope_deg / 45.0 * delta` в секунду
  - При торможении (brake зажат) урон снижается на 80%
- НЕ восстанавливается в рамках одного забега
- При 0 → emit `joint_broken` → смерть "Травма колена"
- Дизайн-идея: быстрый спуск = быстрое время, но рискуешь коленями. Торможение безопасно, но медленно.

### Рельеф и скорость
- Базовая скорость: 200 px/s
- На подъёме: скорость снижается пропорционально углу (`base_speed * (1.0 - slope_deg / 90.0)`)
- На спуске: скорость растёт (`base_speed + slope_deg * 3.0`), если не тормозить
- При торможении на спуске: скорость ограничена base_speed
- Ускорение (газ): +150 px/s к текущей скорости (с плавным набором)

### Препятствия (камни/корни) — будем итерировать
- Пока: столкновение = потеря скорости + небольшой урон по Joints (10-15)
- Прыжок через препятствие тратит Stamina (5-8 за прыжок) — бегун не прыгает легко
- Точный баланс определяется через плейтесты

### "Сойти с дистанции"
- Игрок может сознательно выйти в любой точке (кнопка Esc / отдельная)
- Сход ≠ смерть: нет штрафа, прогресс (когда появится мета-прогрессия) сохраняется пропорционально пройденному
- Детали мета-прогрессии — позже

---

## Game Feel параметры

```
# Движение
base_speed = 200        # px/s, скорость по ровному
max_speed = 400         # px/s, потолок скорости
acceleration = 600      # px/s², набор скорости при ускорении
deceleration = 400      # px/s², торможение
brake_deceleration = 800 # px/s², активное торможение (кнопка)

# Прыжок
jump_velocity = -280    # px/s (вверх, Godot Y инвертирован)
jump_height ≈ 48        # px (результирующая высота)
gravity = 980           # px/s²
coyote_time = 0.1       # секунд (можно прыгнуть после обрыва)

# Камера
camera_offset_x = 60    # px, смещение вправо чтобы видеть рельеф впереди
camera_smoothing = 5.0  # скорость следования камеры
```

---

## Input Map (project.godot actions)

```
# Название action      Кнопки
jump                    Space, Up, W
boost                   Shift, Right, D
brake                   S, Down
quit_run                Escape
```

---

## Команды разработки

```bash
# Запуск игры из командной строки
godot --path . scenes/main.tscn

# Запуск конкретной сцены
godot --path . scenes/levels/level_furmanovo.tscn

# Экспорт (после настройки export presets)
godot --headless --export-release "Windows Desktop" build/almaty_vertical.exe
```

---

## Правила кода (обязательно)

1. **Все публичные переменные** через `@export` с типами
2. **Все узлы** через `@onready` — не в `_init()`
3. **Сигналы** для всех межкомпонентных коммуникаций
4. **Комментарии на русском** — это личный проект
5. **Инкрементальная разработка** — после каждого изменения тест в Godot
6. **Не усложнять** — MVP сначала, полировка потом

### Пример правильного компонента
```gdscript
# stamina_system.gd
class_name StaminaSystem
extends Node

signal stamina_depleted()
signal stamina_changed(current: float, maximum: float)

@export var max_stamina: float = 100.0
@export var recovery_rate: float = 5.0

var current_stamina: float = max_stamina

func drain(amount: float) -> void:
    current_stamina = max(0.0, current_stamina - amount)
    stamina_changed.emit(current_stamina, max_stamina)
    if current_stamina <= 0.0:
        stamina_depleted.emit()

func recover(delta: float) -> void:
    current_stamina = min(max_stamina, current_stamina + recovery_rate * delta)
    stamina_changed.emit(current_stamina, max_stamina)
```

---

## Частые ошибки GDScript (избегать)

- `get_node()` в `_init()` → используй `@onready`
- Python-синтаксис (list comprehensions и т.д.) → не работает в GDScript
- `set_process(false)` забыть после смерти → утечки
- Прямые ссылки между сценами → только через сигналы или autoload

---

## Трекер задач и планы

Все планы и задачи: `docs/task_tracker/` (не коммитятся, docs/ в .gitignore)

```
docs/task_tracker/
├── todo/
│   ├── PLAN.md          # главный файл плана со списком этапов
│   └── mvp/             # файлы этапов MVP (00-10)
├── in_progress/         # задачи в работе
├── done/                # завершённые задачи
└── backlog/             # будущие фичи за пределами MVP
```

- Каждый этап — отдельный .md файл (не больше 300 строк)
- Файл перемещается между папками: todo → in_progress → done
- Статус в PLAN.md обновляется вместе с перемещением

### Рабочий цикл
1. Берём задачу из todo/, переносим в in_progress/
2. Делаем
3. Показываем, тестируем в Godot
4. Отмечаем в файле что сделано
5. Переносим в done/
6. Коммит + обновляем PLAN.md

---

## Git-стратегия

- **main** — прод, стабильная версия
- **dev** — рабочая ветка, тестируем тут
- **feature/xxx** — ветка на каждую фичу (от dev)
  - Для больших фич: подветки feature/xxx-yyy
- Порядок: коммит → мерж в фичу → мерж в dev → тест локально → мерж в main → пуш

---

## Бэклог

Полный список будущих фич: `docs/task_tracker/backlog/BACKLOG.md` (не коммитится)

---

## Полезные ссылки

- Godot 4 Docs: https://docs.godotengine.org/en/stable/
- GDScript Reference: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/
- Бесплатные ассеты: https://kenney.nl/assets | https://itch.io/game-assets/free
- godot-mcp (MCP сервер для Godot): https://github.com/Coding-Connoisseur/godot-mcp

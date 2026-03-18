# 🚀 Стартовый промпт для Claude Code
## Almaty Vertical — MVP Session #1

Скопируй этот промпт целиком в Claude Code когда откроешь папку проекта.

---

## ПРОМПТ:

```
Я делаю trail running roguelite на Godot 4. Называется "Almaty Vertical".

Прочитай CLAUDE.md в корне проекта — там вся архитектура и правила.
Прочитай docs/GDD_almaty_vertical.md — там игровой дизайн.

Наша задача сегодня — поднять рабочий MVP прототип. Делаем по шагам,
после каждого шага я тестирую в Godot и говорю что получилось.

## Шаг 1 — Инициализация проекта

Создай структуру папок согласно CLAUDE.md:
scenes/player/, scenes/levels/, scenes/ui/, scripts/player/, scripts/level/, scripts/data/, assets/sprites/, assets/backgrounds/, assets/ui/

Создай .gitignore для Godot (исключить .godot/, *.import, build/).

Создай project.godot с настройками:
- Разрешение: 320x180
- Stretch mode: canvas_items
- Aspect: keep
- Input map из CLAUDE.md: jump (Space/Up/W), boost (Shift/Right/D), brake (S/Down), quit_run (Escape)

## Шаг 2 — Сцена игрока

Создай scenes/player/Player.tscn со структурой:
Player (CharacterBody2D)
├── CollisionShape2D (прямоугольник 16x24)
├── Sprite2D (placeholder — белый прямоугольник пока нет ассетов)
├── StaminaSystem (Node) → scripts/player/stamina_system.gd
├── JointsSystem (Node) → scripts/player/joints_system.gd
└── MovementController (Node) → scripts/player/movement_controller.gd

Напиши все три GDScript файла согласно архитектуре из CLAUDE.md:
- Компонентный подход
- Сигналы для коммуникации
- @export переменные с типами

Механики (см. GDD и CLAUDE.md — секция "Game Feel параметры"):
- Персонаж бежит вправо автоматически (base_speed 200 px/s)
- jump = прыжок (тратит 5-8 Stamina)
- boost = ускорение (+15 Stamina/сек)
- brake = замедление
- На спуске без торможения при скорости > 250 px/s = урон Joints
- На подъёме = расход Stamina пропорционально углу

## Шаг 3 — Тестовый уровень

Создай scenes/levels/level_test.tscn:
- TileMap с простым рельефом: ровный участок → подъём → спуск
- Камера следит за игроком (Camera2D с smoothing)
- Уровень ~60 секунд бега

Используй placeholder тайлы (просто цветные прямоугольники).

## Шаг 4 — HUD

Создай scenes/ui/HUD.tscn:
- Шкала Stamina (зелёная)
- Шкала Joints (синяя)
- Текущая скорость (для отладки)
- HUD подписывается на сигналы StaminaSystem и JointsSystem

## Шаг 5 — Смерть

Создай scenes/ui/DeathScreen.tscn:
- Большой текст с причиной смерти ("Закислился", "Травма колена", "Споткнулся")
- Кнопка "Попробовать снова" → перезагружает уровень
- Кнопка "В меню" (пока просто quit)

## Шаг 6 — Main сцена

Создай scenes/main.tscn которая собирает всё вместе.
Добавь autoload GameState (scripts/game_state.gd) для хранения:
- текущий маршрут
- количество попыток
- причина последней смерти

---

Начни с Шага 1. После каждого шага останавливайся и жди моей команды.
Пиши комментарии в коде на русском языке.
Если что-то неясно — спрашивай, не придумывай.
```

---

## Следующие сессии (промпты на потом)

**Сессия 2 — Реальный уровень Фурманова:**
```
Продолжаем Almaty Vertical. Прочитай CLAUDE.md.
Сегодня делаем первый настоящий уровень — маршрут Фурманова.
Рельеф: старт у подножия → три подъёма с ровными участками между ними
→ финальный спуск → финиш. Общее время ~3 минуты бега.
Добавь систему чекпоинтов каждые 30 секунд.
```

**Сессия 3 — Ассеты и анимации:**
```
Продолжаем Almaty Vertical. Прочитай CLAUDE.md.
Сегодня подключаем пиксельные ассеты из папки assets/sprites/.
Нужно настроить AnimationPlayer для анимаций: run, jump, fall, slide_down.
Все ассеты уже в папке — просто скажи мне какой формат ожидаешь (spritesheet размер/кол-во фреймов).
```

**Сессия 4 — Второй персонаж:**
```
Продолжаем Almaty Vertical. Прочитай CLAUDE.md.
Добавляем второго персонажа "Дизель": высокая выносливость, медленный спуск.
Нужна система выбора персонажа перед забегом и CharacterData.tres ресурс
для хранения статов каждого персонажа.
```

---

## Полезные советы по работе с Claude Code

1. **CLAUDE.md — главный файл.** Всегда кладётся в корень проекта,
   читается автоматически. Если Claude Code "забыл" контекст — напиши:
   "Перечитай CLAUDE.md и продолжим"

2. **Один шаг за раз.** Не проси делать всё сразу — легче отловить баги.

3. **Godot MCP (опционально, мощная штука):**
   Установи godot-mcp сервер — тогда Claude Code сможет сам запускать
   игру и видеть ошибки без твоего участия.
   GitHub: https://github.com/Coding-Connoisseur/godot-mcp

4. **Если что-то сломалось:**
   "Вот ошибка из консоли Godot: [вставь текст].
   Посмотри scripts/player/stamina_system.gd и исправь."

5. **Сохраняй сессии через git:**
   После каждой рабочей сессии делай `git commit`.
   Claude Code может сам делать коммиты — попроси его.

6. **godogen (продвинутый вариант):**
   Репо с готовыми Claude Code skills для Godot 4, включая генерацию ассетов:
   https://github.com/htdt/godogen

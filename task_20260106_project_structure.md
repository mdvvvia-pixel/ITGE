# Task: Создание структуры проекта и базового UI

**Date:** 2026-01-06  
**Status:** Planning  
**Priority:** High  
**Assignee:** [Имя]  
**Related Files:** 
- `TableGraphEditor/src/TableGraphEditor.mlapp`
- `TableGraphEditor/src/helpers/`
- `TableGraphEditor/README.md`

---

## Objective

Создать базовую структуру проекта Table-Graph Editor, включая структуру папок, основной файл App Designer с базовым UI и определение структуры данных.

**Success Criteria:**
- [ ] Создана структура папок проекта
- [ ] Создан файл `TableGraphEditor.mlapp` в App Designer
- [ ] Добавлены все необходимые UI компоненты
- [ ] Определены properties для хранения данных
- [ ] Базовый layout интерфейса готов

---

## Background

### Context
Это первый этап разработки MVP. Необходимо создать основу приложения, на которой будет строиться весь остальной функционал.

### Requirements
- Структура должна соответствовать `.cursorrules`
- UI компоненты должны следовать соглашениям об именовании
- Layout должен быть адаптивным (grid layout)

### Dependencies
- **Requires:** Нет (начальный этап)
- **Blocks:** Все последующие задачи

---

## Approach

### Design Overview
1. Создать структуру папок согласно `.cursorrules`
2. Создать новый файл App Designer
3. Добавить все необходимые UI компоненты
4. Настроить layout (grid layout)
5. Определить properties для хранения данных

### UI Components Required

#### Обязательные компоненты:
- `uitable` - `app.tblData` - таблица данных
- `uiaxes` - `app.axPlot` - область графика
- `uidropdown` - `app.ddVariable` - выбор переменной из workspace
- `uidropdown` - `app.ddPlotType` - выбор типа графика (по столбцам/строкам)
- `uibutton` - `app.btnSave` - кнопка сохранения
- `uibuttongroup` - `app.bgEditMode` - группа кнопок режима редактирования
- `uiradiobutton` - `app.rbModeXY` - режим редактирования XY (для MVP)

#### Опциональные (можно добавить позже):
- Labels для подписей
- Panels для группировки элементов

### Data Structures

```matlab
properties (Access = private)
    % Данные
    originalData        % Исходные данные (полная матрица)
    currentData         % Текущие редактируемые данные
    selectedVariable    % Выбранная переменная из workspace
    editMode = 'XY'     % Режим редактирования: 'XY' (для MVP)
    currentPlotType = 'columns' % 'columns' или 'rows'
    
    % Для выбора части данных
    selectedColumns = [] % Индексы выбранных столбцов
    selectedRows = []    % Индексы выбранных строк
    
    % Метки
    rowLabels = {}      % Метки строк (первый столбец в режиме "по строкам")
    columnLabels = {}   % Метки столбцов (первая строка в режиме "по столбцам")
    
    % Для перетаскивания
    selectedPoint = []  % Индекс выбранной точки [curveIndex, pointIndex]
    isDragging = false  % Флаг перетаскивания
    dragStartPosition = [] % Начальная позиция перетаскивания
end
```

---

## Implementation Plan

### Phase 1: Структура папок
**Goal:** Создать структуру проекта

**Tasks:**
1. Создать папки: `src/`, `src/helpers/`, `test/`, `examples/`, `resources/`, `docs/`
2. Создать `README.md` в корне проекта
3. Создать `docs/README.md`

**Deliverables:**
- [ ] Структура папок создана
- [ ] README файлы созданы

### Phase 2: Создание App Designer файла
**Goal:** Создать базовый файл App Designer

**Tasks:**
1. Открыть App Designer в MATLAB
2. Создать новый файл `TableGraphEditor.mlapp`
3. Сохранить в папку `src/`

**Deliverables:**
- [ ] Файл `TableGraphEditor.mlapp` создан

### Phase 3: Добавление UI компонентов
**Goal:** Добавить все необходимые UI компоненты

**Tasks:**
1. Добавить `uitable` (app.tblData)
2. Добавить `uiaxes` (app.axPlot)
3. Добавить `uidropdown` для выбора переменной (app.ddVariable)
4. Добавить `uidropdown` для типа графика (app.ddPlotType)
5. Добавить `uibutton` для сохранения (app.btnSave)
6. Добавить `uibuttongroup` (app.bgEditMode)
7. Добавить `uiradiobutton` для режима XY (app.rbModeXY)

**Deliverables:**
- [ ] Все UI компоненты добавлены
- [ ] Имена компонентов соответствуют соглашениям

### Phase 4: Настройка Layout
**Goal:** Настроить адаптивный layout

**Tasks:**
1. Использовать Grid Layout для основного окна
2. Разместить компоненты:
   - Верхняя панель: dropdown'ы и кнопки
   - Левая часть: таблица
   - Правая часть: график
   - Нижняя панель: кнопки управления
3. Настроить размеры и пропорции

**Deliverables:**
- [ ] Layout настроен
- [ ] Интерфейс адаптивный

### Phase 5: Определение Properties
**Goal:** Определить структуру данных

**Tasks:**
1. Добавить properties в секцию Properties
2. Инициализировать значения по умолчанию
3. Добавить комментарии к каждому property

**Deliverables:**
- [ ] Все properties определены
- [ ] Значения по умолчанию установлены

---

## Implementation Notes

### Key Decisions
**Decision 1:** Использовать Grid Layout
- **Rationale:** Обеспечивает адаптивность и гибкость
- **Alternatives:** Absolute positioning
- **Trade-offs:** Grid Layout более современный, но требует настройки

**Decision 2:** Хранить метки отдельно от данных
- **Rationale:** Упрощает обработку и отображение
- **Alternatives:** Хранить метки в той же матрице
- **Trade-offs:** Отдельное хранение требует синхронизации

### Technical Challenges
**Challenge 1:** Настройка Grid Layout
- **Solution:** Использовать документацию MATLAB App Designer
- **Notes:** Может потребоваться экспериментирование с размерами

---

## Code Implementation

### Main App File Structure

**File:** `src/TableGraphEditor.mlapp`

**Properties Section:**
```matlab
properties (Access = private)
    % Данные
    originalData        % Исходные данные (полная матрица)
    currentData         % Текущие редактируемые данные
    selectedVariable    % Выбранная переменная из workspace
    editMode = 'XY'     % Режим редактирования: 'XY' (для MVP)
    currentPlotType = 'columns' % 'columns' или 'rows'
    
    % Для выбора части данных
    selectedColumns = [] % Индексы выбранных столбцов
    selectedRows = []    % Индексы выбранных строк
    
    % Метки
    rowLabels = {}      % Метки строк
    columnLabels = {}   % Метки столбцов
    
    % Для перетаскивания
    selectedPoint = []  % Индекс выбранной точки
    isDragging = false  % Флаг перетаскивания
    dragStartPosition = [] % Начальная позиция
end
```

**Status:** Not Started

---

## Testing & Verification

### Test Strategy
Проверить, что все компоненты созданы и доступны.

### Unit Tests
**Test 1: Проверка структуры папок**
```matlab
function test_project_structure()
    % Проверить существование папок
    assert(exist('src', 'dir') == 7, 'Папка src не существует');
    assert(exist('src/helpers', 'dir') == 7, 'Папка helpers не существует');
    assert(exist('test', 'dir') == 7, 'Папка test не существует');
    assert(exist('examples', 'dir') == 7, 'Папка examples не существует');
    assert(exist('docs', 'dir') == 7, 'Папка docs не существует');
end
```

**Status:** Not Started

### Integration Tests
**Test Case 1: Проверка UI компонентов**
- **Description:** Проверить, что все UI компоненты созданы и доступны
- **Input Data:** Запуск приложения
- **Expected Output:** Все компоненты видны и доступны через app.*
- **Status:** Not Started

---

## Documentation Updates

### Files to Update
- [ ] `README.md` - описание проекта
- [ ] `docs/README.md` - структура документации

### Documentation Checklist
- [ ] Структура проекта описана
- [ ] Компоненты перечислены
- [ ] Properties документированы

---

## Progress Log

### 2026-01-06
- Task created
- Initial design completed

### 2026-01-08
- ✅ Структура папок проверена и дополнена (.gitkeep файлы)
- ✅ README.md обновлен с информацией о структуре проекта
- ✅ Создан APP_STRUCTURE_TEMPLATE.md с детальной структурой App Designer
- ✅ Создан SETUP_INSTRUCTIONS.md с пошаговыми инструкциями
- ✅ Создан тестовый файл test_project_structure.m для проверки структуры
- ✅ Файл TableGraphEditor.mlapp создан в MATLAB App Designer
- ✅ Все UI компоненты добавлены
- ✅ Properties добавлены с правильным объявлением (SetAccess = public)
- ✅ Helper функции созданы в папке helpers/
- ✅ startupFcn создан и работает
- ✅ Путь к helpers настроен
- ✅ Все функции работают корректно

---

## Completion Checklist

Before marking this task as complete:

- [x] Все папки созданы
- [x] Файл App Designer создан
- [x] Все UI компоненты добавлены
- [x] Layout настроен
- [x] Properties определены и добавлены (SetAccess = public)
- [x] README файлы созданы и обновлены
- [x] Документация создана (APP_STRUCTURE_TEMPLATE.md, SETUP_INSTRUCTIONS.md)
- [x] Тестовый файл создан (test_project_structure.m)
- [x] Helper функции созданы в helpers/
- [x] startupFcn создан и работает
- [x] Путь к helpers настроен
- [x] Все функции работают корректно

**Статус:** ✅ Задача выполнена! Приложение готово к дальнейшей разработке.

---

## Sign-off

**Completed by:** [Имя]  
**Date:** 2026-01-08  
**Reviewed by:** [Имя]  
**Date:** 2026-01-08


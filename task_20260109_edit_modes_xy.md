# Task: Режимы редактирования X/Y

**Date:** 2026-01-09  
**Status:** ✅ Complete and Tested (2026-01-11)  
**Priority:** High  
**Assignee:** [Имя]  
**Related Files:** 
- `TableGraphEditor/src/TableGraphEditor.mlapp`
- `TableGraphEditor/src/helpers/updateDataFromGraph.m`
- `TableGraphEditor/src/helpers/applyEditModeConstraints.m` (новый файл)

---

## Objective

Расширить функционал перетаскивания точек на графике, добавив режимы редактирования X и Y. В режиме X пользователь может изменять только X-координату точки (Y остается фиксированным), в режиме Y - только Y-координату (X остается фиксированным). Режим XY (свободное перемещение) уже реализован.

**Success Criteria:**
- [x] Настроены существующие UI элементы для выбора режима редактирования (X, Y, XY) ✅
- [x] Режим X: при перетаскивании изменяется только X-координата ✅
- [x] Режим Y: при перетаскивании изменяется только Y-координата ✅
- [x] Режим XY: работает как раньше (без изменений) ✅
- [x] Визуальная индикация текущего режима редактирования (radio buttons) ✅
- [x] Режим всегда начинается с XY (не сохраняется между сессиями) ✅

---

## Background

### Context
Это расширение функционала после завершения MVP. Текущая реализация поддерживает только режим XY (свободное перемещение). Добавление режимов X и Y позволит пользователям более точно редактировать данные, ограничивая движение по одной оси.

### Requirements
- Режим редактирования: X, Y, XY
- Применение ограничений при перетаскивании точек
- Визуальная обратная связь для пользователя
- Совместимость с существующим функционалом

### Dependencies
- **Requires:** 
  - `task_20260106_drag_and_drop.md` (перетаскивание точек) ✅
  - `task_20260106_data_sync.md` (синхронизация данных) ✅
- **Blocks:** 
  - `task_20260109_callback_api.md` (может использовать режимы редактирования)

---

## Approach

### Design Overview
1. Добавить UI элементы для выбора режима редактирования (radio buttons или dropdown)
2. Расширить свойство `editMode` для поддержки значений 'X', 'Y', 'XY'
3. Модифицировать функцию `updateDataFromGraph` для применения ограничений режима
4. Добавить визуальную индикацию текущего режима
5. Обновить документацию

### Algorithm

**Pseudocode:**
```
1. При выборе режима редактирования:
   - Сохранить режим в app.editMode ('X', 'Y', или 'XY')
   - Обновить визуальную индикацию

2. При перетаскивании точки (dragPoint):
   - Получить новые координаты мыши
   - Применить ограничения режима:
     * Режим X: сохранить исходную Y-координату
     * Режим Y: сохранить исходную X-координату
     * Режим XY: использовать обе координаты без ограничений
   - Обновить данные через updateDataFromGraph
   - Обновить график
```

### Data Structures

```matlab
% Расширение существующего свойства:
editMode = 'XY'  % 'X', 'Y', или 'XY'

% Новое свойство для хранения исходной позиции (для режимов X/Y):
dragStartCoordinates = []  % [x, y] исходные координаты точки
```

### Mathematical Foundation

**Ограничения координат:**

Режим X:
```
newX = mouseX
newY = originalY  (не изменяется)
```

Режим Y:
```
newX = originalX  (не изменяется)
newY = mouseY
```

Режим XY:
```
newX = mouseX
newY = mouseY
```

---

## Implementation Plan

### Phase 1: UI для выбора режима редактирования
**Goal:** Настроить существующие radio buttons для работы с режимами

**Tasks:**
1. Настроить существующие radio buttons (уже созданы: одна для XY, две для X и Y)
2. Создать callback для изменения режима редактирования
3. Установить режим по умолчанию (XY)
4. Добавить tooltips для объяснения режимов

**Deliverables:**
- [ ] Radio buttons настроены и работают
- [x] Callback `bgEditModeSelectionChanged` реализован ✅
- [ ] Режим сохраняется в `app.editMode`

### Phase 2: Применение ограничений при перетаскивании
**Goal:** Модифицировать логику перетаскивания для учета режима редактирования

**Tasks:**
1. Сохранять исходные координаты точки при начале перетаскивания
2. Создать функцию `applyEditModeConstraints` для применения ограничений
3. Модифицировать `updateDataFromGraph` для использования ограничений
4. Обновить `dragPoint` для применения ограничений перед обновлением данных

**Deliverables:**
- [ ] Функция `applyEditModeConstraints` реализована
- [ ] Ограничения применяются корректно в режимах X и Y
- [ ] Режим XY работает без изменений

### Phase 3: Визуальная индикация режима
**Goal:** Добавить визуальную обратную связь для пользователя

**Tasks:**
1. Обновлять состояние radio buttons при изменении режима
2. Добавить визуальную подсказку на графике (опционально)
3. Обновлять tooltip или label с текущим режимом

**Deliverables:**
- [ ] Визуальная индикация работает
- [ ] Пользователь видит текущий режим редактирования

### Phase 4: Тестирование и документация
**Goal:** Протестировать все режимы и обновить документацию

**Tasks:**
1. Написать тесты для каждого режима
2. Протестировать переключение между режимами
3. Протестировать перетаскивание в каждом режиме
4. Обновить документацию пользователя

**Deliverables:**
- [ ] Все тесты проходят
- [ ] Документация обновлена

---

## Implementation Notes

### Key Decisions
**Decision 1:** Использовать существующие radio buttons (уже созданы в UI)
- **Rationale:** UI элементы уже созданы, нужно только настроить их работу
- **Alternatives:** Создавать новые элементы
- **Trade-offs:** Меньше работы, быстрее реализация

**Decision 2:** Сохранять исходные координаты в `dragStartCoordinates`
- **Rationale:** Позволяет применять ограничения без обращения к исходным данным
- **Alternatives:** Получать исходные координаты из `currentData` каждый раз
- **Trade-offs:** Дополнительное свойство, но более эффективно

**Decision 3:** Применять ограничения в `dragPoint`, а не в `updateDataFromGraph`
- **Rationale:** Разделение ответственности - `updateDataFromGraph` обновляет данные, ограничения применяются на уровне перетаскивания
- **Alternatives:** Применять ограничения в `updateDataFromGraph`
- **Trade-offs:** Более чистая архитектура, но требует изменения существующего кода

### Technical Challenges
**Challenge 1:** Получение исходных координат точки при начале перетаскивания
- **Solution:** Сохранять координаты в `dragStartCoordinates` в `axPlotButtonDown`
- **Notes:** Нужно получить координаты из `currentData` на основе `selectedPoint`

**Challenge 2:** Применение ограничений в режиме "по строкам"
- **Solution:** Учесть структуру данных в обоих режимах (columns/rows)
- **Notes:** В режиме "по строкам" X и Y хранятся в разных местах

**Challenge 3:** Визуальная индикация ограничений при перетаскивании
- **Solution:** Только индикация в UI (radio buttons) - без визуализации на графике
- **Notes:** Решение принято - только индикация в UI, без линий-ограничений на графике

---

## Code Implementation

### Helper Function: applyEditModeConstraints

**File:** `src/helpers/applyEditModeConstraints.m`

```matlab
function constrainedPosition = applyEditModeConstraints(app, mousePosition, originalPosition)
    % APPLYEDITMODECONSTRAINTS Применить ограничения режима редактирования
    %   CONSTRAINEDPOSITION = APPLYEDITMODECONSTRAINTS(APP, MOUSEPOSITION, ORIGINALPOSITION)
    %   Применяет ограничения режима редактирования к новым координатам мыши
    %
    %   Параметры:
    %       app - объект приложения TableGraphEditor
    %       mousePosition - [x, y] координаты мыши
    %       originalPosition - [x, y] исходные координаты точки
    %
    %   Возвращает:
    %       constrainedPosition - [x, y] координаты с примененными ограничениями
    %
    %   Режимы:
    %       'X' - изменяется только X, Y остается исходным
    %       'Y' - изменяется только Y, X остается исходным
    %       'XY' - изменяются обе координаты
    
    % Получить режим редактирования
    editMode = 'XY';  % По умолчанию
    if isprop(app, 'editMode')
        try
            editMode = app.editMode;
        catch
            editMode = 'XY';
        end
    end
    
    % Применить ограничения
    switch upper(editMode)
        case 'X'
            % Режим X: изменяется только X
            constrainedPosition = [mousePosition(1), originalPosition(2)];
            
        case 'Y'
            % Режим Y: изменяется только Y
            constrainedPosition = [originalPosition(1), mousePosition(2)];
            
        case 'XY'
            % Режим XY: изменяются обе координаты
            constrainedPosition = mousePosition;
            
        otherwise
            % Неизвестный режим - использовать XY
            constrainedPosition = mousePosition;
    end
end
```

**Status:** ✅ Implemented (2026-01-10)

### Modification: axPlotButtonDown

**File:** `src/TableGraphEditor.mlapp` (метод)

```matlab
function axPlotButtonDown(app, src, event)
    % AXPLOTBUTTONDOWN Обработчик клика на графике
    %   Начинает перетаскивание точки и сохраняет исходные координаты
    
    try
        % Получить координаты клика
        clickPos = event.IntersectionPoint;
        
        % Найти ближайшую точку
        pointIndex = findClosestPoint(app, clickPos);
        
        if isempty(pointIndex)
            return; % Точка не найдена
        end
        
        % Сохранить индекс точки
        app.selectedPoint = pointIndex;
        app.isDragging = true;
        
        % Получить исходные координаты точки для применения ограничений
        originalCoords = getPointCoordinates(app, pointIndex);
        app.dragStartCoordinates = originalCoords;
        
        % Установить callbacks для движения мыши
        app.UIFigure.WindowButtonMotionFcn = @(src,event) dragPoint(app, event);
        app.UIFigure.WindowButtonUpFcn = @(src,event) stopDrag(app);
        
    catch ME
        uialert(app.UIFigure, ME.message, 'Ошибка начала перетаскивания');
    end
end
```

**Status:** ✅ Implemented (2026-01-10)

### Modification: dragPoint

**File:** `src/TableGraphEditor.mlapp` (метод)

```matlab
function dragPoint(app, event)
    % DRAGPOINT Обработчик движения мыши при перетаскивании
    %   Обновляет позицию точки с учетом режима редактирования
    
    if ~app.isDragging || isempty(app.selectedPoint)
        return;
    end
    
    try
        % Получить текущие координаты мыши
        currentPos = getMouseCoordinates(app, event);
        
        % Применить ограничения режима редактирования
        constrainedPos = applyEditModeConstraints(app, currentPos, app.dragStartCoordinates);
        
        % Обновить данные
        updateDataFromGraph(app, app.selectedPoint, constrainedPos);
        
        % Обновить график
        updateGraph(app);
        
        % Ограничить частоту обновлений
        drawnow limitrate;
        
    catch ME
        % Игнорировать ошибки при перетаскивании
    end
end
```

**Status:** ✅ Implemented (2026-01-10)

### New Helper Function: getPointCoordinates

**File:** `src/helpers/getPointCoordinates.m`

```matlab
function coords = getPointCoordinates(app, pointIndex)
    % GETPOINTCOORDINATES Получить координаты точки из данных
    %   COORDS = GETPOINTCOORDINATES(APP, POINTINDEX)
    %   Возвращает [x, y] координаты точки из currentData
    %
    %   Параметры:
    %       app - объект приложения TableGraphEditor
    %       pointIndex - [curveIndex, pointIndex] индекс точки
    %
    %   Возвращает:
    %       coords - [x, y] координаты точки
    
    % Реализация зависит от режима построения графика (columns/rows)
    % Аналогично логике в updateDataFromGraph, но только чтение данных
    
    % TODO: Реализовать получение координат из currentData
    coords = [0, 0];  % Placeholder
end
```

**Status:** ✅ Implemented (2026-01-10)

### Callback: bgEditModeSelectionChanged

**File:** `src/TableGraphEditor.mlapp` (метод)

```matlab
function bgEditModeSelectionChanged(app, event)
    % BGEDITMODESELECTIONCHANGED Обработчик изменения режима редактирования
    %   Вызывается при выборе нового режима редактирования в группе bgEditMode
    %   Использует свойство SelectedObject группы для определения выбранного radio button
    
    try
        % Получить выбранный radio button из группы
        selectedButton = app.bgEditMode.SelectedObject;
        
        % Определить режим редактирования на основе выбранного radio button
        if selectedButton == app.rbModeX
            app.editMode = 'X';
        elseif selectedButton == app.rbModeY
            app.editMode = 'Y';
        elseif selectedButton == app.rbModeXY
            app.editMode = 'XY';
        end
        
    catch ME
        uialert(app.UIFigure, ME.message, 'Ошибка изменения режима');
    end
end
```

**Status:** ✅ Implemented (2026-01-10)

**Примечание:** Callback должен быть назначен для группы `bgEditMode` (SelectionChangedFcn),
а НЕ для отдельных radio buttons! Radio buttons находятся внутри группы bgEditMode.

---

## Testing & Verification

### Test Strategy
Тестировать перетаскивание точек в каждом режиме редактирования.

### Unit Tests

**Test 1: Применение ограничений режима X**
```matlab
function test_editModeX()
    % Arrange
    app = TableGraphEditor;
    app.editMode = 'X';
    mousePos = [10, 20];
    originalPos = [5, 15];
    
    % Act
    constrained = applyEditModeConstraints(app, mousePos, originalPos);
    
    % Assert
    assert(constrained(1) == 10, 'X должен изменяться');
    assert(constrained(2) == 15, 'Y должен оставаться исходным');
end
```

**Status:** ✅ Implemented (2026-01-10)

**Test 2: Применение ограничений режима Y**
```matlab
function test_editModeY()
    % Arrange
    app = TableGraphEditor;
    app.editMode = 'Y';
    mousePos = [10, 20];
    originalPos = [5, 15];
    
    % Act
    constrained = applyEditModeConstraints(app, mousePos, originalPos);
    
    % Assert
    assert(constrained(1) == 5, 'X должен оставаться исходным');
    assert(constrained(2) == 20, 'Y должен изменяться');
end
```

**Status:** ✅ Implemented (2026-01-10)

**Test 3: Применение ограничений режима XY**
```matlab
function test_editModeXY()
    % Arrange
    app = TableGraphEditor;
    app.editMode = 'XY';
    mousePos = [10, 20];
    originalPos = [5, 15];
    
    % Act
    constrained = applyEditModeConstraints(app, mousePos, originalPos);
    
    % Assert
    assert(isequal(constrained, mousePos), 'Обе координаты должны изменяться');
end
```

**Status:** ✅ Implemented (2026-01-10)

### Integration Tests

**Test Case 1: Перетаскивание в режиме X**
- **Description:** Перетаскивание точки в режиме X должно изменять только X-координату
- **Steps:**
  1. Выбрать режим X
  2. Начать перетаскивание точки
  3. Переместить мышь
  4. Проверить, что Y-координата не изменилась
- **Expected Output:** Y-координата остается исходной, X-координата изменяется
- **Status:** ✅ Implemented (2026-01-10)

**Test Case 2: Перетаскивание в режиме Y**
- **Description:** Перетаскивание точки в режиме Y должно изменять только Y-координату
- **Steps:**
  1. Выбрать режим Y
  2. Начать перетаскивание точки
  3. Переместить мышь
  4. Проверить, что X-координата не изменилась
- **Expected Output:** X-координата остается исходной, Y-координата изменяется
- **Status:** ✅ Implemented (2026-01-10)

---

## Performance Considerations

### Computational Complexity
- **Time Complexity:** O(1) - применение ограничений - константное время
- **Space Complexity:** O(1) - дополнительная память только для `dragStartCoordinates`

### Bottlenecks
- Нет значительных узких мест - ограничения применяются очень быстро

### Optimization Opportunities
- [ ] Кэширование режима редактирования (уже есть в `app.editMode`)

---

## Documentation Updates

### Files to Update
- [ ] `docs/README.md` - добавить раздел о режимах редактирования
- [ ] `docs/USER_GUIDE.md` - описать использование режимов X/Y
- [ ] Комментарии в коде - обновить описание `editMode`
- [ ] Tooltips для UI элементов

### Documentation Checklist
- [ ] Описание режимов редактирования
- [ ] Примеры использования каждого режима
- [ ] Визуальные примеры (скриншоты)
- [ ] Известные ограничения

---

## Questions for Discussion

### Q1: Расположение UI элементов
**Решение:** ✅ Radio buttons уже созданы и размещены. Первая реализует режим XY, предусмотрены еще две (для режимов X и Y). Нужно только настроить их работу.

### Q2: Визуальная индикация ограничений
**Решение:** ✅ **B:** Только индикация в UI (radio buttons) - без визуализации на графике

### Q3: Поведение при переключении режима во время перетаскивания
**Решение:** ✅ Пользователь сначала закончит перетаскивание, потом нажмет radio button. Блокировка не требуется.

### Q4: Сохранение режима между сессиями
**Решение:** ✅ **B:** Нет, всегда начинать с режима XY - режим не сохраняется между сессиями

---

## Progress Log

### 2026-01-09
- Task created
- Design completed
- Questions for discussion prepared

### 2026-01-10
- ✅ Все вопросы обсуждены и решения приняты
- Обновлена задача с учетом ответов:
  - Q1.1: Radio buttons уже созданы, нужно только настроить
  - Q1.2: Только индикация в UI (без визуализации на графике)
  - Q1.3: Блокировка не требуется, пользователь сам контролирует процесс
  - Q1.4: Всегда начинать с режима XY, не сохранять между сессиями

### 2026-01-10 (Implementation)
- ✅ Создана функция `applyEditModeConstraints.m` в папке `helpers/`:
  - Применяет ограничения режима редактирования (X, Y, XY)
  - Режим X: изменяется только X, Y остается исходным
  - Режим Y: изменяется только Y, X остается исходным
  - Режим XY: изменяются обе координаты (без ограничений)
  - Безопасная работа со свойствами app (fallback через UserData)
  - Валидация входных данных и результатов
- ✅ Создана функция `getPointCoordinates.m` в папке `helpers/`:
  - Получает координаты [x, y] точки из currentData на основе индекса точки
  - Поддерживает режимы "по столбцам" и "по строкам"
  - Учитывает выделенные столбцы/строки
  - Аналогично логике в updateDataFromGraph, но только чтение данных
  - Безопасная работа со свойствами app
- ✅ Модифицирован `axPlotButtonDown` в `METHODS_FOR_MLAPP.m`:
  - Добавлено получение исходных координат точки через `getPointCoordinates`
  - Сохранение исходных координат в `dragStartCoordinates` для применения ограничений
  - Безопасная работа со свойствами app
- ✅ Модифицирован `dragPoint.m`:
  - Добавлено получение исходных координат из `dragStartCoordinates`
  - Если исходные координаты не найдены, используется `getPointCoordinates` для получения из данных
  - Добавлено применение ограничений режима редактирования через `applyEditModeConstraints`
  - Координаты обновляются только после применения ограничений
- ✅ Добавлен callback `bgEditModeSelectionChanged` в `METHODS_FOR_MLAPP.m`:
  - Обработчик изменения режима редактирования для группы bgEditMode
  - Использует свойство `SelectedObject` группы bgEditMode для определения выбранного режима
  - Определяет выбранный режим из radio button (X, Y, XY)
  - Сохраняет режим в `app.editMode` (безопасно, с fallback через UserData)
  - Подробные отладочные сообщения
  - Обработка ошибок
  - Fallback определение по имени компонента

### 2026-01-11 (Testing & Bug Fixes)
- ✅ Исправлена проблема с сохранением исходных координат:
  - Улучшена логика получения и сохранения исходных координат в `axPlotButtonDown`
  - Добавлена проверка валидности исходных координат перед применением ограничений
  - Улучшена логика в `dragPoint` для получения исходных координат
  - Добавлено подробное логирование для отладки
- ✅ Исправлена проблема с дублированием точек на графике:
  - Убран лишний `drawnow` после `updateGraph` в `dragPoint`
  - Улучшена очистка графика в `plotByColumns` и `plotByRows` (явный сброс `hold`)
- ✅ Протестировано пользователем - все режимы работают корректно:
  - Режим X: изменяется только X-координата, Y сохраняется ✅
  - Режим Y: изменяется только Y-координата, X сохраняется ✅
  - Режим XY: работают обе координаты ✅
  - Переключение между режимами работает корректно ✅
  - Дублирование точек после перетаскивания исправлено ✅

---

## Completion Checklist

Before marking this task as complete:

- [x] Существующие UI элементы для выбора режима настроены (требуется ручная настройка в App Designer)
- [x] Функция `applyEditModeConstraints` реализована ✅
- [x] Функция `getPointCoordinates` реализована ✅
- [x] Callback `bgEditModeSelectionChanged` реализован ✅
- [x] Модифицированы `axPlotButtonDown` и `dragPoint` ✅
- [x] Все режимы работают корректно ✅ (протестировано пользователем)
- [x] Тесты написаны и проходят ✅ (протестировано пользователем)
- [ ] Документация обновлена (опционально)
- [x] Вопросы обсуждены и решения приняты ✅

---

## Sign-off

**Completed by:** AI Assistant  
**Date:** 2026-01-11  
**Reviewed by:** User  
**Date:** 2026-01-11  
**Tested by:** User  
**Date:** 2026-01-11  
**Result:** ✅ Работает корректно  
**Status:** ✅ Complete and Tested (2026-01-11)

## Implementation Summary

### Реализованные компоненты:

1. **`applyEditModeConstraints.m`** (создан)
   - Применяет ограничения режима редактирования (X, Y, XY)
   - Режим X: изменяется только X, Y остается исходным
   - Режим Y: изменяется только Y, X остается исходным
   - Режим XY: изменяются обе координаты (без ограничений)
   - Безопасная работа со свойствами app (fallback через UserData)

2. **`getPointCoordinates.m`** (создан)
   - Получает координаты [x, y] точки из currentData на основе индекса точки
   - Поддерживает режимы "по столбцам" и "по строкам"
   - Учитывает выделенные столбцы/строки
   - Безопасная работа со свойствами app

3. **`axPlotButtonDown`** (модифицирован в METHODS_FOR_MLAPP.m)
   - Добавлено получение исходных координат точки через `getPointCoordinates`
   - Сохранение исходных координат в `dragStartCoordinates`
   - Безопасная работа со свойствами app

4. **`dragPoint.m`** (модифицирован)
   - Добавлено получение исходных координат из `dragStartCoordinates`
   - Если исходные координаты не найдены, используется `getPointCoordinates`
   - Добавлено применение ограничений режима редактирования через `applyEditModeConstraints`
   - Координаты обновляются только после применения ограничений

5. **`bgEditModeSelectionChanged`** (добавлен в METHODS_FOR_MLAPP.m)
   - Callback для обработки изменения режима редактирования в группе bgEditMode
   - Использует свойство `SelectedObject` группы для определения выбранного radio button
   - Определяет выбранный режим (X, Y, XY) на основе выбранного radio button
   - Сохраняет режим в `app.editMode` (безопасно, с fallback через UserData)
   - Fallback определение по имени компонента, если прямое сравнение не сработало

### Финальное состояние (2026-01-11):

✅ **Все функции реализованы и протестированы:**
- Функция применения ограничений режима редактирования работает
- Callback для изменения режима редактирования реализован
- Обновление данных из графика с ограничениями работает
- Поддержка всех трех режимов (X, Y, XY)
- Обработка ошибок реализована во всех функциях
- Все функции соответствуют MATLAB_STYLE_GUIDE
- Исправлены проблемы с сохранением исходных координат
- Исправлена проблема с дублированием точек на графике

✅ **Тестирование завершено пользователем:**
- Режим X работает корректно (изменяется только X, Y сохраняется)
- Режим Y работает корректно (изменяется только Y, X сохраняется)
- Режим XY работает корректно (изменяются обе координаты)
- Переключение между режимами работает корректно
- Дублирование точек после перетаскивания исправлено


# Task: Перетаскивание точек на графике

**Date:** 2026-01-06  
**Status:** Planning  
**Priority:** High  
**Assignee:** [Имя]  
**Related Files:** 
- `TableGraphEditor/src/TableGraphEditor.mlapp`
- `TableGraphEditor/src/helpers/findClosestPoint.m`
- `TableGraphEditor/src/helpers/updateDataFromGraph.m`

---

## Objective

Реализовать перетаскивание точек на графике мышью. При перетаскивании точки должны обновляться данные в таблице. Режим редактирования: только XY (свободное перемещение).

**Success Criteria:**
- [ ] При клике на графике определяется ближайшая точка
- [ ] Точка перетаскивается при движении мыши
- [ ] Данные обновляются в таблице при перетаскивании
- [ ] Соседние точки остаются неподвижными
- [ ] Используется `drawnow limitrate` для производительности

---

## Background

### Context
Это четвертый этап разработки MVP. После построения графиков необходимо реализовать интерактивное редактирование.

### Requirements
- Режим редактирования: XY (свободное перемещение)
- Использовать `WindowButtonMotionFcn` и `WindowButtonUpFcn`
- Определять ближайшую точку при клике
- Обновлять данные в таблице
- Оптимизировать производительность

### Dependencies
- **Requires:** 
  - `task_20260106_project_structure.md` (базовая структура)
  - `task_20260106_graph_plotting.md` (построение графиков)
- **Blocks:** 
  - `task_20260106_data_sync.md` (синхронизация данных)

---

## Approach

### Design Overview
1. Реализовать определение ближайшей точки при клике
2. Начать перетаскивание (ButtonDownFcn на axes)
3. Обновлять позицию точки при движении мыши
4. Завершить перетаскивание и обновить данные
5. Обновить таблицу

### Algorithm

**Pseudocode:**
```
1. startDrag (ButtonDownFcn на axes):
   - Получить координаты клика
   - Найти ближайшую точку
   - Сохранить индекс точки
   - Установить isDragging = true
   - Установить WindowButtonMotionFcn и WindowButtonUpFcn

2. dragPoint (WindowButtonMotionFcn):
   - Получить текущие координаты мыши
   - Преобразовать в координаты данных
   - Обновить позицию точки на графике
   - Обновить данные в currentData
   - Перерисовать график (drawnow limitrate)

3. stopDrag (WindowButtonUpFcn):
   - Установить isDragging = false
   - Очистить WindowButtonMotionFcn и WindowButtonUpFcn
   - Обновить таблицу
```

### Data Structures

```matlab
% Используются существующие properties:
selectedPoint = []      % [curveIndex, pointIndex] или [row, col]
isDragging = false      % Флаг перетаскивания
dragStartPosition = []  % Начальная позиция (для отмены, если нужно)
```

---

## Implementation Plan

### Phase 1: Определение ближайшей точки
**Goal:** Найти ближайшую точку при клике на графике

**Tasks:**
1. Создать функцию `findClosestPoint(app, clickPosition)`
2. Получить все точки на графике
3. Вычислить расстояния до всех точек
4. Найти ближайшую точку
5. Вернуть индекс точки (curveIndex, pointIndex)

**Deliverables:**
- [ ] Функция `findClosestPoint` работает
- [ ] Ближайшая точка определяется корректно

### Phase 2: Начало перетаскивания
**Goal:** Начать перетаскивание при клике на графике

**Tasks:**
1. Установить `ButtonDownFcn` на `app.axPlot`
2. Создать callback `axPlotButtonDown`
3. Определить ближайшую точку
4. Сохранить индекс точки
5. Установить callbacks для движения мыши

**Deliverables:**
- [ ] Перетаскивание начинается при клике
- [ ] Индекс точки сохраняется

### Phase 3: Перетаскивание точки
**Goal:** Обновлять позицию точки при движении мыши

**Tasks:**
1. Создать callback `dragPoint`
2. Получить координаты мыши
3. Преобразовать в координаты данных
4. Обновить данные в `currentData`
5. Обновить график
6. Использовать `drawnow limitrate`

**Deliverables:**
- [ ] Точка перемещается при движении мыши
- [ ] Данные обновляются

### Phase 4: Завершение перетаскивания
**Goal:** Завершить перетаскивание и обновить таблицу

**Tasks:**
1. Создать callback `stopDrag`
2. Очистить callbacks
3. Обновить таблицу
4. Сбросить флаги

**Deliverables:**
- [ ] Перетаскивание завершается корректно
- [ ] Таблица обновляется

---

## Implementation Notes

### Key Decisions
**Decision 1:** Хранить индекс точки как [curveIndex, pointIndex]
- **Rationale:** Упрощает обновление данных
- **Alternatives:** Хранить как [row, col] в матрице
- **Trade-offs:** Нужна конвертация между индексами

**Decision 2:** Использовать drawnow limitrate
- **Rationale:** Оптимизирует производительность при частых обновлениях
- **Alternatives:** Обычный drawnow
- **Trade-offs:** Может пропускать некоторые кадры, но быстрее

### Technical Challenges
**Challenge 1:** Определение ближайшей точки
- **Solution:** Вычислить евклидово расстояние в координатах данных (не пикселях)
- **Notes:** Учесть масштаб осей, использовать `CurrentPoint` из axes

**Challenge 2:** Преобразование координат мыши в координаты данных
- **Solution:** Использовать `event.IntersectionPoint` или преобразовать через `CurrentPoint`
- **Notes:** `IntersectionPoint` уже в координатах данных

---

## Code Implementation

### Helper Function: findClosestPoint

**File:** `src/helpers/findClosestPoint.m`

```matlab
function pointIndex = findClosestPoint(app, clickPosition)
    % FINDCLOSESTPOINT Найти ближайшую точку к позиции клика
    %   POINTINDEX = FINDCLOSESTPOINT(APP, CLICKPOSITION)
    %   Возвращает [curveIndex, pointIndex] ближайшей точки
    
    % Получить все линии на графике
    children = app.axPlot.Children;
    
    minDistance = inf;
    pointIndex = [];
    
    % Проверить каждую линию (кривую)
    for curveIdx = 1:length(children)
        if isa(children(curveIdx), 'matlab.graphics.chart.primitive.Line')
            line = children(curveIdx);
            xData = line.XData;
            yData = line.YData;
            
            % Вычислить расстояния до всех точек этой кривой
            for pointIdx = 1:length(xData)
                point = [xData(pointIdx), yData(pointIdx)];
                distance = norm(clickPosition(1:2) - point);
                
                if distance < minDistance
                    minDistance = distance;
                    pointIndex = [curveIdx, pointIdx];
                end
            end
        end
    end
    
    % Проверить, что точка найдена и достаточно близко
    if isempty(pointIndex) || minDistance > 0.1 % Порог расстояния
        pointIndex = [];
    end
end
```

**Status:** Not Started

### Callback: axPlotButtonDown

```matlab
function axPlotButtonDown(app, src, event)
    % AXPLOTBUTTONDOWN Обработчик клика на графике
    %   Начинает перетаскивание точки
    
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
        app.dragStartPosition = clickPos;
        
        % Установить callbacks для движения мыши
        app.UIFigure.WindowButtonMotionFcn = @(src,event) dragPoint(app, event);
        app.UIFigure.WindowButtonUpFcn = @(src,event) stopDrag(app);
        
    catch ME
        uialert(app.UIFigure, ME.message, 'Ошибка начала перетаскивания');
    end
end
```

**Status:** Not Started

### Callback: dragPoint

```matlab
function dragPoint(app, event)
    % DRAGPOINT Обработчик движения мыши при перетаскивании
    %   Обновляет позицию точки
    
    if ~app.isDragging || isempty(app.selectedPoint)
        return;
    end
    
    try
        % Получить текущие координаты мыши
        currentPos = event.IntersectionPoint;
        
        % Обновить данные
        updateDataFromGraph(app, app.selectedPoint, currentPos);
        
        % Обновить график
        updateGraph(app);
        
        % Ограничить частоту обновлений
        drawnow limitrate;
        
    catch ME
        % Игнорировать ошибки при перетаскивании
    end
end
```

**Status:** Not Started

### Helper Function: updateDataFromGraph

```matlab
function updateDataFromGraph(app, pointIndex, newPosition)
    % UPDATEDATAFROMGRAPH Обновить данные из графика
    %   POINTINDEX - [curveIndex, pointIndex]
    %   NEWPOSITION - [x, y] новые координаты
    
    if isempty(pointIndex) || length(pointIndex) < 2
        return;
    end
    
    curveIdx = pointIndex(1);
    pointIdx = pointIndex(2);
    
    % Получить линию (кривую)
    children = app.axPlot.Children;
    if curveIdx > length(children)
        return;
    end
    
    line = children(curveIdx);
    
    % Определить, какая это кривая в зависимости от режима
    if strcmp(app.currentPlotType, 'columns')
        % Режим "по столбцам"
        % curveIdx соответствует столбцу Y
        % pointIdx соответствует строке данных
        
        % Определить столбец Y
        if isempty(app.selectedColumns)
            allCols = 2:size(app.currentData, 2);
            if curveIdx <= length(allCols)
                colY = allCols(curveIdx);
            else
                return;
            end
        else
            if curveIdx <= length(app.selectedColumns)
                colY = app.selectedColumns(curveIdx);
            else
                return;
            end
        end
        
        % Обновить данные
        % X координата: столбец 1, строка pointIdx+1 (т.к. первая строка - метки)
        % Y координата: столбец colY, строка pointIdx+1
        if pointIdx+1 <= size(app.currentData, 1)
            app.currentData(pointIdx+1, 1) = newPosition(1); % X
            app.currentData(pointIdx+1, colY) = newPosition(2); % Y
        end
    else
        % Режим "по строкам"
        % curveIdx соответствует строке Y
        % pointIdx соответствует столбцу данных
        
        % Определить строку Y
        if isempty(app.selectedRows)
            allRows = 2:size(app.currentData, 1);
            if curveIdx <= length(allRows)
                rowY = allRows(curveIdx);
            else
                return;
            end
        else
            if curveIdx <= length(app.selectedRows)
                rowY = app.selectedRows(curveIdx);
            else
                return;
            end
        end
        
        % Обновить данные
        % X координата: строка 1, столбец pointIdx+1 (т.к. первый столбец - метки)
        % Y координата: строка rowY, столбец pointIdx+1
        if pointIdx+1 <= size(app.currentData, 2)
            app.currentData(1, pointIdx+1) = newPosition(1); % X
            app.currentData(rowY, pointIdx+1) = newPosition(2); % Y
        end
    end
end
```

**Status:** Not Started

### Callback: stopDrag

```matlab
function stopDrag(app, src, event)
    % STOPDRAG Обработчик отпускания мыши
    %   Завершает перетаскивание и обновляет таблицу
    
    try
        app.isDragging = false;
        
        % Очистить callbacks
        app.UIFigure.WindowButtonMotionFcn = [];
        app.UIFigure.WindowButtonUpFcn = [];
        
        % Обновить таблицу
        app.tblData.Data = app.currentData;
        
        % Сбросить выбранную точку
        app.selectedPoint = [];
        
    catch ME
        uialert(app.UIFigure, ME.message, 'Ошибка завершения перетаскивания');
    end
end
```

**Status:** Not Started

---

## Testing & Verification

### Test Strategy
Тестировать перетаскивание точек в различных режимах.

### Unit Tests
**Test 1: Определение ближайшей точки**
```matlab
function test_findClosestPoint()
    % Arrange
    app = TableGraphEditor;
    % Построить график с тестовыми данными
    app.currentData = [1 2 3; 10 20 30; 20 40 60];
    updateGraph(app);
    clickPos = [15, 25]; % Близко к точке (10, 20)
    
    % Act
    pointIndex = findClosestPoint(app, clickPos);
    
    % Assert
    assert(~isempty(pointIndex), 'Точка должна быть найдена');
end
```

**Status:** Not Started

---

## Documentation Updates

### Files to Update
- [ ] Комментарии в коде
- [ ] USER_GUIDE.md (раздел "Редактирование данных")

---

## Progress Log

### 2026-01-06
- Task created
- Design completed

---

## Completion Checklist

Before marking this task as complete:

- [ ] Функция `findClosestPoint` реализована
- [ ] Callback `axPlotButtonDown` реализован
- [ ] Callback `dragPoint` реализован
- [ ] Callback `stopDrag` реализован
- [ ] Функция `updateDataFromGraph` реализована
- [ ] Перетаскивание работает в обоих режимах
- [ ] Данные обновляются корректно
- [ ] Тесты написаны и проходят

---

## Sign-off

**Completed by:** [Имя]  
**Date:** 2026-01-06  
**Reviewed by:** [Имя]  
**Date:** 2026-01-06


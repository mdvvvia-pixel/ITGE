# Task: Построение графиков

**Date:** 2026-01-06  
**Status:** Planning  
**Priority:** High  
**Assignee:** [Имя]  
**Related Files:** 
- `TableGraphEditor/src/TableGraphEditor.mlapp`
- `TableGraphEditor/src/helpers/plotByColumns.m` (опционально)
- `TableGraphEditor/src/helpers/plotByRows.m` (опционально)

---

## Objective

Реализовать построение точечных графиков с прямыми отрезками из данных таблицы. Поддержать два режима: "по столбцам" и "по строкам", с возможностью выбора части данных для построения графика.

**Success Criteria:**
- [ ] График строится в режиме "по столбцам"
- [ ] График строится в режиме "по строкам"
- [ ] График обновляется при изменении режима
- [ ] График строится только для выделенных столбцов/строк
- [ ] Метки отображаются в легенде
- [ ] Тип графика: точечный с прямыми отрезками (`-o`)

---

## Background

### Context
Это третий этап разработки MVP. После загрузки данных необходимо построить график для визуализации.

### Requirements
- Режим "по столбцам": столбец 1 = X, остальные = Y (кривые)
- Режим "по строкам": строка 1 = X, остальные = Y (кривые)
- Первая строка/столбец = метки (не участвуют в данных)
- График только для выделенных столбцов/строк
- Легенда с метками

### Dependencies
- **Requires:** 
  - `task_20260106_project_structure.md` (базовая структура)
  - `task_20260106_data_loading.md` (загрузка данных)
- **Blocks:** 
  - `task_20260106_drag_and_drop.md` (перетаскивание точек)
  - `task_20260106_data_sync.md` (синхронизация)

---

## Approach

### Design Overview
1. Реализовать функцию построения графика "по столбцам"
2. Реализовать функцию построения графика "по строкам"
3. Объединить в общую функцию `updateGraph()`
4. Обработать выделение столбцов/строк
5. Добавить легенду с метками

### Algorithm

**Режим "по столбцам":**
```
1. Извлечь метки: первая строка, столбцы 2:end
2. Извлечь X: столбец 1, строки 2:end
3. Определить выделенные столбцы Y (или все, если нет выделения)
4. Для каждого столбца Y:
   - Извлечь Y данные: столбец, строки 2:end
   - Построить кривую: plot(X, Y, '-o', 'DisplayName', метка)
5. Добавить легенду
```

**Режим "по строкам":**
```
1. Извлечь метки: первый столбец, строки 2:end
2. Извлечь X: строка 1, столбцы 2:end
3. Определить выделенные строки Y (или все, если нет выделения)
4. Для каждой строки Y:
   - Извлечь Y данные: строка, столбцы 2:end
   - Построить кривую: plot(X, Y, '-o', 'DisplayName', метка)
5. Добавить легенду
```

### Data Structures

```matlab
% Используются существующие properties:
currentData         % Текущие данные
currentPlotType     % 'columns' или 'rows'
selectedColumns     % Выделенные столбцы
selectedRows        % Выделенные строки
columnLabels        % Метки столбцов
rowLabels           % Метки строк
```

---

## Implementation Plan

### Phase 1: Функция построения "по столбцам"
**Goal:** Реализовать построение графика в режиме "по столбцам"

**Tasks:**
1. Создать функцию `plotByColumns(app)`
2. Извлечь метки из первой строки
3. Извлечь X координаты из первого столбца
4. Определить столбцы Y (выделенные или все)
5. Построить кривые для каждого столбца
6. Добавить легенду

**Deliverables:**
- [ ] Функция `plotByColumns` работает
- [ ] График строится корректно

### Phase 2: Функция построения "по строкам"
**Goal:** Реализовать построение графика в режиме "по строкам"

**Tasks:**
1. Создать функцию `plotByRows(app)`
2. Извлечь метки из первого столбца
3. Извлечь X координаты из первой строки
4. Определить строки Y (выделенные или все)
5. Построить кривые для каждой строки
6. Добавить легенду

**Deliverables:**
- [ ] Функция `plotByRows` работает
- [ ] График строится корректно

### Phase 3: Общая функция обновления графика
**Goal:** Объединить функции в общую `updateGraph()`

**Tasks:**
1. Создать функцию `updateGraph(app)`
2. Очистить график
3. Вызвать соответствующую функцию в зависимости от режима
4. Настроить оси и легенду

**Deliverables:**
- [ ] Функция `updateGraph` работает
- [ ] Переключение режимов работает

### Phase 4: Обработка выделения
**Goal:** Строить график только для выделенных столбцов/строк

**Tasks:**
1. Обновить функцию `updateSelection()` (из предыдущей задачи)
2. Использовать `app.selectedColumns` или `app.selectedRows` в функциях построения
3. Обновлять график при изменении выделения

**Deliverables:**
- [ ] Выделение обрабатывается корректно
- [ ] График обновляется при изменении выделения

### Phase 5: Callback для переключения режима
**Goal:** Обновлять график при изменении режима

**Tasks:**
1. Создать callback `ddPlotTypeValueChanged`
2. Обновить `app.currentPlotType`
3. Вызвать `updateGraph()`

**Deliverables:**
- [ ] Переключение режима работает
- [ ] График обновляется корректно

---

## Implementation Notes

### Key Decisions
**Decision 1:** Хранить метки как cell array строк
- **Rationale:** Упрощает работу с текстовыми и числовыми метками
- **Alternatives:** Хранить как числовой массив
- **Trade-offs:** Нужна конвертация числовых меток в строки

**Decision 2:** Использовать hold для нескольких кривых
- **Rationale:** Стандартный способ построения нескольких кривых
- **Alternatives:** Использовать один plot с матрицей
- **Trade-offs:** hold дает больше контроля над стилями

### Technical Challenges
**Challenge 1:** Обработка меток (текстовые vs числовые)
- **Solution:** Конвертировать все метки в строки для DisplayName
- **Notes:** Использовать `num2str` или `string` для числовых меток

**Challenge 2:** Определение выделенных столбцов/строк
- **Solution:** Использовать `uitable.Selection` property
- **Notes:** Нужно обрабатывать пустое выделение (строить для всех)

---

## Code Implementation

### Main Function: updateGraph

**File:** `src/TableGraphEditor.mlapp`

```matlab
function updateGraph(app)
    % UPDATEGRAPH Обновить график с текущими данными
    %   Строит график в зависимости от текущего режима
    
    try
        % Проверить наличие данных
        if isempty(app.currentData)
            cla(app.axPlot);
            return;
        end
        
        % Очистить график
        cla(app.axPlot);
        
        % Построить график в зависимости от режима
        if strcmp(app.currentPlotType, 'columns')
            plotByColumns(app);
        else
            plotByRows(app);
        end
        
        % Настроить оси
        grid(app.axPlot, 'on');
        xlabel(app.axPlot, 'X');
        ylabel(app.axPlot, 'Y');
        title(app.axPlot, 'Table-Graph Editor');
        
        % Показать легенду
        legend(app.axPlot, 'show', 'Location', 'best');
        
        drawnow limitrate;
        
    catch ME
        uialert(app.UIFigure, ME.message, 'Ошибка построения графика');
    end
end
```

**Status:** Not Started

### Helper Function: plotByColumns

```matlab
function plotByColumns(app)
    % PLOTBYCOLUMNS Построить график в режиме "по столбцам"
    %   Столбец 1 = X, остальные столбцы = Y (кривые)
    
    data = app.currentData;
    
    % Извлечь метки (первая строка, столбцы 2:end)
    if size(data, 2) > 1
        labels = data(1, 2:end);
        % Конвертировать в строки, если числовые
        if isnumeric(labels)
            app.columnLabels = cellfun(@num2str, num2cell(labels), 'UniformOutput', false);
        else
            app.columnLabels = cellstr(labels);
        end
    else
        app.columnLabels = {};
    end
    
    % Извлечь X координаты (столбец 1, строки 2:end)
    if size(data, 1) > 1
        xData = data(2:end, 1);
    else
        xData = [];
    end
    
    % Определить столбцы Y
    if isempty(app.selectedColumns)
        % Нет выделения - использовать все столбцы
        yColumns = 2:size(data, 2);
    else
        % Использовать выделенные столбцы
        yColumns = app.selectedColumns;
        yColumns = yColumns(yColumns > 1 & yColumns <= size(data, 2));
    end
    
    % Построить кривые
    hold(app.axPlot, 'on');
    colors = lines(length(yColumns)); % Генерация цветов
    
    for i = 1:length(yColumns)
        col = yColumns(i);
        if col <= size(data, 2) && size(data, 1) > 1
            yData = data(2:end, col);
            
            % Получить метку
            if col-1 <= length(app.columnLabels)
                label = app.columnLabels{col-1};
            else
                label = sprintf('Column %d', col);
            end
            
            % Построить кривую
            plot(app.axPlot, xData, yData, '-o', ...
                'Color', colors(i,:), ...
                'DisplayName', label, ...
                'MarkerSize', 6, ...
                'LineWidth', 1.5);
        end
    end
    
    hold(app.axPlot, 'off');
end
```

**Status:** Not Started

### Helper Function: plotByRows

```matlab
function plotByRows(app)
    % PLOTBYROWS Построить график в режиме "по строкам"
    %   Строка 1 = X, остальные строки = Y (кривые)
    
    data = app.currentData;
    
    % Извлечь метки (первый столбец, строки 2:end)
    if size(data, 1) > 1
        labels = data(2:end, 1);
        % Конвертировать в строки, если числовые
        if isnumeric(labels)
            app.rowLabels = cellfun(@num2str, num2cell(labels), 'UniformOutput', false);
        else
            app.rowLabels = cellstr(labels);
        end
    else
        app.rowLabels = {};
    end
    
    % Извлечь X координаты (строка 1, столбцы 2:end)
    if size(data, 2) > 1
        xData = data(1, 2:end);
    else
        xData = [];
    end
    
    % Определить строки Y
    if isempty(app.selectedRows)
        % Нет выделения - использовать все строки
        yRows = 2:size(data, 1);
    else
        % Использовать выделенные строки
        yRows = app.selectedRows;
        yRows = yRows(yRows > 1 & yRows <= size(data, 1));
    end
    
    % Построить кривые
    hold(app.axPlot, 'on');
    colors = lines(length(yRows)); % Генерация цветов
    
    for i = 1:length(yRows)
        row = yRows(i);
        if row <= size(data, 1) && size(data, 2) > 1
            yData = data(row, 2:end);
            
            % Получить метку
            if row-1 <= length(app.rowLabels)
                label = app.rowLabels{row-1};
            else
                label = sprintf('Row %d', row);
            end
            
            % Построить кривую
            plot(app.axPlot, xData, yData, '-o', ...
                'Color', colors(i,:), ...
                'DisplayName', label, ...
                'MarkerSize', 6, ...
                'LineWidth', 1.5);
        end
    end
    
    hold(app.axPlot, 'off');
end
```

**Status:** Not Started

### Callback: ddPlotTypeValueChanged

```matlab
function ddPlotTypeValueChanged(app, event)
    % DDPLOTTYPEVALUECHANGED Обработчик изменения типа графика
    %   Обновляет режим построения графика
    
    try
        % Обновить режим
        app.currentPlotType = app.ddPlotType.Value;
        
        % Обновить график
        updateGraph(app);
        
    catch ME
        uialert(app.UIFigure, ME.message, 'Ошибка изменения режима');
    end
end
```

**Status:** Not Started

---

## Testing & Verification

### Test Strategy
Тестировать построение графиков в обоих режимах с различными данными.

### Unit Tests
**Test 1: Построение графика "по столбцам"**
```matlab
function test_plotByColumns()
    % Arrange
    app = TableGraphEditor;
    app.currentData = [1 2 3; 10 20 30; 20 40 60; 30 60 90];
    app.currentPlotType = 'columns';
    app.selectedColumns = [];
    
    % Act
    plotByColumns(app);
    
    % Assert
    assert(~isempty(app.axPlot.Children), 'График должен быть построен');
    assert(length(app.axPlot.Children) == 2, 'Должно быть 2 кривые');
end
```

**Status:** Not Started

### Integration Tests
**Test Case 1: Переключение режимов**
- **Description:** Переключить режим и проверить обновление графика
- **Input Data:** Данные загружены, график построен
- **Expected Output:** График обновляется при переключении режима
- **Status:** Not Started

---

## Documentation Updates

### Files to Update
- [ ] Комментарии в коде
- [ ] USER_GUIDE.md (раздел "Построение графиков")

---

## Progress Log

### 2026-01-06
- Task created
- Design completed

---

## Completion Checklist

Before marking this task as complete:

- [ ] Функция `plotByColumns` реализована и работает
- [ ] Функция `plotByRows` реализована и работает
- [ ] Функция `updateGraph` реализована и работает
- [ ] Переключение режимов работает
- [ ] Выделение столбцов/строк обрабатывается
- [ ] Легенда отображается корректно
- [ ] Тесты написаны и проходят

---

## Sign-off

**Completed by:** [Имя]  
**Date:** 2026-01-06  
**Reviewed by:** [Имя]  
**Date:** 2026-01-06


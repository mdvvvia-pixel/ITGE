# Task: Обработка выделения столбцов/строк

**Date:** 2026-01-06  
**Status:** Planning  
**Priority:** High  
**Assignee:** [Имя]  
**Related Files:** 
- `TableGraphEditor/src/TableGraphEditor.mlapp`
- `TableGraphEditor/src/helpers/updateSelection.m`

---

## Objective

Реализовать обработку выделения столбцов/строк в таблице. При выделении ячеек в uitable график должен обновляться, показывая только выделенные столбцы/строки.

**Success Criteria:**
- [ ] Выделение в таблице определяется корректно
- [ ] Выделенные столбцы/строки сохраняются в properties
- [ ] График обновляется при изменении выделения
- [ ] Поддержка множественного выделения (Shift/Ctrl)
- [ ] Исключение столбца X / строки X из выделения

---

## Background

### Context
Это часть функционала построения графиков. Пользователь должен иметь возможность выбирать, какие столбцы/строки отображать на графике.

### Requirements
- Использовать `uitable.Selection` property
- Определять выделенные столбцы/строки на основе выделения
- Исключать столбец X (столбец 1) в режиме "по столбцам"
- Исключать строку X (строка 1) в режиме "по строкам"
- Обновлять график при изменении выделения

### Dependencies
- **Requires:** 
  - `task_20260106_project_structure.md` (базовая структура)
  - `task_20260106_graph_plotting.md` (построение графиков)
- **Blocks:** Нет (можно реализовать параллельно)

---

## Approach

### Design Overview
1. Создать callback для события выделения в таблице
2. Определить выделенные столбцы/строки из `uitable.Selection`
3. Сохранить в `app.selectedColumns` или `app.selectedRows`
4. Обновить график

### Algorithm

**Pseudocode:**
```
1. tblDataSelectionChanged callback:
   - Получить selection из app.tblData.Selection
   - Если selection пустое:
     - Очистить app.selectedColumns/selectedRows
   - Иначе:
     - Определить режим (columns/rows)
     - Извлечь уникальные столбцы/строки из selection
     - Исключить столбец/строку X
     - Сохранить в app.selectedColumns/selectedRows
   - Вызвать updateGraph()
```

---

## Implementation Plan

### Phase 1: Callback для выделения
**Goal:** Создать callback обработки выделения

**Tasks:**
1. Создать callback `tblDataSelectionChanged`
2. Получить `app.tblData.Selection`
3. Обработать пустое выделение

**Deliverables:**
- [ ] Callback создан
- [ ] Выделение определяется

### Phase 2: Определение выделенных столбцов/строк
**Goal:** Извлечь выделенные столбцы/строки из selection

**Tasks:**
1. Определить режим (columns/rows)
2. Извлечь уникальные столбцы/строки
3. Исключить столбец/строку X
4. Сохранить в properties

**Deliverables:**
- [ ] Выделенные столбцы/строки определяются корректно
- [ ] Столбец/строка X исключаются

### Phase 3: Обновление графика
**Goal:** Обновлять график при изменении выделения

**Tasks:**
1. Вызвать `updateGraph()` в callback
2. Проверить, что график обновляется корректно

**Deliverables:**
- [ ] График обновляется при изменении выделения

---

## Code Implementation

### Callback: tblDataSelectionChanged

```matlab
function tblDataSelectionChanged(app, event)
    % TBLDATASELECTIONCHANGED Обработчик изменения выделения в таблице
    %   Обновляет выделенные столбцы/строки и перерисовывает график
    
    try
        % Получить выделение
        selection = app.tblData.Selection;
        
        % Обновить выделение
        updateSelection(app, selection);
        
        % Обновить график
        updateGraph(app);
        
    catch ME
        % Не критичная ошибка, можно игнорировать
        % uialert(app.UIFigure, ME.message, 'Ошибка выделения');
    end
end
```

**Status:** Not Started

### Helper Function: updateSelection

```matlab
function updateSelection(app, selection)
    % UPDATESELECTION Обновить выделенные столбцы/строки
    %   SELECTION - массив [row, col] выделенных ячеек
    
    if isempty(selection)
        % Нет выделения - использовать все данные
        app.selectedColumns = [];
        app.selectedRows = [];
        return;
    end
    
    % Определить режим
    if strcmp(app.currentPlotType, 'columns')
        % Режим "по столбцам"
        % Извлечь уникальные столбцы
        selectedCols = unique(selection(:, 2));
        % Исключить столбец X (столбец 1) и метки
        app.selectedColumns = selectedCols(selectedCols > 1);
    else
        % Режим "по строкам"
        % Извлечь уникальные строки
        selectedRows = unique(selection(:, 1));
        % Исключить строку X (строка 1) и метки
        app.selectedRows = selectedRows(selectedRows > 1);
    end
end
```

**Status:** Not Started

---

## Testing & Verification

### Test Strategy
Тестировать выделение различных комбинаций ячеек.

### Unit Tests
**Test 1: Определение выделенных столбцов**
```matlab
function test_updateSelection_columns()
    % Arrange
    app = TableGraphEditor;
    app.currentPlotType = 'columns';
    selection = [2 2; 2 3; 3 2; 3 3]; % Выделены столбцы 2 и 3
    
    % Act
    updateSelection(app, selection);
    
    % Assert
    assert(isequal(app.selectedColumns, [2; 3]), 'Столбцы должны быть [2, 3]');
    assert(isempty(app.selectedRows), 'Строки должны быть пустыми');
end
```

**Status:** Not Started

---

## Documentation Updates

### Files to Update
- [ ] Комментарии в коде
- [ ] USER_GUIDE.md (раздел "Выделение данных")

---

## Progress Log

### 2026-01-06
- Task created
- Design completed

---

## Completion Checklist

Before marking this task as complete:

- [ ] Callback `tblDataSelectionChanged` реализован
- [ ] Функция `updateSelection` реализована
- [ ] Выделение определяется корректно
- [ ] Столбец/строка X исключаются
- [ ] График обновляется при изменении выделения
- [ ] Тесты написаны и проходят

---

## Sign-off

**Completed by:** [Имя]  
**Date:** 2026-01-06  
**Reviewed by:** [Имя]  
**Date:** 2026-01-06


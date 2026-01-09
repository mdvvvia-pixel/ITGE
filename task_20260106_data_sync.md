# Task: Синхронизация данных таблица ↔ график

**Date:** 2026-01-06  
**Status:** Planning  
**Priority:** High  
**Assignee:** [Имя]  
**Related Files:** 
- `TableGraphEditor/src/TableGraphEditor.mlapp`
- `TableGraphEditor/src/helpers/validateNumericData.m`

---

## Objective

Реализовать двустороннюю синхронизацию данных между таблицей и графиком. При редактировании таблицы график должен обновляться, и наоборот. Включить валидацию числовых данных.

**Success Criteria:**
- [ ] При редактировании таблицы график обновляется
- [ ] При перетаскивании точки таблица обновляется
- [ ] Валидация числовых данных работает
- [ ] Метки не редактируются (read-only)
- [ ] Используется `drawnow limitrate` для оптимизации

---

## Background

### Context
Это пятый этап разработки MVP. Необходимо обеспечить синхронизацию между таблицей и графиком для полноценного редактирования данных.

### Requirements
- Таблица → График: автоматическое обновление
- График → Таблица: автоматическое обновление (уже частично реализовано в drag_and_drop)
- Валидация числовых значений
- Метки read-only
- Оптимизация производительности

### Dependencies
- **Requires:** 
  - `task_20260106_project_structure.md` (базовая структура)
  - `task_20260106_graph_plotting.md` (построение графиков)
  - `task_20260106_drag_and_drop.md` (перетаскивание точек)
- **Blocks:** `task_20260106_saving.md` (сохранение)

---

## Approach

### Design Overview
1. Реализовать callback для редактирования таблицы
2. Валидировать введенные данные
3. Обновить `currentData`
4. Обновить график
5. Настроить редактируемость ячеек (метки read-only)

### Algorithm

**Pseudocode:**
```
1. tblDataCellEdit callback:
   - Получить измененную ячейку (row, col)
   - Проверить, не является ли это меткой
   - Валидировать значение (числовое)
   - Обновить currentData
   - Обновить график

2. validateNumericData:
   - Проверить, что значение числовое
   - Проверить, что не NaN/Inf (опционально)
   - Вернуть true/false
```

---

## Implementation Plan

### Phase 1: Валидация данных
**Goal:** Реализовать валидацию числовых данных

**Tasks:**
1. Создать функцию `validateNumericData(value)`
2. Проверить числовой тип
3. Обработать edge cases (NaN, Inf, пустые значения)

**Deliverables:**
- [ ] Функция валидации работает
- [ ] Edge cases обработаны

### Phase 2: Callback редактирования таблицы
**Goal:** Обработать редактирование ячеек таблицы

**Tasks:**
1. Создать callback `tblDataCellEdit`
2. Получить измененную ячейку
3. Проверить, не является ли это меткой
4. Валидировать значение
5. Обновить данные
6. Обновить график

**Deliverables:**
- [ ] Callback работает
- [ ] Данные обновляются

### Phase 3: Настройка редактируемости ячеек
**Goal:** Сделать метки read-only

**Tasks:**
1. Настроить `uitable.ColumnEditable` или `uitable.CellEditCallback`
2. Запретить редактирование первой строки/столбца
3. Обработать попытки редактирования меток

**Deliverables:**
- [ ] Метки не редактируются
- [ ] Остальные ячейки редактируемые

### Phase 4: Оптимизация обновлений
**Goal:** Оптимизировать частоту обновлений графика

**Tasks:**
1. Использовать `drawnow limitrate` в callback
2. Дебаунсинг обновлений (опционально)
3. Обновлять только измененные кривые (опционально)

**Deliverables:**
- [ ] Обновления оптимизированы
- [ ] Производительность приемлемая

---

## Implementation Notes

### Key Decisions
**Decision 1:** Валидировать при редактировании, а не при потере фокуса
- **Rationale:** Немедленная обратная связь пользователю
- **Alternatives:** Валидация при потере фокуса
- **Trade-offs:** Может быть навязчиво, но более безопасно

**Decision 2:** Использовать CellEditCallback вместо ColumnEditable
- **Rationale:** Больше контроля над валидацией
- **Alternatives:** Использовать ColumnEditable для read-only
- **Trade-offs:** Нужно обрабатывать все ячейки вручную

### Technical Challenges
**Challenge 1:** Определение, является ли ячейка меткой
- **Solution:** Проверять row == 1 (для "по столбцам") или col == 1 (для "по строкам")
- **Notes:** Нужно учитывать текущий режим

**Challenge 2:** Обработка ошибок валидации
- **Solution:** Показать сообщение и восстановить предыдущее значение
- **Notes:** Использовать `uialert` для сообщений

---

## Code Implementation

### Helper Function: validateNumericData

**File:** `src/helpers/validateNumericData.m`

```matlab
function isValid = validateNumericData(value)
    % VALIDATENUMERICDATA Валидировать числовое значение
    %   ISVALID = VALIDATENUMERICDATA(VALUE) возвращает true, если значение валидно
    
    isValid = false;
    
    % Проверить, что значение не пустое
    if isempty(value)
        return;
    end
    
    % Попытаться преобразовать в число
    if ischar(value) || isstring(value)
        % Попытаться преобразовать строку в число
        numValue = str2double(value);
        if isnan(numValue)
            return;
        end
        value = numValue;
    end
    
    % Проверить, что значение числовое
    if ~isnumeric(value)
        return;
    end
    
    % Проверить, что это скаляр
    if ~isscalar(value)
        return;
    end
    
    % Проверить на NaN и Inf (можно разрешить или запретить)
    % if isnan(value) || isinf(value)
    %     return;
    % end
    
    isValid = true;
end
```

**Status:** Not Started

### Callback: tblDataCellEdit

```matlab
function tblDataCellEdit(app, event)
    % TBLDATACELLEDIT Обработчик редактирования ячейки таблицы
    %   Валидирует данные и обновляет график
    
    try
        % Получить индексы измененной ячейки
        row = event.Indices(1);
        col = event.Indices(2);
        
        % Проверить, не является ли это меткой
        if strcmp(app.currentPlotType, 'columns')
            % Режим "по столбцам": первая строка = метки
            if row == 1
                % Это метка - запретить редактирование
                uialert(app.UIFigure, ...
                    'Метки не могут быть отредактированы', ...
                    'Ошибка редактирования', ...
                    'Icon', 'warning');
                % Восстановить предыдущее значение
                app.tblData.Data{row, col} = app.currentData(row, col);
                return;
            end
        else
            % Режим "по строкам": первый столбец = метки
            if col == 1
                % Это метка - запретить редактирование
                uialert(app.UIFigure, ...
                    'Метки не могут быть отредактированы', ...
                    'Ошибка редактирования', ...
                    'Icon', 'warning');
                % Восстановить предыдущее значение
                app.tblData.Data{row, col} = app.currentData(row, col);
                return;
            end
        end
        
        % Получить новое значение
        newValue = event.NewData;
        
        % Валидировать значение
        if ~validateNumericData(newValue)
            uialert(app.UIFigure, ...
                'Значение должно быть числовым', ...
                'Ошибка валидации', ...
                'Icon', 'error');
            % Восстановить предыдущее значение
            app.tblData.Data{row, col} = app.currentData(row, col);
            return;
        end
        
        % Преобразовать в число, если нужно
        if ischar(newValue) || isstring(newValue)
            newValue = str2double(newValue);
        end
        
        % Обновить данные
        app.currentData(row, col) = newValue;
        
        % Обновить график
        updateGraph(app);
        
        drawnow limitrate;
        
    catch ME
        uialert(app.UIFigure, ME.message, 'Ошибка редактирования');
        % Восстановить предыдущее значение
        if ~isempty(event.PreviousData)
            app.tblData.Data{event.Indices(1), event.Indices(2)} = event.PreviousData;
        end
    end
end
```

**Status:** Not Started

### Function: setupTableEditability

```matlab
function setupTableEditability(app)
    % SETUPTABLEEDITABILITY Настроить редактируемость ячеек таблицы
    %   Метки делаются read-only
    
    if isempty(app.currentData)
        return;
    end
    
    [numRows, numCols] = size(app.currentData);
    
    % Создать матрицу редактируемости
    editable = true(numRows, numCols);
    
    if strcmp(app.currentPlotType, 'columns')
        % Режим "по столбцам": первая строка = метки (read-only)
        editable(1, :) = false;
    else
        % Режим "по строкам": первый столбец = метки (read-only)
        editable(:, 1) = false;
    end
    
    % Установить редактируемость (если поддерживается)
    % Примечание: uitable может не поддерживать CellEditable напрямую
    % В этом случае используем CellEditCallback для проверки
    % app.tblData.ColumnEditable = editable; % Если поддерживается
end
```

**Status:** Not Started

---

## Testing & Verification

### Test Strategy
Тестировать редактирование таблицы и валидацию данных.

### Unit Tests
**Test 1: Валидация числовых данных**
```matlab
function test_validateNumericData()
    % Arrange & Act & Assert
    assert(validateNumericData(5) == true, 'Число должно быть валидным');
    assert(validateNumericData('5') == true, 'Строка "5" должна быть валидной');
    assert(validateNumericData('abc') == false, 'Строка "abc" не должна быть валидной');
    assert(validateNumericData([]) == false, 'Пустое значение не должно быть валидным');
end
```

**Status:** Not Started

### Integration Tests
**Test Case 1: Редактирование таблицы**
- **Description:** Отредактировать ячейку в таблице и проверить обновление графика
- **Input Data:** Данные загружены, график построен
- **Expected Output:** График обновляется при редактировании
- **Status:** Not Started

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

- [ ] Функция `validateNumericData` реализована
- [ ] Callback `tblDataCellEdit` реализован
- [ ] Метки не редактируются
- [ ] Валидация данных работает
- [ ] График обновляется при редактировании таблицы
- [ ] Оптимизация обновлений реализована
- [ ] Тесты написаны и проходят

---

## Sign-off

**Completed by:** [Имя]  
**Date:** 2026-01-06  
**Reviewed by:** [Имя]  
**Date:** 2026-01-06


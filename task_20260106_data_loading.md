# Task: Загрузка данных из workspace

**Date:** 2026-01-06  
**Status:** ✅ Complete and Verified (2026-01-09)  
**Priority:** High  
**Assignee:** [Имя]  
**Related Files:** 
- `TableGraphEditor/src/TableGraphEditor.mlapp`
- `TableGraphEditor/src/helpers/getWorkspaceVariables.m` (если нужен)

---

## Objective

Реализовать загрузку числовых матриц из workspace MATLAB в приложение. Пользователь должен иметь возможность выбрать переменную из dropdown списка, и данные должны загрузиться в таблицу.

**Success Criteria:**
- [x] Dropdown заполняется списком числовых переменных из workspace
- [x] При выборе переменной данные загружаются в таблицу
- [x] Обрабатываются ошибки (нечисловые данные, пустые переменные)
- [x] Метки извлекаются из первой строки/столбца
- [x] Данные валидируются (только числовые 2D матрицы)

---

## Background

### Context
Это второй этап разработки MVP. После создания базовой структуры необходимо реализовать загрузку данных из workspace.

### Requirements
- Загружать только числовые матрицы (2D)
- Игнорировать другие типы переменных
- Обновлять список при открытии приложения
- Обрабатывать ошибки gracefully

### Dependencies
- **Requires:** `task_20260106_project_structure.md` (базовая структура)
- **Blocks:** `task_20260106_graph_plotting.md` (построение графиков)

---

## Approach

### Design Overview
1. При запуске приложения загрузить список переменных из workspace
2. Отфильтровать только числовые матрицы
3. Заполнить dropdown списком переменных
4. При выборе переменной загрузить данные
5. Извлечь метки и числовые данные
6. Отобразить в таблице

### Algorithm

**Pseudocode:**
```
1. startupFcn:
   - Получить список переменных из workspace
   - Отфильтровать числовые матрицы (2D)
   - Заполнить dropdown

2. ddVariableValueChanged:
   - Получить выбранную переменную
   - Загрузить данные из workspace
   - Валидировать данные
   - Извлечь метки и данные
   - Обновить currentData и originalData
   - Обновить таблицу
```

### Data Structures

```matlab
% В properties уже определены:
selectedVariable    % Имя выбранной переменной
originalData        % Исходные данные
currentData         % Текущие данные
rowLabels           % Метки строк
columnLabels        % Метки столбцов
```

---

## Implementation Plan

### Phase 1: Получение списка переменных
**Goal:** Загрузить список числовых переменных из workspace

**Tasks:**
1. Создать функцию `getNumericVariables()` или встроить в startupFcn
2. Получить список переменных через `evalin('base', 'whos')`
3. Отфильтровать только числовые 2D матрицы
4. Извлечь имена переменных

**Deliverables:**
- [x] Функция получения списка переменных работает
- [x] Только числовые 2D матрицы в списке (исключены скаляры и 1D массивы)

### Phase 2: Заполнение Dropdown
**Goal:** Заполнить dropdown списком переменных

**Tasks:**
1. В startupFcn вызвать функцию получения переменных
2. Заполнить `app.ddVariable.Items`
3. Установить пустое значение по умолчанию или первую переменную

**Deliverables:**
- [x] Dropdown заполнен при запуске (через startupFcn)
- [x] Список обновляется корректно (только 2D матрицы)

### Phase 3: Загрузка данных
**Goal:** Загрузить данные при выборе переменной

**Tasks:**
1. Создать callback `ddVariableValueChanged`
2. Получить имя выбранной переменной
3. Загрузить данные через `evalin('base', variableName)`
4. Валидировать данные (числовая матрица, не пустая)
5. Сохранить в `app.selectedVariable`, `app.originalData`, `app.currentData`

**Deliverables:**
- [x] Данные загружаются при выборе (через ddVariableValueChanged callback)
- [x] Валидация работает корректно (только 2D матрицы через ismatrix)

### Phase 4: Извлечение меток и данных
**Goal:** Разделить метки и числовые данные

**Tasks:**
1. Извлечь первую строку/столбец как метки
2. Остальные данные как числовые
3. Сохранить метки в `app.columnLabels` или `app.rowLabels`
4. Сохранить числовые данные в `app.currentData`

**Deliverables:**
- [x] Метки извлекаются корректно (функция updateTableWithData)
- [x] Числовые данные отделены от меток (сохраняются в app.columnLabels/rowLabels)

### Phase 5: Обновление таблицы
**Goal:** Отобразить данные в таблице

**Tasks:**
1. Установить `app.tblData.Data` = полная матрица (с метками)
2. Настроить редактируемость ячеек (метки read-only)
3. Обновить размеры таблицы

**Deliverables:**
- [x] Данные отображаются в таблице (через updateTableWithData)
- [ ] Метки не редактируются (TODO: настройка редактируемости ячеек в следующей задаче)

---

## Implementation Notes

### Key Decisions
**Decision 1:** Хранить метки вместе с данными в таблице
- **Rationale:** Упрощает отображение и синхронизацию
- **Alternatives:** Хранить метки отдельно
- **Trade-offs:** Нужна валидация при редактировании

**Decision 2:** Использовать evalin для загрузки
- **Rationale:** Стандартный способ работы с workspace
- **Alternatives:** Передавать данные как параметр
- **Trade-offs:** evalin менее безопасен, но необходим для workspace

### Technical Challenges
**Challenge 1:** Валидация данных
- **Solution:** Проверять isnumeric, ismatrix, размерность
- **Notes:** Нужно обрабатывать edge cases (пустые матрицы, 1D массивы)

**Challenge 2:** Обработка меток (текстовые vs числовые)
- **Solution:** Всегда интерпретировать первую строку/столбец как метки
- **Notes:** Если метки числовые, конвертировать в строки для отображения

---

## Code Implementation

### Main Function: startupFcn

**File:** `src/TableGraphEditor.mlapp`

**Interface:**
```matlab
function startupFcn(app)
    % STARTUPCN Вызывается при запуске приложения
    %   Загружает список переменных из workspace и заполняет dropdown
    
    try
        % Получить список числовых переменных
        vars = getNumericVariables();
        
        % Заполнить dropdown
        if ~isempty(vars)
            app.ddVariable.Items = vars;
            app.ddVariable.ItemsData = vars;
        else
            app.ddVariable.Items = {'Нет числовых переменных'};
            app.ddVariable.Enable = 'off';
        end
        
    catch ME
        uialert(app.UIFigure, ME.message, 'Ошибка загрузки');
    end
end
```

**Status:** Not Started

### Helper Function: getNumericVariables

**File:** `src/helpers/getNumericVariables.m` (опционально, можно встроить)

```matlab
function vars = getNumericVariables()
    % GETNUMERICVARIABLES Получить список числовых матриц из workspace
    %   VARS = GETNUMERICVARIABLES() возвращает cell array имен переменных
    
    % Получить список всех переменных
    wsVars = evalin('base', 'whos');
    
    % Отфильтровать числовые 2D матрицы
    vars = {};
    for i = 1:length(wsVars)
        if strcmp(wsVars(i).class, 'double') || ...
           strcmp(wsVars(i).class, 'single') || ...
           strcmp(wsVars(i).class, 'int8') || ...
           strcmp(wsVars(i).class, 'uint8') || ...
           strcmp(wsVars(i).class, 'int16') || ...
           strcmp(wsVars(i).class, 'uint16') || ...
           strcmp(wsVars(i).class, 'int32') || ...
           strcmp(wsVars(i).class, 'uint32') || ...
           strcmp(wsVars(i).class, 'int64') || ...
           strcmp(wsVars(i).class, 'uint64')
            
            % Проверить, что это 2D матрица
            if length(wsVars(i).size) == 2 && ...
               all(wsVars(i).size > 0)
                vars{end+1} = wsVars(i).name;
            end
        end
    end
end
```

**Status:** Not Started

### Callback: ddVariableValueChanged

```matlab
function ddVariableValueChanged(app, event)
    % DDVARIABLEVALUECHANGED Обработчик выбора переменной
    %   Загружает данные из workspace при выборе переменной
    
    try
        % Получить выбранную переменную
        varName = app.ddVariable.Value;
        
        if isempty(varName) || strcmp(varName, 'Нет числовых переменных')
            return;
        end
        
        % Загрузить данные
        data = evalin('base', varName);
        
        % Валидировать данные
        if ~isnumeric(data) || ~ismatrix(data) || isempty(data)
            uialert(app.UIFigure, ...
                'Выбранная переменная должна быть числовой матрицей', ...
                'Ошибка загрузки');
            return;
        end
        
        % Сохранить имя переменной
        app.selectedVariable = varName;
        
        % Сохранить данные
        app.originalData = data;
        app.currentData = data;
        
        % Извлечь метки и обновить таблицу
        updateTableWithData(app);
        
    catch ME
        uialert(app.UIFigure, ME.message, 'Ошибка загрузки данных');
    end
end
```

**Status:** ✅ Implemented (2026-01-08)

**Примечание:** Реализован через helper функцию `loadVariableFromWorkspace` из папки `helpers/`

### Helper Function: updateTableWithData

```matlab
function updateTableWithData(app)
    % UPDATETABLEWITHDATA Обновить таблицу с данными
    %   Извлекает метки и отображает данные в таблице
    
    data = app.currentData;
    
    % Извлечь метки в зависимости от режима
    if strcmp(app.currentPlotType, 'columns')
        % Режим "по столбцам": первая строка = метки
        app.columnLabels = data(1, 2:end);
        % Сохранить полную матрицу для отображения
        app.tblData.Data = data;
    else
        % Режим "по строкам": первый столбец = метки
        app.rowLabels = data(2:end, 1);
        % Сохранить полную матрицу для отображения
        app.tblData.Data = data;
    end
    
    % Настроить редактируемость (метки read-only)
    % TODO: Реализовать в следующей задаче
end
```

**Status:** ✅ Implemented (2026-01-08)

**Примечание:** Функция создана в `helpers/updateTableWithData.m` и вызывается из `loadVariableFromWorkspace`

---

## Testing & Verification

### Test Strategy
Тестировать загрузку различных типов данных и обработку ошибок.

### Unit Tests
**Test 1: Получение списка переменных**
```matlab
function test_getNumericVariables()
    % Arrange
    % Создать тестовые переменные в workspace
    testMatrix = rand(10, 5);
    testScalar = 5;
    testString = 'test';
    assignin('base', 'testMatrix', testMatrix);
    assignin('base', 'testScalar', testScalar);
    assignin('base', 'testString', testString);
    
    % Act
    vars = getNumericVariables();
    
    % Assert
    assert(ismember('testMatrix', vars), 'testMatrix должна быть в списке');
    assert(~ismember('testScalar', vars), 'testScalar не должна быть в списке');
    assert(~ismember('testString', vars), 'testString не должна быть в списке');
end
```

**Status:** Not Started

### Integration Tests
**Test Case 1: Загрузка данных**
- **Description:** Выбрать переменную из dropdown и проверить загрузку
- **Input Data:** Переменная testData = rand(10, 3) в workspace
- **Expected Output:** Данные загружены, таблица обновлена
- **Status:** Not Started

---

## Documentation Updates

### Files to Update
- [ ] Комментарии в коде
- [ ] USER_GUIDE.md (раздел "Загрузка данных")

---

## Progress Log

### 2026-01-06
- Task created
- Design completed

### 2026-01-08
- ✅ Улучшен `updateVariableDropdown.m` - фильтрует только 2D матрицы (исключает скаляры и 1D массивы)
- ✅ Улучшен `validateData.m` - добавлена проверка 2D матрицы через `ismatrix()`
- ✅ Улучшен `loadVariableFromWorkspace.m` - добавлена валидация 2D матриц перед загрузкой
- ✅ Создан `updateTableWithData.m` - функция для извлечения меток и обновления таблицы
- ✅ Обновлен `METHODS_FOR_MLAPP.m` - добавлены шаблоны для `startupFcn` и `ddVariableValueChanged`
- ✅ Обновлена документация в `helpers/README.md`
- ✅ Все функции соответствуют требованиям задачи и MATLAB_STYLE_GUIDE

### 2026-01-09
- ✅ Исправлена проблема с конфликтом метода `loadVariableFromWorkspace` в `.mlapp` файле
- ✅ Удалены дублирующие файлы `src/loadVariableFromWorkspace.m` и `src/updateVariableDropdown.m`
- ✅ Улучшена безопасность проверок в `updateGraph.m` (безопасная проверка `isUpdating`)
- ✅ Улучшена логика получения данных в `updateTableWithData.m` (множественные fallback источники)
- ✅ Добавлен callback `ddPlotTypeValueChanged` с обновлением таблицы
- ✅ **Проверено и работает:** при загрузке переменной данные отображаются в таблице и график строится автоматически

---

## Completion Checklist

Before marking this task as complete:

- [x] Список переменных загружается при запуске (startupFcn → updateVariableDropdown)
- [x] Dropdown заполнен корректно (только 2D матрицы)
- [x] Данные загружаются при выборе переменной (ddVariableValueChanged → loadVariableFromWorkspace)
- [x] Валидация данных работает (проверка через isnumeric && ismatrix)
- [x] Метки извлекаются корректно (updateTableWithData)
- [x] Таблица обновляется (updateTableWithData → app.tblData.Data)
- [x] Обработка ошибок реализована (try-catch блоки, uialert)
- [ ] Тесты написаны и проходят (TODO: ручное тестирование в MATLAB)

**Примечание:** Ручное тестирование требуется выполнить в MATLAB после добавления методов в .mlapp файл

---

## Sign-off

**Completed by:** AI Assistant  
**Date:** 2026-01-09  
**Verified by:** User  
**Date:** 2026-01-09  
**Status:** ✅ Complete and Working

## Implementation Summary

### Реализованные компоненты:

1. **`updateVariableDropdown.m`** (обновлен)
   - Фильтрует только числовые 2D матрицы из workspace
   - Использует `whos` для точной проверки размерности
   - Исключает скаляры и 1D массивы

2. **`validateData.m`** (обновлен)
   - Проверяет, что данные являются числовой 2D матрицей
   - Использует `ismatrix()` для проверки размерности
   - Возвращает понятные сообщения об ошибках

3. **`loadVariableFromWorkspace.m`** (обновлен)
   - Загружает и валидирует 2D матрицы из workspace
   - Сохраняет данные в app.currentData и app.originalData
   - Вызывает `updateTableWithData` для обновления таблицы

4. **`updateTableWithData.m`** (создан)
   - Извлекает метки из первой строки/столбца в зависимости от режима
   - Сохраняет метки в app.columnLabels или app.rowLabels
   - Обновляет таблицу данными

5. **`METHODS_FOR_MLAPP.m`** (обновлен)
   - Шаблоны для `startupFcn` и `ddVariableValueChanged`
   - Правильная интеграция с helper функциями

### Финальное состояние (2026-01-09):

✅ **Все функции работают корректно:**
- При загрузке переменной данные отображаются в таблице
- График строится автоматически при загрузке
- При изменении типа графика (`ddPlotType`) таблица и график обновляются
- Все helper функции вызываются правильно

### Следующие шаги:

1. ✅ Методы `startupFcn` и `ddVariableValueChanged` добавлены в `.mlapp` файл
2. ✅ Ручное тестирование выполнено - все работает
3. ➡️ Перейти к следующей задаче: `task_20260106_graph_plotting.md`


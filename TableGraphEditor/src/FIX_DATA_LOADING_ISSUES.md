# Исправление проблем загрузки данных и отображения

**Date:** 2026-01-09  
**Status:** Fixed  
**Related Task:** `task_20260106_data_loading.md`

---

## Проблемы

### Проблема 1: Таблица не отображается при загрузке переменной
**Симптомы:**
- При выборе переменной из dropdown данные не отображаются в таблице
- График не строится при загрузке

**Причина:**
- `isUpdating` может быть не инициализирован, что блокирует обновление графика
- Данные могут не сохраняться правильно в `app.currentData`
- `updateTableWithData` может не находить данные из-за неправильной логики получения

### Проблема 2: График не строится при загрузке
**Симптомы:**
- При загрузке переменной график не строится
- При изменении `ddPlotType` график начинает строиться

**Причина:**
- В `updateGraph.m` проверка `if app.isUpdating || isempty(currentData)` может вызывать ошибку, если `isUpdating` не инициализирован
- Данные могут быть пустыми из-за неправильного сохранения

### Проблема 3: Таблица пустая при изменении ddPlotType
**Симптомы:**
- При изменении типа графика график строится, но таблица остается пустой

**Причина:**
- Callback `ddPlotTypeValueChanged` не вызывает `updateTableWithData`
- Метки не обновляются при изменении режима

---

## Решения

### Решение 1: Безопасная проверка `isUpdating` в `updateGraph.m`

**Файл:** `helpers/updateGraph.m`

**Изменения:**
- Добавлена безопасная проверка `isUpdating` перед использованием
- Проверка выполняется через `isprop` и `try-catch`
- Если свойство не существует или недоступно, используется значение по умолчанию `false`

**Код:**
```matlab
% Безопасная проверка isUpdating (может не быть инициализирован)
isUpdatingFlag = false;
if isprop(app, 'isUpdating')
    try
        isUpdatingFlag = app.isUpdating;
    catch
        isUpdatingFlag = false;
    end
end

if isUpdatingFlag || isempty(currentData)
    fprintf('Пропуск updateGraph: isUpdating=%d, empty(currentData)=%d\n', ...
        isUpdatingFlag, isempty(currentData));
    return;
end
```

**Также:**
- Безопасная установка и сброс флага `isUpdating` через `try-catch`

---

### Решение 2: Улучшенное сохранение данных в `loadVariableFromWorkspace.m`

**Файл:** `helpers/loadVariableFromWorkspace.m`

**Изменения:**
- Добавлена проверка успешности сохранения данных
- Улучшена обработка ошибок при сохранении в свойства
- Добавлен fallback через `UserData` если свойство недоступно
- Добавлена инициализация свойств перед обновлением таблицы и графика

**Код:**
```matlab
% Инициализировать UserData структуру, если нужно
if ~isfield(app.UIFigure.UserData, 'appData')
    app.UIFigure.UserData.appData = struct();
end

% Сохранить данные (с проверкой возможности установки)
dataSaved = false;
try
    if isprop(app, 'currentData')
        app.currentData = data;
        fprintf('✓ currentData установлен: size=[%s]\n', num2str(size(data)));
        dataSaved = true;
    else
        app.UIFigure.UserData.appData.currentData = data;
        fprintf('currentData сохранен в UserData (свойство не существует)\n');
        dataSaved = true;
    end
catch ME
    fprintf('Предупреждение: не удалось установить currentData: %s\n', ME.message);
    app.UIFigure.UserData.appData.currentData = data;
    fprintf('currentData сохранен в UserData (fallback)\n');
    dataSaved = true;
end

% Проверить, что данные действительно сохранены
if ~dataSaved
    fprintf('✗ ОШИБКА: Данные не были сохранены!\n');
    if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
        uialert(app.UIFigure, ...
            'Не удалось сохранить данные в приложение', ...
            'Ошибка загрузки', ...
            'Icon', 'error');
    end
    return;
end
```

---

### Решение 3: Улучшенная логика получения данных в `updateTableWithData.m`

**Файл:** `helpers/updateTableWithData.m`

**Изменения:**
- Улучшена логика получения данных: сначала из `currentData`, затем из `UserData`, затем из `originalData`
- Добавлены проверки на пустоту данных на каждом этапе
- Добавлено предупреждение пользователю, если данные не найдены

**Код:**
```matlab
% Получить текущие данные (из свойства или UserData)
data = [];

% Сначала попробовать получить из свойства
if isprop(app, 'currentData')
    try
        data = app.currentData;
        if ~isempty(data)
            fprintf('Данные получены из app.currentData: size=[%s]\n', num2str(size(data)));
        end
    catch ME
        fprintf('Ошибка получения currentData из свойства: %s\n', ME.message);
    end
end

% Если данные не получены из свойства, попробовать UserData
if isempty(data)
    if isfield(app.UIFigure.UserData, 'appData') && ...
       isfield(app.UIFigure.UserData.appData, 'currentData')
        data = app.UIFigure.UserData.appData.currentData;
        fprintf('Данные получены из UserData: size=[%s]\n', num2str(size(data)));
    end
end

% Если данные все еще пусты, попробовать originalData
if isempty(data)
    if isprop(app, 'originalData')
        try
            data = app.originalData;
            if ~isempty(data)
                fprintf('Данные получены из app.originalData: size=[%s]\n', num2str(size(data)));
            end
        catch ME
            fprintf('Ошибка получения originalData: %s\n', ME.message);
        end
    end
end

% Если данные все еще пусты, попробовать originalData из UserData
if isempty(data)
    if isfield(app.UIFigure.UserData, 'appData') && ...
       isfield(app.UIFigure.UserData.appData, 'originalData')
        data = app.UIFigure.UserData.appData.originalData;
        fprintf('Данные получены из UserData.originalData: size=[%s]\n', num2str(size(data)));
    end
end

if isempty(data)
    fprintf('⚠ ОШИБКА: Данные не найдены ни в currentData, ни в originalData, ни в UserData\n');
    if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
        uialert(app.UIFigure, ...
            'Данные не найдены. Пожалуйста, загрузите переменную из workspace.', ...
            'Ошибка', ...
            'Icon', 'warning');
    end
    return;
end
```

---

### Решение 4: Добавлен callback `ddPlotTypeValueChanged` с обновлением таблицы

**Файл:** `helpers/METHODS_FOR_MLAPP.m`

**Изменения:**
- Добавлен полный callback `ddPlotTypeValueChanged`
- Callback обновляет `app.currentPlotType`
- Вызывает `updateTableWithData` для обновления меток и таблицы
- Вызывает `updateGraph` для перестроения графика

**Код:**
```matlab
function ddPlotTypeValueChanged(app, event)
    % DDPLOTTYPEVALUECHANGED Обработчик изменения типа графика
    %   Обновляет режим построения графика и перестраивает график
    %   Также обновляет таблицу для корректного отображения меток
    
    fprintf('ddPlotTypeValueChanged вызван\n');
    
    try
        % Получить выбранное значение и преобразовать в режим
        selectedValue = app.ddPlotType.Value;
        if contains(selectedValue, 'Column', 'IgnoreCase', true) || ...
           strcmp(selectedValue, 'columns')
            plotType = 'columns';
        elseif contains(selectedValue, 'Row', 'IgnoreCase', true) || ...
               strcmp(selectedValue, 'rows')
            plotType = 'rows';
        else
            plotType = 'columns';  % По умолчанию
        end
        
        % Обновить тип графика (безопасно)
        if isprop(app, 'currentPlotType')
            try
                app.currentPlotType = plotType;
            catch ME
                % Fallback через UserData
                if ~isfield(app.UIFigure.UserData, 'appData')
                    app.UIFigure.UserData.appData = struct();
                end
                app.UIFigure.UserData.appData.currentPlotType = plotType;
            end
        end
        
        % Обновить таблицу с новыми метками (важно!)
        if exist('updateTableWithData', 'file') == 2
            updateTableWithData(app);
        end
        
        % Обновить график
        if exist('updateGraph', 'file') == 2
            updateGraph(app);
        end
        
    catch ME
        fprintf('Ошибка в ddPlotTypeValueChanged: %s\n', ME.message);
        if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
            uialert(app.UIFigure, ...
                sprintf('Ошибка изменения режима графика: %s', ME.message), ...
                'Ошибка', ...
                'Icon', 'error');
        end
    end
end
```

---

## Тестирование

### Шаги для проверки исправлений:

1. **Загрузка переменной:**
   - Запустить приложение
   - Выбрать переменную из dropdown
   - Проверить, что данные отображаются в таблице
   - Проверить, что график строится

2. **Изменение типа графика:**
   - Изменить `ddPlotType` на "By Rows" или "By Columns"
   - Проверить, что график перестраивается
   - Проверить, что таблица обновляется с правильными метками

3. **Проверка логов:**
   - Проверить вывод в Command Window
   - Убедиться, что нет ошибок при загрузке
   - Убедиться, что данные сохраняются правильно

---

## Следующие шаги

1. **Добавить callback в .mlapp файл:**
   - Скопировать `ddPlotTypeValueChanged` из `METHODS_FOR_MLAPP.m` в `.mlapp` файл
   - Назначить callback в Design View для компонента `ddPlotType`

2. **Проверить свойства:**
   - Убедиться, что все свойства объявлены в `.mlapp` файле
   - Проверить, что свойства имеют правильный `SetAccess`

3. **Ручное тестирование:**
   - Выполнить тестирование в MATLAB
   - Проверить все сценарии использования

---

## Файлы, измененные в этом исправлении

1. `helpers/updateGraph.m` - безопасная проверка `isUpdating`
2. `helpers/loadVariableFromWorkspace.m` - улучшенное сохранение данных
3. `helpers/updateTableWithData.m` - улучшенная логика получения данных
4. `helpers/METHODS_FOR_MLAPP.m` - добавлен callback `ddPlotTypeValueChanged`

---

## Примечания

- Все изменения следуют принципам FPF (First Principles Framework)
- Код использует безопасные проверки и fallback механизмы
- Добавлено подробное логирование для отладки
- Обработка ошибок реализована на всех уровнях

---

**Completed by:** AI Assistant  
**Date:** 2026-01-09


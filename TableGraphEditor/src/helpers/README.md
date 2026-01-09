# Helper функции для TableGraphEditor

**Date:** 2026-01-08  
**Purpose:** Вспомогательные функции для приложения TableGraphEditor

---

## Описание

Эти функции содержат основную логику приложения и вызываются из методов в `.mlapp` файле.

---

## Файлы

### 1. `updateVariableDropdown.m`
Обновляет список переменных в dropdown, фильтруя только числовые переменные из workspace.

**Использование:**
```matlab
updateVariableDropdown(app);
```

### 2. `loadVariableFromWorkspace.m`
Загружает переменную из workspace и сохраняет в `app.currentData`.

**Использование:**
```matlab
loadVariableFromWorkspace(app, 'variableName');
```

### 3. `plotByColumns.m`
Строит график, где каждый столбец данных отображается как отдельная кривая.

**Использование:**
```matlab
plotByColumns(app, data);
```

### 4. `plotByRows.m`
Строит график, где каждая строка данных отображается как отдельная кривая.

**Использование:**
```matlab
plotByRows(app, data);
```

### 5. `updateGraph.m`
Обновляет график на основе текущих данных и выбранного типа (столбцы/строки).

**Использование:**
```matlab
updateGraph(app);
```

### 6. `validateData.m`
Проверяет корректность данных (числовая 2D матрица).

**Использование:**
```matlab
isValid = validateData(app, data);
```

### 7. `updateTableWithData.m`
Извлекает метки и обновляет таблицу данными.

**Использование:**
```matlab
updateTableWithData(app);
```

### 8. `findNumericFieldsInStruct.m`
Рекурсивно находит числовые 2D поля в структуре.

**Использование:**
```matlab
paths = findNumericFieldsInStruct(structVar, 'structName');
% Возвращает: {'structName.field1', 'structName.field2.subfield', ...}
```

### 9. `getAllNumericVariables.m`
Получает все числовые переменные из workspace (прямые и из структур).

**Использование:**
```matlab
allVars = getAllNumericVariables();
% allVars.names - имена для отображения
% allVars.paths - пути для загрузки
% allVars.types - типы ('direct' или 'struct')
```

### 10. `saveVariableToWorkspace.m`
Сохраняет переменную в workspace (поддерживает прямые переменные и структуры).

**Использование:**
```matlab
saveVariableToWorkspace(app, 'variableName', data);
saveVariableToWorkspace(app, 'struct.field', data);  % Для структур
```

---

## Интеграция с .mlapp

### Вариант 1: Прямой вызов (рекомендуется)

В методах `.mlapp` файла просто вызывайте функции:

```matlab
function startupFcn(app, varargin)
    updateVariableDropdown(app);  % Вызов helper функции
end

function ddVariableValueChanged(app, event)
    varName = app.ddVariable.Value;
    if ~isempty(varName) && ~strcmp(varName, 'Select variable...')
        loadVariableFromWorkspace(app, varName);  % Вызов helper функции
    end
end
```

### Вариант 2: Обертки методов

Если нужны обертки в `.mlapp`, используйте код из `METHODS_FOR_MLAPP.m`.

---

## Пути

Все функции находятся в папке `helpers/`, которая должна быть в MATLAB path.

App Designer автоматически добавляет папку с `.mlapp` файлом в path, поэтому функции будут доступны.

---

## Преимущества такого подхода

✅ **Модульность** - каждая функция в отдельном файле  
✅ **Тестируемость** - можно тестировать функции отдельно  
✅ **Читаемость** - код в `.mlapp` остается чистым  
✅ **Переиспользование** - функции можно использовать в других проектах  
✅ **Версионирование** - легче отслеживать изменения в Git  

---

## Обновления

### 2026-01-08: Улучшения загрузки данных
- ✅ `updateVariableDropdown` теперь фильтрует только 2D матрицы (исключает скаляры и 1D массивы)
- ✅ `validateData` проверяет, что данные являются именно 2D матрицей
- ✅ `loadVariableFromWorkspace` валидирует 2D матрицы перед загрузкой
- ✅ Добавлена функция `updateTableWithData` для извлечения меток и обновления таблицы

### 2026-01-09: Поддержка переменных из структур
- ✅ Добавлена функция `findNumericFieldsInStruct` для рекурсивного поиска числовых полей в структурах
- ✅ Добавлена функция `getAllNumericVariables` для получения всех переменных (прямых и из структур)
- ✅ Обновлен `updateVariableDropdown` для поддержки переменных из структур
- ✅ Обновлен `loadVariableFromWorkspace` для загрузки данных из структур (пути вида 'struct.field')
- ✅ Добавлена функция `saveVariableToWorkspace` для сохранения данных (включая структуры)

### Изменения в валидации:
- Требуется числовая 2D матрица (не скаляр, не 1D массив)
- Используется `ismatrix()` для проверки размерности
- Используется `whos` вместо `who` для более точной проверки размерности

### Поддержка структур:
- Рекурсивный поиск числовых 2D матриц в структурах любой глубины
- Поддержка путей вида `struct.field` или `struct.field.subfield`
- Автоматическое сохранение изменений обратно в структуру

---

## Следующие шаги

1. ✅ Helper функции созданы и обновлены
2. ⏳ Добавьте методы-обертки в `.mlapp` (опционально, можно вызывать напрямую)
3. ⏳ Реализуйте callbacks для UI компонентов
4. ✅ Базовая функциональность загрузки данных реализована


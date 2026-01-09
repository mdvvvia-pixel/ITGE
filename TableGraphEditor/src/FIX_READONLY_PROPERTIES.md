# Решение: Properties не могут быть установлены (read-only)

**Date:** 2026-01-08  
**Ошибка:** "Setting the 'originalData' property of class 'TableGraphEditor' is not supported"  
**Причина:** Properties объявлены как read-only или с неправильным доступом

---

## 🔴 Проблема

Хотя Properties найдены через `isprop()`, они не могут быть установлены. Это означает, что они объявлены как:
- `Constant` (константы)
- `Dependent` (вычисляемые)
- Или имеют неправильный `SetAccess`

---

## ✅ Решение 1: Проверить объявление Properties

В App Designer Code View проверьте, что Properties объявлены правильно:

### ❌ Неправильно (read-only):

```matlab
properties (Access = private, SetAccess = private, GetAccess = public)
    originalData
end
```

или

```matlab
properties (Constant)
    originalData
end
```

### ✅ Правильно:

```matlab
properties (Access = private)
    originalData
    currentData
    % ... остальные свойства
end
```

**ВАЖНО:** Не должно быть `SetAccess = private` или `Constant`!

---

## ✅ Решение 2: Исправить объявление в .mlapp

### Шаг 1: Откройте .mlapp в App Designer

```matlab
cd('TableGraphEditor/src')
appdesigner('TableGraphEditor.mlapp')
```

### Шаг 2: Перейдите в Code View

### Шаг 3: Найдите секцию Properties

Найдите:

```matlab
properties (Access = private)
```

### Шаг 4: Убедитесь, что нет ограничений SetAccess

Должно быть просто:

```matlab
properties (Access = private)
    originalData
    currentData
    selectedVariable
    editMode = 'XY'
    currentPlotType = 'columns'
    selectedColumns = []
    selectedRows = []
    rowLabels = {}
    columnLabels = {}
    selectedPoint = []
    isDragging = false
    dragStartPosition = []
    isUpdating = false
end
```

**НЕ должно быть:**
- `SetAccess = private`
- `GetAccess = ...`
- `Constant`
- `Dependent`

### Шаг 5: Сохраните и перезапустите

---

## ✅ Решение 3: Использовать UserData (временное решение)

Если Properties действительно read-only, можно использовать `UserData` UIFigure:

```matlab
function loadVariableFromWorkspace(app, varName)
    try
        data = evalin('base', varName);
        
        % Сохранить в UserData вместо Properties
        if ~isfield(app.UIFigure.UserData, 'appData')
            app.UIFigure.UserData.appData = struct();
        end
        
        app.UIFigure.UserData.appData.originalData = data;
        app.UIFigure.UserData.appData.currentData = data;
        app.UIFigure.UserData.appData.selectedVariable = varName;
        
        % Обновить таблицу
        app.tblData.Data = data;
        
    catch ME
        uialert(app.UIFigure, ME.message, 'Ошибка');
    end
end
```

И в других местах использовать:
```matlab
app.UIFigure.UserData.appData.currentData
```

---

## 🔍 Диагностика

Запустите проверку свойств:

```matlab
app = TableGraphEditor;

% Проверить метаданные свойств
mc = metaclass(app);
for i = 1:length(mc.PropertyList)
    prop = mc.PropertyList(i);
    if strcmp(prop.Name, 'originalData')
        fprintf('Свойство: %s\n', prop.Name);
        fprintf('  SetAccess: %s\n', char(prop.SetAccess));
        fprintf('  GetAccess: %s\n', char(prop.GetAccess));
        fprintf('  Constant: %d\n', prop.Constant);
        fprintf('  Dependent: %d\n', prop.Dependent);
    end
end
```

Это покажет, почему свойство не может быть установлено.

---

## 📋 Рекомендация

**Лучше всего исправить объявление Properties** в `.mlapp` файле - убрать все ограничения `SetAccess`.

Если это невозможно, используйте `UserData` как временное решение.

---

**Проверьте объявление Properties и убедитесь, что нет ограничений SetAccess!**


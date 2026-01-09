# Решение: Properties с SetAccess = private

**Date:** 2026-01-08  
**Проблема:** Properties имеют `SetAccess: private`, поэтому их нельзя установить из helper функций  
**Решение:** Изменить объявление Properties в .mlapp

---

## 🔴 Проблема

Проверка показала:
- ✅ Все свойства найдены
- ✅ `SetAccess: private` (это нормально для private properties)
- ❌ **НО:** С `SetAccess: private` свойства можно устанавливать ТОЛЬКО из методов класса
- ❌ Helper функции находятся ВНЕ класса, поэтому не могут устанавливать свойства

---

## ✅ Решение: Изменить SetAccess

### Вариант 1: SetAccess = public (рекомендуется для helper функций)

В App Designer Code View измените объявление Properties:

**Было:**
```matlab
properties (Access = private)
    originalData
    currentData
    % ...
end
```

**Должно быть:**
```matlab
properties (Access = private, SetAccess = public)
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

**Или проще (если не нужно ограничивать чтение):**
```matlab
properties (Access = public)
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

### Вариант 2: Использовать методы класса (более правильный подход)

Создайте методы в `.mlapp` для установки свойств:

```matlab
methods (Access = private)
    function setCurrentData(app, data)
        app.currentData = data;
    end
    
    function setOriginalData(app, data)
        app.originalData = data;
    end
    
    % И так далее для всех свойств
end
```

Затем в helper функциях вызывайте эти методы.

---

## 📝 Пошаговая инструкция

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

### Шаг 4: Измените на

```matlab
properties (Access = private, SetAccess = public)
```

**Или:**

```matlab
properties (Access = public)
```

### Шаг 5: Сохраните и перезапустите

---

## ✅ Проверка после исправления

После изменения запустите:

```matlab
app = TableGraphEditor;
testPropertyAccess();
```

Все свойства должны устанавливаться успешно.

---

## 💡 Рекомендация

**Используйте `SetAccess = public`** - это позволит helper функциям устанавливать свойства, при этом `Access = private` сохранит их приватность для внешнего доступа (только через методы класса).

---

**Измените SetAccess в объявлении Properties!**


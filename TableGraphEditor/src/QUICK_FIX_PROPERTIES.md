# Быстрое решение: Properties read-only

**Date:** 2026-01-08  
**Ошибка:** "Setting the 'originalData' property is not supported"  
**Решение:** Исправить объявление Properties в .mlapp

---

## 🔴 Проблема

Properties найдены, но не могут быть установлены. Это означает, что они объявлены с ограничениями доступа.

---

## ✅ Быстрое решение

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

### Шаг 4: Проверьте, нет ли ограничений

**НЕ должно быть:**
- `SetAccess = private`
- `SetAccess = immutable`
- `Constant`
- `Dependent`

**Должно быть просто:**

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

### Шаг 5: Если есть ограничения - удалите их

Например, если видите:

```matlab
properties (Access = private, SetAccess = private)  % ← УДАЛИТЬ SetAccess = private
```

Измените на:

```matlab
properties (Access = private)  % ← БЕЗ SetAccess
```

### Шаг 6: Сохраните и перезапустите

---

## 🔍 Диагностика

Запустите проверку доступа:

```matlab
app = TableGraphEditor;
check_properties_access(app);
```

Это покажет, какие свойства могут быть установлены, а какие нет.

---

## 💡 Временное решение: UserData

Если Properties действительно read-only и их нельзя изменить, используйте `UserData`:

В `loadVariableFromWorkspace` данные будут сохраняться в `app.UIFigure.UserData.appData`, и обновленная функция уже это поддерживает.

---

**Проверьте объявление Properties и убедитесь, что нет SetAccess = private!**


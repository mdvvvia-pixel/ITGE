# Исправление конфликта метода loadVariableFromWorkspace

**Date:** 2026-01-09  
**Status:** ✅ Fixed (2026-01-09)  
**Priority:** High

---

## Проблема

В `.mlapp` файле существует метод `loadVariableFromWorkspace`, который перекрывает helper функцию из папки `helpers/`. Это приводит к тому, что при загрузке переменной не вызываются `updateTableWithData` и `updateGraph`.

**Симптомы:**
- При загрузке переменной данные не отображаются в таблице
- График не строится при загрузке
- При изменении `ddPlotType` все работает (так как вызывается напрямую `updateGraph`)

**Причина:**
В MATLAB методы класса имеют приоритет над функциями в path. Если в `.mlapp` файле есть метод `loadVariableFromWorkspace`, он будет вызываться вместо helper функции из `helpers/`.

---

## Решение

### Шаг 1: Удалить метод из .mlapp файла

1. Откройте файл `TableGraphEditor.mlapp` в App Designer
2. Перейдите в **Code View** (кнопка "Code" в правом верхнем углу)
3. Найдите метод `loadVariableFromWorkspace` в секции `methods (Access = private)`
4. **УДАЛИТЕ** весь метод полностью (включая комментарии)
5. Сохраните файл (Ctrl+S или Cmd+S)

### Шаг 2: Проверить, что helper функция вызывается

Убедитесь, что в методе `ddVariableValueChanged` вызывается helper функция:

```matlab
function ddVariableValueChanged(app, event)
    % ... код получения varName ...
    
    % Вызов helper функции из папки helpers/
    loadVariableFromWorkspace(app, varName);
end
```

Helper функция автоматически доступна, так как папка `helpers/` добавляется в MATLAB path.

### Шаг 3: Проверить работу

1. Запустите приложение
2. Выберите переменную из dropdown
3. Проверьте, что:
   - Данные отображаются в таблице
   - График строится автоматически
   - В Command Window видны логи из `loadVariableFromWorkspace`

---

## Удаленные файлы

Для устранения конфликтов были удалены следующие дублирующие файлы:

1. ✅ `src/loadVariableFromWorkspace.m` - старая версия без вызова `updateTableWithData` и `updateGraph`
2. ✅ `src/updateVariableDropdown.m` - старая версия, менее функциональная

Правильные версии находятся в `src/helpers/`:
- `src/helpers/loadVariableFromWorkspace.m` - полная версия с обновлением таблицы и графика
- `src/helpers/updateVariableDropdown.m` - полная версия с фильтрацией 2D матриц

---

## Проверка после исправления

После удаления метода из `.mlapp` файла, при загрузке переменной должны появиться следующие логи:

```
ddVariableValueChanged вызван
Выбранное значение: 'aa' (тип: char)
Обработанное значение: "aa"
Загрузка переменной: aa
loadVariableFromWorkspace вызван для: aa
Загрузка данных из workspace: aa
Данные загружены: size=[9  4], тип=double
✓ Валидация пройдена
✓ originalData установлен: size=[9  4]
✓ currentData установлен: size=[9  4]
✓ selectedVariable установлен: aa
Вызов updateTableWithData...
updateTableWithData вызван
Данные получены из app.currentData: size=[9  4]
✓ Таблица обновлена успешно
✓ updateTableWithData завершен
Вызов updateGraph...
updateGraph вызван
Данные для графика: size=[9  4]
✓ График обновлен
```

---

## Альтернативное решение (если метод нужен)

Если по каким-то причинам метод `loadVariableFromWorkspace` должен остаться в `.mlapp` файле, обновите его, чтобы он вызывал helper функцию:

```matlab
function loadVariableFromWorkspace(app, varName)
    % LOADVARIABLEFROMWORKSPACE Загружает переменную из workspace
    %   Вызывает helper функцию из папки helpers/
    
    % Получить путь к helper функции
    helpersPath = fullfile(fileparts(mfilename('fullpath')), 'helpers');
    
    % Добавить helpers в path, если еще не добавлен
    if ~contains(path, helpersPath)
        addpath(helpersPath);
    end
    
    % Вызвать helper функцию через полный путь
    % Используем eval для обхода приоритета методов класса
    eval(sprintf('helpers.loadVariableFromWorkspace(app, ''%s'')', varName));
end
```

**НО:** Это не рекомендуется, так как усложняет код и может вызвать проблемы с path.

---

## Файлы для справки

- `src/helpers/loadVariableFromWorkspace.m` - правильная версия helper функции
- `src/helpers/METHODS_FOR_MLAPP.m` - шаблоны методов для добавления в .mlapp
- `src/FIX_DATA_LOADING_ISSUES.md` - описание других исправлений

---

**Completed by:** AI Assistant  
**Date:** 2026-01-09


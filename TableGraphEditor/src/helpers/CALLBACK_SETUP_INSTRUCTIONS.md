# Инструкция: Настройка callback ddVariableValueChanged

**Дата:** 2026-01-08  
**Проблема:** После выбора переменной ничего не происходит

---

## ✅ Решение

### Шаг 1: Добавить метод в .mlapp файл

1. Откройте `TableGraphEditor.mlapp` в App Designer
2. Переключитесь в **Code View**
3. Найдите секцию `methods (Access = private)`
4. Скопируйте метод `ddVariableValueChanged` из файла `METHODS_FOR_MLAPP.m` (строки 71-134)
5. Вставьте его в секцию `methods (Access = private)`
6. Сохраните файл (Ctrl+S)

### Шаг 2: Проверить startupFcn

Убедитесь, что в `startupFcn` есть назначение callback (это должно работать автоматически, если обновленная версия скопирована).

### Шаг 3: Проверка

После добавления метода:

1. Перезапустите приложение:
   ```matlab
   app = TableGraphEditor;
   ```

2. Выберите переменную из dropdown

3. В командном окне MATLAB должно появиться:
   ```
   ddVariableValueChanged вызван
   Выбранное значение: [значение]
   Обработанное значение: "[имя переменной]"
   Загрузка переменной: [имя]
   ✓ Переменная загружена успешно
   ```

4. Таблица должна обновиться данными

---

## Альтернатива: Назначение через Design View

Если хотите назначить callback вручную через Design View:

1. В App Designer переключитесь в **Design View**
2. Выберите компонент `ddVariable`
3. В **Property Inspector** найдите **ValueChangedFcn**
4. В выпадающем списке выберите: **@app.ddVariableValueChanged**
   - Или введите вручную: `@app.ddVariableValueChanged`
5. Сохраните файл

---

## Отладочный вывод

Метод `ddVariableValueChanged` теперь включает отладочный вывод:
- Когда callback вызывается
- Какое значение выбрано
- Тип значения
- Обработанное значение
- Результат загрузки

Это поможет понять, работает ли callback и какие значения он получает.

---

## Если ничего не происходит

1. Проверьте, что метод добавлен:
   ```matlab
   ismethod(app, 'ddVariableValueChanged')  % Должно вернуть 1
   ```

2. Проверьте, что callback назначен:
   ```matlab
   app.ddVariable.ValueChangedFcn  % Не должно быть пусто
   ```

3. Проверьте отладочный вывод в командном окне MATLAB

4. Проверьте, что helper функции доступны:
   ```matlab
   exist('loadVariableFromWorkspace', 'file')  % Должно вернуть 2
   exist('updateTableWithData', 'file')  % Должно вернуть 2
   ```

---

## Файлы

- ✅ `METHODS_FOR_MLAPP.m` - обновлен с отладочным выводом и программным назначением callback
- ⏳ `.mlapp` файл - нужно добавить метод `ddVariableValueChanged`


# Task: Callback API для внешних программ

**Date:** 2026-01-09  
**Last Updated:** 2026-01-10  
**Status:** Planning  
**Priority:** High  
**Assignee:** [Имя]  
**Related Files:** 
- `TableGraphEditor/src/editTableData.m` (новый файл - wrapper функция)
- `TableGraphEditor/src/TableGraphEditor.mlapp` (модификация)
- `TableGraphEditor/docs/API_REFERENCE.md` (новый файл)

---

## Objective

Реализовать функцию-обертку для вызова TableGraphEditor из внешних программ с callback функцией. Callback вызывается при сохранении данных или закрытии приложения, позволяя внешней программе продолжить работу с обновленными данными.

**Сценарий использования:**
1. Внешняя программа работает с данными в Workspace
2. Возникает необходимость изменения данных
3. Внешняя программа вызывает TableGraphEditor через функцию `editTableData(variableName, callbackFunction)`
4. Пользователь корректирует данные в TableGraphEditor
5. Данные сохраняются в Workspace (или приложение закрывается без сохранения)
6. Вызывается callback функция во внешней программе с результатом
7. Внешняя программа продолжает работу

**Success Criteria:**
- [ ] Создана функция `editTableData(variableName, callbackFunction)`
- [ ] Функция создает экземпляр TableGraphEditor
- [ ] Функция автоматически загружает указанную переменную
- [ ] Callback вызывается при сохранении данных (`wasSaved = true`)
- [ ] Callback вызывается при закрытии без сохранения (`wasSaved = false`)
- [ ] Документация API создана
- [ ] Примеры использования предоставлены
- [ ] Обработка ошибок реализована

---

## Background

### Context
Это расширение функционала для интеграции с внешними системами. Вместо сложной системы событий нужна простая функция-обертка, которая позволяет внешним программам вызывать TableGraphEditor как утилиту для редактирования данных и получать уведомление о завершении работы.

### Requirements
- Простая функция-обертка для запуска приложения
- Автоматическая загрузка указанной переменной
- Callback функция вызывается при сохранении/закрытии
- Передача информации о результате (сохранено или нет)
- Обработка ошибок

### Dependencies
- **Requires:** 
  - Все этапы MVP (базовая функциональность) ✅
  - Загрузка переменной из Workspace ✅
  - Сохранение данных в Workspace ✅
- **Blocks:** 
  - Интеграция с внешними системами
  - Автоматизация процессов редактирования данных

---

## Approach

### Design Overview
1. Создать wrapper функцию `editTableData.m`
2. Модифицировать TableGraphEditor для поддержки callback
3. Добавить вызов callback при сохранении данных
4. Добавить вызов callback при закрытии приложения
5. Создать документацию и примеры

### Algorithm

**Pseudocode:**
```
1. editTableData(variableName, callbackFunction):
   - Проверить существование переменной в Workspace
   - Создать экземпляр TableGraphEditor
   - Сохранить callback в app.externalCallback
   - Автоматически загрузить переменную variableName
   - Вернуть объект app (для контроля, если нужно)

2. При сохранении данных (btnSaveButtonPushed):
   - Сохранить данные в Workspace (как раньше)
   - Если app.externalCallback существует:
     * Вызвать callback(variableName, data, true)
   - Закрыть приложение (опционально)

3. При закрытии приложения (UIFigureCloseRequest):
   - Если app.externalCallback существует и данные не сохранены:
     * Вызвать callback(variableName, data, false)
   - Закрыть приложение
```

### Callback Function Signature

```matlab
function callbackFunction(variableName, data, wasSaved)
    % CALLBACKFUNCTION Callback функция для TableGraphEditor
    %
    %   Параметры:
    %       variableName - имя переменной в Workspace (строка)
    %       data - данные (матрица) - текущее состояние данных
    %       wasSaved - логическое значение:
    %           true - данные были сохранены в Workspace
    %           false - приложение закрыто без сохранения
    %
    %   Пример:
    %       function myCallback(varName, data, saved)
    %           if saved
    %               fprintf('Данные %s сохранены\n', varName);
    %               % Продолжить работу с обновленными данными
    %           else
    %               fprintf('Изменения не сохранены\n');
    %           end
    %       end
```

### Data Structures

```matlab
% Новое свойство в TableGraphEditor.mlapp:
properties (SetAccess = public)
    % ... существующие свойства ...
    
    % === Callback API ===
    externalCallback = []  % Function handle callback функции от внешней программы
    wasSavedOnClose = false  % Флаг: были ли данные сохранены при закрытии
end
```

---

## Implementation Plan

### Phase 1: Wrapper функция editTableData
**Goal:** Создать функцию-обертку для запуска приложения

**Tasks:**
1. Создать файл `src/editTableData.m`
2. Реализовать проверку существования переменной в Workspace
3. Создать экземпляр TableGraphEditor
4. Передать callback в app.externalCallback
5. Автоматически загрузить переменную
6. Вернуть объект app

**Deliverables:**
- [ ] Функция `editTableData` реализована
- [ ] Проверка переменной работает
- [ ] Автоматическая загрузка работает

### Phase 2: Модификация TableGraphEditor для callback
**Goal:** Добавить поддержку callback в приложение

**Tasks:**
1. Добавить свойство `externalCallback` в app
2. Добавить свойство `wasSavedOnClose` в app
3. Модифицировать `btnSaveButtonPushed` для вызова callback при сохранении
4. Модифицировать `UIFigureCloseRequest` для вызова callback при закрытии
5. Реализовать обработку ошибок в callback

**Deliverables:**
- [ ] Свойства добавлены
- [ ] Callback вызывается при сохранении
- [ ] Callback вызывается при закрытии
- [ ] Обработка ошибок работает

### Phase 3: Документация и примеры
**Goal:** Создать документацию и примеры использования

**Tasks:**
1. Создать `docs/API_REFERENCE.md` с описанием API
2. Создать примеры использования в папке `examples/`
3. Добавить примеры в основной README
4. Документировать формат callback функции

**Deliverables:**
- [ ] Документация API создана
- [ ] Примеры использования предоставлены
- [ ] README обновлен

### Phase 4: Тестирование
**Goal:** Протестировать интеграцию с внешними программами

**Tasks:**
1. Написать тест для `editTableData`
2. Написать тест для callback при сохранении
3. Написать тест для callback при закрытии
4. Протестировать обработку ошибок

**Deliverables:**
- [ ] Все тесты проходят
- [ ] Интеграция работает корректно

---

## Implementation Notes

### Key Decisions
**Decision 1:** Использовать простую wrapper функцию вместо сложной системы событий
- **Rationale:** Соответствует сценарию использования - простая интеграция
- **Alternatives:** Система событий с множественными callback
- **Trade-offs:** Проще в реализации и использовании, но менее гибко

**Decision 2:** Callback вызывается только при сохранении/закрытии
- **Rationale:** Внешней программе нужен только финальный результат
- **Alternatives:** Callback на каждое изменение данных
- **Trade-offs:** Проще, но меньше информации о промежуточных изменениях

**Decision 3:** Передавать текущие данные в callback (даже если не сохранены)
- **Rationale:** Позволяет внешней программе решить, что делать с изменениями
- **Alternatives:** Передавать только при сохранении
- **Trade-offs:** Больше гибкости для внешней программы

**Decision 4:** Неблокирующий режим - приложение открывается, внешняя программа может продолжать работу
- **Rationale:** Пользователь может редактировать данные долго, блокировка не нужна
- **Alternatives:** Блокирующий режим (waitfor)
- **Trade-offs:** Больше гибкости, но нужно правильно обрабатывать асинхронность

### Technical Challenges
**Challenge 1:** Автоматическая загрузка переменной при запуске
- **Solution:** Вызвать метод загрузки переменной после создания приложения
- **Notes:** Нужно убедиться, что приложение полностью инициализировано

**Challenge 2:** Определение, были ли данные сохранены при закрытии
- **Solution:** Флаг `wasSavedOnClose` устанавливается в true при сохранении
- **Notes:** Проверять флаг при закрытии окна

**Challenge 3:** Обработка ошибок в callback функции
- **Solution:** Обернуть вызов callback в try-catch, логировать ошибки
- **Notes:** Ошибка в callback не должна ломать приложение

**Challenge 4:** Закрытие приложения после сохранения (опционально)
- **Solution:** Добавить опцию autoClose при вызове editTableData
- **Notes:** По умолчанию не закрывать, чтобы пользователь мог продолжить редактирование

---

## Code Implementation

### Wrapper Function: editTableData

**File:** `src/editTableData.m`

```matlab
function app = editTableData(variableName, callbackFunction, options)
    % EDITTABLEDATA Открыть TableGraphEditor для редактирования переменной
    %   APP = EDITTABLEDATA(VARIABLENAME, CALLBACKFUNCTION) открывает
    %   TableGraphEditor с загруженной переменной и вызывает callback
    %   при сохранении или закрытии приложения.
    %
    %   Параметры:
    %       variableName - имя переменной в Workspace (строка)
    %       callbackFunction - function handle callback функции (опционально)
    %                          Формат: callbackFunction(varName, data, wasSaved)
    %       options - структура с опциями (опционально):
    %           .autoClose - закрыть приложение после сохранения (default: false)
    %
    %   Возвращает:
    %       app - объект приложения TableGraphEditor
    %
    %   Пример:
    %       % Простой вызов
    %       app = editTableData('myData');
    %
    %       % С callback функцией
    %       callback = @(var, data, saved) fprintf('Saved: %d\n', saved);
    %       app = editTableData('myData', callback);
    %
    %   See also: TableGraphEditor
    
    % Обработка входных параметров
    if nargin < 1
        error('Необходимо указать имя переменной');
    end
    
    if nargin < 2
        callbackFunction = [];
    end
    
    if nargin < 3
        options = struct();
    end
    
    % Проверить существование переменной в Workspace
    if ~evalin('base', sprintf('exist(''%s'', ''var'')', variableName))
        error('Переменная ''%s'' не найдена в Workspace', variableName);
    end
    
    % Проверить, что переменная - числовая матрица
    data = evalin('base', variableName);
    if ~isnumeric(data) || ~ismatrix(data)
        error('Переменная ''%s'' должна быть числовой матрицей', variableName);
    end
    
    % Создать экземпляр приложения
    try
        app = TableGraphEditor;
    catch ME
        error('Ошибка создания приложения: %s', ME.message);
    end
    
    % Сохранить callback функцию в приложении
    if ~isempty(callbackFunction)
        if ~isa(callbackFunction, 'function_handle')
            error('callbackFunction должен быть function handle');
        end
        app.externalCallback = callbackFunction;
    end
    
    % Сохранить опции
    if isfield(options, 'autoClose')
        app.autoCloseOnSave = options.autoClose;
    else
        app.autoCloseOnSave = false;
    end
    
    % Автоматически загрузить переменную
    try
        % Установить выбранную переменную
        app.selectedVariable = variableName;
        
        % Загрузить данные
        loadVariableData(app, variableName);
        
        % Обновить dropdown (если нужно)
        updateVariableDropdown(app);
        
        % Обновить таблицу и график
        updateTable(app);
        updateGraph(app);
        
    catch ME
        warning('Ошибка при загрузке переменной: %s', ME.message);
        % Приложение все равно открыто, пользователь может загрузить вручную
    end
    
    % Приложение открыто и готово к использованию
    fprintf('TableGraphEditor открыт для редактирования переменной ''%s''\n', variableName);
    if ~isempty(callbackFunction)
        fprintf('Callback функция зарегистрирована\n');
    end
end
```

**Status:** Not Started

### Modification: TableGraphEditor.mlapp - Properties

```matlab
properties (SetAccess = public)
    % ... существующие свойства ...
    
    % === Callback API ===
    externalCallback = []  % Function handle callback функции от внешней программы
    wasSavedOnClose = false  % Флаг: были ли данные сохранены при закрытии
    autoCloseOnSave = false  % Флаг: закрывать ли приложение после сохранения
end
```

**Status:** Not Started

### Modification: btnSaveButtonPushed

```matlab
function btnSaveButtonPushed(app, src, event)
    % BTNSAVEBUTTONPUSHED Обработчик нажатия кнопки сохранения
    %   Сохраняет данные в Workspace и вызывает callback, если задан
    
    try
        % Получить данные из таблицы
        data = app.currentData;
        
        % Проверить данные
        if ~isnumeric(data)
            uialert(app.UIFigure, 'Данные должны быть числовыми', 'Ошибка');
            return;
        end
        
        % Подтверждение сохранения
        variableName = app.selectedVariable;
        if isempty(variableName)
            uialert(app.UIFigure, 'Переменная не выбрана', 'Ошибка');
            return;
        end
        
        % Диалог подтверждения
        answer = uiconfirm(app.UIFigure, ...
            sprintf('Сохранить данные в переменную ''%s''?', variableName), ...
            'Подтверждение сохранения', ...
            'Options', {'Да', 'Нет'}, ...
            'DefaultOption', 1);
        
        if strcmp(answer, 'Да')
            % Сохранить в Workspace
            assignin('base', variableName, data);
            
            % Установить флаг сохранения
            app.wasSavedOnClose = true;
            
            % Вызвать callback функцию, если задана
            if ~isempty(app.externalCallback)
                try
                    app.externalCallback(variableName, data, true);
                catch ME
                    warning('Ошибка в callback функции: %s', ME.message);
                    % Не прерываем сохранение из-за ошибки в callback
                end
            end
            
            % Показать сообщение об успехе
            uialert(app.UIFigure, 'Данные сохранены', 'Успех', 'Icon', 'success');
            
            % Закрыть приложение, если установлена опция autoClose
            if app.autoCloseOnSave
                close(app.UIFigure);
            end
        end
        
    catch ME
        uialert(app.UIFigure, ME.message, 'Ошибка сохранения', 'Icon', 'error');
    end
end
```

**Status:** Not Started

### Modification: UIFigureCloseRequest

```matlab
function UIFigureCloseRequest(app, src, event)
    % UIFIGURECLOSEREQUEST Обработчик закрытия окна приложения
    %   Вызывает callback функцию при закрытии, если данные не были сохранены
    
    try
        % Если callback задан и данные не были сохранены
        if ~isempty(app.externalCallback) && ~app.wasSavedOnClose
            % Получить текущие данные
            data = app.currentData;
            variableName = app.selectedVariable;
            
            if ~isempty(variableName) && ~isempty(data)
                try
                    % Вызвать callback с флагом wasSaved = false
                    app.externalCallback(variableName, data, false);
                catch ME
                    warning('Ошибка в callback функции при закрытии: %s', ME.message);
                    % Не прерываем закрытие из-за ошибки в callback
                end
            end
        end
        
        % Закрыть приложение
        delete(app);
        
    catch ME
        % В случае ошибки все равно закрыть приложение
        delete(app);
        warning('Ошибка при закрытии приложения: %s', ME.message);
    end
end
```

**Status:** Not Started

### Helper Function: loadVariableData

**File:** `src/helpers/loadVariableData.m` (если не существует)

```matlab
function loadVariableData(app, variableName)
    % LOADVARIABLEDATA Загрузить переменную из Workspace
    %   LOADVARIABLEDATA(APP, VARIABLENAME) загружает переменную
    %   из Workspace в приложение
    
    % Получить данные из Workspace
    data = evalin('base', variableName);
    
    % Сохранить в приложении
    app.originalData = data;
    app.currentData = data;
    app.selectedVariable = variableName;
end
```

**Status:** Not Started (возможно, уже существует)

---

## Testing & Verification

### Test Strategy
Тестировать вызов приложения, загрузку переменной, вызов callback при сохранении и закрытии.

### Unit Tests

**Test 1: Создание приложения через editTableData**
```matlab
function test_editTableData_creation()
    % Arrange
    testData = rand(5, 3);
    assignin('base', 'testVar', testData);
    
    % Act
    app = editTableData('testVar');
    
    % Assert
    assert(~isempty(app), 'Приложение должно быть создано');
    assert(strcmp(app.selectedVariable, 'testVar'), 'Переменная должна быть выбрана');
    
    % Cleanup
    close(app.UIFigure);
    evalin('base', 'clear testVar');
end
```

**Status:** Not Started

**Test 2: Callback при сохранении**
```matlab
function test_callback_on_save()
    % Arrange
    testData = rand(5, 3);
    assignin('base', 'testVar', testData);
    
    callbackCalled = false;
    callbackData = [];
    callbackVarName = '';
    callbackWasSaved = false;
    
    callback = @(var, data, saved) ...
        deal(callbackCalled = true, callbackVarName = var, ...
             callbackData = data, callbackWasSaved = saved);
    
    app = editTableData('testVar', callback);
    
    % Act - симуляция сохранения
    app.btnSaveButtonPushed(app, [], []);
    
    % Assert
    assert(callbackCalled, 'Callback должен быть вызван');
    assert(strcmp(callbackVarName, 'testVar'), 'Имя переменной должно совпадать');
    assert(callbackWasSaved == true, 'wasSaved должен быть true');
    
    % Cleanup
    close(app.UIFigure);
    evalin('base', 'clear testVar');
end
```

**Status:** Not Started

### Integration Tests

**Test Case 1: Полный сценарий использования**
- **Description:** Внешняя программа вызывает TableGraphEditor, редактирует данные, сохраняет, получает callback
- **Steps:**
  1. Создать данные в Workspace
  2. Зарегистрировать callback функцию
  3. Вызвать `editTableData('myData', callback)`
  4. Отредактировать данные в приложении
  5. Сохранить данные
  6. Проверить, что callback был вызван с правильными параметрами
- **Expected Output:** Callback вызван с `wasSaved = true`, данные обновлены в Workspace
- **Status:** Not Started

---

## Documentation Updates

### Files to Update
- [ ] `docs/API_REFERENCE.md` - документация функции `editTableData` (новый файл)
- [ ] `docs/README.md` - добавить раздел об интеграции с внешними программами
- [ ] `examples/external_program_example.m` - пример использования (новый файл)
- [ ] Комментарии в коде - описать все функции

### API Documentation Structure

**docs/API_REFERENCE.md:**
```markdown
# TableGraphEditor API Reference

## editTableData

Открыть TableGraphEditor для редактирования переменной из Workspace.

### Syntax
```matlab
app = editTableData(variableName)
app = editTableData(variableName, callbackFunction)
app = editTableData(variableName, callbackFunction, options)
```

### Description
[Описание функции]

### Examples
[Примеры использования]

### Callback Function Format
[Описание формата callback функции]
```

---

## Progress Log

### 2026-01-09
- Task created
- Initial design completed

### 2026-01-10
- Task переработана под новый сценарий использования
- Определен формат callback функции
- Определен алгоритм работы wrapper функции

---

## Completion Checklist

Before marking this task as complete:

- [ ] Функция `editTableData` реализована
- [ ] Свойства `externalCallback`, `wasSavedOnClose`, `autoCloseOnSave` добавлены
- [ ] Модифицирован `btnSaveButtonPushed` для вызова callback
- [ ] Модифицирован `UIFigureCloseRequest` для вызова callback
- [ ] Автоматическая загрузка переменной работает
- [ ] Обработка ошибок реализована
- [ ] Тесты написаны и проходят
- [ ] Документация создана
- [ ] Примеры использования предоставлены

---

## Sign-off

**Created by:** AI Assistant  
**Date:** 2026-01-09  
**Last Updated:** 2026-01-10  
**Status:** Planning - готово к реализации

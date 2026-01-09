# Структура App Designer: TableGraphEditor.mlapp

**Date:** 2026-01-08  
**Purpose:** Шаблон структуры для создания файла App Designer

---

## UI Components (Design View)

### Обязательные компоненты:

1. **uitable** - `app.tblData`
   - Purpose: Отображение и редактирование числовых данных
   - Location: Левая часть окна
   - Properties:
     - ColumnEditable: true (для всех столбцов, кроме меток)
     - ColumnFormat: {'numeric'}

2. **uiaxes** - `app.axPlot`
   - Purpose: Область для построения графиков
   - Location: Правая часть окна
   - Properties:
     - NextPlot: 'replace'
     - Box: 'on'
     - Grid: 'on'

3. **uidropdown** - `app.ddVariable`
   - Purpose: Выбор переменной из workspace
   - Location: Верхняя панель
   - Items: Заполняется динамически

4. **uidropdown** - `app.ddPlotType`
   - Purpose: Выбор типа графика (по столбцам/строкам)
   - Location: Верхняя панель
   - Items: {'By Columns', 'By Rows'}

5. **uibutton** - `app.btnSave`
   - Purpose: Сохранение данных в workspace
   - Location: Нижняя панель
   - Text: 'Save to Workspace'

6. **uibuttongroup** - `app.bgEditMode`
   - Purpose: Группа для выбора режима редактирования
   - Location: Верхняя панель

7. **uiradiobutton** - `app.rbModeXY`
   - Purpose: Режим редактирования XY (для MVP)
   - Location: Внутри app.bgEditMode
   - Text: 'XY'
   - Value: true (по умолчанию)

### Опциональные компоненты (для будущих версий):

- `app.btnUndo` - кнопка отмены
- `app.btnRedo` - кнопка повтора
- `app.btnAddPoint` - добавление точки
- `app.btnDeletePoint` - удаление точки
- `app.rbModeX` - режим редактирования только X
- `app.rbModeY` - режим редактирования только Y

---

## Properties Section

```matlab
properties (Access = private)
    % === Данные ===
    originalData        % Исходные данные (полная матрица)
    currentData         % Текущие редактируемые данные
    selectedVariable    % Выбранная переменная из workspace (string)
    editMode = 'XY'     % Режим редактирования: 'XY' (для MVP)
    currentPlotType = 'columns' % 'columns' или 'rows'
    
    % === Выбор части данных ===
    selectedColumns = [] % Индексы выбранных столбцов
    selectedRows = []    % Индексы выбранных строк
    
    % === Метки ===
    rowLabels = {}      % Метки строк (первый столбец в режиме "по строкам")
    columnLabels = {}   % Метки столбцов (первая строка в режиме "по столбцам")
    
    % === Перетаскивание ===
    selectedPoint = []  % Индекс выбранной точки [curveIndex, pointIndex]
    isDragging = false  % Флаг активного перетаскивания
    dragStartPosition = [] % Начальная позиция перетаскивания [x, y]
    
    % === Состояние приложения ===
    isUpdating = false  % Флаг обновления (предотвращает циклические обновления)
end
```

---

## Methods Section

### Callback Functions

```matlab
methods (Access = private)
    
    % === Инициализация ===
    function startupFcn(app, varargin)
        % STARTUPFCN Выполняется при запуске приложения
        %   Инициализирует dropdown переменных из workspace
    end
    
    % === Загрузка данных ===
    function ddVariableValueChanged(app, event)
        % DDVARIABLEVALUECHANGED Callback выбора переменной
        %   Загружает выбранную переменную в таблицу
    end
    
    % === Построение графиков ===
    function ddPlotTypeValueChanged(app, event)
        % DDPLOTTYPEVALUECHANGED Callback выбора типа графика
        %   Перестраивает график в выбранном режиме
    end
    
    % === Редактирование таблицы ===
    function tblDataCellEdit(app, event)
        % TBLDATACELLEDIT Callback редактирования ячейки таблицы
        %   Обновляет данные и график при изменении таблицы
    end
    
    % === Выделение в таблице ===
    function tblDataCellSelection(app, event)
        % TBLDATACELLSELECTION Callback выделения ячеек
        %   Определяет выделенные столбцы/строки и обновляет график
    end
    
    % === Перетаскивание на графике ===
    function axPlotButtonDown(app, event)
        % AXPLOTBUTTONDOWN Callback нажатия на график
        %   Начинает перетаскивание точки
    end
    
    % === Сохранение ===
    function btnSaveButtonPushed(app, event)
        % BTNSAVEBUTTONPUSHED Callback кнопки сохранения
        %   Сохраняет данные в workspace
    end
end
```

### Helper Methods

```matlab
methods (Access = private)
    
    % === Загрузка данных ===
    function loadVariableFromWorkspace(app, varName)
        % LOADVARIABLEFROMWORKSPACE Загружает переменную из workspace
    end
    
    function updateVariableDropdown(app)
        % UPDATEVARIABLEDROPDOWN Обновляет список переменных в dropdown
    end
    
    % === Построение графиков ===
    function plotByColumns(app, data)
        % PLOTBYCOLUMNS Строит график по столбцам
    end
    
    function plotByRows(app, data)
        % PLOTBYROWS Строит график по строкам
    end
    
    function updateGraph(app)
        % UPDATEGRAPH Обновляет график на основе текущих данных
    end
    
    % === Обработка выделения ===
    function updateSelection(app, selection)
        % UPDATESELECTION Обновляет выделенные столбцы/строки
    end
    
    % === Перетаскивание ===
    function startDrag(app, pointIndex)
        % STARTDRAG Начинает перетаскивание точки
    end
    
    function dragPoint(app, event)
        % DRAGPOINT Обрабатывает движение мыши при перетаскивании
    end
    
    function stopDrag(app)
        % STOPDRAG Завершает перетаскивание и обновляет данные
    end
    
    % === Валидация ===
    function isValid = validateData(app, data)
        % VALIDATEDATA Проверяет корректность данных
    end
end
```

---

## Layout Structure

### Grid Layout (рекомендуется):

```
┌─────────────────────────────────────────────────────┐
│  Grid Layout (Root)                                 │
├─────────────────────────────────────────────────────┤
│  Row 1: Toolbar (Height: 40px)                      │
│    [ddVariable] [ddPlotType] [bgEditMode]           │
├─────────────────────────────────────────────────────┤
│  Row 2: Main Content (Height: Flexible)              │
│    ┌──────────────┬──────────────────────────────┐ │
│    │ Grid (Left)  │ Grid (Right)                 │ │
│    │              │                               │ │
│    │ tblData      │ axPlot                        │ │
│    │              │                               │ │
│    └──────────────┴──────────────────────────────┘ │
├─────────────────────────────────────────────────────┤
│  Row 3: Buttons (Height: 40px)                      │
│    [btnSave]                                        │
└─────────────────────────────────────────────────────┘
```

---

## Инструкции по созданию в App Designer

1. Откройте MATLAB
2. Запустите App Designer: `appdesigner`
3. Создайте новый файл: File → New → App
4. Сохраните как `TableGraphEditor.mlapp` в папку `src/`
5. Добавьте UI компоненты согласно списку выше
6. Настройте имена компонентов согласно соглашениям
7. Добавьте Properties в секцию Properties
8. Добавьте Methods согласно шаблону
9. Настройте Layout используя Grid Layout Manager

---

## Соглашения об именовании

- UI компоненты: префикс + описательное имя (например, `tblData`, `axPlot`)
- Properties: camelCase (например, `currentData`, `selectedPoint`)
- Methods: camelCase (например, `updateGraph`, `loadVariableFromWorkspace`)
- Callbacks: автоматически генерируются App Designer

---

## Примечания

- Файл `.mlapp` - это бинарный формат MATLAB, его нельзя создать программно
- Необходимо использовать MATLAB App Designer для создания файла
- После создания базовой структуры можно редактировать код в Code View


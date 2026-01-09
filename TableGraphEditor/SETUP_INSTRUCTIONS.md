# Инструкции по настройке проекта

**Date:** 2026-01-08  
**Purpose:** Пошаговые инструкции по созданию базовой структуры App Designer

---

## Предварительные требования

- MATLAB R2021a или выше
- App Designer (входит в MATLAB)
- Доступ к workspace MATLAB

---

## Шаг 1: Проверка структуры папок

Убедитесь, что структура папок создана:

```
TableGraphEditor/
├── src/
│   ├── helpers/
│   └── TableGraphEditor.mlapp (будет создан)
├── test/
├── examples/
├── resources/
└── docs/
```

---

## Шаг 2: Создание файла App Designer

### 2.1 Запуск App Designer

```matlab
% В командном окне MATLAB
appdesigner
```

Или через меню: **Apps** → **Design App**

### 2.2 Создание нового приложения

1. В App Designer: **File** → **New** → **App**
2. Выберите шаблон: **Blank App**
3. Сохраните файл: **File** → **Save As**
   - Имя файла: `TableGraphEditor.mlapp`
   - Папка: `TableGraphEditor/src/`

---

## Шаг 3: Добавление UI компонентов

### 3.1 Настройка основного окна

1. Выберите `UIFigure` в Component Browser
2. В Property Inspector установите:
   - **Name**: `UIFigure`
   - **Title**: `Table-Graph Editor`
   - **WindowState**: `normal`

### 3.2 Добавление компонентов

Добавьте компоненты из палитры Component Library:

#### Таблица данных
1. Перетащите **Table (uitable)** на форму
2. В Property Inspector:
   - **Name**: `tblData`
   - Разместите в левой части окна

#### График
1. Перетащите **Axes (uiaxes)** на форму
2. В Property Inspector:
   - **Name**: `axPlot`
   - Разместите в правой части окна

#### Dropdown для переменных
1. Перетащите **Drop Down (uidropdown)** на форму
2. В Property Inspector:
   - **Name**: `ddVariable`
   - **Items**: `{'Select variable...'}` (временно)
   - Разместите в верхней панели

#### Dropdown для типа графика
1. Перетащите **Drop Down (uidropdown)** на форму
2. В Property Inspector:
   - **Name**: `ddPlotType`
   - **Items**: `{'By Columns', 'By Rows'}`
   - **Value**: `'By Columns'`
   - Разместите рядом с `ddVariable`

#### Кнопка сохранения
1. Перетащите **Button (uibutton)** на форму
2. В Property Inspector:
   - **Name**: `btnSave`
   - **Text**: `Save to Workspace`
   - Разместите в нижней панели

#### Button Group для режима редактирования
1. Перетащите **Button Group (uibuttongroup)** на форму
2. В Property Inspector:
   - **Name**: `bgEditMode`
   - **Title**: `Edit Mode`
   - Разместите в верхней панели

3. Добавьте Radio Button внутрь Button Group:
   - **Name**: `rbModeXY`
   - **Text**: `XY`
   - **Value**: `true`

---

## Шаг 4: Настройка Layout

### 4.1 Использование Grid Layout (рекомендуется)

1. Выберите `UIFigure`
2. В Property Inspector найдите **Layout**
3. Выберите **Grid Layout Manager**

### 4.2 Размещение компонентов

Настройте Grid Layout следующим образом:

```
Row 1 (Height: 40px):
  - ddVariable (Column 1)
  - ddPlotType (Column 2)
  - bgEditMode (Column 3)

Row 2 (Height: Flexible):
  - tblData (Column 1, Span: 1)
  - axPlot (Column 2, Span: 1)

Row 3 (Height: 40px):
  - btnSave (Column 1, Centered)
```

---

## Шаг 5: Добавление Properties

1. Переключитесь в **Code View**
2. Найдите секцию `properties (Access = private)`
3. Добавьте properties согласно `APP_STRUCTURE_TEMPLATE.md`:

```matlab
properties (Access = private)
    % Данные
    originalData        % Исходные данные (полная матрица)
    currentData         % Текущие редактируемые данные
    selectedVariable    % Выбранная переменная из workspace
    editMode = 'XY'     % Режим редактирования: 'XY' (для MVP)
    currentPlotType = 'columns' % 'columns' или 'rows'
    
    % Для выбора части данных
    selectedColumns = [] % Индексы выбранных столбцов
    selectedRows = []    % Индексы выбранных строк
    
    % Метки
    rowLabels = {}      % Метки строк
    columnLabels = {}   % Метки столбцов
    
    % Для перетаскивания
    selectedPoint = []  % Индекс выбранной точки
    isDragging = false  % Флаг перетаскивания
    dragStartPosition = [] % Начальная позиция
    
    % Состояние приложения
    isUpdating = false  % Флаг обновления
end
```

---

## Шаг 6: Создание базовых Callback функций

### 6.1 StartupFcn

1. В Code View найдите функцию `startupFcn`
2. Добавьте базовую инициализацию:

```matlab
function startupFcn(app, varargin)
    % STARTUPFCN Выполняется при запуске приложения
    
    % Обновить список переменных в dropdown
    updateVariableDropdown(app);
end
```

### 6.2 Заглушки для других callbacks

Создайте заглушки для основных callback функций (они будут реализованы в следующих задачах):

```matlab
function ddVariableValueChanged(app, event)
    % DDVARIABLEVALUECHANGED Callback выбора переменной
    % TODO: Реализовать в task_20260106_data_loading.md
end

function ddPlotTypeValueChanged(app, event)
    % DDPLOTTYPEVALUECHANGED Callback выбора типа графика
    % TODO: Реализовать в task_20260106_graph_plotting.md
end

function tblDataCellEdit(app, event)
    % TBLDATACELLEDIT Callback редактирования ячейки таблицы
    % TODO: Реализовать в task_20260106_data_sync.md
end

function btnSaveButtonPushed(app, event)
    % BTNSAVEBUTTONPUSHED Callback кнопки сохранения
    % TODO: Реализовать в task_20260106_saving.md
end
```

---

## Шаг 7: Проверка

### 7.1 Сохранение

1. Сохраните файл: **File** → **Save**
2. Убедитесь, что файл сохранен в `src/TableGraphEditor.mlapp`

### 7.2 Тестовый запуск

```matlab
% В командном окне MATLAB
cd('TableGraphEditor/src')
app = TableGraphEditor;
```

Проверьте:
- [ ] Приложение запускается без ошибок
- [ ] Все UI компоненты видны
- [ ] Layout корректно отображается
- [ ] Dropdown'ы и кнопки доступны

---

## Следующие шаги

После создания базовой структуры переходите к следующим задачам:

1. **task_20260106_data_loading.md** - загрузка данных из workspace
2. **task_20260106_graph_plotting.md** - построение графиков
3. **task_20260106_selection_handling.md** - обработка выделения
4. **task_20260106_drag_and_drop.md** - перетаскивание точек
5. **task_20260106_data_sync.md** - синхронизация данных
6. **task_20260106_saving.md** - сохранение данных

---

## Troubleshooting

### Проблема: App Designer не запускается
**Решение:** Убедитесь, что используется MATLAB R2021a или выше

### Проблема: Компоненты не отображаются
**Решение:** Проверьте, что компоненты добавлены в правильный контейнер (UIFigure)

### Проблема: Layout не работает
**Решение:** Убедитесь, что используется Grid Layout Manager, а не абсолютное позиционирование

---

## Дополнительные ресурсы

- MATLAB App Designer Documentation: https://www.mathworks.com/help/matlab/app-designer.html
- `.cursorrules` - правила проекта
- `MATLAB_STYLE_GUIDE.md` - стиль кодирования
- `APP_STRUCTURE_TEMPLATE.md` - детальная структура компонентов


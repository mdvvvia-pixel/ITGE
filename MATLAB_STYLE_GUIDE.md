# Руководство по стилю MATLAB для проекта TableGraphEditor

## 1. Структура файлов
TableGraphEditor/
├── src/
│ ├── TableGraphEditor.mlapp # Основной файл App Designer
│ ├── helpers/ # Вспомогательные функции
│ │ ├── findClosestPoint.m
│ │ ├── calculateDependentColumn.m
│ │ └── addHistoryEntry.m
│ └── callbacks/ # Дополнительные callback функции
├── test/ # Тесты
├── examples/ # Примеры данных
└── docs/ # Документация

## 2. Соглашения об именовании

### Переменные
```matlab
% Хорошо
currentData
selectedPointIndex
plotOptions

% Плохо
current_data
SelectedPointIndex
PLOTOPTIONS
```

### Функции
```matlab
% Хорошо
updateGraph()
findClosestPoint()
calculateStatistics()

% Плохо
UpdateGraph()
Find_Closest_Point()
calcStats()
```

### UI компоненты в App Designer
```matlab
% Префиксы + описательное имя
app.tblData          % Таблица
app.axPlot           % Оси графика
app.btnSave          % Кнопка сохранения
app.ddVariables      % Dropdown выбора переменных
app.rbModeXY         % Radio button режима XY
```

## 3. Структура кода

### Функции должны иметь заголовок
```matlab
function result = calculateAverage(data)
    % CALCULATEAVERAGE Вычисляет среднее значение
    %   RESULT = CALCULATEAVERAGE(DATA) возвращает среднее
    %   значение массива DATA.
    %
    %   Пример:
    %       avg = calculateAverage([1 2 3 4 5])
    
    % Проверка входных данных
    if isempty(data)
        error('Входной массив не может быть пустым');
    end
    
    % Основная логика
    result = mean(data(:));
end
```

### Callback функции в App Designer
```matlab
methods (Access = private)
    
    function ButtonPushed(app, event)
        % BUTTONPUSHED Обработчик нажатия кнопки
        %   Вызывается при нажатии кнопки сохранения
        
        try
            % Получить данные из таблицы
            data = app.tblData.Data;
            
            % Проверить данные
            if ~isnumeric(data)
                uialert(app.UIFigure, 'Данные должны быть числовыми', 'Ошибка');
                return;
            end
            
            % Сохранить в workspace
            assignin('base', app.selectedVariable, data);
            
            % Показать подтверждение
            uialert(app.UIFigure, 'Данные сохранены', 'Успех');
            
        catch ME
            % Обработка ошибок
            uialert(app.UIFigure, ME.message, 'Ошибка сохранения');
        end
    end
end
```

## 4. Обработка ошибок

### Используйте try-catch в callback
```matlab
try
    % Код, который может вызвать ошибку
    result = riskyOperation(data);
catch ME
    % Логирование ошибки
    app.lastError = ME;
    
    % Показать пользователю
    uialert(app.UIFigure, ...
        sprintf('Ошибка: %s', ME.message), ...
        'Ошибка операции', ...
        'Icon', 'error');
    
    % Вернуть приложение в стабильное состояние
    resetAppState(app);
end
```

## 5. Оптимизация производительности

### Для частых обновлений графиков
```matlab
% Вместо этого
for i = 1:100
    updatePlot(app);
    drawnow;
end

% Используйте это
for i = 1:100
    updatePlot(app);
    drawnow limitrate;  % Ограничивает частоту обновлений
end
```

### Работа с большими данными
```matlab
% Копируйте только при необходимости
function processLargeData(app)
    % Используйте ссылки, если возможно
    dataRef = app.largeData;  % Не копирует данные
    
    % Изменяйте данные на месте
    dataRef(:, 1) = dataRef(:, 1) * 2;
    
    % Обновляйте только измененные части
    app.tblData.Data(:, 1) = dataRef(:, 1);
end
```

## 6. Комментарии и документация

### Комментируйте "почему", а не "что"
```matlab
% Плохо
x = x + 1;  % Увеличить x на 1

% Хорошо
% Корректировка смещения из-за индексации MATLAB с 1
x = x + 1;
```

### Используйте TODO, FIXME, NOTE
```matlab
% TODO: Добавить поддержку комплексных чисел
% FIXME: Исправить обработку граничных значений
% NOTE: Эта функция оптимизирована для speed
```

## 7. Тестирование

### Создавайте тестовые скрипты
```matlab
%% Тест функции findClosestPoint
% Инициализация
testData = rand(10, 2);
targetPoint = [0.5, 0.5];

% Выполнение
index = findClosestPoint(testData, targetPoint);

% Проверка
expectedIndex = 5;  % Предполагаемый результат
assert(index == expectedIndex, 'Тест не пройден');

disp('Тест findClosestPoint пройден успешно');
```

## 8. Версионирование

### Используйте семантическое версионирование

- **MAJOR:** обратно несовместимые изменения
- **MINOR:** новая функциональность с обратной совместимостью
- **PATCH:** исправления ошибок

Храните историю изменений:
```matlab
% В начале файла .mlapp
% История изменений:
% v1.0.0 (2024-01-01): Первоначальный выпуск
% v1.1.0 (2024-01-15): Добавлены режимы редактирования X/Y
% v1.1.1 (2024-01-20): Исправлена ошибка с зависимыми столбцами
```
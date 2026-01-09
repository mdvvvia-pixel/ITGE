%% CHECKAPPPROPERTIES Проверяет, какие свойства объявлены в классе
%   Показывает, какие свойства отсутствуют и должны быть добавлены
%
%   Использование:
%       checkAppProperties(app)

function checkAppProperties(app)
    % CHECKAPPPROPERTIES Проверяет свойства приложения
    
    fprintf('=== Проверка Properties в TableGraphEditor ===\n\n');
    
    requiredProperties = {
        'isUpdating';
        'currentData';
        'originalData';
        'currentPlotType';
        'editMode';
        'selectedVariable';
        'selectedColumns';
        'selectedRows';
        'rowLabels';
        'columnLabels';
        'selectedPoint';
        'isDragging';
        'dragStartPosition'
    };
    
    fprintf('Проверка свойств:\n');
    fprintf('-----------------\n');
    
    missingProperties = {};
    existingProperties = {};
    
    for i = 1:length(requiredProperties)
        propName = requiredProperties{i};
        if isprop(app, propName)
            fprintf('✓ %s - ОК\n', propName);
            existingProperties{end+1} = propName;
        else
            fprintf('✗ %s - ОТСУТСТВУЕТ\n', propName);
            missingProperties{end+1} = propName;
        end
    end
    
    fprintf('\n=== Итоги ===\n');
    fprintf('Найдено: %d из %d свойств\n', length(existingProperties), length(requiredProperties));
    fprintf('Отсутствует: %d свойств\n\n', length(missingProperties));
    
    if ~isempty(missingProperties)
        fprintf('⚠ ВНИМАНИЕ: Следующие свойства нужно добавить в .mlapp файл:\n\n');
        fprintf('Скопируйте этот код в секцию properties (Access = private) в App Designer:\n\n');
        fprintf('properties (Access = private)\n');
        fprintf('    %% === Данные ===\n');
        if ismember('originalData', missingProperties)
            fprintf('    originalData        %% Исходные данные (полная матрица)\n');
        end
        if ismember('currentData', missingProperties)
            fprintf('    currentData         %% Текущие редактируемые данные\n');
        end
        if ismember('selectedVariable', missingProperties)
            fprintf('    selectedVariable    %% Выбранная переменная из workspace\n');
        end
        if ismember('editMode', missingProperties)
            fprintf('    editMode = ''XY''     %% Режим редактирования: ''XY''\n');
        end
        if ismember('currentPlotType', missingProperties)
            fprintf('    currentPlotType = ''columns'' %% ''columns'' или ''rows''\n');
        end
        fprintf('    \n');
        fprintf('    %% === Выбор части данных ===\n');
        if ismember('selectedColumns', missingProperties)
            fprintf('    selectedColumns = [] %% Индексы выбранных столбцов\n');
        end
        if ismember('selectedRows', missingProperties)
            fprintf('    selectedRows = []    %% Индексы выбранных строк\n');
        end
        fprintf('    \n');
        fprintf('    %% === Метки ===\n');
        if ismember('rowLabels', missingProperties)
            fprintf('    rowLabels = {}      %% Метки строк\n');
        end
        if ismember('columnLabels', missingProperties)
            fprintf('    columnLabels = {}   %% Метки столбцов\n');
        end
        fprintf('    \n');
        fprintf('    %% === Перетаскивание ===\n');
        if ismember('selectedPoint', missingProperties)
            fprintf('    selectedPoint = []  %% Индекс выбранной точки [curveIndex, pointIndex]\n');
        end
        if ismember('isDragging', missingProperties)
            fprintf('    isDragging = false  %% Флаг активного перетаскивания\n');
        end
        if ismember('dragStartPosition', missingProperties)
            fprintf('    dragStartPosition = [] %% Начальная позиция перетаскивания [x, y]\n');
        end
        fprintf('    \n');
        fprintf('    %% === Состояние приложения ===\n');
        if ismember('isUpdating', missingProperties)
            fprintf('    isUpdating = false  %% Флаг обновления (предотвращает циклические обновления)\n');
        end
        fprintf('end\n\n');
        
        fprintf('Или используйте полный код из файла PROPERTIES_TO_ADD.m\n');
    else
        fprintf('✓ Все свойства объявлены!\n');
    end
end


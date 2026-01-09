%% INITIALIZEAPPPROPERTIES Инициализирует свойства приложения
%   Убеждается, что все необходимые свойства инициализированы
%
%   Использование:
%       initializeAppProperties(app)

function initializeAppProperties(app)
    % INITIALIZEAPPPROPERTIES Инициализирует свойства приложения
    %   Безопасно проверяет и инициализирует свойства, если они существуют
    %   
    %   ВАЖНО: Эта функция только проверяет и инициализирует существующие свойства.
    %   Если свойства не объявлены в классе, они должны быть добавлены вручную
    %   в секцию properties (Access = private) в App Designer.
    
    % Использовать isprop для проверки существования свойства в классе
    % и безопасную установку только если свойство существует и пустое
    
    propertiesToInit = {
        'isUpdating', false;
        'currentData', [];
        'originalData', [];
        'currentPlotType', 'columns';
        'editMode', 'XY';
        'selectedVariable', '';
        'selectedColumns', [];
        'selectedRows', [];
        'rowLabels', {};
        'columnLabels', {};
        'selectedPoint', [];
        'isDragging', false;
        'dragStartPosition', []
    };
    
    missingProps = {};
    
    for i = 1:size(propertiesToInit, 1)
        propName = propertiesToInit{i, 1};
        defaultValue = propertiesToInit{i, 2};
        
        % Проверить, существует ли свойство в классе
        if isprop(app, propName)
            try
                % Получить текущее значение
                currentValue = app.(propName);
                
                % Установить значение по умолчанию, если свойство пустое
                if isempty(currentValue)
                    app.(propName) = defaultValue;
                end
            catch ME
                % Свойство существует, но не может быть установлено
                % Это может быть read-only свойство
                missingProps{end+1} = propName;
            end
        else
            % Свойство не существует - нужно добавить в класс
            missingProps{end+1} = propName;
        end
    end
    
    % Показать предупреждение только если есть отсутствующие свойства
    if ~isempty(missingProps)
        fprintf('\n⚠ ВНИМАНИЕ: Следующие свойства не объявлены в классе:\n');
        for i = 1:length(missingProps)
            fprintf('   - %s\n', missingProps{i});
        end
        fprintf('\nДобавьте их в секцию properties (Access = private) в App Designer.\n');
        fprintf('Используйте код из файла PROPERTIES_TO_ADD.m\n\n');
    else
        % Все свойства найдены - можно тихо инициализировать
        % (не выводим сообщения, чтобы не засорять вывод)
    end
end


%% SAFE_ADD_CODE Безопасно добавляет Properties и методы в .mlapp
%   Использует более безопасный подход с проверками

function safe_add_code()
    % SAFE_ADD_CODE Безопасно добавляет код
    
    fprintf('=== Безопасное добавление Properties и методов ===\n\n');
    
    % Прочитать текущий код
    try
        currentCode = read_mlapp_code();
        fprintf('✓ Код прочитан (%d символов)\n', length(currentCode));
    catch ME
        error('Не удалось прочитать код: %s', ME.message);
    end
    
    % Проверить, есть ли уже Properties
    if contains(currentCode, 'originalData')
        fprintf('⚠ Properties уже добавлены. Пропускаем.\n');
    else
        % Добавить Properties
        currentCode = insertProperties(currentCode);
        fprintf('✓ Properties добавлены\n');
    end
    
    % Проверить, есть ли уже методы
    if contains(currentCode, 'function startupFcn')
        fprintf('⚠ Методы уже добавлены. Пропускаем.\n');
    else
        % Добавить методы
        currentCode = insertMethods(currentCode);
        fprintf('✓ Методы добавлены\n');
    end
    
    % Записать обратно
    try
        write_mlapp_code(currentCode);
        fprintf('\n✅ Файл успешно обновлен!\n');
        fprintf('Откройте в App Designer для проверки\n');
    catch ME
        fprintf('\n✗ Ошибка: %s\n', ME.message);
        fprintf('Используйте файлы PROPERTIES_TO_ADD.m и METHODS_TO_ADD.m для ручного добавления\n');
        rethrow(ME);
    end
end

function newCode = insertProperties(currentCode)
    % INSERTPROPERTIES Вставляет Properties после UI компонентов
    
    % Найти конец секции properties (Access = public)
    pattern = '(properties \(Access = public\)[^}]*end\s+)';
    match = regexp(currentCode, pattern, 'match', 'once');
    
    if isempty(match)
        error('Не найдена секция properties для UI компонентов');
    end
    
    % Properties для добавления
    propsCode = [newline, '    % Application data and state', newline];
    propsCode = [propsCode, '    properties (Access = private)', newline];
    propsCode = [propsCode, '        % === Данные ===', newline];
    propsCode = [propsCode, '        originalData        % Исходные данные (полная матрица)', newline];
    propsCode = [propsCode, '        currentData         % Текущие редактируемые данные', newline];
    propsCode = [propsCode, '        selectedVariable    % Выбранная переменная из workspace', newline];
    propsCode = [propsCode, '        editMode = ''XY''     % Режим редактирования: ''XY''', newline];
    propsCode = [propsCode, '        currentPlotType = ''columns'' % ''columns'' или ''rows''', newline];
    propsCode = [propsCode, '        ', newline];
    propsCode = [propsCode, '        % === Выбор части данных ===', newline];
    propsCode = [propsCode, '        selectedColumns = [] % Индексы выбранных столбцов', newline];
    propsCode = [propsCode, '        selectedRows = []    % Индексы выбранных строк', newline];
    propsCode = [propsCode, '        ', newline];
    propsCode = [propsCode, '        % === Метки ===', newline];
    propsCode = [propsCode, '        rowLabels = {}      % Метки строк', newline];
    propsCode = [propsCode, '        columnLabels = {}   % Метки столбцов', newline];
    propsCode = [propsCode, '        ', newline];
    propsCode = [propsCode, '        % === Перетаскивание ===', newline];
    propsCode = [propsCode, '        selectedPoint = []  % Индекс выбранной точки [curveIndex, pointIndex]', newline];
    propsCode = [propsCode, '        isDragging = false  % Флаг активного перетаскивания', newline];
    propsCode = [propsCode, '        dragStartPosition = [] % Начальная позиция перетаскивания [x, y]', newline];
    propsCode = [propsCode, '        ', newline];
    propsCode = [propsCode, '        % === Состояние приложения ===', newline];
    propsCode = [propsCode, '        isUpdating = false  % Флаг обновления (предотвращает циклические обновления)', newline];
    propsCode = [propsCode, '    end', newline, newline];
    
    % Вставить после match
    newCode = strrep(currentCode, match, [match, propsCode]);
end

function newCode = insertMethods(currentCode)
    % INSERTMETHODS Вставляет методы после createComponents
    
    % Найти конец createComponents
    pattern = '(function createComponents\(app\)[^}]*?end\s+)';
    match = regexp(currentCode, pattern, 'match', 'once');
    
    if isempty(match)
        error('Не найдена функция createComponents');
    end
    
    % Методы для добавления (упрощенная версия)
    methodsCode = [newline, '        % STARTUPFCN Выполняется при запуске приложения', newline];
    methodsCode = [methodsCode, '        function startupFcn(app, varargin)', newline];
    methodsCode = [methodsCode, '            updateVariableDropdown(app);', newline];
    methodsCode = [methodsCode, '        end', newline, newline];
    
    methodsCode = [methodsCode, '        function updateVariableDropdown(app)', newline];
    methodsCode = [methodsCode, '            try', newline];
    methodsCode = [methodsCode, '                vars = evalin(''base'', ''who'');', newline];
    methodsCode = [methodsCode, '                numericVars = {};', newline];
    methodsCode = [methodsCode, '                for i = 1:length(vars)', newline];
    methodsCode = [methodsCode, '                    try', newline];
    methodsCode = [methodsCode, '                        varData = evalin(''base'', vars{i});', newline];
    methodsCode = [methodsCode, '                        if isnumeric(varData) && ~isempty(varData)', newline];
    methodsCode = [methodsCode, '                            numericVars{end+1} = vars{i};', newline];
    methodsCode = [methodsCode, '                        end', newline];
    methodsCode = [methodsCode, '                    catch', newline];
    methodsCode = [methodsCode, '                    end', newline];
    methodsCode = [methodsCode, '                end', newline];
    methodsCode = [methodsCode, '                app.ddVariable.Items = [''Select variable...'', numericVars];', newline];
    methodsCode = [methodsCode, '            catch ME', newline];
    methodsCode = [methodsCode, '                fprintf(''Ошибка: %s\n'', ME.message);', newline];
    methodsCode = [methodsCode, '            end', newline];
    methodsCode = [methodsCode, '        end', newline, newline];
    
    methodsCode = [methodsCode, '        function updateGraph(app)', newline];
    methodsCode = [methodsCode, '            if app.isUpdating || isempty(app.currentData)', newline];
    methodsCode = [methodsCode, '                return;', newline];
    methodsCode = [methodsCode, '            end', newline];
    methodsCode = [methodsCode, '            app.isUpdating = true;', newline];
    methodsCode = [methodsCode, '            try', newline];
    methodsCode = [methodsCode, '                if strcmp(app.currentPlotType, ''columns'')', newline];
    methodsCode = [methodsCode, '                    plotByColumns(app, app.currentData);', newline];
    methodsCode = [methodsCode, '                else', newline];
    methodsCode = [methodsCode, '                    plotByRows(app, app.currentData);', newline];
    methodsCode = [methodsCode, '                end', newline];
    methodsCode = [methodsCode, '            catch ME', newline];
    methodsCode = [methodsCode, '                uialert(app.UIFigure, ME.message, ''Ошибка'');', newline];
    methodsCode = [methodsCode, '            end', newline];
    methodsCode = [methodsCode, '            app.isUpdating = false;', newline];
    methodsCode = [methodsCode, '        end', newline];
    
    % Вставить после match
    newCode = strrep(currentCode, match, [match, methodsCode]);
    
    % Добавить вызов startupFcn в конструктор
    if ~contains(newCode, 'runStartupFcn')
        pattern = '(registerApp\(app, app\.UIFigure\)\s+)';
        replacement = ['registerApp(app, app.UIFigure)', newline, newline, '            runStartupFcn(app, @startupFcn)', newline];
        newCode = regexprep(newCode, pattern, replacement, 'once');
    end
end


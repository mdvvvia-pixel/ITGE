%% ADD_PROPERTIES_AND_METHODS Добавляет Properties и методы в существующий .mlapp
%   Сохраняет все существующие UI компоненты и добавляет Properties и методы
%
%   Использование:
%       add_properties_and_methods

function add_properties_and_methods()
    % ADD_PROPERTIES_AND_METHODS Добавляет Properties и методы
    
    fprintf('=== Добавление Properties и методов в TableGraphEditor.mlapp ===\n\n');
    
    % Прочитать текущий код
    try
        currentCode = read_mlapp_code();
        fprintf('✓ Текущий код прочитан\n');
    catch ME
        error('Не удалось прочитать код: %s', ME.message);
    end
    
    % Проверить, есть ли уже наши Properties
    if contains(currentCode, 'originalData')
        fprintf('⚠ Properties уже добавлены. Пропускаем добавление Properties.\n');
        fprintf('Проверяем методы...\n');
    else
        % Добавить Properties после секции UI компонентов
        currentCode = addPropertiesToCode(currentCode);
        fprintf('✓ Properties добавлены\n');
    end
    
    % Добавить методы
    currentCode = addMethodsToCode(currentCode);
    fprintf('✓ Методы добавлены\n');
    
    % Записать обратно
    try
        write_mlapp_code(currentCode);
        fprintf('\n✓ Файл успешно обновлен!\n');
        fprintf('Откройте в App Designer для проверки: appdesigner(''TableGraphEditor.mlapp'')\n');
    catch ME
        fprintf('\n✗ Ошибка при записи: %s\n', ME.message);
        rethrow(ME);
    end
end

function newCode = addPropertiesToCode(currentCode)
    % ADDPROPERTIESTOCODE Добавляет Properties после UI компонентов
    
    % Найти конец секции properties для UI компонентов
    pattern = '(properties \(Access = public\)[^}]*end)';
    match = regexp(currentCode, pattern, 'match', 'once');
    
    if isempty(match)
        error('Не найдена секция properties для UI компонентов');
    end
    
    % Добавить наши Properties после секции UI компонентов
    propertiesCode = [newline, '    % Application data and state', newline];
    propertiesCode = [propertiesCode, '    properties (Access = private)', newline];
    propertiesCode = [propertiesCode, '        % === Данные ===', newline];
    propertiesCode = [propertiesCode, '        originalData        % Исходные данные (полная матрица)', newline];
    propertiesCode = [propertiesCode, '        currentData         % Текущие редактируемые данные', newline];
    propertiesCode = [propertiesCode, '        selectedVariable    % Выбранная переменная из workspace', newline];
    propertiesCode = [propertiesCode, '        editMode = ''XY''     % Режим редактирования: ''XY''', newline];
    propertiesCode = [propertiesCode, '        currentPlotType = ''columns'' % ''columns'' или ''rows''', newline];
    propertiesCode = [propertiesCode, '        ', newline];
    propertiesCode = [propertiesCode, '        % === Выбор части данных ===', newline];
    propertiesCode = [propertiesCode, '        selectedColumns = [] % Индексы выбранных столбцов', newline];
    propertiesCode = [propertiesCode, '        selectedRows = []    % Индексы выбранных строк', newline];
    propertiesCode = [propertiesCode, '        ', newline];
    propertiesCode = [propertiesCode, '        % === Метки ===', newline];
    propertiesCode = [propertiesCode, '        rowLabels = {}      % Метки строк', newline];
    propertiesCode = [propertiesCode, '        columnLabels = {}   % Метки столбцов', newline];
    propertiesCode = [propertiesCode, '        ', newline];
    propertiesCode = [propertiesCode, '        % === Перетаскивание ===', newline];
    propertiesCode = [propertiesCode, '        selectedPoint = []  % Индекс выбранной точки [curveIndex, pointIndex]', newline];
    propertiesCode = [propertiesCode, '        isDragging = false  % Флаг активного перетаскивания', newline];
    propertiesCode = [propertiesCode, '        dragStartPosition = [] % Начальная позиция перетаскивания [x, y]', newline];
    propertiesCode = [propertiesCode, '        ', newline];
    propertiesCode = [propertiesCode, '        % === Состояние приложения ===', newline];
    propertiesCode = [propertiesCode, '        isUpdating = false  % Флаг обновления (предотвращает циклические обновления)', newline];
    propertiesCode = [propertiesCode, '    end', newline, newline];
    
    % Вставить после секции UI компонентов
    newCode = strrep(currentCode, match, [match, propertiesCode]);
end

function newCode = addMethodsToCode(currentCode)
    % ADDMETHODSTOCODE Добавляет методы перед секцией App creation
    
    % Найти секцию "Component initialization"
    pattern = '(methods \(Access = private\)[^}]*?end\s+end)';
    
    % Если не найдено, попробуем найти конец методов
    if isempty(regexp(currentCode, pattern, 'once'))
        % Найти где заканчиваются методы createComponents
        pattern = '(function createComponents\(app\)[^}]*?end\s+)';
    end
    
    % Добавить методы после createComponents
    methodsCode = [newline, '        % STARTUPFCN Выполняется при запуске приложения', newline];
    methodsCode = [methodsCode, '        function startupFcn(app, varargin)', newline];
    methodsCode = [methodsCode, '            % Инициализирует dropdown переменных из workspace', newline];
    methodsCode = [methodsCode, '            updateVariableDropdown(app);', newline];
    methodsCode = [methodsCode, '        end', newline, newline];
    
    methodsCode = [methodsCode, '        % === Загрузка данных ===', newline];
    methodsCode = [methodsCode, '        function loadVariableFromWorkspace(app, varName)', newline];
    methodsCode = [methodsCode, '            % LOADVARIABLEFROMWORKSPACE Загружает переменную из workspace', newline];
    methodsCode = [methodsCode, '            try', newline];
    methodsCode = [methodsCode, '                data = evalin(''base'', varName);', newline];
    methodsCode = [methodsCode, '                if ~isnumeric(data)', newline];
    methodsCode = [methodsCode, '                    uialert(app.UIFigure, ''Переменная должна быть числовой'', ''Ошибка'');', newline];
    methodsCode = [methodsCode, '                    return;', newline];
    methodsCode = [methodsCode, '                end', newline];
    methodsCode = [methodsCode, '                app.originalData = data;', newline];
    methodsCode = [methodsCode, '                app.currentData = data;', newline];
    methodsCode = [methodsCode, '                app.selectedVariable = varName;', newline];
    methodsCode = [methodsCode, '                % TODO: Обновить таблицу и график', newline];
    methodsCode = [methodsCode, '            catch ME', newline];
    methodsCode = [methodsCode, '                uialert(app.UIFigure, ME.message, ''Ошибка загрузки'');', newline];
    methodsCode = [methodsCode, '            end', newline];
    methodsCode = [methodsCode, '        end', newline, newline];
    
    methodsCode = [methodsCode, '        function updateVariableDropdown(app)', newline];
    methodsCode = [methodsCode, '            % UPDATEVARIABLEDROPDOWN Обновляет список переменных в dropdown', newline];
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
    methodsCode = [methodsCode, '                        % Пропустить переменную', newline];
    methodsCode = [methodsCode, '                    end', newline];
    methodsCode = [methodsCode, '                end', newline];
    methodsCode = [methodsCode, '                app.ddVariable.Items = [''Select variable...'', numericVars];', newline];
    methodsCode = [methodsCode, '            catch ME', newline];
    methodsCode = [methodsCode, '                fprintf(''Ошибка обновления dropdown: %s\n'', ME.message);', newline];
    methodsCode = [methodsCode, '            end', newline];
    methodsCode = [methodsCode, '        end', newline, newline];
    
    methodsCode = [methodsCode, '        % === Построение графиков ===', newline];
    methodsCode = [methodsCode, '        function plotByColumns(app, data)', newline];
    methodsCode = [methodsCode, '            % PLOTBYCOLUMNS Строит график по столбцам', newline];
    methodsCode = [methodsCode, '            cla(app.axPlot);', newline];
    methodsCode = [methodsCode, '            hold(app.axPlot, ''on'');', newline];
    methodsCode = [methodsCode, '            for col = 1:size(data, 2)', newline];
    methodsCode = [methodsCode, '                plot(app.axPlot, 1:size(data, 1), data(:, col), ''-o'');', newline];
    methodsCode = [methodsCode, '            end', newline];
    methodsCode = [methodsCode, '            hold(app.axPlot, ''off'');', newline];
    methodsCode = [methodsCode, '            xlabel(app.axPlot, ''Index'');', newline];
    methodsCode = [methodsCode, '            ylabel(app.axPlot, ''Value'');', newline];
    methodsCode = [methodsCode, '            title(app.axPlot, ''Plot by Columns'');', newline];
    methodsCode = [methodsCode, '            legend(app.axPlot, ''show'');', newline];
    methodsCode = [methodsCode, '        end', newline, newline];
    
    methodsCode = [methodsCode, '        function plotByRows(app, data)', newline];
    methodsCode = [methodsCode, '            % PLOTBYROWS Строит график по строкам', newline];
    methodsCode = [methodsCode, '            cla(app.axPlot);', newline];
    methodsCode = [methodsCode, '            hold(app.axPlot, ''on'');', newline];
    methodsCode = [methodsCode, '            for row = 1:size(data, 1)', newline];
    methodsCode = [methodsCode, '                plot(app.axPlot, 1:size(data, 2), data(row, :), ''-o'');', newline];
    methodsCode = [methodsCode, '            end', newline];
    methodsCode = [methodsCode, '            hold(app.axPlot, ''off'');', newline];
    methodsCode = [methodsCode, '            xlabel(app.axPlot, ''Index'');', newline];
    methodsCode = [methodsCode, '            ylabel(app.axPlot, ''Value'');', newline];
    methodsCode = [methodsCode, '            title(app.axPlot, ''Plot by Rows'');', newline];
    methodsCode = [methodsCode, '            legend(app.axPlot, ''show'');', newline];
    methodsCode = [methodsCode, '        end', newline, newline];
    
    methodsCode = [methodsCode, '        function updateGraph(app)', newline];
    methodsCode = [methodsCode, '            % UPDATEGRAPH Обновляет график на основе текущих данных', newline];
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
    methodsCode = [methodsCode, '                drawnow limitrate;', newline];
    methodsCode = [methodsCode, '            catch ME', newline];
    methodsCode = [methodsCode, '                uialert(app.UIFigure, ME.message, ''Ошибка построения графика'');', newline];
    methodsCode = [methodsCode, '            end', newline];
    methodsCode = [methodsCode, '            app.isUpdating = false;', newline];
    methodsCode = [methodsCode, '        end', newline, newline];
    
    methodsCode = [methodsCode, '        % === Валидация ===', newline];
    methodsCode = [methodsCode, '        function isValid = validateData(app, data)', newline];
    methodsCode = [methodsCode, '            % VALIDATEDATA Проверяет корректность данных', newline];
    methodsCode = [methodsCode, '            isValid = isnumeric(data) && ~isempty(data);', newline];
    methodsCode = [methodsCode, '        end', newline];
    
    % Вставить после createComponents
    insertPattern = '(function createComponents\(app\)[^}]*?end\s+)';
    newCode = regexprep(currentCode, insertPattern, ['$1', methodsCode], 'once');
    
    % Если не вставилось, попробуем другой способ
    if strcmp(newCode, currentCode)
        % Найти конец методов (Access = private)
        pattern = '(end\s+end\s+% App creation)';
        newCode = regexprep(currentCode, pattern, [methodsCode, '$1'], 'once');
    end
    
    % Добавить вызов startupFcn в конструктор, если его еще нет
    if ~contains(newCode, 'runStartupFcn')
        pattern = '(registerApp\(app, app\.UIFigure\)\s+)';
        replacement = ['registerApp(app, app.UIFigure)', newline, newline, '            % Execute startup function', newline, '            runStartupFcn(app, @startupFcn)', newline];
        newCode = regexprep(newCode, pattern, replacement, 'once');
    end
end


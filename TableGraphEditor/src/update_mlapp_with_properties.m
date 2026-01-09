%% UPDATE_MLAPP_WITH_PROPERTIES Обновляет .mlapp файл с Properties и методами
%   Добавляет базовые Properties и методы в TableGraphEditor.mlapp
%
%   Использование:
%       update_mlapp_with_properties

function update_mlapp_with_properties()
    % UPDATE_MLAPP_WITH_PROPERTIES Обновляет .mlapp файл
    
    fprintf('=== Обновление TableGraphEditor.mlapp ===\n\n');
    
    % Прочитать текущий код
    try
        currentCode = read_mlapp_code();
        fprintf('✓ Текущий код прочитан\n');
    catch ME
        error('Не удалось прочитать код: %s', ME.message);
    end
    
    % Создать обновленный код
    newCode = createUpdatedCode(currentCode);
    
    % Записать обратно
    try
        write_mlapp_code(newCode);
        fprintf('\n✓ Файл успешно обновлен!\n');
        fprintf('Откройте в App Designer для проверки: appdesigner(''TableGraphEditor.mlapp'')\n');
    catch ME
        fprintf('\n✗ Ошибка при записи: %s\n', ME.message);
        fprintf('Попробуйте открыть файл в App Designer и добавить код вручную\n');
        rethrow(ME);
    end
end

function newCode = createUpdatedCode(currentCode)
    % CREATEUPDATEDCODE Создает обновленный код с Properties и методами
    
    % Найти где заканчивается секция Properties для UI компонентов
    % И добавить наши Properties
    
    % Базовый шаблон кода
    newCode = ['classdef TableGraphEditor < matlab.apps.AppBase', newline, newline];
    
    % Properties для UI компонентов (будут добавлены через GUI)
    newCode = [newCode, '    % Properties that correspond to app components', newline];
    newCode = [newCode, '    properties (Access = public)', newline];
    newCode = [newCode, '        UIFigure  matlab.ui.Figure', newline];
    newCode = [newCode, '    end', newline, newline];
    
    % Наши Properties для данных
    newCode = [newCode, '    % Application data and state', newline];
    newCode = [newCode, '    properties (Access = private)', newline];
    newCode = [newCode, '        % === Данные ===', newline];
    newCode = [newCode, '        originalData        % Исходные данные (полная матрица)', newline];
    newCode = [newCode, '        currentData         % Текущие редактируемые данные', newline];
    newCode = [newCode, '        selectedVariable    % Выбранная переменная из workspace', newline];
    newCode = [newCode, '        editMode = ''XY''     % Режим редактирования: ''XY''', newline];
    newCode = [newCode, '        currentPlotType = ''columns'' % ''columns'' или ''rows''', newline];
    newCode = [newCode, '        ', newline];
    newCode = [newCode, '        % === Выбор части данных ===', newline];
    newCode = [newCode, '        selectedColumns = [] % Индексы выбранных столбцов', newline];
    newCode = [newCode, '        selectedRows = []    % Индексы выбранных строк', newline];
    newCode = [newCode, '        ', newline];
    newCode = [newCode, '        % === Метки ===', newline];
    newCode = [newCode, '        rowLabels = {}      % Метки строк', newline];
    newCode = [newCode, '        columnLabels = {}   % Метки столбцов', newline];
    newCode = [newCode, '        ', newline];
    newCode = [newCode, '        % === Перетаскивание ===', newline];
    newCode = [newCode, '        selectedPoint = []  % Индекс выбранной точки [curveIndex, pointIndex]', newline];
    newCode = [newCode, '        isDragging = false  % Флаг активного перетаскивания', newline];
    newCode = [newCode, '        dragStartPosition = [] % Начальная позиция перетаскивания [x, y]', newline];
    newCode = [newCode, '        ', newline];
    newCode = [newCode, '        % === Состояние приложения ===', newline];
    newCode = [newCode, '        isUpdating = false  % Флаг обновления (предотвращает циклические обновления)', newline];
    newCode = [newCode, '    end', newline, newline];
    
    % Component initialization
    newCode = [newCode, '    % Component initialization', newline];
    newCode = [newCode, '    methods (Access = private)', newline, newline];
    newCode = [newCode, '        % Create UIFigure and components', newline];
    newCode = [newCode, '        function createComponents(app)', newline, newline];
    newCode = [newCode, '            % Create UIFigure and hide until all components are created', newline];
    newCode = [newCode, '            app.UIFigure = uifigure(''Visible'', ''off'');', newline];
    newCode = [newCode, '            app.UIFigure.Position = [100 100 1200 800];', newline];
    newCode = [newCode, '            app.UIFigure.Name = ''Table-Graph Editor'';', newline];
    newCode = [newCode, '            app.UIFigure.Tag = ''Table-Graph Editor'';', newline, newline];
    newCode = [newCode, '            % TODO: Добавить UI компоненты через Design View', newline];
    newCode = [newCode, '            % - app.tblData (uitable)', newline];
    newCode = [newCode, '            % - app.axPlot (uiaxes)', newline];
    newCode = [newCode, '            % - app.ddVariable (uidropdown)', newline];
    newCode = [newCode, '            % - app.ddPlotType (uidropdown)', newline];
    newCode = [newCode, '            % - app.btnSave (uibutton)', newline];
    newCode = [newCode, '            % - app.bgEditMode (uibuttongroup)', newline];
    newCode = [newCode, '            % - app.rbModeXY (uiradiobutton)', newline, newline];
    newCode = [newCode, '            % Show the figure after all components are created', newline];
    newCode = [newCode, '            app.UIFigure.Visible = ''on'';', newline];
    newCode = [newCode, '        end', newline, newline];
    
    % Startup function
    newCode = [newCode, '        % STARTUPFCN Выполняется при запуске приложения', newline];
    newCode = [newCode, '        function startupFcn(app, varargin)', newline];
    newCode = [newCode, '            % Инициализирует dropdown переменных из workspace', newline];
    newCode = [newCode, '            % TODO: Реализовать после добавления UI компонентов', newline];
    newCode = [newCode, '            % updateVariableDropdown(app);', newline];
    newCode = [newCode, '        end', newline, newline];
    
    % Helper methods
    newCode = [newCode, '        % === Загрузка данных ===', newline];
    newCode = [newCode, '        function loadVariableFromWorkspace(app, varName)', newline];
    newCode = [newCode, '            % LOADVARIABLEFROMWORKSPACE Загружает переменную из workspace', newline];
    newCode = [newCode, '            % TODO: Реализовать', newline];
    newCode = [newCode, '        end', newline, newline];
    
    newCode = [newCode, '        function updateVariableDropdown(app)', newline];
    newCode = [newCode, '            % UPDATEVARIABLEDROPDOWN Обновляет список переменных в dropdown', newline];
    newCode = [newCode, '            % TODO: Реализовать после добавления UI компонентов', newline];
    newCode = [newCode, '        end', newline, newline];
    
    newCode = [newCode, '        % === Построение графиков ===', newline];
    newCode = [newCode, '        function plotByColumns(app, data)', newline];
    newCode = [newCode, '            % PLOTBYCOLUMNS Строит график по столбцам', newline];
    newCode = [newCode, '            % TODO: Реализовать после добавления UI компонентов', newline];
    newCode = [newCode, '        end', newline, newline];
    
    newCode = [newCode, '        function plotByRows(app, data)', newline];
    newCode = [newCode, '            % PLOTBYROWS Строит график по строкам', newline];
    newCode = [newCode, '            % TODO: Реализовать после добавления UI компонентов', newline];
    newCode = [newCode, '        end', newline, newline];
    
    newCode = [newCode, '        function updateGraph(app)', newline];
    newCode = [newCode, '            % UPDATEGRAPH Обновляет график на основе текущих данных', newline];
    newCode = [newCode, '            % TODO: Реализовать после добавления UI компонентов', newline];
    newCode = [newCode, '        end', newline, newline];
    
    newCode = [newCode, '        % === Валидация ===', newline];
    newCode = [newCode, '        function isValid = validateData(app, data)', newline];
    newCode = [newCode, '            % VALIDATEDATA Проверяет корректность данных', newline];
    newCode = [newCode, '            isValid = isnumeric(data) && ~isempty(data);', newline];
    newCode = [newCode, '        end', newline];
    newCode = [newCode, '    end', newline, newline];
    
    % App creation and deletion
    newCode = [newCode, '    % App creation and deletion', newline];
    newCode = [newCode, '    methods (Access = public)', newline, newline];
    newCode = [newCode, '        % Construct app', newCode];
    newCode = [newCode, '        function app = TableGraphEditor', newline, newline];
    newCode = [newCode, '            % Create UIFigure and components', newline];
    newCode = [newCode, '            createComponents(app)', newline, newline];
    newCode = [newCode, '            % Register the app with App Designer', newline];
    newCode = [newCode, '            registerApp(app, app.UIFigure)', newline, newline];
    newCode = [newCode, '            % Execute startup function', newline];
    newCode = [newCode, '            runStartupFcn(app, @startupFcn)', newline, newline];
    newCode = [newCode, '            if nargout == 0', newline];
    newCode = [newCode, '                clear app', newline];
    newCode = [newCode, '            end', newline];
    newCode = [newCode, '        end', newline, newline];
    
    newCode = [newCode, '        % Code that executes before app deletion', newline];
    newCode = [newCode, '        function delete(app)', newline, newline];
    newCode = [newCode, '            % Delete UIFigure when app is deleted', newline];
    newCode = [newCode, '            delete(app.UIFigure)', newline];
    newCode = [newCode, '        end', newline];
    newCode = [newCode, '    end', newline];
    newCode = [newCode, 'end', newline];
end


%% METHODS_TO_ADD Методы для добавления в TableGraphEditor.mlapp
%   Скопируйте эти методы в секцию methods (Access = private)
%   Добавьте после функции createComponents

        % STARTUPFCN Выполняется при запуске приложения
        function startupFcn(app, varargin)
            % Инициализирует dropdown переменных из workspace
            updateVariableDropdown(app);
        end
        
        % === Загрузка данных ===
        function loadVariableFromWorkspace(app, varName)
            % LOADVARIABLEFROMWORKSPACE Загружает переменную из workspace
            try
                data = evalin('base', varName);
                if ~isnumeric(data)
                    uialert(app.UIFigure, 'Переменная должна быть числовой', 'Ошибка');
                    return;
                end
                app.originalData = data;
                app.currentData = data;
                app.selectedVariable = varName;
                % TODO: Обновить таблицу и график
            catch ME
                uialert(app.UIFigure, ME.message, 'Ошибка загрузки');
            end
        end
        
        function updateVariableDropdown(app)
            % UPDATEVARIABLEDROPDOWN Обновляет список переменных в dropdown
            try
                vars = evalin('base', 'who');
                numericVars = {};
                for i = 1:length(vars)
                    try
                        varData = evalin('base', vars{i});
                        if isnumeric(varData) && ~isempty(varData)
                            numericVars{end+1} = vars{i};
                        end
                    catch
                        % Пропустить переменную
                    end
                end
                app.ddVariable.Items = ['Select variable...', numericVars];
            catch ME
                fprintf('Ошибка обновления dropdown: %s\n', ME.message);
            end
        end
        
        % === Построение графиков ===
        function plotByColumns(app, data)
            % PLOTBYCOLUMNS Строит график по столбцам
            cla(app.axPlot);
            hold(app.axPlot, 'on');
            for col = 1:size(data, 2)
                plot(app.axPlot, 1:size(data, 1), data(:, col), '-o');
            end
            hold(app.axPlot, 'off');
            xlabel(app.axPlot, 'Index');
            ylabel(app.axPlot, 'Value');
            title(app.axPlot, 'Plot by Columns');
            legend(app.axPlot, 'show');
        end
        
        function plotByRows(app, data)
            % PLOTBYROWS Строит график по строкам
            cla(app.axPlot);
            hold(app.axPlot, 'on');
            for row = 1:size(data, 1)
                plot(app.axPlot, 1:size(data, 2), data(row, :), '-o');
            end
            hold(app.axPlot, 'off');
            xlabel(app.axPlot, 'Index');
            ylabel(app.axPlot, 'Value');
            title(app.axPlot, 'Plot by Rows');
            legend(app.axPlot, 'show');
        end
        
        function updateGraph(app)
            % UPDATEGRAPH Обновляет график на основе текущих данных
            if app.isUpdating || isempty(app.currentData)
                return;
            end
            app.isUpdating = true;
            try
                if strcmp(app.currentPlotType, 'columns')
                    plotByColumns(app, app.currentData);
                else
                    plotByRows(app, app.currentData);
                end
                drawnow limitrate;
            catch ME
                uialert(app.UIFigure, ME.message, 'Ошибка построения графика');
            end
            app.isUpdating = false;
        end
        
        % === Валидация ===
        function isValid = validateData(app, data)
            % VALIDATEDATA Проверяет корректность данных
            isValid = isnumeric(data) && ~isempty(data);
        end


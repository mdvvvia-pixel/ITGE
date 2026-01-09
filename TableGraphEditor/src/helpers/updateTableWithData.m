%% UPDATETABLEWITHDATA Обновить таблицу с данными
%   Извлекает метки и отображает данные в таблице
%
%   Использование:
%       updateTableWithData(app)
%
%   Параметры:
%       app - объект приложения TableGraphEditor
%
%   Описание:
%       Извлекает метки из первой строки/столбца в зависимости от режима
%       отображения (columns/rows) и обновляет таблицу данными.
%       Метки сохраняются в app.columnLabels или app.rowLabels.

function updateTableWithData(app)
    % UPDATETABLEWITHDATA Обновить таблицу с данными
    
    fprintf('updateTableWithData вызван\n');  % Отладочный вывод
    
    try
        % Получить текущие данные (из свойства или UserData)
        data = [];
        
        % Сначала попробовать получить из свойства
        if isprop(app, 'currentData')
            try
                data = app.currentData;
                if ~isempty(data)
                    fprintf('Данные получены из app.currentData: size=[%s]\n', num2str(size(data)));
                end
            catch ME
                fprintf('Ошибка получения currentData из свойства: %s\n', ME.message);
            end
        end
        
        % Если данные не получены из свойства, попробовать UserData
        if isempty(data)
            if isfield(app.UIFigure.UserData, 'appData') && ...
               isfield(app.UIFigure.UserData.appData, 'currentData')
                data = app.UIFigure.UserData.appData.currentData;
                fprintf('Данные получены из UserData: size=[%s]\n', num2str(size(data)));
            end
        end
        
        % Если данные все еще пусты, попробовать originalData
        if isempty(data)
            if isprop(app, 'originalData')
                try
                    data = app.originalData;
                    if ~isempty(data)
                        fprintf('Данные получены из app.originalData: size=[%s]\n', num2str(size(data)));
                    end
                catch ME
                    fprintf('Ошибка получения originalData: %s\n', ME.message);
                end
            end
        end
        
        % Если данные все еще пусты, попробовать originalData из UserData
        if isempty(data)
            if isfield(app.UIFigure.UserData, 'appData') && ...
               isfield(app.UIFigure.UserData.appData, 'originalData')
                data = app.UIFigure.UserData.appData.originalData;
                fprintf('Данные получены из UserData.originalData: size=[%s]\n', num2str(size(data)));
            end
        end
        
        if isempty(data)
            fprintf('⚠ ОШИБКА: Данные не найдены ни в currentData, ни в originalData, ни в UserData\n');
            if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                uialert(app.UIFigure, ...
                    'Данные не найдены. Пожалуйста, загрузите переменную из workspace.', ...
                    'Ошибка', ...
                    'Icon', 'warning');
            end
            return;
        end
        
        fprintf('Данные получены: size=[%s], тип=%s\n', num2str(size(data)), class(data));
        
        % Определить режим отображения (если свойство существует)
        if isprop(app, 'currentPlotType')
            try
                plotType = app.currentPlotType;
            catch
                plotType = 'columns';  % По умолчанию
            end
        else
            plotType = 'columns';  % По умолчанию
        end
        
        % Извлечь метки и обновить данные в зависимости от режима
        if strcmp(plotType, 'columns')
            % Режим "по столбцам": первая строка = метки столбцов
            % Вся матрица отображается как есть (первая строка с метками)
            displayData = data;
            
            % Сохранить метки столбцов (если свойство существует)
            if size(data, 1) > 0
                if isprop(app, 'columnLabels')
                    try
                        app.columnLabels = data(1, :);
                    catch
                        % Если не получилось, попробовать через UserData
                        if ~isfield(app.UIFigure.UserData, 'appData')
                            app.UIFigure.UserData.appData = struct();
                        end
                        app.UIFigure.UserData.appData.columnLabels = data(1, :);
                    end
                end
            end
        else
            % Режим "по строкам": первый столбец = метки строк
            % Вся матрица отображается как есть (первый столбец с метками)
            displayData = data;
            
            % Сохранить метки строк (если свойство существует)
            if size(data, 2) > 0
                if isprop(app, 'rowLabels')
                    try
                        app.rowLabels = data(:, 1);
                    catch
                        % Если не получилось, попробовать через UserData
                        if ~isfield(app.UIFigure.UserData, 'appData')
                            app.UIFigure.UserData.appData = struct();
                        end
                        app.UIFigure.UserData.appData.rowLabels = data(:, 1);
                    end
                end
            end
        end
        
        % Обновить таблицу (если компонент существует)
        if isprop(app, 'tblData') && isvalid(app.tblData)
            try
                fprintf('Обновление таблицы: size=[%s]\n', num2str(size(displayData)));
                app.tblData.Data = displayData;
                fprintf('✓ Таблица обновлена успешно\n');
            catch ME
                fprintf('Предупреждение: не удалось обновить таблицу: %s\n', ME.message);
                fprintf('Стек ошибки:\n');
                for i = 1:length(ME.stack)
                    fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
                end
            end
        else
            fprintf('⚠ Таблица tblData не найдена или не валидна\n');
        end
        
    catch ME
        fprintf('Ошибка обновления таблицы: %s\n', ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        
        if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
            uialert(app.UIFigure, ...
                sprintf('Ошибка обновления таблицы: %s', ME.message), ...
                'Ошибка', ...
                'Icon', 'error');
        end
    end
end


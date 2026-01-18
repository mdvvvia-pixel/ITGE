%% UPDATESELECTION Обновляет выделенные столбцы/строки на основе выделения в таблице
%   Извлекает выделенные столбцы/строки из uitable.Selection.
%   В новой модели данных таблица содержит только Y-матрицу, поэтому
%   исключать "служебные" строку/столбец больше не нужно.
%
%   Использование:
%       updateSelection(app, selection)
%
%   Параметры:
%       app - объект приложения TableGraphEditor
%       selection - массив [row, col] выделенных ячеек (из uitable.Selection)
%
%   Описание:
%       - В режиме "по столбцам": извлекает уникальные столбцы, исключая столбец 1
%       - В режиме "по строкам": извлекает уникальные строки, исключая строку 1
%       - Сохраняет результат в app.selectedColumns или app.selectedRows

function updateSelection(app, selection)
    % UPDATESELECTION Обновляет выделенные столбцы/строки
    
    fprintf('updateSelection вызван\n');  % Отладочный вывод
    
    % Проверить входные данные
    if isempty(selection)
        % Нет выделения - очистить выделенные столбцы/строки
        fprintf('Выделение пустое - очистка selectedColumns и selectedRows\n');
        
        % Очистить selectedColumns (безопасно)
        if isprop(app, 'selectedColumns')
            try
                app.selectedColumns = [];
            catch
                % Если не удалось, сохранить в UserData
                if ~isfield(app.UIFigure.UserData, 'appData')
                    app.UIFigure.UserData.appData = struct();
                end
                app.UIFigure.UserData.appData.selectedColumns = [];
            end
        else
            if ~isfield(app.UIFigure.UserData, 'appData')
                app.UIFigure.UserData.appData = struct();
            end
            app.UIFigure.UserData.appData.selectedColumns = [];
        end
        
        % Очистить selectedRows (безопасно)
        if isprop(app, 'selectedRows')
            try
                app.selectedRows = [];
            catch
                % Если не удалось, сохранить в UserData
                if ~isfield(app.UIFigure.UserData, 'appData')
                    app.UIFigure.UserData.appData = struct();
                end
                app.UIFigure.UserData.appData.selectedRows = [];
            end
        else
            if ~isfield(app.UIFigure.UserData, 'appData')
                app.UIFigure.UserData.appData = struct();
            end
            app.UIFigure.UserData.appData.selectedRows = [];
        end
        
        return;
    end
    
    % Проверить формат selection
    % uitable.Selection возвращает массив [row, col] для каждой выделенной ячейки
    if size(selection, 2) ~= 2
        fprintf('⚠ updateSelection: неверный формат selection (ожидается [row, col])\n');
        return;
    end
    
    fprintf('Выделение: %d ячеек\n', size(selection, 1));
    
    % Получить режим построения графика
    plotType = 'columns';
    if isprop(app, 'currentPlotType')
        try
            plotType = app.currentPlotType;
        catch
            % Если не удалось получить, использовать значение по умолчанию
            if isfield(app.UIFigure.UserData, 'appData') && ...
               isfield(app.UIFigure.UserData.appData, 'currentPlotType')
                plotType = app.UIFigure.UserData.appData.currentPlotType;
            end
        end
    else
        if isfield(app.UIFigure.UserData, 'appData') && ...
           isfield(app.UIFigure.UserData.appData, 'currentPlotType')
            plotType = app.UIFigure.UserData.appData.currentPlotType;
        end
    end
    
    fprintf('Режим графика: %s\n', plotType);
    
    try
        if strcmp(plotType, 'columns')
            % Режим "по столбцам"
            % Извлечь уникальные столбцы из выделения
            selectedCols = unique(selection(:, 2));
            
            fprintf('Выделенные столбцы (до фильтрации): [%s]\n', num2str(selectedCols'));
            
            % Таблица содержит только Y: индексы столбцов напрямую соответствуют кривым
            filteredCols = selectedCols(:);
            
            fprintf('Выделенные столбцы (после фильтрации): [%s]\n', num2str(filteredCols'));
            
            % Сохранить в app.selectedColumns (безопасно)
            if isprop(app, 'selectedColumns')
                try
                    app.selectedColumns = filteredCols(:);  % Преобразовать в column vector
                catch
                    % Если не удалось, сохранить в UserData
                    if ~isfield(app.UIFigure.UserData, 'appData')
                        app.UIFigure.UserData.appData = struct();
                    end
                    app.UIFigure.UserData.appData.selectedColumns = filteredCols(:);
                end
            else
                if ~isfield(app.UIFigure.UserData, 'appData')
                    app.UIFigure.UserData.appData = struct();
                end
                app.UIFigure.UserData.appData.selectedColumns = filteredCols(:);
            end
            
            % Очистить selectedRows (не используется в этом режиме)
            if isprop(app, 'selectedRows')
                try
                    app.selectedRows = [];
                catch
                    if ~isfield(app.UIFigure.UserData, 'appData')
                        app.UIFigure.UserData.appData = struct();
                    end
                    app.UIFigure.UserData.appData.selectedRows = [];
                end
            else
                if ~isfield(app.UIFigure.UserData, 'appData')
                    app.UIFigure.UserData.appData = struct();
                end
                app.UIFigure.UserData.appData.selectedRows = [];
            end
            
        else
            % Режим "по строкам"
            % Извлечь уникальные строки из выделения
            selectedRows = unique(selection(:, 1));
            
            fprintf('Выделенные строки (до фильтрации): [%s]\n', num2str(selectedRows'));
            
            % Таблица содержит только Y: индексы строк напрямую соответствуют кривым
            filteredRows = selectedRows(:);
            
            fprintf('Выделенные строки (после фильтрации): [%s]\n', num2str(filteredRows'));
            
            % Сохранить в app.selectedRows (безопасно)
            if isprop(app, 'selectedRows')
                try
                    app.selectedRows = filteredRows(:);  % Преобразовать в column vector
                catch
                    % Если не удалось, сохранить в UserData
                    if ~isfield(app.UIFigure.UserData, 'appData')
                        app.UIFigure.UserData.appData = struct();
                    end
                    app.UIFigure.UserData.appData.selectedRows = filteredRows(:);
                end
            else
                if ~isfield(app.UIFigure.UserData, 'appData')
                    app.UIFigure.UserData.appData = struct();
                end
                app.UIFigure.UserData.appData.selectedRows = filteredRows(:);
            end
            
            % Очистить selectedColumns (не используется в этом режиме)
            if isprop(app, 'selectedColumns')
                try
                    app.selectedColumns = [];
                catch
                    if ~isfield(app.UIFigure.UserData, 'appData')
                        app.UIFigure.UserData.appData = struct();
                    end
                    app.UIFigure.UserData.appData.selectedColumns = [];
                end
            else
                if ~isfield(app.UIFigure.UserData, 'appData')
                    app.UIFigure.UserData.appData = struct();
                end
                app.UIFigure.UserData.appData.selectedColumns = [];
            end
        end
        
        fprintf('✓ Выделение обновлено успешно\n');
        
    catch ME
        fprintf('Ошибка в updateSelection: %s\n', ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        
        if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
            uialert(app.UIFigure, ...
                sprintf('Ошибка обработки выделения: %s', ME.message), ...
                'Ошибка выделения', ...
                'Icon', 'error');
        end
    end
end


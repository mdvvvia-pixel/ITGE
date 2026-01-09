%% PLOTBYCOLUMNS Строит график по столбцам
%   Каждый столбец данных отображается как отдельная кривая
%
%   Использование:
%       plotByColumns(app, data)
%
%   Параметры:
%       app - объект приложения TableGraphEditor
%       data - матрица данных (числовая)

function plotByColumns(app, data)
    % PLOTBYCOLUMNS Строит график по столбцам
    
    fprintf('plotByColumns вызван: size=[%s]\n', num2str(size(data)));
    
    % Проверить входные данные
    if isempty(data) || ~isnumeric(data)
        fprintf('⚠ plotByColumns: данные пусты или не числовые\n');
        return;
    end
    
    % Проверить наличие компонента axPlot
    if ~isprop(app, 'axPlot') || ~isvalid(app.axPlot)
        fprintf('⚠ plotByColumns: axPlot не найден или не валиден\n');
        return;
    end
    
    try
        % Очистить график
        cla(app.axPlot);
        hold(app.axPlot, 'on');
        
        % Построить каждую колонку как отдельную кривую
        numCols = size(data, 2);
        numRows = size(data, 1);
        fprintf('Построение графика: %d столбцов, %d строк\n', numCols, numRows);
        
        colors = lines(numCols); % Генерация цветов
        
        for col = 1:numCols
            xData = 1:numRows;
            yData = data(:, col);
            
            % Использовать метку столбца, если доступна
            label = sprintf('Column %d', col);
            if isprop(app, 'columnLabels')
                try
                    if ~isempty(app.columnLabels) && ...
                       (iscell(app.columnLabels) || isnumeric(app.columnLabels))
                        if iscell(app.columnLabels)
                            if length(app.columnLabels) >= col && ~isempty(app.columnLabels{col})
                                label = char(string(app.columnLabels{col}));
                            end
                        elseif isnumeric(app.columnLabels) && length(app.columnLabels) >= col
                            label = sprintf('Column %.2f', app.columnLabels(col));
                        end
                    end
                catch
                    % Использовать значение по умолчанию
                end
            end
            
            plot(app.axPlot, xData, yData, '-o', ...
                'Color', colors(col, :), ...
                'DisplayName', label, ...
                'MarkerSize', 6);
            fprintf('  Построена кривая %d: %s\n', col, label);
        end
        
        hold(app.axPlot, 'off');
        
        % Настройка осей
        xlabel(app.axPlot, 'Index');
        ylabel(app.axPlot, 'Value');
        title(app.axPlot, 'Plot by Columns');
        legend(app.axPlot, 'show');
        grid(app.axPlot, 'on');
        
        fprintf('✓ График построен успешно\n');
        
    catch ME
        fprintf('Ошибка в plotByColumns: %s\n', ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        
        if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
            uialert(app.UIFigure, sprintf('Ошибка построения графика: %s', ME.message), 'Ошибка');
        end
    end
end


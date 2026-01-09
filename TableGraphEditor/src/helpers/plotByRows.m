%% PLOTBYROWS Строит график по строкам
%   Каждая строка данных отображается как отдельная кривая
%
%   Использование:
%       plotByRows(app, data)
%
%   Параметры:
%       app - объект приложения TableGraphEditor
%       data - матрица данных (числовая)

function plotByRows(app, data)
    % PLOTBYROWS Строит график по строкам
    
    fprintf('plotByRows вызван: size=[%s]\n', num2str(size(data)));
    
    % Проверить входные данные
    if isempty(data) || ~isnumeric(data)
        fprintf('⚠ plotByRows: данные пусты или не числовые\n');
        return;
    end
    
    % Проверить наличие компонента axPlot
    if ~isprop(app, 'axPlot') || ~isvalid(app.axPlot)
        fprintf('⚠ plotByRows: axPlot не найден или не валиден\n');
        return;
    end
    
    try
        % Очистить график
        cla(app.axPlot);
        hold(app.axPlot, 'on');
        
        % Построить каждую строку как отдельную кривую
        numRows = size(data, 1);
        numCols = size(data, 2);
        fprintf('Построение графика: %d строк, %d столбцов\n', numRows, numCols);
        
        colors = lines(numRows); % Генерация цветов
        
        for row = 1:numRows
            xData = 1:numCols;
            yData = data(row, :);
            
            % Использовать метку строки, если доступна
            label = sprintf('Row %d', row);
            if isprop(app, 'rowLabels')
                try
                    if ~isempty(app.rowLabels) && ...
                       (iscell(app.rowLabels) || isnumeric(app.rowLabels))
                        if iscell(app.rowLabels)
                            if length(app.rowLabels) >= row && ~isempty(app.rowLabels{row})
                                label = char(string(app.rowLabels{row}));
                            end
                        elseif isnumeric(app.rowLabels) && length(app.rowLabels) >= row
                            label = sprintf('Row %.2f', app.rowLabels(row));
                        end
                    end
                catch
                    % Использовать значение по умолчанию
                end
            end
            
            plot(app.axPlot, xData, yData, '-o', ...
                'Color', colors(row, :), ...
                'DisplayName', label, ...
                'MarkerSize', 6);
            fprintf('  Построена кривая %d: %s\n', row, label);
        end
        
        hold(app.axPlot, 'off');
        
        % Настройка осей
        xlabel(app.axPlot, 'Index');
        ylabel(app.axPlot, 'Value');
        title(app.axPlot, 'Plot by Rows');
        legend(app.axPlot, 'show');
        grid(app.axPlot, 'on');
        
        fprintf('✓ График построен успешно\n');
        
    catch ME
        fprintf('Ошибка в plotByRows: %s\n', ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        
        if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
            uialert(app.UIFigure, sprintf('Ошибка построения графика: %s', ME.message), 'Ошибка');
        end
    end
end


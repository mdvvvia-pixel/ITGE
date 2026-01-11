%% PLOTBYCOLUMNS Строит график по столбцам
%   Режим "по столбцам": столбец 1 = X, остальные столбцы = Y (кривые)
%   Первая строка = метки (не участвует в данных)
%
%   Использование:
%       plotByColumns(app, data)
%
%   Параметры:
%       app - объект приложения TableGraphEditor
%       data - матрица данных (числовая, первая строка - метки)
%
%   Описание:
%       - Столбец 1 (строки 2:end) = координаты X для всех кривых
%       - Столбцы 2:end (строки 2:end) = значения Y (каждый столбец = отдельная кривая)
%       - Первая строка (столбцы 2:end) = метки для легенды
%       - Поддерживает выделенные столбцы через app.selectedColumns

function plotByColumns(app, data)
    % PLOTBYCOLUMNS Строит график по столбцам
    
    fprintf('plotByColumns вызван: size=[%s]\n', num2str(size(data)));
    
    % Проверить входные данные
    if isempty(data) || ~isnumeric(data)
        fprintf('⚠ plotByColumns: данные пусты или не числовые\n');
        return;
    end
    
    % Проверить минимальный размер данных
    if size(data, 1) < 2 || size(data, 2) < 2
        fprintf('⚠ plotByColumns: недостаточно данных (нужно минимум 2x2)\n');
        return;
    end
    
    % Проверить наличие компонента axPlot
    if ~isprop(app, 'axPlot') || ~isvalid(app.axPlot)
        fprintf('⚠ plotByColumns: axPlot не найден или не валиден\n');
        return;
    end
    
    try
        % Очистить график перед построением
        % ВАЖНО: cla очищает все графические объекты на axes
        cla(app.axPlot);
        % Сбросить состояние hold перед началом построения
        hold(app.axPlot, 'off');
        hold(app.axPlot, 'on');
        
        % Извлечь метки (первая строка, столбцы 2:end)
        columnLabels = data(1, 2:end);
        
        % Конвертировать метки в cell array строк
        labelsCell = {};
        if isnumeric(columnLabels)
            labelsCell = cellfun(@num2str, num2cell(columnLabels), 'UniformOutput', false);
        elseif iscell(columnLabels)
            labelsCell = cellfun(@(x) char(string(x)), columnLabels, 'UniformOutput', false);
        else
            labelsCell = cellstr(columnLabels);
        end
        
        % Сохранить метки в свойство app (безопасно)
        if isprop(app, 'columnLabels')
            try
                app.columnLabels = labelsCell;
            catch
                % Если не удалось сохранить в свойство, сохранить в UserData
                if ~isfield(app.UIFigure.UserData, 'appData')
                    app.UIFigure.UserData.appData = struct();
                end
                app.UIFigure.UserData.appData.columnLabels = labelsCell;
            end
        else
            % Сохранить в UserData, если свойство не существует
            if ~isfield(app.UIFigure.UserData, 'appData')
                app.UIFigure.UserData.appData = struct();
            end
            app.UIFigure.UserData.appData.columnLabels = labelsCell;
        end
        
        % Извлечь X координаты (столбец 1, строки 2:end)
        xData = data(2:end, 1);
        
        % Проверить, что X данные не пусты
        if isempty(xData)
            fprintf('⚠ plotByColumns: X координаты пусты\n');
            hold(app.axPlot, 'off');
            return;
        end
        
        % Найти валидные индексы для X (исключить NaN и Inf)
        validXIndices = isfinite(xData);
        
        if ~any(validXIndices)
            fprintf('⚠ plotByColumns: нет валидных X координат\n');
            hold(app.axPlot, 'off');
            return;
        end
        
        % Отфильтровать X координаты (оставить только валидные)
        xDataFiltered = xData(validXIndices);
        
        fprintf('X координаты: всего %d, валидных %d\n', length(xData), length(xDataFiltered));
        
        % Определить столбцы Y (выделенные или все)
        numCols = size(data, 2);
        selectedColumns = [];
        
        % Попробовать получить выделенные столбцы
        if isprop(app, 'selectedColumns')
            try
                selectedColumns = app.selectedColumns;
            catch
                selectedColumns = [];
            end
        end
        
        % Если нет выделения или выделение пустое, использовать все столбцы (кроме первого)
        if isempty(selectedColumns)
            yColumns = 2:numCols;
        else
            % Фильтровать выделенные столбцы: только те, что > 1 и <= numCols
            yColumns = selectedColumns(selectedColumns > 1 & selectedColumns <= numCols);
            if isempty(yColumns)
                % Если после фильтрации ничего не осталось, использовать все
                yColumns = 2:numCols;
            end
        end
        
        fprintf('Построение графика: X из столбца 1, Y из столбцов [%s]\n', num2str(yColumns));
        
        % Генерация цветов для кривых
        numCurves = length(yColumns);
        colors = lines(numCurves);
        
        % Построить кривые для каждого столбца Y
        curvesPlotted = 0;
        for i = 1:numCurves
            col = yColumns(i);
            
            % Извлечь Y данные (столбец, строки 2:end)
            yData = data(2:end, col);
            
            % Проверить, что Y данные не пусты
            if isempty(yData)
                fprintf('⚠ Пропуск столбца %d: данные пусты\n', col);
                continue;
            end
            
            % Найти валидные индексы для Y (исключить NaN и Inf)
            validYIndices = isfinite(yData);
            
            % Комбинировать валидные индексы: точка валидна, если валидны и X, и Y
            validIndices = validXIndices & validYIndices;
            
            if ~any(validIndices)
                fprintf('⚠ Пропуск столбца %d: нет валидных точек (все NaN/Inf)\n', col);
                continue;
            end
            
            % Отфильтровать данные: оставить только валидные пары (X, Y)
            % validIndices имеет размер исходного массива (2:end строк)
            xDataCurve = xData(validIndices);
            yDataCurve = yData(validIndices);
            
            % Проверить, что после фильтрации остались данные
            if isempty(xDataCurve) || isempty(yDataCurve)
                fprintf('⚠ Пропуск столбца %d: после фильтрации NaN данных не осталось\n', col);
                continue;
            end
            
            % Получить метку для легенды
            labelIdx = col - 1; % Индекс в метках (столбцы начинаются с 2)
            columnLabelsToUse = labelsCell; % Использовать локальную переменную
            if labelIdx <= length(columnLabelsToUse) && ~isempty(columnLabelsToUse{labelIdx})
                label = char(string(columnLabelsToUse{labelIdx}));
            else
                label = sprintf('Column %d', col);
            end
            
            % Построить кривую: точечный график с прямыми отрезками
            plot(app.axPlot, xDataCurve, yDataCurve, '-o', ...
                'Color', colors(i, :), ...
                'DisplayName', label, ...
                'MarkerSize', 6, ...
                'LineWidth', 1.5);
            
            curvesPlotted = curvesPlotted + 1;
            fprintf('  Построена кривая %d: %s (валидных точек: %d из %d)\n', ...
                curvesPlotted, label, length(xDataCurve), length(yData));
        end
        
        hold(app.axPlot, 'off');
        
        % Настройка осей
        xlabel(app.axPlot, 'X');
        ylabel(app.axPlot, 'Y');
        title(app.axPlot, 'Table-Graph Editor (By Columns)');
        legend(app.axPlot, 'show', 'Location', 'best');
        grid(app.axPlot, 'on');
        
        fprintf('✓ График построен успешно (%d кривых из %d запрошенных)\n', curvesPlotted, numCurves);
        
    catch ME
        fprintf('Ошибка в plotByColumns: %s\n', ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        
        if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
            uialert(app.UIFigure, ...
                sprintf('Ошибка построения графика: %s', ME.message), ...
                'Ошибка построения графика', ...
                'Icon', 'error');
        end
    end
end

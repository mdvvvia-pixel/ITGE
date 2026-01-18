%% PLOTBYCOLUMNS Строит график по столбцам
%   Новая модель:
%   - data = Y (MxN)
%   - X берется из A (RowNames): appData.rowNameValues (длина M)
%   - Метки легенды берутся из B (ColumnNames): app.columnLabels/appData.columnLabels (длина N)
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
    if size(data, 1) < 2 || size(data, 2) < 1
        fprintf('⚠ plotByColumns: недостаточно данных (нужно минимум 2x1)\n');
        return;
    end
    
    % Проверить наличие компонента axPlot
    if ~isprop(app, 'axPlot') || ~isvalid(app.axPlot)
        fprintf('⚠ plotByColumns: axPlot не найден или не валиден\n');
        return;
    end
    
    try
        % Очистить график перед построением
        % ВАЖНО: cla очищает все графические объекты на axes, но легенда может остаться
        % Явно удалить легенду перед очисткой
        try
            if ~isempty(app.axPlot.Legend) && isvalid(app.axPlot.Legend)
                delete(app.axPlot.Legend);
            end
        catch
            % Игнорировать ошибки при удалении легенды
        end
        
        % Очистить все графические объекты (включая линии, маркеры и т.д.)
        cla(app.axPlot);
        
        % ВАЖНО: Убедиться, что все графические объекты (линии) удалены
        % Иногда cla не удаляет все объекты, особенно если они были созданы недавно
        % Удаляем только линии, не трогая другие элементы (например, текстовые аннотации)
        children = app.axPlot.Children;
        if ~isempty(children)
            linesToDelete = [];
            for i = 1:length(children)
                if isa(children(i), 'matlab.graphics.chart.primitive.Line')
                    linesToDelete = [linesToDelete, i];
                end
            end
            if ~isempty(linesToDelete)
                fprintf('⚠ plotByColumns: после cla остались линии (%d), удаление...\n', length(linesToDelete));
                delete(children(linesToDelete));
            end
        end
        
        % Сбросить состояние hold перед началом построения
        hold(app.axPlot, 'off');
        hold(app.axPlot, 'on');
        
        % Получить метки столбцов (B) как cellstr
        labelsCell = {};
        try
            if isprop(app, 'columnLabels')
                labelsCell = app.columnLabels;
            end
        catch
        end
        if isempty(labelsCell) && isfield(app.UIFigure.UserData, 'appData') && ...
           isfield(app.UIFigure.UserData.appData, 'columnLabels')
            labelsCell = app.UIFigure.UserData.appData.columnLabels;
        end
        if isempty(labelsCell)
            labelsCell = cellfun(@num2str, num2cell(1:size(data, 2)), 'UniformOutput', false);
        end
        
        % Получить X координаты из A (RowNames)
        xData = [];
        if isfield(app.UIFigure.UserData, 'appData') && ...
           isfield(app.UIFigure.UserData.appData, 'rowNameValues')
            xData = app.UIFigure.UserData.appData.rowNameValues;
        end
        if isempty(xData)
            fprintf('⚠ plotByColumns: rowNameValues (A) не найдены\n');
            hold(app.axPlot, 'off');
            return;
        end
        xData = xData(:);
        if numel(xData) ~= size(data, 1)
            fprintf('⚠ plotByColumns: длина A (%d) не совпадает с числом строк Y (%d)\n', ...
                numel(xData), size(data, 1));
            hold(app.axPlot, 'off');
            return;
        end
        
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
        
        % Если нет выделения или выделение пустое, использовать все столбцы
        if isempty(selectedColumns)
            yColumns = 1:numCols;
        else
            % Фильтровать выделенные столбцы: только те, что в [1..numCols]
            yColumns = selectedColumns(selectedColumns >= 1 & selectedColumns <= numCols);
            if isempty(yColumns)
                % Если после фильтрации ничего не осталось, использовать все
                yColumns = 1:numCols;
            end
        end
        
        fprintf('Построение графика: X из A (RowNames), Y из столбцов [%s]\n', num2str(yColumns));
        
        % Генерация цветов для кривых
        numCurves = length(yColumns);
        colors = lines(numCurves);
        
        % Построить кривые для каждого столбца Y
        curvesPlotted = 0;
        for i = 1:numCurves
            col = yColumns(i);
            
            % Извлечь Y данные (столбец)
            yData = data(:, col);
            
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
            % validIndices имеет размер исходного массива (M строк)
            xDataCurve = xData(validIndices);
            yDataCurve = yData(validIndices);
            
            % Проверить, что после фильтрации остались данные
            if isempty(xDataCurve) || isempty(yDataCurve)
                fprintf('⚠ Пропуск столбца %d: после фильтрации NaN данных не осталось\n', col);
                continue;
            end
            
            % Получить метку для легенды
            labelIdx = col; % индексация 1..N
            columnLabelsToUse = labelsCell;
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
        
        % Настройка подписей осей/заголовка по требованиям
        if exist('updateAxesLabels', 'file') == 2
            updateAxesLabels(app, 'columns');
        else
            xlabel(app.axPlot, 'X');
            ylabel(app.axPlot, '');
            title(app.axPlot, '');
        end
        
        % ВАЖНО: Убедиться, что старая легенда удалена перед созданием новой
        % Это предотвращает накопление записей в легенде
        if ~isempty(app.axPlot.Legend)
            delete(app.axPlot.Legend);
        end
        
        % Создать новую легенду только если есть кривые
        if curvesPlotted > 0
            legend(app.axPlot, 'show', 'Location', 'best');
        end
        
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

%% PLOTBYROWS Строит график по строкам
%   Новая модель:
%   - data = Y (MxN)
%   - X берется из B (ColumnNames): appData.columnNameValues (длина N)
%   - Метки легенды берутся из A (RowNames): app.rowLabels/appData.rowLabels (длина M)
%
%   Использование:
%       plotByRows(app, data)
%
%   Параметры:
%       app - объект приложения TableGraphEditor
%       data - матрица данных (числовая, первый столбец - метки)
%
%   Описание:
%       - Строка 1 (столбцы 2:end) = координаты X для всех кривых
%       - Строки 2:end (столбцы 2:end) = значения Y (каждая строка = отдельная кривая)
%       - Первый столбец (строки 2:end) = метки для легенды
%       - Поддерживает выделенные строки через app.selectedRows

function plotByRows(app, data)
    % PLOTBYROWS Строит график по строкам
    
    fprintf('plotByRows вызван: size=[%s]\n', num2str(size(data)));
    
    % Проверить входные данные
    if isempty(data) || ~isnumeric(data)
        fprintf('⚠ plotByRows: данные пусты или не числовые\n');
        return;
    end
    
    % Проверить минимальный размер данных
    if size(data, 1) < 1 || size(data, 2) < 2
        fprintf('⚠ plotByRows: недостаточно данных (нужно минимум 1x2)\n');
        return;
    end
    
    % Проверить наличие компонента axPlot
    if ~isprop(app, 'axPlot') || ~isvalid(app.axPlot)
        fprintf('⚠ plotByRows: axPlot не найден или не валиден\n');
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
                fprintf('⚠ plotByRows: после cla остались линии (%d), удаление...\n', length(linesToDelete));
                delete(children(linesToDelete));
            end
        end
        
        % Сбросить состояние hold перед началом построения
        hold(app.axPlot, 'off');
        hold(app.axPlot, 'on');
        
        % Получить метки строк (A) как cellstr
        labelsCell = {};
        try
            if isprop(app, 'rowLabels')
                labelsCell = app.rowLabels;
            end
        catch
        end
        if isempty(labelsCell) && isfield(app.UIFigure.UserData, 'appData') && ...
           isfield(app.UIFigure.UserData.appData, 'rowLabels')
            labelsCell = app.UIFigure.UserData.appData.rowLabels;
        end
        if isempty(labelsCell)
            labelsCell = cellfun(@num2str, num2cell((1:size(data, 1))'), 'UniformOutput', false);
        end
        
        % Получить X координаты из B (ColumnNames)
        xData = [];
        if isfield(app.UIFigure.UserData, 'appData') && ...
           isfield(app.UIFigure.UserData.appData, 'columnNameValues')
            xData = app.UIFigure.UserData.appData.columnNameValues;
        end
        if isempty(xData)
            fprintf('⚠ plotByRows: columnNameValues (B) не найдены\n');
            hold(app.axPlot, 'off');
            return;
        end
        xData = xData(:).';
        if numel(xData) ~= size(data, 2)
            fprintf('⚠ plotByRows: длина B (%d) не совпадает с числом столбцов Y (%d)\n', ...
                numel(xData), size(data, 2));
            hold(app.axPlot, 'off');
            return;
        end
        
        % Проверить, что X данные не пусты
        if isempty(xData)
            fprintf('⚠ plotByRows: X координаты пусты\n');
            hold(app.axPlot, 'off');
            return;
        end
        
        % Найти валидные индексы для X (исключить NaN и Inf)
        validXIndices = isfinite(xData);
        
        if ~any(validXIndices)
            fprintf('⚠ plotByRows: нет валидных X координат\n');
            hold(app.axPlot, 'off');
            return;
        end
        
        % Отфильтровать X координаты (оставить только валидные)
        xDataFiltered = xData(validXIndices);
        
        fprintf('X координаты: всего %d, валидных %d\n', length(xData), length(xDataFiltered));
        
        % Определить строки Y (выделенные или все)
        numRows = size(data, 1);
        selectedRows = [];
        
        % Попробовать получить выделенные строки
        if isprop(app, 'selectedRows')
            try
                selectedRows = app.selectedRows;
            catch
                selectedRows = [];
            end
        end
        
        % Если нет выделения или выделение пустое, использовать все строки
        if isempty(selectedRows)
            yRows = 1:numRows;
        else
            % Фильтровать выделенные строки: только те, что в [1..numRows]
            yRows = selectedRows(selectedRows >= 1 & selectedRows <= numRows);
            if isempty(yRows)
                % Если после фильтрации ничего не осталось, использовать все
                yRows = 1:numRows;
            end
        end
        
        fprintf('Построение графика: X из B (ColumnNames), Y из строк [%s]\n', num2str(yRows));
        
        % Генерация цветов для кривых
        numCurves = length(yRows);
        colors = lines(numCurves);
        
        % Построить кривые для каждой строки Y
        curvesPlotted = 0;
        for i = 1:numCurves
            row = yRows(i);
            
            % Извлечь Y данные (строка)
            yData = data(row, :);
            
            % Проверить, что Y данные не пусты
            if isempty(yData)
                fprintf('⚠ Пропуск строки %d: данные пусты\n', row);
                continue;
            end
            
            % Найти валидные индексы для Y (исключить NaN и Inf)
            validYIndices = isfinite(yData);
            
            % Комбинировать валидные индексы: точка валидна, если валидны и X, и Y
            validIndices = validXIndices & validYIndices;
            
            if ~any(validIndices)
                fprintf('⚠ Пропуск строки %d: нет валидных точек (все NaN/Inf)\n', row);
                continue;
            end
            
            % Отфильтровать данные: оставить только валидные пары (X, Y)
            % validIndices имеет размер исходного массива (N столбцов)
            xDataCurve = xData(validIndices);
            yDataCurve = yData(validIndices);
            
            % Проверить, что после фильтрации остались данные
            if isempty(xDataCurve) || isempty(yDataCurve)
                fprintf('⚠ Пропуск строки %d: после фильтрации NaN данных не осталось\n', row);
                continue;
            end
            
            % Получить метку для легенды
            labelIdx = row; % индексация 1..M
            rowLabelsToUse = labelsCell;
            if labelIdx <= length(rowLabelsToUse) && ~isempty(rowLabelsToUse{labelIdx})
                label = char(string(rowLabelsToUse{labelIdx}));
            else
                label = sprintf('Row %d', row);
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
            updateAxesLabels(app, 'rows');
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
        fprintf('Ошибка в plotByRows: %s\n', ME.message);
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

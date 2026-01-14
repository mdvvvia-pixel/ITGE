%% PLOTBYROWS Строит график по строкам
%   Режим "по строкам": строка 1 = X, остальные строки = Y (кривые)
%   Первый столбец = метки (не участвует в данных)
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
    if size(data, 1) < 2 || size(data, 2) < 2
        fprintf('⚠ plotByRows: недостаточно данных (нужно минимум 2x2)\n');
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
        
        % Извлечь метки (первый столбец, строки 2:end)
        rowLabels = data(2:end, 1);
        
        % Конвертировать метки в cell array строк
        labelsCell = {};
        if isnumeric(rowLabels)
            labelsCell = cellfun(@num2str, num2cell(rowLabels), 'UniformOutput', false);
        elseif iscell(rowLabels)
            labelsCell = cellfun(@(x) char(string(x)), rowLabels, 'UniformOutput', false);
        else
            labelsCell = cellstr(rowLabels);
        end
        
        % Сохранить метки в свойство app (безопасно)
        if isprop(app, 'rowLabels')
            try
                app.rowLabels = labelsCell;
            catch
                % Если не удалось сохранить в свойство, сохранить в UserData
                if ~isfield(app.UIFigure.UserData, 'appData')
                    app.UIFigure.UserData.appData = struct();
                end
                app.UIFigure.UserData.appData.rowLabels = labelsCell;
            end
        else
            % Сохранить в UserData, если свойство не существует
            if ~isfield(app.UIFigure.UserData, 'appData')
                app.UIFigure.UserData.appData = struct();
            end
            app.UIFigure.UserData.appData.rowLabels = labelsCell;
        end
        
        % Извлечь X координаты (строка 1, столбцы 2:end)
        xData = data(1, 2:end);
        
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
        
        % Если нет выделения или выделение пустое, использовать все строки (кроме первой)
        if isempty(selectedRows)
            yRows = 2:numRows;
        else
            % Фильтровать выделенные строки: только те, что > 1 и <= numRows
            yRows = selectedRows(selectedRows > 1 & selectedRows <= numRows);
            if isempty(yRows)
                % Если после фильтрации ничего не осталось, использовать все
                yRows = 2:numRows;
            end
        end
        
        fprintf('Построение графика: X из строки 1, Y из строк [%s]\n', num2str(yRows));
        
        % Генерация цветов для кривых
        numCurves = length(yRows);
        colors = lines(numCurves);
        
        % Построить кривые для каждой строки Y
        curvesPlotted = 0;
        for i = 1:numCurves
            row = yRows(i);
            
            % Извлечь Y данные (строка, столбцы 2:end)
            yData = data(row, 2:end);
            
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
            % validIndices имеет размер исходного массива (2:end столбцов)
            xDataCurve = xData(validIndices);
            yDataCurve = yData(validIndices);
            
            % Проверить, что после фильтрации остались данные
            if isempty(xDataCurve) || isempty(yDataCurve)
                fprintf('⚠ Пропуск строки %d: после фильтрации NaN данных не осталось\n', row);
                continue;
            end
            
            % Получить метку для легенды
            labelIdx = row - 1; % Индекс в метках (строки начинаются с 2)
            rowLabelsToUse = labelsCell; % Использовать локальную переменную
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
        
        % Настройка осей
        xlabel(app.axPlot, 'X');
        ylabel(app.axPlot, 'Y');
        title(app.axPlot, 'Table-Graph Editor (By Rows)');
        
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

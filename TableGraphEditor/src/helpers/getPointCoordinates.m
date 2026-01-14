%% GETPOINTCOORDINATES Получить координаты точки из данных
%   Возвращает координаты [x, y] точки из currentData на основе индекса точки
%
%   Использование:
%       coords = getPointCoordinates(app, pointIndex)
%
%   Параметры:
%       app - объект приложения TableGraphEditor
%       pointIndex - [curveIndex, pointIndex] индекс точки на графике
%                    curveIndex - индекс кривой (линии) на графике
%                    pointIndex - индекс точки в кривой
%
%   Возвращает:
%       coords - [x, y] координаты точки в координатах данных
%
%   Описание:
%       - Определяет координаты точки из currentData на основе режима построения
%       - Поддерживает режимы "по столбцам" и "по строкам"
%       - Учитывает выделенные столбцы/строки
%       - Аналогично логике в updateDataFromGraph, но только чтение данных
%
%   Автор: AI Assistant
%   Дата: 2026-01-10
%   Версия: 1.0.0

function coords = getPointCoordinates(app, pointIndex)
    % GETPOINTCOORDINATES Получить координаты точки из данных
    
    % Проверить входные данные
    if isempty(pointIndex) || length(pointIndex) < 2
        fprintf('⚠ getPointCoordinates: некорректный pointIndex\n');
        coords = [0, 0];
        return;
    end
    
    curveIdx = pointIndex(1);
    pointIdx = pointIndex(2);
    
    % Получить текущие данные (безопасно)
    currentData = [];
    if isprop(app, 'currentData')
        try
            currentData = app.currentData;
        catch
            if isfield(app.UIFigure.UserData, 'appData') && ...
               isfield(app.UIFigure.UserData.appData, 'currentData')
                currentData = app.UIFigure.UserData.appData.currentData;
            end
        end
    else
        if isfield(app.UIFigure.UserData, 'appData') && ...
           isfield(app.UIFigure.UserData.appData, 'currentData')
            currentData = app.UIFigure.UserData.appData.currentData;
        end
    end
    
    if isempty(currentData)
        fprintf('⚠ getPointCoordinates: currentData пуст\n');
        coords = [0, 0];
        return;
    end
    
    % Получить режим построения графика
    plotType = 'columns';
    if isprop(app, 'currentPlotType')
        try
            plotType = app.currentPlotType;
        catch
            plotType = 'columns';
        end
    end
    
    % Получить выделенные столбцы/строки
    selectedColumns = [];
    selectedRows = [];
    
    if isprop(app, 'selectedColumns')
        try
            selectedColumns = app.selectedColumns;
        catch
            selectedColumns = [];
        end
    end
    
    if isprop(app, 'selectedRows')
        try
            selectedRows = app.selectedRows;
        catch
            selectedRows = [];
        end
    end
    
    try
        % ВАЖНО: curveIdx из findClosestPoint - это индекс в app.axPlot.Children
        % (обратный порядок: последняя нарисованная кривая = Children(1))
        % Нужно получить координаты напрямую из графика, а не через преобразование в столбцы
        
        % Проверить, что график существует
        if ~isprop(app, 'axPlot') || ~isvalid(app.axPlot)
            fprintf('⚠ getPointCoordinates: axPlot не найден или не валиден\n');
            coords = [0, 0];
            return;
        end
        
        % Получить все кривые на графике
        children = app.axPlot.Children;
        
        % Проверить, что curveIdx валиден
        if curveIdx < 1 || curveIdx > length(children)
            fprintf('⚠ getPointCoordinates: curveIdx=%d выходит за пределы (всего кривых: %d)\n', ...
                curveIdx, length(children));
            coords = [0, 0];
            return;
        end
        
        % Получить кривую по индексу
        line = children(curveIdx);
        
        if ~isa(line, 'matlab.graphics.chart.primitive.Line')
            fprintf('⚠ getPointCoordinates: элемент %d не является линией\n', curveIdx);
            coords = [0, 0];
            return;
        end
        
        % Получить данные кривой
        xData = line.XData;
        yData = line.YData;
        
        % Проверить, что данные не пусты
        if isempty(xData) || isempty(yData) || length(xData) ~= length(yData)
            fprintf('⚠ getPointCoordinates: данные кривой пусты или несовместимы\n');
            coords = [0, 0];
            return;
        end
        
        % Проверить, что pointIdx валиден
        if pointIdx < 1 || pointIdx > length(xData)
            fprintf('⚠ getPointCoordinates: pointIdx=%d выходит за пределы (всего точек: %d)\n', ...
                pointIdx, length(xData));
            coords = [0, 0];
            return;
        end
        
        % Получить координаты напрямую из графика
        xCoord = xData(pointIdx);
        yCoord = yData(pointIdx);
        
        fprintf('getPointCoordinates: кривая %d, точка %d, координаты [%.4f, %.4f]\n', ...
            curveIdx, pointIdx, xCoord, yCoord);
            
        
        coords = [xCoord, yCoord];
        
        % Проверить валидность координат
        if ~isfinite(coords(1)) || ~isfinite(coords(2))
            fprintf('⚠ getPointCoordinates: координаты содержат NaN/Inf\n');
            coords = [0, 0];
        end
        
    catch ME
        fprintf('Ошибка в getPointCoordinates: %s\n', ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        coords = [0, 0];
    end
end


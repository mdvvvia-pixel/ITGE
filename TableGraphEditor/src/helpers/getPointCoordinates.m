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
        % Определить координаты в зависимости от режима
        if strcmp(plotType, 'columns')
            % Режим "по столбцам"
            % Структура данных:
            % - Столбец 1 (строки 2:end) = X координаты
            % - Столбцы 2:end (строки 2:end) = Y координаты (каждый столбец = кривая)
            % - Первая строка = метки (не участвует в данных)
            
            % Определить столбец Y
            numCols = size(currentData, 2);
            if isempty(selectedColumns)
                allCols = 2:numCols;
                if curveIdx <= length(allCols)
                    colY = allCols(curveIdx);
                else
                    fprintf('⚠ getPointCoordinates: curveIdx=%d выходит за пределы\n', curveIdx);
                    coords = [0, 0];
                    return;
                end
            else
                validCols = selectedColumns(selectedColumns > 1 & selectedColumns <= numCols);
                if isempty(validCols)
                    allCols = 2:numCols;
                    if curveIdx <= length(allCols)
                        colY = allCols(curveIdx);
                    else
                        fprintf('⚠ getPointCoordinates: curveIdx=%d выходит за пределы\n', curveIdx);
                        coords = [0, 0];
                        return;
                    end
                else
                    if curveIdx <= length(validCols)
                        colY = validCols(curveIdx);
                    else
                        fprintf('⚠ getPointCoordinates: curveIdx=%d выходит за пределы\n', curveIdx);
                        coords = [0, 0];
                        return;
                    end
                end
            end
            
            % Определить строку данных
            xData = currentData(2:end, 1);
            validXIndices = isfinite(xData);
            validIndicesList = find(validXIndices);
            
            if pointIdx > length(validIndicesList)
                fprintf('⚠ getPointCoordinates: pointIdx=%d выходит за пределы\n', pointIdx);
                coords = [0, 0];
                return;
            end
            
            dataRowIdx = validIndicesList(pointIdx) + 1; % +1 т.к. первая строка - метки
            
            % Проверить границы
            if dataRowIdx > size(currentData, 1) || colY > size(currentData, 2)
                fprintf('⚠ getPointCoordinates: индексы выходят за пределы данных\n');
                coords = [0, 0];
                return;
            end
            
            % Получить координаты
            xCoord = currentData(dataRowIdx, 1);
            yCoord = currentData(dataRowIdx, colY);
            
        else
            % Режим "по строкам"
            % Структура данных:
            % - Строка 1 (столбцы 2:end) = X координаты
            % - Строки 2:end (столбцы 2:end) = Y координаты (каждая строка = кривая)
            % - Первый столбец = метки (не участвует в данных)
            
            % Определить строку Y
            numRows = size(currentData, 1);
            if isempty(selectedRows)
                allRows = 2:numRows;
                if curveIdx <= length(allRows)
                    rowY = allRows(curveIdx);
                else
                    fprintf('⚠ getPointCoordinates: curveIdx=%d выходит за пределы\n', curveIdx);
                    coords = [0, 0];
                    return;
                end
            else
                validRows = selectedRows(selectedRows > 1 & selectedRows <= numRows);
                if isempty(validRows)
                    allRows = 2:numRows;
                    if curveIdx <= length(allRows)
                        rowY = allRows(curveIdx);
                    else
                        fprintf('⚠ getPointCoordinates: curveIdx=%d выходит за пределы\n', curveIdx);
                        coords = [0, 0];
                        return;
                    end
                else
                    if curveIdx <= length(validRows)
                        rowY = validRows(curveIdx);
                    else
                        fprintf('⚠ getPointCoordinates: curveIdx=%d выходит за пределы\n', curveIdx);
                        coords = [0, 0];
                        return;
                    end
                end
            end
            
            % Определить столбец данных
            xData = currentData(1, 2:end);
            validXIndices = isfinite(xData);
            validIndicesList = find(validXIndices);
            
            if pointIdx > length(validIndicesList)
                fprintf('⚠ getPointCoordinates: pointIdx=%d выходит за пределы\n', pointIdx);
                coords = [0, 0];
                return;
            end
            
            dataColIdx = validIndicesList(pointIdx) + 1; % +1 т.к. первый столбец - метки
            
            % Проверить границы
            if rowY > size(currentData, 1) || dataColIdx > size(currentData, 2)
                fprintf('⚠ getPointCoordinates: индексы выходят за пределы данных\n');
                coords = [0, 0];
                return;
            end
            
            % Получить координаты
            xCoord = currentData(1, dataColIdx);
            yCoord = currentData(rowY, dataColIdx);
        end
        
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


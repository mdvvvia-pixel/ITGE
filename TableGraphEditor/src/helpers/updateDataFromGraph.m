%% UPDATEDATAFROMGRAPH Обновить данные из графика при перетаскивании точки
%   Обновляет данные в currentData на основе новой позиции точки на графике
%
%   Использование:
%       updateDataFromGraph(app, pointIndex, newPosition)
%
%   Параметры:
%       app - объект приложения TableGraphEditor
%       pointIndex - [curveIndex, pointIndex] индекс точки на графике
%                    curveIndex - индекс кривой (линии) на графике
%                    pointIndex - индекс точки в кривой
%       newPosition - [x, y] новые координаты точки в координатах данных
%
%   Описание:
%       - Определяет, какая ячейка в currentData соответствует точке
%       - Обновляет X и Y координаты в зависимости от режима (columns/rows)
%       - Учитывает выделенные столбцы/строки
%       - Режим редактирования: XY (свободное перемещение)

function updateDataFromGraph(app, pointIndex, newPosition)
    % UPDATEDATAFROMGRAPH Обновить данные из графика
    
    fprintf('updateDataFromGraph вызван: pointIndex=[%s], newPosition=[%s]\n', ...
        mat2str(pointIndex), mat2str(newPosition));
    
    % Проверить входные данные
    if isempty(pointIndex) || length(pointIndex) < 2
        fprintf('⚠ updateDataFromGraph: некорректный pointIndex\n');
        return;
    end
    
    if isempty(newPosition) || length(newPosition) < 2
        fprintf('⚠ updateDataFromGraph: некорректные координаты\n');
        return;
    end
    
    % Проверить валидность координат
    if ~isfinite(newPosition(1)) || ~isfinite(newPosition(2))
        fprintf('⚠ updateDataFromGraph: координаты содержат NaN или Inf\n');
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
        fprintf('⚠ updateDataFromGraph: currentData пуст\n');
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
        % Определить, какая это кривая в зависимости от режима
        if strcmp(plotType, 'columns')
            % Режим "по столбцам"
            % Структура данных:
            % - Столбец 1 (строки 2:end) = X координаты
            % - Столбцы 2:end (строки 2:end) = Y координаты (каждый столбец = кривая)
            % - Первая строка = метки (не участвует в данных)
            
            % Определить столбец Y
            numCols = size(currentData, 2);
            if isempty(selectedColumns)
                % Нет выделения - использовать все столбцы (кроме первого)
                allCols = 2:numCols;
                if curveIdx <= length(allCols)
                    colY = allCols(curveIdx);
                else
                    fprintf('⚠ updateDataFromGraph: curveIdx=%d выходит за пределы (всего %d кривых)\n', ...
                        curveIdx, length(allCols));
                    return;
                end
            else
                % Использовать выделенные столбцы
                % Фильтровать: только столбцы > 1
                validCols = selectedColumns(selectedColumns > 1 & selectedColumns <= numCols);
                if isempty(validCols)
                    % Если после фильтрации ничего не осталось, использовать все
                    allCols = 2:numCols;
                    if curveIdx <= length(allCols)
                        colY = allCols(curveIdx);
                    else
                        fprintf('⚠ updateDataFromGraph: curveIdx=%d выходит за пределы\n', curveIdx);
                        return;
                    end
                else
                    if curveIdx <= length(validCols)
                        colY = validCols(curveIdx);
                    else
                        fprintf('⚠ updateDataFromGraph: curveIdx=%d выходит за пределы выделенных столбцов\n', curveIdx);
                        return;
                    end
                end
            end
            
            % Определить строку данных
            % pointIdx - это индекс точки в кривой (после фильтрации NaN)
            % Нужно найти соответствующую строку в currentData
            % Для этого нужно получить исходные данные до фильтрации
            
            % Получить X данные из столбца 1
            xData = currentData(2:end, 1);
            
            % Найти валидные индексы (исключить NaN и Inf)
            validXIndices = isfinite(xData);
            
            % Найти индекс строки в исходных данных
            validIndicesList = find(validXIndices);
            if pointIdx > length(validIndicesList)
                fprintf('⚠ updateDataFromGraph: pointIdx=%d выходит за пределы валидных точек\n', pointIdx);
                return;
            end
            
            % Индекс строки в currentData (с учетом первой строки - метки)
            dataRowIdx = validIndicesList(pointIdx) + 1; % +1 т.к. первая строка - метки
            
            % Проверить границы
            if dataRowIdx > size(currentData, 1) || colY > size(currentData, 2)
                fprintf('⚠ updateDataFromGraph: индексы выходят за пределы данных\n');
                return;
            end
            
            % Обновить данные
            % X координата: столбец 1, строка dataRowIdx
            % Y координата: столбец colY, строка dataRowIdx
            currentData(dataRowIdx, 1) = newPosition(1); % X
            currentData(dataRowIdx, colY) = newPosition(2); % Y
            
            fprintf('✓ Обновлены данные: строка %d, столбец X=1, столбец Y=%d, новые координаты [%.4f, %.4f]\n', ...
                dataRowIdx, colY, newPosition(1), newPosition(2));
            
        else
            % Режим "по строкам"
            % Структура данных:
            % - Строка 1 (столбцы 2:end) = X координаты
            % - Строки 2:end (столбцы 2:end) = Y координаты (каждая строка = кривая)
            % - Первый столбец = метки (не участвует в данных)
            
            % Определить строку Y
            numRows = size(currentData, 1);
            if isempty(selectedRows)
                % Нет выделения - использовать все строки (кроме первой)
                allRows = 2:numRows;
                if curveIdx <= length(allRows)
                    rowY = allRows(curveIdx);
                else
                    fprintf('⚠ updateDataFromGraph: curveIdx=%d выходит за пределы (всего %d кривых)\n', ...
                        curveIdx, length(allRows));
                    return;
                end
            else
                % Использовать выделенные строки
                % Фильтровать: только строки > 1
                validRows = selectedRows(selectedRows > 1 & selectedRows <= numRows);
                if isempty(validRows)
                    % Если после фильтрации ничего не осталось, использовать все
                    allRows = 2:numRows;
                    if curveIdx <= length(allRows)
                        rowY = allRows(curveIdx);
                    else
                        fprintf('⚠ updateDataFromGraph: curveIdx=%d выходит за пределы\n', curveIdx);
                        return;
                    end
                else
                    if curveIdx <= length(validRows)
                        rowY = validRows(curveIdx);
                    else
                        fprintf('⚠ updateDataFromGraph: curveIdx=%d выходит за пределы выделенных строк\n', curveIdx);
                        return;
                    end
                end
            end
            
            % Определить столбец данных
            % pointIdx - это индекс точки в кривой (после фильтрации NaN)
            % Нужно найти соответствующий столбец в currentData
            
            % Получить X данные из строки 1
            xData = currentData(1, 2:end);
            
            % Найти валидные индексы (исключить NaN и Inf)
            validXIndices = isfinite(xData);
            
            % Найти индекс столбца в исходных данных
            validIndicesList = find(validXIndices);
            if pointIdx > length(validIndicesList)
                fprintf('⚠ updateDataFromGraph: pointIdx=%d выходит за пределы валидных точек\n', pointIdx);
                return;
            end
            
            % Индекс столбца в currentData (с учетом первого столбца - метки)
            dataColIdx = validIndicesList(pointIdx) + 1; % +1 т.к. первый столбец - метки
            
            % Проверить границы
            if rowY > size(currentData, 1) || dataColIdx > size(currentData, 2)
                fprintf('⚠ updateDataFromGraph: индексы выходят за пределы данных\n');
                return;
            end
            
            % Обновить данные
            % X координата: строка 1, столбец dataColIdx
            % Y координата: строка rowY, столбец dataColIdx
            currentData(1, dataColIdx) = newPosition(1); % X
            currentData(rowY, dataColIdx) = newPosition(2); % Y
            
            fprintf('✓ Обновлены данные: строка X=1, строка Y=%d, столбец %d, новые координаты [%.4f, %.4f]\n', ...
                rowY, dataColIdx, newPosition(1), newPosition(2));
        end
        
        % Сохранить обновленные данные обратно в app (безопасно)
        if isprop(app, 'currentData')
            try
                app.currentData = currentData;
            catch
                % Если не удалось сохранить в свойство, сохранить в UserData
                if ~isfield(app.UIFigure.UserData, 'appData')
                    app.UIFigure.UserData.appData = struct();
                end
                app.UIFigure.UserData.appData.currentData = currentData;
            end
        else
            % Сохранить в UserData, если свойство не существует
            if ~isfield(app.UIFigure.UserData, 'appData')
                app.UIFigure.UserData.appData = struct();
            end
            app.UIFigure.UserData.appData.currentData = currentData;
        end
        
    catch ME
        fprintf('Ошибка в updateDataFromGraph: %s\n', ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end


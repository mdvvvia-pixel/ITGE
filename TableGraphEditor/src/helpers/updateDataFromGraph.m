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
%       - Учитывает режим редактирования (X/Y/XY):
%         * 'X' - обновляет только X, сохраняет исходную Y
%         * 'Y' - обновляет только Y, сохраняет исходную X
%         * 'XY' - обновляет обе координаты (свободное перемещение)

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
            % ВАЖНО: Порядок Children в MATLAB обратный порядку построения
            % Когда строятся кривые для столбцов [2, 3, 4]:
            % - Сначала строится Column 2 → попадает в Children(3) (последний)
            % - Затем Column 3 → попадает в Children(2) (средний)
            % - Затем Column 4 → попадает в Children(1) (первый, верхний)
            % Поэтому curveIdx = 1 → Children(1) = Column 4 (последний столбец)
            % Для преобразования используем обратное индексирование:
            % colY = yColumns(length(yColumns) - curveIdx + 1)
            
            numCols = size(currentData, 2);
            if isempty(selectedColumns)
                % Нет выделения - использовать все столбцы (кроме первого)
                allCols = 2:numCols;
                if curveIdx <= length(allCols)
                    % Обратное преобразование: curveIdx в Children → индекс в allCols
                    colIdx = length(allCols) - curveIdx + 1;
                    colY = allCols(colIdx);
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
                        % Обратное преобразование
                        colIdx = length(allCols) - curveIdx + 1;
                        colY = allCols(colIdx);
                    else
                        fprintf('⚠ updateDataFromGraph: curveIdx=%d выходит за пределы\n', curveIdx);
                        return;
                    end
                else
                    if curveIdx <= length(validCols)
                        % Обратное преобразование
                        colIdx = length(validCols) - curveIdx + 1;
                        colY = validCols(colIdx);
                    else
                        fprintf('⚠ updateDataFromGraph: curveIdx=%d выходит за пределы выделенных столбцов\n', curveIdx);
                        return;
                    end
                end
            end
            
            % Определить строку данных
            % ВАЖНО: В режиме 'Y' координата X не изменяется, поэтому мы можем использовать
            % исходную координату X для поиска правильной строки. Это более надежно, чем
            % использование pointIdx, который может измениться при перетаскивании.
            
            % Попытаться получить исходную координату X из dragStartCoordinates
            originalX = [];
            if isprop(app, 'dragStartCoordinates')
                try
                    dragCoords = app.dragStartCoordinates;
                    if ~isempty(dragCoords) && length(dragCoords) >= 1 && isfinite(dragCoords(1))
                        originalX = dragCoords(1);
                    end
                catch
                    if isfield(app.UIFigure.UserData, 'appData') && ...
                       isfield(app.UIFigure.UserData.appData, 'dragStartCoordinates')
                        dragCoords = app.UIFigure.UserData.appData.dragStartCoordinates;
                        if ~isempty(dragCoords) && length(dragCoords) >= 1 && isfinite(dragCoords(1))
                            originalX = dragCoords(1);
                        end
                    end
                end
            else
                if isfield(app.UIFigure.UserData, 'appData') && ...
                   isfield(app.UIFigure.UserData.appData, 'dragStartCoordinates')
                    dragCoords = app.UIFigure.UserData.appData.dragStartCoordinates;
                    if ~isempty(dragCoords) && length(dragCoords) >= 1 && isfinite(dragCoords(1))
                        originalX = dragCoords(1);
                    end
                end
            end
            
            % Если исходная координата X не найдена, использовать pointIdx как fallback
            if isempty(originalX)
                fprintf('⚠ updateDataFromGraph: исходная координата X не найдена, используется pointIdx\n');
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
            else
                % Использовать исходную координату X для поиска правильной строки
                % Это более надежно, так как координата X не изменяется в режиме 'Y'
                xData = currentData(2:end, 1);
                
                % Найти строку с такой же координатой X (с учетом погрешности округления)
                tolerance = 1e-10;
                dataRowIdx = [];
                for row = 2:size(currentData, 1)
                    if isfinite(xData(row-1)) && abs(xData(row-1) - originalX) < tolerance
                        % Проверить, что это правильный столбец Y (для дополнительной проверки)
                        if isfinite(currentData(row, colY))
                            dataRowIdx = row;
                            fprintf('✓ Найдена строка %d по исходной координате X=%.4f (текущая X=%.4f)\n', ...
                                row, originalX, xData(row-1));
                            break;
                        end
                    end
                end
                
                % Если не найдена строка по исходной координате X, использовать pointIdx как fallback
                if isempty(dataRowIdx)
                    fprintf('⚠ updateDataFromGraph: не найдена строка по исходной координате X=%.4f, используется pointIdx\n', originalX);
                    validXIndices = isfinite(xData);
                    validIndicesList = find(validXIndices);
                    if pointIdx > length(validIndicesList)
                        fprintf('⚠ updateDataFromGraph: pointIdx=%d выходит за пределы валидных точек\n', pointIdx);
                        return;
                    end
                    dataRowIdx = validIndicesList(pointIdx) + 1;
                end
            end
            
            % Проверить границы
            if dataRowIdx > size(currentData, 1) || colY > size(currentData, 2)
                fprintf('⚠ updateDataFromGraph: индексы выходят за пределы данных\n');
                return;
            end
            
            % Получить режим редактирования для применения ограничений
            editMode = 'Y';  % По умолчанию 'Y'
            if isprop(app, 'editMode')
                try
                    editMode = app.editMode;
                catch
                    if isfield(app.UIFigure.UserData, 'appData') && ...
                       isfield(app.UIFigure.UserData.appData, 'editMode')
                        editMode = app.UIFigure.UserData.appData.editMode;
                    end
                end
            else
                if isfield(app.UIFigure.UserData, 'appData') && ...
                   isfield(app.UIFigure.UserData.appData, 'editMode')
                    editMode = app.UIFigure.UserData.appData.editMode;
                end
            end
            
            % Проверить валидность режима
            if ~ischar(editMode) && ~isstring(editMode)
                editMode = 'Y';
            end
            editMode = upper(char(editMode));
            
            % Обновить данные с учетом режима редактирования
            % ВАЖНО: В режиме 'Y' координата X НЕ должна изменяться
            % В режиме 'X' координата Y НЕ должна изменяться
            % В режиме 'XY' обе координаты изменяются
            switch editMode
                case 'Y'
                    % Режим Y: изменяется только Y, X остается исходным
                    % Сохранить исходную координату X из данных
                    originalX = currentData(dataRowIdx, 1);
                    
                    % ВАЖНО: Дополнительная проверка - убедиться, что мы обновляем правильную строку
                    % Если исходная координата X из dragStartCoordinates не совпадает с текущей,
                    % это может означать, что мы обновляем не ту строку
                    if ~isempty(originalX) && isfinite(originalX)
                        % Получить исходную координату X из dragStartCoordinates для проверки
                        dragStartX = [];
                        if isprop(app, 'dragStartCoordinates')
                            try
                                dragCoords = app.dragStartCoordinates;
                                if ~isempty(dragCoords) && length(dragCoords) >= 1 && isfinite(dragCoords(1))
                                    dragStartX = dragCoords(1);
                                end
                            catch
                                if isfield(app.UIFigure.UserData, 'appData') && ...
                                   isfield(app.UIFigure.UserData.appData, 'dragStartCoordinates')
                                    dragCoords = app.UIFigure.UserData.appData.dragStartCoordinates;
                                    if ~isempty(dragCoords) && length(dragCoords) >= 1 && isfinite(dragCoords(1))
                                        dragStartX = dragCoords(1);
                                    end
                                end
                            end
                        else
                            if isfield(app.UIFigure.UserData, 'appData') && ...
                               isfield(app.UIFigure.UserData.appData, 'dragStartCoordinates')
                                dragCoords = app.UIFigure.UserData.appData.dragStartCoordinates;
                                if ~isempty(dragCoords) && length(dragCoords) >= 1 && isfinite(dragCoords(1))
                                    dragStartX = dragCoords(1);
                                end
                            end
                        end
                        
                        % Проверить совпадение координат X (с учетом погрешности)
                        if ~isempty(dragStartX) && abs(originalX - dragStartX) > 1e-10
                            fprintf('⚠ Предупреждение: координата X в данных (%.4f) не совпадает с исходной (%.4f)\n', ...
                                originalX, dragStartX);
                            % Использовать исходную координату X из dragStartCoordinates
                            originalX = dragStartX;
                        end
                    end
                    
                    currentData(dataRowIdx, 1) = originalX; % X - сохранить исходную
                    currentData(dataRowIdx, colY) = newPosition(2); % Y - обновить
                    fprintf('✓ Обновлены данные (режим Y): строка %d, столбец X=1 (сохранен: %.4f), столбец Y=%d (новый: %.4f)\n', ...
                        dataRowIdx, originalX, colY, newPosition(2));
                    
                case 'X'
                    % Режим X: изменяется только X, Y остается исходным
                    % Сохранить исходную координату Y из данных
                    originalY = currentData(dataRowIdx, colY);
                    newX = newPosition(1);
                    
                    % ВАЖНО: Проверить, не создаст ли обновление X дубликаты
                    % Если для того же столбца Y уже есть точка с таким X, удалить старые дубликаты
                    xDataAll = currentData(2:end, 1);
                    yDataCol = currentData(2:end, colY);
                    
                    % Найти все строки с таким же X для того же столбца Y (кроме текущей)
                    duplicateRows = [];
                    for row = 2:size(currentData, 1)
                        if row ~= dataRowIdx && isfinite(xDataAll(row-1)) && isfinite(yDataCol(row-1))
                            % Проверить, совпадает ли X (с учетом погрешности округления)
                            if abs(xDataAll(row-1) - newX) < 1e-10
                                duplicateRows = [duplicateRows, row];
                            end
                        end
                    end
                    
                    % Удалить дубликаты (установить NaN)
                    if ~isempty(duplicateRows)
                        fprintf('⚠ Найдены дубликаты по X=%.4f для столбца Y=%d в строках [%s], удаление...\n', ...
                            newX, colY, num2str(duplicateRows));
                        for dupRow = duplicateRows
                            currentData(dupRow, 1) = NaN; % Удалить X
                            currentData(dupRow, colY) = NaN; % Удалить Y
                        end
                    end
                    
                    % Обновить данные
                    currentData(dataRowIdx, 1) = newPosition(1); % X - обновить
                    currentData(dataRowIdx, colY) = originalY; % Y - сохранить исходную
                    fprintf('✓ Обновлены данные (режим X): строка %d, столбец X=1 (новый: %.4f), столбец Y=%d (сохранен: %.4f)\n', ...
                        dataRowIdx, newPosition(1), colY, originalY);
                    
                case 'XY'
                    % Режим XY: изменяются обе координаты
                    % ВАЖНО: Проверить, не создаст ли обновление X дубликаты
                    % Если для того же столбца Y уже есть точка с таким X, удалить старые дубликаты
                    newX = newPosition(1);
                    xDataAll = currentData(2:end, 1);
                    yDataCol = currentData(2:end, colY);
                    
                    % Найти все строки с таким же X для того же столбца Y (кроме текущей)
                    duplicateRows = [];
                    for row = 2:size(currentData, 1)
                        if row ~= dataRowIdx && isfinite(xDataAll(row-1)) && isfinite(yDataCol(row-1))
                            % Проверить, совпадает ли X (с учетом погрешности округления)
                            if abs(xDataAll(row-1) - newX) < 1e-10
                                duplicateRows = [duplicateRows, row];
                            end
                        end
                    end
                    
                    % Удалить дубликаты (установить NaN)
                    if ~isempty(duplicateRows)
                        fprintf('⚠ Найдены дубликаты по X=%.4f для столбца Y=%d в строках [%s], удаление...\n', ...
                            newX, colY, num2str(duplicateRows));
                        for dupRow = duplicateRows
                            currentData(dupRow, 1) = NaN; % Удалить X
                            currentData(dupRow, colY) = NaN; % Удалить Y
                        end
                    end
                    
                    % Обновить данные
                    currentData(dataRowIdx, 1) = newPosition(1); % X
                    currentData(dataRowIdx, colY) = newPosition(2); % Y
                    fprintf('✓ Обновлены данные (режим XY): строка %d, столбец X=1, столбец Y=%d, новые координаты [%.4f, %.4f]\n', ...
                        dataRowIdx, colY, newPosition(1), newPosition(2));
                    
                otherwise
                    % Неизвестный режим - использовать Y по умолчанию
                    originalX = currentData(dataRowIdx, 1);
                    currentData(dataRowIdx, 1) = originalX; % X - сохранить исходную
                    currentData(dataRowIdx, colY) = newPosition(2); % Y - обновить
                    fprintf('⚠ Неизвестный режим "%s", используется Y. Обновлены данные: строка %d, столбец X=1 (сохранен: %.4f), столбец Y=%d (новый: %.4f)\n', ...
                        editMode, dataRowIdx, originalX, colY, newPosition(2));
            end
            
        else
            % Режим "по строкам"
            % Структура данных:
            % - Строка 1 (столбцы 2:end) = X координаты
            % - Строки 2:end (столбцы 2:end) = Y координаты (каждая строка = кривая)
            % - Первый столбец = метки (не участвует в данных)
            
            % Определить строку Y
            % ВАЖНО: Порядок Children в MATLAB обратный порядку построения
            % Когда строятся кривые для строк [2, 3, 4]:
            % - Сначала строится Row 2 → попадает в Children(3) (последний)
            % - Затем Row 3 → попадает в Children(2) (средний)
            % - Затем Row 4 → попадает в Children(1) (первый, верхний)
            % Поэтому curveIdx = 1 → Children(1) = Row 4 (последняя строка)
            % Для преобразования используем обратное индексирование:
            % rowY = yRows(length(yRows) - curveIdx + 1)
            
            numRows = size(currentData, 1);
            if isempty(selectedRows)
                % Нет выделения - использовать все строки (кроме первой)
                allRows = 2:numRows;
                if curveIdx <= length(allRows)
                    % Обратное преобразование: curveIdx в Children → индекс в allRows
                    rowIdx = length(allRows) - curveIdx + 1;
                    rowY = allRows(rowIdx);
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
                        % Обратное преобразование
                        rowIdx = length(allRows) - curveIdx + 1;
                        rowY = allRows(rowIdx);
                    else
                        fprintf('⚠ updateDataFromGraph: curveIdx=%d выходит за пределы\n', curveIdx);
                        return;
                    end
                else
                    if curveIdx <= length(validRows)
                        % Обратное преобразование
                        rowIdx = length(validRows) - curveIdx + 1;
                        rowY = validRows(rowIdx);
                    else
                        fprintf('⚠ updateDataFromGraph: curveIdx=%d выходит за пределы выделенных строк\n', curveIdx);
                        return;
                    end
                end
            end
            
            % Определить столбец данных
            % ВАЖНО: В режиме 'Y' координата X не изменяется, поэтому мы можем использовать
            % исходную координату X для поиска правильного столбца. Это более надежно, чем
            % использование pointIdx, который может измениться при перетаскивании.
            
            % Попытаться получить исходную координату X из dragStartCoordinates
            originalX = [];
            if isprop(app, 'dragStartCoordinates')
                try
                    dragCoords = app.dragStartCoordinates;
                    if ~isempty(dragCoords) && length(dragCoords) >= 1 && isfinite(dragCoords(1))
                        originalX = dragCoords(1);
                    end
                catch
                    if isfield(app.UIFigure.UserData, 'appData') && ...
                       isfield(app.UIFigure.UserData.appData, 'dragStartCoordinates')
                        dragCoords = app.UIFigure.UserData.appData.dragStartCoordinates;
                        if ~isempty(dragCoords) && length(dragCoords) >= 1 && isfinite(dragCoords(1))
                            originalX = dragCoords(1);
                        end
                    end
                end
            else
                if isfield(app.UIFigure.UserData, 'appData') && ...
                   isfield(app.UIFigure.UserData.appData, 'dragStartCoordinates')
                    dragCoords = app.UIFigure.UserData.appData.dragStartCoordinates;
                    if ~isempty(dragCoords) && length(dragCoords) >= 1 && isfinite(dragCoords(1))
                        originalX = dragCoords(1);
                    end
                end
            end
            
            % Если исходная координата X не найдена, использовать pointIdx как fallback
            if isempty(originalX)
                fprintf('⚠ updateDataFromGraph: исходная координата X не найдена, используется pointIdx\n');
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
            else
                % Использовать исходную координату X для поиска правильного столбца
                % Это более надежно, так как координата X не изменяется в режиме 'Y'
                xData = currentData(1, 2:end);
                
                % Найти столбец с такой же координатой X (с учетом погрешности округления)
                tolerance = 1e-10;
                dataColIdx = [];
                for col = 2:size(currentData, 2)
                    if isfinite(xData(col-1)) && abs(xData(col-1) - originalX) < tolerance
                        % Проверить, что это правильная строка Y (для дополнительной проверки)
                        if isfinite(currentData(rowY, col))
                            dataColIdx = col;
                            fprintf('✓ Найден столбец %d по исходной координате X=%.4f (текущая X=%.4f)\n', ...
                                col, originalX, xData(col-1));
                            break;
                        end
                    end
                end
                
                % Если не найден столбец по исходной координате X, использовать pointIdx как fallback
                if isempty(dataColIdx)
                    fprintf('⚠ updateDataFromGraph: не найден столбец по исходной координате X=%.4f, используется pointIdx\n', originalX);
                    validXIndices = isfinite(xData);
                    validIndicesList = find(validXIndices);
                    if pointIdx > length(validIndicesList)
                        fprintf('⚠ updateDataFromGraph: pointIdx=%d выходит за пределы валидных точек\n', pointIdx);
                        return;
                    end
                    dataColIdx = validIndicesList(pointIdx) + 1;
                end
            end
            
            % Проверить границы
            if rowY > size(currentData, 1) || dataColIdx > size(currentData, 2)
                fprintf('⚠ updateDataFromGraph: индексы выходят за пределы данных\n');
                return;
            end
            
            % Получить режим редактирования для применения ограничений
            editMode = 'Y';  % По умолчанию 'Y'
            if isprop(app, 'editMode')
                try
                    editMode = app.editMode;
                catch
                    if isfield(app.UIFigure.UserData, 'appData') && ...
                       isfield(app.UIFigure.UserData.appData, 'editMode')
                        editMode = app.UIFigure.UserData.appData.editMode;
                    end
                end
            else
                if isfield(app.UIFigure.UserData, 'appData') && ...
                   isfield(app.UIFigure.UserData.appData, 'editMode')
                    editMode = app.UIFigure.UserData.appData.editMode;
                end
            end
            
            % Проверить валидность режима
            if ~ischar(editMode) && ~isstring(editMode)
                editMode = 'Y';
            end
            editMode = upper(char(editMode));
            
            % Обновить данные с учетом режима редактирования
            % ВАЖНО: В режиме 'Y' координата X НЕ должна изменяться
            % В режиме 'X' координата Y НЕ должна изменяться
            % В режиме 'XY' обе координаты изменяются
            switch editMode
                case 'Y'
                    % Режим Y: изменяется только Y, X остается исходным
                    % Сохранить исходную координату X из данных
                    originalX = currentData(1, dataColIdx);
                    
                    % ВАЖНО: Дополнительная проверка - убедиться, что мы обновляем правильный столбец
                    % Если исходная координата X из dragStartCoordinates не совпадает с текущей,
                    % это может означать, что мы обновляем не тот столбец
                    if ~isempty(originalX) && isfinite(originalX)
                        % Получить исходную координату X из dragStartCoordinates для проверки
                        dragStartX = [];
                        if isprop(app, 'dragStartCoordinates')
                            try
                                dragCoords = app.dragStartCoordinates;
                                if ~isempty(dragCoords) && length(dragCoords) >= 1 && isfinite(dragCoords(1))
                                    dragStartX = dragCoords(1);
                                end
                            catch
                                if isfield(app.UIFigure.UserData, 'appData') && ...
                                   isfield(app.UIFigure.UserData.appData, 'dragStartCoordinates')
                                    dragCoords = app.UIFigure.UserData.appData.dragStartCoordinates;
                                    if ~isempty(dragCoords) && length(dragCoords) >= 1 && isfinite(dragCoords(1))
                                        dragStartX = dragCoords(1);
                                    end
                                end
                            end
                        else
                            if isfield(app.UIFigure.UserData, 'appData') && ...
                               isfield(app.UIFigure.UserData.appData, 'dragStartCoordinates')
                                dragCoords = app.UIFigure.UserData.appData.dragStartCoordinates;
                                if ~isempty(dragCoords) && length(dragCoords) >= 1 && isfinite(dragCoords(1))
                                    dragStartX = dragCoords(1);
                                end
                            end
                        end
                        
                        % Проверить совпадение координат X (с учетом погрешности)
                        if ~isempty(dragStartX) && abs(originalX - dragStartX) > 1e-10
                            fprintf('⚠ Предупреждение: координата X в данных (%.4f) не совпадает с исходной (%.4f)\n', ...
                                originalX, dragStartX);
                            % Использовать исходную координату X из dragStartCoordinates
                            originalX = dragStartX;
                        end
                    end
                    
                    currentData(1, dataColIdx) = originalX; % X - сохранить исходную
                    currentData(rowY, dataColIdx) = newPosition(2); % Y - обновить
                    fprintf('✓ Обновлены данные (режим Y): строка X=1 (сохранен: %.4f), строка Y=%d, столбец %d (новый Y: %.4f)\n', ...
                        originalX, rowY, dataColIdx, newPosition(2));
                    
                case 'X'
                    % Режим X: изменяется только X, Y остается исходным
                    % Сохранить исходную координату Y из данных
                    originalY = currentData(rowY, dataColIdx);
                    newX = newPosition(1);
                    
                    % ВАЖНО: Проверить, не создаст ли обновление X дубликаты
                    % Если для той же строки Y уже есть столбец с таким X, удалить старые дубликаты
                    xDataRow = currentData(1, 2:end);
                    yDataRow = currentData(rowY, 2:end);
                    
                    % Найти все столбцы с таким же X для той же строки Y (кроме текущего)
                    duplicateCols = [];
                    for col = 2:size(currentData, 2)
                        if col ~= dataColIdx && isfinite(xDataRow(col-1)) && isfinite(yDataRow(col-1))
                            % Проверить, совпадает ли X (с учетом погрешности округления)
                            if abs(xDataRow(col-1) - newX) < 1e-10
                                duplicateCols = [duplicateCols, col];
                            end
                        end
                    end
                    
                    % Удалить дубликаты (установить NaN)
                    if ~isempty(duplicateCols)
                        fprintf('⚠ Найдены дубликаты по X=%.4f для строки Y=%d в столбцах [%s], удаление...\n', ...
                            newX, rowY, num2str(duplicateCols));
                        for dupCol = duplicateCols
                            currentData(1, dupCol) = NaN; % Удалить X
                            currentData(rowY, dupCol) = NaN; % Удалить Y
                        end
                    end
                    
                    % Обновить данные
                    currentData(1, dataColIdx) = newPosition(1); % X - обновить
                    currentData(rowY, dataColIdx) = originalY; % Y - сохранить исходную
                    fprintf('✓ Обновлены данные (режим X): строка X=1 (новый: %.4f), строка Y=%d, столбец %d (сохранен Y: %.4f)\n', ...
                        newPosition(1), rowY, dataColIdx, originalY);
                    
                case 'XY'
                    % Режим XY: изменяются обе координаты
                    % ВАЖНО: Проверить, не создаст ли обновление X дубликаты
                    % Если для той же строки Y уже есть столбец с таким X, удалить старые дубликаты
                    newX = newPosition(1);
                    xDataRow = currentData(1, 2:end);
                    yDataRow = currentData(rowY, 2:end);
                    
                    % Найти все столбцы с таким же X для той же строки Y (кроме текущего)
                    duplicateCols = [];
                    for col = 2:size(currentData, 2)
                        if col ~= dataColIdx && isfinite(xDataRow(col-1)) && isfinite(yDataRow(col-1))
                            % Проверить, совпадает ли X (с учетом погрешности округления)
                            if abs(xDataRow(col-1) - newX) < 1e-10
                                duplicateCols = [duplicateCols, col];
                            end
                        end
                    end
                    
                    % Удалить дубликаты (установить NaN)
                    if ~isempty(duplicateCols)
                        fprintf('⚠ Найдены дубликаты по X=%.4f для строки Y=%d в столбцах [%s], удаление...\n', ...
                            newX, rowY, num2str(duplicateCols));
                        for dupCol = duplicateCols
                            currentData(1, dupCol) = NaN; % Удалить X
                            currentData(rowY, dupCol) = NaN; % Удалить Y
                        end
                    end
                    
                    % Обновить данные
                    currentData(1, dataColIdx) = newPosition(1); % X
                    currentData(rowY, dataColIdx) = newPosition(2); % Y
                    fprintf('✓ Обновлены данные (режим XY): строка X=1, строка Y=%d, столбец %d, новые координаты [%.4f, %.4f]\n', ...
                        rowY, dataColIdx, newPosition(1), newPosition(2));
                    
                otherwise
                    % Неизвестный режим - использовать Y по умолчанию
                    originalX = currentData(1, dataColIdx);
                    currentData(1, dataColIdx) = originalX; % X - сохранить исходную
                    currentData(rowY, dataColIdx) = newPosition(2); % Y - обновить
                    fprintf('⚠ Неизвестный режим "%s", используется Y. Обновлены данные: строка X=1 (сохранен: %.4f), строка Y=%d, столбец %d (новый Y: %.4f)\n', ...
                        editMode, originalX, rowY, dataColIdx, newPosition(2));
            end
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


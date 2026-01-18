%% UPDATEDATAFROMGRAPH Обновить данные из графика при перетаскивании точки
%   Новая модель данных:
%   - app.currentData / appData.currentData = Y-матрица (MxN)
%   - X фиксирован и берется из:
%       * A (RowNames): appData.rowNameValues (длина M) — для режима "по столбцам"
%       * B (ColumnNames): appData.columnNameValues (длина N) — для режима "по строкам"
%   - Редактирование выполняется только по Y (X не изменяется).
%
%   Использование:
%       updateDataFromGraph(app, pointIndex, newPosition)
%
%   Параметры:
%       pointIndex - [curveIndex, pointIndex] индекс точки на графике (по Children)
%       newPosition - [x, y] новые координаты точки (y используется для записи)
%
function updateDataFromGraph(app, pointIndex, newPosition)
    fprintf('updateDataFromGraph вызван: pointIndex=[%s], newPosition=[%s]\n', ...
        mat2str(pointIndex), mat2str(newPosition));
    
    % Проверка входных данных
    if isempty(pointIndex) || numel(pointIndex) < 2
        fprintf('⚠ updateDataFromGraph: некорректный pointIndex\n');
        return;
    end
    if isempty(newPosition) || numel(newPosition) < 2
        fprintf('⚠ updateDataFromGraph: некорректные координаты\n');
        return;
    end
    if ~isfinite(newPosition(2))
        fprintf('⚠ updateDataFromGraph: newPosition(2) содержит NaN/Inf\n');
        return;
    end
    
    curveIdx = pointIndex(1);
    pointIdx = pointIndex(2);
    
    % Получить Y
    yMat = [];
    if isprop(app, 'currentData')
        try
            yMat = app.currentData;
        catch
        end
    end
    if isempty(yMat) && isfield(app.UIFigure.UserData, 'appData') && ...
            isfield(app.UIFigure.UserData.appData, 'currentData')
        yMat = app.UIFigure.UserData.appData.currentData;
    end
    if isempty(yMat) || ~isnumeric(yMat) || ~ismatrix(yMat)
        fprintf('⚠ updateDataFromGraph: currentData (Y) не найдены или невалидны\n');
        return;
    end
    
    m = size(yMat, 1);
    n = size(yMat, 2);
    
    % Тип графика
    plotType = 'columns';
    if isprop(app, 'currentPlotType')
        try
            plotType = app.currentPlotType;
        catch
        end
    elseif isfield(app.UIFigure.UserData, 'appData') && ...
            isfield(app.UIFigure.UserData.appData, 'currentPlotType')
        plotType = app.UIFigure.UserData.appData.currentPlotType;
    end
    
    % Принудительно Y-only (на всякий случай)
    try
        if isprop(app, 'editMode'); app.editMode = 'Y'; end
        if ~isfield(app.UIFigure.UserData, 'appData'); app.UIFigure.UserData.appData = struct(); end
        app.UIFigure.UserData.appData.editMode = 'Y';
    catch
    end
    
    % Выделение
    selectedColumns = [];
    selectedRows = [];
    if isprop(app, 'selectedColumns')
        try; selectedColumns = app.selectedColumns; catch; end
    end
    if isprop(app, 'selectedRows')
        try; selectedRows = app.selectedRows; catch; end
    end
    
    % Исходный X (для надежного маппинга)
    originalX = [];
    if isprop(app, 'dragStartCoordinates')
        try
            dc = app.dragStartCoordinates;
            if ~isempty(dc) && numel(dc) >= 1 && isfinite(dc(1))
                originalX = dc(1);
            end
        catch
        end
    end
    if isempty(originalX) && isfield(app.UIFigure.UserData, 'appData') && ...
            isfield(app.UIFigure.UserData.appData, 'dragStartCoordinates')
        dc = app.UIFigure.UserData.appData.dragStartCoordinates;
        if ~isempty(dc) && numel(dc) >= 1 && isfinite(dc(1))
            originalX = dc(1);
        end
    end
    
    try
        if strcmp(plotType, 'columns')
            % X = A (RowNames), кривая = столбец
            if ~isfield(app.UIFigure.UserData, 'appData') || ...
                    ~isfield(app.UIFigure.UserData.appData, 'rowNameValues')
                fprintf('⚠ updateDataFromGraph: rowNameValues (A) не найдены\n');
                return;
            end
            xVec = app.UIFigure.UserData.appData.rowNameValues(:);
            if numel(xVec) ~= m
                fprintf('⚠ updateDataFromGraph: длина A (%d) не совпадает с M (%d)\n', numel(xVec), m);
                return;
            end
            
            if isempty(selectedColumns)
                yColumns = 1:n;
            else
                yColumns = selectedColumns(selectedColumns >= 1 & selectedColumns <= n);
                if isempty(yColumns); yColumns = 1:n; end
            end
            
            if curveIdx < 1 || curveIdx > numel(yColumns)
                fprintf('⚠ updateDataFromGraph: curveIdx=%d вне диапазона (%d)\n', curveIdx, numel(yColumns));
                return;
            end
            colY = yColumns(numel(yColumns) - curveIdx + 1); % обратный порядок Children
            
            rowIdx = [];
            if ~isempty(originalX)
                tol = 1e-10;
                [minDiff, idxMin] = min(abs(xVec - originalX));
                if isfinite(minDiff) && minDiff < tol
                    rowIdx = idxMin;
                end
            end
            if isempty(rowIdx)
                % Фолбэк по pointIdx среди валидных точек (y finite)
                yCol = yMat(:, colY);
                validList = find(isfinite(yCol));
                if pointIdx < 1 || pointIdx > numel(validList)
                    fprintf('⚠ updateDataFromGraph: pointIdx=%d вне диапазона (%d)\n', pointIdx, numel(validList));
                    return;
                end
                rowIdx = validList(pointIdx);
            end
            
            yMat(rowIdx, colY) = newPosition(2);
            
            if isprop(app, 'tblData') && isvalid(app.tblData)
                try
                    app.tblData.Data(rowIdx, colY) = yMat(rowIdx, colY);
                catch
                end
            end
            
        else
            % plotType == 'rows': X = B (ColumnNames), кривая = строка
            if ~isfield(app.UIFigure.UserData, 'appData') || ...
                    ~isfield(app.UIFigure.UserData.appData, 'columnNameValues')
                fprintf('⚠ updateDataFromGraph: columnNameValues (B) не найдены\n');
                return;
            end
            xVec = app.UIFigure.UserData.appData.columnNameValues(:).';
            if numel(xVec) ~= n
                fprintf('⚠ updateDataFromGraph: длина B (%d) не совпадает с N (%d)\n', numel(xVec), n);
                return;
            end
            
            if isempty(selectedRows)
                yRows = 1:m;
            else
                yRows = selectedRows(selectedRows >= 1 & selectedRows <= m);
                if isempty(yRows); yRows = 1:m; end
            end
            
            if curveIdx < 1 || curveIdx > numel(yRows)
                fprintf('⚠ updateDataFromGraph: curveIdx=%d вне диапазона (%d)\n', curveIdx, numel(yRows));
                return;
            end
            rowY = yRows(numel(yRows) - curveIdx + 1); % обратный порядок Children
            
            colIdx = [];
            if ~isempty(originalX)
                tol = 1e-10;
                [minDiff, idxMin] = min(abs(xVec(:) - originalX));
                if isfinite(minDiff) && minDiff < tol
                    colIdx = idxMin;
                end
            end
            if isempty(colIdx)
                yRow = yMat(rowY, :);
                validList = find(isfinite(yRow));
                if pointIdx < 1 || pointIdx > numel(validList)
                    fprintf('⚠ updateDataFromGraph: pointIdx=%d вне диапазона (%d)\n', pointIdx, numel(validList));
                    return;
                end
                colIdx = validList(pointIdx);
            end
            
            yMat(rowY, colIdx) = newPosition(2);
            
            if isprop(app, 'tblData') && isvalid(app.tblData)
                try
                    app.tblData.Data(rowY, colIdx) = yMat(rowY, colIdx);
                catch
                end
            end
        end
        
        % Сохранить Y обратно
        if isprop(app, 'currentData')
            try
                app.currentData = yMat;
            catch
                if ~isfield(app.UIFigure.UserData, 'appData'); app.UIFigure.UserData.appData = struct(); end
                app.UIFigure.UserData.appData.currentData = yMat;
            end
        else
            if ~isfield(app.UIFigure.UserData, 'appData'); app.UIFigure.UserData.appData = struct(); end
            app.UIFigure.UserData.appData.currentData = yMat;
        end
        
        fprintf('✓ updateDataFromGraph: Y обновлен\n');
        
    catch ME
        fprintf('Ошибка в updateDataFromGraph: %s\n', ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
            uialert(app.UIFigure, sprintf('Ошибка обновления данных: %s', ME.message), 'Ошибка обновления данных');
        end
    end
end



%% LOADVARIABLEFROMWORKSPACE Загружает переменную из workspace
%   Загружает числовую 2D матрицу из workspace и сохраняет в app.currentData
%   Поддерживает как прямые переменные, так и переменные из структур
%
%   Использование:
%       loadVariableFromWorkspace(app, varPath)
%
%   Параметры:
%       app - объект приложения TableGraphEditor
%       varPath - путь к переменной в workspace (string)
%                 Может быть прямой переменной: 'data'
%                 Или переменной из структуры: 'struct.field' или 'struct.field.subfield'
%
%   Описание:
%       Загружает переменную из workspace (прямую или из структуры),
%       валидирует её как числовую 2D матрицу и сохраняет в app.currentData
%       и app.originalData. Также обновляет таблицу через updateTableWithData.

function loadVariableFromWorkspace(app, varName)
    % LOADVARIABLEFROMWORKSPACE Загружает переменную из workspace
    
    fprintf('loadVariableFromWorkspace вызван для: %s\n', varName);
    
    try
        % Сохранить предыдущее состояние (чтобы откатиться при отмене выбора A/B)
        prevState = struct();
        prevState.hasData = false;
        try
            if isprop(app, 'currentData')
                prevState.currentData = app.currentData;
                prevState.hasData = ~isempty(prevState.currentData);
            elseif isfield(app.UIFigure.UserData, 'appData') && isfield(app.UIFigure.UserData.appData, 'currentData')
                prevState.currentData = app.UIFigure.UserData.appData.currentData;
                prevState.hasData = ~isempty(prevState.currentData);
            else
                prevState.currentData = [];
            end
        catch
            prevState.currentData = [];
            prevState.hasData = false;
        end
        try
            if isprop(app, 'originalData')
                prevState.originalData = app.originalData;
            elseif isfield(app.UIFigure.UserData, 'appData') && isfield(app.UIFigure.UserData.appData, 'originalData')
                prevState.originalData = app.UIFigure.UserData.appData.originalData;
            else
                prevState.originalData = [];
            end
        catch
            prevState.originalData = [];
        end
        try
            if isfield(app.UIFigure.UserData, 'appData')
                prevState.appData = app.UIFigure.UserData.appData;
            else
                prevState.appData = struct();
            end
        catch
            prevState.appData = struct();
        end
        
        % Проверить входной параметр
        if isempty(varName) || strcmp(varName, 'Select variable...') || ...
           strcmp(varName, 'Нет числовых переменных') || strcmp(varName, '')
            fprintf('Пропуск: невалидное имя переменной\n');
            return;
        end
        
        % Получить данные из workspace
        % Поддержка путей к структурам (например, 'struct.field')
        fprintf('Загрузка данных из workspace: %s\n', varName);
        
        % Проверить, является ли путь к структуре (содержит точку)
        if contains(varName, '.')
            % Это путь к переменной в структуре
            % Валидировать путь перед загрузкой
            try
                % Проверить существование пути
                % Используем evalin для проверки существования
                testExpr = ['exist(''', varName, ''', ''var'')'];
                if ~evalin('base', testExpr)
                    % Попробуем альтернативный способ - загрузить напрямую
                    % Если путь не существует, evalin выбросит ошибку
                end
            catch
                % Если проверка не удалась, попробуем загрузить напрямую
            end
        end
        
        % Загрузить данные (работает для прямых переменных и путей к структурам)
        data = evalin('base', varName);
        fprintf('Данные загружены: size=[%s], тип=%s\n', num2str(size(data)), class(data));
        
        % Валидировать данные (числовая матрица или вектор)
        if ~isnumeric(data) || ~ismatrix(data) || isempty(data)
            fprintf('✗ Валидация не пройдена: isnumeric=%d, ismatrix=%d, empty=%d\n', ...
                isnumeric(data), ismatrix(data), isempty(data));
            if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                uialert(app.UIFigure, ...
                    'Выбранная переменная должна быть числовой 2D матрицей', ...
                    'Ошибка загрузки', ...
                    'Icon', 'error');
            end
            return;
        end
        
        fprintf('✓ Валидация пройдена\n');
        
        % Новое правило: выбранная переменная = только Y (MxN) или вектор (Lx1)
        % A и B выбираются отдельно и используются для:
        % - A: RowNames таблицы, X в режиме "по столбцам", легенда в режиме "по строкам"
        % - B: ColumnNames таблицы, X в режиме "по строкам", легенда в режиме "по столбцам"
        
        % Если основная переменная - вектор, разрешаем и строку и столбец.
        % Для унификации храним Y как column vector (Lx1) и используем plotType='columns'.
        isVectorY = isvector(data);
        if isVectorY
            if isrow(data)
                data = data(:);
            end
        end
        
        m = size(data, 1);
        n = size(data, 2);
        
        % Попробовать автоподстановку A/B по TableGraphEditor/resources/Variables.csv
        [isMapped, mappedAName, mappedBName] = findVariablesCsvMapping(varName);
        
        aPath = '';
        bPath = '';
        aVec = [];
        bVec = [];
        
        if isMapped
            % В режиме маппинга: при проблемах показываем ошибку и прерываем загрузку.
            if isempty(mappedAName)
                if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                    uialert(app.UIFigure, ...
                        sprintf('Variables.csv: для "%s" не задана переменная A (2-й столбец).', varName), ...
                        'Ошибка маппинга', 'Icon', 'error');
                end
                return;
            end
            
            % Загрузить и проверить A (длина M), привести к столбцу
            aPath = mappedAName;
            try
                vA = evalin('base', aPath);
            catch ME
                if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                    uialert(app.UIFigure, ...
                        sprintf('Не удалось загрузить A="%s": %s', aPath, ME.message), ...
                        'Ошибка маппинга', 'Icon', 'error');
                end
                return;
            end
            if ~isnumeric(vA) || ~isvector(vA)
                if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                    uialert(app.UIFigure, ...
                        sprintf('A="%s" должна быть числовым вектором.', aPath), ...
                        'Ошибка маппинга', 'Icon', 'error');
                end
                return;
            end
            vA = double(vA(:)); % A -> column
            if numel(vA) ~= m
                if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                    uialert(app.UIFigure, ...
                        sprintf('Длина A="%s" (%d) не совпадает с M (%d).', aPath, numel(vA), m), ...
                        'Ошибка маппинга', 'Icon', 'error');
                end
                return;
            end
            if ~all(isfinite(vA)) || numel(unique(vA)) ~= numel(vA)
                if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                    uialert(app.UIFigure, ...
                        sprintf('A="%s" должна быть без NaN/Inf и без дубликатов.', aPath), ...
                        'Ошибка маппинга', 'Icon', 'error');
                end
                return;
            end
            aVec = vA;
            
            if isVectorY
                % Для вектора Y допускаем пустой B (3-й столбец) — используем дефолт.
                bPath = '';
                bVec = 1; % единственный столбец
            else
                % Для матрицы Y ожидаем B (длина N), привести к строке
                if isempty(mappedBName)
                    if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                        uialert(app.UIFigure, ...
                            sprintf('Variables.csv: для "%s" не задана переменная B (3-й столбец).', varName), ...
                            'Ошибка маппинга', 'Icon', 'error');
                    end
                    return;
                end
                
                bPath = mappedBName;
                try
                    vB = evalin('base', bPath);
                catch ME
                    if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                        uialert(app.UIFigure, ...
                            sprintf('Не удалось загрузить B="%s": %s', bPath, ME.message), ...
                            'Ошибка маппинга', 'Icon', 'error');
                    end
                    return;
                end
                if ~isnumeric(vB) || ~isvector(vB)
                    if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                        uialert(app.UIFigure, ...
                            sprintf('B="%s" должна быть числовым вектором.', bPath), ...
                            'Ошибка маппинга', 'Icon', 'error');
                    end
                    return;
                end
                vB = double(vB(:).'); % B -> row
                if numel(vB) ~= n
                    if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                        uialert(app.UIFigure, ...
                            sprintf('Длина B="%s" (%d) не совпадает с N (%d).', bPath, numel(vB), n), ...
                            'Ошибка маппинга', 'Icon', 'error');
                    end
                    return;
                end
                if ~all(isfinite(vB)) || numel(unique(vB)) ~= numel(vB)
                    if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                        uialert(app.UIFigure, ...
                            sprintf('B="%s" должна быть без NaN/Inf и без дубликатов.', bPath), ...
                            'Ошибка маппинга', 'Icon', 'error');
                    end
                    return;
                end
                bVec = vB;
            end
        end
        
        % Если маппинга нет — используем текущую процедуру ручного выбора A/B.
        if ~isMapped
            % Запросить A (длина M)
            [aPath, aVec] = promptSelectVectorVariable( ...
                app, m, ...
                'Выбор переменной A', ...
                sprintf('Выберите вектор A длиной %d: X (по столбцам) и RowNames', m));
            if isempty(aPath) || isempty(aVec)
                fprintf('Загрузка отменена пользователем на шаге выбора A\n');
                if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                    uialert(app.UIFigure, 'Загрузка отменена: не выбран вектор A.', 'Загрузка отменена', 'Icon', 'warning');
                end
                % Откат
                try
                    if isprop(app, 'currentData'); app.currentData = prevState.currentData; end
                    if isprop(app, 'originalData'); app.originalData = prevState.originalData; end
                    if ~isfield(app.UIFigure.UserData, 'appData'); app.UIFigure.UserData.appData = struct(); end
                    app.UIFigure.UserData.appData = prevState.appData;
                catch
                end
                return;
            end
            aVec = double(aVec(:)); % A -> column (явно)
            
            % Запросить B (длина N). Для вектора Y (n=1) всё равно спросим B,
            % чтобы поведение было предсказуемым, если маппинга нет.
            [bPath, bVec] = promptSelectVectorVariable( ...
                app, n, ...
                'Выбор переменной B', ...
                sprintf('Выберите вектор B длиной %d: X (по строкам) и ColumnNames', n));
            if isempty(bPath) || isempty(bVec)
                fprintf('Загрузка отменена пользователем на шаге выбора B\n');
                if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                    uialert(app.UIFigure, 'Загрузка отменена: не выбран вектор B.', 'Загрузка отменена', 'Icon', 'warning');
                end
                % Откат
                try
                    if isprop(app, 'currentData'); app.currentData = prevState.currentData; end
                    if isprop(app, 'originalData'); app.originalData = prevState.originalData; end
                    if ~isfield(app.UIFigure.UserData, 'appData'); app.UIFigure.UserData.appData = struct(); end
                    app.UIFigure.UserData.appData = prevState.appData;
                catch
                end
                return;
            end
            
            bVec = double(bVec(:).'); % B -> row (явно)
        end
        
        % Сформировать строковые метки без округления
        rowLabelsCell = cellfun(@num2str, num2cell(aVec(:)), 'UniformOutput', false);
        colLabelsCell = cellfun(@num2str, num2cell(bVec(:)), 'UniformOutput', false);
        
        % Инициализировать UserData структуру, если нужно
        if ~isfield(app.UIFigure.UserData, 'appData')
            app.UIFigure.UserData.appData = struct();
        end
        
        % Сохранить A/B в appData (все дальнейшие операции используют их, а не currentData)
        app.UIFigure.UserData.appData.rowNameValues = aVec(:);
        app.UIFigure.UserData.appData.columnNameValues = bVec(:).';
        app.UIFigure.UserData.appData.rowNameVarPath = aPath;
        app.UIFigure.UserData.appData.columnNameVarPath = bPath;
        app.UIFigure.UserData.appData.rowLabels = rowLabelsCell;
        app.UIFigure.UserData.appData.columnLabels = colLabelsCell;
        
        % Сохранить данные (с проверкой возможности установки)
        dataSaved = false;
        try
            if isprop(app, 'originalData')
                app.originalData = data;
                fprintf('✓ originalData установлен: size=[%s]\n', num2str(size(data)));
            else
                app.UIFigure.UserData.appData.originalData = data;
                fprintf('originalData сохранен в UserData (свойство не существует)\n');
            end
        catch ME
            fprintf('Предупреждение: не удалось установить originalData: %s\n', ME.message);
            app.UIFigure.UserData.appData.originalData = data;
            fprintf('originalData сохранен в UserData (fallback)\n');
        end
        
        try
            if isprop(app, 'currentData')
                app.currentData = data;
                fprintf('✓ currentData установлен: size=[%s]\n', num2str(size(data)));
                dataSaved = true;
            else
                app.UIFigure.UserData.appData.currentData = data;
                fprintf('currentData сохранен в UserData (свойство не существует)\n');
                dataSaved = true;
            end
        catch ME
            fprintf('Предупреждение: не удалось установить currentData: %s\n', ME.message);
            app.UIFigure.UserData.appData.currentData = data;
            fprintf('currentData сохранен в UserData (fallback)\n');
            dataSaved = true;
        end
        
        % Проверить, что данные действительно сохранены
        if ~dataSaved
            fprintf('✗ ОШИБКА: Данные не были сохранены!\n');
            if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                uialert(app.UIFigure, ...
                    'Не удалось сохранить данные в приложение', ...
                    'Ошибка загрузки', ...
                    'Icon', 'error');
            end
            return;
        end
        
        try
            if isprop(app, 'selectedVariable')
                app.selectedVariable = varName;
                fprintf('✓ selectedVariable установлен: %s\n', varName);
            else
                app.UIFigure.UserData.appData.selectedVariable = varName;
                fprintf('selectedVariable сохранен в UserData (свойство не существует)\n');
            end
        catch ME
            fprintf('Предупреждение: не удалось установить selectedVariable: %s\n', ME.message);
            app.UIFigure.UserData.appData.selectedVariable = varName;
            fprintf('selectedVariable сохранен в UserData (fallback)\n');
        end
        
        % Инициализировать свойства, если нужно (перед обновлением таблицы и графика)
        if exist('initializeAppProperties', 'file') == 2
            initializeAppProperties(app);
        end
        
        % Обновить метки в свойствах (если они существуют)
        try
            if isprop(app, 'rowLabels')
                app.rowLabels = rowLabelsCell;
            end
            if isprop(app, 'columnLabels')
                app.columnLabels = colLabelsCell;
            end
        catch
        end
        
        % Редактирование только Y: принудительно установить режим и отключить X/XY
        try
            if isprop(app, 'editMode')
                app.editMode = 'Y';
            else
                app.UIFigure.UserData.appData.editMode = 'Y';
            end
        catch
            app.UIFigure.UserData.appData.editMode = 'Y';
        end
        try
            if isprop(app, 'bgEditMode') && isvalid(app.bgEditMode)
                if isprop(app, 'rbModeX') && isvalid(app.rbModeX); app.rbModeX.Enable = 'off'; end
                if isprop(app, 'rbModeXY') && isvalid(app.rbModeXY); app.rbModeXY.Enable = 'off'; end
                if isprop(app, 'rbModeY') && isvalid(app.rbModeY)
                    app.rbModeY.Enable = 'on';
                    app.bgEditMode.SelectedObject = app.rbModeY;
                end
            end
        catch
        end
        
        % Для вектора Y принудительно используем режим построения "по столбцам",
        % чтобы не требовать X из B (так как B может быть дефолтным).
        if isVectorY
            try
                if isprop(app, 'currentPlotType')
                    app.currentPlotType = 'columns';
                else
                    app.UIFigure.UserData.appData.currentPlotType = 'columns';
                end
            catch
                app.UIFigure.UserData.appData.currentPlotType = 'columns';
            end
            
            % Отключить режим rows в UI (если есть dropdown ddPlotType)
            try
                if isprop(app, 'ddPlotType') && isvalid(app.ddPlotType)
                    % Попытаться выставить значение на "columns" (в зависимости от Items)
                    selectedValue = '';
                    try
                        selectedValue = app.ddPlotType.Value;
                    catch
                        selectedValue = '';
                    end
                    
                    try
                        items = app.ddPlotType.Items;
                        if iscell(items) && ~isempty(items)
                            idxCol = find(contains(string(items), "Column", 'IgnoreCase', true) | ...
                                          strcmpi(string(items), "columns"), 1, 'first');
                            if ~isempty(idxCol)
                                % Установить значение на "columns", если сейчас не оно
                                try
                                    if ~(ischar(selectedValue) || isstring(selectedValue)) || ...
                                            ~strcmpi(string(selectedValue), string(items{idxCol}))
                                        app.ddPlotType.Value = items{idxCol};
                                    end
                                catch
                                    % Если Value не принимает текст из Items (например, ItemsData),
                                    % просто игнорируем — updateGraph всё равно принудит columns.
                                end
                            end
                        end
                    catch
                    end
                    
                    app.ddPlotType.Enable = 'off';
                end
            catch
            end
        else
            % Для матрицы — вернуть возможность переключения columns/rows
            try
                if isprop(app, 'ddPlotType') && isvalid(app.ddPlotType)
                    app.ddPlotType.Enable = 'on';
                end
            catch
            end
        end
        
        % Сбросить выделение при новой загрузке
        try
            if isprop(app, 'selectedColumns'); app.selectedColumns = []; end
            if isprop(app, 'selectedRows'); app.selectedRows = []; end
        catch
        end
        app.UIFigure.UserData.appData.selectedColumns = [];
        app.UIFigure.UserData.appData.selectedRows = [];
        
        % Извлечь метки и обновить таблицу
        fprintf('Вызов updateTableWithData...\n');
        if exist('updateTableWithData', 'file') == 2
            updateTableWithData(app);
            fprintf('✓ updateTableWithData завершен\n');
        else
            fprintf('⚠ Функция updateTableWithData не найдена в path\n');
        end
        
        % Построить график после загрузки данных
        fprintf('Вызов updateGraph...\n');
        if exist('updateGraph', 'file') == 2
            updateGraph(app);
            fprintf('✓ График обновлен\n');
        else
            fprintf('⚠ Функция updateGraph не найдена в path\n');
        end
        
    catch ME
        fprintf('Ошибка в loadVariableFromWorkspace: %s\n', ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        
        if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
            uialert(app.UIFigure, sprintf('Ошибка загрузки переменной: %s', ME.message), 'Ошибка загрузки');
        end
    end
end


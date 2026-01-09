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
        
        % Валидировать данные (должна быть числовая 2D матрица)
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
        
        % Инициализировать UserData структуру, если нужно
        if ~isfield(app.UIFigure.UserData, 'appData')
            app.UIFigure.UserData.appData = struct();
        end
        
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


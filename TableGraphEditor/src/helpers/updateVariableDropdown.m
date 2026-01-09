%% UPDATEVARIABLEDROPDOWN Обновляет список переменных в dropdown
%   Заполняет dropdown списком числовых 2D матриц из workspace
%   Поддерживает как прямые переменные, так и переменные из структур
%
%   Использование:
%       updateVariableDropdown(app)
%
%   Параметры:
%       app - объект приложения TableGraphEditor
%
%   Описание:
%       Загружает список переменных из workspace и фильтрует только
%       числовые 2D матрицы (исключает скаляры, 1D массивы, 3D+ массивы).
%       Также находит числовые 2D матрицы внутри структур (рекурсивно).

function updateVariableDropdown(app)
    % UPDATEVARIABLEDROPDOWN Обновляет список переменных в dropdown
    
    try
        % Получить все числовые переменные (прямые и из структур)
        allVars = getAllNumericVariables();
        
        % Обновить dropdown
        if ~isempty(allVars.names)
            % Правильная конкатенация cell arrays
            app.ddVariable.Items = [{'Select variable...'}, allVars.names];
            % ItemsData должен содержать пути для загрузки
            app.ddVariable.ItemsData = [{''}, allVars.paths];
            app.ddVariable.Enable = 'on';
        else
            app.ddVariable.Items = {'Нет числовых переменных'};
            app.ddVariable.ItemsData = {''};
            app.ddVariable.Enable = 'off';
        end
        
    catch ME
        fprintf('Ошибка обновления dropdown: %s\n', ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        
        % Показать сообщение пользователю, если UIFigure доступен
        if isfield(app, 'UIFigure') && isvalid(app.UIFigure)
            uialert(app.UIFigure, ...
                sprintf('Ошибка обновления списка переменных: %s', ME.message), ...
                'Ошибка', ...
                'Icon', 'error');
        end
    end
end


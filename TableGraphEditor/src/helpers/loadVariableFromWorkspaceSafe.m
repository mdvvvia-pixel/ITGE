%% LOADVARIABLEFROMWORKSPACESAFE Безопасная загрузка переменной с проверкой свойств
%   Альтернативная версия, которая проверяет возможность установки свойств
%
%   Использование:
%       loadVariableFromWorkspaceSafe(app, varName)

function loadVariableFromWorkspaceSafe(app, varName)
    % LOADVARIABLEFROMWORKSPACESAFE Безопасная загрузка переменной
    
    try
        % Получить данные из workspace
        data = evalin('base', varName);
        
        % Проверить, что данные числовые
        if ~isnumeric(data)
            uialert(app.UIFigure, 'Переменная должна быть числовой', 'Ошибка');
            return;
        end
        
        if isempty(data)
            uialert(app.UIFigure, 'Переменная пуста', 'Ошибка');
            return;
        end
        
        % Безопасная установка свойств
        % Проверить, можно ли установить свойство
        if isprop(app, 'originalData')
            try
                app.originalData = data;
            catch ME
                fprintf('Предупреждение: не удалось установить originalData: %s\n', ME.message);
                % Попробовать через метаданные класса
                try
                    mc = metaclass(app);
                    prop = findobj(mc.PropertyList, 'Name', 'originalData');
                    if ~isempty(prop) && ~prop.Constant && ~prop.Dependent
                        app.originalData = data;
                    end
                catch
                    % Если не получилось, сохранить в UserData
                    if ~isfield(app.UIFigure.UserData, 'appData')
                        app.UIFigure.UserData.appData = struct();
                    end
                    app.UIFigure.UserData.appData.originalData = data;
                end
            end
        end
        
        if isprop(app, 'currentData')
            try
                app.currentData = data;
            catch ME
                fprintf('Предупреждение: не удалось установить currentData: %s\n', ME.message);
                if isfield(app.UIFigure.UserData, 'appData')
                    app.UIFigure.UserData.appData.currentData = data;
                end
            end
        end
        
        if isprop(app, 'selectedVariable')
            try
                app.selectedVariable = varName;
            catch ME
                fprintf('Предупреждение: не удалось установить selectedVariable: %s\n', ME.message);
                if isfield(app.UIFigure.UserData, 'appData')
                    app.UIFigure.UserData.appData.selectedVariable = varName;
                end
            end
        end
        
        % Обновить таблицу (если компонент существует)
        if isfield(app, 'tblData') && isvalid(app.tblData)
            app.tblData.Data = data;
        end
        
    catch ME
        uialert(app.UIFigure, sprintf('Ошибка загрузки переменной: %s', ME.message), 'Ошибка загрузки');
    end
end


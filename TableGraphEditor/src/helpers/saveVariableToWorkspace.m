%% SAVEVARIABLETOWORKSPACE Сохраняет переменную в workspace
%   Сохраняет данные в workspace, поддерживает как прямые переменные,
%   так и переменные в структурах
%
%   Использование:
%       saveVariableToWorkspace(app, varPath, data)
%
%   Параметры:
%       app - объект приложения TableGraphEditor
%       varPath - путь к переменной в workspace (string)
%                 Может быть прямой переменной: 'data'
%                 Или переменной из структуры: 'struct.field' или 'struct.field.subfield'
%       data - данные для сохранения (числовая 2D матрица)
%
%   Описание:
%       Сохраняет данные в workspace. Если varPath - прямая переменная,
%       использует assignin. Если varPath - путь к структуре, загружает
%       структуру, обновляет поле и сохраняет структуру обратно.
%
%   Пример:
%       % Сохранение прямой переменной
%       saveVariableToWorkspace(app, 'data', rand(10, 5));
%       
%       % Сохранение в структуру
%       saveVariableToWorkspace(app, 'experiment.data', rand(10, 5));

function saveVariableToWorkspace(app, varPath, data)
    % SAVEVARIABLETOWORKSPACE Сохраняет переменную в workspace
    
    try
        % Проверить входные параметры
        if isempty(varPath) || isempty(data)
            if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                uialert(app.UIFigure, ...
                    'Не указан путь к переменной или данные пусты', ...
                    'Ошибка сохранения', ...
                    'Icon', 'error');
            end
            return;
        end
        
        % Проверить, является ли путь к структуре (содержит точку)
        if contains(varPath, '.')
            % Это путь к переменной в структуре
            % Разделить путь на части
            pathParts = strsplit(varPath, '.');
            
            if length(pathParts) < 2
                error('Неверный формат пути к структуре: %s', varPath);
            end
            
            % Имя корневой структуры
            structName = pathParts{1};
            
            % Путь к полю в структуре (без корневого имени)
            fieldPath = strjoin(pathParts(2:end), '.');
            
            % Загрузить структуру из workspace
            try
                structVar = evalin('base', structName);
            catch ME
                if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                    uialert(app.UIFigure, ...
                        sprintf('Структура "%s" не найдена в workspace', structName), ...
                        'Ошибка сохранения', ...
                        'Icon', 'error');
                end
                rethrow(ME);
            end
            
            % Обновить поле в структуре
            % Для вложенных путей нужно рекурсивно обновить
            updatedStruct = setNestedField(structVar, pathParts(2:end), data);
            
            % Сохранить обновленную структуру обратно в workspace
            assignin('base', structName, updatedStruct);
            
            fprintf('✓ Данные сохранены в структуру: %s\n', varPath);
            
        else
            % Это прямая переменная - сохранить напрямую
            assignin('base', varPath, data);
            fprintf('✓ Данные сохранены в переменную: %s\n', varPath);
        end
        
    catch ME
        fprintf('Ошибка сохранения переменной %s: %s\n', varPath, ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        
        if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
            uialert(app.UIFigure, ...
                sprintf('Ошибка сохранения переменной "%s": %s', varPath, ME.message), ...
                'Ошибка сохранения', ...
                'Icon', 'error');
        end
        rethrow(ME);
    end
end

%% Вспомогательная функция для установки вложенного поля в структуре
function structVar = setNestedField(structVar, fieldPath, value)
    % SETNESTEDFIELD Устанавливает значение вложенного поля структуры
    %   structVar - структура для обновления
    %   fieldPath - cell array с путем к полю (например, {'field', 'subfield'})
    %   value - значение для установки
    
    if length(fieldPath) == 1
        % Это конечное поле - установить значение
        structVar.(fieldPath{1}) = value;
    else
        % Это вложенное поле - рекурсивно обойти
        currentField = fieldPath{1};
        remainingPath = fieldPath(2:end);
        
        % Проверить, что текущее поле существует и является структурой
        if ~isfield(structVar, currentField)
            % Создать новое поле как структуру
            structVar.(currentField) = struct();
        end
        
        % Рекурсивно обновить вложенную структуру
        structVar.(currentField) = setNestedField(structVar.(currentField), remainingPath, value);
    end
end


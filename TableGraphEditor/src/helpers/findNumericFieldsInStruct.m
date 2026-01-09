%% FINDSNUMERICFIELDSINSTRUCT Рекурсивно находит числовые 2D поля в структуре
%   Находит все числовые 2D матрицы в структуре и возвращает пути к ним
%
%   Использование:
%       paths = findNumericFieldsInStruct(structVar, prefix)
%
%   Параметры:
%       structVar - структура для поиска
%       prefix - префикс пути (например, 'struct.field') или пустая строка для корня
%
%   Возвращает:
%       paths - cell array строк с путями к числовым 2D полям
%               (например, {'struct.data', 'struct.results.matrix'})
%
%   Описание:
%       Рекурсивно обходит структуру и находит все поля, которые являются
%       числовыми 2D матрицами. Возвращает полные пути к этим полям.
%
%   Пример:
%       experiment.data = rand(10, 5);
%       experiment.results.matrix = rand(20, 3);
%       paths = findNumericFieldsInStruct(experiment, 'experiment');
%       % paths = {'experiment.data', 'experiment.results.matrix'}

function paths = findNumericFieldsInStruct(structVar, prefix)
    % FINDSNUMERICFIELDSINSTRUCT Рекурсивно находит числовые 2D поля в структуре
    
    paths = {};
    
    % Проверить, что structVar - структура
    if ~isstruct(structVar)
        return;
    end
    
    % Получить список полей структуры
    fieldNames = fieldnames(structVar);
    
    % Обработать массив структур (если structVar - массив структур)
    if length(structVar) > 1
        % Для массивов структур обрабатываем только первый элемент
        % (можно расширить для обработки всех элементов)
        structVar = structVar(1);
    end
    
    % Обойти каждое поле
    for i = 1:length(fieldNames)
        fieldName = fieldNames{i};
        fieldValue = structVar.(fieldName);
        
        % Сформировать текущий путь
        if isempty(prefix)
            currentPath = fieldName;
        else
            currentPath = [prefix, '.', fieldName];
        end
        
        % Проверить тип поля
        if isnumeric(fieldValue) && ismatrix(fieldValue) && ...
           ~isempty(fieldValue) && ...
           size(fieldValue, 1) > 1 && size(fieldValue, 2) > 1
            % Это числовая 2D матрица - добавить в список
            paths{end+1} = currentPath;
            
        elseif isstruct(fieldValue)
            % Это вложенная структура - рекурсивно обойти
            nestedPaths = findNumericFieldsInStruct(fieldValue, currentPath);
            paths = [paths, nestedPaths];
        end
        % Игнорируем другие типы (cell arrays, strings, etc.)
    end
end


%% FINDSNUMERICFIELDSINSTRUCT Рекурсивно находит числовые 2D матрицы/векторы в структуре
%   Находит все числовые 2D матрицы и векторы (1xK/Kx1, K>1) в структуре
%   и возвращает пути к ним.
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
%       числовыми 2D матрицами или числовыми векторами (кроме скаляров).
%       Возвращает полные пути к этим полям.
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
        if isnumeric(fieldValue) && ismatrix(fieldValue) && ~isempty(fieldValue)
            sz = size(fieldValue);
            isMatrix2D = (numel(sz) == 2 && sz(1) > 1 && sz(2) > 1);
            isVector1D = (numel(sz) == 2 && ((sz(1) == 1 && sz(2) > 1) || (sz(2) == 1 && sz(1) > 1)));
            if isMatrix2D || isVector1D
                % Это числовая 2D матрица или вектор (кроме скаляра) - добавить в список
                paths{end+1} = currentPath;
            end
            
        elseif isstruct(fieldValue)
            % Это вложенная структура - рекурсивно обойти
            nestedPaths = findNumericFieldsInStruct(fieldValue, currentPath);
            paths = [paths, nestedPaths];
        end
        % Игнорируем другие типы (cell arrays, strings, etc.)
    end
end


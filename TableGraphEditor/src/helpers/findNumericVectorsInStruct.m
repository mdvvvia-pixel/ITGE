%% FINDSNUMERICVECTORSINSTRUCT Рекурсивно находит числовые векторы в структуре
%   Находит все числовые векторы в структуре и возвращает пути к ним.
%   Используется для выбора A/B (RowNames/ColumnNames и X координат).
%
%   Использование:
%       paths = findNumericVectorsInStruct(structVar, prefix, expectedLength)
%
%   Параметры:
%       structVar - структура для поиска
%       prefix - префикс пути (например, 'structName') или пустая строка
%       expectedLength - ожидаемая длина вектора (scalar > 0). Если пусто,
%                        фильтрация по длине не применяется.
%
%   Возвращает:
%       paths - cell array строк с путями к числовым векторам
%
function paths = findNumericVectorsInStruct(structVar, prefix, expectedLength)
    paths = {};
    
    if nargin < 3
        expectedLength = [];
    end
    
    if ~isstruct(structVar)
        return;
    end
    
    % Для массивов структур обрабатываем только первый элемент
    if numel(structVar) > 1
        structVar = structVar(1);
    end
    
    fieldNames = fieldnames(structVar);
    
    for i = 1:numel(fieldNames)
        fieldName = fieldNames{i};
        fieldValue = structVar.(fieldName);
        
        if isempty(prefix)
            currentPath = fieldName;
        else
            currentPath = [prefix, '.', fieldName];
        end
        
        if isnumeric(fieldValue) && isvector(fieldValue) && ~isempty(fieldValue)
            vec = fieldValue(:);
            if all(isfinite(vec)) && numel(unique(vec)) == numel(vec)
                if isempty(expectedLength) || numel(vec) == expectedLength
                    paths{end+1} = currentPath; %#ok<AGROW>
                end
            end
        elseif isstruct(fieldValue)
            nestedPaths = findNumericVectorsInStruct(fieldValue, currentPath, expectedLength);
            if ~isempty(nestedPaths)
                paths = [paths, nestedPaths]; %#ok<AGROW>
            end
        end
    end
end



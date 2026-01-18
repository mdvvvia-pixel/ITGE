%% GETALLNUMERICVECTORVARIABLES Получить все числовые векторы (прямые и из структур)
%   Возвращает список всех числовых векторов из workspace, удовлетворяющих:
%   - isnumeric && isvector && ~isempty
%   - все элементы конечные (no NaN/Inf)
%   - нет дубликатов (unique)
%   - (опционально) длина равна expectedLength
%
%   Использование:
%       allVars = getAllNumericVectorVariables(expectedLength)
%
%   Параметры:
%       expectedLength - ожидаемая длина вектора (scalar > 0) или [] для любого
%
%   Возвращает:
%       allVars - структура с полями:
%         .names - cell array имен для отображения
%         .paths - cell array путей для evalin
%         .types - 'direct' или 'struct'
%
function allVars = getAllNumericVectorVariables(expectedLength)
    allVars = struct();
    allVars.names = {};
    allVars.paths = {};
    allVars.types = {};
    
    if nargin < 1
        expectedLength = [];
    end
    
    try
        wsVars = evalin('base', 'whos');
        
        for i = 1:numel(wsVars)
            varName = wsVars(i).name;
            varClass = wsVars(i).class;
            
            % Прямые числовые векторы
            if any(strcmp(varClass, {'double','single','int8','uint8','int16','uint16','int32','uint32','int64','uint64'}))
                % Быстрый фильтр по размерности из whos
                sz = wsVars(i).size;
                if numel(sz) == 2 && (sz(1) == 1 || sz(2) == 1) && prod(sz) >= 1
                    if ~isempty(expectedLength) && prod(sz) ~= expectedLength
                        continue;
                    end
                    
                    % Полная проверка содержимого (finite + unique)
                    try
                        v = evalin('base', varName);
                        v = v(:);
                        if isempty(v) || ~isnumeric(v)
                            continue;
                        end
                        if ~all(isfinite(v))
                            continue;
                        end
                        if numel(unique(v)) ~= numel(v)
                            continue;
                        end
                        allVars.names{end+1} = varName; %#ok<AGROW>
                        allVars.paths{end+1} = varName; %#ok<AGROW>
                        allVars.types{end+1} = 'direct'; %#ok<AGROW>
                    catch
                        % Игнорировать проблемные переменные
                    end
                end
                
            elseif strcmp(varClass, 'struct')
                % Структуры: поиск по полям
                try
                    structVar = evalin('base', varName);
                    structPaths = findNumericVectorsInStruct(structVar, varName, expectedLength);
                    for j = 1:numel(structPaths)
                        allVars.names{end+1} = structPaths{j}; %#ok<AGROW>
                        allVars.paths{end+1} = structPaths{j}; %#ok<AGROW>
                        allVars.types{end+1} = 'struct'; %#ok<AGROW>
                    end
                catch
                    % Игнорировать ошибки структуры
                end
            end
        end
        
        % Сортировка: direct затем struct
        if ~isempty(allVars.names)
            directIdx = strcmp(allVars.types, 'direct');
            structIdx = strcmp(allVars.types, 'struct');
            allVars.names = [allVars.names(directIdx), allVars.names(structIdx)];
            allVars.paths = [allVars.paths(directIdx), allVars.paths(structIdx)];
            allVars.types = [allVars.types(directIdx), allVars.types(structIdx)];
        end
        
    catch ME
        fprintf('Ошибка getAllNumericVectorVariables: %s\n', ME.message);
        allVars.names = {};
        allVars.paths = {};
        allVars.types = {};
    end
end



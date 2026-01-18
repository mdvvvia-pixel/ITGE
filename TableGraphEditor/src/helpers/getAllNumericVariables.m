%% GETALLNUMERICVARIABLES Получить все числовые переменные (прямые и из структур)
%   Объединяет прямые числовые 2D матрицы/векторы и числовые 2D матрицы/векторы из структур
%
%   Использование:
%       allVars = getAllNumericVariables()
%
%   Возвращает:
%       allVars - структура с полями:
%         .names - cell array имен переменных для отображения в dropdown
%         .paths - cell array полных путей для загрузки
%         .types - cell array типов ('direct' или 'struct')
%
%   Описание:
%       Получает список всех переменных из workspace и находит:
%       1. Прямые числовые 2D матрицы (MxN, M>1, N>1)
%       2. Прямые числовые векторы (1xK или Kx1, K>1)
%       3. Числовые 2D матрицы/векторы внутри структур (рекурсивно)
%       
%       Возвращает объединенный список с указанием типа каждой переменной.
%
%   Пример:
%       % В workspace:
%       data1 = rand(10, 5);
%       experiment.data = rand(20, 3);
%       experiment.results.matrix = rand(15, 4);
%       
%       allVars = getAllNumericVariables();
%       % allVars.names = {'data1', 'experiment.data', 'experiment.results.matrix'}
%       % allVars.paths = {'data1', 'experiment.data', 'experiment.results.matrix'}
%       % allVars.types = {'direct', 'struct', 'struct'}

function allVars = getAllNumericVariables()
    % GETALLNUMERICVARIABLES Получить все числовые переменные
    
    allVars = struct();
    allVars.names = {};
    allVars.paths = {};
    allVars.types = {};
    
    try
        % Получить список всех переменных из workspace
        wsVars = evalin('base', 'whos');
        
        % Обработать каждую переменную
        for i = 1:length(wsVars)
            varName = wsVars(i).name;
            varClass = wsVars(i).class;
            
            % Проверить, что переменная числовая
            if strcmp(varClass, 'double') || ...
               strcmp(varClass, 'single') || ...
               strcmp(varClass, 'int8') || ...
               strcmp(varClass, 'uint8') || ...
               strcmp(varClass, 'int16') || ...
               strcmp(varClass, 'uint16') || ...
               strcmp(varClass, 'int32') || ...
               strcmp(varClass, 'uint32') || ...
               strcmp(varClass, 'int64') || ...
               strcmp(varClass, 'uint64')
                
                % Проверить, что это 2D матрица или вектор (исключить скаляры)
                sz = wsVars(i).size;
                if numel(sz) == 2
                    isMatrix2D = (sz(1) > 1 && sz(2) > 1);
                    isVector1D = ((sz(1) == 1 && sz(2) > 1) || (sz(2) == 1 && sz(1) > 1));
                    if isMatrix2D || isVector1D
                        allVars.names{end+1} = varName;
                        allVars.paths{end+1} = varName;
                        allVars.types{end+1} = 'direct';
                    end
                end
                
            elseif strcmp(varClass, 'struct')
                % Это структура - найти числовые поля внутри
                try
                    structVar = evalin('base', varName);
                    structPaths = findNumericFieldsInStruct(structVar, varName);
                    
                    % Добавить найденные пути
                    for j = 1:length(structPaths)
                        allVars.names{end+1} = structPaths{j};
                        allVars.paths{end+1} = structPaths{j};
                        allVars.types{end+1} = 'struct';
                    end
                catch ME
                    % Игнорировать ошибки при обработке структуры
                    % (например, если структура содержит недопустимые данные)
                    fprintf('Предупреждение: не удалось обработать структуру %s: %s\n', ...
                        varName, ME.message);
                end
            end
        end
        
        % Отсортировать список (прямые переменные сначала, затем из структур)
        if ~isempty(allVars.names)
            % Создать индексы для сортировки
            directIndices = strcmp(allVars.types, 'direct');
            structIndices = strcmp(allVars.types, 'struct');
            
            % Переупорядочить: сначала прямые, затем из структур
            sortedNames = [allVars.names(directIndices), allVars.names(structIndices)];
            sortedPaths = [allVars.paths(directIndices), allVars.paths(structIndices)];
            sortedTypes = [allVars.types(directIndices), allVars.types(structIndices)];
            
            allVars.names = sortedNames;
            allVars.paths = sortedPaths;
            allVars.types = sortedTypes;
        end
        
    catch ME
        fprintf('Ошибка получения переменных: %s\n', ME.message);
        % Вернуть пустую структуру при ошибке
        allVars.names = {};
        allVars.paths = {};
        allVars.types = {};
    end
end


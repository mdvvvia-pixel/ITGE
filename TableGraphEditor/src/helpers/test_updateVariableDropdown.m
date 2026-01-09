%% TEST_UPDATEVARIABLEDROPDOWN Простой тест функции updateVariableDropdown
%   Тестирует логику фильтрации без реального app объекта
%
%   Использование:
%       test_updateVariableDropdown

function test_updateVariableDropdown()
    % TEST_UPDATEVARIABLEDROPDOWN Тест функции
    
    fprintf('=== Тест updateVariableDropdown ===\n\n');
    
    % Создать тестовые переменные в workspace
    fprintf('1. Создание тестовых переменных...\n');
    assignin('base', 'testMatrix2D', rand(10, 5));
    assignin('base', 'testMatrix1D', rand(10, 1));
    assignin('base', 'testScalar', 5);
    fprintf('   ✓ Создано 3 тестовые переменные\n\n');
    
    % Тест получения переменных
    fprintf('2. Получение переменных через whos...\n');
    try
        wsVars = evalin('base', 'whos');
        fprintf('   ✓ Получено %d переменных из workspace\n', length(wsVars));
    catch ME
        fprintf('   ✗ Ошибка: %s\n', ME.message);
        return;
    end
    fprintf('\n');
    
    % Тест фильтрации (используем ту же логику, что и в функции)
    fprintf('3. Фильтрация 2D матриц (исключая скаляры и векторы)...\n');
    numericVars = {};
    skipped = {};
    for i = 1:length(wsVars)
        if strcmp(wsVars(i).class, 'double') || ...
           strcmp(wsVars(i).class, 'single') || ...
           strcmp(wsVars(i).class, 'int8') || ...
           strcmp(wsVars(i).class, 'uint8') || ...
           strcmp(wsVars(i).class, 'int16') || ...
           strcmp(wsVars(i).class, 'uint16') || ...
           strcmp(wsVars(i).class, 'int32') || ...
           strcmp(wsVars(i).class, 'uint32') || ...
           strcmp(wsVars(i).class, 'int64') || ...
           strcmp(wsVars(i).class, 'uint64')
            
            % Проверка: оба размера должны быть > 1
            if length(wsVars(i).size) == 2 && ...
               wsVars(i).size(1) > 1 && ...
               wsVars(i).size(2) > 1
                numericVars{end+1} = wsVars(i).name;
                fprintf('   ✓ %s (size=[%s]) - ДОБАВЛЕНА\n', ...
                    wsVars(i).name, num2str(wsVars(i).size));
            else
                skipped{end+1} = wsVars(i).name;
                fprintf('   - %s (size=[%s]) - ПРОПУЩЕНА\n', ...
                    wsVars(i).name, num2str(wsVars(i).size));
            end
        end
    end
    fprintf('   ✓ Найдено %d 2D матриц, пропущено %d (скаляры/векторы)\n\n', ...
        length(numericVars), length(skipped));
    
    % Тест формирования списка (важно!)
    fprintf('4. Формирование списка для dropdown...\n');
    try
        if ~isempty(numericVars)
            % Правильный способ - использовать { } для создания cell array
            items = [{'Select variable...'}, numericVars];
            itemsData = [{''}, numericVars];
            
            fprintf('   ✓ Items создан: %d элементов\n', length(items));
            fprintf('   ✓ ItemsData создан: %d элементов\n', length(itemsData));
            
            % Показать элементы
            fprintf('   Элементы Items:\n');
            for i = 1:length(items)
                fprintf('     [%d] %s\n', i, items{i});
            end
            
            % Проверить типы
            if iscell(items) && iscell(itemsData)
                fprintf('   ✓ Оба списка являются cell arrays\n');
            else
                fprintf('   ✗ ОШИБКА: списки не являются cell arrays!\n');
            end
        else
            fprintf('   - Список пуст\n');
        end
    catch ME
        fprintf('   ✗ Ошибка: %s\n', ME.message);
        fprintf('   Стек:\n');
        for i = 1:length(ME.stack)
            fprintf('     %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        return;
    end
    
    % Очистка
    evalin('base', 'clear testMatrix2D testMatrix1D testScalar');
    fprintf('\n=== Тест завершен ===\n');
end


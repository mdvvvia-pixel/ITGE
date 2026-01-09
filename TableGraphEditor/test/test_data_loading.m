%% TEST_DATA_LOADING Тест загрузки данных из workspace
%   Тестирует функции загрузки переменных из workspace
%
%   Использование:
%       test_data_loading
%
%   Дата: 2026-01-08

function test_data_loading()
    % TEST_DATA_LOADING Тест загрузки данных
    
    fprintf('=== Тестирование загрузки данных из workspace ===\n\n');
    
    % Сохранить текущее состояние workspace
    fprintf('1. Создание тестовых переменных в workspace...\n');
    
    % Создать тестовые переменные
    testMatrix2D = rand(10, 5);  % 2D матрица - должна быть в списке
    testMatrix1D = rand(10, 1);  % 1D массив - не должна быть в списке
    testScalar = 5;               % Скаляр - не должна быть в списке
    testString = 'test';          % Строка - не должна быть в списке
    testMatrix3D = rand(2, 3, 4); % 3D массив - не должна быть в списке
    
    assignin('base', 'testMatrix2D', testMatrix2D);
    assignin('base', 'testMatrix1D', testMatrix1D);
    assignin('base', 'testScalar', testScalar);
    assignin('base', 'testString', testString);
    assignin('base', 'testMatrix3D', testMatrix3D);
    
    fprintf('   ✓ Создано 5 тестовых переменных\n\n');
    
    % Тест 1: Проверка получения списка переменных через whos
    fprintf('2. Тест получения переменных через whos...\n');
    try
        wsVars = evalin('base', 'whos');
        fprintf('   ✓ whos работает, найдено %d переменных\n', length(wsVars));
        
        % Показать все переменные
        for i = 1:length(wsVars)
            fprintf('   - %s: class=%s, size=[%s]\n', ...
                wsVars(i).name, ...
                wsVars(i).class, ...
                num2str(wsVars(i).size));
        end
    catch ME
        fprintf('   ✗ Ошибка: %s\n', ME.message);
        return;
    end
    fprintf('\n');
    
    % Тест 2: Проверка фильтрации 2D матриц
    fprintf('3. Тест фильтрации 2D матриц...\n');
    try
        numericVars = {};
        for i = 1:length(wsVars)
            % Проверить, что переменная числовая
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
                
                % Проверить, что это 2D матрица
                if length(wsVars(i).size) == 2 && ...
                   all(wsVars(i).size > 0)
                    numericVars{end+1} = wsVars(i).name;
                    fprintf('   ✓ Добавлена: %s (size=[%s])\n', ...
                        wsVars(i).name, num2str(wsVars(i).size));
                else
                    fprintf('   - Пропущена: %s (size=[%s] - не 2D)\n', ...
                        wsVars(i).name, num2str(wsVars(i).size));
                end
            end
        end
        
        fprintf('   ✓ Найдено %d 2D матриц: %s\n', ...
            length(numericVars), strjoin(numericVars, ', '));
        
        % Проверить, что testMatrix2D есть в списке
        if ismember('testMatrix2D', numericVars)
            fprintf('   ✓ testMatrix2D присутствует в списке\n');
        else
            fprintf('   ✗ ОШИБКА: testMatrix2D отсутствует в списке!\n');
        end
        
        % Проверить, что testMatrix1D НЕ в списке
        if ~ismember('testMatrix1D', numericVars)
            fprintf('   ✓ testMatrix1D правильно исключена из списка\n');
        else
            fprintf('   ✗ ОШИБКА: testMatrix1D присутствует в списке (не должна быть)!\n');
        end
        
    catch ME
        fprintf('   ✗ Ошибка фильтрации: %s\n', ME.message);
        return;
    end
    fprintf('\n');
    
    % Тест 3: Проверка формирования списка для dropdown
    fprintf('4. Тест формирования списка для dropdown...\n');
    try
        if ~isempty(numericVars)
            % Правильный способ конкатенации cell arrays
            items = [{'Select variable...'}, numericVars];
            itemsData = [{''}, numericVars];
            
            fprintf('   ✓ Список Items создан: %d элементов\n', length(items));
            fprintf('   ✓ Список ItemsData создан: %d элементов\n', length(itemsData));
            
            % Показать первые несколько элементов
            fprintf('   Первые элементы Items:\n');
            for i = 1:min(3, length(items))
                fprintf('     - %s\n', items{i});
            end
        else
            fprintf('   - Список пуст, используется сообщение по умолчанию\n');
        end
    catch ME
        fprintf('   ✗ Ошибка формирования списка: %s\n', ME.message);
        fprintf('   Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('     - %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        return;
    end
    fprintf('\n');
    
    % Тест 4: Проверка валидации данных
    fprintf('5. Тест валидации данных...\n');
    try
        testData = evalin('base', 'testMatrix2D');
        
        % Проверка валидации
        if isnumeric(testData) && ismatrix(testData) && ~isempty(testData)
            fprintf('   ✓ testMatrix2D прошла валидацию (numeric && ismatrix && ~empty)\n');
        else
            fprintf('   ✗ testMatrix2D НЕ прошла валидацию\n');
        end
        
        % Проверка 1D массива (не должен проходить)
        testData1D = evalin('base', 'testMatrix1D');
        if isnumeric(testData1D) && ~ismatrix(testData1D)
            fprintf('   ✓ testMatrix1D правильно исключена (ismatrix возвращает false для 1D)\n');
        else
            fprintf('   ⚠ testMatrix1D: isnumeric=%d, ismatrix=%d\n', ...
                isnumeric(testData1D), ismatrix(testData1D));
        end
        
    catch ME
        fprintf('   ✗ Ошибка валидации: %s\n', ME.message);
        return;
    end
    fprintf('\n');
    
    fprintf('=== Тестирование завершено ===\n');
    
    % Очистка тестовых переменных (опционально)
    fprintf('\nОчистить тестовые переменные? (y/n): ');
    % Для автоматического теста просто очистим
    evalin('base', 'clear testMatrix2D testMatrix1D testScalar testString testMatrix3D');
    fprintf('✓ Тестовые переменные очищены\n');
end


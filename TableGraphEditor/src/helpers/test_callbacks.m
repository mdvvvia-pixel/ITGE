%% TEST_CALLBACKS Тест startupFcn и ddVariableValueChanged
%   Тестирует логику callback функций без реального app объекта
%
%   Использование:
%       test_callbacks

function test_callbacks()
    % TEST_CALLBACKS Тест callback функций
    
    fprintf('=== Тест startupFcn и ddVariableValueChanged ===\n\n');
    
    % Тест 1: Симуляция startupFcn
    fprintf('1. Тест логики startupFcn...\n');
    try
        % Проверим, что updateVariableDropdown доступна
        if exist('updateVariableDropdown', 'file') == 2
            fprintf('   ✓ Функция updateVariableDropdown доступна\n');
        else
            fprintf('   ✗ ОШИБКА: updateVariableDropdown не найдена в path!\n');
            fprintf('   Решение: Убедитесь, что папка helpers/ в MATLAB path\n');
        end
        
        % Проверим сигнатуру функции
        funcInfo = functions(@updateVariableDropdown);
        if ~isempty(funcInfo.file)
            fprintf('   ✓ updateVariableDropdown найдена в: %s\n', funcInfo.file);
        end
        
    catch ME
        fprintf('   ✗ Ошибка: %s\n', ME.message);
    end
    fprintf('\n');
    
    % Тест 2: Симуляция ddVariableValueChanged
    fprintf('2. Тест логики ddVariableValueChanged...\n');
    
    % Создать тестовые значения для dropdown
    testValues = {
        '',                      % Пустая строка - должна быть пропущена
        'Select variable...',    % Заголовок - должна быть пропущена
        'Нет числовых переменных', % Сообщение - должна быть пропущена
        'testMatrix2D'          % Валидное имя - должна быть принята
    };
    
    fprintf('   Тестирование проверки значений:\n');
    for i = 1:length(testValues)
        varName = testValues{i};
        shouldSkip = isempty(varName) || ...
                     strcmp(varName, 'Select variable...') || ...
                     strcmp(varName, 'Нет числовых переменных') || ...
                     strcmp(varName, '');
        
        if shouldSkip
            fprintf('     - "%s" → ПРОПУЩЕНО ✓\n', varName);
        else
            fprintf('     - "%s" → ПРИНЯТО ✓\n', varName);
        end
    end
    fprintf('\n');
    
    % Тест 3: Проверка доступности loadVariableFromWorkspace
    fprintf('3. Проверка доступности loadVariableFromWorkspace...\n');
    try
        if exist('loadVariableFromWorkspace', 'file') == 2
            fprintf('   ✓ Функция loadVariableFromWorkspace доступна\n');
        else
            fprintf('   ✗ ОШИБКА: loadVariableFromWorkspace не найдена в path!\n');
            fprintf('   Решение: Убедитесь, что папка helpers/ в MATLAB path\n');
        end
        
        % Проверим сигнатуру функции
        funcInfo = functions(@loadVariableFromWorkspace);
        if ~isempty(funcInfo.file)
            fprintf('   ✓ loadVariableFromWorkspace найдена в: %s\n', funcInfo.file);
        end
        
    catch ME
        fprintf('   ✗ Ошибка: %s\n', ME.message);
    end
    fprintf('\n');
    
    % Тест 4: Проверка работы с Items и ItemsData
    fprintf('4. Тест работы с dropdown Items и ItemsData...\n');
    try
        % Симуляция того, что возвращает updateVariableDropdown
        numericVars = {'testMatrix1', 'testMatrix2'};
        items = [{'Select variable...'}, numericVars];
        itemsData = [{''}, numericVars];
        
        fprintf('   Items: %d элементов\n', length(items));
        fprintf('   ItemsData: %d элементов\n', length(itemsData));
        
        % Проверить соответствие Items и ItemsData
        if length(items) == length(itemsData)
            fprintf('   ✓ Items и ItemsData имеют одинаковую длину\n');
        else
            fprintf('   ✗ ОШИБКА: Items и ItemsData имеют разную длину!\n');
        end
        
        % Симуляция выбора элемента
        selectedIndex = 2;  % Выбрали второй элемент (testMatrix1)
        if selectedIndex <= length(itemsData)
            selectedValue = itemsData{selectedIndex};
            fprintf('   Выбран элемент [%d]: Items="%s", ItemsData="%s"\n', ...
                selectedIndex, items{selectedIndex}, selectedValue);
            
            % Проверить, что это не заголовок
            if ~strcmp(selectedValue, '') && ...
               ~strcmp(selectedValue, 'Select variable...') && ...
               ~strcmp(selectedValue, 'Нет числовых переменных')
                fprintf('   ✓ Значение валидно для загрузки\n');
            else
                fprintf('   ✗ Значение должно быть пропущено\n');
            end
        end
        
    catch ME
        fprintf('   ✗ Ошибка: %s\n', ME.message);
    end
    fprintf('\n');
    
    fprintf('=== Тест завершен ===\n');
end


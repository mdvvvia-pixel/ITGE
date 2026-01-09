%% TEST_DROPDOWN_CALLBACK Тест работы callback ddVariableValueChanged
%   Тестирует, правильно ли работает callback при выборе переменной
%
%   Использование:
%       test_dropdown_callback

function test_dropdown_callback()
    % TEST_DROPDOWN_CALLBACK Тест callback
    
    fprintf('=== Тест callback ddVariableValueChanged ===\n\n');
    
    try
        % 1. Создать тестовые переменные в workspace
        fprintf('1. Создание тестовых переменных...\n');
        testData = rand(10, 5);
        assignin('base', 'testData', testData);
        fprintf('   ✓ Создана переменная testData (size=[%s])\n', num2str(size(testData)));
        fprintf('\n');
        
        % 2. Запустить приложение
        fprintf('2. Запуск приложения...\n');
        scriptPath = fileparts(mfilename('fullpath'));
        appDir = fullfile(scriptPath, '..');
        cd(appDir);
        
        % Добавить helpers в path
        addpath(scriptPath);
        
        app = TableGraphEditor;
        fprintf('   ✓ Приложение запущено\n');
        fprintf('\n');
        
        % 3. Проверить, что dropdown инициализирован
        fprintf('3. Проверка инициализации dropdown...\n');
        if isprop(app, 'ddVariable') && isvalid(app.ddVariable)
            fprintf('   ✓ ddVariable найден и валиден\n');
            fprintf('   Items: %d элементов\n', length(app.ddVariable.Items));
            fprintf('   Items: %s\n', strjoin(app.ddVariable.Items, ', '));
            
            % Проверить, что testData в списке
            if any(contains(app.ddVariable.Items, 'testData'))
                fprintf('   ✓ testData присутствует в списке\n');
            else
                fprintf('   ⚠ testData отсутствует в списке\n');
                fprintf('   Попытка обновить список...\n');
                updateVariableDropdown(app);
                fprintf('   Items после обновления: %d элементов\n', length(app.ddVariable.Items));
            end
        else
            fprintf('   ✗ ddVariable не найден или не валиден\n');
            delete(app);
            return;
        end
        fprintf('\n');
        
        % 4. Проверить callback
        fprintf('4. Проверка callback ddVariableValueChanged...\n');
        if ismethod(app, 'ddVariableValueChanged')
            fprintf('   ✓ Метод ddVariableValueChanged найден\n');
        else
            fprintf('   ✗ Метод ddVariableValueChanged НЕ найден!\n');
            fprintf('   Проверьте, что callback добавлен в .mlapp файл\n');
            delete(app);
            return;
        end
        
        % Проверить, что callback назначен
        if isprop(app.ddVariable, 'ValueChangedFcn') && ...
           ~isempty(app.ddVariable.ValueChangedFcn)
            fprintf('   ✓ Callback назначен в ValueChangedFcn\n');
            funcInfo = functions(app.ddVariable.ValueChangedFcn);
            fprintf('   Callback: %s\n', funcInfo.function);
        else
            fprintf('   ✗ Callback НЕ назначен в ValueChangedFcn!\n');
            fprintf('   Это проблема! Callback нужно настроить в Design View\n');
        end
        fprintf('\n');
        
        % 5. Симуляция выбора переменной
        fprintf('5. Симуляция выбора переменной...\n');
        
        % Найти testData в списке
        testDataIndex = find(contains(app.ddVariable.Items, 'testData'), 1);
        
        if isempty(testDataIndex)
            fprintf('   ⚠ testData не найден в списке, используем первый валидный элемент\n');
            % Найти первый элемент, который не является заголовком
            validIndices = find(~contains(app.ddVariable.Items, 'Select') & ...
                               ~contains(app.ddVariable.Items, 'Нет'));
            if ~isempty(validIndices)
                testDataIndex = validIndices(1);
                selectedVar = app.ddVariable.Items{testDataIndex};
                fprintf('   Выбран: %s\n', selectedVar);
            else
                fprintf('   ✗ Нет валидных переменных для теста\n');
                delete(app);
                return;
            end
        else
            selectedVar = app.ddVariable.Items{testDataIndex};
            fprintf('   ✓ testData найден в списке (index %d)\n', testDataIndex);
        end
        
        % Установить значение dropdown
        if ~isempty(app.ddVariable.ItemsData) && ...
           length(app.ddVariable.ItemsData) >= testDataIndex
            app.ddVariable.Value = app.ddVariable.ItemsData{testDataIndex};
            fprintf('   ✓ Значение установлено через ItemsData: %s\n', ...
                app.ddVariable.ItemsData{testDataIndex});
        else
            app.ddVariable.Value = app.ddVariable.Items{testDataIndex};
            fprintf('   ✓ Значение установлено через Items: %s\n', ...
                app.ddVariable.Items{testDataIndex});
        end
        
        fprintf('   Текущее значение dropdown: %s\n', app.ddVariable.Value);
        fprintf('\n');
        
        % 6. Проверить, что данные загрузились
        fprintf('6. Проверка загрузки данных...\n');
        
        % Подождать немного, чтобы callback мог выполниться
        pause(0.5);
        
        if isprop(app, 'currentData')
            try
                if ~isempty(app.currentData)
                    fprintf('   ✓ currentData не пуст (size=[%s])\n', num2str(size(app.currentData)));
                else
                    fprintf('   ✗ currentData пуст! Данные не загрузились\n');
                end
            catch
                fprintf('   ✗ Ошибка доступа к currentData\n');
            end
        else
            fprintf('   ✗ Свойство currentData не найдено\n');
        end
        
        if isprop(app, 'selectedVariable')
            try
                if ~isempty(app.selectedVariable)
                    fprintf('   ✓ selectedVariable установлен: %s\n', app.selectedVariable);
                else
                    fprintf('   ✗ selectedVariable пуст!\n');
                end
            catch
                fprintf('   ✗ Ошибка доступа к selectedVariable\n');
            end
        else
            fprintf('   ✗ Свойство selectedVariable не найдено\n');
        end
        
        % Проверить таблицу
        if isprop(app, 'tblData') && isvalid(app.tblData)
            try
                if ~isempty(app.tblData.Data)
                    fprintf('   ✓ Таблица содержит данные (size=[%s])\n', ...
                        num2str(size(app.tblData.Data)));
                else
                    fprintf('   ✗ Таблица пуста! Данные не обновились\n');
                end
            catch
                fprintf('   ✗ Ошибка доступа к таблице\n');
            end
        else
            fprintf('   ⚠ Компонент tblData не найден или не валиден\n');
        end
        fprintf('\n');
        
        % 7. Рекомендации
        fprintf('=== Рекомендации ===\n');
        if isempty(app.selectedVariable) || isempty(app.currentData)
            fprintf('✗ Callback не сработал или работает неправильно\n');
            fprintf('\nПроверьте:\n');
            fprintf('1. В Design View выберите компонент ddVariable\n');
            fprintf('2. В Property Inspector найдите "ValueChangedFcn"\n');
            fprintf('3. Убедитесь, что там выбрано: @app.ddVariableValueChanged\n');
            fprintf('4. Сохраните файл и перезапустите приложение\n');
        else
            fprintf('✓ Callback работает корректно!\n');
        end
        fprintf('\n');
        
        % Закрыть приложение
        fprintf('Закрытие приложения...\n');
        delete(app);
        fprintf('✓ Приложение закрыто\n');
        
        % Очистить тестовые переменные
        evalin('base', 'clear testData');
        
    catch ME
        fprintf('✗ Ошибка в тесте: %s\n', ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        
        % Попытка закрыть приложение, если оно открыто
        if exist('app', 'var') && isvalid(app)
            try
                delete(app);
            catch
            end
        end
    end
    
    fprintf('\n=== Тест завершен ===\n');
end


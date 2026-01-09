%% TEST_REAL_SCENARIO Реальный сценарий использования
%   Тестирует реальный сценарий: запуск приложения и выбор переменной

function test_real_scenario()
    % TEST_REAL_SCENARIO Реальный сценарий
    
    fprintf('=== Реальный сценарий использования ===\n\n');
    
    try
        % 1. Создать тестовую переменную
        fprintf('1. Создание тестовой переменной...\n');
        testData = rand(10, 3);
        assignin('base', 'aa', testData);
        fprintf('   ✓ Переменная aa создана (size=[%s])\n\n', num2str(size(testData)));
        
        % 2. Запустить приложение
        fprintf('2. Запуск приложения...\n');
        scriptPath = fileparts(mfilename('fullpath'));
        appDir = fullfile(scriptPath, '..');
        cd(appDir);
        addpath(scriptPath);
        
        app = TableGraphEditor_exported;
        pause(1);  % Подождать инициализацию
        fprintf('   ✓ Приложение запущено\n\n');
        
        % 3. Проверить список переменных
        fprintf('3. Проверка списка переменных:\n');
        if isprop(app, 'ddVariable') && isvalid(app.ddVariable)
            fprintf('   Dropdown Items: %s\n', strjoin(app.ddVariable.Items, ', '));
            if any(contains(app.ddVariable.Items, 'aa'))
                fprintf('   ✓ aa найден в списке\n');
            else
                fprintf('   ✗ aa НЕ найден в списке!\n');
            end
        else
            fprintf('   ✗ Dropdown не найден или не валиден\n');
        end
        fprintf('\n');
        
        % 4. Симулировать выбор переменной (как пользователь)
        fprintf('4. Симуляция выбора переменной aa...\n');
        if isprop(app, 'ddVariable') && isvalid(app.ddVariable)
            try
                % Найти индекс
                idx = find(contains(app.ddVariable.Items, 'aa'), 1);
                if ~isempty(idx)
                    fprintf('   Найден индекс: %d\n', idx);
                    
                    % Установить значение
                    if ~isempty(app.ddVariable.ItemsData) && length(app.ddVariable.ItemsData) >= idx
                        app.ddVariable.Value = app.ddVariable.ItemsData{idx};
                    else
                        app.ddVariable.Value = app.ddVariable.Items{idx};
                    end
                    fprintf('   ✓ Значение установлено: %s\n', char(app.ddVariable.Value));
                    
                    % Подождать выполнения callback
                    fprintf('   Ожидание выполнения callback...\n');
                    pause(2);
                    
                else
                    fprintf('   ✗ aa не найден в списке\n');
                end
            catch ME
                fprintf('   ✗ Ошибка установки значения: %s\n', ME.message);
            end
        end
        fprintf('\n');
        
        % 5. Проверить результат
        fprintf('5. Проверка результата:\n');
        
        % Данные
        if isprop(app, 'currentData')
            try
                if ~isempty(app.currentData)
                    fprintf('   ✓ currentData установлен: size=[%s]\n', num2str(size(app.currentData)));
                    if isequal(app.currentData, testData)
                        fprintf('   ✓ Данные совпадают с исходными\n');
                    else
                        fprintf('   ⚠ Данные НЕ совпадают с исходными\n');
                    end
                else
                    fprintf('   ✗ currentData пуст!\n');
                end
            catch ME
                fprintf('   ✗ Ошибка доступа к currentData: %s\n', ME.message);
            end
        end
        
        % Переменная
        if isprop(app, 'selectedVariable')
            try
                if ~isempty(app.selectedVariable)
                    fprintf('   ✓ selectedVariable: %s\n', app.selectedVariable);
                else
                    fprintf('   ✗ selectedVariable пуст!\n');
                end
            catch ME
                fprintf('   ✗ Ошибка доступа к selectedVariable: %s\n', ME.message);
            end
        end
        
        % Таблица
        if isprop(app, 'tblData') && isvalid(app.tblData)
            try
                tableData = app.tblData.Data;
                if ~isempty(tableData)
                    fprintf('   ✓ Таблица заполнена: size=[%s]\n', num2str(size(tableData)));
                else
                    fprintf('   ✗ Таблица пуста!\n');
                end
            catch ME
                fprintf('   ✗ Ошибка доступа к таблице: %s\n', ME.message);
            end
        end
        
        % График
        if isprop(app, 'axPlot') && isvalid(app.axPlot)
            try
                children = app.axPlot.Children;
                if ~isempty(children)
                    fprintf('   ✓ График содержит %d элементов\n', length(children));
                else
                    fprintf('   ✗ График пуст!\n');
                end
            catch ME
                fprintf('   ✗ Ошибка доступа к графику: %s\n', ME.message);
            end
        end
        fprintf('\n');
        
        fprintf('=== Тест завершен ===\n');
        fprintf('Приложение оставлено открытым. Выполните: delete(app)\n');
        
    catch ME
        fprintf('✗ Критическая ошибка: %s\n', ME.message);
        fprintf('Стек:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end


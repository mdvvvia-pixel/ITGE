%% TEST_WITH_MANUAL_CALL Тест с явным вызовом callback
%   Тестирует с явным вызовом callback для проверки работы

function test_with_manual_call()
    % TEST_WITH_MANUAL_CALL Тест
    
    fprintf('=== Тест с явным вызовом callback ===\n\n');
    
    try
        % 1. Создать тестовую переменную
        fprintf('1. Создание тестовой переменной...\n');
        testData = rand(10, 3);
        assignin('base', 'aa', testData);
        fprintf('   ✓ Переменная aa создана\n\n');
        
        % 2. Запустить приложение
        fprintf('2. Запуск приложения...\n');
        scriptPath = fileparts(mfilename('fullpath'));
        appDir = fullfile(scriptPath, '..');
        cd(appDir);
        addpath(scriptPath);
        
        app = TableGraphEditor_exported;
        pause(1);
        fprintf('   ✓ Приложение запущено\n\n');
        
        % 3. Проверить callback
        fprintf('3. Проверка callback...\n');
        if isprop(app, 'ddVariable') && isvalid(app.ddVariable)
            callbackFcn = app.ddVariable.ValueChangedFcn;
            if ~isempty(callbackFcn)
                fprintf('   ✓ Callback назначен\n');
            else
                fprintf('   ✗ Callback НЕ назначен!\n');
                return;
            end
        end
        fprintf('\n');
        
        % 4. Установить значение и вызвать callback вручную
        fprintf('4. Установка значения и вызов callback вручную...\n');
        if isprop(app, 'ddVariable') && isvalid(app.ddVariable)
            try
                % Установить значение
                idx = find(contains(app.ddVariable.Items, 'aa'), 1);
                if ~isempty(idx)
                    if ~isempty(app.ddVariable.ItemsData) && length(app.ddVariable.ItemsData) >= idx
                        app.ddVariable.Value = app.ddVariable.ItemsData{idx};
                    else
                        app.ddVariable.Value = app.ddVariable.Items{idx};
                    end
                    fprintf('   ✓ Значение установлено: %s\n', char(app.ddVariable.Value));
                    
                    % Вызвать callback вручную
                    fprintf('   Вызов callback вручную...\n');
                    try
                        event = struct('Value', app.ddVariable.Value, 'PreviousValue', app.ddVariable.Items{1});
                        app.ddVariableValueChanged(app, event);
                        fprintf('   ✓ Callback вызван вручную\n');
                    catch ME
                        fprintf('   ✗ Ошибка вызова callback: %s\n', ME.message);
                        fprintf('   Стек:\n');
                        for i = 1:length(ME.stack)
                            fprintf('     %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
                        end
                    end
                    
                    pause(1);
                end
            catch ME
                fprintf('   ✗ Ошибка: %s\n', ME.message);
            end
        end
        fprintf('\n');
        
        % 5. Проверить результат
        fprintf('5. Проверка результата:\n');
        
        if isprop(app, 'currentData')
            try
                if ~isempty(app.currentData)
                    fprintf('   ✓ currentData установлен: size=[%s]\n', num2str(size(app.currentData)));
                else
                    fprintf('   ✗ currentData пуст!\n');
                end
            catch ME
                fprintf('   ✗ Ошибка доступа: %s\n', ME.message);
            end
        end
        
        if isprop(app, 'selectedVariable')
            try
                if ~isempty(app.selectedVariable)
                    fprintf('   ✓ selectedVariable: %s\n', app.selectedVariable);
                else
                    fprintf('   ✗ selectedVariable пуст!\n');
                end
            catch ME
                fprintf('   ✗ Ошибка доступа: %s\n', ME.message);
            end
        end
        
        if isprop(app, 'tblData') && isvalid(app.tblData)
            try
                tableData = app.tblData.Data;
                if ~isempty(tableData)
                    fprintf('   ✓ Таблица заполнена: size=[%s]\n', num2str(size(tableData)));
                else
                    fprintf('   ✗ Таблица пуста!\n');
                end
            catch ME
                fprintf('   ✗ Ошибка доступа: %s\n', ME.message);
            end
        end
        
        fprintf('\n=== Тест завершен ===\n');
        
    catch ME
        fprintf('✗ Ошибка: %s\n', ME.message);
    end
end


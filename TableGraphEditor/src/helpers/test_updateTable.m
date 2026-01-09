%% TEST_UPDATETABLE Тест updateTableWithData
%   Тестирует обновление таблицы напрямую

function test_updateTable()
    % TEST_UPDATETABLE Тест
    
    fprintf('=== Тест updateTableWithData ===\n\n');
    
    try
        % 1. Запустить приложение
        fprintf('1. Запуск приложения...\n');
        scriptPath = fileparts(mfilename('fullpath'));
        appDir = fullfile(scriptPath, '..');
        cd(appDir);
        addpath(scriptPath);
        
        app = TableGraphEditor_exported;
        pause(0.5);
        fprintf('   ✓ Приложение запущено\n\n');
        
        % 2. Установить данные напрямую
        fprintf('2. Установка данных напрямую...\n');
        testData = rand(10, 3);
        app.currentData = testData;
        app.selectedVariable = 'aa';
        fprintf('   ✓ Данные установлены: size=[%s]\n', num2str(size(testData)));
        fprintf('   Проверка app.currentData: size=[%s], empty=%d\n', ...
            num2str(size(app.currentData)), isempty(app.currentData));
        fprintf('\n');
        
        % 3. Вызвать updateTableWithData
        fprintf('3. Вызов updateTableWithData...\n');
        try
            updateTableWithData(app);
            fprintf('   ✓ Функция выполнена\n\n');
        catch ME
            fprintf('   ✗ Ошибка: %s\n', ME.message);
            fprintf('   Стек:\n');
            for i = 1:length(ME.stack)
                fprintf('     %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
            end
            fprintf('\n');
        end
        
        % 4. Проверить таблицу
        fprintf('4. Проверка таблицы:\n');
        if isprop(app, 'tblData') && isvalid(app.tblData)
            try
                tableData = app.tblData.Data;
                fprintf('   Таблица Data: size=[%s]\n', num2str(size(tableData)));
                if ~isempty(tableData)
                    fprintf('   ✓ Таблица содержит данные\n');
                    fprintf('   Первые элементы: %s\n', mat2str(tableData(1:min(3,size(tableData,1)), 1:min(3,size(tableData,2)))));
                else
                    fprintf('   ✗ Таблица пуста!\n');
                end
            catch ME
                fprintf('   ✗ Ошибка доступа: %s\n', ME.message);
            end
        else
            fprintf('   ✗ Таблица не найдена или не валидна\n');
        end
        fprintf('\n');
        
        % 5. Попытка установить данные напрямую в таблицу
        fprintf('5. Попытка установить данные напрямую в таблицу...\n');
        try
            app.tblData.Data = testData;
            fprintf('   ✓ Данные установлены напрямую\n');
            fprintf('   Проверка: size=[%s]\n', num2str(size(app.tblData.Data)));
            
            if isequal(app.tblData.Data, testData)
                fprintf('   ✓ Данные совпадают\n');
            else
                fprintf('   ✗ Данные НЕ совпадают!\n');
            end
        catch ME
            fprintf('   ✗ Ошибка: %s\n', ME.message);
        end
        fprintf('\n');
        
        fprintf('=== Тест завершен ===\n');
        
    catch ME
        fprintf('✗ Ошибка: %s\n', ME.message);
    end
end


%% TEST_LOADVARIABLEDIRECT Прямой тест loadVariableFromWorkspace
%   Тестирует функцию напрямую, чтобы найти проблему

function test_loadVariableDirect()
    % TEST_LOADVARIABLEDIRECT Прямой тест
    
    fprintf('=== Прямой тест loadVariableFromWorkspace ===\n\n');
    
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
        pause(0.5);
        fprintf('   ✓ Приложение запущено\n\n');
        
        % 3. Проверить свойства перед вызовом
        fprintf('3. Состояние до вызова loadVariableFromWorkspace:\n');
        fprintf('   currentData: %s\n', mat2str(size(app.currentData)));
        fprintf('   selectedVariable: %s\n', mat2str(app.selectedVariable));
        fprintf('\n');
        
        % 4. Вызвать функцию напрямую
        fprintf('4. Прямой вызов loadVariableFromWorkspace("aa")...\n');
        try
            loadVariableFromWorkspace(app, 'aa');
            fprintf('   ✓ Функция выполнена без ошибок\n\n');
        catch ME
            fprintf('   ✗ Ошибка: %s\n', ME.message);
            fprintf('   Стек:\n');
            for i = 1:length(ME.stack)
                fprintf('     %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
            end
            fprintf('\n');
        end
        
        % 5. Проверить свойства после вызова
        fprintf('5. Состояние после вызова loadVariableFromWorkspace:\n');
        
        % Проверить currentData
        if isprop(app, 'currentData')
            try
                data = app.currentData;
                if ~isempty(data)
                    fprintf('   ✓ currentData установлен: size=[%s]\n', num2str(size(data)));
                    fprintf('   ✓ Данные совпадают: %d\n', isequal(data, testData));
                else
                    fprintf('   ✗ currentData пуст!\n');
                    
                    % Проверить UserData
                    if isfield(app.UIFigure.UserData, 'appData') && ...
                       isfield(app.UIFigure.UserData.appData, 'currentData')
                        fprintf('   ✓ Данные в UserData: size=[%s]\n', ...
                            num2str(size(app.UIFigure.UserData.appData.currentData)));
                    end
                end
            catch ME
                fprintf('   ✗ Ошибка доступа к currentData: %s\n', ME.message);
            end
        else
            fprintf('   ✗ Свойство currentData не найдено\n');
        end
        
        % Проверить selectedVariable
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
        
        % Проверить таблицу
        if isprop(app, 'tblData') && isvalid(app.tblData)
            try
                tableData = app.tblData.Data;
                if ~isempty(tableData)
                    fprintf('   ✓ Таблица содержит данные: size=[%s]\n', num2str(size(tableData)));
                else
                    fprintf('   ✗ Таблица пуста!\n');
                end
            catch ME
                fprintf('   ✗ Ошибка доступа к таблице: %s\n', ME.message);
            end
        end
        fprintf('\n');
        
        % 6. Попытка установить свойства напрямую
        fprintf('6. Попытка установить свойства напрямую:\n');
        try
            fprintf('   Попытка установить app.currentData = testData...\n');
            app.currentData = testData;
            fprintf('   ✓ Успешно установлено через app.currentData\n');
            fprintf('   Проверка: size=[%s]\n', num2str(size(app.currentData)));
        catch ME
            fprintf('   ✗ Ошибка установки: %s\n', ME.message);
            fprintf('   Проверка SetAccess для currentData...\n');
            
            % Проверить метаданные свойства
            mc = metaclass(app);
            prop = findobj(mc.PropertyList, 'Name', 'currentData');
            if ~isempty(prop)
                fprintf('   SetAccess: %s\n', char(prop.SetAccess));
            end
        end
        fprintf('\n');
        
        % 7. Проверить через UserData
        fprintf('7. Проверка данных через UserData:\n');
        if isfield(app.UIFigure.UserData, 'appData')
            fprintf('   UserData.appData существует\n');
            if isfield(app.UIFigure.UserData.appData, 'currentData')
                fprintf('   ✓ currentData в UserData: size=[%s]\n', ...
                    num2str(size(app.UIFigure.UserData.appData.currentData)));
            else
                fprintf('   ✗ currentData нет в UserData\n');
            end
        else
            fprintf('   ✗ UserData.appData не существует\n');
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


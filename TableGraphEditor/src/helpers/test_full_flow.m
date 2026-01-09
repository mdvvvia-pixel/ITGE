%% TEST_FULL_FLOW Полный тест загрузки данных и отображения
%   Тестирует весь процесс от выбора переменной до отображения

function test_full_flow()
    % TEST_FULL_FLOW Полный тест
    
    fprintf('=== Полный тест загрузки и отображения данных ===\n\n');
    
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
        fprintf('   ✓ Приложение запущено\n\n');
        
        % Подождать немного для инициализации
        pause(0.5);
        
        % 3. Проверить состояние до выбора
        fprintf('3. Состояние до выбора переменной:\n');
        fprintf('   currentData пуст: %d\n', isempty(app.currentData));
        fprintf('   selectedVariable: %s\n', mat2str(app.selectedVariable));
        fprintf('   tblData.Data размер: %s\n', num2str(size(app.tblData.Data)));
        fprintf('\n');
        
        % 4. Симулировать выбор переменной
        fprintf('4. Симуляция выбора переменной aa...\n');
        
        % Найти индекс переменной в списке
        if any(contains(app.ddVariable.Items, 'aa'))
            testDataIndex = find(contains(app.ddVariable.Items, 'aa'), 1);
            fprintf('   ✓ aa найден в списке (index %d)\n', testDataIndex);
            
            % Установить значение
            if ~isempty(app.ddVariable.ItemsData) && ...
               length(app.ddVariable.ItemsData) >= testDataIndex
                app.ddVariable.Value = app.ddVariable.ItemsData{testDataIndex};
                fprintf('   ✓ Значение установлено через ItemsData\n');
            else
                app.ddVariable.Value = app.ddVariable.Items{testDataIndex};
                fprintf('   ✓ Значение установлено через Items\n');
            end
            
            % Подождать, чтобы callback выполнился
            fprintf('   Ожидание выполнения callback...\n');
            pause(1);
            
        else
            fprintf('   ✗ aa не найден в списке\n');
            fprintf('   Доступные элементы: %s\n', strjoin(app.ddVariable.Items, ', '));
            delete(app);
            return;
        end
        fprintf('\n');
        
        % 5. Проверить состояние после выбора
        fprintf('5. Состояние после выбора переменной:\n');
        
        % Проверить currentData
        if isprop(app, 'currentData')
            try
                if ~isempty(app.currentData)
                    fprintf('   ✓ currentData установлен: size=[%s]\n', num2str(size(app.currentData)));
                else
                    fprintf('   ✗ currentData пуст!\n');
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
        else
            fprintf('   ✗ Таблица не найдена или не валидна\n');
        end
        
        % Проверить график
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
        else
            fprintf('   ✗ График не найден или не валиден\n');
        end
        fprintf('\n');
        
        % 6. Проверить доступность helper функций
        fprintf('6. Проверка доступности helper функций:\n');
        helpers = {'loadVariableFromWorkspace', 'updateTableWithData', 'updateGraph', ...
                   'plotByColumns', 'plotByRows'};
        for i = 1:length(helpers)
            if exist(helpers{i}, 'file') == 2
                fprintf('   ✓ %s доступна\n', helpers{i});
            else
                fprintf('   ✗ %s НЕ найдена в path!\n', helpers{i});
            end
        end
        fprintf('\n');
        
        % 7. Ручной тест updateTableWithData
        fprintf('7. Ручной тест updateTableWithData:\n');
        try
            if exist('updateTableWithData', 'file') == 2
                fprintf('   Вызов updateTableWithData...\n');
                updateTableWithData(app);
                fprintf('   ✓ updateTableWithData выполнен\n');
            else
                fprintf('   ✗ updateTableWithData не найдена\n');
            end
        catch ME
            fprintf('   ✗ Ошибка: %s\n', ME.message);
            fprintf('   Стек:\n');
            for i = 1:length(ME.stack)
                fprintf('     %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
            end
        end
        fprintf('\n');
        
        % 8. Ручной тест updateGraph
        fprintf('8. Ручной тест updateGraph:\n');
        try
            if exist('updateGraph', 'file') == 2
                fprintf('   Вызов updateGraph...\n');
                updateGraph(app);
                fprintf('   ✓ updateGraph выполнен\n');
            else
                fprintf('   ✗ updateGraph не найдена\n');
            end
        catch ME
            fprintf('   ✗ Ошибка: %s\n', ME.message);
            fprintf('   Стек:\n');
            for i = 1:length(ME.stack)
                fprintf('     %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
            end
        end
        fprintf('\n');
        
        % 9. Итоги
        fprintf('=== Итоги теста ===\n');
        
        % Проверить финальное состояние
        hasData = ~isempty(app.currentData);
        hasTable = isprop(app, 'tblData') && ~isempty(app.tblData.Data);
        hasGraph = isprop(app, 'axPlot') && ~isempty(app.axPlot.Children);
        
        if hasData
            fprintf('✓ Данные загружены\n');
        else
            fprintf('✗ Данные НЕ загружены\n');
        end
        
        if hasTable
            fprintf('✓ Таблица заполнена\n');
        else
            fprintf('✗ Таблица НЕ заполнена\n');
        end
        
        if hasGraph
            fprintf('✓ График построен\n');
        else
            fprintf('✗ График НЕ построен\n');
        end
        
        fprintf('\nПриложение оставлено открытым для проверки.\n');
        fprintf('Выполните: delete(app) чтобы закрыть\n');
        
        % Не удаляем app, чтобы пользователь мог проверить
        % delete(app);
        
    catch ME
        fprintf('✗ Критическая ошибка: %s\n', ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        
        if exist('app', 'var') && isvalid(app)
            try
                delete(app);
            catch
            end
        end
    end
    
    fprintf('\n=== Тест завершен ===\n');
end


%% RUN_DIAGNOSIS Запуск диагностики приложения
%   Автоматически запускает приложение и выполняет диагностику
%
%   Использование:
%       run_diagnosis

function run_diagnosis()
    % RUN_DIAGNOSIS Запуск диагностики
    
    fprintf('=== Автоматическая диагностика TableGraphEditor ===\n\n');
    
    try
        % 1. Проверить путь к файлу приложения
        fprintf('1. Проверка пути к файлу приложения...\n');
        scriptPath = fileparts(mfilename('fullpath'));
        appPath = fullfile(scriptPath, '..', 'TableGraphEditor.mlapp');
        
        if ~exist(appPath, 'file')
            fprintf('   ✗ Файл не найден: %s\n', appPath);
            fprintf('   Попытка найти файл...\n');
            
            % Попробовать найти в разных местах
            possiblePaths = {
                fullfile(scriptPath, 'TableGraphEditor.mlapp'),
                fullfile(scriptPath, '..', '..', 'src', 'TableGraphEditor.mlapp'),
                'TableGraphEditor.mlapp'
            };
            
            found = false;
            for i = 1:length(possiblePaths)
                if exist(possiblePaths{i}, 'file')
                    appPath = possiblePaths{i};
                    fprintf('   ✓ Найден: %s\n', appPath);
                    found = true;
                    break;
                end
            end
            
            if ~found
                fprintf('   ✗ Файл приложения не найден. Проверьте путь.\n');
                return;
            end
        else
            fprintf('   ✓ Файл найден: %s\n', appPath);
        end
        fprintf('\n');
        
        % 2. Попытка запустить приложение
        fprintf('2. Запуск приложения...\n');
        try
            % Перейти в директорию с файлом
            [appDir, ~, ~] = fileparts(appPath);
            if ~isempty(appDir)
                cd(appDir);
            end
            
            % Добавить helpers в path
            helpersPath = fullfile(scriptPath);
            if ~contains(path, helpersPath)
                addpath(helpersPath);
                fprintf('   ✓ Добавлен путь к helpers: %s\n', helpersPath);
            end
            
            % Попытка создать экземпляр приложения
            fprintf('   Попытка создать экземпляр приложения...\n');
            app = TableGraphEditor;
            fprintf('   ✓ Приложение запущено\n');
            fprintf('\n');
            
            % 3. Запуск диагностики
            fprintf('3. Запуск диагностики компонентов...\n\n');
            DIAGNOSE_DROPDOWN(app);  % Используем правильный регистр
            fprintf('\n');
            
            % 4. Проверка startupFcn
            fprintf('4. Проверка startupFcn...\n');
            try
                % Попытка вызвать startupFcn напрямую
                if ismethod(app, 'startupFcn')
                    fprintf('   ✓ Метод startupFcn найден\n');
                    
                    % Проверим, можно ли вызвать updateVariableDropdown
                    if exist('updateVariableDropdown', 'file') == 2
                        fprintf('   ✓ Функция updateVariableDropdown доступна\n');
                    else
                        fprintf('   ✗ Функция updateVariableDropdown не найдена в path\n');
                        fprintf('   Попытка добавить путь...\n');
                        addpath(helpersPath);
                        if exist('updateVariableDropdown', 'file') == 2
                            fprintf('   ✓ updateVariableDropdown теперь доступна\n');
                        end
                    end
                else
                    fprintf('   ✗ Метод startupFcn не найден\n');
                end
            catch ME
                fprintf('   ✗ Ошибка проверки startupFcn: %s\n', ME.message);
            end
            fprintf('\n');
            
            % 5. Итоговые рекомендации
            fprintf('=== Итоговые рекомендации ===\n');
            
            if isprop(app, 'ddVariable')
                fprintf('✓ Компонент ddVariable найден!\n');
                fprintf('  Проверьте, что он валиден и правильно инициализирован.\n');
            else
                fprintf('✗ Компонент ddVariable НЕ найден!\n');
                fprintf('  Действия:\n');
                fprintf('  1. Откройте TableGraphEditor.mlapp в App Designer\n');
                fprintf('  2. В Design View добавьте компонент Drop Down (uidropdown)\n');
                fprintf('  3. Установите Name = "ddVariable" в Property Inspector\n');
                fprintf('  4. Сохраните файл и перезапустите приложение\n');
            end
            
            % Закрыть приложение, если нужно
            fprintf('\nПриложение оставлено открытым для дальнейшей проверки.\n');
            fprintf('Закройте его вручную или выполните: delete(app)\n');
            
        catch ME
            fprintf('   ✗ Ошибка запуска приложения: %s\n', ME.message);
            fprintf('   Стек ошибки:\n');
            for i = 1:length(ME.stack)
                fprintf('     %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
            end
            fprintf('\n');
            fprintf('Возможные причины:\n');
            fprintf('  1. Файл .mlapp поврежден\n');
            fprintf('  2. Отсутствуют необходимые компоненты\n');
            fprintf('  3. Ошибки в коде приложения\n');
        end
        
    catch ME
        fprintf('Критическая ошибка: %s\n', ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
    
    fprintf('\n=== Диагностика завершена ===\n');
end


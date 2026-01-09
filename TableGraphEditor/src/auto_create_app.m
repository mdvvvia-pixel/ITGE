%% AUTO_CREATE_APP Попытка автоматического создания App Designer файла
%   Этот скрипт пытается создать .mlapp файл программно
%
%   ВНИМАНИЕ: .mlapp файлы требуют GUI App Designer и могут не создаваться
%   полностью программно. Этот скрипт - экспериментальная попытка.
%
%   Использование:
%       auto_create_app

function success = auto_create_app()
    % AUTO_CREATE_APP Попытка автоматического создания приложения
    
    success = false;
    
    fprintf('=== Попытка автоматического создания TableGraphEditor.mlapp ===\n\n');
    
    % Получить путь
    scriptPath = fileparts(mfilename('fullpath'));
    mlappPath = fullfile(scriptPath, 'TableGraphEditor.mlapp');
    
    % Проверить, существует ли уже
    if exist(mlappPath, 'file') == 2
        fprintf('✓ Файл уже существует: %s\n', mlappPath);
        success = true;
        return;
    end
    
    %% Попытка 1: Использование appdesigner с параметрами
    fprintf('Попытка 1: Использование appdesigner()...\n');
    try
        % Открыть App Designer и создать новый файл
        % Примечание: это может открыть GUI, но не создаст файл автоматически
        appdesigner;
        fprintf('  ⚠ App Designer открыт. Создайте файл вручную:\n');
        fprintf('     1. File → New → App\n');
        fprintf('     2. Сохраните как: %s\n', mlappPath);
        fprintf('     3. Следуйте SETUP_INSTRUCTIONS.md\n\n');
    catch ME
        fprintf('  ✗ Ошибка: %s\n\n', ME.message);
    end
    
    %% Попытка 2: Создание через MATLAB API (если доступно)
    fprintf('Попытка 2: Поиск MATLAB API для создания .mlapp...\n');
    
    % Проверить доступность внутренних функций
    if exist('matlab.apputil.create', 'file') == 2
        try
            fprintf('  Найден matlab.apputil.create, попытка использования...\n');
            % Это может не работать, так как требует специфических параметров
            fprintf('  ⚠ Требуются дополнительные параметры\n');
        catch ME
            fprintf('  ✗ Ошибка: %s\n', ME.message);
        end
    else
        fprintf('  ⚠ matlab.apputil.create не найден\n');
    end
    
    %% Попытка 3: Создание минимального .mlapp через структуру
    fprintf('Попытка 3: Создание структуры .mlapp файла...\n');
    
    try
        % .mlapp файлы - это ZIP архивы с XML и другими файлами
        % Это очень сложно создать программно без знания внутренней структуры
        
        fprintf('  ⚠ .mlapp файлы имеют сложную внутреннюю структуру\n');
        fprintf('     (ZIP архив с XML, метаданными и кодом)\n');
        fprintf('     Рекомендуется создание через GUI App Designer\n\n');
        
    catch ME
        fprintf('  ✗ Ошибка: %s\n\n', ME.message);
    end
    
    %% Итоговые рекомендации
    fprintf('=== Рекомендации ===\n\n');
    fprintf('Файлы .mlapp требуют создания через GUI App Designer.\n');
    fprintf('Выполните следующие шаги:\n\n');
    fprintf('1. Запустите MATLAB\n');
    fprintf('2. Выполните: appdesigner\n');
    fprintf('3. File → New → App (выберите Blank App)\n');
    fprintf('4. File → Save As → %s\n', mlappPath);
    fprintf('5. Следуйте инструкциям в SETUP_INSTRUCTIONS.md\n');
    fprintf('6. Используйте APP_STRUCTURE_TEMPLATE.md как справочник\n\n');
    
    fprintf('Альтернатива: Используйте create_app_structure.m для создания\n');
    fprintf('вспомогательных файлов и базового класса.\n\n');
    
    success = false;
end


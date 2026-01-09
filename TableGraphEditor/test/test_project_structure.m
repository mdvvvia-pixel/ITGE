%% TEST_PROJECT_STRUCTURE Проверка структуры проекта
%   Проверяет, что все необходимые папки и файлы созданы
%
%   Пример:
%       test_project_structure

function test_project_structure()
    % TEST_PROJECT_STRUCTURE Проверка структуры проекта
    
    fprintf('=== Проверка структуры проекта TableGraphEditor ===\n\n');
    
    % Получить путь к корню проекта
    projectRoot = fileparts(mfilename('fullpath'));
    projectRoot = fileparts(projectRoot); % Подняться на уровень выше test/
    
    errors = {};
    warnings = {};
    
    %% Проверка папок
    fprintf('Проверка папок...\n');
    
    requiredDirs = {
        'src'
        'src/helpers'
        'test'
        'examples'
        'resources'
        'docs'
    };
    
    for i = 1:length(requiredDirs)
        dirPath = fullfile(projectRoot, requiredDirs{i});
        if exist(dirPath, 'dir') == 7
            fprintf('  ✓ %s\n', requiredDirs{i});
        else
            errorMsg = sprintf('Папка %s не существует', requiredDirs{i});
            errors{end+1} = errorMsg;
            fprintf('  ✗ %s - НЕ НАЙДЕНА\n', requiredDirs{i});
        end
    end
    
    %% Проверка файлов
    fprintf('\nПроверка файлов...\n');
    
    requiredFiles = {
        'README.md'
        'docs/README.md'
        'src/APP_STRUCTURE_TEMPLATE.md'
        'SETUP_INSTRUCTIONS.md'
    };
    
    for i = 1:length(requiredFiles)
        filePath = fullfile(projectRoot, requiredFiles{i});
        if exist(filePath, 'file') == 2
            fprintf('  ✓ %s\n', requiredFiles{i});
        else
            warningMsg = sprintf('Файл %s не найден (опциональный)', requiredFiles{i});
            warnings{end+1} = warningMsg;
            fprintf('  ⚠ %s - НЕ НАЙДЕН\n', requiredFiles{i});
        end
    end
    
    %% Проверка App Designer файла
    fprintf('\nПроверка App Designer файла...\n');
    
    mlappFile = fullfile(projectRoot, 'src', 'TableGraphEditor.mlapp');
    if exist(mlappFile, 'file') == 2
        fprintf('  ✓ TableGraphEditor.mlapp найден\n');
    else
        warningMsg = 'TableGraphEditor.mlapp не найден (нужно создать в App Designer)';
        warnings{end+1} = warningMsg;
        fprintf('  ⚠ TableGraphEditor.mlapp - НЕ НАЙДЕН\n');
        fprintf('     См. SETUP_INSTRUCTIONS.md для инструкций по созданию\n');
    end
    
    %% Итоги
    fprintf('\n=== Итоги проверки ===\n');
    
    if isempty(errors) && isempty(warnings)
        fprintf('✓ Все проверки пройдены успешно!\n');
    else
        if ~isempty(errors)
            fprintf('\nОшибки:\n');
            for i = 1:length(errors)
                fprintf('  ✗ %s\n', errors{i});
            end
        end
        
        if ~isempty(warnings)
            fprintf('\nПредупреждения:\n');
            for i = 1:length(warnings)
                fprintf('  ⚠ %s\n', warnings{i});
            end
        end
    end
    
    fprintf('\n');
    
    % Выбросить ошибку, если есть критические проблемы
    if ~isempty(errors)
        error('Обнаружены критические ошибки в структуре проекта');
    end
end


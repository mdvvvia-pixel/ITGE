%% EXTRACT_MLAPP_CODE Извлекает код из .mlapp файла для редактирования
%   .mlapp файлы - это ZIP архивы, содержащие код приложения
%   Этот скрипт извлекает код для просмотра и редактирования
%
%   Использование:
%       extract_mlapp_code
%       extract_mlapp_code('TableGraphEditor.mlapp')

function extract_mlapp_code(mlappFile)
    % EXTRACT_MLAPP_CODE Извлекает код из .mlapp файла
    
    if nargin < 1
        mlappFile = 'TableGraphEditor.mlapp';
    end
    
    % Получить полный путь
    scriptPath = fileparts(mfilename('fullpath'));
    mlappPath = fullfile(scriptPath, mlappFile);
    
    if ~exist(mlappPath, 'file')
        error('Файл %s не найден', mlappPath);
    end
    
    fprintf('=== Извлечение кода из %s ===\n\n', mlappFile);
    
    % Создать временную папку для извлечения
    tempDir = fullfile(scriptPath, 'temp_extract');
    if exist(tempDir, 'dir')
        rmdir(tempDir, 's');
    end
    mkdir(tempDir);
    
    try
        % Извлечь ZIP архив
        unzip(mlappPath, tempDir);
        fprintf('✓ Файл извлечен во временную папку: %s\n\n', tempDir);
        
        % Найти файл с кодом
        % Обычно это metadata/app.m или metadata/code.m
        codeFiles = {
            fullfile(tempDir, 'metadata', 'app.m')
            fullfile(tempDir, 'metadata', 'code.m')
            fullfile(tempDir, 'app.m')
        };
        
        codeFile = '';
        for i = 1:length(codeFiles)
            if exist(codeFiles{i}, 'file')
                codeFile = codeFiles{i};
                break;
            end
        end
        
        % Также поищем все .m файлы
        if isempty(codeFile)
            mFiles = dir(fullfile(tempDir, '**', '*.m'));
            if ~isempty(mFiles)
                codeFile = fullfile(mFiles(1).folder, mFiles(1).name);
            end
        end
        
        if ~isempty(codeFile)
            fprintf('✓ Найден файл с кодом: %s\n\n', codeFile);
            
            % Прочитать код
            codeContent = fileread(codeFile);
            
            % Сохранить в читаемый файл
            outputFile = fullfile(scriptPath, 'TableGraphEditor_extracted.m');
            fid = fopen(outputFile, 'w');
            if fid ~= -1
                fprintf(fid, '%% Код, извлеченный из %s\n', mlappFile);
                fprintf(fid, '%% Date: %s\n\n', datestr(now));
                fprintf(fid, '%s', codeContent);
                fclose(fid);
                fprintf('✓ Код сохранен в: %s\n', outputFile);
                fprintf('  Вы можете редактировать этот файл\n\n');
            end
            
            % Показать структуру
            fprintf('=== Структура кода ===\n');
            showCodeStructure(codeContent);
            
        else
            fprintf('⚠ Файл с кодом не найден в стандартных местах\n');
            fprintf('Содержимое архива:\n');
            listArchiveContents(tempDir);
        end
        
        % Показать список всех файлов
        fprintf('\n=== Все файлы в архиве ===\n');
        listAllFiles(tempDir, '');
        
    catch ME
        fprintf('✗ Ошибка при извлечении: %s\n', ME.message);
    end
    
    fprintf('\n=== Готово ===\n');
    fprintf('ВНИМАНИЕ: Не редактируйте файлы напрямую в temp_extract/\n');
    fprintf('Используйте извлеченный файл TableGraphEditor_extracted.m\n');
    fprintf('После редактирования код нужно будет вставить обратно в App Designer\n');
end

function showCodeStructure(codeContent)
    % Показать структуру кода
    
    % Найти properties
    propMatches = regexp(codeContent, 'properties\s*\([^)]*\)', 'match');
    if ~isempty(propMatches)
        fprintf('Properties найдены: %d секций\n', length(propMatches));
    end
    
    % Найти methods
    methodMatches = regexp(codeContent, 'methods\s*\([^)]*\)', 'match');
    if ~isempty(methodMatches)
        fprintf('Methods найдены: %d секций\n', length(methodMatches));
    end
    
    % Найти функции
    functionMatches = regexp(codeContent, 'function\s+\w+', 'match');
    if ~isempty(functionMatches)
        fprintf('Functions найдены: %d\n', length(functionMatches));
        fprintf('  Первые 5 функций:\n');
        for i = 1:min(5, length(functionMatches))
            fprintf('    - %s\n', functionMatches{i});
        end
    end
end

function listArchiveContents(dirPath)
    % Показать содержимое архива
    items = dir(dirPath);
    for i = 1:length(items)
        if items(i).name(1) ~= '.'
            itemPath = fullfile(items(i).folder, items(i).name);
            if items(i).isdir
                fprintf('  [DIR]  %s/\n', items(i).name);
            else
                fprintf('  [FILE] %s\n', items(i).name);
            end
        end
    end
end

function listAllFiles(dirPath, prefix)
    % Рекурсивно показать все файлы
    items = dir(dirPath);
    for i = 1:length(items)
        if items(i).name(1) ~= '.'
            itemPath = fullfile(items(i).folder, items(i).name);
            if items(i).isdir
                fprintf('%s%s/\n', prefix, items(i).name);
                listAllFiles(itemPath, [prefix '  ']);
            else
                fprintf('%s%s\n', prefix, items(i).name);
            end
        end
    end
end


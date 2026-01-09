%% WRITE_MLAPP_CODE Записывает код обратно в .mlapp файл
%   ВНИМАНИЕ: Это экспериментальная функция
%   Рекомендуется использовать App Designer для редактирования
%
%   Использование:
%       write_mlapp_code(newCode)
%       write_mlapp_code(newCode, 'TableGraphEditor.mlapp')

function write_mlapp_code(newCode, mlappFile)
    % WRITE_MLAPP_CODE Записывает код в .mlapp файл
    
    if nargin < 2
        mlappFile = 'TableGraphEditor.mlapp';
    end
    
    scriptPath = fileparts(mfilename('fullpath'));
    mlappPath = fullfile(scriptPath, mlappFile);
    
    if ~exist(mlappPath, 'file')
        error('Файл %s не найден', mlappPath);
    end
    
    fprintf('=== Запись кода в %s ===\n\n', mlappFile);
    fprintf('⚠ ВНИМАНИЕ: Прямое редактирование .mlapp файлов может быть рискованным\n');
    fprintf('Рекомендуется использовать App Designer Code View\n\n');
    
    % Создать резервную копию
    backupPath = [mlappPath, '.backup.', datestr(now, 'yyyymmdd_HHMMSS')];
    copyfile(mlappPath, backupPath);
    fprintf('✓ Создана резервная копия: %s\n\n', backupPath);
    
    % Извлечь весь архив
    tempDir = fullfile(scriptPath, 'temp_write');
    if exist(tempDir, 'dir')
        rmdir(tempDir, 's');
    end
    mkdir(tempDir);
    
    try
        % Извлечь архив
        unzip(mlappPath, tempDir);
        fprintf('✓ Архив извлечен\n');
        
        % Обновить document.xml с новым кодом
        docFile = fullfile(tempDir, 'matlab', 'document.xml');
        if ~exist(docFile, 'file')
            error('document.xml не найден');
        end
        
        % Прочитать текущий XML
        docContent = fileread(docFile);
        
        % Заменить код в CDATA секции
        % Найти CDATA секцию
        pattern = '<!\[CDATA\[.*?\]\]>';
        replacement = ['<![CDATA[', newCode, ']]>'];
        
        newDocContent = regexprep(docContent, pattern, replacement, 'once');
        
        if isempty(regexp(newDocContent, '<!\[CDATA\[', 'once'))
            error('Не удалось заменить код в XML');
        end
        
        % Записать обратно
        fid = fopen(docFile, 'w');
        if fid == -1
            error('Не удалось открыть document.xml для записи');
        end
        fprintf(fid, '%s', newDocContent);
        fclose(fid);
        fprintf('✓ document.xml обновлен\n');
        
        % Пересоздать .mlapp файл
        delete(mlappPath);
        zip(mlappPath, '*', tempDir);
        fprintf('✓ .mlapp файл обновлен\n\n');
        
        % Очистить временную папку
        rmdir(tempDir, 's');
        
        fprintf('=== Готово ===\n');
        fprintf('✓ Код успешно записан в %s\n', mlappFile);
        fprintf('✓ Резервная копия сохранена: %s\n', backupPath);
        fprintf('\nРекомендуется:\n');
        fprintf('1. Открыть файл в App Designer: appdesigner(''%s'')\n', mlappPath);
        fprintf('2. Проверить, что все работает корректно\n');
        fprintf('3. Если есть проблемы, восстановить из резервной копии\n');
        
    catch ME
        % Восстановить из резервной копии в случае ошибки
        if exist(backupPath, 'file')
            copyfile(backupPath, mlappPath);
            fprintf('\n⚠ Ошибка! Файл восстановлен из резервной копии\n');
        end
        
        % Очистить временную папку
        if exist(tempDir, 'dir')
            rmdir(tempDir, 's');
        end
        
        rethrow(ME);
    end
end


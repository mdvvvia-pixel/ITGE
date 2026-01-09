%% EDIT_MLAPP_CODE Помощник для редактирования кода в .mlapp файле
%   Этот скрипт помогает работать с кодом внутри .mlapp файла
%
%   ВАЖНО: .mlapp файлы хранят код в специальном формате
%   Лучший способ редактирования - через Code View в App Designer
%   Но этот скрипт может помочь извлечь информацию
%
%   Использование:
%       edit_mlapp_code                    % Открыть файл в App Designer
%       edit_mlapp_code('extract')         % Извлечь информацию
%       edit_mlapp_code('open')            % Открыть в App Designer

function edit_mlapp_code(action)
    % EDIT_MLAPP_CODE Помощник для редактирования кода
    
    if nargin < 1
        action = 'open';
    end
    
    scriptPath = fileparts(mfilename('fullpath'));
    mlappPath = fullfile(scriptPath, 'TableGraphEditor.mlapp');
    
    if ~exist(mlappPath, 'file')
        error('Файл %s не найден', mlappPath);
    end
    
    switch lower(action)
        case 'open'
            % Открыть файл в App Designer
            fprintf('Открытие %s в App Designer...\n', mlappPath);
            try
                appdesigner(mlappPath);
                fprintf('✓ Файл открыт в App Designer\n');
                fprintf('Переключитесь в Code View для редактирования кода\n');
            catch ME
                fprintf('✗ Ошибка: %s\n', ME.message);
                fprintf('Попробуйте открыть вручную: appdesigner(''%s'')\n', mlappPath);
            end
            
        case 'extract'
            % Извлечь информацию о структуре
            fprintf('=== Информация о структуре .mlapp файла ===\n\n');
            
            % Проверить размер
            info = dir(mlappPath);
            fprintf('Размер файла: %.2f KB\n', info.bytes / 1024);
            
            % Извлечь и показать XML метаданные
            try
                tempDir = fullfile(scriptPath, 'temp_extract');
                if exist(tempDir, 'dir')
                    rmdir(tempDir, 's');
                end
                mkdir(tempDir);
                unzip(mlappPath, tempDir);
                
                % Прочитать метаданные
                metadataFile = fullfile(tempDir, 'metadata', 'appMetadata.xml');
                if exist(metadataFile, 'file')
                    fprintf('✓ Метаданные найдены\n');
                    metadata = fileread(metadataFile);
                    % Показать часть метаданных
                    fprintf('\nМетаданные (первые 500 символов):\n');
                    fprintf('%s\n', metadata(1:min(500, length(metadata))));
                end
                
                % Проверить document.xml
                docFile = fullfile(tempDir, 'matlab', 'document.xml');
                if exist(docFile, 'file')
                    fprintf('\n✓ document.xml найден\n');
                    docContent = fileread(docFile);
                    fprintf('Размер document.xml: %d символов\n', length(docContent));
                    fprintf('Первые 300 символов:\n');
                    fprintf('%s\n', docContent(1:min(300, length(docContent))));
                end
                
                % Очистить временную папку
                rmdir(tempDir, 's');
                
            catch ME
                fprintf('⚠ Ошибка при извлечении: %s\n', ME.message);
            end
            
        case 'info'
            % Показать информацию о файле
            fprintf('=== Информация о TableGraphEditor.mlapp ===\n\n');
            fprintf('Путь: %s\n', mlappPath);
            
            info = dir(mlappPath);
            fprintf('Размер: %.2f KB\n', info.bytes / 1024);
            fprintf('Дата изменения: %s\n', info.date);
            
            fprintf('\n=== Рекомендации ===\n');
            fprintf('1. Откройте файл в App Designer: appdesigner(''%s'')\n', mlappPath);
            fprintf('2. Переключитесь в Code View (кнопка вверху)\n');
            fprintf('3. Редактируйте код как обычный MATLAB код\n');
            fprintf('4. Сохраните изменения (Ctrl+S)\n\n');
            
        otherwise
            fprintf('Неизвестное действие: %s\n', action);
            fprintf('Доступные действия:\n');
            fprintf('  ''open''    - Открыть в App Designer\n');
            fprintf('  ''extract'' - Извлечь информацию\n');
            fprintf('  ''info''    - Показать информацию\n');
    end
end


%% READ_MLAPP_CODE Читает код из .mlapp файла
%   Извлекает MATLAB код из .mlapp файла для просмотра и редактирования
%
%   Использование:
%       code = read_mlapp_code()
%       code = read_mlapp_code('TableGraphEditor.mlapp')

function code = read_mlapp_code(mlappFile)
    % READ_MLAPP_CODE Читает код из .mlapp файла
    
    if nargin < 1
        mlappFile = 'TableGraphEditor.mlapp';
    end
    
    scriptPath = fileparts(mfilename('fullpath'));
    mlappPath = fullfile(scriptPath, mlappFile);
    
    if ~exist(mlappPath, 'file')
        error('Файл %s не найден', mlappPath);
    end
    
    % Извлечь document.xml
    tempDir = fullfile(scriptPath, 'temp_read');
    if exist(tempDir, 'dir')
        rmdir(tempDir, 's');
    end
    mkdir(tempDir);
    
    try
        unzip(mlappPath, tempDir);
        
        % Прочитать document.xml
        docFile = fullfile(tempDir, 'matlab', 'document.xml');
        if ~exist(docFile, 'file')
            error('document.xml не найден в архиве');
        end
        
        docContent = fileread(docFile);
        
        % Извлечь код из CDATA секции
        % Формат: <![CDATA[код]]>
        pattern = '<!\[CDATA\[(.*?)\]\]>';
        matches = regexp(docContent, pattern, 'tokens', 'once');
        
        if isempty(matches)
            error('Код не найден в CDATA секции');
        end
        
        code = matches{1};
        
        % Очистить временную папку
        rmdir(tempDir, 's');
        
    catch ME
        % Очистить в случае ошибки
        if exist(tempDir, 'dir')
            rmdir(tempDir, 's');
        end
        rethrow(ME);
    end
end


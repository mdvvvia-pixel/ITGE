%% ADDHELPERSTOPATH Добавляет папку helpers в MATLAB path
%   Эта функция должна быть вызвана при запуске приложения
%   для обеспечения доступа к helper функциям
%
%   Использование:
%       addHelpersToPath()
%       addHelpersToPath(app)  % с объектом приложения для сообщений

function addHelpersToPath(app)
    % ADDHELPERSTOPATH Добавляет папку helpers в path
    
    if nargin < 1
        app = [];
    end
    
    % Получить путь к папке helpers
    % Если вызывается из .mlapp, mfilename('fullpath') вернет путь к .mlapp
    % Если вызывается из helpers/, вернет путь к helpers/
    currentFile = mfilename('fullpath');
    [currentDir, ~, ~] = fileparts(currentFile);
    
    % Определить, где мы находимся
    if contains(currentDir, 'helpers')
        % Вызвано из helpers/, подняться на уровень выше
        helpersPath = currentDir;
        srcPath = fileparts(currentDir);
    else
        % Вызвано из src/, добавить helpers/
        srcPath = currentDir;
        helpersPath = fullfile(srcPath, 'helpers');
    end
    
    % Проверить существование папки
    if ~exist(helpersPath, 'dir')
        error('Папка helpers не найдена: %s', helpersPath);
    end
    
    % Добавить в path, если еще не добавлена
    if isempty(strfind(path, helpersPath))
        addpath(helpersPath);
        if ~isempty(app)
            fprintf('✓ Папка helpers добавлена в path: %s\n', helpersPath);
        end
    end
end


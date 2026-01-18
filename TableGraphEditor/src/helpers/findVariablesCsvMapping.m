%% FINDVARIABLECSVMAPPING Найти маппинг A/B для выбранной переменной по Variables.csv
%   Ищет точное совпадение имени основной переменной в 1-м столбце файла
%   TableGraphEditor/resources/Variables.csv (разделитель ';').
%   Возвращает имена переменных A (2-й столбец) и B (3-й столбец).
%   При дубликатах берёт первую подходящую строку.
%
%   Использование:
%       [isFound, aVarName, bVarName, csvPath] = findVariablesCsvMapping(mainVarName)
%
%   Параметры:
%       mainVarName - char/string, точное имя/путь (например, 'data' или 'struct.field')
%
%   Возвращает:
%       isFound  - logical scalar
%       aVarName - char ('' если не найдено)
%       bVarName - char ('' если не задано/пусто в CSV)
%       csvPath  - char, фактический путь к Variables.csv

function [isFound, aVarName, bVarName, csvPath] = findVariablesCsvMapping(mainVarName)
    isFound = false;
    aVarName = '';
    bVarName = '';
    csvPath = '';
    
    if nargin < 1
        return;
    end
    
    if isstring(mainVarName)
        mainVarName = char(mainVarName);
    end
    if ~ischar(mainVarName) || isempty(mainVarName)
        return;
    end
    
    % Путь к resources/Variables.csv относительно helpers/
    helpersDir = fileparts(mfilename('fullpath'));
    csvPath = fullfile(helpersDir, '..', '..', 'resources', 'Variables.csv');
    
    if exist(csvPath, 'file') ~= 2
        return;
    end
    
    try
        raw = readcell(csvPath, 'Delimiter', ';', 'TextType', 'char');
    catch
        % Fallback: иногда readcell может отсутствовать/вести себя иначе
        try
            raw = readcell(csvPath, 'Delimiter', ';');
        catch
            return;
        end
    end
    
    if isempty(raw) || size(raw, 2) < 2
        return;
    end
    
    % Нормализовать размеры (гарантировать 3 колонки)
    if size(raw, 2) < 3
        raw(:, 3) = {''};
    end
    
    % Поиск первой строки с точным совпадением 1-го столбца
    for i = 1:size(raw, 1)
        key = raw{i, 1};
        if isempty(key)
            continue;
        end
        if isstring(key); key = char(key); end
        if ~ischar(key)
            continue;
        end
        % Игнорируем случайные пробелы, если встретятся
        if strcmp(strtrim(key), strtrim(mainVarName))
            a = raw{i, 2};
            b = raw{i, 3};
            if isstring(a); a = char(a); end
            if isstring(b); b = char(b); end
            if ~ischar(a); a = ''; end
            if ~ischar(b); b = ''; end
            aVarName = strtrim(a);
            bVarName = strtrim(b);
            isFound = true;
            return;
        end
    end
end


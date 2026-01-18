%% PROMPTSELECTVECTORVARIABLE Попросить выбрать числовой вектор из workspace (модально)
%   Открывает модальный список и возвращает выбранный вектор и его путь.
%   Используется при загрузке Y-матрицы для выбора A (RowNames) и B (ColumnNames).
%
%   Использование:
%       [varPath, vec] = promptSelectVectorVariable(app, expectedLength, titleText, promptText)
%
%   Параметры:
%       app - объект приложения (для uialert)
%       expectedLength - ожидаемая длина (scalar > 0)
%       titleText - заголовок диалога
%       promptText - текст подсказки в диалоге
%
%   Возвращает:
%       varPath - путь к переменной (string/char). '' если отменено/ошибка
%       vec - column vector double (expectedLength x 1). [] если отменено/ошибка
%
function [varPath, vec] = promptSelectVectorVariable(app, expectedLength, titleText, promptText)
    varPath = '';
    vec = [];
    
    if nargin < 4
        promptText = 'Выберите переменную:';
    end
    if nargin < 3
        titleText = 'Выбор переменной';
    end
    
    % Защитные проверки
    if isempty(expectedLength) || ~isscalar(expectedLength) || expectedLength <= 0
        error('expectedLength должен быть скаляром > 0');
    end
    
    allVars = getAllNumericVectorVariables(expectedLength);
    if isempty(allVars.names)
        if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
            uialert(app.UIFigure, ...
                sprintf('Нет подходящих числовых векторов длиной %d (без NaN/Inf и дубликатов).', expectedLength), ...
                'Нет подходящих переменных', ...
                'Icon', 'warning');
        end
        return;
    end
    
    % listdlg - модальный диалог (подходит под требование)
    [idx, ok] = listdlg( ...
        'ListString', allVars.names, ...
        'SelectionMode', 'single', ...
        'PromptString', promptText, ...
        'Name', titleText, ...
        'ListSize', [420, 300]);
    
    if ~ok || isempty(idx)
        return;
    end
    
    varPath = allVars.paths{idx};
    
    try
        v = evalin('base', varPath);
        if ~isnumeric(v) || ~isvector(v)
            varPath = '';
            vec = [];
            return;
        end
        v = double(v(:));
        if numel(v) ~= expectedLength
            varPath = '';
            vec = [];
            return;
        end
        if ~all(isfinite(v)) || numel(unique(v)) ~= numel(v)
            varPath = '';
            vec = [];
            return;
        end
        vec = v;
    catch
        varPath = '';
        vec = [];
    end
end



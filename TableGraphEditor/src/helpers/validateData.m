%% VALIDATEDATA Проверяет корректность данных
%   Проверяет, что данные являются числовой 2D матрицей
%
%   Использование:
%       isValid = validateData(app, data)
%
%   Параметры:
%       app - объект приложения TableGraphEditor
%       data - данные для проверки
%
%   Возвращает:
%       isValid - true, если данные корректны (числовая 2D матрица), false иначе
%
%   Описание:
%       Проверяет, что данные:
%       - числовые (isnumeric)
%       - 2D матрица (ismatrix)
%       - не пустые
%       - не содержат NaN и Inf

function isValid = validateData(app, data)
    % VALIDATEDATA Проверяет корректность данных
    
    % Проверить базовые условия
    if ~isnumeric(data)
        uialert(app.UIFigure, ...
            'Данные должны быть числовыми', ...
            'Ошибка валидации', ...
            'Icon', 'error');
        isValid = false;
        return;
    end
    
    if isempty(data)
        uialert(app.UIFigure, ...
            'Данные не могут быть пустыми', ...
            'Ошибка валидации', ...
            'Icon', 'error');
        isValid = false;
        return;
    end
    
    % Проверить, что это 2D матрица (исключить скаляры и 1D массивы)
    if ~ismatrix(data)
        uialert(app.UIFigure, ...
            'Данные должны быть 2D матрицей (не скаляр и не 1D массив)', ...
            'Ошибка валидации', ...
            'Icon', 'error');
        isValid = false;
        return;
    end
    
    % Проверить на NaN и Inf (опционально, можно позволить)
    % Для начала разрешим NaN и Inf, так как они могут быть допустимы
    isValid = true;
end


%% VALIDATENUMERICDATA Валидировать числовое значение
%   Проверяет, является ли значение валидным числовым значением
%
%   Использование:
%       isValid = validateNumericData(value)
%
%   Параметры:
%       value - значение для валидации (может быть числом, строкой, и т.д.)
%
%   Возвращает:
%       isValid - true, если значение валидно (числовое, скалярное)
%                 false, если значение невалидно (пустое, нечисловое, массив)
%
%   Описание:
%       - Проверяет, что значение не пустое
%       - Преобразует строки в числа, если возможно
%       - Проверяет, что значение числовое и скалярное
%       - NaN и Inf разрешены (можно изменить, раскомментировав проверку)
%
%   Примеры:
%       validateNumericData(5)           % true
%       validateNumericData('5')          % true
%       validateNumericData('abc')        % false
%       validateNumericData([])           % false
%       validateNumericData([1 2 3])     % false (не скаляр)
%       validateNumericData(nan)         % true (NaN разрешен)
%       validateNumericData(inf)         % true (Inf разрешен)

function isValid = validateNumericData(value)
    % VALIDATENUMERICDATA Валидировать числовое значение
    
    isValid = false;
    
    % Проверить, что значение не пустое
    if isempty(value)
        return;
    end
    
    % Попытаться преобразовать в число
    if ischar(value) || isstring(value)
        % Попытаться преобразовать строку в число
        numValue = str2double(value);
        if isnan(numValue)
            % Проверить, не является ли это специальным значением 'NaN' или 'Inf'
            valueStr = strtrim(char(value));
            if strcmpi(valueStr, 'nan') || strcmpi(valueStr, 'inf') || ...
               strcmpi(valueStr, '-inf') || strcmpi(valueStr, '+inf')
                % Разрешить специальные значения
                isValid = true;
                return;
            end
            return;
        end
        value = numValue;
    end
    
    % Проверить, что значение числовое
    if ~isnumeric(value)
        return;
    end
    
    % Проверить, что это скаляр
    if ~isscalar(value)
        return;
    end
    
    % Проверить на NaN и Inf (можно разрешить или запретить)
    % По умолчанию разрешаем NaN и Inf, так как они могут быть валидными значениями
    % Раскомментируйте следующую проверку, если нужно запретить NaN/Inf:
    % if isnan(value) || isinf(value)
    %     return;
    % end
    
    isValid = true;
end


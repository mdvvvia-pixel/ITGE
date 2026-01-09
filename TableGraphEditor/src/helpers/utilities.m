% UTILITIES Вспомогательные функции
%   Содержит вспомогательные функции для приложения

classdef utilities
    % UTILITIES Вспомогательные функции

    methods (Static)
        function result = validateNumericData(data)
            % VALIDATENUMERICDATA Проверяет, что данные числовые
            result = isnumeric(data) && ~isempty(data);
        end
    end
end

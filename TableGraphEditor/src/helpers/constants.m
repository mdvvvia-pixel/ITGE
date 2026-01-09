% CONSTANTS Константы приложения
%   Определяет константы, используемые в приложении

classdef constants
    % CONSTANTS Константы TableGraphEditor

    properties (Constant)
        % Режимы редактирования
        EDIT_MODE_XY = 'XY'
        EDIT_MODE_X = 'X'
        EDIT_MODE_Y = 'Y'
        
        % Типы графиков
        PLOT_TYPE_COLUMNS = 'columns'
        PLOT_TYPE_ROWS = 'rows'
        
        % Размеры по умолчанию
        DEFAULT_WINDOW_WIDTH = 1200
        DEFAULT_WINDOW_HEIGHT = 800
    end
end

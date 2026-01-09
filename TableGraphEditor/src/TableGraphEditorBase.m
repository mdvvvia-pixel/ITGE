% TableGraphEditorBase - Базовый класс приложения
%   Этот файл служит шаблоном для создания .mlapp файла
%   Используйте его как справочник при создании App Designer приложения

classdef TableGraphEditorBase < handle
    % TABLEGRAPHEDITORBASE Базовый класс Table-Graph Editor

    properties (Access = private)
        % Данные
        originalData        % Исходные данные (полная матрица)
        currentData         % Текущие редактируемые данные
        selectedVariable    % Выбранная переменная из workspace
        editMode = 'XY'     % Режим редактирования: 'XY'
        currentPlotType = 'columns' % 'columns' или 'rows'
        
        % Для выбора части данных
        selectedColumns = [] % Индексы выбранных столбцов
        selectedRows = []    % Индексы выбранных строк
        
        % Метки
        rowLabels = {}      % Метки строк
        columnLabels = {}   % Метки столбцов
        
        % Для перетаскивания
        selectedPoint = []  % Индекс выбранной точки
        isDragging = false  % Флаг перетаскивания
        dragStartPosition = [] % Начальная позиция
        
        % Состояние приложения
        isUpdating = false  % Флаг обновления
    end

    methods
        function obj = TableGraphEditorBase()
            % Конструктор
            fprintf('TableGraphEditorBase создан\n');
        end
    end
end

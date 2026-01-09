%% APPDATASTORE Класс для хранения данных приложения
%   Альтернативное решение: хранить данные в отдельном классе
%   Используется, если Properties не могут быть добавлены в .mlapp
%
%   Использование:
%       appData = AppDataStore();
%       appData.currentData = rand(10, 3);

classdef AppDataStore < handle
    % APPDATASTORE Хранилище данных для TableGraphEditor
    
    properties
        % === Данные ===
        originalData        % Исходные данные (полная матрица)
        currentData         % Текущие редактируемые данные
        selectedVariable    % Выбранная переменная из workspace
        editMode = 'XY'     % Режим редактирования: 'XY'
        currentPlotType = 'columns' % 'columns' или 'rows'
        
        % === Выбор части данных ===
        selectedColumns = [] % Индексы выбранных столбцов
        selectedRows = []    % Индексы выбранных строк
        
        % === Метки ===
        rowLabels = {}      % Метки строк
        columnLabels = {}   % Метки столбцов
        
        % === Перетаскивание ===
        selectedPoint = []  % Индекс выбранной точки [curveIndex, pointIndex]
        isDragging = false  % Флаг активного перетаскивания
        dragStartPosition = [] % Начальная позиция перетаскивания [x, y]
        
        % === Состояние приложения ===
        isUpdating = false  % Флаг обновления (предотвращает циклические обновления)
    end
    
    methods
        function obj = AppDataStore()
            % Конструктор
            obj.isUpdating = false;
            obj.currentPlotType = 'columns';
            obj.editMode = 'XY';
            obj.selectedVariable = '';
            obj.selectedColumns = [];
            obj.selectedRows = [];
            obj.rowLabels = {};
            obj.columnLabels = {};
            obj.selectedPoint = [];
            obj.isDragging = false;
            obj.dragStartPosition = [];
        end
    end
end


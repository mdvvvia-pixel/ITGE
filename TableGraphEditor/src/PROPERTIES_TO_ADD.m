%% PROPERTIES_TO_ADD Properties для добавления в TableGraphEditor.mlapp
%   Скопируйте этот код в секцию Properties в Code View App Designer
%   Добавьте после секции properties (Access = public) с UI компонентами

% Application data and state
% ВАЖНО: Нельзя использовать Access и SetAccess одновременно в MATLAB!
% Используем SetAccess = public для возможности записи из helper функций
properties (SetAccess = public)
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


%% UPDATEGRAPH Обновляет график на основе текущих данных
%   Строит график в зависимости от выбранного типа (по столбцам или строкам)
%
%   Использование:
%       updateGraph(app)
%
%   Параметры:
%       app - объект приложения TableGraphEditor

function updateGraph(app)
    % UPDATEGRAPH Обновляет график на основе текущих данных
    
    fprintf('updateGraph вызван\n');  % Отладочный вывод
    
    % Инициализировать свойства, если нужно (тихо, без сообщений)
    if exist('initializeAppProperties', 'file') == 2
        initializeAppProperties(app);
    end
    
    % Получить данные (проверка из свойства или UserData)
    currentData = [];
    if isprop(app, 'currentData')
        try
            currentData = app.currentData;
        catch
            if isfield(app.UIFigure.UserData, 'appData') && ...
               isfield(app.UIFigure.UserData.appData, 'currentData')
                currentData = app.UIFigure.UserData.appData.currentData;
            end
        end
    else
        if isfield(app.UIFigure.UserData, 'appData') && ...
           isfield(app.UIFigure.UserData.appData, 'currentData')
            currentData = app.UIFigure.UserData.appData.currentData;
        end
    end
    
    % Предотвратить циклические обновления
    % Безопасная проверка isUpdating (может не быть инициализирован)
    % ВАЖНО: Не блокировать обновления во время перетаскивания
    isUpdatingFlag = false;
    isDraggingFlag = false;
    
    if isprop(app, 'isUpdating')
        try
            isUpdatingFlag = app.isUpdating;
        catch
            isUpdatingFlag = false;
        end
    end
    
    % Проверить, идет ли перетаскивание
    if isprop(app, 'isDragging')
        try
            isDraggingFlag = app.isDragging;
        catch
            if isfield(app.UIFigure.UserData, 'appData') && ...
               isfield(app.UIFigure.UserData.appData, 'isDragging')
                isDraggingFlag = app.UIFigure.UserData.appData.isDragging;
            end
        end
    else
        if isfield(app.UIFigure.UserData, 'appData') && ...
           isfield(app.UIFigure.UserData.appData, 'isDragging')
            isDraggingFlag = app.UIFigure.UserData.appData.isDragging;
        end
    end
    
    % Если идет перетаскивание, разрешить обновление (не блокировать)
    % Иначе блокировать, если уже идет обновление
    if ~isDraggingFlag && isUpdatingFlag || isempty(currentData)
        fprintf('Пропуск updateGraph: isUpdating=%d, isDragging=%d, empty(currentData)=%d\n', ...
            isUpdatingFlag, isDraggingFlag, isempty(currentData));
        return;
    end
    
    fprintf('Данные для графика: size=[%s]\n', num2str(size(currentData)));
    
    % Получить тип графика
    plotType = 'columns';
    if isprop(app, 'currentPlotType')
        try
            plotType = app.currentPlotType;
        catch
            plotType = 'columns';
        end
    end
    fprintf('Тип графика: %s\n', plotType);
    
    % Установить флаг обновления (безопасно)
    if isprop(app, 'isUpdating')
        try
            app.isUpdating = true;
        catch
            % Если не удалось установить, продолжить без флага
        end
    end
    
    try
        % Проверить минимальный размер данных
        if size(currentData, 1) < 2 || size(currentData, 2) < 2
            fprintf('⚠ updateGraph: недостаточно данных для построения графика (нужно минимум 2x2)\n');
            cla(app.axPlot);
            text(app.axPlot, 0.5, 0.5, 'Недостаточно данных для построения графика', ...
                'HorizontalAlignment', 'center', 'Units', 'normalized');
            drawnow limitrate;
            return;
        end
        
        % Построить график в зависимости от типа
        if strcmp(plotType, 'columns')
            fprintf('Вызов plotByColumns...\n');
            if exist('plotByColumns', 'file') == 2
                plotByColumns(app, currentData);
            else
                fprintf('⚠ Функция plotByColumns не найдена\n');
                cla(app.axPlot);
                text(app.axPlot, 0.5, 0.5, 'Функция plotByColumns не найдена', ...
                    'HorizontalAlignment', 'center', 'Units', 'normalized');
            end
        else
            fprintf('Вызов plotByRows...\n');
            if exist('plotByRows', 'file') == 2
                plotByRows(app, currentData);
            else
                fprintf('⚠ Функция plotByRows не найдена\n');
                cla(app.axPlot);
                text(app.axPlot, 0.5, 0.5, 'Функция plotByRows не найдена', ...
                    'HorizontalAlignment', 'center', 'Units', 'normalized');
            end
        end
        
        % Ограничить частоту обновлений
        drawnow limitrate;
        
        fprintf('✓ График обновлен\n');
        
    catch ME
        fprintf('Ошибка в updateGraph: %s\n', ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        
        if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
            uialert(app.UIFigure, sprintf('Ошибка построения графика: %s', ME.message), 'Ошибка построения графика');
        end
    end
    
    % Сбросить флаг обновления (безопасно)
    if isprop(app, 'isUpdating')
        try
            app.isUpdating = false;
        catch
            % Если не удалось сбросить, продолжить
        end
    end
end


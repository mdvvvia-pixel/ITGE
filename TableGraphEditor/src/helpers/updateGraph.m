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
    isUpdatingFlag = false;
    if isprop(app, 'isUpdating')
        try
            isUpdatingFlag = app.isUpdating;
        catch
            isUpdatingFlag = false;
        end
    end
    
    if isUpdatingFlag || isempty(currentData)
        fprintf('Пропуск updateGraph: isUpdating=%d, empty(currentData)=%d\n', ...
            isUpdatingFlag, isempty(currentData));
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
        % Построить график в зависимости от типа
        if strcmp(plotType, 'columns')
            fprintf('Вызов plotByColumns...\n');
            if exist('plotByColumns', 'file') == 2
                plotByColumns(app, currentData);
            else
                fprintf('⚠ Функция plotByColumns не найдена\n');
            end
        else
            fprintf('Вызов plotByRows...\n');
            if exist('plotByRows', 'file') == 2
                plotByRows(app, currentData);
            else
                fprintf('⚠ Функция plotByRows не найдена\n');
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


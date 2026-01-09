%% DRAGPOINT Обновить позицию точки при движении мыши при перетаскивании
%   Обновляет позицию точки при движении мыши
%   Вызывает helper функцию updateDataFromGraph из helpers/
%
%   Использование:
%       dragPoint(app, src, event)
%
%   Параметры:
%       app - объект приложения TableGraphEditor
%       src - источник события (обычно UIFigure)
%       event - объект события (может быть пустым)
%
%   Примечание: Вызывается через WindowButtonMotionFcn или таймер
%   Использует CurrentPoint из axes для получения координат мыши

function dragPoint(app, src, event)
    % DRAGPOINT Обновить позицию точки при движении мыши
    %   В MacOS WindowButtonMotionFcn может не работать, используется таймер
    
    fprintf('dragPoint вызван (MacOS: %d)\n', ismac);  % Отладочный вывод
    
    % Установить флаг, что мышь двигалась
    if isprop(app, 'hasMoved')
        try
            app.hasMoved = true;
        catch
            if ~isfield(app.UIFigure.UserData, 'appData')
                app.UIFigure.UserData.appData = struct();
            end
            app.UIFigure.UserData.appData.hasMoved = true;
        end
    else
        if ~isfield(app.UIFigure.UserData, 'appData')
            app.UIFigure.UserData.appData = struct();
        end
        app.UIFigure.UserData.appData.hasMoved = true;
    end
    
    % Проверить, что перетаскивание активно (безопасно)
    isDraggingFlag = false;
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
    
    if ~isDraggingFlag
        fprintf('⚠ dragPoint: перетаскивание не активно\n');
        return;
    end
    
    % Получить индекс выбранной точки (безопасно)
    selectedPoint = [];
    if isprop(app, 'selectedPoint')
        try
            selectedPoint = app.selectedPoint;
        catch
            if isfield(app.UIFigure.UserData, 'appData') && ...
               isfield(app.UIFigure.UserData.appData, 'selectedPoint')
                selectedPoint = app.UIFigure.UserData.appData.selectedPoint;
            end
        end
    else
        if isfield(app.UIFigure.UserData, 'appData') && ...
           isfield(app.UIFigure.UserData.appData, 'selectedPoint')
            selectedPoint = app.UIFigure.UserData.appData.selectedPoint;
        end
    end
    
    if isempty(selectedPoint)
        fprintf('⚠ dragPoint: selectedPoint пуст\n');
        return;
    end
    
    try
        % Проверить, что график существует и валиден
        if ~isprop(app, 'axPlot') || ~isvalid(app.axPlot)
            fprintf('⚠ dragPoint: axPlot не найден или не валиден\n');
            return;
        end
        
        % Получить текущие координаты мыши в координатах данных
        % Используем CurrentPoint из axes (в координатах данных)
        % CurrentPoint всегда возвращает координаты в системе координат axes,
        % даже если мышь находится вне axes (но в пределах figure)
        cp = app.axPlot.CurrentPoint;
        currentPos = cp(1, 1:2);
        
        % Проверить, что координаты находятся в пределах axes
        % (CurrentPoint может возвращать координаты даже вне axes)
        xLim = app.axPlot.XLim;
        yLim = app.axPlot.YLim;
        
        % Ограничить координаты пределами axes (опционально)
        % Можно раскомментировать, если нужно ограничивать перемещение:
        % currentPos(1) = max(xLim(1), min(xLim(2), currentPos(1)));
        % currentPos(2) = max(yLim(1), min(yLim(2), currentPos(2)));
        
        fprintf('Координаты мыши: [%.4f, %.4f]\n', currentPos(1), currentPos(2));
        
        % Проверить валидность координат
        if ~isfinite(currentPos(1)) || ~isfinite(currentPos(2))
            fprintf('⚠ dragPoint: координаты не валидны (NaN/Inf)\n');
            return;
        end
        
        % Обновить данные через helper функцию
        if exist('updateDataFromGraph', 'file') == 2
            fprintf('Вызов updateDataFromGraph...\n');
            updateDataFromGraph(app, selectedPoint, currentPos);
            fprintf('✓ updateDataFromGraph завершен\n');
        else
            fprintf('⚠ Функция updateDataFromGraph не найдена\n');
            return;
        end
        
        % Обновить график (перестроить с новыми данными)
        if exist('updateGraph', 'file') == 2
            fprintf('Вызов updateGraph...\n');
            updateGraph(app);
            fprintf('✓ updateGraph завершен\n');
        else
            fprintf('⚠ Функция updateGraph не найдена\n');
        end
        
        % Принудительно обновить график
        % Используем drawnow (не limitrate) для более надежного обновления
        drawnow;
        
    catch ME
        % Показать ошибки для отладки
        fprintf('Ошибка в dragPoint: %s\n', ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end

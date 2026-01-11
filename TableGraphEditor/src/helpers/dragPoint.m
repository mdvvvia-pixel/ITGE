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
        
        % Получить исходные координаты точки для применения ограничений режима
        % ВАЖНО: Исходные координаты должны сохраняться один раз при начале перетаскивания
        % и НЕ должны обновляться во время перетаскивания
        dragStartCoordinates = [];
        if isprop(app, 'dragStartCoordinates')
            try
                dragStartCoordinates = app.dragStartCoordinates;
            catch
                if isfield(app.UIFigure.UserData, 'appData') && ...
                   isfield(app.UIFigure.UserData.appData, 'dragStartCoordinates')
                    dragStartCoordinates = app.UIFigure.UserData.appData.dragStartCoordinates;
                end
            end
        else
            if isfield(app.UIFigure.UserData, 'appData') && ...
               isfield(app.UIFigure.UserData.appData, 'dragStartCoordinates')
                dragStartCoordinates = app.UIFigure.UserData.appData.dragStartCoordinates;
            end
        end
        
        % Если исходные координаты не найдены, получить их из данных
        % Это должно происходить только один раз в начале перетаскивания
        if isempty(dragStartCoordinates)
            if exist('getPointCoordinates', 'file') == 2
                dragStartCoordinates = getPointCoordinates(app, selectedPoint);
                fprintf('⚠ Исходные координаты не были сохранены, получены из данных: [%.4f, %.4f]\n', ...
                    dragStartCoordinates(1), dragStartCoordinates(2));
                % Сохранить их для последующих вызовов
                if isprop(app, 'dragStartCoordinates')
                    try
                        app.dragStartCoordinates = dragStartCoordinates;
                    catch
                        if ~isfield(app.UIFigure.UserData, 'appData')
                            app.UIFigure.UserData.appData = struct();
                        end
                        app.UIFigure.UserData.appData.dragStartCoordinates = dragStartCoordinates;
                    end
                else
                    if ~isfield(app.UIFigure.UserData, 'appData')
                        app.UIFigure.UserData.appData = struct();
                    end
                    app.UIFigure.UserData.appData.dragStartCoordinates = dragStartCoordinates;
                end
            else
                % Если функция не найдена, использовать текущие координаты
                fprintf('⚠ getPointCoordinates не найдена, используются текущие координаты\n');
                dragStartCoordinates = currentPos;
            end
        end
        
        % Проверить валидность исходных координат
        if isempty(dragStartCoordinates) || length(dragStartCoordinates) < 2 || ...
           ~isfinite(dragStartCoordinates(1)) || ~isfinite(dragStartCoordinates(2))
            fprintf('⚠ dragPoint: исходные координаты не валидны: [%s]\n', ...
                mat2str(dragStartCoordinates));
            % Попытаться получить из данных еще раз
            if exist('getPointCoordinates', 'file') == 2
                dragStartCoordinates = getPointCoordinates(app, selectedPoint);
                fprintf('Повторное получение из данных: [%.4f, %.4f]\n', ...
                    dragStartCoordinates(1), dragStartCoordinates(2));
            else
                fprintf('⚠ Не удалось получить валидные исходные координаты, пропуск обновления\n');
                return;
            end
        end
        
        fprintf('Исходные координаты (для ограничений): [%.4f, %.4f]\n', ...
            dragStartCoordinates(1), dragStartCoordinates(2));
        
        % Применить ограничения режима редактирования
        constrainedPos = currentPos;
        if exist('applyEditModeConstraints', 'file') == 2
            constrainedPos = applyEditModeConstraints(app, currentPos, dragStartCoordinates);
            fprintf('Координаты мыши: [%.4f, %.4f] → после ограничений: [%.4f, %.4f]\n', ...
                currentPos(1), currentPos(2), constrainedPos(1), constrainedPos(2));
        else
            fprintf('⚠ applyEditModeConstraints не найдена, ограничения не применены\n');
        end
        
        % Обновить данные через helper функцию
        if exist('updateDataFromGraph', 'file') == 2
            fprintf('Вызов updateDataFromGraph...\n');
            updateDataFromGraph(app, selectedPoint, constrainedPos);
            fprintf('✓ updateDataFromGraph завершен\n');
        else
            fprintf('⚠ Функция updateDataFromGraph не найдена\n');
            return;
        end
        
        % Обновить график (перестроить с новыми данными)
        % ВАЖНО: updateGraph уже вызывает drawnow limitrate, дополнительный drawnow не нужен
        if exist('updateGraph', 'file') == 2
            fprintf('Вызов updateGraph...\n');
            updateGraph(app);
            fprintf('✓ updateGraph завершен\n');
        else
            fprintf('⚠ Функция updateGraph не найдена\n');
        end
        
    catch ME
        % Показать ошибки для отладки
        fprintf('Ошибка в dragPoint: %s\n', ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end

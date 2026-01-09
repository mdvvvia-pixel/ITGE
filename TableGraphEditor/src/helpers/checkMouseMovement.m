%% CHECKMOUSEMOVEMENT Проверить движение мыши через таймер
%   Проверяет движение мыши через таймер для отслеживания перетаскивания
%   Это fallback механизм, если WindowButtonMotionFcn не работает
%
%   Использование:
%       checkMouseMovement(app, timerObj)
%
%   Параметры:
%       app - объект приложения TableGraphEditor
%       timerObj - объект таймера
%
%   Примечание: Вызывается таймером каждые 50 мс во время перетаскивания

function checkMouseMovement(app, timerObj)
    % CHECKMOUSEMOVEMENT Проверить движение мыши
    %   В MacOS использует специальную обработку координат
    
    % Отладочный вывод для MacOS
    persistent callCount;
    if isempty(callCount)
        callCount = 0;
    end
    callCount = callCount + 1;
    
    % Выводить сообщение при первом вызове и каждые 20 вызовов
    if callCount == 1
        fprintf('✓ checkMouseMovement вызван ПЕРВЫЙ РАЗ (MacOS: %d)\n', ismac);
    elseif mod(callCount, 20) == 0
        fprintf('checkMouseMovement вызван (MacOS: %d, вызов #%d)\n', ismac, callCount);
    end
    
    try
        % Получить app из UserData, если не передан напрямую
        if nargin < 1 || isempty(app)
            if isfield(timerObj.UserData, 'dragApp')
                app = timerObj.UserData.dragApp;
            else
                fprintf('⚠ checkMouseMovement: app не найден\n');
                return;
            end
        end
        
        % Проверить, что перетаскивание активно
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
        
        if callCount == 1
            fprintf('  isDraggingFlag = %d\n', isDraggingFlag);
        end
        
        if ~isDraggingFlag
            % Перетаскивание не активно - остановить таймер
            if callCount == 1
                fprintf('⚠ checkMouseMovement: isDraggingFlag=false, останавливаем таймер\n');
            end
            try
                stop(timerObj);
            catch
            end
            return;
        end
        
        % Получить текущую позицию мыши
        % В MacOS координаты могут быть в другой системе, учитываем это
        currentMousePos = get(0, 'PointerLocation');
        
        % В MacOS координаты могут быть относительно экрана, а не окна
        % Нужно преобразовать в координаты относительно figure
        try
            % Получить позицию figure на экране
            figPos = app.UIFigure.Position;
            % В MacOS может потребоваться корректировка координат
            % get(0, 'PointerLocation') возвращает координаты относительно экрана
            % Нужно вычесть позицию figure
            if ismac
                % В MacOS координаты могут быть в другой системе
                % Используем альтернативный способ получения координат
                % через CurrentPoint из axes
                if isprop(app, 'axPlot') && isvalid(app.axPlot)
                    cp = app.axPlot.CurrentPoint;
                    currentPos = cp(1, 1:2);
                else
                    return;
                end
            else
                % Для других ОС используем стандартный способ
                mousePosInFig = currentMousePos - [figPos(1), figPos(2)];
                axPos = app.axPlot.Position;
                if mousePosInFig(1) >= axPos(1) && ...
                   mousePosInFig(1) <= axPos(1) + axPos(3) && ...
                   mousePosInFig(2) >= axPos(2) && ...
                   mousePosInFig(2) <= axPos(2) + axPos(4)
                    cp = app.axPlot.CurrentPoint;
                    currentPos = cp(1, 1:2);
                else
                    return;
                end
            end
        catch
            % Если не удалось получить координаты, использовать CurrentPoint напрямую
            if isprop(app, 'axPlot') && isvalid(app.axPlot)
                cp = app.axPlot.CurrentPoint;
                currentPos = cp(1, 1:2);
            else
                return;
            end
        end
        
        % Получить предыдущую позицию для проверки движения
        lastMousePos = [];
        if isprop(app, 'lastMousePosition')
            try
                lastMousePos = app.lastMousePosition;
            catch
                if isfield(app.UIFigure.UserData, 'lastMousePosition')
                    lastMousePos = app.UIFigure.UserData.lastMousePosition;
                end
            end
        else
            if isfield(app.UIFigure.UserData, 'lastMousePosition')
                lastMousePos = app.UIFigure.UserData.lastMousePosition;
            end
        end
        
        % Проверить, что мышь двигалась
        % В MacOS используем координаты данных для проверки движения
        if ~isempty(lastMousePos)
            % Для MacOS проверяем движение в координатах данных
            if ismac && isprop(app, 'axPlot') && isvalid(app.axPlot)
                % Получить предыдущие координаты данных
                if isfield(app.UIFigure.UserData, 'lastDataPosition')
                    lastDataPos = app.UIFigure.UserData.lastDataPosition;
                    mouseMoved = any(abs(currentPos - lastDataPos) > 0.01); % Порог в координатах данных
                else
                    mouseMoved = true; % Первый вызов - считаем, что двигалась
                end
                % Сохранить текущие координаты данных
                app.UIFigure.UserData.lastDataPosition = currentPos;
            else
                % Для других ОС используем пиксели
                mouseMoved = any(abs(currentMousePos - lastMousePos) > 1); % Порог 1 пиксель
            end
            
            if mouseMoved
                % Мышь двигалась - обновить данные
                % Координаты уже получены выше
                
                % Получить индекс выбранной точки
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
                
                if ~isempty(selectedPoint) && isfinite(currentPos(1)) && isfinite(currentPos(2))
                    % Установить флаг движения
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
                    
                    % Обновить данные
                    if exist('updateDataFromGraph', 'file') == 2
                        updateDataFromGraph(app, selectedPoint, currentPos);
                    end
                    
                    % Обновить график
                    if exist('updateGraph', 'file') == 2
                        updateGraph(app);
                    end
                    
                    drawnow;
                end
            end
        else
            % Первый вызов - сохранить позицию
            if ismac && isprop(app, 'axPlot') && isvalid(app.axPlot)
                try
                    app.UIFigure.UserData.lastDataPosition = currentPos;
                catch
                end
            end
        end
        
        % Сохранить текущую позицию
        % В MacOS сохраняем и пиксели, и координаты данных
        if isprop(app, 'lastMousePosition')
            try
                app.lastMousePosition = currentMousePos;
            catch
                app.UIFigure.UserData.lastMousePosition = currentMousePos;
            end
        else
            app.UIFigure.UserData.lastMousePosition = currentMousePos;
        end
        
        % В MacOS также сохраняем координаты данных для следующей проверки
        if ismac && isprop(app, 'axPlot') && isvalid(app.axPlot)
            try
                cp = app.axPlot.CurrentPoint;
                currentDataPos = cp(1, 1:2);
                app.UIFigure.UserData.lastDataPosition = currentDataPos;
            catch
                % Игнорировать ошибки
            end
        end
        
    catch ME
        % Игнорировать ошибки в таймере (не критичные)
        fprintf('Ошибка в checkMouseMovement: %s\n', ME.message);
    end
end

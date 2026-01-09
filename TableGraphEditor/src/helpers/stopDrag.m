%% STOPDRAG Завершить перетаскивание и обновить таблицу
%   Обработчик отпускания мыши при перетаскивании точки
%   Завершает перетаскивание и обновляет таблицу
%
%   Использование:
%       stopDrag(app, src, event)
%
%   Параметры:
%       app - объект приложения TableGraphEditor
%       src - источник события (обычно UIFigure)
%       event - объект события (может быть пустым)
%
%   Примечание: Вызывается через WindowButtonUpFcn

function stopDrag(app, src, event)
    % STOPDRAG Завершить перетаскивание
    
    fprintf('stopDrag вызван\n');  % Отладочный вывод
    
    % Проверить, что мышь действительно двигалась (не просто клик)
    hasMovedFlag = false;
    if isprop(app, 'hasMoved')
        try
            hasMovedFlag = app.hasMoved;
        catch
            if isfield(app.UIFigure.UserData, 'appData') && ...
               isfield(app.UIFigure.UserData.appData, 'hasMoved')
                hasMovedFlag = app.UIFigure.UserData.appData.hasMoved;
            end
        end
    else
        if isfield(app.UIFigure.UserData, 'appData') && ...
           isfield(app.UIFigure.UserData.appData, 'hasMoved')
            hasMovedFlag = app.UIFigure.UserData.appData.hasMoved;
        end
    end
    
    if ~hasMovedFlag
        fprintf('⚠ stopDrag: мышь не двигалась (это был просто клик, не перетаскивание)\n');
        % Просто очистить callbacks и таймер, не обновлять данные
        cleanupDrag(app);
        return;
    end
    
    try
        % Остановить таймер перетаскивания (если запущен)
        cleanupDragTimer(app);
        
        % Сбросить флаг перетаскивания (безопасно)
        if isprop(app, 'isDragging')
            try
                app.isDragging = false;
            catch
                if isfield(app.UIFigure.UserData, 'appData')
                    app.UIFigure.UserData.appData.isDragging = false;
                end
            end
        else
            if isfield(app.UIFigure.UserData, 'appData')
                app.UIFigure.UserData.appData.isDragging = false;
            end
        end
        
        % Очистить callbacks
        app.UIFigure.WindowButtonMotionFcn = [];
        app.UIFigure.WindowButtonUpFcn = [];
        
        % Обновить таблицу с новыми данными (безопасно)
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
        
        if ~isempty(currentData) && isprop(app, 'tblData') && isvalid(app.tblData)
            app.tblData.Data = currentData;
            fprintf('✓ Таблица обновлена\n');
        end
        
        % Сбросить выбранную точку (безопасно)
        if isprop(app, 'selectedPoint')
            try
                app.selectedPoint = [];
            catch
                if isfield(app.UIFigure.UserData, 'appData')
                    app.UIFigure.UserData.appData.selectedPoint = [];
                end
            end
        else
            if isfield(app.UIFigure.UserData, 'appData')
                app.UIFigure.UserData.appData.selectedPoint = [];
            end
        end
        
        fprintf('✓ Перетаскивание завершено\n');
        
    catch ME
        fprintf('Ошибка в stopDrag: %s\n', ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        
        % Очистить callbacks в любом случае
        cleanupDrag(app);
        
        if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
            uialert(app.UIFigure, ...
                sprintf('Ошибка завершения перетаскивания: %s', ME.message), ...
                'Ошибка перетаскивания', ...
                'Icon', 'error');
        end
    end
end

function cleanupDrag(app)
    % CLEANUPDRAG Очистить все ресурсы перетаскивания
    %   Вспомогательная функция для очистки callbacks и таймера
    
    try
        cleanupDragTimer(app);
        app.UIFigure.WindowButtonMotionFcn = [];
        app.UIFigure.WindowButtonUpFcn = [];
        
        % Сбросить флаги
        if isprop(app, 'isDragging')
            try
                app.isDragging = false;
            catch
                if isfield(app.UIFigure.UserData, 'appData')
                    app.UIFigure.UserData.appData.isDragging = false;
                end
            end
        end
        if isprop(app, 'selectedPoint')
            try
                app.selectedPoint = [];
            catch
                if isfield(app.UIFigure.UserData, 'appData')
                    app.UIFigure.UserData.appData.selectedPoint = [];
                end
            end
        end
    catch
        % Игнорировать ошибки при очистке
    end
end

function cleanupDragTimer(app)
    % CLEANUPDRAGTIMER Остановить и удалить таймер перетаскивания
    %   Вспомогательная функция для очистки таймера
    
    try
        if isprop(app, 'dragTimer')
            try
                if isvalid(app.dragTimer)
                    stop(app.dragTimer);
                    delete(app.dragTimer);
                end
            catch
                if isfield(app.UIFigure.UserData, 'dragTimer')
                    try
                        if isvalid(app.UIFigure.UserData.dragTimer)
                            stop(app.UIFigure.UserData.dragTimer);
                            delete(app.UIFigure.UserData.dragTimer);
                        end
                    catch
                    end
                    app.UIFigure.UserData = rmfield(app.UIFigure.UserData, 'dragTimer');
                end
            end
        else
            if isfield(app.UIFigure.UserData, 'dragTimer')
                try
                    if isvalid(app.UIFigure.UserData.dragTimer)
                        stop(app.UIFigure.UserData.dragTimer);
                        delete(app.UIFigure.UserData.dragTimer);
                    end
                catch
                end
                app.UIFigure.UserData = rmfield(app.UIFigure.UserData, 'dragTimer');
            end
        end
    catch
        % Игнорировать ошибки при очистке таймера
    end
end

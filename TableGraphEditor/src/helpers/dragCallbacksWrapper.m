%% DRAGCALLBACKSWRAPPER Wrapper функции для callbacks перетаскивания
%   Эти функции используются для обхода проблем с вызовом методов класса
%   из WindowButtonMotionFcn и WindowButtonUpFcn в MATLAB App Designer
%
%   Использование:
%       Эти функции автоматически вызываются из callbacks, установленных
%       в axPlotButtonDown. Они получают app из UserData figure и вызывают
%       соответствующие методы класса.

function dragCallbacksWrapper()
    % Этот файл содержит wrapper функции для callbacks перетаскивания
    % Функции определены ниже
end

function handleDragMotion(src, evt)
    % HANDLEDRAGMOTION Wrapper для dragPoint
    %   Вызывается из WindowButtonMotionFcn
    %   Получает app из UserData figure и вызывает app.dragPoint
    
    try
        % Получить app из UserData figure
        if isfield(src.UserData, 'dragApp')
            app = src.UserData.dragApp;
            if isvalid(app) && ismethod(app, 'dragPoint')
                % Вызвать метод dragPoint
                app.dragPoint(src, evt);
            else
                fprintf('⚠ handleDragMotion: app не валиден или метод dragPoint не найден\n');
            end
        else
            fprintf('⚠ handleDragMotion: dragApp не найден в UserData\n');
        end
    catch ME
        fprintf('Ошибка в handleDragMotion: %s\n', ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end

function handleDragUp(src, evt)
    % HANDLEDRAGUP Wrapper для stopDrag
    %   Вызывается из WindowButtonUpFcn
    %   Получает app из UserData figure и вызывает app.stopDrag
    
    try
        % Получить app из UserData figure
        if isfield(src.UserData, 'dragApp')
            app = src.UserData.dragApp;
            if isvalid(app) && ismethod(app, 'stopDrag')
                % Вызвать метод stopDrag
                app.stopDrag(src, evt);
            else
                fprintf('⚠ handleDragUp: app не валиден или метод stopDrag не найден\n');
            end
        else
            fprintf('⚠ handleDragUp: dragApp не найден в UserData\n');
        end
    catch ME
        fprintf('Ошибка в handleDragUp: %s\n', ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end


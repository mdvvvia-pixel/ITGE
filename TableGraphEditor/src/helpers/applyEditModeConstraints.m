%% APPLYEDITMODECONSTRAINTS Применить ограничения режима редактирования
%   Применяет ограничения режима редактирования к новым координатам мыши
%
%   Использование:
%       constrainedPosition = applyEditModeConstraints(app, mousePosition, originalPosition)
%
%   Параметры:
%       app - объект приложения TableGraphEditor
%       mousePosition - [x, y] координаты мыши в координатах данных
%       originalPosition - [x, y] исходные координаты точки
%
%   Возвращает:
%       constrainedPosition - [x, y] координаты с примененными ограничениями
%
%   Режимы:
%       'X' - изменяется только X, Y остается исходным
%       'Y' - изменяется только Y, X остается исходным
%       'XY' - изменяются обе координаты (без ограничений)
%
%   Автор: AI Assistant
%   Дата: 2026-01-10
%   Версия: 1.0.0

function constrainedPosition = applyEditModeConstraints(app, mousePosition, originalPosition)
    % APPLYEDITMODECONSTRAINTS Применить ограничения режима редактирования
    
    % Проверить входные данные
    if isempty(mousePosition) || length(mousePosition) < 2
        fprintf('⚠ applyEditModeConstraints: некорректные координаты мыши\n');
        constrainedPosition = [];
        return;
    end
    
    if isempty(originalPosition) || length(originalPosition) < 2
        fprintf('⚠ applyEditModeConstraints: некорректные исходные координаты\n');
        constrainedPosition = [];
        return;
    end
    
    % Получить режим редактирования (безопасно)
    editMode = 'XY';  % По умолчанию
    if isprop(app, 'editMode')
        try
            editMode = app.editMode;
        catch
            if isfield(app.UIFigure.UserData, 'appData') && ...
               isfield(app.UIFigure.UserData.appData, 'editMode')
                editMode = app.UIFigure.UserData.appData.editMode;
            else
                editMode = 'XY';
            end
        end
    else
        if isfield(app.UIFigure.UserData, 'appData') && ...
           isfield(app.UIFigure.UserData.appData, 'editMode')
            editMode = app.UIFigure.UserData.appData.editMode;
        end
    end
    
    % Проверить валидность режима
    if ~ischar(editMode) && ~isstring(editMode)
        editMode = 'XY';
    end
    
    editMode = upper(char(editMode));
    
    % Применить ограничения
    switch editMode
        case 'X'
            % Режим X: изменяется только X, Y остается исходным
            % ВАЖНО: сохраняем исходную координату Y
            constrainedPosition = [mousePosition(1), originalPosition(2)];
            fprintf('  Режим X: X=%.4f (от мыши), Y=%.4f (сохранен исходный)\n', ...
                mousePosition(1), originalPosition(2));
            
        case 'Y'
            % Режим Y: изменяется только Y, X остается исходным
            % ВАЖНО: сохраняем исходную координату X
            constrainedPosition = [originalPosition(1), mousePosition(2)];
            fprintf('  Режим Y: X=%.4f (сохранен исходный), Y=%.4f (от мыши)\n', ...
                originalPosition(1), mousePosition(2));
            
        case 'XY'
            % Режим XY: изменяются обе координаты
            constrainedPosition = mousePosition;
            fprintf('  Режим XY: обе координаты изменяются свободно\n');
            
        otherwise
            % Неизвестный режим - использовать XY
            fprintf('⚠ applyEditModeConstraints: неизвестный режим "%s", используется XY\n', editMode);
            constrainedPosition = mousePosition;
    end
    
    % Проверить валидность результата
    if ~isfinite(constrainedPosition(1)) || ~isfinite(constrainedPosition(2))
        fprintf('⚠ applyEditModeConstraints: результат содержит NaN/Inf\n');
        % Вернуть исходные координаты в случае ошибки
        constrainedPosition = originalPosition;
    end
end


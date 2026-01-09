%% UPDATEGRAPHWITHDATASTORE Обновляет график используя AppDataStore
%   Альтернативная версия updateGraph для использования с AppDataStore
%
%   Использование:
%       updateGraphWithDataStore(app, appData)

function updateGraphWithDataStore(app, appData)
    % UPDATEGRAPHWITHDATASTORE Обновляет график используя AppDataStore
    
    % Предотвратить циклические обновления
    if appData.isUpdating || isempty(appData.currentData)
        return;
    end
    
    appData.isUpdating = true;
    
    try
        % Построить график в зависимости от типа
        if strcmp(appData.currentPlotType, 'columns')
            plotByColumns(app, appData.currentData);
        else
            plotByRows(app, appData.currentData);
        end
        
        % Ограничить частоту обновлений
        drawnow limitrate;
        
    catch ME
        uialert(app.UIFigure, sprintf('Ошибка построения графика: %s', ME.message), 'Ошибка построения графика');
    end
    
    appData.isUpdating = false;
end


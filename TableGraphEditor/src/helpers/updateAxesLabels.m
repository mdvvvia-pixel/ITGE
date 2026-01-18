%% UPDATEAXESLABELS Обновляет подписи графика (Title/XLabel/YLabel) по текущим данным
%   Требования:
%   - Заголовок графика: имя основной переменной (selectedVariable)
%   - Подпись оси X: имя переменной, используемой как X (A или B)
%   - Подпись оси Y: убрать (пустая строка)
%
%   Использование:
%       updateAxesLabels(app, plotType)
%
%   Параметры:
%       app      - объект приложения
%       plotType - 'columns' или 'rows'

function updateAxesLabels(app, plotType)
    if nargin < 2
        plotType = 'columns';
    end
    
    % Защитные проверки
    if ~isprop(app, 'axPlot') || ~isvalid(app.axPlot)
        return;
    end
    
    % selectedVariable
    mainVarName = '';
    try
        if isprop(app, 'selectedVariable')
            mainVarName = app.selectedVariable;
        elseif isfield(app.UIFigure.UserData, 'appData') && isfield(app.UIFigure.UserData.appData, 'selectedVariable')
            mainVarName = app.UIFigure.UserData.appData.selectedVariable;
        end
    catch
        mainVarName = '';
    end
    if isstring(mainVarName)
        mainVarName = char(mainVarName);
    end
    if ~ischar(mainVarName)
        mainVarName = '';
    end
    
    % X variable name/path
    xVarName = '';
    try
        if isfield(app.UIFigure.UserData, 'appData')
            if strcmp(plotType, 'rows') && isfield(app.UIFigure.UserData.appData, 'columnNameVarPath')
                xVarName = app.UIFigure.UserData.appData.columnNameVarPath; % B
            elseif isfield(app.UIFigure.UserData.appData, 'rowNameVarPath')
                xVarName = app.UIFigure.UserData.appData.rowNameVarPath;     % A
            end
        end
    catch
        xVarName = '';
    end
    if isstring(xVarName)
        xVarName = char(xVarName);
    end
    if ~ischar(xVarName)
        xVarName = '';
    end
    
    % Применить подписи
    try
        if ~isempty(mainVarName)
            title(app.axPlot, mainVarName, 'Interpreter', 'none');
        else
            title(app.axPlot, '', 'Interpreter', 'none');
        end
    catch
    end
    
    try
        if ~isempty(xVarName)
            xlabel(app.axPlot, xVarName, 'Interpreter', 'none');
        else
            xlabel(app.axPlot, 'X', 'Interpreter', 'none');
        end
    catch
    end
    
    % Убрать подпись Y
    try
        ylabel(app.axPlot, '', 'Interpreter', 'none');
    catch
    end
end


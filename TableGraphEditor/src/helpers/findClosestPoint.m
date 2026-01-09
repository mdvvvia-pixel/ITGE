%% FINDCLOSESTPOINT Найти ближайшую точку к позиции клика на графике
%   Находит ближайшую точку на графике к заданной позиции клика
%
%   Использование:
%       pointIndex = findClosestPoint(app, clickPosition)
%
%   Параметры:
%       app - объект приложения TableGraphEditor
%       clickPosition - координаты клика [x, y] в координатах данных
%
%   Возвращает:
%       pointIndex - [curveIndex, pointIndex] или [] если точка не найдена
%                    curveIndex - индекс кривой (линии) на графике
%                    pointIndex - индекс точки в кривой
%
%   Описание:
%       - Ищет ближайшую точку среди всех кривых на графике
%       - Использует нормализованные координаты (0-1) для учета разных масштабов осей
%       - Вычисляет евклидово расстояние в нормализованных координатах
%       - Возвращает пустой массив, если ближайшая точка слишком далеко
%       - Порог расстояния: адаптивный, учитывает размер маркеров (MarkerSize = 6)
%       - Порог вычисляется в нормализованных координатах для корректной работы
%         с любыми масштабами осей

function pointIndex = findClosestPoint(app, clickPosition)
    % FINDCLOSESTPOINT Найти ближайшую точку к позиции клика
    
    fprintf('findClosestPoint вызван: clickPosition=[%s]\n', mat2str(clickPosition));
    
    % Проверить входные данные
    if isempty(clickPosition) || length(clickPosition) < 2
        fprintf('⚠ findClosestPoint: некорректные координаты клика\n');
        pointIndex = [];
        return;
    end
    
    % Проверить наличие компонента axPlot
    if ~isprop(app, 'axPlot') || ~isvalid(app.axPlot)
        fprintf('⚠ findClosestPoint: axPlot не найден или не валиден\n');
        pointIndex = [];
        return;
    end
    
    try
        % Получить все дочерние элементы графика (кривые)
        children = app.axPlot.Children;
        
        if isempty(children)
            fprintf('⚠ findClosestPoint: график пуст (нет кривых)\n');
            pointIndex = [];
            return;
        end
        
        % Вычислить адаптивный порог расстояния на основе диапазона данных
        % Получить все точки со всех кривых для вычисления диапазона
        allX = [];
        allY = [];
        for i = 1:length(children)
            if isa(children(i), 'matlab.graphics.chart.primitive.Line')
                line = children(i);
                if ~isempty(line.XData) && ~isempty(line.YData)
                    allX = [allX, line.XData];
                    allY = [allY, line.YData];
                end
            end
        end
        
        % Вычислить адаптивный порог расстояния в нормализованных координатах
        % ВАЖНО: Используем нормализованные координаты (0-1) для учета разных масштабов осей
        if ~isempty(allX) && ~isempty(allY)
            % Получить размер axes в пикселях для преобразования
            axPos = getpixelposition(app.axPlot);
            axWidthPx = axPos(3);
            axHeightPx = axPos(4);
            
            % Размер маркера в пикселях (MarkerSize = 6)
            markerSizePx = 6;
            
            % Преобразовать размер маркера в нормализованные координаты (0-1)
            % markerSizePx / axSizePx дает размер маркера как долю от размера axes
            markerSizeNormX = markerSizePx / axWidthPx;
            markerSizeNormY = markerSizePx / axHeightPx;
            
            % Использовать максимальный размер для области захвата
            % Это обеспечивает достаточную область захвата в обоих направлениях
            markerSizeNorm = max(markerSizeNormX, markerSizeNormY);
            
            % Базовый порог: 5% от диагонали в нормализованных координатах
            % В нормализованных координатах диагональ всегда sqrt(2) ≈ 1.414
            baseThresholdNorm = 0.05 * sqrt(2);
            
            % Финальный порог в нормализованных координатах: максимум из базового порога
            % и размера маркера с коэффициентом для комфортного захвата
            distanceThresholdNorm = max(baseThresholdNorm, markerSizeNorm * 5.0);
            
            % Минимальный порог для очень маленьких маркеров
            if distanceThresholdNorm < 0.01
                distanceThresholdNorm = 0.01;
            end
            
            fprintf('Порог расстояния (нормализованный): %.4f (базовый: %.4f, размер маркера: %.4f)\n', ...
                distanceThresholdNorm, baseThresholdNorm, markerSizeNorm);
        else
            % Использовать фиксированный порог в нормализованных координатах, если не удалось вычислить
            distanceThresholdNorm = 0.1;
        end
        
        fprintf('Порог расстояния (нормализованный): %.4f\n', distanceThresholdNorm);
        
        % Получить пределы осей для нормализации координат (один раз, вне цикла)
        xLim = app.axPlot.XLim;
        yLim = app.axPlot.YLim;
        xRangeNorm = xLim(2) - xLim(1);
        yRangeNorm = yLim(2) - yLim(1);
        
        % Проверить, что диапазоны не нулевые
        if xRangeNorm <= 0 || yRangeNorm <= 0
            fprintf('⚠ findClosestPoint: некорректные пределы осей (xRange=%.4f, yRange=%.4f)\n', ...
                xRangeNorm, yRangeNorm);
            pointIndex = [];
            return;
        end
        
        % Нормализовать координаты клика (один раз, вне цикла)
        clickNorm = [
            (clickPosition(1) - xLim(1)) / xRangeNorm,
            (clickPosition(2) - yLim(1)) / yRangeNorm
        ];
        
        minDistance = inf;
        pointIndex = [];
        bestCurveIdx = [];
        bestPointIdx = [];
        
        % Проверить каждую линию (кривую) на графике
        for curveIdx = 1:length(children)
            if isa(children(curveIdx), 'matlab.graphics.chart.primitive.Line')
                line = children(curveIdx);
                xData = line.XData;
                yData = line.YData;
                
                % Проверить, что данные не пусты
                if isempty(xData) || isempty(yData) || length(xData) ~= length(yData)
                    continue;
                end
                
                % Вычислить расстояния до всех точек этой кривой
                % ВАЖНО: Используем нормализованные координаты для учета разных масштабов осей
                
                for pointIdx = 1:length(xData)
                    point = [xData(pointIdx), yData(pointIdx)];
                    
                    % Проверить, что точка валидна (не NaN, не Inf)
                    if ~isfinite(point(1)) || ~isfinite(point(2))
                        continue;
                    end
                    
                    % Нормализовать координаты точки
                    pointNorm = [
                        (point(1) - xLim(1)) / xRangeNorm,
                        (point(2) - yLim(1)) / yRangeNorm
                    ];
                    
                    % Вычислить евклидово расстояние в нормализованных координатах
                    distanceNorm = norm(clickNorm - pointNorm);
                    
                    if distanceNorm < minDistance
                        minDistance = distanceNorm;
                        bestCurveIdx = curveIdx;
                        bestPointIdx = pointIdx;
                    end
                end
            end
        end
        
        % Проверить, что точка найдена и достаточно близко (в нормализованных координатах)
        if isempty(bestCurveIdx) || minDistance > distanceThresholdNorm
            fprintf('⚠ findClosestPoint: точка не найдена (minDistance=%.4f, threshold=%.4f)\n', ...
                minDistance, distanceThresholdNorm);
            pointIndex = [];
            return;
        end
        
        pointIndex = [bestCurveIdx, bestPointIdx];
        fprintf('✓ Найдена ближайшая точка: кривая %d, точка %d (расстояние=%.4f)\n', ...
            bestCurveIdx, bestPointIdx, minDistance);
        
    catch ME
        fprintf('Ошибка в findClosestPoint: %s\n', ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        pointIndex = [];
    end
end


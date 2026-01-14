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
        
        % АЛГОРИТМ: Так как у всех кривых одинаковые X координаты (в режиме "по столбцам"),
        % сначала находим ближайшую координату X, затем среди точек с этим X выбираем ближайшую по Y.
        % Это более логично и соответствует ожиданиям пользователя.
        
        % Шаг 1: Найти все уникальные X координаты и определить ближайшую к клику
        allXCoords = [];
        for curveIdx = 1:length(children)
            if isa(children(curveIdx), 'matlab.graphics.chart.primitive.Line')
                line = children(curveIdx);
                xData = line.XData;
                if ~isempty(xData)
                    allXCoords = [allXCoords, xData];
                end
            end
        end
        
        % Получить уникальные X координаты
        uniqueXCoords = unique(allXCoords);
        uniqueXCoords = uniqueXCoords(isfinite(uniqueXCoords));
        
        if isempty(uniqueXCoords)
            fprintf('⚠ findClosestPoint: не найдено валидных X координат\n');
            pointIndex = [];
            return;
        end
        
        % Найти ближайшую X координату к клику
        clickX = clickPosition(1);
        xDistances = abs(uniqueXCoords - clickX);
        [~, closestXIdx] = min(xDistances);
        closestX = uniqueXCoords(closestXIdx);
        
        fprintf('  Ближайшая X координата: %.4f (клик: %.4f, расстояние: %.4f)\n', ...
            closestX, clickX, xDistances(closestXIdx));
        
        % Шаг 2: Найти все точки на всех кривых с этой X координатой
        % и выбрать ближайшую по Y координате, учитывая z-order
        minYDistance = inf;
        pointIndex = [];
        bestCurveIdx = [];
        bestPointIdx = [];
        
        % ВАЖНО: Перебираем кривые в прямом порядке (от верхней к нижней), чтобы
        % при визуальном перекрытии выбирать верхнюю кривую.
        % В MATLAB последняя нарисованная кривая находится визуально "сверху".
        %
        % ПОРЯДОК В Children (обратный порядку построения):
        % При построении по столбцам: yColumns = [2, 3, 4]
        % - Первая нарисованная: Column 2 → Children(3) (нижняя)
        % - Вторая нарисованная: Column 3 → Children(2) (средняя)
        % - Третья нарисованная: Column 4 → Children(1) (верхняя, визуально сверху)
        %
        % Children(1) = верхняя кривая (последняя нарисованная)
        % Children(3) = нижняя кривая (первая нарисованная)
        %
        % Меньший индекс = выше в z-order
        %
        % Добавить отладочный вывод для проверки порядка кривых
        fprintf('  Всего кривых на графике: %d\n', length(children));
        for debugIdx = 1:length(children)
            if isa(children(debugIdx), 'matlab.graphics.chart.primitive.Line')
                debugLine = children(debugIdx);
                if ~isempty(debugLine.XData) && ~isempty(debugLine.YData) && length(debugLine.XData) >= 2
                    % Определить позицию кривой для отладки
                    if debugIdx == 1
                        positionStr = 'верхняя';
                    elseif debugIdx == length(children)
                        positionStr = 'нижняя';
                    else
                        positionStr = 'средняя';
                    end
                    fprintf('  Children(%d): X=%.4f, Y=%.4f (точка 2) - %s\n', ...
                        debugIdx, debugLine.XData(2), debugLine.YData(2), positionStr);
                end
            end
        end
        
        % Перебираем в прямом порядке (от верхней к нижней), чтобы приоритет был у верхней кривой
        for curveIdx = 1:length(children)
            if isa(children(curveIdx), 'matlab.graphics.chart.primitive.Line')
                line = children(curveIdx);
                xData = line.XData;
                yData = line.YData;
                
                % Проверить, что данные не пусты
                if isempty(xData) || isempty(yData) || length(xData) ~= length(yData)
                    continue;
                end
                
                % Найти точки с ближайшей X координатой
                % Используем небольшой порог для учета погрешностей округления
                xTolerance = 1e-6 * xRangeNorm; % Очень маленький порог для сравнения X
                
                for pointIdx = 1:length(xData)
                    pointX = xData(pointIdx);
                    pointY = yData(pointIdx);
                    
                    % Проверить, что точка валидна (не NaN, не Inf)
                    if ~isfinite(pointX) || ~isfinite(pointY)
                        continue;
                    end
                    
                    % Проверить, что X координата совпадает с ближайшей (в пределах tolerance)
                    if abs(pointX - closestX) > xTolerance
                        continue;
                    end
                    
                    % Вычислить расстояние по Y координате (в нормализованных координатах)
                    pointYNorm = (pointY - yLim(1)) / yRangeNorm;
                    clickYNorm = clickNorm(2);
                    yDistanceNorm = abs(clickYNorm - pointYNorm);
                    
                    fprintf('  Кривая %d, точка %d: X=%.4f, Y=%.4f, расстояние по Y=%.4f\n', ...
                        curveIdx, pointIdx, pointX, pointY, yDistanceNorm);
                    
                    % ВАЖНО: При переборе в прямом порядке (от верхней к нижней)
                    % первая найденная точка находится на верхней кривой (Children(1)).
                    % Если точка на верхней кривой находится в пределах разумного порога,
                    % выбираем её, даже если на нижних кривых есть точки ближе по Y.
                    % Это соответствует визуальному восприятию пользователя.
                    %
                    % Порядок в Children: Children(1) = верхняя, Children(3) = нижняя
                    % Меньший индекс = выше в z-order
                    %
                    % КЛЮЧЕВАЯ ЛОГИКА: Если уже выбрана точка на верхней кривой (меньший curveIdx),
                    % точка на нижней кривой (больший curveIdx) может заменить её ТОЛЬКО если
                    % она значительно ближе (более чем на visualOverlapThreshold).
                    
                    % Порог для учета визуального перекрытия (в нормализованных координатах)
                    % Если точка на верхней кривой в пределах этого порога, она выбирается,
                    % даже если на нижней кривой есть точка ближе по Y
                    visualOverlapThreshold = distanceThresholdNorm; % Используем тот же порог, что и для проверки валидности
                    
                    % Выбрать ближайшую по Y, учитывая z-order
                    if isempty(bestCurveIdx)
                        % Первая найденная точка - всегда выбираем (это верхняя кривая при прямом переборе)
                        minYDistance = yDistanceNorm;
                        bestCurveIdx = curveIdx;
                        bestPointIdx = pointIdx;
                        fprintf('    → Выбрана (первая точка на этой X, кривая %d, расстояние по Y=%.4f)\n', ...
                            curveIdx, yDistanceNorm);
                    elseif curveIdx < bestCurveIdx
                        % Найдена точка на верхней кривой (меньший индекс = выше в z-order)
                        % Если она в пределах визуального перекрытия - выбираем её
                        if yDistanceNorm <= visualOverlapThreshold
                            fprintf('    → Обновлено (визуальный приоритет верхней кривой): кривая %d вместо %d (расстояние по Y: %.4f <= %.4f)\n', ...
                                curveIdx, bestCurveIdx, yDistanceNorm, visualOverlapThreshold);
                            minYDistance = yDistanceNorm;
                            bestCurveIdx = curveIdx;
                            bestPointIdx = pointIdx;
                        else
                            fprintf('    → Пропущено (верхняя кривая, но слишком далеко по Y: %.4f > %.4f)\n', ...
                                yDistanceNorm, visualOverlapThreshold);
                        end
                    elseif curveIdx > bestCurveIdx
                        % Найдена точка на нижней кривой (больший индекс = ниже в z-order)
                        % Может заменить верхнюю ТОЛЬКО если:
                        % 1. Верхняя кривая НЕ в пределах визуального перекрытия (слишком далеко)
                        % 2. ИЛИ нижняя кривая значительно ближе (более чем на visualOverlapThreshold)
                        upperCurveInRange = minYDistance <= visualOverlapThreshold;
                        
                        if ~upperCurveInRange
                            % Верхняя кривая слишком далеко - можно заменить на ближайшую
                            if yDistanceNorm < minYDistance
                                fprintf('    → Обновлено (нижняя кривая ближе, верхняя была слишком далеко): кривая %d вместо %d\n', ...
                                    curveIdx, bestCurveIdx);
                                minYDistance = yDistanceNorm;
                                bestCurveIdx = curveIdx;
                                bestPointIdx = pointIdx;
                            else
                                fprintf('    → Пропущено (нижняя кривая дальше, верхняя была слишком далеко)\n');
                            end
                        elseif yDistanceNorm < minYDistance - visualOverlapThreshold
                            % Верхняя кривая в пределах визуального перекрытия, но нижняя значительно ближе
                            fprintf('    → Обновлено (нижняя кривая значительно ближе): кривая %d вместо %d (расстояние: %.4f < %.4f - %.4f)\n', ...
                                curveIdx, bestCurveIdx, yDistanceNorm, minYDistance, visualOverlapThreshold);
                            minYDistance = yDistanceNorm;
                            bestCurveIdx = curveIdx;
                            bestPointIdx = pointIdx;
                        else
                            fprintf('    → Пропущено (нижняя кривая, но верхняя в пределах визуального перекрытия и не достаточно ближе)\n');
                        end
                    else
                        % curveIdx == bestCurveIdx (та же кривая) - не должно происходить, но на всякий случай
                        if yDistanceNorm < minYDistance
                            fprintf('    → Обновлено (та же кривая, ближе точка): точка %d вместо %d\n', ...
                                pointIdx, bestPointIdx);
                            minYDistance = yDistanceNorm;
                            bestPointIdx = pointIdx;
                        end
                    end
                end
            end
        end
        
        % Проверить, что точка найдена и достаточно близко по Y (в нормализованных координатах)
        % Используем порог для Y координаты (расстояние по Y должно быть в пределах порога)
        if isempty(bestCurveIdx) || minYDistance > distanceThresholdNorm
            fprintf('⚠ findClosestPoint: точка не найдена (minYDistance=%.4f, threshold=%.4f)\n', ...
                minYDistance, distanceThresholdNorm);
            pointIndex = [];
            return;
        end
        
        pointIndex = [bestCurveIdx, bestPointIdx];
        fprintf('✓ Найдена ближайшая точка: кривая %d, точка %d (расстояние по Y=%.4f, X=%.4f)\n', ...
            bestCurveIdx, bestPointIdx, minYDistance, closestX);
        
    catch ME
        fprintf('Ошибка в findClosestPoint: %s\n', ME.message);
        fprintf('Стек ошибки:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        pointIndex = [];
    end
end


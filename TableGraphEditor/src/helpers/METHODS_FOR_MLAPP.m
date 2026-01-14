%% METHODS_FOR_MLAPP Методы для добавления в .mlapp файл
%   Эти методы вызывают helper функции из папки helpers/
%   Скопируйте эти методы в секцию methods (Access = private) в Code View
%
%   Добавьте после функции createComponents или в любом месте в methods (Access = private)
%
%   Дата обновления: 2026-01-10 (добавлен editModeChanged для режимов редактирования X/Y/XY)
%
% ═══════════════════════════════════════════════════════════════════════
% СПИСОК ФУНКЦИЙ ДЛЯ ДОБАВЛЕНИЯ В .MLAPP ФАЙЛ:
% ═══════════════════════════════════════════════════════════════════════
%
% ОБЯЗАТЕЛЬНО добавить в TableGraphEditor.mlapp:
%
% 1. startupFcn                    (строки ~45-110)
% 2. ddVariableDropDownOpening     (строки ~142-172)  ← ДЛЯ ОБНОВЛЕНИЯ СПИСКА ПЕРЕМЕННЫХ
% 3. ddVariableValueChanged        (строки ~174-237)
% 4. ddPlotTypeValueChanged        (строки ~239-333)
% 5. btnSaveButtonPushed          (строки ~328-423)
% 6. tblDataSelectionChanged       (строки ~426-488)
% 7. tblDataCellEdit                (строки ~523-643)  ← ДЛЯ РЕДАКТИРОВАНИЯ ТАБЛИЦЫ
% 8. axPlotButtonDown             (строки ~643-779)  ← ДЛЯ ПЕРЕТАСКИВАНИЯ
% 9. bgEditModeSelectionChanged    (строки ~1181+)  ← ДЛЯ РЕЖИМОВ РЕДАКТИРОВАНИЯ X/Y/XY
%
% ПРИМЕЧАНИЕ: dragPoint, stopDrag и checkMouseMovement вынесены в отдельные файлы:
% - helpers/dragPoint.m
% - helpers/stopDrag.m  
% - helpers/checkMouseMovement.m
% НЕ нужно добавлять эти методы в .mlapp файл - они вызываются как helper функции!
%
% ═══════════════════════════════════════════════════════════════════════
% ИНСТРУКЦИЯ ПО ДОБАВЛЕНИЮ:
% ═══════════════════════════════════════════════════════════════════════
%
% 1. Откройте TableGraphEditor.mlapp в App Designer
% 2. Перейдите в Code View
% 3. Найдите секцию methods (Access = private)
% 4. Скопируйте нужные функции из этого файла
% 5. Для ddVariable: в Design View выберите ddVariable → Property Inspector
%    → OpeningFcn → установите: @app.ddVariableDropDownOpening
%    → ValueChangedFcn → установите: @app.ddVariableValueChanged
% 6. Для axPlotButtonDown: в Design View выберите axPlot → Property Inspector
%    → ButtonDownFcn → установите: @app.axPlotButtonDown
% 7. Сохраните файл
%
% ═══════════════════════════════════════════════════════════════════════

        % === Инициализация ===
        function startupFcn(app, varargin)
            % STARTUPFCN Выполняется при запуске приложения
            %   Инициализирует dropdown переменных из workspace
            %   Вызывает helper функцию updateVariableDropdown из helpers/
            try
                % Проверить, что dropdown существует (используем isprop для App Designer)
                % В App Designer компоненты создаются как свойства, не как поля
                if ~isprop(app, 'ddVariable')
                    fprintf('Предупреждение: свойство ddVariable не найдено\n');
                    fprintf('Диагностика: проверяем доступные свойства...\n');
                    
                    % Диагностика: показать доступные свойства, содержащие 'Variable'
                    props = properties(app);
                    matchingProps = props(contains(props, 'Variable', 'IgnoreCase', true) | ...
                                        contains(props, 'dd', 'IgnoreCase', true) | ...
                                        contains(props, 'Dropdown', 'IgnoreCase', true));
                    if ~isempty(matchingProps)
                        fprintf('Найдены похожие свойства: %s\n', strjoin(matchingProps, ', '));
                    else
                        fprintf('Похожие свойства не найдены. Убедитесь, что компонент создан в Design View\n');
                    end
                    return;
                end
                
                % Проверить, что объект валиден
                if ~isvalid(app.ddVariable)
                    fprintf('Предупреждение: ddVariable не валиден\n');
                    return;
                end
                
                % Назначить callbacks программно (если не назначены)
                % Сначала проверяем, что методы существуют
                if ismethod(app, 'ddVariableDropDownOpening')
                    if isempty(app.ddVariable.OpeningFcn)
                        fprintf('Назначение callback ddVariableDropDownOpening программно...\n');
                        app.ddVariable.OpeningFcn = @app.ddVariableDropDownOpening;
                        fprintf('✓ OpeningFcn callback назначен\n');
                    else
                        fprintf('✓ OpeningFcn callback уже назначен\n');
                    end
                else
                    fprintf('⚠ Метод ddVariableDropDownOpening не найден!\n');
                    fprintf('  Необходимо добавить метод в .mlapp файл\n');
                    fprintf('  Скопируйте метод из METHODS_FOR_MLAPP.m\n');
                end
                
                if ismethod(app, 'ddVariableValueChanged')
                    if isempty(app.ddVariable.ValueChangedFcn)
                        fprintf('Назначение callback ddVariableValueChanged программно...\n');
                        app.ddVariable.ValueChangedFcn = @app.ddVariableValueChanged;
                        fprintf('✓ ValueChangedFcn callback назначен\n');
                    else
                        fprintf('✓ ValueChangedFcn callback уже назначен\n');
                    end
                else
                    fprintf('⚠ Метод ddVariableValueChanged не найден!\n');
                    fprintf('  Необходимо добавить метод в .mlapp файл\n');
                    fprintf('  Скопируйте метод из METHODS_FOR_MLAPP.m\n');
                end
                
                % Обновить список переменных
                updateVariableDropdown(app);
                
                % Установить режим редактирования 'Y' по умолчанию
                % ВАЖНО: Режим 'Y' устанавливается при запуске программы
                if isprop(app, 'editMode')
                    try
                        app.editMode = 'Y';
                        fprintf('✓ Режим редактирования установлен: Y (по умолчанию)\n');
                    catch
                        if ~isfield(app.UIFigure.UserData, 'appData')
                            app.UIFigure.UserData.appData = struct();
                        end
                        app.UIFigure.UserData.appData.editMode = 'Y';
                        fprintf('✓ Режим редактирования сохранен в UserData: Y (по умолчанию)\n');
                    end
                else
                    if ~isfield(app.UIFigure.UserData, 'appData')
                        app.UIFigure.UserData.appData = struct();
                    end
                    app.UIFigure.UserData.appData.editMode = 'Y';
                    fprintf('✓ Режим редактирования сохранен в UserData: Y (по умолчанию)\n');
                end
                
                % Установить выбранный radio button в группе bgEditMode (если существует)
                if isprop(app, 'bgEditMode') && isvalid(app.bgEditMode)
                    if isprop(app, 'rbModeY') && isvalid(app.rbModeY)
                        try
                            app.bgEditMode.SelectedObject = app.rbModeY;
                            fprintf('✓ Radio button rbModeY установлен как выбранный\n');
                        catch ME
                            fprintf('⚠ Не удалось установить rbModeY: %s\n', ME.message);
                        end
                    end
                end
                
                fprintf('✓ Инициализация завершена успешно\n');
                
            catch ME
                fprintf('Ошибка в startupFcn: %s\n', ME.message);
                fprintf('Стек ошибки:\n');
                for i = 1:length(ME.stack)
                    fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
                end
                
                if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                    uialert(app.UIFigure, ...
                        sprintf('Ошибка инициализации: %s', ME.message), ...
                        'Ошибка запуска', ...
                        'Icon', 'error');
                end
            end
        end
        
        % === Загрузка данных ===
        % ВАЖНО: Если в .mlapp файле есть метод loadVariableFromWorkspace,
        % УДАЛИТЕ ЕГО! Helper функция из папки helpers/ должна вызываться напрямую.
        % Методы класса имеют приоритет над функциями в path, поэтому
        % если метод существует в .mlapp, он перекрывает helper функцию.
        %
        % Если метод loadVariableFromWorkspace существует в .mlapp файле:
        % 1. Откройте .mlapp файл в App Designer
        % 2. Перейдите в Code View
        % 3. Найдите метод loadVariableFromWorkspace
        % 4. УДАЛИТЕ его полностью
        % 5. Сохраните файл
        %
        % Helper функция из helpers/loadVariableFromWorkspace.m будет
        % вызываться автоматически из ddVariableValueChanged
        
        function ddVariableDropDownOpening(app, event)
            % DDVARIABLEDROPDOWNOPENING Обработчик открытия dropdown
            %   Обновляет список переменных из workspace при открытии dropdown
            %   Вызывает helper функцию updateVariableDropdown из helpers/
            %
            %   ВАЖНО: Этот callback должен быть назначен в Design View:
            %   1. Выберите компонент ddVariable в Design View
            %   2. В Property Inspector найдите "OpeningFcn"
            %   3. Установите: @app.ddVariableDropDownOpening
            %   4. Сохраните файл
            %
            %   Это позволяет обновлять список переменных каждый раз,
            %   когда пользователь открывает dropdown, даже если переменные
            %   в Workspace изменились во время работы программы.
            %
            %   ПРИМЕЧАНИЕ: Если метод добавлен в .mlapp файл, callback
            %   может быть назначен программно в startupFcn (автоматически).
            
            fprintf('ddVariableDropDownOpening вызван - обновление списка переменных\n');
            
            try
                % Обновить список переменных из workspace
                updateVariableDropdown(app);
                fprintf('✓ Список переменных обновлен\n');
            catch ME
                fprintf('Ошибка обновления списка переменных: %s\n', ME.message);
                fprintf('Стек ошибки:\n');
                for i = 1:length(ME.stack)
                    fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
                end
                
                % Не показываем ошибку пользователю, чтобы не мешать работе
                % Просто логируем ошибку
            end
        end
        
        function ddVariableValueChanged(app, event)
            % DDVARIABLEVALUECHANGED Обработчик выбора переменной
            %   Загружает данные из workspace при выборе переменной
            %   Вызывает helper функцию loadVariableFromWorkspace из helpers/
            %
            %   ВАЖНО: Этот callback должен быть назначен в Design View:
            %   1. Выберите компонент ddVariable в Design View
            %   2. В Property Inspector найдите "ValueChangedFcn"
            %   3. Установите: @app.ddVariableValueChanged
            %   4. Сохраните файл
            
            fprintf('ddVariableValueChanged вызван\n');  % Отладочный вывод
            
            try
                % Получить выбранную переменную
                % Если используется ItemsData, то Value будет содержать значение из ItemsData
                % Иначе - строку из Items
                varName = app.ddVariable.Value;
                fprintf('Выбранное значение: %s (тип: %s)\n', ...
                    mat2str(varName), class(varName));
                
                % Преобразовать в строку, если это не строка
                if isnumeric(varName)
                    varName = '';
                elseif ischar(varName)
                    varName = varName;
                elseif isstring(varName)
                    varName = char(varName);
                else
                    varName = '';
                end
                
                fprintf('Обработанное значение: "%s"\n', varName);
                
                % Проверить, что выбрана валидная переменная
                if isempty(varName) || strcmp(varName, 'Select variable...') || ...
                   strcmp(varName, 'Нет числовых переменных') || strcmp(varName, '')
                    fprintf('Пропуск: значение не валидно\n');
                    return;
                end
                
                fprintf('Загрузка переменной: %s\n', varName);
                
                % Загрузить переменную (helper функция сделает валидацию)
                % Helper функция находится в helpers/ и автоматически в path
                loadVariableFromWorkspace(app, varName);
                
                fprintf('✓ Переменная загружена успешно\n');
                
            catch ME
                fprintf('Ошибка в ddVariableValueChanged: %s\n', ME.message);
                fprintf('Стек ошибки:\n');
                for i = 1:length(ME.stack)
                    fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
                end
                
                if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                    uialert(app.UIFigure, ...
                        sprintf('Ошибка загрузки данных: %s', ME.message), ...
                        'Ошибка загрузки', ...
                        'Icon', 'error');
                end
            end
        end
        
        % === Построение графиков ===
        function ddPlotTypeValueChanged(app, event)
            % DDPLOTTYPEVALUECHANGED Обработчик изменения типа графика
            %   Обновляет режим построения графика и перестраивает график
            %   Также обновляет таблицу для корректного отображения меток
            %
            %   ВАЖНО: Этот callback должен быть назначен в Design View:
            %   1. Выберите компонент ddPlotType в Design View
            %   2. В Property Inspector найдите "ValueChangedFcn"
            %   3. Установите: @app.ddPlotTypeValueChanged
            %   4. Сохраните файл
            
            fprintf('ddPlotTypeValueChanged вызван\n');  % Отладочный вывод
            
            try
                % Получить выбранное значение
                selectedValue = app.ddPlotType.Value;
                fprintf('Выбранное значение: %s (тип: %s)\n', ...
                    mat2str(selectedValue), class(selectedValue));
                
                % Преобразовать значение dropdown в режим ('columns' или 'rows')
                % Предполагаем, что Items содержат: {'By Columns', 'By Rows'}
                % или {'columns', 'rows'}
                if ischar(selectedValue) || isstring(selectedValue)
                    selectedValue = char(selectedValue);
                    if contains(selectedValue, 'Column', 'IgnoreCase', true) || ...
                       strcmp(selectedValue, 'columns')
                        plotType = 'columns';
                    elseif contains(selectedValue, 'Row', 'IgnoreCase', true) || ...
                           strcmp(selectedValue, 'rows')
                        plotType = 'rows';
                    else
                        plotType = 'columns';  % По умолчанию
                    end
                else
                    plotType = 'columns';  % По умолчанию
                end
                
                fprintf('Установка режима: %s\n', plotType);
                
                % Обновить тип графика (безопасно)
                if isprop(app, 'currentPlotType')
                    try
                        app.currentPlotType = plotType;
                        fprintf('✓ currentPlotType установлен: %s\n', plotType);
                    catch ME
                        fprintf('Предупреждение: не удалось установить currentPlotType: %s\n', ME.message);
                        % Попробовать через UserData
                        if ~isfield(app.UIFigure.UserData, 'appData')
                            app.UIFigure.UserData.appData = struct();
                        end
                        app.UIFigure.UserData.appData.currentPlotType = plotType;
                        fprintf('currentPlotType сохранен в UserData\n');
                    end
                else
                    % Сохранить в UserData, если свойство не существует
                    if ~isfield(app.UIFigure.UserData, 'appData')
                        app.UIFigure.UserData.appData = struct();
                    end
                    app.UIFigure.UserData.appData.currentPlotType = plotType;
                    fprintf('currentPlotType сохранен в UserData (свойство не существует)\n');
                end
                
                % Обновить таблицу с новыми метками (важно для корректного отображения)
                if exist('updateTableWithData', 'file') == 2
                    fprintf('Обновление таблицы...\n');
                    updateTableWithData(app);
                    fprintf('✓ Таблица обновлена\n');
                else
                    fprintf('⚠ Функция updateTableWithData не найдена\n');
                end
                
                % Обновить график (вызов helper функции)
                if exist('updateGraph', 'file') == 2
                    fprintf('Обновление графика...\n');
                    updateGraph(app);
                    fprintf('✓ График обновлен\n');
                else
                    fprintf('⚠ Функция updateGraph не найдена\n');
                end
                
            catch ME
                fprintf('Ошибка в ddPlotTypeValueChanged: %s\n', ME.message);
                fprintf('Стек ошибки:\n');
                for i = 1:length(ME.stack)
                    fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
                end
                
                if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                    uialert(app.UIFigure, ...
                        sprintf('Ошибка изменения режима графика: %s', ME.message), ...
                        'Ошибка', ...
                        'Icon', 'error');
                end
            end
        end
        
        % Эти методы можно вызывать напрямую из callbacks, используя helper функции
        % из папки helpers/. Например:
        %   plotByColumns(app, app.currentData);
        %   plotByRows(app, app.currentData);
        %   updateGraph(app);
        %
        % Helper функции автоматически доступны, так как папка helpers/
        % добавляется в MATLAB path при открытии .mlapp файла
        
        % === Сохранение данных ===
        function btnSaveButtonPushed(app, event)
            % BTNSAVEBUTTONPUSHED Обработчик нажатия кнопки сохранения
            %   Сохраняет данные в workspace с подтверждением
            %   Поддерживает как прямые переменные, так и переменные из структур
            %   Вызывает helper функцию saveVariableToWorkspace из helpers/
            %
            %   ВАЖНО: Этот callback должен быть назначен в Design View:
            %   1. Выберите компонент btnSave в Design View
            %   2. В Property Inspector найдите "ButtonPushedFcn"
            %   3. Установите: @app.btnSaveButtonPushed
            %   4. Сохраните файл
            
            fprintf('btnSaveButtonPushed вызван\n');  % Отладочный вывод
            
            try
                % Получить данные для сохранения (безопасно)
                currentData = [];
                selectedVariable = '';
                
                % Попробовать получить currentData
                if isprop(app, 'currentData')
                    currentData = app.currentData;
                elseif isfield(app.UIFigure.UserData, 'appData') && ...
                       isfield(app.UIFigure.UserData.appData, 'currentData')
                    currentData = app.UIFigure.UserData.appData.currentData;
                end
                
                % Попробовать получить selectedVariable
                if isprop(app, 'selectedVariable')
                    selectedVariable = app.selectedVariable;
                elseif isfield(app.UIFigure.UserData, 'appData') && ...
                       isfield(app.UIFigure.UserData.appData, 'selectedVariable')
                    selectedVariable = app.UIFigure.UserData.appData.selectedVariable;
                end
                
                % Проверить, что данные загружены
                if isempty(currentData) || isempty(selectedVariable)
                    uialert(app.UIFigure, ...
                        'Нет данных для сохранения. Сначала загрузите переменную.', ...
                        'Ошибка сохранения', ...
                        'Icon', 'warning');
                    return;
                end
                
                % Показать диалог подтверждения
                message = sprintf('Перезаписать переменную "%s" в workspace?', ...
                    selectedVariable);
                
                selection = uiconfirm(app.UIFigure, ...
                    message, ...
                    'Подтверждение сохранения', ...
                    'Options', {'Да', 'Нет'}, ...
                    'DefaultOption', 'Нет', ...
                    'CancelOption', 'Нет', ...
                    'Icon', 'question');
                
                % Проверить ответ
                if strcmp(selection, 'Да')
                    % Сохранить данные через helper функцию
                    % (поддерживает как прямые переменные, так и структуры)
                    saveVariableToWorkspace(app, selectedVariable, currentData);
                    
                    % Обновить originalData
                    if isprop(app, 'originalData')
                        app.originalData = currentData;
                    elseif isfield(app.UIFigure.UserData, 'appData')
                        app.UIFigure.UserData.appData.originalData = currentData;
                    end
                    
                    % Показать сообщение об успехе
                    uialert(app.UIFigure, ...
                        sprintf('Данные успешно сохранены в переменную "%s"', ...
                            selectedVariable), ...
                        'Сохранение завершено', ...
                        'Icon', 'success');
                    
                    fprintf('✓ Данные сохранены успешно\n');
                else
                    fprintf('Сохранение отменено пользователем\n');
                end
                
            catch ME
                fprintf('Ошибка в btnSaveButtonPushed: %s\n', ME.message);
                fprintf('Стек ошибки:\n');
                for i = 1:length(ME.stack)
                    fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
                end
                
                if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                    uialert(app.UIFigure, ...
                        sprintf('Ошибка сохранения: %s', ME.message), ...
                        'Ошибка сохранения', ...
                        'Icon', 'error');
                end
            end
        end
        
        % === Обработка выделения в таблице ===
        function tblDataSelectionChanged(app, event)
            % TBLDATASELECTIONCHANGED Обработчик изменения выделения в таблице
            %   Обновляет выделенные столбцы/строки и перерисовывает график
            %   Вызывает helper функцию updateSelection из helpers/
            %
            %   ВАЖНО: Этот callback должен быть назначен в Design View:
            %   1. Выберите компонент tblData в Design View
            %   2. В Property Inspector найдите "SelectionChangedFcn"
            %   3. Установите: @app.tblDataSelectionChanged
            %   4. Сохраните файл
            %
            %   Примечание: uitable.Selection содержит массив [row, col] для каждой
            %   выделенной ячейки. Функция updateSelection извлекает уникальные
            %   столбцы/строки и исключает столбец/строку X (используемые для координат)
            
            fprintf('tblDataSelectionChanged вызван\n');  % Отладочный вывод
            
            try
                % Получить выделение из таблицы
                if ~isprop(app, 'tblData') || ~isvalid(app.tblData)
                    fprintf('⚠ tblData не найден или не валиден\n');
                    return;
                end
                
                selection = app.tblData.Selection;
                fprintf('Выделение получено: %s\n', mat2str(selection));
                
                % Обновить выделение через helper функцию
                % (извлекает уникальные столбцы/строки и исключает столбец/строку X)
                if exist('updateSelection', 'file') == 2
                    updateSelection(app, selection);
                    fprintf('✓ Выделение обновлено\n');
                else
                    fprintf('⚠ Функция updateSelection не найдена\n');
                    return;
                end
                
                % Обновить график (только для выделенных столбцов/строк)
                if exist('updateGraph', 'file') == 2
                    fprintf('Обновление графика с учетом выделения...\n');
                    updateGraph(app);
                    fprintf('✓ График обновлен\n');
                else
                    fprintf('⚠ Функция updateGraph не найдена\n');
                end
                
            catch ME
                fprintf('Ошибка в tblDataSelectionChanged: %s\n', ME.message);
                fprintf('Стек ошибки:\n');
                for i = 1:length(ME.stack)
                    fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
                end
                
                % Не показывать ошибку пользователю для выделения (не критичная операция)
                % Можно раскомментировать, если нужно показывать ошибки:
                % if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                %     uialert(app.UIFigure, ...
                %         sprintf('Ошибка обработки выделения: %s', ME.message), ...
                %         'Ошибка выделения', ...
                %         'Icon', 'warning');
                % end
            end
        end
        
        % === Редактирование таблицы ===
        %
        % ═══════════════════════════════════════════════════════════════
        % ВАЖНО: ФУНКЦИЯ ДЛЯ ДОБАВЛЕНИЯ В .MLAPP ФАЙЛ
        % ═══════════════════════════════════════════════════════════════
        %
        % Нужно добавить в TableGraphEditor.mlapp следующий метод:
        %
        % 1. tblDataCellEdit  (строки ~460-580)
        %
        % Инструкция по добавлению:
        % ──────────────────────────────────────────────────────────────
        % 1. Откройте TableGraphEditor.mlapp в App Designer
        % 2. Перейдите в Code View
        % 3. Найдите секцию methods (Access = private)
        % 4. Скопируйте функцию tblDataCellEdit (полностью, со всеми комментариями)
        % 5. В Design View выберите компонент tblData
        % 6. В Property Inspector найдите "CellEditCallback"
        % 7. Установите: @app.tblDataCellEdit
        % 8. Сохраните файл
        %
        % ═══════════════════════════════════════════════════════════════
        
        function tblDataCellEdit(app, event)
            % TBLDATACELLEDIT Обработчик редактирования ячейки таблицы
            %   Валидирует данные и обновляет график
            %   Вызывается при редактировании ячейки в таблице
            %
            %   ВАЖНО: Этот callback должен быть назначен в Design View:
            %   1. Выберите компонент tblData в Design View
            %   2. В Property Inspector найдите "CellEditCallback"
            %   3. Установите: @app.tblDataCellEdit
            %   4. Сохраните файл
            %
            %   Примечание: event содержит:
            %   - event.Indices - [row, col] индексы измененной ячейки
            %   - event.NewData - новое значение ячейки
            %   - event.PreviousData - предыдущее значение ячейки
            %
            %   Функция:
            %   - Проверяет, не является ли ячейка меткой (read-only)
            %   - Валидирует числовое значение через validateNumericData
            %   - Обновляет currentData
            %   - Обновляет график через updateGraph
            %   - Использует drawnow limitrate для оптимизации
            
            fprintf('tblDataCellEdit вызван: row=%d, col=%d\n', ...
                event.Indices(1), event.Indices(2));  % Отладочный вывод
            
            try
                % Проверить наличие компонента таблицы
                if ~isprop(app, 'tblData') || ~isvalid(app.tblData)
                    fprintf('⚠ tblData не найден или не валиден\n');
                    return;
                end
                
                % Получить индексы измененной ячейки
                row = event.Indices(1);
                col = event.Indices(2);
                
                % Получить текущий режим построения графика
                plotType = 'columns';
                if isprop(app, 'currentPlotType')
                    try
                        plotType = app.currentPlotType;
                    catch
                        plotType = 'columns';
                    end
                end
                
                % Проверить, не является ли это меткой
                if strcmp(plotType, 'columns')
                    % Режим "по столбцам": первая строка = метки
                    if row == 1
                        % Это метка - запретить редактирование
                        fprintf('⚠ Попытка редактирования метки (row=1) - запрещено\n');
                        if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                            uialert(app.UIFigure, ...
                                'Метки не могут быть отредактированы', ...
                                'Ошибка редактирования', ...
                                'Icon', 'warning');
                        end
                        
                        % Восстановить предыдущее значение
                        % Получить currentData безопасно
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
                        
                        if ~isempty(currentData) && row <= size(currentData, 1) && ...
                           col <= size(currentData, 2)
                            app.tblData.Data{row, col} = currentData(row, col);
                        else
                            % Если не удалось восстановить, использовать PreviousData
                            if ~isempty(event.PreviousData)
                                app.tblData.Data{row, col} = event.PreviousData;
                            end
                        end
                        return;
                    end
                else
                    % Режим "по строкам": первый столбец = метки
                    if col == 1
                        % Это метка - запретить редактирование
                        fprintf('⚠ Попытка редактирования метки (col=1) - запрещено\n');
                        if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                            uialert(app.UIFigure, ...
                                'Метки не могут быть отредактированы', ...
                                'Ошибка редактирования', ...
                                'Icon', 'warning');
                        end
                        
                        % Восстановить предыдущее значение
                        % Получить currentData безопасно
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
                        
                        if ~isempty(currentData) && row <= size(currentData, 1) && ...
                           col <= size(currentData, 2)
                            app.tblData.Data{row, col} = currentData(row, col);
                        else
                            % Если не удалось восстановить, использовать PreviousData
                            if ~isempty(event.PreviousData)
                                app.tblData.Data{row, col} = event.PreviousData;
                            end
                        end
                        return;
                    end
                end
                
                % Получить новое значение
                newValue = event.NewData;
                
                % Валидировать значение через helper функцию
                if exist('validateNumericData', 'file') == 2
                    if ~validateNumericData(newValue)
                        fprintf('⚠ Валидация не пройдена для значения: %s\n', mat2str(newValue));
                        if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                            uialert(app.UIFigure, ...
                                'Значение должно быть числовым', ...
                                'Ошибка валидации', ...
                                'Icon', 'error');
                        end
                        
                        % Восстановить предыдущее значение
                        % Получить currentData безопасно
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
                        
                        if ~isempty(currentData) && row <= size(currentData, 1) && ...
                           col <= size(currentData, 2)
                            app.tblData.Data{row, col} = currentData(row, col);
                        else
                            % Если не удалось восстановить, использовать PreviousData
                            if ~isempty(event.PreviousData)
                                app.tblData.Data{row, col} = event.PreviousData;
                            end
                        end
                        return;
                    end
                else
                    fprintf('⚠ Функция validateNumericData не найдена\n');
                    % Продолжить без валидации, если функция не найдена
                end
                
                % Преобразовать в число, если нужно
                if ischar(newValue) || isstring(newValue)
                    newValue = str2double(newValue);
                    % Проверить результат преобразования
                    if isnan(newValue)
                        fprintf('⚠ Не удалось преобразовать строку в число: %s\n', char(newValue));
                        if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                            uialert(app.UIFigure, ...
                                'Не удалось преобразовать значение в число', ...
                                'Ошибка преобразования', ...
                                'Icon', 'error');
                        end
                        % Восстановить предыдущее значение
                        if ~isempty(event.PreviousData)
                            app.tblData.Data{row, col} = event.PreviousData;
                        end
                        return;
                    end
                end
                
                % Обновить данные в currentData (безопасно)
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
                
                if isempty(currentData)
                    fprintf('⚠ currentData пуст, не удалось обновить данные\n');
                    return;
                end
                
                % Проверить границы
                if row > size(currentData, 1) || col > size(currentData, 2)
                    fprintf('⚠ Индексы выходят за пределы данных (row=%d, col=%d, размер=%s)\n', ...
                        row, col, mat2str(size(currentData)));
                    return;
                end
                
                % Обновить данные
                currentData(row, col) = newValue;
                
                % Сохранить обновленные данные обратно в app (безопасно)
                if isprop(app, 'currentData')
                    try
                        app.currentData = currentData;
                    catch
                        % Если не удалось сохранить в свойство, сохранить в UserData
                        if ~isfield(app.UIFigure.UserData, 'appData')
                            app.UIFigure.UserData.appData = struct();
                        end
                        app.UIFigure.UserData.appData.currentData = currentData;
                    end
                else
                    % Сохранить в UserData, если свойство не существует
                    if ~isfield(app.UIFigure.UserData, 'appData')
                        app.UIFigure.UserData.appData = struct();
                    end
                    app.UIFigure.UserData.appData.currentData = currentData;
                end
                
                fprintf('✓ Данные обновлены: row=%d, col=%d, newValue=%.4f\n', row, col, newValue);
                
                % Обновить график через helper функцию
                if exist('updateGraph', 'file') == 2
                    fprintf('Обновление графика после редактирования таблицы...\n');
                    updateGraph(app);
                    fprintf('✓ График обновлен\n');
                else
                    fprintf('⚠ Функция updateGraph не найдена\n');
                end
                
                % Ограничить частоту обновлений
                drawnow limitrate;
                
            catch ME
                fprintf('Ошибка в tblDataCellEdit: %s\n', ME.message);
                fprintf('Стек ошибки:\n');
                for i = 1:length(ME.stack)
                    fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
                end
                
                % Показать ошибку пользователю
                if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                    uialert(app.UIFigure, ...
                        sprintf('Ошибка редактирования: %s', ME.message), ...
                        'Ошибка редактирования', ...
                        'Icon', 'error');
                end
                
                % Восстановить предыдущее значение
                if ~isempty(event.PreviousData)
                    try
                        app.tblData.Data{event.Indices(1), event.Indices(2)} = event.PreviousData;
                    catch
                        fprintf('⚠ Не удалось восстановить предыдущее значение\n');
                    end
                end
            end
        end
        
        % === Перетаскивание точек на графике ===
        %
        % ═══════════════════════════════════════════════════════════════
        % ВАЖНО: ФУНКЦИИ ДЛЯ ДОБАВЛЕНИЯ В .MLAPP ФАЙЛ
        % ═══════════════════════════════════════════════════════════════
        %
        % Нужно добавить в TableGraphEditor.mlapp следующие методы:
        %
        % 1. axPlotButtonDown  (строки ~459-645)
        %
        % НЕ нужно добавлять в .mlapp (вынесены в отдельные файлы):
        % - dragPoint         → helpers/dragPoint.m (вызывается напрямую)
        % - stopDrag           → helpers/stopDrag.m (вызывается напрямую)
        % - dragPoint → helpers/dragPoint.m (вызывается из WindowButtonMotionFcn)
        % - stopDrag → helpers/stopDrag.m (вызывается из WindowButtonUpFcn)
        % - checkMouseMovement → helpers/checkMouseMovement.m (вызывается таймером)
        %
        % Инструкция по добавлению:
        % ──────────────────────────────────────────────────────────────
        % 1. Откройте TableGraphEditor.mlapp в App Designer
        % 2. Перейдите в Code View
        % 3. Найдите секцию methods (Access = private)
        % 4. Скопируйте ТОЛЬКО функцию axPlotButtonDown (полностью, со всеми комментариями)
        %    dragPoint, stopDrag и checkMouseMovement находятся в helpers/ и вызываются автоматически
        % 5. В Design View выберите компонент axPlot
        % 6. В Property Inspector найдите "ButtonDownFcn"
        % 7. Установите: @app.axPlotButtonDown
        % 8. Сохраните файл
        %
        % Примечание: dragPoint и stopDrag находятся в helpers/ и вызываются автоматически через
        % WindowButtonMotionFcn и WindowButtonUpFcn, которые устанавливаются
        % программно в axPlotButtonDown. НЕ нужно добавлять их в .mlapp файл!
        % checkMouseMovement также находится в helpers/ и вызывается таймером.
        %
        % ═══════════════════════════════════════════════════════════════
        
        function axPlotButtonDown(app, src, event)
            % AXPLOTBUTTONDOWN Обработчик клика на графике
            %   Начинает перетаскивание точки при клике на графике
            %   Вызывает helper функцию findClosestPoint из helpers/
            %
            %   ВАЖНО: Этот callback должен быть назначен в Design View:
            %   1. Выберите компонент axPlot в Design View
            %   2. В Property Inspector найдите "ButtonDownFcn"
            %   3. Установите: @app.axPlotButtonDown
            %   4. Сохраните файл
            %
            %   Примечание: Использует CurrentPoint из axes для получения
            %   точных координат клика в координатах данных.
            %   CurrentPoint более надежен, чем IntersectionPoint, особенно
            %   при клике на маркерах точек.
            
            fprintf('axPlotButtonDown вызван\n');  % Отладочный вывод
            
            try
                % Проверить, что график существует и валиден
                if ~isprop(app, 'axPlot') || ~isvalid(app.axPlot)
                    fprintf('⚠ axPlotButtonDown: axPlot не найден или не валиден\n');
                    return;
                end
                
                % Получить координаты клика в координатах данных
                % ВАЖНО: Используем CurrentPoint вместо IntersectionPoint, так как
                % IntersectionPoint может быть неточным при клике на маркере точки.
                % CurrentPoint всегда возвращает точные координаты мыши в координатах данных.
                cp = app.axPlot.CurrentPoint;
                clickPos = cp(1, 1:2);
                
                % Альтернативно, можно попробовать использовать IntersectionPoint,
                % но только если он доступен и валиден
                % if isprop(event, 'IntersectionPoint') && ~isempty(event.IntersectionPoint)
                %     intersectionPos = event.IntersectionPoint(1:2);
                %     % Проверить, что IntersectionPoint не слишком далеко от CurrentPoint
                %     if norm(intersectionPos - clickPos) < 0.01 * norm(clickPos)
                %         clickPos = intersectionPos;
                %     end
                % end
                
                fprintf('Координаты клика (CurrentPoint): [%.4f, %.4f]\n', clickPos(1), clickPos(2));
                
                % Найти ближайшую точку через helper функцию
                if exist('findClosestPoint', 'file') == 2
                    pointIndex = findClosestPoint(app, clickPos);
                else
                    fprintf('⚠ Функция findClosestPoint не найдена\n');
                    return;
                end
                
                if isempty(pointIndex)
                    fprintf('⚠ Точка не найдена (клик слишком далеко от точек)\n');
                    return;
                end
                
                fprintf('✓ Найдена точка: кривая %d, точка %d\n', pointIndex(1), pointIndex(2));
                
                % Получить исходные координаты точки для применения ограничений режима редактирования
                % ВАЖНО: Эти координаты должны сохраняться один раз при начале перетаскивания
                % и использоваться для сохранения координаты, которая не должна изменяться
                % (в режиме X - сохраняется Y, в режиме Y - сохраняется X)
                originalCoords = [];
                if exist('getPointCoordinates', 'file') == 2
                    originalCoords = getPointCoordinates(app, pointIndex);
                    
                    % Проверить валидность полученных координат
                    if isempty(originalCoords) || length(originalCoords) < 2 || ...
                       ~isfinite(originalCoords(1)) || ~isfinite(originalCoords(2))
                        fprintf('⚠ getPointCoordinates вернула невалидные координаты, используются координаты клика\n');
                        originalCoords = clickPos;
                    end
                    
                    fprintf('Исходные координаты точки (из данных): [%.4f, %.4f]\n', ...
                        originalCoords(1), originalCoords(2));
                else
                    % Если функция не найдена, использовать координаты клика
                    fprintf('⚠ getPointCoordinates не найдена, используются координаты клика\n');
                    originalCoords = clickPos;
                end
                
                % Проверить валидность перед сохранением
                if isempty(originalCoords) || length(originalCoords) < 2 || ...
                   ~isfinite(originalCoords(1)) || ~isfinite(originalCoords(2))
                    fprintf('⚠ Исходные координаты не валидны, пропуск сохранения\n');
                else
                    % Сохранить исходные координаты для применения ограничений
                    % Эти координаты будут использоваться для сохранения фиксированной координаты
                    if isprop(app, 'dragStartCoordinates')
                        try
                            app.dragStartCoordinates = originalCoords;
                            fprintf('✓ Исходные координаты сохранены в dragStartCoordinates\n');
                        catch
                            if ~isfield(app.UIFigure.UserData, 'appData')
                                app.UIFigure.UserData.appData = struct();
                            end
                            app.UIFigure.UserData.appData.dragStartCoordinates = originalCoords;
                            fprintf('✓ Исходные координаты сохранены в UserData.appData.dragStartCoordinates\n');
                        end
                    else
                        if ~isfield(app.UIFigure.UserData, 'appData')
                            app.UIFigure.UserData.appData = struct();
                        end
                        app.UIFigure.UserData.appData.dragStartCoordinates = originalCoords;
                        fprintf('✓ Исходные координаты сохранены в UserData.appData.dragStartCoordinates (свойство не существует)\n');
                    end
                end
                
                % Сохранить индекс точки и начать перетаскивание (безопасно)
                if isprop(app, 'selectedPoint')
                    try
                        app.selectedPoint = pointIndex;
                    catch
                        if ~isfield(app.UIFigure.UserData, 'appData')
                            app.UIFigure.UserData.appData = struct();
                        end
                        app.UIFigure.UserData.appData.selectedPoint = pointIndex;
                    end
                else
                    if ~isfield(app.UIFigure.UserData, 'appData')
                        app.UIFigure.UserData.appData = struct();
                    end
                    app.UIFigure.UserData.appData.selectedPoint = pointIndex;
                end
                
                if isprop(app, 'isDragging')
                    try
                        app.isDragging = true;
                    catch
                        if ~isfield(app.UIFigure.UserData, 'appData')
                            app.UIFigure.UserData.appData = struct();
                        end
                        app.UIFigure.UserData.appData.isDragging = true;
                    end
                else
                    if ~isfield(app.UIFigure.UserData, 'appData')
                        app.UIFigure.UserData.appData = struct();
                    end
                    app.UIFigure.UserData.appData.isDragging = true;
                end
                
                if isprop(app, 'dragStartPosition')
                    try
                        app.dragStartPosition = clickPos;
                    catch
                        if ~isfield(app.UIFigure.UserData, 'appData')
                            app.UIFigure.UserData.appData = struct();
                        end
                        app.UIFigure.UserData.appData.dragStartPosition = clickPos;
                    end
                else
                    if ~isfield(app.UIFigure.UserData, 'appData')
                        app.UIFigure.UserData.appData = struct();
                    end
                    app.UIFigure.UserData.appData.dragStartPosition = clickPos;
                end
                
                % Установить callbacks для движения мыши
                % ВАЖНО: В MATLAB App Designer WindowButtonMotionFcn может не работать
                % надежно. Используем комбинированный подход:
                % 1. WindowButtonMotionFcn (если работает)
                % 2. Таймер для периодической проверки движения мыши (fallback)
                
                % Сохранить ссылку на app в UserData для доступа из callbacks
                app.UIFigure.UserData.dragApp = app;
                
                % Установить WindowButtonMotionFcn (основной механизм)
                % Используем прямые вызовы функций из helpers/
                app.UIFigure.WindowButtonMotionFcn = @(src,evt) dragPoint(app, src, evt);
                app.UIFigure.WindowButtonUpFcn = @(src,evt) stopDrag(app, src, evt);
                
                % Создать таймер для отслеживания движения мыши (fallback механизм)
                % Таймер будет проверять позицию мыши каждые 0.05 секунды
                if isprop(app, 'dragTimer')
                    try
                        if isvalid(app.dragTimer)
                            stop(app.dragTimer);
                            delete(app.dragTimer);
                        end
                    catch
                    end
                end
                
                % Создать новый таймер
                % ВАЖНО: Сохраняем app в UserData таймера для доступа из callback
                dragTimer = timer(...
                    'ExecutionMode', 'fixedRate', ...
                    'Period', 0.05, ...  % Проверка каждые 50 мс
                    'TimerFcn', @(t,~) checkMouseMovement(app, t), ...
                    'BusyMode', 'drop', ...
                    'TasksToExecute', Inf);
                
                % Сохранить app в UserData таймера для доступа из callback
                dragTimer.UserData.dragApp = app;
                
                % Сохранить таймер в app
                if isprop(app, 'dragTimer')
                    try
                        app.dragTimer = dragTimer;
                    catch
                        app.UIFigure.UserData.dragTimer = dragTimer;
                    end
                else
                    app.UIFigure.UserData.dragTimer = dragTimer;
                end
                
                % Сохранить предыдущую позицию мыши для отслеживания движения
                % В MacOS координаты могут работать по-другому, учитываем это
                currentMousePos = get(0, 'PointerLocation');
                if isprop(app, 'lastMousePosition')
                    try
                        app.lastMousePosition = currentMousePos;
                    catch
                        app.UIFigure.UserData.lastMousePosition = currentMousePos;
                    end
                else
                    app.UIFigure.UserData.lastMousePosition = currentMousePos;
                end
                
                % В MacOS также сохраняем начальные координаты данных
                if ismac && isprop(app, 'axPlot') && isvalid(app.axPlot)
                    try
                        cp = app.axPlot.CurrentPoint;
                        initialDataPos = cp(1, 1:2);
                        app.UIFigure.UserData.lastDataPosition = initialDataPos;
                        fprintf('✓ Начальные координаты данных для MacOS: [%.4f, %.4f]\n', ...
                            initialDataPos(1), initialDataPos(2));
                    catch
                        % Игнорировать ошибки
                    end
                end
                
                % Запустить таймер
                start(dragTimer);
                
                % Проверить, что таймер действительно запущен
                if strcmp(get(dragTimer, 'Running'), 'on')
                    fprintf('✓ Таймер запущен успешно (Running=on)\n');
                else
                    fprintf('⚠ Таймер НЕ запущен! (Running=%s)\n', get(dragTimer, 'Running'));
                end
                
                fprintf('✓ Callbacks установлены + таймер запущен (fallback механизм)\n');
                
                fprintf('✓ Callbacks установлены\n');
                
                % Проверить, что callbacks установлены
                if ~isempty(app.UIFigure.WindowButtonMotionFcn)
                    fprintf('✓ WindowButtonMotionFcn установлен\n');
                else
                    fprintf('⚠ WindowButtonMotionFcn НЕ установлен!\n');
                end
                if ~isempty(app.UIFigure.WindowButtonUpFcn)
                    fprintf('✓ WindowButtonUpFcn установлен\n');
                else
                    fprintf('⚠ WindowButtonUpFcn НЕ установлен!\n');
                end
                
                % Добавить флаг, что перетаскивание действительно началось
                % (для проверки, что мышь двигалась)
                if isprop(app, 'dragStartPosition')
                    try
                        app.dragStartPosition = clickPos;
                    catch
                        if ~isfield(app.UIFigure.UserData, 'appData')
                            app.UIFigure.UserData.appData = struct();
                        end
                        app.UIFigure.UserData.appData.dragStartPosition = clickPos;
                    end
                else
                    if ~isfield(app.UIFigure.UserData, 'appData')
                        app.UIFigure.UserData.appData = struct();
                    end
                    app.UIFigure.UserData.appData.dragStartPosition = clickPos;
                end
                
                % Флаг, что мышь двигалась (для отличия клика от перетаскивания)
                if isprop(app, 'hasMoved')
                    try
                        app.hasMoved = false;
                    catch
                        if ~isfield(app.UIFigure.UserData, 'appData')
                            app.UIFigure.UserData.appData = struct();
                        end
                        app.UIFigure.UserData.appData.hasMoved = false;
                    end
                else
                    if ~isfield(app.UIFigure.UserData, 'appData')
                        app.UIFigure.UserData.appData = struct();
                    end
                    app.UIFigure.UserData.appData.hasMoved = false;
                end
                
                fprintf('✓ Перетаскивание начато (callbacks установлены)\n');
                
            catch ME
                fprintf('Ошибка в axPlotButtonDown: %s\n', ME.message);
                fprintf('Стек ошибки:\n');
                for i = 1:length(ME.stack)
                    fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
                end
                
                if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                    uialert(app.UIFigure, ...
                        sprintf('Ошибка начала перетаскивания: %s', ME.message), ...
                        'Ошибка перетаскивания', ...
                        'Icon', 'error');
                end
            end
        end
        
        % ПРИМЕЧАНИЕ: dragPoint, stopDrag и checkMouseMovement вынесены в отдельные файлы:
        % - helpers/dragPoint.m
        % - helpers/stopDrag.m
        % - helpers/checkMouseMovement.m
        %
        % Эти функции вызываются напрямую из callbacks в axPlotButtonDown
        % НЕ нужно добавлять методы dragPoint, stopDrag, checkMouseMovement в .mlapp файл!
        
        % === Валидация ===
        % Используйте helper функцию validateData напрямую:
        %   isValid = validateData(app, data);
        
        % === Режимы редактирования ===
        %
        % ═══════════════════════════════════════════════════════════════
        % ВАЖНО: ФУНКЦИЯ ДЛЯ ДОБАВЛЕНИЯ В .MLAPP ФАЙЛ
        % ═══════════════════════════════════════════════════════════════
        %
        % Нужно добавить в TableGraphEditor.mlapp следующий метод:
        %
        % 1. bgEditModeSelectionChanged  (ниже)
        %
        % Инструкция по добавлению:
        % ──────────────────────────────────────────────────────────────
        % 1. Откройте TableGraphEditor.mlapp в App Designer
        % 2. Перейдите в Code View
        % 3. Найдите секцию methods (Access = private)
        % 4. Скопируйте функцию bgEditModeSelectionChanged
        % 5. В Design View настройте callback для группы bgEditMode:
        %    - Выберите bgEditMode (uibuttongroup) → Property Inspector
        %    - Найдите "SelectionChangedFcn"
        %    - Установите: @app.bgEditModeSelectionChanged
        % 6. Сохраните файл
        %
        % ПРИМЕЧАНИЕ: Radio buttons (rbModeX, rbModeY, rbModeXY) находятся внутри
        % группы bgEditMode. Callback должен быть назначен только для группы,
        % а не для отдельных radio buttons!
        %
        % ═══════════════════════════════════════════════════════════════
        
        function bgEditModeSelectionChanged(app, event)
            % BGEDITMODESELECTIONCHANGED Обработчик изменения режима редактирования
            %   Вызывается при выборе нового режима редактирования в группе bgEditMode
            %   Обновляет свойство app.editMode на основе выбранного radio button
            %
            %   ВАЖНО: Этот callback должен быть назначен в Design View для группы bgEditMode:
            %   1. Выберите bgEditMode (uibuttongroup) в Design View
            %   2. В Property Inspector найдите "SelectionChangedFcn"
            %   3. Установите: @app.bgEditModeSelectionChanged
            %   4. Сохраните файл
            %
            %   Radio buttons (rbModeX, rbModeY, rbModeXY) должны быть внутри группы bgEditMode.
            %   Callback НЕ нужно назначать для отдельных radio buttons!
            
            fprintf('bgEditModeSelectionChanged вызван\n');  % Отладочный вывод
            
            try
                % Проверить, что группа bgEditMode существует
                if ~isprop(app, 'bgEditMode') || ~isvalid(app.bgEditMode)
                    fprintf('⚠ bgEditMode не найден или не валиден\n');
                    return;
                end
                
                % Получить выбранный radio button из группы
                % В MATLAB App Designer uibuttongroup имеет свойство SelectedObject,
                % которое содержит ссылку на выбранный radio button
                selectedButton = app.bgEditMode.SelectedObject;
                
                if isempty(selectedButton)
                    fprintf('⚠ Выбранный radio button не найден\n');
                    return;
                end
                
                % Определить режим редактирования на основе выбранного radio button
                newMode = 'XY';  % По умолчанию
                
                % Сравнить выбранный radio button с известными radio buttons
                if isprop(app, 'rbModeX') && isvalid(app.rbModeX) && selectedButton == app.rbModeX
                    newMode = 'X';
                elseif isprop(app, 'rbModeY') && isvalid(app.rbModeY) && selectedButton == app.rbModeY
                    newMode = 'Y';
                elseif isprop(app, 'rbModeXY') && isvalid(app.rbModeXY) && selectedButton == app.rbModeXY
                    newMode = 'XY';
                else
                    % Fallback: попробовать определить по имени компонента
                    try
                        buttonName = selectedButton.Tag;
                        if contains(buttonName, 'rbModeX', 'IgnoreCase', true)
                            newMode = 'X';
                        elseif contains(buttonName, 'rbModeY', 'IgnoreCase', true)
                            newMode = 'Y';
                        elseif contains(buttonName, 'rbModeXY', 'IgnoreCase', true)
                            newMode = 'XY';
                        end
                    catch
                        fprintf('⚠ Не удалось определить режим по имени компонента\n');
                    end
                end
                
                fprintf('Выбран режим редактирования: %s\n', newMode);
                
                % Сохранить режим в app.editMode (безопасно)
                if isprop(app, 'editMode')
                    try
                        app.editMode = newMode;
                        fprintf('✓ editMode установлен: %s\n', newMode);
                    catch
                        % Сохранить в UserData, если не удалось установить свойство
                        if ~isfield(app.UIFigure.UserData, 'appData')
                            app.UIFigure.UserData.appData = struct();
                        end
                        app.UIFigure.UserData.appData.editMode = newMode;
                        fprintf('editMode сохранен в UserData: %s\n', newMode);
                    end
                else
                    % Сохранить в UserData, если свойство не существует
                    if ~isfield(app.UIFigure.UserData, 'appData')
                        app.UIFigure.UserData.appData = struct();
                    end
                    app.UIFigure.UserData.appData.editMode = newMode;
                    fprintf('editMode сохранен в UserData (свойство не существует): %s\n', newMode);
                end
                
            catch ME
                fprintf('Ошибка в bgEditModeSelectionChanged: %s\n', ME.message);
                fprintf('Стек ошибки:\n');
                for i = 1:length(ME.stack)
                    fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
                end
                
                if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
                    uialert(app.UIFigure, ...
                        sprintf('Ошибка изменения режима редактирования: %s', ME.message), ...
                        'Ошибка', ...
                        'Icon', 'error');
                end
            end
        end


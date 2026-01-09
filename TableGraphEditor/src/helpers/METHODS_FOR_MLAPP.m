%% METHODS_FOR_MLAPP Методы для добавления в .mlapp файл
%   Эти методы вызывают helper функции из папки helpers/
%   Скопируйте эти методы в секцию methods (Access = private) в Code View
%
%   Добавьте после функции createComponents или в любом месте в methods (Access = private)
%
%   Дата обновления: 2026-01-08

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
                
                % Назначить callback программно (если не назначен)
                % Сначала проверяем, что метод существует
                if ismethod(app, 'ddVariableValueChanged')
                    if isempty(app.ddVariable.ValueChangedFcn)
                        fprintf('Назначение callback ddVariableValueChanged программно...\n');
                        app.ddVariable.ValueChangedFcn = @app.ddVariableValueChanged;
                        fprintf('✓ Callback назначен\n');
                    else
                        fprintf('✓ Callback уже назначен\n');
                    end
                else
                    fprintf('⚠ Метод ddVariableValueChanged не найден!\n');
                    fprintf('  Необходимо добавить метод в .mlapp файл\n');
                    fprintf('  Скопируйте метод из METHODS_FOR_MLAPP.m\n');
                end
                
                % Обновить список переменных
                updateVariableDropdown(app);
                
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
        
        % === Валидация ===
        % Используйте helper функцию validateData напрямую:
        %   isValid = validateData(app, data);


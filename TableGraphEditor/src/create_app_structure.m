%% CREATE_APP_STRUCTURE Создает базовую структуру App Designer приложения
%   Этот скрипт помогает автоматизировать создание базовой структуры
%   для TableGraphEditor.mlapp
%
%   Использование:
%       create_app_structure
%
%   Примечание: Файл .mlapp должен быть создан вручную в App Designer,
%   но этот скрипт создаст вспомогательные файлы и структуру.

function create_app_structure()
    % CREATE_APP_STRUCTURE Создает базовую структуру приложения
    
    fprintf('=== Создание структуры TableGraphEditor ===\n\n');
    
    % Получить путь к папке src
    scriptPath = fileparts(mfilename('fullpath'));
    srcPath = scriptPath;
    mlappPath = fullfile(srcPath, 'TableGraphEditor.mlapp');
    
    %% Проверка существования .mlapp файла
    if exist(mlappPath, 'file') == 2
        fprintf('✓ TableGraphEditor.mlapp уже существует\n');
        fprintf('  Расположение: %s\n\n', mlappPath);
        
        % Предложить открыть в App Designer
        response = input('Открыть файл в App Designer? (y/n): ', 's');
        if strcmpi(response, 'y') || strcmpi(response, 'yes')
            try
                appdesigner(mlappPath);
                fprintf('Файл открыт в App Designer\n');
            catch ME
                fprintf('Ошибка при открытии: %s\n', ME.message);
                fprintf('Попробуйте открыть вручную: appdesigner(''%s'')\n', mlappPath);
            end
        end
    else
        fprintf('⚠ TableGraphEditor.mlapp не найден\n');
        fprintf('  Расположение: %s\n\n', mlappPath);
        
        %% Создание через App Designer API (если доступно)
        fprintf('Попытка создать файл через App Designer API...\n');
        
        try
            % Попытка использовать внутренний API MATLAB
            % Примечание: Это может не работать, так как .mlapp требует GUI
            
            % Альтернатива: создать базовый .m файл класса
            createBaseClass(srcPath);
            
            fprintf('\n✓ Создан базовый класс приложения\n');
            fprintf('  Файл: TableGraphEditorBase.m\n');
            fprintf('  Вы можете использовать его как основу для .mlapp\n\n');
            
        catch ME
            fprintf('⚠ Не удалось создать автоматически: %s\n', ME.message);
            fprintf('\nРекомендуется:\n');
            fprintf('1. Откройте MATLAB App Designer: appdesigner\n');
            fprintf('2. Создайте новый Blank App\n');
            fprintf('3. Сохраните как: %s\n', mlappPath);
            fprintf('4. Следуйте инструкциям в SETUP_INSTRUCTIONS.md\n\n');
        end
    end
    
    %% Создание вспомогательных файлов
    fprintf('Создание вспомогательных файлов...\n');
    
    % Создать файл с константами
    createConstantsFile(srcPath);
    fprintf('  ✓ constants.m\n');
    
    % Создать файл с утилитами
    createUtilitiesFile(srcPath);
    fprintf('  ✓ utilities.m\n');
    
    fprintf('\n=== Готово ===\n');
    fprintf('Следующие шаги:\n');
    fprintf('1. Создайте TableGraphEditor.mlapp в App Designer\n');
    fprintf('2. Используйте APP_STRUCTURE_TEMPLATE.md как справочник\n');
    fprintf('3. Следуйте SETUP_INSTRUCTIONS.md для детальных инструкций\n');
end

%% Вспомогательные функции

function createBaseClass(srcPath)
    % CREATEBASECLASS Создает базовый класс приложения
    
    baseClassPath = fullfile(srcPath, 'TableGraphEditorBase.m');
    
    if exist(baseClassPath, 'file') == 2
        fprintf('  TableGraphEditorBase.m уже существует, пропускаем...\n');
        return;
    end
    
    % Создать базовый класс
    fid = fopen(baseClassPath, 'w');
    if fid == -1
        error('Не удалось создать файл TableGraphEditorBase.m');
    end
    
    fprintf(fid, '%% TableGraphEditorBase - Базовый класс приложения\n');
    fprintf(fid, '%%   Этот файл служит шаблоном для создания .mlapp файла\n');
    fprintf(fid, '%%   Используйте его как справочник при создании App Designer приложения\n\n');
    fprintf(fid, 'classdef TableGraphEditorBase < handle\n');
    fprintf(fid, '    %% TABLEGRAPHEDITORBASE Базовый класс Table-Graph Editor\n\n');
    fprintf(fid, '    properties (Access = private)\n');
    fprintf(fid, '        %% Данные\n');
    fprintf(fid, '        originalData        %% Исходные данные (полная матрица)\n');
    fprintf(fid, '        currentData         %% Текущие редактируемые данные\n');
    fprintf(fid, '        selectedVariable    %% Выбранная переменная из workspace\n');
    fprintf(fid, '        editMode = ''XY''     %% Режим редактирования: ''XY''\n');
    fprintf(fid, '        currentPlotType = ''columns'' %% ''columns'' или ''rows''\n');
    fprintf(fid, '        \n');
    fprintf(fid, '        %% Для выбора части данных\n');
    fprintf(fid, '        selectedColumns = [] %% Индексы выбранных столбцов\n');
    fprintf(fid, '        selectedRows = []    %% Индексы выбранных строк\n');
    fprintf(fid, '        \n');
    fprintf(fid, '        %% Метки\n');
    fprintf(fid, '        rowLabels = {}      %% Метки строк\n');
    fprintf(fid, '        columnLabels = {}   %% Метки столбцов\n');
    fprintf(fid, '        \n');
    fprintf(fid, '        %% Для перетаскивания\n');
    fprintf(fid, '        selectedPoint = []  %% Индекс выбранной точки\n');
    fprintf(fid, '        isDragging = false  %% Флаг перетаскивания\n');
    fprintf(fid, '        dragStartPosition = [] %% Начальная позиция\n');
    fprintf(fid, '        \n');
    fprintf(fid, '        %% Состояние приложения\n');
    fprintf(fid, '        isUpdating = false  %% Флаг обновления\n');
    fprintf(fid, '    end\n\n');
    fprintf(fid, '    methods\n');
    fprintf(fid, '        function obj = TableGraphEditorBase()\n');
    fprintf(fid, '            %% Конструктор\n');
    fprintf(fid, '            fprintf(''TableGraphEditorBase создан\\n'');\n');
    fprintf(fid, '        end\n');
    fprintf(fid, '    end\n');
    fprintf(fid, 'end\n');
    
    fclose(fid);
end

function createConstantsFile(srcPath)
    % CREATECONSTANTSFILE Создает файл с константами
    
    constantsPath = fullfile(srcPath, 'helpers', 'constants.m');
    
    if exist(constantsPath, 'file') == 2
        return;
    end
    
    fid = fopen(constantsPath, 'w');
    if fid == -1
        return;
    end
    
    fprintf(fid, '%% CONSTANTS Константы приложения\n');
    fprintf(fid, '%%   Определяет константы, используемые в приложении\n\n');
    fprintf(fid, 'classdef constants\n');
    fprintf(fid, '    %% CONSTANTS Константы TableGraphEditor\n\n');
    fprintf(fid, '    properties (Constant)\n');
    fprintf(fid, '        %% Режимы редактирования\n');
    fprintf(fid, '        EDIT_MODE_XY = ''XY''\n');
    fprintf(fid, '        EDIT_MODE_X = ''X''\n');
    fprintf(fid, '        EDIT_MODE_Y = ''Y''\n');
    fprintf(fid, '        \n');
    fprintf(fid, '        %% Типы графиков\n');
    fprintf(fid, '        PLOT_TYPE_COLUMNS = ''columns''\n');
    fprintf(fid, '        PLOT_TYPE_ROWS = ''rows''\n');
    fprintf(fid, '        \n');
    fprintf(fid, '        %% Размеры по умолчанию\n');
    fprintf(fid, '        DEFAULT_WINDOW_WIDTH = 1200\n');
    fprintf(fid, '        DEFAULT_WINDOW_HEIGHT = 800\n');
    fprintf(fid, '    end\n');
    fprintf(fid, 'end\n');
    
    fclose(fid);
end

function createUtilitiesFile(srcPath)
    % CREATEUTILITIESFILE Создает файл с утилитами
    
    utilitiesPath = fullfile(srcPath, 'helpers', 'utilities.m');
    
    if exist(utilitiesPath, 'file') == 2
        return;
    end
    
    fid = fopen(utilitiesPath, 'w');
    if fid == -1
        return;
    end
    
    fprintf(fid, '%% UTILITIES Вспомогательные функции\n');
    fprintf(fid, '%%   Содержит вспомогательные функции для приложения\n\n');
    fprintf(fid, 'classdef utilities\n');
    fprintf(fid, '    %% UTILITIES Вспомогательные функции\n\n');
    fprintf(fid, '    methods (Static)\n');
    fprintf(fid, '        function result = validateNumericData(data)\n');
    fprintf(fid, '            %% VALIDATENUMERICDATA Проверяет, что данные числовые\n');
    fprintf(fid, '            result = isnumeric(data) && ~isempty(data);\n');
    fprintf(fid, '        end\n');
    fprintf(fid, '    end\n');
    fprintf(fid, 'end\n');
    
    fclose(fid);
end


%% DIAGNOSE_DROPDOWN Диагностика dropdown компонента
%   Помогает найти проблему с компонентом ddVariable
%
%   Использование:
%       diagnose_dropdown(app)

function diagnose_dropdown(app)
    % DIAGNOSE_DROPDOWN Диагностика dropdown
    
    fprintf('=== Диагностика dropdown компонента ===\n\n');
    
    % 1. Проверить доступные свойства
    fprintf('1. Доступные свойства app:\n');
    props = properties(app);
    fprintf('   Всего свойств: %d\n', length(props));
    
    % Найти свойства, связанные с dropdown
    dropdownProps = props(contains(props, 'Variable', 'IgnoreCase', true) | ...
                         contains(props, 'dd', 'IgnoreCase', true) | ...
                         contains(props, 'Dropdown', 'IgnoreCase', true));
    
    if ~isempty(dropdownProps)
        fprintf('   Найдены похожие свойства:\n');
        for i = 1:length(dropdownProps)
            fprintf('     - %s\n', dropdownProps{i});
            try
                if isprop(app, dropdownProps{i})
                    val = app.(dropdownProps{i});
                    if isvalid(val)
                        fprintf('       ✓ Валиден, тип: %s\n', class(val));
                        if isprop(val, 'Items')
                            fprintf('       Items: %d элементов\n', length(val.Items));
                        end
                    else
                        fprintf('       ✗ Не валиден\n');
                    end
                end
            catch ME
                fprintf('       ✗ Ошибка доступа: %s\n', ME.message);
            end
        end
    else
        fprintf('   ✗ Похожие свойства не найдены\n');
    end
    fprintf('\n');
    
    % 2. Проверить через метаданные класса
    fprintf('2. Проверка через метаданные класса:\n');
    try
        mc = metaclass(app);
        propList = mc.PropertyList;
        for i = 1:length(propList)
            if contains(propList(i).Name, 'Variable', 'IgnoreCase', true) || ...
               contains(propList(i).Name, 'dd', 'IgnoreCase', true)
                fprintf('   - %s (Access=%s)\n', ...
                    propList(i).Name, char(propList(i).SetAccess));
            end
        end
    catch ME
        fprintf('   Ошибка: %s\n', ME.message);
    end
    fprintf('\n');
    
    % 3. Проверить через isprop и isfield
    fprintf('3. Проверка существования:\n');
    fprintf('   isprop(app, ''ddVariable''): %d\n', isprop(app, 'ddVariable'));
    fprintf('   isfield(app, ''ddVariable''): %d\n', isfield(app, 'ddVariable'));
    fprintf('\n');
    
    % 4. Попытка доступа к компоненту
    fprintf('4. Попытка прямого доступа:\n');
    try
        if isprop(app, 'ddVariable')
            dd = app.ddVariable;
            fprintf('   ✓ ddVariable доступен\n');
            fprintf('   Тип: %s\n', class(dd));
            fprintf('   Валиден: %d\n', isvalid(dd));
            if isvalid(dd)
                fprintf('   Items: %d элементов\n', length(dd.Items));
                if ~isempty(dd.Items)
                    fprintf('   Первый элемент: %s\n', dd.Items{1});
                end
            end
        else
            fprintf('   ✗ ddVariable не найден через isprop\n');
        end
    catch ME
        fprintf('   ✗ Ошибка доступа: %s\n', ME.message);
    end
    fprintf('\n');
    
    % 5. Рекомендации
    fprintf('=== Рекомендации ===\n');
    if ~isprop(app, 'ddVariable')
        fprintf('1. Откройте App Designer в Design View\n');
        fprintf('2. Убедитесь, что компонент uidropdown создан\n');
        fprintf('3. Проверьте, что Name компонента = "ddVariable"\n');
        fprintf('4. Сохраните файл и перезапустите приложение\n');
    else
        fprintf('✓ Компонент найден! Проблема может быть в инициализации\n');
    end
    fprintf('\n');
end


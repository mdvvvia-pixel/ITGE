%% CHECK_PROPERTIES_ACCESS Проверяет доступ к свойствам для записи
%   Показывает, какие свойства могут быть установлены, а какие нет
%
%   Использование:
%       check_properties_access(app)

function check_properties_access(app)
    % CHECK_PROPERTIES_ACCESS Проверяет доступ к свойствам
    
    fprintf('=== Проверка доступа к Properties ===\n\n');
    
    propertiesToCheck = {
        'isUpdating';
        'currentData';
        'originalData';
        'currentPlotType';
        'editMode';
        'selectedVariable';
        'selectedColumns';
        'selectedRows';
        'rowLabels';
        'columnLabels';
        'selectedPoint';
        'isDragging';
        'dragStartPosition'
    };
    
    mc = metaclass(app);
    
    fprintf('Проверка доступа к свойствам:\n');
    fprintf('--------------------------------\n');
    
    for i = 1:length(propertiesToCheck)
        propName = propertiesToCheck{i};
        prop = findobj(mc.PropertyList, 'Name', propName);
        
        if isempty(prop)
            fprintf('✗ %s - СВОЙСТВО НЕ НАЙДЕНО\n', propName);
        else
            setAccess = char(prop.SetAccess);
            getAccess = char(prop.GetAccess);
            isConstant = prop.Constant;
            isDependent = prop.Dependent;
            
            canSet = ~isConstant && ~isDependent && ~strcmp(setAccess, 'none') && ~strcmp(setAccess, 'immutable');
            
            if canSet
                fprintf('✓ %s - МОЖЕТ БЫТЬ УСТАНОВЛЕНО\n', propName);
                fprintf('    SetAccess: %s, Constant: %d, Dependent: %d\n', setAccess, isConstant, isDependent);
            else
                fprintf('✗ %s - НЕ МОЖЕТ БЫТЬ УСТАНОВЛЕНО\n', propName);
                fprintf('    SetAccess: %s, Constant: %d, Dependent: %d\n', setAccess, isConstant, isDependent);
                fprintf('    ⚠ ПРОБЛЕМА: Свойство read-only или вычисляемое!\n');
            end
        end
    end
    
    fprintf('\n=== Рекомендации ===\n');
    fprintf('Если свойства не могут быть установлены:\n');
    fprintf('1. Проверьте объявление в .mlapp - не должно быть SetAccess = private\n');
    fprintf('2. Убедитесь, что свойства не Constant и не Dependent\n');
    fprintf('3. Используйте UserData как временное решение\n');
end


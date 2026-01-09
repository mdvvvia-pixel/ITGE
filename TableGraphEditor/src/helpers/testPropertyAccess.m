%% TESTPROPERTYACCESS Тестирует установку свойств
%   Проверяет, можно ли установить свойства напрямую
%
%   Использование:
%       testPropertyAccess()

function testPropertyAccess()
    % TESTPROPERTYACCESS Тестирует установку свойств
    
    fprintf('=== Тест установки Properties ===\n\n');
    
    try
        app = TableGraphEditor;
        fprintf('✓ Приложение создано\n\n');
        
        % Тест установки каждого свойства
        testProps = {
            'isUpdating', false;
            'currentData', rand(5, 3);
            'originalData', rand(5, 3);
            'currentPlotType', 'columns';
            'editMode', 'XY';
            'selectedVariable', 'testVar';
            'selectedColumns', [1 2];
            'selectedRows', [1 2];
            'rowLabels', {'Row1', 'Row2'};
            'columnLabels', {'Col1', 'Col2'};
            'selectedPoint', [1 1];
            'isDragging', false;
            'dragStartPosition', [0 0]
        };
        
        fprintf('Попытка установки свойств:\n');
        fprintf('---------------------------\n');
        
        successCount = 0;
        failCount = 0;
        
        for i = 1:size(testProps, 1)
            propName = testProps{i, 1};
            propValue = testProps{i, 2};
            
            try
                app.(propName) = propValue;
                fprintf('✓ %s = установлено успешно\n', propName);
                successCount = successCount + 1;
            catch ME
                fprintf('✗ %s = ОШИБКА: %s\n', propName, ME.message);
                failCount = failCount + 1;
            end
        end
        
        fprintf('\n=== Итоги ===\n');
        fprintf('Успешно: %d из %d\n', successCount, size(testProps, 1));
        fprintf('Ошибок: %d\n\n', failCount);
        
        if failCount == 0
            fprintf('✓ Все свойства могут быть установлены!\n');
        else
            fprintf('⚠ Некоторые свойства не могут быть установлены\n');
            fprintf('Возможные причины:\n');
            fprintf('1. Свойства объявлены с ограничениями SetAccess\n');
            fprintf('2. Объект еще не полностью инициализирован\n');
            fprintf('3. Свойства объявлены как Constant или Dependent\n');
        end
        
    catch ME
        fprintf('✗ Ошибка при создании приложения: %s\n', ME.message);
    end
end


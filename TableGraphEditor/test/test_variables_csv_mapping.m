%% TEST_VARIABLES_CSV_MAPPING Тест маппинга по Variables.csv
%   Проверяет:
%   - файл Variables.csv найден в TableGraphEditor/resources
%   - точное совпадение ключа возвращает первую подходящую строку
%   - пустой 3-й столбец корректно возвращается как ''

function test_variables_csv_mapping()
    % Путь до helper
    assert(exist('findVariablesCsvMapping', 'file') == 2, ...
        'findVariablesCsvMapping не найден в path.');
    
    % 1) Базовый кейс: есть 3 колонки
    [isFound1, a1, b1, csvPath1] = findVariablesCsvMapping('bank_cruise.Cya_bank');
    assert(isFound1 == true, 'Ожидали найти bank_cruise.Cya_bank в Variables.csv');
    assert(strcmp(a1, 'bank_cruise.al_bank'), 'Неверное значение A для bank_cruise.Cya_bank');
    assert(strcmp(b1, 'bank_cruise.M_bank'), 'Неверное значение B для bank_cruise.Cya_bank');
    assert(exist(csvPath1, 'file') == 2, 'csvPath не существует: %s', csvPath1);
    
    % 2) Кейс с пустым B (3-й столбец пустой)
    [isFound2, a2, b2] = findVariablesCsvMapping('bank_cruise.Cya_fi_bank');
    assert(isFound2 == true, 'Ожидали найти bank_cruise.Cya_fi_bank в Variables.csv');
    assert(strcmp(a2, 'bank_cruise.M_bank'), 'Неверное значение A для bank_cruise.Cya_fi_bank');
    assert(ischar(b2) && isempty(b2), 'Ожидали пустой B для bank_cruise.Cya_fi_bank');
    
    disp('test_variables_csv_mapping: OK');
end


%% TEST_GETALLNUMERICVARIABLES_INCLUDES_VECTORS
%   Проверяет, что getAllNumericVariables включает в список векторы (1xK/Kx1, K>1).

function test_getAllNumericVariables_includes_vectors()
    assert(exist('getAllNumericVariables', 'file') == 2, ...
        'getAllNumericVariables не найден в path.');
    
    % Подготовить данные в base workspace
    evalin('base', 'itge_test_vec_row = 1:5;');
    evalin('base', 'itge_test_vec_col = (1:6)'';');
    
    allVars = getAllNumericVariables();
    names = string(allVars.names);
    
    assert(any(names == "itge_test_vec_row"), 'Вектор-строка не попал в ddVariable list.');
    assert(any(names == "itge_test_vec_col"), 'Вектор-столбец не попал в ddVariable list.');
    
    % Cleanup
    evalin('base', 'clear itge_test_vec_row itge_test_vec_col;');
    
    disp('test_getAllNumericVariables_includes_vectors: OK');
end


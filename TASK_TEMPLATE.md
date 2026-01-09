# Task: [Краткое описание задачи]

**Date:** YYYY-MM-DD  
**Status:** Planning / In Progress / Testing / Completed  
**Priority:** High / Medium / Low  
**Assignee:** [Имя]  
**Related Files:** [список файлов, которые будут созданы/изменены]

---

## Objective

[Подробное описание того, что нужно достичь]

**Success Criteria:**
- [ ] [Критерий 1]
- [ ] [Критерий 2]
- [ ] [Критерий 3]

---

## Background

### Context
[Почему эта задача нужна? Какую проблему решает?]

### Requirements
- [Требование 1]
- [Требование 2]
- [Требование 3]

### Dependencies
- **Requires:** [Список задач, которые должны быть выполнены до этой]
- **Blocks:** [Список задач, которые зависят от этой]

---

## Approach

### Design Overview
[Общий подход к решению задачи]

### Algorithm / Method
[Описание алгоритма или метода решения]

**Pseudocode:**
```
1. [Шаг 1]
2. [Шаг 2]
3. [Шаг 3]
```

### Data Structures
[Какие структуры данных будут использоваться]

```matlab
% Пример структуры данных
example = struct(...
    'field1', value1, ...
    'field2', value2  ...
);
```

### Mathematical Foundation
[Математическая основа, если применимо]

```
Формулы:
y = f(x) = ...
где:
  x - [описание]
  y - [описание]
```

---

## Implementation Plan

### Phase 1: [Название фазы]
**Goal:** [Цель этой фазы]

**Tasks:**
1. [Подзадача 1]
2. [Подзадача 2]
3. [Подзадача 3]

**Deliverables:**
- [ ] [Файл/функция 1]
- [ ] [Файл/функция 2]

### Phase 2: [Название фазы]
[Аналогично]

### Phase 3: [Название фазы]
[Аналогично]

---

## Implementation Notes

### Key Decisions
**Decision 1:** [Описание решения]
- **Rationale:** [Почему так решили]
- **Alternatives:** [Какие были альтернативы]
- **Trade-offs:** [Плюсы и минусы]

**Decision 2:** [Описание решения]
[Аналогично]

### Technical Challenges
**Challenge 1:** [Описание проблемы]
- **Solution:** [Как решили]
- **Notes:** [Дополнительные заметки]

**Challenge 2:** [Описание проблемы]
[Аналогично]

### Fortran Comparison
[Если это миграция с Fortran]

**Original Fortran Code:**
```fortran
! Релевантная часть Fortran кода для справки
```

**MATLAB Implementation:**
```matlab
% Соответствующий MATLAB код
```

**Key Differences:**
- [Различие 1]
- [Различие 2]

---

## Code Implementation

### Main Function

**File:** `src/+package/functionName.m`

**Interface:**
```matlab
function [output1, output2] = functionName(input1, input2, options)
    % FUNCTIONNAME Brief description
    %
    %   [OUTPUT1, OUTPUT2] = FUNCTIONNAME(INPUT1, INPUT2) detailed description
    %
    %   Inputs:
    %       input1 - description [units]
    %       input2 - description [units]
    %       options - (optional) structure with fields:
    %           .field1 - description [units] (default: value)
    %           .field2 - description [units] (default: value)
    %
    %   Outputs:
    %       output1 - description [units]
    %       output2 - description [units]
    %
    %   Example:
    %       [out1, out2] = functionName(10, 20);
    %
    %   See also: RELATEDFUNCTION1, RELATEDFUNCTION2
    
    % Implementation
end
```

**Status:** Not Started / In Progress / Completed / Tested

### Helper Functions

**Function 1:** `helperFunction1.m`
- Purpose: [назначение]
- Status: [статус]

**Function 2:** `helperFunction2.m`
- Purpose: [назначение]
- Status: [статус]

---

## Testing & Verification

### Test Strategy
[Общая стратегия тестирования]

### Unit Tests

**Test 1: [Название теста]**
```matlab
% Test code
function test_basic_functionality()
    % Arrange
    input = [test data];
    expected = [expected result];
    
    % Act
    actual = functionName(input);
    
    % Assert
    assert(isequal(actual, expected), 'Test failed');
end
```

**Status:** Not Started / Passed / Failed

**Test 2: [Название теста]**
[Аналогично]

### Integration Tests

**Test Case 1: [Название]**
- **Description:** [описание теста]
- **Input Data:** [входные данные или файл]
- **Expected Output:** [ожидаемый результат]
- **Status:** Not Started / Passed / Failed

### Verification Against Fortran

**Verification Script:** `tests/verify_[task_name].m`

```matlab
% Verification script structure
% 1. Load Fortran reference data
% 2. Run MATLAB implementation
% 3. Compare results
% 4. Report differences
```

**Acceptance Criteria:**
- Maximum difference: [значение]
- Acceptable tolerance: [значение]

**Results:**
| Parameter | MATLAB | Fortran | Difference | Status |
|-----------|--------|---------|------------|--------|
| [Param 1] | [val]  | [val]   | [diff]     | ✓/✗    |
| [Param 2] | [val]  | [val]   | [diff]     | ✓/✗    |

---

## Performance Considerations

### Computational Complexity
- **Time Complexity:** O(...)
- **Space Complexity:** O(...)

### Bottlenecks
- [Потенциальное узкое место 1]
- [Потенциальное узкое место 2]

### Optimization Opportunities
- [ ] [Возможность оптимизации 1]
- [ ] [Возможность оптимизации 2]

### Benchmarking
```matlab
% Benchmark code
tic;
[output] = functionName(input);
elapsed = toc;
fprintf('Execution time: %.4f seconds\n', elapsed);
```

**Target Performance:** [требуемое время выполнения]  
**Actual Performance:** [фактическое время]

---

## Documentation Updates

### Files to Update
- [ ] PROJECT_DOCS.md
  - Section: [какой раздел]
  - Content: [что добавить]
  
- [ ] Function documentation (H1 line and help text)
- [ ] Inline comments in code
- [ ] User guide (if applicable)

### Documentation Checklist
- [ ] Function purpose clearly stated
- [ ] All inputs and outputs documented
- [ ] Units specified for all physical quantities
- [ ] Examples provided
- [ ] References to literature/standards included
- [ ] Known limitations documented

---

## References

### Literature
1. [Ссылка на книгу/статью 1]
2. [Ссылка на книгу/статью 2]

### Related Work
- [Ссылка на похожую реализацию]
- [Relevant MATLAB documentation]

### Fortran Source
- File: [путь к файлу Fortran]
- Function/Subroutine: [название]
- Lines: [номера строк]

---

## Progress Log

### 2024-11-23
- Task created
- Initial design completed
- [другие события]

### YYYY-MM-DD
- [Событие 1]
- [Событие 2]

---

## Issues & Questions

### Open Issues
- [ ] Issue 1: [описание проблемы]
  - Status: Open / In Progress / Resolved
  - Notes: [заметки]

### Questions for Review
- [ ] Question 1: [вопрос]
  - Answer: [ответ, когда получен]

---

## Completion Checklist

Before marking this task as complete:

- [ ] All code implemented
- [ ] Code reviewed and refactored
- [ ] Unit tests written and passing
- [ ] Integration tests passing
- [ ] Verified against Fortran (if applicable)
- [ ] Performance acceptable
- [ ] Documentation complete
- [ ] PROJECT_DOCS.md updated
- [ ] Code committed to version control
- [ ] Task status updated

---

## Sign-off

**Completed by:** [Имя]  
**Date:** YYYY-MM-DD  
**Reviewed by:** [Имя]  
**Date:** YYYY-MM-DD  

**Final Notes:**
[Финальные комментарии, lessons learned, рекомендации для будущих задач]

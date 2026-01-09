# Task: Сохранение данных в workspace

**Date:** 2026-01-06  
**Status:** Planning  
**Priority:** High  
**Assignee:** [Имя]  
**Related Files:** 
- `TableGraphEditor/src/TableGraphEditor.mlapp`

---

## Objective

Реализовать сохранение отредактированных данных обратно в workspace MATLAB. Всегда спрашивать подтверждение перед перезаписью исходной переменной.

**Success Criteria:**
- [ ] Кнопка "Save to Workspace" работает
- [ ] Всегда спрашивается подтверждение перед сохранением
- [ ] Данные сохраняются в исходную переменную
- [ ] Обрабатываются ошибки сохранения
- [ ] Показывается сообщение об успешном сохранении

---

## Background

### Context
Это финальный этап разработки MVP. После редактирования данных пользователь должен иметь возможность сохранить изменения обратно в workspace.

### Requirements
- Всегда спрашивать подтверждение (`uiconfirm`)
- Перезаписывать исходную переменную
- Показывать имя переменной в диалоге
- Обрабатывать ошибки

### Dependencies
- **Requires:** 
  - `task_20260106_project_structure.md` (базовая структура)
  - `task_20260106_data_loading.md` (загрузка данных)
- **Blocks:** Нет (финальная задача MVP)

---

## Approach

### Design Overview
1. Создать callback для кнопки "Save to Workspace"
2. Проверить, что данные загружены
3. Показать диалог подтверждения
4. Сохранить данные через `assignin`
5. Показать сообщение об успехе

### Algorithm

**Pseudocode:**
```
1. btnSaveButtonPushed callback:
   - Проверить, что данные загружены
   - Показать диалог подтверждения с именем переменной
   - Если подтверждено:
     - Сохранить currentData в workspace
     - Показать сообщение об успехе
   - Если отменено:
     - Ничего не делать
```

---

## Implementation Plan

### Phase 1: Callback кнопки сохранения
**Goal:** Создать callback для кнопки сохранения

**Tasks:**
1. Создать callback `btnSaveButtonPushed`
2. Проверить наличие данных
3. Получить имя переменной

**Deliverables:**
- [ ] Callback создан
- [ ] Проверка данных работает

### Phase 2: Диалог подтверждения
**Goal:** Показать диалог подтверждения

**Tasks:**
1. Использовать `uiconfirm` для диалога
2. Показать имя переменной
3. Обработать ответ пользователя

**Deliverables:**
- [ ] Диалог показывается
- [ ] Ответ обрабатывается

### Phase 3: Сохранение данных
**Goal:** Сохранить данные в workspace

**Tasks:**
1. Использовать `assignin('base', ...)`
2. Сохранить `currentData`
3. Обновить `originalData`

**Deliverables:**
- [ ] Данные сохраняются
- [ ] originalData обновляется

### Phase 4: Обработка ошибок и сообщения
**Goal:** Обработать ошибки и показать сообщения

**Tasks:**
1. Обработать ошибки сохранения
2. Показать сообщение об успехе
3. Показать сообщение об ошибке

**Deliverables:**
- [ ] Ошибки обрабатываются
- [ ] Сообщения показываются

---

## Implementation Notes

### Key Decisions
**Decision 1:** Всегда спрашивать подтверждение
- **Rationale:** Защита от случайной перезаписи
- **Alternatives:** Спрашивать только при изменениях
- **Trade-offs:** Может быть навязчиво, но безопаснее

**Decision 2:** Использовать uiconfirm вместо uialert
- **Rationale:** uiconfirm поддерживает кнопки Да/Нет
- **Alternatives:** Использовать uialert с кастомными кнопками
- **Trade-offs:** uiconfirm проще в использовании

### Technical Challenges
**Challenge 1:** Проверка изменений данных
- **Solution:** Можно сравнить currentData с originalData (опционально)
- **Notes:** Для MVP всегда спрашиваем подтверждение

**Challenge 2:** Обработка ошибок при сохранении
- **Solution:** Использовать try-catch и показывать сообщение
- **Notes:** Может быть ошибка, если переменная была удалена из workspace

---

## Code Implementation

### Callback: btnSaveButtonPushed

```matlab
function btnSaveButtonPushed(app, src, event)
    % BTNSAVEBUTTONPUSHED Обработчик нажатия кнопки сохранения
    %   Сохраняет данные в workspace с подтверждением
    
    try
        % Проверить, что данные загружены
        if isempty(app.currentData) || isempty(app.selectedVariable)
            uialert(app.UIFigure, ...
                'Нет данных для сохранения', ...
                'Ошибка сохранения', ...
                'Icon', 'warning');
            return;
        end
        
        % Показать диалог подтверждения
        message = sprintf('Перезаписать переменную "%s" в workspace?', ...
            app.selectedVariable);
        
        selection = uiconfirm(app.UIFigure, ...
            message, ...
            'Подтверждение сохранения', ...
            'Options', {'Да', 'Нет'}, ...
            'DefaultOption', 'Нет', ...
            'CancelOption', 'Нет', ...
            'Icon', 'question');
        
        % Проверить ответ
        if strcmp(selection, 'Да')
            % Сохранить данные
            assignin('base', app.selectedVariable, app.currentData);
            
            % Обновить originalData
            app.originalData = app.currentData;
            
            % Показать сообщение об успехе
            uialert(app.UIFigure, ...
                sprintf('Данные успешно сохранены в переменную "%s"', ...
                    app.selectedVariable), ...
                'Сохранение завершено', ...
                'Icon', 'success');
        end
        
    catch ME
        uialert(app.UIFigure, ...
            sprintf('Ошибка при сохранении: %s', ME.message), ...
            'Ошибка сохранения', ...
            'Icon', 'error');
    end
end
```

**Status:** Not Started

---

## Testing & Verification

### Test Strategy
Тестировать сохранение данных и обработку ошибок.

### Integration Tests
**Test Case 1: Сохранение данных**
- **Description:** Отредактировать данные и сохранить в workspace
- **Input Data:** Переменная testData в workspace, данные отредактированы
- **Expected Output:** Данные сохранены, переменная обновлена в workspace
- **Status:** Not Started

**Test Case 2: Отмена сохранения**
- **Description:** Нажать "Сохранить" и отменить в диалоге
- **Input Data:** Данные отредактированы
- **Expected Output:** Данные не сохранены, переменная не изменена
- **Status:** Not Started

---

## Documentation Updates

### Files to Update
- [ ] Комментарии в коде
- [ ] USER_GUIDE.md (раздел "Сохранение данных")

---

## Progress Log

### 2026-01-06
- Task created
- Design completed

---

## Completion Checklist

Before marking this task as complete:

- [ ] Callback `btnSaveButtonPushed` реализован
- [ ] Диалог подтверждения показывается
- [ ] Данные сохраняются в workspace
- [ ] originalData обновляется
- [ ] Ошибки обрабатываются
- [ ] Сообщения показываются
- [ ] Тесты написаны и проходят

---

## Sign-off

**Completed by:** [Имя]  
**Date:** 2026-01-06  
**Reviewed by:** [Имя]  
**Date:** 2026-01-06


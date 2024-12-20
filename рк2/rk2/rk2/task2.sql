-- 1. Инструкция SELECT, использующая поисковое выражение CASE
-- Разбиение сотрудников на Ньюфагов, Среднячков и Олдов.
SELECT PK_ID, ФИО, Год_рождения,
    CASE 
        WHEN Должность = 'Менеджер' THEN 'Среднячок'
        WHEN Должность = 'Старший менеджер' THEN 'Олд'
        ELSE 'Ньюфаг'
    END AS Должность
FROM Сотрудник;

-- 2. Инструкция UPDATE со скалярным подзапросом в предложении SET
-- Увеличение курса продажи USD на 5%
UPDATE Курсы_валют
SET Продажа = (
    SELECT Продажа * 1.05
    FROM Курсы_валют КВ
    WHERE КВ.PK_ID = Курсы_валют.PK_ID
      AND EXISTS (
        SELECT 1
        FROM Виды_валют ВВ
        WHERE ВВ.PK_ID = КВ.ID_Валюта AND ВВ.Валюта = 'USD'
    )
)
WHERE EXISTS (
    SELECT 1
    FROM Виды_валют ВВ
    WHERE ВВ.PK_ID = Курсы_валют.ID_Валюта AND ВВ.Валюта = 'USD'
);


-- 3. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов
-- Получение статистики по операциям обмена для каждой валюты
SELECT 
    В.Валюта,
    SUM(ОО.Сумма) AS Общая_сумма,
    AVG(ОО.Сумма) AS Средняя_сумма,
    COUNT(*) AS Количество_операций
FROM Операция_обмена ОО
JOIN Курсы_валют КВ ON ОО.ID_Курс_валют = КВ.PK_ID
JOIN Виды_валют В ON КВ.ID_Валюта = В.PK_ID
GROUP BY В.Валюта;

-- 1 ПЛАН

EXPLAIN
SELECT s.*
FROM satellite s
WHERE NOT EXISTS (
    SELECT 1
    FROM flight f
    WHERE f.satellite_id = s.id
);

-- Описание на естественном языке:
-- Этот запрос находит все спутники из таблицы satellite, для которых не существует ни одного соответствующего полета в таблице flight.

-- Hash Anti Join означает, что база данных выполняет антисоединение, чтобы исключить строки из таблицы satellite, для которых есть совпадения в таблице flight.
-- Seq Scan on satellite указывает на полное последовательное сканирование таблицы satellite.
-- Hash и Seq Scan on flight показывают, что таблица flight также полностью сканируется и создаётся хэш-таблица для проверки отсутствия соответствия.


-- 2 ПЛАН

EXPLAIN
SELECT 
    date_trunc('month', f.launch_date) AS month,
    COUNT(*)
FROM flight f
JOIN satellite s 
    ON date_trunc('month', f.launch_date) = date_trunc('month', s.manufacture_date)
GROUP BY date_trunc('month', f.launch_date);

-- Описание на естественном языке:
-- Этот запрос находит количество совпадающих записей, где месяц и год даты запуска из таблицы flight совпадает с месяцем и годом даты рождения спутника из таблицы satellite.

-- Hash Join выполняет соединение таблиц flight и satellite на основе условия совпадения месяца и года.
-- Seq Scan указывает на последовательное сканирование обеих таблиц.
-- HashAggregate указывает на агрегирование результатов для подсчёта количества строк.
-- В строке Group Key: date_trunc('month'::text, (s.birth)::timestamp with time zone) указано, что группировка выполняется по результату функции date_trunc.
-- Строка HashAggregate указывает на выполнение агрегации с использованием хэш-таблицы.
-- Агрегация означает, что строки, сгруппированные по Group Key, обрабатываются для получения итоговых значений. Примеры агрегатных функций: COUNT, SUM, AVG, MAX, MIN.
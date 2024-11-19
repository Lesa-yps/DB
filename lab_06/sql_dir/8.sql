-- 8. Вызвать системную функцию или процедуру

-- информация обо всех текущих соединениях с базой данных
COPY (
    SELECT * FROM pg_stat_activity
) TO '/tmp/8.csv' WITH CSV HEADER;

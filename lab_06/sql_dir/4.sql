-- 4. Выполнить запрос к метаданным
-- выводит информацию о коолонках таблица Authors
COPY (
    SELECT column_name, data_type, is_nullable
    FROM information_schema.columns
    WHERE table_name = 'authors'
) TO '/tmp/4.csv' WITH CSV HEADER;

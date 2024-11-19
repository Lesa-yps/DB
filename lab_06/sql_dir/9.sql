-- 9. Создать таблицу в базе данных, соответствующую тематике БД

-- создаём таблицу с информацией о жанрах книг
CREATE TABLE IF NOT EXISTS Genres (
    genre_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT
);

-- выводим содержимое таблицы
COPY (
    SELECT *
    FROM Genres
) TO '/tmp/9.csv' WITH CSV HEADER;

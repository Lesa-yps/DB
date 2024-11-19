-- 10. Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY

-- вставляем данные в таблицу жанров
INSERT INTO Genres (name, description)
VALUES
    ('Fantasy', 'A genre of speculative fiction involving magical elements.'),
    ('Science Fiction', 'Fiction dealing with futuristic settings, advanced technology, or space exploration.'),
    ('Mystery', 'Fiction focused on solving a crime or uncovering secrets.'),
    ('Romance', 'A genre centered around love and relationships.');

-- выводим содержимое таблицы
COPY (
    SELECT *
    FROM Genres
) TO '/tmp/10.csv' WITH CSV HEADER;

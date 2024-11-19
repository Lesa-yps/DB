-- 1. Выполнить скалярный запрос
-- число книг в жанре фэнтези
COPY (
    SELECT COUNT(*) AS fantasy_books_count
    FROM Books
    WHERE genre = 'Fantasy'
) TO '/tmp/1.csv' WITH CSV HEADER;

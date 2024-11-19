-- 7. Вызвать хранимую процедуру (написанную в третьей лабораторной работе)

-- Увеличивает годы издания книг на переданное число для книг автора с переданным id
CREATE OR REPLACE PROCEDURE update_author_publish_year(author_id_ask INT, num INT)
AS $$
BEGIN
    UPDATE Books
    SET publish_year = publish_year + num
    WHERE author_id = author_id_ask;
END;
$$
LANGUAGE plpgsql;
-- Вызов процедуры (увеличение для автора с id = 6 лет издания книг на 1
CALL update_author_publish_year(6, 1);

-- Вызов функции для вывода книг автора с id = 6
COPY (
    SELECT * FROM find_books_author(6)
) TO '/tmp/7.csv' WITH CSV HEADER;

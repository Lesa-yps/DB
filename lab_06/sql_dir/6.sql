-- 6. Вызвать многооператорную табличную функцию (написанную в третьей лабораторной работе)

-- Вернёт книги, которые не арендованы и id автора меньше 10, и книги, у которых есть аренда и id читателя [10, 20]
CREATE OR REPLACE FUNCTION find_books_authors()
RETURNS TABLE(book_id INT, title VARCHAR, author_id INT)
AS $$
BEGIN
    -- Первый запрос: книги авторов с id < 10 и которые не присутствуют в аренде
    RETURN QUERY
    SELECT B.book_id, B.title, B.author_id
    FROM Books B
    WHERE B.author_id < 10
    AND NOT EXISTS (
        SELECT 1
        FROM Rentals RB
        WHERE B.book_id = RB.book_id
    );

    -- Второй запрос: книги, которые были взяты читателями с id от 10 до 20
    RETURN QUERY
    SELECT B.book_id, B.title, B.author_id
    FROM Books B
    JOIN Rentals RB ON B.book_id = RB.book_id
    JOIN Readers R ON R.reader_id = RB.reader_id
    WHERE R.reader_id >= 10 AND R.reader_id <= 20;
END;
$$
LANGUAGE plpgsql;

-- Вызов функции
COPY (
    SELECT *
    FROM find_books_authors()
) TO '/tmp/6.csv' WITH CSV HEADER;

-- 5. Вызвать скалярную функцию (написанную в третьей лабораторной работе)

-- Считает количество книг у автора с переданным id
CREATE OR REPLACE FUNCTION calc_count_books_author(author_id INT)
RETURNS INT
AS $$
DECLARE
       books_count INT;
BEGIN
       SELECT count(*)
       INTO books_count
       FROM Books
       WHERE Books.author_id = calc_count_books_author.author_id;

       RETURN books_count;
END;
$$
LANGUAGE plpgsql;

-- Вызов функции
COPY (
    SELECT calc_count_books_author(10)
) TO '/tmp/5.csv' WITH CSV HEADER;

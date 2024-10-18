-- Лабораторная работа № 3: SQL модули
-- Задание: Разработать и тестировать 10 модулей

-- 1. Четыре функции

-- 1.1. Скалярную функцию
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
SELECT calc_count_books_author(10);

-- 1.2. Подставляемую табличную функцию
-- Выводит (названия, жанр, год публикации) книг у автора с переданным id
CREATE OR REPLACE FUNCTION find_books_author(author_id INT)
RETURNS TABLE(book_title VARCHAR, genre VARCHAR, publish_year INT
AS $$
BEGIN
	   RETURN QUERY

       SELECT B.title, B.genre, B.publish_year
       FROM Books B
       WHERE B.author_id = find_books_author.author_id;
END;
$$
LANGUAGE plpgsql;
-- Вызов функции
SELECT *
FROM find_books_author(10);


-- 1.3. Многооператорную табличную функцию
-- Считает количество книг у всех авторов и выводит (имя автора, фамилия автора, количество книг автора)
CREATE OR REPLACE FUNCTION find_books_authors()
RETURNS TABLE(author_first_name VARCHAR, author_last_name VARCHAR, count_books BIGINT)
AS $$
DECLARE
       i RECORD;
BEGIN
	   FOR i IN SELECT author_id, first_name, last_name
			    FROM Authors
	   LOOP
			 RETURN QUERY

       		 SELECT i.first_name, i.last_name, COUNT(*)
       		 FROM Books B
      		 WHERE B.author_id = i.author_id;
	   END LOOP;
END;
$$
LANGUAGE plpgsql;
-- Вызов функции
SELECT *
FROM find_books_authors();
-- Удаление функции
drop function find_books_authors;


-- 1.4. Функцию с рекурсивным ОТВ
-- Возвращает списки аренды для всех читателей, у которых дата возврата книги return_date_ask
CREATE OR REPLACE FUNCTION get_book_rentals_by_return_date(return_date_ask DATE)
RETURNS TABLE(rental_id INT, book_id INT, reader_id INT, take_date DATE, return_date DATE)
AS $$
BEGIN
    RETURN QUERY
	-- Определение ОТВ 
	WITH RECURSIVE BookRentals AS
	(
	    -- Закрепленный элемент: выбираем ренты с датой возврата return_date_ask и помечаем как взятые
	    SELECT r.rental_id, r.book_id, r.reader_id, r.take_date, r.return_date, TRUE AS is_take
	    FROM Rentals r
	    WHERE r.return_date = return_date_ask
	
	    UNION ALL
	
	    -- Рекурсивный элемент: добавляем ренты того же читателя, если они еще не помечены как взятые
	    SELECT r.rental_id, r.book_id, r.reader_id, r.take_date, r.return_date, TRUE AS is_take
	    FROM Rentals r
	    INNER JOIN BookRentals br ON r.reader_id = br.reader_id
	    WHERE br.is_take != True
	)
	-- Инструкция, использующая ОТВ
	SELECT rb.rental_id, rb.book_id, rb.reader_id, rb.take_date, rb.return_date
	FROM BookRentals rb;
END;
$$
LANGUAGE plpgsql;
-- Вызов функции
SELECT *
FROM get_book_rentals_by_return_date('2024-04-09');
-- Удаление функции
drop function get_book_rentals_by_return_date;


-- 2. Четыре хранимых процедуры

-- 2.1. Хранимую процедуру с параметрами
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
-- Вызов процедуры (увеличение для автора с id = 4 лет издания книг на 1)
CALL update_author_publish_year(4, 1);
-- Вызов функции для вывода книг автора с id = 4
SELECT * FROM find_books_author(4);

-- 2.2. Рекурсивную хранимую процедуру или хранимую процедур с рекурсивным ОТВ
-- Отодвигает дату возврата всех книг для читателей, у которых хоть одна книга взята до переданной даты, на 10 дней вперёд
CREATE OR replace PROCEDURE update_book_rentals_by_return_date(return_date_ask DATE)
AS $$
BEGIN
	-- Определение ОТВ 
	WITH RECURSIVE BookRentals AS
	(
	    -- Закрепленный элемент: выбираем ренты с датой возврата return_date_ask и помечаем как взятые
	    SELECT r.rental_id, r.book_id, r.reader_id, r.take_date, r.return_date, TRUE AS is_take
	    FROM Rentals r
	    WHERE r.return_date = return_date_ask
	
	    UNION ALL
	
	    -- Рекурсивный элемент: добавляем ренты того же читателя, если они еще не помечены как взятые
	    SELECT r.rental_id, r.book_id, r.reader_id, r.take_date, r.return_date, TRUE AS is_take
	    FROM Rentals r
	    INNER JOIN BookRentals br ON r.reader_id = br.reader_id
	    WHERE br.is_take != True
	)
	-- Инструкция, использующая ОТВ
	UPDATE Rentals
    SET return_date = return_date + INTERVAL '10 days'
    WHERE rental_id IN (SELECT rental_id FROM BookRentals);
END;
$$
LANGUAGE plpgsql;
-- Вызов процедуры
CALL update_book_rentals_by_return_date('2024-04-09');

-- Вызов функции
SELECT *
FROM get_book_rentals_by_return_date('2024-04-09');


-- 2.3. Хранимую процедуру с курсором
-- Выводит информацию о читателях и книгах, которые они должны вернуть в переданную дату
CREATE OR REPLACE PROCEDURE get_readers_with_due_books(return_date_ask DATE)
AS $$
DECLARE
    rental_cursor CURSOR FOR
        SELECT reader.first_name, reader.last_name, reader.email, book.title
        FROM Rentals rental
			JOIN Readers reader ON  reader.reader_id = rental.reader_id
			JOIN Books book ON  book.book_id = rental.book_id
		WHERE rental.return_date = return_date_ask;
    rental_record RECORD;
BEGIN
    -- Открываем курсор
    OPEN rental_cursor;
    -- Цикл для извлечения каждой строки
    LOOP
        FETCH rental_cursor INTO rental_record;
        EXIT WHEN NOT FOUND;  -- Выход из цикла, если данных больше нет
        -- Вывод информации о читателе и книге
        RAISE NOTICE 'Reader: % %, Email: %, Book Title: %',
            rental_record.first_name, rental_record.last_name, rental_record.email, rental_record.title;
    END LOOP;
    -- Закрываем курсор
    CLOSE rental_cursor;
END;
$$
LANGUAGE plpgsql;

-- Вызов процедуры
CALL get_readers_with_due_books('2024-04-09');
-- Удаление процедуры
DROP PROCEDURE get_readers_with_due_books;


-- 2.4. Хранимую процедуру доступа к метаданным
-- Выводит названия столбцов и типы данных в них по назвиниям переданных таблицы и схемы
CREATE OR REPLACE PROCEDURE get_table_columns(table_name_ask VARCHAR, table_schema_ask VARCHAR)
AS $$
DECLARE
	-- Переменная для хранения информации о столбце
    column_record RECORD;  
BEGIN
    RAISE NOTICE 'Столбцы в таблице %:', table_name_ask;

    FOR column_record IN
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_name = table_name_ask
          AND table_schema = table_schema_ask
    LOOP
        RAISE NOTICE 'Column Name: %, Data Type: %',
            column_record.column_name, column_record.data_type;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

-- Вызов процедуры
call get_table_columns('books', 'public')


-- 3. Два DML триггера

-- 3.1. Триггер AFTER
-- Триггерная функция (будто читатель с id=4 арендует все только что выпущенные книги на 3 дня)
CREATE OR REPLACE FUNCTION add_rental_on_new_book()
RETURNS trigger
AS $$
DECLARE
    next_rental_id INT;
BEGIN
    -- Получаем максимальный rental_id и увеличиваем на 1
    SELECT COALESCE(MAX(rental_id), 0) + 1 INTO next_rental_id FROM Rentals;
    -- Добавляем новую запись в Rentals
    INSERT INTO Rentals (rental_id, book_id, reader_id, take_date, return_date)
    VALUES (next_rental_id, NEW.book_id, 4, CURRENT_DATE, CURRENT_DATE + INTERVAL '3 days');

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

-- Сам триггер
CREATE TRIGGER after_book_insert
AFTER INSERT ON Books
FOR EACH ROW
EXECUTE FUNCTION add_rental_on_new_book();

-- Добавление строки -> вызов триггера
INSERT INTO Books (book_id, title, genre, author_id, publish_year)
VALUES (1113, 'New Book Title', 'Fantasy', 1, 2024);


-- 3.2. Триггер INSTEAD OF

-- нужно работать с представлением, поскольку триггеры INSTEAD OF не могут быть созданы для обычных таблиц, поэтому создадим его на основе таблицы книг
CREATE VIEW Books_View AS
SELECT * FROM Books;

-- Триггерная функция (будто id каждой добавляемой книги формируется автоматически на основе максимального существующего)
CREATE OR REPLACE FUNCTION add_new_book_auto_id()
RETURNS trigger
AS $$
DECLARE
    next_book_id INT;
BEGIN
    -- Получаем максимальный book_id и увеличиваем на 1
    SELECT COALESCE(MAX(book_id), 0) + 1 INTO next_book_id FROM Books;
    -- Добавляем новую запись в Books
    INSERT INTO Books (book_id, title, genre, author_id, publish_year)
    VALUES (next_book_id, NEW.title, NEW.genre, NEW.author_id, NEW.publish_year);

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

-- Сам триггер
CREATE TRIGGER instead_of_book_insert
INSTEAD OF INSERT ON Books_View
FOR EACH ROW
EXECUTE FUNCTION add_new_book_auto_id();

-- Добавление строки якобы в представление, но посредством триггера в саму таблицу книг -> вызов триггера
INSERT INTO Books_View (title, genre, author_id, publish_year)
VALUES ('New Book Title 2', 'Fantasy', 1, 2024);

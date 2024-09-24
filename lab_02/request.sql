-- Лабораторная работа № 2: SQL запросы
-- 1. Инструкция SELECT, использующая предикат сравнения.
-- Вернуть список названий книг по жанру фэнтези
SELECT title 
FROM Books 
WHERE TRIM(genre) = 'fantasy';
-- 2. Инструкция SELECT, использующая предикат BETWEEN.
-- Получить список псевдонимов авторов, родившихся в 80-е 
SELECT  pseudonym
FROM Authors
WHERE birthday BETWEEN '1980-01-01' AND '1989-12-31'
-- 3. Инструкция SELECT, использующая предикат LIKE.
-- Получить список читателей, указавших почту mail.ru 
SELECT  first_name
       ,last_name
FROM Readers
WHERE email LIKE '%@mail.ru'
-- 4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
-- Получить список писателей, у которых есть книга в жанре фэнтези 
SELECT  first_name
       ,last_name
FROM Authors
WHERE author_id IN ( SELECT author_id FROM Books WHERE TRIM(genre) = 'fantasy' )
-- 5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом.
-- Получить список читателей, которые ещё ни разу не брали ни 1 книги 
SELECT  first_name
       ,last_name
FROM Readers
WHERE EXISTS (
SELECT  Readers.reader_id
FROM Readers
LEFT OUTER JOIN Rentals
ON Readers.reader_id = Rentals.reader_id
WHERE Rentals.reader_id IS NULL )
-- 6. Инструкция SELECT, использующая предикат сравнения с квантором.
-- Получить список названий книг, год издания которых позже всех фэнтезюшных 
SELECT  title
FROM Books
WHERE publish_year > ALL (
SELECT  publish_year
FROM Books
WHERE TRIM(genre) = 'fantasy' )
-- 7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов.
-- Получить список средних минимальных лет издания книг каждого жанра 
SELECT  AVG(min_years)                AS Actual_year_avg
       ,SUM(min_years) / COUNT(genre) AS Calc_year_avg
FROM
(
	SELECT  genre
	       ,MIN(publish_year) AS min_years
	FROM Books
	GROUP by genre
)
-- 8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
-- Получить список авторов с количеством написанных ими книг 
SELECT  A.author_id
       ,A.first_name
       ,A.last_name
       ,(
SELECT  COUNT(*)
FROM Books B
WHERE B.author_id = A.author_id) AS count_books
FROM Authors A
-- 9. Инструкция SELECT, использующая простое выражение CASE.
-- Разбирает книги на типы новел 
SELECT  book_id
       ,title
       ,CASE TRIM(genre) WHEN 'romance novel' THEN 'romance novel' WHEN 'historical novel' THEN 'historical novel' ELSE 'not novel' END AS genre_novel
FROM Books
-- 10. Инструкция SELECT, использующая поисковое выражение CASE.
-- Для каждой книги даёт относительную оценку новизны 
SELECT  book_id
       ,title
       ,CASE WHEN publish_year > 2020 THEN 'newest'
             WHEN publish_year > 2000 THEN 'new'
             WHEN publish_year > 1800 THEN 'average'  ELSE 'old' END AS
             WHEN_publish
FROM Books
-- 11. Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT.
-- Создаёт временную локальную таблицу из читателей, дата регистрации которых 2024+
DROP TABLE IF EXISTS NewReaders;
CREATE TEMP TABLE NewReaders AS
SELECT reader_id, first_name, last_name, email, registration_date
FROM Readers
WHERE registration_date >= '2024-01-01';
SELECT * FROM NewReaders
-- 12. Инструкция SELECT, использующая вложенные коррелированные подзапросы в качестве производных таблиц в предложении FROM.
-- Считает сколько у каждого читателя книг 
SELECT  Rea.reader_id
       ,Rea.first_name
       ,Rea.last_name
       ,(
SELECT  COUNT(*)
FROM Rentals Ren
WHERE Ren.reader_id = Rea.reader_id) AS count_books
FROM Readers Rea
-- 13. Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3.
-- Получает все id авторов, у которых есть книги, бывшие в аренде 
SELECT  author_id
FROM Authors A
WHERE EXISTS (
SELECT  1
FROM Books B
WHERE A.author_id = B.author_id
AND EXISTS (
SELECT  1
FROM Rentals R
WHERE B.book_id = R.book_id))
-- 14. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING.
-- Считает количество книг у 1 автора
SELECT  author_id
       ,COUNT(*) AS count_books
FROM Books
GROUP BY  author_id
-- 15. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY  и предложения HAVING.
-- Считает количество книг у 1 автора и выбирает тех, где > 3 
SELECT  author_id
       ,COUNT(*) AS count_books
FROM Books
GROUP BY author_id
HAVING COUNT(*) > 3
-- 16. Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений.
-- Вставка нового читателя 
INSERT INTO Readers (reader_id, first_name, last_name, email, registration_date) VALUES (1050, 'Anny', 'Polycova', 'polyanny@mail.ru', '2020-01-05')
-- 17. Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса.
-- Вставка нового читателя (id на 1 больше максимального текущего) 
INSERT INTO Readers (reader_id, first_name, last_name, email, registration_date) VALUES ( (
SELECT  MAX(reader_id)
FROM Readers) + 1, 'John', 'Duo', 'djo@yandex.ru', '2010-10-10')
-- 18. Простая инструкция UPDATE.
-- Добавляет к названиям книг жанра биография "Биография " 
UPDATE Books
SET title = 'biography ' || COALESCE(title, '')
WHERE TRIM(genre) = 'biography'
-- 19. Инструкция UPDATE со скалярным подзапросом в предложении SET.
-- устанавливает email 2-ого читателя такой же как у 1-ого 
 UPDATE Readers
SET registration_date = (
SELECT  registration_date
FROM Readers
WHERE reader_id = 1 )
WHERE reader_id = 2
-- 20. Простая инструкция DELETE.
-- удаляет всех читателей, зарегистрировавшихся в 2023 году 
DELETE FROM Readers
WHERE EXTRACT(YEAR FROM registration_date) = 2023;
-- 21. Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE.
-- удаляет всех читателей, кто ещё не арендовал ни 1 книги 
 DELETE
FROM Readers Rea
WHERE NOT EXISTS (
SELECT  1
FROM Rentals Ren
WHERE Rea.reader_id = Ren.reader_id)
-- 22. Инструкция SELECT, использующая простое обобщенное табличное выражение
-- Считает среднее количество книг у авторов 
WITH Count_Author_Books
(author_id, count_books
) AS (
SELECT  author_id
       ,COUNT(*) AS count_books
FROM Books
GROUP BY  author_id)
SELECT  AVG(count_books) AS Avg_count_author_books
FROM Count_Author_Books
-- 23. Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение.
-- Возвращает списки аренды для всех читателей, у которых дата возврата книги '2024-04-09'
-- Определение ОТВ 
WITH RECURSIVE BookRentals AS
(
    -- Закрепленный элемент: выбираем ренты с отсутствующей датой возврата и помечаем как взятые
    SELECT rental_id, book_id, reader_id, take_date, return_date, TRUE AS is_take
    FROM Rentals
    WHERE return_date = '2024-04-09'

    UNION ALL

    -- Рекурсивный элемент: добавляем ренты того же читателя, если они еще не помечены как взятые
    SELECT r.rental_id, r.book_id, r.reader_id, r.take_date, r.return_date, TRUE AS is_take
    FROM Rentals r
    INNER JOIN BookRentals br ON r.reader_id = br.reader_id
    WHERE br.is_take = FALSE
)
-- Инструкция, использующая ОТВ
SELECT rental_id, book_id, reader_id, take_date, return_date
FROM BookRentals;
--24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER()
-- Для каждой книги высчитывается средний, минимальный и максимальный годы публикации книг этого автора 
SELECT  B.book_id
       ,B.title
       ,B.genre
       ,B.author_id
       ,AVG(B.publish_year) OVER(PARTITION BY B.author_id) AS avg_year
       ,MIN(B.publish_year) OVER(PARTITION BY B.author_id) AS min_year
       ,MAX(B.publish_year) OVER(PARTITION BY B.author_id) AS max_year
FROM Books B
-- 25. Оконные фнкции для устранения дублей Придумать запрос, в результате которого в данных появляются полные дубли.
-- Устранить дублирующиеся строки с использованием функции ROW_NUMBER(). 
INSERT INTO Authors (author_id, first_name, last_name, pseudonym, birthday)
VALUES (2000, 'Leo', 'Tolstoy', 'L.N. Tolstoy', '1828-09-09'),
(2000, 'Leo', 'Tolstoy', 'L.N. Tolstoy', '1828-09-09');

DELETE
FROM Authors
WHERE author_id IN (
SELECT author_id
FROM  (
SELECT author_id, ROW_NUMBER() OVER (PARTITION BY author_id ORDER BY author_id) AS rn FROM Authors  ) AS temp
WHERE rn > 1 ) 
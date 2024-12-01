select * from pg_language;
create extension if not exists plpython3u;

-- Задание: Создать, развернуть и протестировать 6 объектов SQL CLR:


-- 1) Определяемая пользователем скалярная функцию CLR.
-- Получить имя + фамилия автора по id.
CREATE OR REPLACE FUNCTION get_author_full_name(find_id INT)
RETURNS VARCHAR
AS $$
	query = plpy.execute(f" \
	    SELECT first_name, last_name \
	    FROM Authors  \
	    WHERE author_id = {find_id};")
	if query:
	    return query[0]['first_name'] + query[0]['last_name']
$$ LANGUAGE plpython3u;

SELECT * FROM get_author_full_name(5);

DROP FUNCTION get_author_full_name;


-- 2) Пользовательская агрегатная функция CLR.
-- Получить год с наибольшим количеством выпущенных книг
CREATE OR REPLACE FUNCTION get_year_max_publish_books()
RETURNS INT
AS $$
	query = plpy.execute(f" \
	    SELECT book_id, publish_year \
	    FROM Books;")
	if not query:
	    return -1
	dict_year = dict()
	for strk in query:
		year = strk['publish_year']
		if year not in dict_year:
			dict_year[year] = 0
		dict_year[year] += 1
	max_year = max(dict_year, key=dict_year.get)
	return max_year
$$ LANGUAGE plpython3u;

-- используя функцию get_year_max_publish_books выводит книги, выпущенные в год, в котором было выпущено наибольшее количество книг
SELECT *
from Books
where publish_year = get_year_max_publish_books();

DROP FUNCTION get_year_max_publish_books;


-- 3) Определяемая пользователем табличная функция CLR.
-- Возвращает объединённую таблицу авторов и книг, если авторы опубликовали их в возрасте <= переданного числа лет
CREATE OR REPLACE FUNCTION get_books_authors_less_than_yaers(count_years INT)
RETURNS TABLE (
    author_id INT,
    first_name VARCHAR,
    last_name VARCHAR,
    birthday_year INT,
    title VARCHAR,
    publish_year INT,
    diff_year INT
)
AS $$
	query = plpy.execute(f" \
	    SELECT A.author_id, A.first_name, A.last_name, EXTRACT(YEAR FROM A.birthday) AS birthday_year, B.title, B.publish_year \
	    FROM Books B join Authors A on B.author_id = A.author_id;")
	res_query = list()
	for strk in query:
		diff_year = strk['publish_year'] - strk['birthday_year']
		if diff_year <= count_years and diff_year > 0:
			strk['diff_year'] = diff_year
			res_query.append(strk)
	return res_query
$$ LANGUAGE plpython3u;

SELECT *
from  get_books_authors_less_than_yaers(20);

DROP FUNCTION get_books_authors_less_than_yaers;


-- 4) Хранимая процедура CLR.
-- Увеличивает годы издания книг на переданное число для книг автора с переданным id
CREATE OR REPLACE PROCEDURE update_author_publish_year(author_id_ask INT, num INT)
AS $$
    plpy.execute(f"""
        UPDATE Books
        SET publish_year = publish_year + {num}
        WHERE author_id = {author_id_ask};
    """)
$$ LANGUAGE plpython3u;

-- Вызов процедуры (увеличение для автора с id = 4 лет издания книг на 1)
CALL update_author_publish_year(4, 1);

-- Вызов функции для вывода книг автора с id = 4
SELECT * FROM find_books_author(4);


-- 5) Триггер CLR. (Триггер AFTER)
-- Триггерная функция (будто читатель с id=4 арендует все только что выпущенные книги на 3 дня)
CREATE OR REPLACE FUNCTION add_rental_on_new_book()
RETURNS trigger
AS $$
    # Получаем максимальный rental_id
    query = plpy.execute("SELECT COALESCE(MAX(rental_id), 0) + 1 AS next_rental_id FROM Rentals")
    
    next_rental_id = query[0]["next_rental_id"] if query else 1

    # Добавляем новую запись в Rentals
    plpy.execute(f"""
        INSERT INTO Rentals (rental_id, book_id, reader_id, take_date, return_date)
        VALUES ({next_rental_id}, {TD['new']['book_id']}, 4, CURRENT_DATE, CURRENT_DATE + INTERVAL '3 days');
    """)
    return None
$$ LANGUAGE plpython3u;

-- Сам триггер
CREATE OR REPLACE TRIGGER after_book_insert
AFTER INSERT ON Books
FOR EACH ROW
EXECUTE FUNCTION add_rental_on_new_book();

-- Добавление строки -> вызов триггера
INSERT INTO Books (book_id, title, genre, author_id, publish_year)
VALUES (1115, 'New Book Title', 'Fantasy', 4, 2024);


-- 6) Определяемый пользователем тип данных
-- Вернёт авторов с количеством читателей их книг типом author_cread
create type author_cread as (
  author_id int,
  pseudonym VARCHAR,
  cread int
);

CREATE OR REPLACE FUNCTION get_author_cread()
RETURNS SETOF author_cread  -- Используем SETOF для возврата нескольких строк
AS $$
    query = plpy.execute(f"""
        SELECT A.author_id, A.pseudonym, COUNT(*) as cread
        FROM Books B JOIN Authors A ON B.author_id = A.author_id
        JOIN Rentals R ON B.book_id = R.book_id
        GROUP BY A.author_id
		ORDER BY A.author_id;
    """)
    
    # Если запрос не вернул результатов
    if not query:
        return []

    # Возвращаем список кортежей, каждый из которых соответствует структуре типа author_cread
    result = []
    for row in query:
        result.append((row['author_id'], row['pseudonym'], row['cread']))

    return result
$$ LANGUAGE plpython3u;

select * from get_author_cread();

DROP TYPE IF EXISTS author_cread CASCADE;


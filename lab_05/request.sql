create database DB_Litres_test;

-- Задание:
-- 1. Из таблиц базы данных, созданной в первой лабораторной работе, извлечь данные в JSON
SELECT json_agg(Books) AS books_json FROM Books;
SELECT json_agg(Authors) AS authors_json FROM Authors;
SELECT json_agg(Readers) AS readers_json FROM Readers;
SELECT json_agg(Rentals) AS rentals_json FROM Rentals;



-- 2. Выполнить загрузку и сохранение JSON файла в таблицу.

-- создаётся новая таблица с авторами
CREATE TABLE if not exists new_Authors
(
    author_id INT primary KEY,
    first_name VARCHAR(225),
    last_name VARCHAR(225),
    pseudonym VARCHAR(225),
    birthday DATE
);

-- данные из старой таблицы с авторами копируются в файл
-- если в терминале:
-- sudo -i -u postgres
-- \c DB_Litres
COPY (
    SELECT row_to_json(Authors) AS result
    FROM Authors 
) TO '/tmp/Authors.json';

-- создаётся временная таблица для  хранения данных из JSON, чтобы выполнить преобразования
CREATE TEMP TABLE temp_Authors
(
	data JSONB
);

-- импорт JSON-данных в эту таблицу
COPY temp_Authors(data) FROM '/tmp/Authors.json';

-- преобразуем данные и вставим в результирующую таблицу
INSERT INTO new_Authors (author_id, first_name, last_name, pseudonym, birthday)
SELECT
    (data->>'author_id')::INT AS author_id,
    data->>'first_name' AS first_name,
    data->>'last_name' AS last_name,
    data->>'pseudonym' AS pseudonym,
    (data->>'birthday')::DATE AS birthday
FROM temp_authors;

SELECT * FROM new_Authors;




-- 3. Создать таблицу, в которой будет атрибут(-ы) с типом JSON, или добавить атрибут с типом JSON к уже существующей таблице.
-- Заполнить атрибут правдоподобными данными с помощью команд INSERT или UPDATE.

CREATE TABLE IF NOT EXISTS new_Authors_json
(
    data json
);

INSERT INTO new_Authors_json (data)
VALUES
    (json_object('{author_id, first_name, last_name}', '{1, "Jonny", "Depp"}')),
    (json_object('{author_id, first_name, last_name}', '{2, "John", "Doe"}')),
    (json_object('{author_id, first_name, last_name}', '{3, "Anna", "Smith"}'));


SELECT * FROM new_Authors_json;




-- 4. Выполнить следующие действия:

-- -- 1. Извлечь XML/JSON фрагмент из XML/JSON документа

-- создаётся временная таблица для  хранения данных из JSON, чтобы выполнить преобразования
CREATE TEMP TABLE IF NOT exists temp_Authors
(
	data JSONB
);

-- импорт JSON-данных в эту таблицу
COPY temp_Authors(data) FROM '/tmp/Authors.json';

-- преобразуем данные
SELECT
    (data->>'author_id')::INT AS author_id,
    data->>'first_name' AS first_name,
    data->>'last_name' AS last_name,
    data->>'pseudonym' AS pseudonym,
    (data->>'birthday')::DATE AS birthday
FROM temp_authors
WHERE TRIM(data->>'first_name') LIKE 'D%'
limit 10;



-- -- 2. Извлечь значения конкретных узлов или атрибутов XML/JSON документа

-- создаётся временная таблица для  хранения данных из JSON, чтобы выполнить преобразования
CREATE TEMP TABLE IF NOT exists temp_Authors
(
	data JSONB
);

-- импорт JSON-данных в эту таблицу
COPY temp_Authors(data) FROM '/tmp/Authors.json';

-- преобразуем данные
SELECT
    (data->>'author_id')::INT AS author_id,
    data->>'first_name' AS first_name,
    data->>'last_name' AS last_name,
    data->>'pseudonym' AS pseudonym,
    (data->>'birthday')::DATE AS birthday
FROM temp_authors;



-- -- 3. Выполнить проверку существования узла или атрибута

-- создаётся временная таблица для  хранения данных из JSON, чтобы выполнить преобразования
CREATE TEMP TABLE IF NOT exists temp_Authors
(
	data JSONB
);

-- импорт JSON-данных в эту таблицу
COPY temp_Authors(data) FROM '/tmp/Authors.json';

-- преобразуем данные
SELECT
    (data->>'author_id')::INT AS author_id,
    data->>'first_name' AS first_name,
    data->>'last_name' AS last_name,
    data->>'pseudonym' AS pseudonym,
    (data->>'birthday')::DATE AS birthday
FROM temp_authors;

-- список всех ключей в таблице
SELECT DISTINCT jsonb_object_keys(data) AS key
FROM temp_authors;

-- вернёт все строки, где ключ first_name существует в JSON-объекте
SELECT *
FROM temp_authors
WHERE data ? 'first_name';

-- вернёт все строки, где оба ключа 'first_name' и 'last_name' существуют
SELECT *
FROM temp_authors
WHERE data ?& ARRAY['first_name', 'last_name'];

-- вернёт все строки, где хотя бы один из ключей 'first_name' или 'some_name' существует
SELECT *
FROM temp_authors
WHERE data ?| ARRAY['first_name', 'some_name'];




-- -- 4. Изменить XML/JSON документ

CREATE TEMP TABLE IF NOT exists temp_Authors
(
	data JSONB
);

-- импорт JSON-данных в эту таблицу
COPY temp_Authors(data) FROM '/tmp/Authors.json';

-- выводим данные
SELECT
    (data->>'author_id')::INT AS author_id,
    data->>'first_name' AS first_name,
    data->>'last_name' AS last_name,
    data->>'pseudonym' AS pseudonym,
    (data->>'birthday')::DATE AS birthday
FROM temp_Authors;

-- обновим все id таблицы на id + 1
UPDATE temp_Authors
SET data = jsonb_set(
    data,
    '{author_id}',
    ((data->>'author_id')::INT + 1)::TEXT::JSONB
);

-- выводим данные
SELECT
    (data->>'author_id')::INT AS author_id,
    data->>'first_name' AS first_name,
    data->>'last_name' AS last_name,
    data->>'pseudonym' AS pseudonym,
    (data->>'birthday')::DATE AS birthday
FROM temp_Authors;

-- данные из временной обновлённой таблицы с авторами копируются в файл
COPY temp_Authors(data)
TO '/tmp/Authors.json';


-- -- 5. Разделить XML/JSON документ на несколько строк по узлам

CREATE TEMP TABLE IF NOT exists arr_temp_Authors
(
	data JSONB
);

-- запись JSON-данных в эту таблицу
INSERT INTO arr_temp_Authors VALUES ('[{"author_id": 0, "first_name": "Igor", "last_name": "Fisher"},
  								  	 {"author_id": 1, "first_name": "Oleg", "last_name": "Winter"}, 
								  	 {"author_id": 2, "first_name": "Pavel", "last_name": "Skaut"}]');


-- выводим данные построчно
SELECT jsonb_array_elements(data::jsonb) AS result
FROM arr_temp_Authors;




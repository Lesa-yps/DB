-- 2. Выполнить запрос с несколькими соединениями (JOIN)
-- книги + читатели
COPY (
    SELECT B.book_id, B.title, R.reader_id, R.first_name, R.last_name
    FROM (Books B JOIN Rentals RL on B.book_id = RL.book_id) JOIN Readers R on RL.reader_id = R.reader_id
) TO '/tmp/2.csv' WITH CSV HEADER;

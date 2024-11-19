Это написано под мою Винду. Что делать, чтоб работало на Линуксе:

1) меняй содержимое config.py на config_Linux.py

2) пункт 3 меню работать не будет, как скопировать данные через 1 место:

1.1) в терминале:

Копировать все файлы .csv в директорию /tmp/, чтобы PostgreSQL имел к ним доступ.

sudo cp /home/olesya/Learn/DB/lab_01/test_data/authors.csv /tmp/
sudo cp /home/olesya/Learn/DB/lab_01/test_data/books.csv /tmp/
sudo cp /home/olesya/Learn/DB/lab_01/test_data/readers.csv /tmp/
sudo cp /home/olesya/Learn/DB/lab_01/test_data/rentals.csv /tmp/

1.2) в терминале:

sudo -i -u postgres

postgres@olesya-BRN-GXXX:~$ psql -U postgres -d DB_Litres
psql (16.4 (Ubuntu 16.4-0ubuntu0.24.04.2))
Type "help" for help.

DB_Litres=# \copy Authors (author_id, first_name, last_name, pseudonym, birthday) FROM '/tmp/authors.csv' DELIMITER ',' CSV HEADER;
COPY 999
DB_Litres=# \copy Books (book_id, title, genre, author_id, publish_year) FROM '/tmp/books.csv' DELIMITER ',' CSV HEADER;
/tmp/books.csv: Нет такого файла или каталога
DB_Litres=# \copy Books (book_id, title, genre, author_id, publish_year) FROM '/tmp/books.csv' DELIMITER ',' CSV HEADER;
COPY 999
DB_Litres=# \copy Readers (reader_id, first_name, last_name, email, registration_date) FROM '/tmp/readers.csv' DELIMITER ',' CSV HEADER;
COPY 999
DB_Litres=# \copy Rentals (rental_id, book_id, reader_id, take_date, return_date) FROM '/tmp/rentals.csv' DELIMITER ',' CSV HEADER;
COPY 999

DB_Litres=# exit

postgres@olesya-BRN-GXXX:~$ exit


1.3) Перезапустить службу PostgreSQL (для того чтобы изменения вступили в силу) (тоже в терминале):

sudo systemctl restart postgresql
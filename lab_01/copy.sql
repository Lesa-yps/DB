-- Authors table
COPY Authors (author_id, first_name, last_name, pseudonym, birthday)
FROM 'L:\sem_5\DB\lab_01\test_data\authors.csv'
DELIMITER ','
CSV;

-- Books table
COPY Books (book_id, title, genre, author_id, publish_year)
FROM 'L:\sem_5\DB\lab_01\test_data\books.csv'
DELIMITER ','
CSV;

-- Readers table
COPY Readers (reader_id, first_name, last_name, email, registration_date)
FROM 'L:\sem_5\DB\lab_01\test_data\readers.csv'
DELIMITER ','
CSV;

-- Rentals table
COPY Rentals (rental_id, book_id, author_id, reader_id, take_date, return_date)
FROM 'L:\sem_5\DB\lab_01\test_data\rentals.csv'
DELIMITER ','
CSV;
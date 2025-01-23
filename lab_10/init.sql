DROP TABLE IF EXISTS Rentals;
DROP TABLE IF EXISTS Books;
DROP TABLE IF EXISTS Authors;
DROP TABLE IF EXISTS Readers;

CREATE TABLE Authors
(
    author_id INT,
    first_name VARCHAR(225),
    last_name VARCHAR(225),
    pseudonym VARCHAR(225),
    birthday DATE
);

CREATE TABLE Books
(
    book_id INT,
    title VARCHAR(225),
    genre VARCHAR(225),
    author_id INT,
    publish_year INT
);

CREATE TABLE Readers
(
    reader_id INT,
    first_name VARCHAR(225),
    last_name VARCHAR(225),
    email VARCHAR(225),
    registration_date DATE
);

CREATE TABLE Rentals
(
    rental_id INT,
    book_id INT,
    reader_id INT,
    take_date DATE,
    return_date DATE
);


ALTER TABLE Authors
ADD CONSTRAINT PK_Authors PRIMARY KEY (author_id),
ALTER COLUMN first_name SET NOT NULL,
ALTER COLUMN last_name SET NOT NULL,
ADD CONSTRAINT CHK_Authors_Birthday CHECK (birthday <= CURRENT_DATE);

ALTER TABLE Books
ADD CONSTRAINT PK_Books PRIMARY KEY (book_id),
ADD CONSTRAINT FK_Books_Author FOREIGN KEY (author_id) REFERENCES Authors(author_id) 
ON DELETE CASCADE ON UPDATE CASCADE,
ALTER COLUMN title SET NOT NULL,
ADD CONSTRAINT CHK_Books_Publish_Year CHECK (publish_year >= 0 AND publish_year <= EXTRACT(YEAR FROM CURRENT_DATE));

ALTER TABLE Readers
ADD CONSTRAINT PK_Readers PRIMARY KEY (reader_id),
ALTER COLUMN first_name SET NOT NULL,
ALTER COLUMN last_name SET NOT NULL,
ADD CONSTRAINT UNQ_Readers_Email UNIQUE (email),
ADD CONSTRAINT CHK_Readers_Email_Format CHECK (email LIKE '%@%.%'),
ADD CONSTRAINT CHK_Readers_Registration CHECK (registration_date <= CURRENT_DATE);

ALTER TABLE Rentals
ADD CONSTRAINT PK_Rentals PRIMARY KEY (rental_id),
ADD CONSTRAINT FK_Rentals_Book FOREIGN KEY (book_id) REFERENCES Books(book_id) 
ON DELETE CASCADE ON UPDATE CASCADE,
ADD CONSTRAINT FK_Rentals_Reader FOREIGN KEY (reader_id) REFERENCES Readers(reader_id) 
ON DELETE CASCADE ON UPDATE CASCADE,
ADD CONSTRAINT CHK_Rentals_Return_Date CHECK (return_date >= take_date),
ADD CONSTRAINT CHK_Rentals_Take_Date CHECK (take_date <= CURRENT_DATE);


COPY Authors (author_id, first_name, last_name, pseudonym, birthday)
FROM '/docker-entrypoint-initdb.d/test_data/authors.csv'
DELIMITER ','
CSV;

COPY Books (book_id, title, genre, author_id, publish_year)
FROM '/docker-entrypoint-initdb.d/test_data/books.csv'
DELIMITER ','
CSV;

COPY Readers (reader_id, first_name, last_name, email, registration_date)
FROM '/docker-entrypoint-initdb.d/test_data/readers.csv'
DELIMITER ','
CSV;

COPY Rentals (rental_id, book_id, reader_id, take_date, return_date)
FROM '/docker-entrypoint-initdb.d/test_data/rentals.csv'
DELIMITER ','
CSV;
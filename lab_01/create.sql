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
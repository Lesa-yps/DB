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
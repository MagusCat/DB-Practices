USE BookStore;

-- Insert Authors
INSERT INTO Author (FirstName, LastName, BirthDate) VALUES ('John', 'Doe', '1975-06-15');
INSERT INTO Author (FirstName, LastName, BirthDate) VALUES ('Jane', 'Smith', '1982-12-22');
INSERT INTO Author (FirstName, LastName, BirthDate) VALUES ('Alice', 'Johnson', '1990-03-10');

-- Insert Genres
INSERT INTO Genre (Name) VALUES ('Fiction');
INSERT INTO Genre (Name) VALUES ('Science Fiction');
INSERT INTO Genre (Name) VALUES ('Fantasy');

-- Insert Books
INSERT INTO Book (Title, Price, AuthorId) VALUES ('The Great Adventure', 19.99, 1);
INSERT INTO Book (Title, Price, AuthorId) VALUES ('Space Odyssey', 24.99, 2);
INSERT INTO Book (Title, Price, AuthorId) VALUES ('Magical Realms', 29.99, 3);

-- Link Books to Genres
EXEC AddGenreBook @BookId = 1, @GenreId = 1; -- 'The Great Adventure' is Fiction
EXEC AddGenreBook @BookId = 2, @GenreId = 2; -- 'Space Odyssey' is Science Fiction
EXEC AddGenreBook @BookId = 3, @GenreId = 3; -- 'Magical Realms' is Fantasy

-- Register Sales
EXEC ResgisterSale @BookId = 1, @Quantity = 3; -- Sold 3 copies of 'The Great Adventure'
EXEC ResgisterSale @BookId = 2, @Quantity = 2; -- Sold 2 copies of 'Space Odyssey'
EXEC ResgisterSale @BookId = 3, @Quantity = 5, @DateSale = '2024-08-15'; -- Sold 5 copies of 'Magical Realms'

-- Report Book
EXEC ReportBook @BookId = 3, @StartDate = '2024-01-01', @EndDate = '2024-12-01';

-- Add Author
EXEC AddAuthor @FirstName = 'John', @LastName = 'Doe', @BirthDate = '2000-01-06';

SELECT * FROM Author;

-- Add Book
EXEC AddBook @Title = 'John Doe - Last Life', @Price = 30.5, @AuthorId = 4;

-- Genre
EXEC AddGenreBook @BookId = 4, @GenreId = 1; -- 'The Great Adventure' is Fiction


-- Delet Book
EXEC DeleteBook @BookId = 4;

-- Restore
EXEC RestoreBook @BookId = 4;
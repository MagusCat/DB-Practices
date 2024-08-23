USE master;
GO

DROP DATABASE IF EXISTS BookStore;
GO

CREATE DATABASE BookStore;
GO

USE BookStore;
GO

CREATE TABLE Author (
        AuthorId int identity(1,1) primary key,
        FirstName varchar(50),
        LastName varchar(50),
        BirthDate datetime
);
GO

CREATE TABLE Genre 
(
        GenreId int identity(1,1) primary key,
        Name varchar(50) unique
);
GO

CREATE TABLE Book 
(
        BookId int identity(1,1) primary key,
        Title varchar(120),
        Price float,
        AuthorId int foreign key references Author(AuthorId),
        Deleted bit default(0)
);
GO

CREATE TABLE BookGenre 
(
        BookGenreId int identity(1,1) primary key,
        BookId int foreign key references Book(BookId),
        GenreId int foreign key references Genre(GenreId)
);
GO

CREATE TABLE Sale 
(
        SaleId int identity(1,1) primary key,
        BookId int foreign key references Book(BookId),
        SaleDate datetime default(GetDate()),
        Quantity int default(0),
        TotalAmount float
);
GO

/* PROCEDURES */

CREATE PROC ResgisterSale
        @BookId  int, 
        @Quantity int,
        @DateSale datetime = null
AS
BEGIN
        SET NOCOUNT ON;
        
        if NOT EXISTS (SELECT BookId FROM Book WHERE Book.BookId = @BookId AND Book.Deleted = 0)
        BEGIN
                RAISERROR('The book dosent exist',1,1);
                RETURN;
        END
        
        if @Quantity <= 0 
        BEGIN
                RAISERROR('The Quantity is not valid',1,1);
                RETURN;
        END
        
        SET @DateSale = ISNULL(@DateSale, GETDATE());
        DECLARE @Total float = @Quantity * (SELECT Price FROM Book WHERE Book.BookId = @BookId);
        
        INSERT INTO Sale (BookId, SaleDate, Quantity, TotalAmount) VALUES (@BookId, @DateSale, @Quantity, @Total);
END
GO

CREATE PROC AddAuthor
        @FirstName varchar(50),
        @LastName varchar(50),
        @BirthDate datetime
AS
BEGIN
        SET NOCOUNT ON;
        IF EXISTS (SELECT AuthorId FROM Author WHERE Author.FirstName = @FirstName AND Author.LastName = @LastName AND Author.BirthDate = @BirthDate)
        BEGIN
                RAISERROR('The Author already exists',1,1);
                RETURN;
        END
        
        INSERT INTO Author (FirstName, LastName, BirthDate) VALUES (@FirstName, @LastName, @BirthDate);
END
GO

CREATE PROC AddBook
        @Title varchar(120),
        @Price float,
        @AuthorId int
AS
BEGIN
        SET NOCOUNT ON;
        IF NOT EXISTS (SELECT AuthorId FROM Author WHERE Author.AuthorId = @AuthorId)
        BEGIN
                RAISERROR('The author does not exist',1,1);
                RETURN;
        END
        
        IF @Price <= 0
        BEGIN
                RAISERROR('The price must be greater than zero', 1, 1);
                RETURN;
        END
        
        INSERT INTO Book (Title, Price, AuthorId) VALUES (@Title, @Price, @AuthorId);
END
GO

CREATE PROC AddGenreBook
        @BookId  int,
        @GenreId int
AS
BEGIN
        SET NOCOUNT ON;
        
        if NOT EXISTS (SELECT BookId FROM Book WHERE Book.BookId = @BookId)
        BEGIN
                RAISERROR('The book dosent exist',1,1);
                RETURN;
        END
        
        if NOT EXISTS (SELECT GenreId FROM Genre WHERE Genre.GenreId = @GenreId)
        BEGIN
                RAISERROR('The genre dosent exist',1,1);
                RETURN;
        END
        
        if EXISTS (SELECT BookGenreId FROM BookGenre WHERE BookGenre.GenreId = @GenreId AND BookGenre.BookId = @BookId)
        BEGIN
                RAISERROR('The book already have the genre',1,1);
                RETURN;
        END
        
        INSERT INTO BookGenre (BookId, GenreId) VALUES (@BookId, @GenreId);
END
GO

CREATE PROC RemoveGenreBook
        @BookId  int,
        @GenreId int
AS
BEGIN
        SET NOCOUNT ON;
        
        if NOT EXISTS (SELECT BookId FROM Book WHERE Book.BookId = @BookId AND Book.Deleted = 0)
        BEGIN
                RAISERROR('The book dosent exist',1,1);
                RETURN;
        END
        
        if NOT EXISTS (SELECT GenreId FROM Genre WHERE Genre.GenreId = @GenreId)
        BEGIN
                RAISERROR('The genre dosent exist',1,1);
                RETURN;
        END
        
        if NOT EXISTS (SELECT BookGenreId FROM BookGenre WHERE BookGenre.GenreId = @GenreId AND BookGenre.BookId = @BookId)
        BEGIN
                RAISERROR('The book dont have the genre',1,1);
                RETURN;
        END
        
        DELETE BookGenre WHERE BookGenre.GenreId = @GenreId AND BookGenre.BookId = @BookId;
END
GO

CREATE PROC UpdateBookPrice
    @BookId int,
    @NewPrice float
AS
BEGIN
        SET NOCOUNT ON;
        IF NOT EXISTS (SELECT BookId FROM Book WHERE BookId = @BookId)
        BEGIN
                RAISERROR('The book does not exist', 1, 1);
                RETURN;
        END
    
        IF @NewPrice <= 0
        BEGIN
                RAISERROR('The new price must be greater than zero', 1, 1);
                RETURN;
        END
    
        UPDATE Book SET Price = @NewPrice WHERE BookId = @BookId;
END
GO

CREATE PROC DeleteBook
        @BookId  int
AS
BEGIN
        SET NOCOUNT ON;
        
        if NOT EXISTS (SELECT BookId FROM Book WHERE Book.BookId = @BookId AND Book.Deleted = 0)
        BEGIN
                RAISERROR('The book dosent exist',1,1);
                RETURN;
        END
        
        UPDATE Book SET Deleted = 1 WHERE Book.BookId = @BookId;
END
GO

CREATE PROC RestoreBook
        @BookId  int
AS
BEGIN
        SET NOCOUNT ON;
        
        if NOT EXISTS (SELECT BookId FROM Book WHERE Book.BookId = @BookId AND Book.Deleted = 1)
        BEGIN
                RAISERROR('The book dosent exist',1,1);
                RETURN;
        END
        
        UPDATE Book SET Deleted = 0 WHERE Book.BookId = @BookId;
END
GO

CREATE PROC ReportBook
    @BookId int,
    @StartDate datetime,
    @EndDate datetime
AS
BEGIN
        SET NOCOUNT ON;
        IF NOT EXISTS (SELECT BookId FROM Book WHERE BookId = @BookId)
        BEGIN
                RAISERROR('The book does not exist', 1, 1);
                RETURN;
        END
        
        IF @StartDate > @EndDate 
        BEGIN
                RAISERROR('The start date cannot be more old than end date', 1, 1);
                RETURN;
        END
    
        SELECT COUNT(*) as 'Total Sales', SUM(TotalAmount) as 'Total Sell', SUM(Quantity) as 'Total Sells books' FROM Sale WHERE Sale.BookId = @BookId AND Sale.SaleDate >= @StartDate AND Sale.SaleDate <= @EndDate;
END
GO
CREATE DATABASE MoviesApp
USE MoviesApp

CREATE TABLE Directors (
	Id INT PRIMARY KEY IDENTITY(1, 1),
	[Name] NVARCHAR(50),
	Surname NVARCHAR(50)
)

INSERT INTO Directors
VALUES
	('Christopher', 'Nolan'),
	('Steven', 'Spielberg'),
	('Quentin', 'Tarantino')

CREATE TABLE Languages (
	Id INT PRIMARY KEY IDENTITY(1, 1),
	[Name] NVARCHAR(50)
)

INSERT INTO Languages
VALUES
	('English'),
	('French'),
	('Spanish')

CREATE TABLE Movies (
	Id INT PRIMARY KEY IDENTITY(1, 1),
	[Name] NVARCHAR(50),
	[Description] NVARCHAR(255),
	CoverPhoto NVARCHAR(255),
	LanguageId INT,
	FOREIGN KEY(LanguageId) REFERENCES Languages(Id)
) 

INSERT INTO Movies
VALUES
	('Inception', 'A mind-bending thriller', 'inception.jpg', 1),
	('Jurassic Park', 'Dinosaurs run amok', 'jurassic_park.jpg', 2),
	('Pulp Fiction', 'Interwoven stories', 'pulp_fiction.jpg', 1)

CREATE TABLE Actors (
	Id INT PRIMARY KEY IDENTITY(1, 1),
	[Name] NVARCHAR(50),
	Surname NVARCHAR(50)
)

INSERT INTO Actors
VALUES
	('Leonardo', 'DiCaprio'),
	('Samuel L.', 'Jackson'),
	('Tom', 'Hanks')

CREATE TABLE Genres (
	Id INT PRIMARY KEY IDENTITY(1, 1),
	[Name] NVARCHAR(50)
)

INSERT INTO Genres
VALUES
	('Sci-Fi'),
	('Adventure'),
	('Drama')

CREATE TABLE DirectorsMovies (
	MovieId INT,
	DirectorId INT,
	FOREIGN KEY(MovieId) REFERENCES Movies(Id),
	FOREIGN KEY(DirectorId) REFERENCES Directors(Id)
)

INSERT INTO DirectorsMovies
VALUES
	(1, 1),
	(2, 2),
	(3, 3)

CREATE TABLE MoviesActors (
	MovieId INT,
	ActorId INT,
	FOREIGN KEY(MovieId) REFERENCES Movies(Id),
	FOREIGN KEY(ActorId) REFERENCES Actors(Id)
)

INSERT INTO MoviesActors
VALUES 
	(1, 1),
	(2, 3),
	(3, 2)

CREATE TABLE MoviesGenres (
	MovieId INT,
	GenreId INT,
	FOREIGN KEY(MovieId) REFERENCES Movies(Id),
	FOREIGN KEY(GenreId) REFERENCES Genres(Id)
)

INSERT INTO MoviesGenres
VALUES 
	(1, 1),
	(2, 2),
	(3, 3)



CREATE OR ALTER PROCEDURE GetFilmsOfDirector @directorId INT
AS
BEGIN
	SELECT m.Name AS MovieName, l.Name AS [Language]
	FROM Movies m
	JOIN Languages l ON m.LanguageId = l.Id
	JOIN DirectorsMovies dm ON m.Id = dm.MovieId
	WHERE dm.DirectorId = @directorId
END

EXEC GetFilmsOfDirector 4



CREATE FUNCTION GetCountOfMoviesByLanguage (@languageId INT)
RETURNS INT
BEGIN
	DECLARE @count INT
	SELECT @count = COUNT(*) FROM Movies m
	WHERE m.LanguageId = @languageId
	RETURN @count
END

SELECT dbo.GetCountOfMoviesByLanguage(1) 
SELECT dbo.GetCountOfMoviesByLanguage(2)
SELECT dbo.GetCountOfMoviesByLanguage(3) 




CREATE PROCEDURE GetMoviesByGenre @genreId INT
AS
BEGIN 
	SELECT m.Name AS MovieName, d.Name AS DirectorName, d.Surname AS DirectorSurname
	FROM Movies m
	JOIN MoviesGenres mg ON m.Id = mg.MovieId
	JOIN DirectorsMovies dm ON dm.MovieId = m.Id
	JOIN Directors d ON dm.DirectorId = d.Id
	WHERE mg.GenreId = @genreId
END

EXEC GetMoviesByGenre 1
EXEC GetMoviesByGenre 2
EXEC GetMoviesByGenre 3



CREATE FUNCTION HasActorMoreThanThreeMovies (@actorId INT)
RETURNS BIT
BEGIN
	DECLARE @count INT
	DECLARE @result BIT
	SELECT @count = COUNT(*) FROM MoviesActors
	WHERE ActorId = @actorId
	IF @count > 3
		SET @result = 1
	ELSE
		SET @result = 0
	
	RETURN @result
END

SELECT dbo.HasActorMoreThanThreeMovies(1)


INSERT INTO Movies
VALUES
	('Movie2', 'Movie2Description', 'Movie2CoverPhoto', 2),
	('Movie1', 'Movie1Description', 'Movie1CoverPhoto', 3)

CREATE OR ALTER TRIGGER GetMoviesAfterInsert ON Movies
AFTER INSERT 
AS
BEGIN
	SELECT m.Name AS MovieName, d.Name AS DirectorName, d.Surname AS DirectorSurname, l.Name AS [Language]
	FROM Movies m
	JOIN DirectorsMovies dm ON dm.MovieId = m.Id
	JOIN Directors d ON d.Id = dm.DirectorId
	JOIN Languages l ON l.Id = m.LanguageId
END


CREATE TABLE Groups (
	Id INT PRIMARY KEY IDENTITY(1, 1),
	[Name] NVARCHAR(50),
	Limit INT,
	BeginDate DATE,
	EndDate DATE
)


INSERT INTO Groups
VALUES 
	('Group C', 2, '2024-01-01', '2024-12-31'),
	('Group A', 30, '2024-01-01', '2024-12-31'),
	('Group B', 25, '2024-01-01', '2024-12-31')


CREATE TABLE Students (
	Id INT PRIMARY KEY IDENTITY(1, 1),
	[Name] NVARCHAR(50),
	Surname NVARCHAR(50),
	Email NVARCHAR(50),
	PhoneNumber NVARCHAR(50),
	BirthDate DATE,
	GPA DECIMAL
)

INSERT INTO Students
VALUES 
	('John', 'Doe', 'john.doe@example.com', '555-1234', '2005-05-15', 3.5),
	('Jane', 'Smith', 'jane.smith@example.com', '555-5678', '2004-08-22', 3.8),
	('Alice', 'Johnson', 'alice.johnson@example.com', '555-8765', '2003-11-30', 3.7),
	('Michael', 'Brown', 'michael.brown@example.com', '555-4321', '2005-07-14', 3.9),
	('Emily', 'Davis', 'emily.davis@example.com', '555-9876', '2003-09-10', 3.6),
	('David', 'Wilson', 'david.wilson@example.com', '555-1239', '2004-04-18', 3.4),
	('Sarah', 'Taylor', 'sarah.taylor@example.com', '555-6543', '2005-12-12', 3.7)

CREATE TABLE GroupsStudents (
	GroupId INT,
	StudentId INT,
	FOREIGN KEY (GroupId) REFERENCES Groups(Id),
	FOREIGN KEY (StudentId) REFERENCES Students(Id)
)

INSERT INTO GroupsStudents
VALUES
	(2, 4),
	(2, 3),
	(2, 2),
	(2, 1),
	(1, 3),
	(1, 1),
	(1, 2)

--a. Bir trigger yazilmalidir, hansi ki student elave olunan zaman qrupun limitin yoxlamalidir eger qrupda 
--limitli sayda telebe varsa elave etmemelidir, eks halda etmelidir

CREATE TRIGGER AddStudentToGroup ON GroupsStudents
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @Id INT
	DECLARE @Limit INT
	DECLARE @Count INT

	SELECT @Id = inserted.GroupId FROM inserted
	SELECT @Limit = [Limit] FROM [Groups] WHERE Id = @Id
	SELECT @Count = COUNT(*) FROM GroupsStudents WHERE GroupId = @Id

	IF @Count < @Limit
	BEGIN 
		INSERT INTO GroupsStudents
		SELECT StudentId, GroupId FROM inserted
	END
	ELSE
	BEGIN
		RAISERROR ('Group is full', 1, 1)
	END
END
 
 --b. Bir trigger yazilmalidir, hansi ki o studentin yasinin 16dan cox oldugunu yoxlamalidir, eger boyukdurse elave etmelidir, eks halda ise yox

CREATE TRIGGER CheckAgeThenAddGroup ON Students
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @todaysDate DATE = GETDATE()
	DECLARE @birthDate DATE
	DECLARE @age INT

	SELECT @birthDate = BirthDate FROM inserted
	SET @age = DATEDIFF(YEAR, @birthDate, @todaysDate)
	IF @age > 16
	BEGIN
		INSERT INTO Students
		SELECT Name, Surname, Email, PhoneNumber, BirthDate, GPA FROM inserted
	END
	ELSE
	BEGIN
		RAISERROR('Student is not suitable', 1, 1)
	END
END

INSERT INTO Students
VALUES
	('StudentName1', 'StudentSurname1', 'gmail1@gmail.com', '000000000', '2003-01-01', 4.6)

--c. Bir funksiya yazilmalidir, hansi ki o groupId parametr qebul edir ve qrupun ortalama gpa qaytarir

CREATE FUNCTION ShowAverageGPAOfGroup (@groupId INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
	DECLARE @average DECIMAL(10, 2)

	SELECT @average = AVG(s.GPA)
	FROM Students s
	JOIN GroupsStudents gs ON gs.StudentId = s.Id
	WHERE gs.GroupId = @groupId

	RETURN @average
END

SELECT dbo.ShowAverageGPAOfGroup(1)
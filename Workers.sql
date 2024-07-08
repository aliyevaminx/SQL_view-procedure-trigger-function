CREATE TABLE Departments (
	Id INT PRIMARY KEY IDENTITY(1, 1),
	[Name] NVARCHAR(50)
)

INSERT INTO Departments
VALUES 
	('Department1'), 
	('Department2'), 
	('Department3')

CREATE TABLE Positions (
	Id INT PRIMARY KEY IDENTITY(1, 1),
	[Name] NVARCHAR(50),
	Limit INT
)

INSERT INTO Positions
VALUES 
	('Position1', 2), 
	('Position2', 5), 
	('Position3', 3)

CREATE TABLE Workers (
	Id INT PRIMARY KEY IDENTITY(1, 1),
	[Name] NVARCHAR(50),
	Surname NVARCHAR(50),
	PhoneNumber NVARCHAR(50),
	Salary DECIMAL,
	BirthDate DATE,
	DepartmentId INT,
	PositionId INT,
	FOREIGN KEY(DepartmentId) REFERENCES Departments(Id),
	FOREIGN KEY(PositionId) REFERENCES Positions(Id)
)

INSERT INTO Workers
VALUES
	('Frank', 'Johnson', '555-9685', 85000, '1994-05-13', 2, 1),
    ('Alice', 'Smith', '555-1234', 50000, '1990-05-15', 2, 1),
    ('Bob', 'Johnson', '555-5678', 60000, '1985-08-25', 2, 1),
    ('David', 'Williams', '555-4321', 70000, '1988-02-20', 1, 3),
	('Frank', 'Miller', '555-6543', 68000, '1992-11-30', 1, 3)

--a. Departamente gore iscilerin orta emek haqqisini getiren bir function yazilmalidir

CREATE FUNCTION GetWorkersAverageSalaryForDepartment (@departmentId INT)
RETURNS DECIMAL (18, 2)
BEGIN 
	DECLARE @average DECIMAL(18, 2)

	SELECT @average = AVG(Salary)
	FROM Workers 
	WHERE DepartmentId = @departmentId
	RETURN @average
END

SELECT dbo.GetWorkersAverageSalaryForDepartment(2)

--b. Isci elave olunarken yasi check olunmalidir, 18den kicikdirse elave olunmamalidir, eks halda ise olunmalidir
CREATE OR ALTER TRIGGER CheckWorkersAgeThenAdd ON Workers
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @birthDate DATE
	DECLARE @todaysDate DATE = GETDATE()
	DECLARE @age INT

	SELECT @birthDate = BirthDate FROM inserted
	SET @age = DATEDIFF(YEAR, @birthDate, @todaysDate)

	IF @age > 18
	BEGIN 
		INSERT INTO Workers
		SELECT Name, Surname, PhoneNumber, Salary, BirthDate, DepartmentId, PositionId FROM inserted
	END
	ELSE
	BEGIN
		RAISERROR('Worker is not suitable', 1, 1)
	END
END

INSERT INTO Workers
VALUES
	('WorkerName1', 'WorkerSurname1', '000000000', 1200, '2005-01-01', 1, 3 )

--c. Position-a isci elave olunanda limit yoxlanilmalidir, limitden azdirsa elave olunmalidir, eks halda ise yox

CREATE OR ALTER TRIGGER CheckLimitAndAddWorkerToPosition ON Workers
INSTEAD OF INSERT
AS
BEGIN 
	DECLARE @id INT
	DECLARE @limit INT
	DECLARE @count INT

	SELECT @id = PositionId FROM inserted

	SELECT @limit = [Limit] FROM Positions WHERE Id = @id

	IF @count < @limit
	BEGIN
		INSERT INTO Workers 
		SELECT Name, Surname, PhoneNumber, Salary, BirthDate, DepartmentId, PositionId FROM inserted
	END
	ELSE
	BEGIN
		RAISERROR('Position Limit is full', 1, 1)
	END
END
-- Create Database
CREATE DATABASE TechSolutionsDB;

-- Use the Database
USE TechSolutionsDB;

-- Create DEPARTMENT table
CREATE TABLE DEPARTMENT (
    DeptID INT PRIMARY KEY,
    DeptName VARCHAR(100) NOT NULL,
    Location VARCHAR(100)
);

-- Create EMPLOYEE table
CREATE TABLE EMPLOYEE (
    EmpID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Gender VARCHAR(10),
    Salary DECIMAL(10,2),
    HireDate DATE,
    DeptID INT,
    FOREIGN KEY (DeptID) REFERENCES DEPARTMENT(DeptID)
);

-- Create PROJECT table
CREATE TABLE PROJECT (
    ProjectID INT PRIMARY KEY,
    ProjectName VARCHAR(100),
    StartDate Date,
    EndDate DATE,
    Budget DECIMAL(12,2)
);

-- Works_On Table
CREATE TABLE Works_On (
    EmpID INT,
    ProjectID INT,
    HoursWorked INT,
    PRIMARY KEY (EmpID, ProjectID),
    FOREIGN KEY (EmpID) REFERENCES Employee(EmpID),
    FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID)
);

-- Insert into DEPARTMENT
INSERT INTO DEPARTMENT VALUES
(1, 'HR', 'New York'),
(2, 'IT', 'London'),
(3, 'Finance', 'Tokyo'),
(4, 'Marketing', 'Paris'),
(5, 'Operations', 'Berlin');

-- Insert into EMPLOYEE
INSERT INTO EMPLOYEE VALUES
(101, 'John', 'Smith', 'Male', 45000, '2020-05-10', 1),
(102, 'Emma', 'Brown', 'Female', 52000, '2019-03-15', 2),
(103, 'Michael', 'Johnson', 'Male', 60000, '2021-07-01', 3),
(104, 'Sophia', 'Davis', 'Female', 48000, '2022-01-20', 4),
(105, 'David', 'Wilson', 'Male', 70000, '2018-11-30', 2);

-- Insert into PROJECT
INSERT INTO PROJECT VALUES
(1, 'Website Development', '2026-12-31', 100000),
(2, 'Mobile App', '2026-10-15', 80000),
(3, 'AI System', '2027-05-20', 150000),
(4, 'Database Upgrade', '2026-08-01', 60000),
(5, 'Cloud Migration', '2026-09-30', 120000);

UPDATE EMPLOYEE
SET Salary = Salary * 1.10
WHERE EmpID = 102;

DELETE FROM PROJECT
WHERE ProjectID = 5;

SELECT *
FROM EMPLOYEE
WHERE Salary > 50000;

SELECT FirstName, LastName, Salary
FROM EMPLOYEE
ORDER BY Salary DESC;

SELECT E.FirstName, E.LastName, D.DeptName
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DeptID = D.DeptID
WHERE D.DeptName = 'IT';

SELECT D.DeptName, COUNT(E.EmpID) AS TotalEmployees
FROM DEPARTMENT D
LEFT JOIN EMPLOYEE E ON D.DeptID = E.DeptID
GROUP BY D.DeptName;

SELECT *
FROM EMPLOYEE
WHERE HireDate > '2022-01-01';

SELECT E.FirstName, E.LastName, D.DeptName
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DeptID = D.DeptID;

CREATE TABLE EMPLOYEE_PROJECT (
    EmpID INT,
    ProjectID INT,
    PRIMARY KEY (EmpID, ProjectID),
    FOREIGN KEY (EmpID) REFERENCES EMPLOYEE(EmpID),
    FOREIGN KEY (ProjectID) REFERENCES PROJECT(ProjectID)
);

INSERT INTO EMPLOYEE_PROJECT VALUES
(101,1),
(102,2),
(103,3),
(104,4),
(105,1);

SELECT E.FirstName, E.LastName, P.ProjectName
FROM EMPLOYEE E
JOIN EMPLOYEE_PROJECT EP ON E.EmpID = EP.EmpID
JOIN PROJECT P ON EP.ProjectID = P.ProjectID;

SELECT e.FirstName, e.LastName, p.ProjectName
FROM Employee e
JOIN Works_On w ON e.EmpID = w.EmpID
JOIN Project p ON w.ProjectID = p.ProjectID;


SELECT p.ProjectName, SUM(w.HoursWorked) AS TotalHours
FROM Project p
JOIN Works_On w ON p.ProjectID = w.ProjectID
GROUP BY p.ProjectName;


-- part e
SELECT DeptID, AVG(Salary) AS AverageSalary
FROM Employee
GROUP BY DeptID;

SELECT DeptID, COUNT(*) AS TotalEmployees
FROM Employee
GROUP BY DeptID
ORDER BY TotalEmployees DESC
LIMIT 1;

SELECT FirstName, LastName, Salary
FROM Employee
WHERE Salary > (
    SELECT AVG(Salary)
    FROM Employee
);

CREATE VIEW HighSalaryEmployees AS
SELECT *
FROM EMPLOYEE
WHERE Salary > 600000;

SELECT * FROM HighSalaryEmployees;

CREATE INDEX idx_lastname
ON EMPLOYEE(LastName);


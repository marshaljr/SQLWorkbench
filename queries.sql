-- 1. Oracle does not use SHOW DATABASES or USE
-- Tables are created inside the current schema.

-- 2. Create employee table
CREATE TABLE employee (
    EmployeeID VARCHAR2(20) PRIMARY KEY NOT NULL,
    FirstName VARCHAR2(20),
    LastName VARCHAR2(20),
    Gender CHAR(1),
    DateofBirth DATE,
    Designation VARCHAR2(50),
    DepartmentName VARCHAR2(20),
    ManagerId VARCHAR2(20),
    JoinedDate DATE,
    Salary NUMBER(10)
);

-- 3. Insert employee records
INSERT INTO employee VALUES (
'0012','Season','Maharjan','M',
DATE '1996-04-02',
'Engineer',
'Software Management',
'0005',
DATE '2022-04-02',
5000000
);

INSERT INTO employee VALUES (
'0011','Ramesh','Rai','M',
DATE '2000-04-02',
'Manager',
'Software Management',
'0003',
DATE '2022-04-02',
1000000
);

-- Display table
SELECT * FROM employee;

-- 4. Update gender of employee
UPDATE employee
SET Gender = 'M'
WHERE EmployeeID = '003';

-- 5. Display employees older than 25
SELECT
FirstName,
SYSDATE AS CurrentDate,
DateofBirth,
FLOOR(MONTHS_BETWEEN(SYSDATE, DateofBirth)/12) AS Age
FROM employee
WHERE FLOOR(MONTHS_BETWEEN(SYSDATE, DateofBirth)/12) > 25;

-- 6. Find the oldest employee
SELECT *
FROM employee
WHERE DateofBirth = (
    SELECT MIN(DateofBirth) FROM employee
);

-- 7. Find the youngest employee
SELECT *
FROM employee
WHERE DateofBirth = (
    SELECT MAX(DateofBirth) FROM employee
);

-- 8. Maximum salary department-wise
SELECT DepartmentName, MAX(Salary) AS MaxSalary
FROM employee
GROUP BY DepartmentName;

-- 9. Employees who act as managers
SELECT FirstName
FROM employee
WHERE EmployeeID IN (
    SELECT ManagerID FROM employee
);

-- 10. Most recently joined employee
SELECT *
FROM employee
WHERE JoinedDate = (
    SELECT MAX(JoinedDate) FROM employee
);

Oracle does not use CREATE DATABASE or USE
Tables are created in the current schema

-- Create Department Table
CREATE TABLE DEPARTMENT(
    DNAME VARCHAR2(20),
    DNUMBER NUMBER PRIMARY KEY,
    MGRSSN VARCHAR2(15),
    MGRSTARTDATE DATE
);

-- Create Employee Table
CREATE TABLE EMPLOYEE(
    FNAME VARCHAR2(20),
    MINIT CHAR(1),
    LNAME VARCHAR2(20),
    SSN VARCHAR2(15) PRIMARY KEY,
    BDATE DATE,
    ADDRESS VARCHAR2(100),
    SEX CHAR(1),
    SALARY NUMBER,
    SUPERSSN VARCHAR2(15),
    DNO NUMBER,
    FOREIGN KEY (DNO) REFERENCES DEPARTMENT(DNUMBER)
);

-- Insert into Department
INSERT INTO DEPARTMENT VALUES
('Research',5,'333445555',DATE '1988-05-22');

INSERT INTO DEPARTMENT VALUES
('Administration',4,'987654321',DATE '1995-01-01');

INSERT INTO DEPARTMENT VALUES
('Headquarters',1,'888665555',DATE '1981-06-19');

-- Insert into Employee
INSERT INTO EMPLOYEE VALUES
('John','B','Smith','123456789',DATE '1965-01-09','Houston, TX','M',30000,'333445555',5);

INSERT INTO EMPLOYEE VALUES
('Franklin','T','Wong','333445555',DATE '1955-12-08','Houston, TX','M',40000,'888665555',5);

INSERT INTO EMPLOYEE VALUES
('Alicia','J','Zelaya','999887777',DATE '1968-01-19','Spring, TX','F',25000,'987654321',4);

INSERT INTO EMPLOYEE VALUES
('Jennifer','S','Wallace','987654321',DATE '1941-06-20','Bellaire, TX','F',43000,'888665555',4);

INSERT INTO EMPLOYEE VALUES
('Ramesh','K','Narayan','666884444',DATE '1962-09-15','Houston, TX','M',38000,'333445555',5);

INSERT INTO EMPLOYEE VALUES
('Joyce','A','English','453453453',DATE '1972-07-31','Houston, TX','F',25000,'333445555',5);

INSERT INTO EMPLOYEE VALUES
('Ahmad','V','Jabbar','987987987',DATE '1969-03-29','Houston, TX','M',25000,'987654321',4);

INSERT INTO EMPLOYEE VALUES
('James','E','Borg','888665555',DATE '1937-11-10','Houston, TX','M',55000,NULL,1);

SELECT E.FNAME, E.LNAME,
       E.SALARY * 1.1 AS increased_salary
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DNO = D.DNUMBER
WHERE D.DNAME = 'Research';

SELECT SUM(E.SALARY) AS Total,
       MAX(E.SALARY) AS Max,
       MIN(E.SALARY) AS Min,
       AVG(E.SALARY) AS Average
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DNO = D.DNUMBER
WHERE D.DNAME = 'Administration';

SELECT FNAME, LNAME, SSN, SUPERSSN, SALARY
FROM EMPLOYEE
WHERE DNO = 5;

SELECT FNAME, LNAME, SSN, SUPERSSN, SALARY
FROM EMPLOYEE
WHERE SUPERSSN = (
    SELECT MGRSSN
    FROM DEPARTMENT
    WHERE DNUMBER = 5
);

SELECT D.DNAME, D.DNUMBER, COUNT(E.SSN) AS total_employees
FROM DEPARTMENT D
JOIN EMPLOYEE E ON D.DNUMBER = E.DNO
GROUP BY D.DNAME, D.DNUMBER
HAVING COUNT(E.SSN) >= 2;

SELECT FNAME, LNAME
FROM EMPLOYEE
WHERE EXTRACT(YEAR FROM BDATE) BETWEEN 1950 AND 1999;

SELECT E.FNAME, E.LNAME, D.DNAME
FROM EMPLOYEE E
JOIN DEPARTMENT D
ON E.DNO = D.DNUMBER;
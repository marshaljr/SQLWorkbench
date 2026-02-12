show databases;
-- create database practise;
-- use practise;

CREATE TABLE departments (
    id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);

CREATE TABLE employees (
    id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department_id INT,  
        FOREIGN KEY (department_id) REFERENCES department(id));

INSERT INTO departments (id, department_name)
VALUES 
(1,'Sales'),
(2,'Engineering'),
(3,'Human Resources'),
(4,'Customer Service'),
(5,'Research and Development')
;

INSERT INTO employees (id,employee_name, department_id)
VALUES
(1,'Homer Simpson', 4),
(2,'Ned Flanders', 1),
(3,'Barney Gumble', 5),
(4,'Clancy Wiggum', 3),
(5,'Moe Szyslak', NULL);

SELECT 
   *
FROM employees e
INNER JOIN departments d
    ON e.department_id = d.id;
    
    
    SELECT 
  *
FROM employees e
LEFT JOIN departments d
    ON e.department_id = d.id;
    
    
    SELECT 
   *
FROM employees e
RIGHT JOIN departments d
    ON e.department_id = d.id;
    
    
  SELECT 
   *
FROM employees e
CROSS JOIN departments d;
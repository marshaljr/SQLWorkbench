#1.	Create a database named dbemp and switch to it.
show databases;
create database dbemp1;
use dbemp1;
#2.	Create an employee table with appropriate data types 
#and constraints for employee details.
create table employee(
		EmployeeID varchar(20) NOT NULL PRIMARY KEY,
        FirstName varchar(20),
        LastName varchar(20),
        Gender char(1),
        DateofBirth DATE,
        Designation varchar(50),
        DepartmentName varchar(20),
        ManagerId varchar(20),
        JoinedDate DATE,
        Salary decimal(10,0)
);
#3.	Insert at least two employee records into the employee table.
insert into employee (
EmployeeID,FirstName,LastName,Gender,DateofBirth,Designation,
DepartmentName,ManagerId,JoinedDate,Salary)
values (
'0012','Season','Maharjan','M','1996-04-02','Engineer',
'Software Management', '0005','2022-04-02','5000000'
),(
'0011','Ramesh','Rai','M','2000-04-02','Manager',
'Software Management', '0003','2022-04-02','1000000'
);
select * from employee;
#4.Update the gender of an employee whose EmployeeID is 001.
use dbemp1;
update employee 
set Gender = 'M'
where EmployeeID = '003';
#5Display the first name, current date,
#date of birth, and age of employees 
#who are older than 25 years.
select Firstname, CURDATE() as CurrentDate,
DateofBirth,
timestampdiff(YEAR, DateofBirth,CURDATE()) as Age
from employee where 
timestampdiff(YEAR,DateofBirth,CURDATE()) >25;
#6 Write a query to find the oldest employee.
select * from employee 
where 
DateofBirth = (select MIN(DateofBirth) 
from employee);
#7 youngest employee
select * from employee where 
DateofBirth = (select MAX(DateofBirth) 
from employee);
#8 Display the maximum salary department-wise.
select DepartmentName, Max(Salary) as MaxSalary
from employee Group by DepartmentName;
#9 List the employees who act as managers.
select * from employee;
select FirstName from employee where 
EmployeeID in (Select ManagerID from employee);
#10 Display the details of 
#the most recently joined employee.
select * from employee where
JoinedDate = 
(select Max(JoinedDate) from employee);
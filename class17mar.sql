DROP DATABASE IF EXISTS BankDB;

CREATE DATABASE BankDB;
USE BankDB;

CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    account_holder VARCHAR(50),
    balance INT
);

INSERT INTO accounts VALUES
(1, 'Ram', 50000),
(2, 'Shyam', 30000),
(3, 'Sita', 20000);

SELECT * FROM accounts;

START TRANSACTION;

UPDATE accounts
SET balance = balance - 5000
WHERE account_holder = 'Ram';

UPDATE accounts
SET balance = balance + 5000
WHERE account_holder = 'Shyam';

COMMIT;

SELECT * FROM accounts;

START TRANSACTION;

UPDATE accounts
SET balance = balance - 10000
WHERE account_holder = 'Shyam';

UPDATE accounts
SET balance = balance + 10000
WHERE account_holder = 'Sita';

ROLLBACK;

SELECT * FROM accounts;

START TRANSACTION;

UPDATE accounts
SET balance = balance - 2000
WHERE account_holder = 'Ram';

SAVEPOINT sp1;

UPDATE accounts
SET balance = balance + 2000
WHERE account_holder = 'Sita';

ROLLBACK TO sp1;

COMMIT;

SELECT * FROM accounts;


#Triggers
#1. Ceate a table employees with the
#fields: emp_id, name , salary 
create table employees (
emp_id int primary key,
name varchar(100),
salary decimal(10,2)
);

#2.Create another table salary_log to 
#record employee salary changes with 
#fields: log_id, emp_id,
#old_salary, new_salary, updated_at.
create table salary_log (
log_id int auto_increment primary key,
emp_id int,
old_salary decimal(10,2),
new_salary decimal(10,2),
updated_at timestamp default current_timestamp
);

#3.Create a BEFORE INSERT trigger on employees
#that prevents inserting employees whose
#salary is less than 10000.
Delimiter $$
create trigger check_salary
before insert on employees
for each row 
begin
if new.salary < 10000 then
signal sqlstate '45000'
set message_text = 'salary must be at least 10000';
end if;
end $$
Delimiter ;

#4Create an AFTER UPDATE trigger on employees 
#thar records salary changes into the
#salary_log table
Delimiter $$
create trigger log_salary_update
after update on employees
for each row 
begin
insert into salary_log(emp_id, old_salary, new_salary)
values(old.emp_id, old.salary, new.salary);
end $$
Delimiter ;

#stored procedure
#1. Create a stored procedure that retrieves all 
#records from the employees table.
Delimiter $$
create procedure getEmployees()
begin
select * from employees; 
end
$$
Delimiter ;
call getEmployees();

#2. Create a stored procedure that insert a
#new employee into the employees table using
#parameters
Delimiter $$
create procedure addEmployee(
in p_id int, in p_name varchar(100), in p_salary decimal(10,2)
)
begin 
insert into employees values(
p_id,p_name,p_salary
);
end
$$
Delimiter ;
call addEmployee(5, 'Hari', 20000);

#3. Create a stored procedure that updates the
#salary of an employee based on employee ID.
Delimiter $$
create procedure updateSalary(
in p_id int, in new_salary decimal(10,2))
begin
update employees
set salary = new_salary 
where emp_id = p_id;
end $$
Delimiter ;
call updateSalary(1, 30000);

#4. Create a stored procedure that transfer 
#money between two accounts using a transaction.
-- 4. Create a stored procedure that transfers money between two accounts.
DELIMITER $$
CREATE PROCEDURE transferMoney(
    IN p_sender_id INT,
    IN p_receiver_id INT,
    IN p_amount DECIMAL(10,2)
)
BEGIN
    -- Define custom messages for success and failure
    DECLARE rollback_message VARCHAR(255) DEFAULT 'Transaction rolled back: Insufficient funds';
    DECLARE commit_message   VARCHAR(255) DEFAULT 'Transaction committed successfully';
    -- Start transaction
    START TRANSACTION;
    -- Debit sender and credit receiver
    UPDATE accounts
    SET balance = balance - p_amount
    WHERE account_id = p_sender_id;

    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_receiver_id;
    -- Check if sender has enough balance; if not, roll back
    IF (SELECT balance FROM accounts WHERE account_id = p_sender_id) < 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = rollback_message;
    ELSE
        -- Record the transfer in a transactions log (optional)
        INSERT INTO transactions (account_id, amount, transaction_type)
            VALUES (p_sender_id, -p_amount, 'WITHDRAWAL');
        INSERT INTO transactions (account_id, amount, transaction_type)
            VALUES (p_receiver_id,  p_amount, 'DEPOSIT');
        -- Commit changes
        COMMIT;
        SELECT commit_message AS Result;
    END IF;
END$$
DELIMITER ;
CALL transferMoney(1, 2, 5000.00);


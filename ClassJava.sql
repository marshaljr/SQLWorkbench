CREATE DATABASE college;
USE college;

CREATE TABLE student(
  sid    INT,
  name   VARCHAR(50),
  pop    DOUBLE,
  cn     DOUBLE,
  db     DOUBLE,
  total  DOUBLE,
  average DOUBLE,
  result VARCHAR(10)
);

CREATE DATABASE logindb;
USE logindb;

CREATE TABLE users (
id INT AUTO_INCREMENT PRIMARY KEY,
username VARCHAR(50),
password VARCHAR(50)
);

INSERT INTO users(username,password) VALUES
('admin','admin123'),
('rohit','pass123'),
('student','abc123');

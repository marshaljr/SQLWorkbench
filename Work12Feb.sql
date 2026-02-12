-- 1) Create database and switch to it
DROP DATABASE IF EXISTS sample_db;
CREATE DATABASE sample_db;
USE sample_db;

-- 2) Create tables (parent first so FK can reference it)
CREATE TABLE customers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date DATE NOT NULL,
  total DECIMAL(10,2) DEFAULT 0.00,
  status VARCHAR(20) DEFAULT 'pending',
  notes TEXT,
  CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
    REFERENCES customers(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3) ALTER TABLE examples: add columns and constraints
ALTER TABLE customers ADD COLUMN phone VARCHAR(20) NULL;
ALTER TABLE orders ADD COLUMN shipping_address VARCHAR(255) NULL;

-- Add a simple CHECK (MySQL 8+ supports CHECK; older MySQL may ignore it)
ALTER TABLE orders ADD CONSTRAINT chk_total_nonneg CHECK (total >= 0);

-- 4) Create indexes
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_customers_email ON customers(email);

-- 5) Insert sample data
INSERT INTO customers (name, email, phone)
VALUES
 ('Alice Johnson','alice@example.com','+977-9800000001'),
 ('Bob Smith','bob@example.com','+977-9800000002'),
 ('Carol Lee','carol@example.com',NULL);

INSERT INTO orders (customer_id, order_date, total, status, notes, shipping_address)
VALUES
 (1, '2026-02-01', 120.50, 'completed', 'First order', 'Kathmandu'),
 (1, '2026-02-05', 45.00, 'shipped', 'Add gift wrap', 'Kathmandu'),
 (2, '2026-02-06', 89.99, 'pending', NULL, 'Biratnagar'),
 (3, '2026-02-07', 10.00, 'completed', 'Promo applied', 'Pokhara');

-- 6) SELECT basics
SELECT * FROM customers;
SELECT name, email FROM customers WHERE email LIKE '%@example.com' ORDER BY name;
SELECT DISTINCT status FROM orders;

-- 7) JOINs
-- INNER JOIN: customers with their orders (only customers having orders)
SELECT c.id AS customer_id, c.name, o.id AS order_id, o.total, o.order_date
FROM customers c
JOIN orders o ON c.id = o.customer_id
ORDER BY o.order_date;

-- LEFT JOIN: all customers, with orders if any
SELECT c.id, c.name, o.id AS order_id, o.total
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id;

-- RIGHT JOIN (returns all orders and matching customers; equivalent shown)
SELECT c.id, c.name, o.id AS order_id, o.total
FROM customers c
RIGHT JOIN orders o ON c.id = o.customer_id;

-- (MySQL does not support FULL OUTER JOIN directly. Use UNION of LEFT and RIGHT as workaround.)
-- FULL JOIN workaround:
SELECT c.id AS customer_id, c.name, o.id AS order_id
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
UNION
SELECT c.id AS customer_id, c.name, o.id AS order_id
FROM customers c
RIGHT JOIN orders o ON c.id = o.customer_id;

-- 8) Aggregates, GROUP BY, HAVING
-- Total spent per customer
SELECT c.id, c.name, COUNT(o.id) AS orders_count, SUM(o.total) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
HAVING total_spent > 0;

-- 9) Other predicates: IN, BETWEEN, EXISTS
SELECT * FROM orders WHERE customer_id IN (1,2);
SELECT * FROM orders WHERE order_date BETWEEN '2026-02-01' AND '2026-02-06';
SELECT * FROM customers c WHERE EXISTS (
  SELECT 1 FROM orders o WHERE o.customer_id = c.id AND o.total > 50
);

-- 10) UPDATE and DELETE
-- Update status for a single order
UPDATE orders SET status = 'delivered' WHERE id = 2;

-- Bulk update (e.g., apply 10% discount to pending orders)
UPDATE orders SET total = total * 0.9 WHERE status = 'pending';

-- Delete a single order
DELETE FROM orders WHERE id = 4;

-- Delete all orders for a customer (demonstrates cascade delete if FK set to ON DELETE CASCADE)
DELETE FROM customers WHERE id = 2; -- this will remove customer 2 and their orders

-- 11) Views
CREATE OR REPLACE VIEW vw_customer_summary AS
SELECT c.id AS customer_id, c.name, c.email,
       COUNT(o.id) AS orders_count,
       COALESCE(SUM(o.total),0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name, c.email;

-- Query the view
SELECT * FROM vw_customer_summary ORDER BY total_spent DESC;

-- 12) Stored procedure (MySQL) - create helper to add an order
DROP PROCEDURE IF EXISTS add_order;
DELIMITER $$
CREATE PROCEDURE add_order(IN p_customer_id INT, IN p_total DECIMAL(10,2))
BEGIN
  INSERT INTO orders (customer_id, order_date, total, status)
  VALUES (p_customer_id, CURDATE(), p_total, 'pending');
END $$
DELIMITER ;

-- Use the procedure
CALL add_order(1, 55.75);

-- 13) Transaction example (atomic operations)
START TRANSACTION;
  UPDATE customers SET phone = '+977-9850000000' WHERE id = 1;
  INSERT INTO orders (customer_id, order_date, total, status) VALUES (1, CURDATE(), 5.00, 'pending');
COMMIT;
-- if something goes wrong, use ROLLBACK instead of COMMIT

-- 14) Cleanup / reverse (DROP) - teardown in logical reverse order
-- Remove procedure and view first
DROP PROCEDURE IF EXISTS add_order;
DROP VIEW IF EXISTS vw_customer_summary;

-- Drop tables (orders first because it references customers)
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

-- Finally drop database
DROP DATABASE IF EXISTS sample_db;
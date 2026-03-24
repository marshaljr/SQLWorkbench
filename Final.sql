-- Create database
CREATE DATABASE aspire_fitness;
USE aspire_fitness;

-- Members
CREATE TABLE Member (
    MemberID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Address TEXT,
    Telephone VARCHAR(20),
    Email VARCHAR(100),
    DateOfBirth DATE,
    MedicalConditions TEXT,
    WeeklySubscription DECIMAL(5,2) NOT NULL DEFAULT 10.00,
    ExtraClassFee DECIMAL(5,2) NOT NULL DEFAULT 5.00
) ENGINE=InnoDB;

-- Staff
CREATE TABLE Staff (
    StaffID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Role VARCHAR(30) NOT NULL,
    PhoneNumber VARCHAR(20),
    CHECK (Role IN ('Trainer','Instructor','GymStaff','Manager','Administration'))
) ENGINE=InnoDB;

-- Facilities
CREATE TABLE Facility (
    FacilityID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL UNIQUE,
    Description TEXT,
    MaxCapacity INT NOT NULL
) ENGINE=InnoDB;

-- Activities
CREATE TABLE Activity (
    ActivityID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Activity-Facility mapping
CREATE TABLE ActivityFacility (
    ActivityFacilityID INT AUTO_INCREMENT PRIMARY KEY,
    ActivityID INT NOT NULL,
    FacilityID INT NOT NULL,
    FOREIGN KEY (ActivityID) REFERENCES Activity(ActivityID),
    FOREIGN KEY (FacilityID) REFERENCES Facility(FacilityID),
    UNIQUE (ActivityID, FacilityID)
) ENGINE=InnoDB;

-- Classes
CREATE TABLE Class (
    ClassID INT AUTO_INCREMENT PRIMARY KEY,
    ClassName VARCHAR(100) NOT NULL,
    InstructorID INT NOT NULL,
    ClassDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    MaxClassSize INT NOT NULL,
    FOREIGN KEY (InstructorID) REFERENCES Staff(StaffID),
    CHECK (EndTime > StartTime)
) ENGINE=InnoDB;

-- Facility Booking
CREATE TABLE FacilityBooking (
    BookingID INT AUTO_INCREMENT PRIMARY KEY,
    MemberID INT NOT NULL,
    FacilityID INT NOT NULL,
    ActivityID INT NOT NULL,
    BookingDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
    FOREIGN KEY (FacilityID) REFERENCES Facility(FacilityID),
    FOREIGN KEY (ActivityID) REFERENCES Activity(ActivityID),
    CHECK (EndTime > StartTime),
    UNIQUE (FacilityID, BookingDate, StartTime)
) ENGINE=InnoDB;

-- Class Booking
CREATE TABLE ClassBooking (
    ClassBookingID INT AUTO_INCREMENT PRIMARY KEY,
    ClassID INT NOT NULL,
    MemberID INT NOT NULL,
    BookingDate DATE NOT NULL,
    FOREIGN KEY (ClassID) REFERENCES Class(ClassID),
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID)
) ENGINE=InnoDB;

-- Payment
CREATE TABLE Payment (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    MemberID INT NOT NULL,
    PaymentDate DATE NOT NULL,
    Amount DECIMAL(8,2) NOT NULL,
    PaymentMethod VARCHAR(20) NOT NULL,
    Description TEXT,
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
    CHECK (PaymentMethod IN ('Cash','Card','Online'))
) ENGINE=InnoDB;

-- Equipment
CREATE TABLE Equipment (
    EquipmentID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL UNIQUE,
    Description TEXT,
    Quantity INT NOT NULL
) ENGINE=InnoDB;

-- Membership Plan
CREATE TABLE MembershipPlan (
    PlanID INT AUTO_INCREMENT PRIMARY KEY,
    PlanName VARCHAR(50) NOT NULL,
    WeeklySubscriptionFee DECIMAL(5,2) NOT NULL,
    FreeClassLimit INT NOT NULL DEFAULT 5,
    ExtraClassFee DECIMAL(5,2) NOT NULL DEFAULT 5.00
) ENGINE=InnoDB;

-- Member Plan
CREATE TABLE MemberPlan (
    MemberPlanID INT AUTO_INCREMENT PRIMARY KEY,
    MemberID INT NOT NULL,
    PlanID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE,
    IsActive TINYINT(1) NOT NULL DEFAULT 1,
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
    FOREIGN KEY (PlanID) REFERENCES MembershipPlan(PlanID)
) ENGINE=InnoDB;


DELIMITER $$
CREATE TRIGGER limit_facility_bookings
BEFORE INSERT ON FacilityBooking
FOR EACH ROW
BEGIN
    DECLARE booking_count INT;

    SELECT COUNT(*) INTO booking_count
    FROM FacilityBooking
    WHERE MemberID = NEW.MemberID
    AND YEARWEEK(BookingDate, 1) = YEARWEEK(NEW.BookingDate, 1);

    IF booking_count >= 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Booking limit exceeded: only one facility booking per week allowed.';
    END IF;
END $$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER limit_class_bookings
AFTER INSERT ON ClassBooking
FOR EACH ROW
BEGIN
    DECLARE class_count INT;
    DECLARE free_limit INT;
    DECLARE extra_fee DECIMAL(5,2);

    -- Count classes booked this week
    SELECT COUNT(*) INTO class_count
    FROM ClassBooking
    WHERE MemberID = NEW.MemberID
    AND YEARWEEK(BookingDate,1) = YEARWEEK(NEW.BookingDate,1);

    -- Get free class limit
    SELECT COALESCE(mp.FreeClassLimit, 5)
    INTO free_limit
    FROM MemberPlan mpl
    JOIN MembershipPlan mp ON mpl.PlanID = mp.PlanID
    WHERE mpl.MemberID = NEW.MemberID
    AND mpl.IsActive = 1
    LIMIT 1;

    -- Get extra class fee
    SELECT COALESCE(mp.ExtraClassFee, 5.00)
    INTO extra_fee
    FROM MemberPlan mpl
    JOIN MembershipPlan mp ON mpl.PlanID = mp.PlanID
    WHERE mpl.MemberID = NEW.MemberID
    AND mpl.IsActive = 1
    LIMIT 1;

    IF class_count > free_limit THEN
        INSERT INTO Payment (MemberID, PaymentDate, Amount, PaymentMethod, Description)
        VALUES (NEW.MemberID, CURDATE(), extra_fee, 'Card', 'Extra class fee');
    END IF;
END $$
DELIMITER ;


INSERT INTO Member (MemberID, FirstName, LastName, Email, WeeklySubscription, ExtraClassFee)
VALUES
(1, 'Alice', 'Smith', 'alice@example.com', 10.0, 5.0),
(2, 'Bob', 'Jones', 'bob@example.com', 10.0, 5.0),
(3, 'Carlos', 'Lee', 'carlos@example.com', 12.0, 4.0),
(4, 'Diana', 'White', 'diana@example.com', 10.0, 5.0),
(5, 'Ethan', 'Clark', 'ethan@example.com', 10.0, 5.0);


INSERT INTO Staff (StaffID, FirstName, LastName, Role)
VALUES
(1, 'David', 'Brown', 'Instructor'),
(2, 'Elena', 'Green', 'Trainer'),
(3, 'Frank', 'Taylor', 'GymStaff'),
(4, 'Grace', 'Wilson', 'Instructor'),
(5, 'Henry', 'Adams', 'Manager');


INSERT INTO Facility (FacilityID, Name, MaxCapacity)
VALUES
(1, 'Main Hall', 80),
(2, 'Yoga Hall', 25),
(3, 'Small Dance Room', 10),
(4, 'Fitness Studio', 30),
(5, 'Outdoor Court', 50);

INSERT INTO Activity (ActivityID, Name)
VALUES
(1, 'Yoga'),
(2, 'Basketball'),
(3, 'Zumba'),
(4, 'Pilates'),
(5, 'Dance');


INSERT INTO ActivityFacility (ActivityID, FacilityID)
VALUES
(1, 2),
(1, 3),
(2, 1),
(3, 2),
(5, 3);



INSERT INTO Class (ClassID, ClassName, InstructorID, ClassDate, StartTime, EndTime, MaxClassSize)
VALUES
(1, 'Morning Yoga', 1, '2026-03-15', '08:00:00', '09:00:00', 20),
(2, 'Basketball Clinic', 2, '2026-03-15', '10:00:00', '12:00:00', 30),
(3, 'Zumba Fitness', 4, '2026-03-16', '09:00:00', '10:00:00', 25),
(4, 'Pilates Core', 1, '2026-03-17', '07:30:00', '08:30:00', 20),
(5, 'Dance Cardio', 4, '2026-03-18', '18:00:00', '19:00:00', 25);

INSERT INTO FacilityBooking (BookingID, MemberID, FacilityID, ActivityID, BookingDate, StartTime, EndTime)
VALUES
(1, 1, 1, 2, '2026-03-11', '09:00:00', '11:00:00'),
(2, 2, 2, 1, '2026-03-12', '15:00:00', '17:00:00'),
(3, 3, 3, 5, '2026-03-13', '10:00:00', '12:00:00'),
(4, 4, 4, 4, '2026-03-14', '13:00:00', '15:00:00'),
(5, 5, 5, 2, '2026-03-15', '16:00:00', '18:00:00');

INSERT INTO ClassBooking (ClassID, MemberID, BookingDate)
VALUES
(1, 1, '2026-03-10'),
(1, 2, '2026-03-10'),
(2, 3, '2026-03-10'),
(3, 4, '2026-03-11'),
(4, 5, '2026-03-11');

INSERT INTO Payment (PaymentID, MemberID, PaymentDate, Amount, PaymentMethod, Description)
VALUES
(1, 1, '2026-03-05', 50.0, 'Card', 'Membership renewal'),
(2, 2, '2026-03-05', 50.0, 'Cash', 'Membership renewal'),
(3, 3, '2026-03-06', 60.0, 'Online', 'Membership renewal'),
(4, 4, '2026-03-06', 50.0, 'Card', 'Membership renewal'),
(5, 5, '2026-03-07', 50.0, 'Cash', 'Membership renewal');

INSERT INTO Equipment (EquipmentID, Name, Quantity)
VALUES
(1, 'Yoga Mat', 30),
(2, 'Basketball', 15),
(3, 'Dumbbells', 40),
(4, 'Resistance Bands', 25),
(5, 'Exercise Balls', 20);

INSERT INTO MembershipPlan (PlanID, PlanName, WeeklySubscriptionFee, FreeClassLimit, ExtraClassFee)
VALUES
(1, 'Standard', 10.0, 5, 5.0),
(2, 'Premium', 15.0, 8, 3.0),
(3, 'Student', 8.0, 5, 4.0),
(4, 'Family', 12.0, 6, 4.0),
(5, 'VIP', 20.0, 10, 2.0);

INSERT INTO MemberPlan (MemberPlanID, MemberID, PlanID, StartDate)
VALUES
(1, 1, 1, '2026-01-01'),
(2, 2, 2, '2026-01-01'),
(3, 3, 3, '2026-01-05'),
(4, 4, 1, '2026-02-01'),
(5, 5, 5, '2026-02-10');


-- 1. List all members 
SELECT MemberID, FirstName, LastName, Email FROM Member ORDER BY LastName; 
 
SELECT StaffID, FirstName, LastName, Role 
FROM Staff 
ORDER BY StaffID; 
 
-- Current week facility bookings for a member (Alice) 
SELECT fb.BookingDate, fb.StartTime, fb.EndTime, f.Name AS Facility, a.Name AS Activity 
FROM FacilityBooking fb 
JOIN Facility f ON fb.FacilityID = f.FacilityID 
JOIN Activity a ON fb.ActivityID = a.ActivityID 
WHERE fb.MemberID = 1 
  AND fb.BookingDate BETWEEN date('2026-03-10') AND date('2026-03-16'); 
 
-- Classes offered by an instructor during a week 
SELECT c.ClassName, c.ClassDate, c.StartTime, c.EndTime, COUNT(cb.ClassBookingID) AS 
Registrations 
FROM Class c 
LEFT JOIN ClassBooking cb ON c.ClassID = cb.ClassID 
WHERE c.InstructorID = 1 
  AND c.ClassDate BETWEEN '2026-03-10' AND '2026-03-16' 
GROUP BY c.ClassID; 
 
-- Identify most active members (combined bookings) 
SELECT m.MemberID, m.FirstName, m.LastName, 
       COUNT(DISTINCT fb.BookingID) AS FacilityBookings, 
       COUNT(DISTINCT cb.ClassBookingID) AS ClassBookings, 
       (COUNT(DISTINCT fb.BookingID) + COUNT(DISTINCT cb.ClassBookingID)) AS TotalActivities 
FROM Member m 
LEFT JOIN FacilityBooking fb ON m.MemberID = fb.MemberID 
LEFT JOIN ClassBooking    cb ON m.MemberID = cb.MemberID 
GROUP BY m.MemberID 
ORDER BY TotalActivities DESC; 
 
-- Class occupancy rates 
SELECT c.ClassName, c.ClassDate, COUNT(cb.ClassBookingID) AS Booked,        c.MaxClassSize, 
       (COUNT(cb.ClassBookingID) * 100.0 / c.MaxClassSize) AS OccupancyPercentage 
FROM Class c 
LEFT JOIN ClassBooking cb ON c.ClassID = cb.ClassID 
GROUP BY c.ClassID; 
 
-- Facility utilisation 
SELECT f.Name, COUNT(fb.BookingID) AS TotalBookings 
FROM Facility f 
LEFT JOIN FacilityBooking fb ON f.FacilityID = fb.FacilityID 
GROUP BY f.FacilityID; 
 
-- Top instructors by number of classes 
SELECT s.StaffID, s.FirstName, s.LastName, COUNT(c.ClassID) AS ClassesTaught 
FROM Staff s 
JOIN Class c ON s.StaffID = c.InstructorID 
GROUP BY s.StaffID 
ORDER BY ClassesTaught DESC; 




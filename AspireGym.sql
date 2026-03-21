CREATE DATABASE AspireFitness;
USE AspireFitness;

-- Create Member table
CREATE TABLE Member (
    MemberID INTEGER PRIMARY KEY,
    FirstName TEXT NOT NULL,
    LastName TEXT NOT NULL,
    Address TEXT,
    Telephone TEXT,
    Email TEXT,
    DateOfBirth DATE,
    MedicalConditions TEXT,
    WeeklySubscription REAL DEFAULT 10.0,
    ExtraClassCharge REAL DEFAULT 5.0
);

-- Create Staff table
CREATE TABLE Staff (
    StaffID INTEGER PRIMARY KEY,
    FirstName TEXT NOT NULL,
    LastName TEXT NOT NULL,
    Role TEXT NOT NULL,
    PhoneNumber TEXT
);

-- Create Facility table
CREATE TABLE Facility (
    FacilityID INTEGER PRIMARY KEY,
    Name TEXT NOT NULL,
    Description TEXT,
    MaxCapacity INTEGER NOT NULL
);

-- Create Activity table
CREATE TABLE Activity (
    ActivityID INTEGER PRIMARY KEY,
    Name TEXT NOT NULL
);

-- Create FacilityBooking table
CREATE TABLE FacilityBooking (
    BookingID INTEGER PRIMARY KEY,
    MemberID INTEGER NOT NULL,
    FacilityID INTEGER NOT NULL,
    ActivityID INTEGER NOT NULL,
    BookingDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    FOREIGN KEY(MemberID) REFERENCES Member(MemberID),
    FOREIGN KEY(FacilityID) REFERENCES Facility(FacilityID),
    FOREIGN KEY(ActivityID) REFERENCES Activity(ActivityID)
);

-- Create Class table
CREATE TABLE Class (
    ClassID INTEGER PRIMARY KEY,
    ClassName TEXT NOT NULL,
    InstructorID INTEGER NOT NULL,
    ClassDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    MaxClassSize INTEGER NOT NULL,
    FOREIGN KEY(InstructorID) REFERENCES Staff(StaffID)
);

-- Create ClassBooking table
CREATE TABLE ClassBooking (
    ClassBookingID INTEGER PRIMARY KEY,
    ClassID INTEGER NOT NULL,
    MemberID INTEGER NOT NULL,
    BookingDate DATE NOT NULL,
    FOREIGN KEY(ClassID) REFERENCES Class(ClassID),
    FOREIGN KEY(MemberID) REFERENCES Member(MemberID)
);

-- Insert sample members
INSERT INTO Member VALUES (1,'Alice','Smith','123 Main St','1234567890','alice@example.com','1990-05-10','None',10.0,5.0);
INSERT INTO Member VALUES (2,'Bob','Johnson','456 Elm St','0987654321','bob@example.com','1985-09-20','Asthma',10.0,5.0);
INSERT INTO Member VALUES (3,'Carol','Williams','789 Maple Ave','5555555555','carol@example.com','1992-12-05','Diabetes',10.0,5.0);

-- Insert staff
INSERT INTO Staff VALUES (1,'David','Brown','Instructor','1111111111');
INSERT INTO Staff VALUES (2,'Eve','Davis','Personal Trainer','2222222222');
INSERT INTO Staff VALUES (3,'Frank','Miller','Manager','3333333333');

-- Insert facilities
INSERT INTO Facility VALUES (1,'Main Hall','Functional activities like football, basketball, netball, volleyball',80);
INSERT INTO Facility VALUES (2,'Yoga Hall','Yoga, dance, combat',25);
INSERT INTO Facility VALUES (3,'Small Dance Room','Yoga, dance',10);

-- Insert activities
INSERT INTO Activity VALUES (1,'Volleyball');
INSERT INTO Activity VALUES (2,'Basketball');
INSERT INTO Activity VALUES (3,'Yoga');
INSERT INTO Activity VALUES (4,'Zumba');

-- Insert facility bookings
INSERT INTO FacilityBooking VALUES (1,1,1,2,'2026-03-08','10:00','12:00');
INSERT INTO FacilityBooking VALUES (2,2,2,3,'2026-03-09','13:00','14:30');
INSERT INTO FacilityBooking VALUES (3,3,1,1,'2026-03-07','15:00','17:00');

-- Insert classes
INSERT INTO Class VALUES (1,'Yoga for Beginners',1,'2026-03-08','09:00','10:00',25);
INSERT INTO Class VALUES (2,'Advanced Zumba',1,'2026-03-09','17:00','18:00',30);
INSERT INTO Class VALUES (3,'Pilates Session',2,'2026-03-10','08:00','09:00',20);

-- Insert class bookings
INSERT INTO ClassBooking VALUES (1,1,1,'2026-03-07');
INSERT INTO ClassBooking VALUES (2,1,2,'2026-03-07');
INSERT INTO ClassBooking VALUES (3,2,3,'2026-03-08');
INSERT INTO ClassBooking VALUES (4,3,1,'2026-03-09');
INSERT INTO ClassBooking VALUES (5,3,2,'2026-03-09');

SELECT *  
FROM Member  
ORDER BY MemberID; 

SELECT StaffID, FirstName, LastName, Role 
FROM Staff 
ORDER BY StaffID; 

SELECT fb.BookingID, fb.BookingDate, fb.StartTime, fb.EndTime, 
      f.Name   AS Facility, 
      a.Name   AS Activity 
FROM FacilityBooking fb 
JOIN Facility f   ON fb.FacilityID = f.FacilityID 
JOIN Activity a   ON fb.ActivityID = a.ActivityID 
WHERE fb.MemberID = 1 
 AND fb.BookingDate BETWEEN DATE('2026-03-07') AND DATE('2026-03-13'); 
 
 SELECT c.ClassID, c.ClassName, c.ClassDate, c.StartTime, c.EndTime 
FROM Class c 
JOIN Staff s ON c.InstructorID = s.StaffID 
WHERE s.FirstName = 'David' AND s.LastName = 'Brown' 
 AND c.ClassDate BETWEEN '2026-03-07' AND '2026-03-14' 
ORDER BY c.ClassDate, c.StartTime; 

SELECT m.MemberID,
       CONCAT(m.FirstName, ' ', m.LastName) AS MemberName,
       (IFNULL(fb.CountBookings,0) + IFNULL(cb.CountBookings,0)) AS TotalBookings
FROM Member m
LEFT JOIN (
   SELECT MemberID, COUNT(*) AS CountBookings
   FROM FacilityBooking
   GROUP BY MemberID
) fb ON m.MemberID = fb.MemberID
LEFT JOIN (
   SELECT MemberID, COUNT(*) AS CountBookings
   FROM ClassBooking
   GROUP BY MemberID
) cb ON m.MemberID = cb.MemberID
ORDER BY TotalBookings DESC;

SELECT f.Name, COUNT(fb.BookingID) AS TotalBookings 
FROM Facility f 
LEFT JOIN FacilityBooking fb ON f.FacilityID = fb.FacilityID 
GROUP BY f.FacilityID 
ORDER BY TotalBookings DESC; 

SELECT c.ClassID, c.ClassName, c.MaxClassSize, 
      COUNT(cb.ClassBookingID) AS BookedSlots, 
      ROUND(COUNT(cb.ClassBookingID) * 100.0 / c.MaxClassSize, 1) AS OccupancyPercent 
FROM Class c 
LEFT JOIN ClassBooking cb ON c.ClassID = cb.ClassID 
GROUP BY c.ClassID; 

SELECT s.StaffID, 
      CONCAT(s.FirstName , ' ' , s.LastName) AS InstructorName, 
      COUNT(c.ClassID) AS NumClasses 
FROM Staff s 
JOIN Class c ON s.StaffID = c.InstructorID 
GROUP BY s.StaffID 
ORDER BY NumClasses DESC; 
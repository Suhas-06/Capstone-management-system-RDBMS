-- Create the database schema
CREATE DATABASE UniversityDB;
USE UniversityDB;

-- drop database universitydb;

-- Create the Project table
CREATE TABLE Project (
    ProjectID INT PRIMARY KEY,
    TeamID INT,
    Status VARCHAR(255),
    Title VARCHAR(255),
    Domain VARCHAR(255)
);
ALTER TABLE Project
ADD CONSTRAINT
FOREIGN KEY (TeamID) REFERENCES Team(TeamID) ON DELETE CASCADE;


-- Create the Grades table
CREATE TABLE Grades (
    StudentID INT,
    ProjectID INT,
    Grade varchar(1),
    PRIMARY KEY (StudentID, ProjectID)
);

ALTER TABLE Grades
ADD CONSTRAINT
FOREIGN KEY (StudentID) REFERENCES Student(StudentID) ON DELETE CASCADE, ADD CONSTRAINT FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID) ON DELETE CASCADE;


-- Create the Student table
CREATE TABLE Student (
    StudentID INT PRIMARY KEY,
    TeamID INT,
    FirstName VARCHAR(255),
    MiddleName VARCHAR(255),
    LastName VARCHAR(255),
    Email VARCHAR(255),
    DOB DATE,
    CGPA DECIMAL(4, 2)
);

ALTER TABLE Student
ADD CONSTRAINT
FOREIGN KEY (TeamID) REFERENCES Team(TeamID) ON DELETE CASCADE;


-- Create the Team table
CREATE TABLE Team (
    TeamID INT PRIMARY KEY,
    ProjectID INT,
    MentorID INT

);

ALTER TABLE Team
ADD CONSTRAINT
FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID) ON DELETE CASCADE, ADD CONSTRAINT FOREIGN KEY (MentorID) REFERENCES Mentor(MentorID) ON DELETE CASCADE;


-- Create the Mentor table
CREATE TABLE Mentor (
    MentorID INT PRIMARY KEY,
    TeamID INT,
    FirstName VARCHAR(255),
    MiddleName VARCHAR(255),
    LastName VARCHAR(255),
    Email VARCHAR(255)
);

ALTER TABLE Mentor
ADD CONSTRAINT
FOREIGN KEY (TeamID) REFERENCES Team(TeamID) ON DELETE CASCADE;

ALTER TABLE Mentor ADD COLUMN status VARCHAR(255) DEFAULT 'Pending';

-- Create the Review table
CREATE TABLE Review (
    ReviewID INT PRIMARY KEY,
    TeamID INT,
    PanelID INT,
    Day INT,
    Month INT,
    Year INT,
    Feedback TEXT
);

ALTER TABLE Review
ADD CONSTRAINT
 FOREIGN KEY (TeamID) REFERENCES Team(TeamID) ON DELETE CASCADE, ADD CONSTRAINT FOREIGN KEY (PanelID) REFERENCES Panel(PanelID) ON DELETE CASCADE;



-- Create the Panel table
CREATE TABLE Panel (
    PanelID INT PRIMARY KEY,
    JudgeID INT,
    TeamID INT,
    RoomNumber INT
);

ALTER TABLE Panel
ADD CONSTRAINT
 FOREIGN KEY (JudgeID) REFERENCES Mentor(MentorID)ON DELETE CASCADE, ADD CONSTRAINT FOREIGN KEY (TeamID) REFERENCES Team(TeamID) ON DELETE CASCADE;



-- Create a table for multivalued attributes
CREATE TABLE TeamStudent (
    TeamID INT,
    StudentID INT,
    PRIMARY KEY (TeamID, StudentID),
    FOREIGN KEY (TeamID) REFERENCES Team(TeamID) ON DELETE CASCADE,
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID) ON DELETE CASCADE
);

-- Create a table for multivalued attributes
CREATE TABLE MentorTeam (
    MentorID INT,
    TeamID INT,
    PRIMARY KEY (MentorID, TeamID),
    FOREIGN KEY (MentorID) REFERENCES Mentor(MentorID) ON DELETE CASCADE,
    FOREIGN KEY (TeamID) REFERENCES Team(TeamID) ON DELETE CASCADE
);

-- Create a table for multivalued attributes
CREATE TABLE PanelJudge (
    PanelID INT,
    JudgeID INT,
    PRIMARY KEY (PanelID, JudgeID),
    FOREIGN KEY (PanelID) REFERENCES Panel(PanelID) ON DELETE CASCADE,
    FOREIGN KEY (JudgeID) REFERENCES Mentor(MentorID) ON DELETE CASCADE
);





INSERT INTO Student (StudentID, TeamID, FirstName, MiddleName, LastName, Email, DOB, CGPA)
VALUES
    (1, 1, 'John', 'A.', 'Doe', 'john.doe@example.com', '2000-05-15', 5.75),
    (2, 1, 'Jane', 'B.', 'Smith', 'jane.smith@example.com', '2001-02-20', 6.90),
(3, 1, 'Robert', 'C.', 'Johnson', 'robert.johnson@example.com', '2000-11-10', 7.60),
(4, 1, 'Emily', 'D.', 'Wilson', 'emily.wilson@example.com', '2002-07-05', 8.85),
(5, 2, 'Michael', 'E.', 'Brown', 'michael.brown@example.com', '1999-08-30', 9.70),
(6, 2, 'Sarah', 'F.', 'Clark', 'sarah.clark@example.com', '2001-04-25', 4.95),
(7, 2, 'David', 'G.', 'White', 'david.white@example.com', '2000-09-12', 5.55),
(8, 2, 'Olivia', 'H.', 'Adams', 'olivia.adams@example.com', '2002-01-08', 6.80),
(9, 3, 'William', 'I.', 'Martin', 'william.martin@example.com', '2001-06-18', 3.65),
(10, 3, 'Sophia', 'J.', 'Anderson', 'sophia.anderson@example.com', '2002-03-22', 8.75),
(11, 3, 'Megan', 'K.', 'Harris', 'megan.harris@example.com', '2001-08-17', 7.70),
(12, 3, 'Daniel', 'L.', 'Young', 'daniel.young@example.com', '2000-12-02', 9.88);

INSERT INTO Student (StudentID, TeamID, FirstName, MiddleName, LastName, Email, DOB, CGPA)
VALUES
    -- Team 4
    (13, 4, 'Ava', 'M.', 'Turner', 'ava.turner@example.com', '2000-04-14', 6.45),
    (14, 4, 'Ethan', 'N.', 'Parker', 'ethan.parker@example.com', '2001-10-28', 7.20),
    (15, 4, 'Hannah', 'O.', 'Baker', 'hannah.baker@example.com', '2002-05-05', 8.30),
    (16, 4, 'Liam', 'P.', 'Fisher', 'liam.fisher@example.com', '2000-09-22', 9.15),

    -- Team 5
    (17, 5, 'Emma', 'Q.', 'Cook', 'emma.cook@example.com', '2001-07-12', 5.90),
    (18, 5, 'Jackson', 'R.', 'Jones', 'jackson.jones@example.com', '2002-02-15', 6.75),
    (19, 5, 'Sophie', 'S.', 'Taylor', 'sophie.taylor@example.com', '2001-11-30', 7.95),
    (20, 5, 'Logan', 'T.', 'Ward', 'logan.ward@example.com', '2000-03-25', 8.50);
INSERT INTO Student (StudentID, TeamID, FirstName, MiddleName, LastName, Email, DOB, CGPA)
VALUES
    (21, 6, 'Aiden', 'U.', 'Hill', 'aiden.hill@example.com', '2002-08-08', 7.10),
    (22, 6, 'Grace', 'V.', 'Murphy', 'grace.murphy@example.com', '2001-01-19', 8.60),
    (23, 6, 'Elijah', 'W.', 'Cooper', 'elijah.cooper@example.com', '2000-06-14', 9.45);






-- Create a trigger to populate the TeamStudent table when a new student is inserted
DELIMITER //

CREATE TRIGGER populate_team_student
AFTER INSERT ON Student
FOR EACH ROW
BEGIN
  INSERT INTO TeamStudent (TeamID, StudentID)
  VALUES (NEW.TeamID, NEW.StudentID);
END;
//
DELIMITER ;


-- drop trigger populate_team_student;
-- delete from Teamstudent;


-- Create a trigger to populate the MentorTeam table when a new Team is inserted
DELIMITER //

CREATE TRIGGER populate_mentor_team
AFTER INSERT ON Mentor
FOR EACH ROW
BEGIN
  INSERT INTO MentorTeam (TeamID, MentorID)
  VALUES (NEW.TeamID, NEW.MentorID);
END;
//DELIMITER ;

select * from paneljudge;

DELIMITER //

CREATE TRIGGER before_student_insert
BEFORE INSERT ON STUDENT
FOR EACH ROW
BEGIN
    DECLARE team_size INT;

    -- Get the current team size
    SELECT COUNT(*) INTO team_size FROM STUDENT WHERE teamID = NEW.teamID;

    -- Check if the team is already full
    IF team_size >= 4 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Team is already full. Cannot add more members.';
    END IF;
END //

DELIMITER ;







-- Create a trigger to populate the paneljudge table when a new Judge is inserted
DELIMITER //

CREATE TRIGGER InsertIntoPanelJudge
AFTER INSERT ON Panel
FOR EACH ROW
BEGIN
    -- Check if there's a Mentor with the same identifier as Judge in the new Panel record
    DECLARE mentor_id INT;
    
    SELECT MentorID INTO mentor_id
    FROM Mentor
    WHERE Mentor.MentorID = NEW.JudgeID;

    IF mentor_id IS NOT NULL THEN
        -- Insert into PanelJudge when a Mentor with matching JudgeID is found
        INSERT INTO PanelJudge (PanelID, JudgeID)
        VALUES (NEW.PanelID, NEW.JudgeID);
    END IF;
END;
//
DELIMITER ;


-- Insert 4 random values into the Project table
INSERT INTO Project (ProjectID, TeamID, Status, Title, Domain)
VALUES
    (101, 1, 'In Progress', 'Project A', 'Technology'),
    (102, 2, 'Completed', 'Project B', 'Science'),
    (103, 3, 'In Progress', 'Project C', 'Engineering'),
    (104, 4, 'Planned', 'Project D', 'Business'),
    (105, 5, 'Planned', 'Project E', 'Medical');
    
-- Insert 5 random records into the Project table
INSERT INTO Project (ProjectID, TeamID, Status, Title, Domain)
VALUES
    (106, 6, 'Completed', 'Project F', 'Art'),
    (107, 7, 'In Progress', 'Project G', 'Technology'),
    (108, 8, 'Planned', 'Project H', 'Science'),
    (109, 9, 'In Progress', 'Project I', 'Engineering'),
    (110, 10, 'Planned', 'Project J', 'Business');

-- select * from project;
-- Insert 5 random teams without references to projects or mentors
INSERT INTO Team (TeamID, ProjectID, MentorID)
VALUES
    (1, NULL, NULL),  -- Team 1 with no project or mentor
    (2, NULL, NULL),  -- Team 2 with no project or mentor
    (3, NULL, NULL),  -- Team 3 with no project or mentor
    (4, NULL, NULL),  -- Team 4 with no project or mentor
    (5, NULL, NULL);  -- Team 5 with no project or mentor
-- Insert 5 random teams without references to projects or mentors
INSERT INTO Team (TeamID, ProjectID, MentorID)
VALUES
    (6, NULL, NULL),  -- Team 1 with no project or mentor
    (7, NULL, NULL),  -- Team 2 with no project or mentor
    (8, NULL, NULL),  -- Team 3 with no project or mentor
    (9, NULL, NULL),  -- Team 4 with no project or mentor
    (10, NULL, NULL);  -- Team 5 with no project or mentor
    
INSERT INTO Team (TeamID, ProjectID, MentorID)
VALUES
    (1, 101, 201), -- Adjust the values as needed
    (2, 102, 202),
    (3, 103, 203),
    (4, 104, 204),
    (5, 105, 205);

-- Insert 5 random mentors without references to teams
INSERT INTO Mentor (MentorID, TeamID, FirstName, MiddleName, LastName, Email)
VALUES
    (201, 1, 'Mentor1', 'A.', 'Smith', 'mentor1@example.com'),
    (202, 2, 'Mentor2', 'B.', 'Johnson', 'mentor2@example.com'),
    (203, 3, 'Mentor3', 'C.', 'Williams', 'mentor3@example.com'),
    (204, 4, 'Mentor4', 'D.', 'Brown', 'mentor4@example.com'),
    (205, 5, 'Mentor5', 'E.', 'Davis', 'mentor5@example.com');


-- Insert 5 random records into the Mentor table
INSERT INTO Mentor (MentorID, TeamID, FirstName, MiddleName, LastName, Email)
VALUES
    (206, 6, 'Mentor6', 'F.', 'Anderson', 'mentor6@example.com'),
    (207, 7, 'Mentor7', 'G.', 'Martinez', 'mentor7@example.com'),
    (208, 8, 'Mentor8', 'H.', 'Robinson', 'mentor8@example.com'),
    (209, 9, 'Mentor9', 'I.', 'Clark', 'mentor9@example.com'),
    (210, 10, 'Mentor10', 'J.', 'Rodriguez', 'mentor10@example.com');

-- Insert 5 random records into the Panel table
INSERT INTO Panel (PanelID, JudgeID, TeamID, RoomNumber)
VALUES
    (1, 201, 1, 111),
    (2, 202, 2, 222),
    (3, 203, 3, 333),
    (4, 204, 4, 444),
    (5, 205, 5, 555);

DELIMITER //

-- Create a stored procedure to update Team based on Project data
CREATE PROCEDURE UpdateTeamProjectID()
BEGIN
    -- Declare variables to hold ProjectID and TeamID
    DECLARE project_id INT;
    DECLARE team_id INT;

    -- Declare a variable to check if a row was found
    DECLARE no_more_rows INT DEFAULT 0;

    -- Declare a cursor for selecting Project data

    DECLARE project_cursor CURSOR FOR
        SELECT Project.ProjectID, Team.TeamID
        FROM Project
        JOIN Team ON Project.TeamID = Team.TeamID;

    -- Declare a continue handler to exit the loop when no more rows are found
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more_rows = 1;

    -- Open the cursor
    OPEN project_cursor;

    -- Start processing rows
    read_loop: LOOP
        FETCH project_cursor INTO project_id, team_id;

        -- If no more rows are found, exit the loop
        IF no_more_rows = 1 THEN
            LEAVE read_loop;
        END IF;

        -- Update the Team table with ProjectID
        UPDATE Team
        SET ProjectID = project_id
        WHERE TeamID = team_id;
    END LOOP;

    -- Close the cursor
    CLOSE project_cursor;
END;
//
DELIMITER ;

CALL UpdateTeamProjectID();

DELIMITER //

-- Create a stored procedure to update Team based on Mentor data
CREATE PROCEDURE UpdateTeamMentorID()
BEGIN
    -- Declare variables to hold MentorID and TeamID
    DECLARE mentor_id INT;
    DECLARE team_id INT;

    -- Declare a variable to check if a row was found
    DECLARE no_more_rows INT DEFAULT 0;

    -- Declare a cursor for selecting Mentor data
    DECLARE mentor_cursor CURSOR FOR
        SELECT Mentor.MentorID, Team.TeamID
        FROM Mentor
        JOIN Team ON Mentor.TeamID = Team.TeamID;

    -- Declare a continue handler to exit the loop when no more rows are found
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more_rows = 1;

    -- Open the cursor
    OPEN mentor_cursor;

    -- Start processing rows
    read_loop: LOOP
        FETCH mentor_cursor INTO mentor_id, team_id;

        -- If no more rows are found, exit the loop
        IF no_more_rows = 1 THEN
            LEAVE read_loop;
        END IF;

        -- Update the Team table with MentorID
        UPDATE Team
        SET MentorID = mentor_id
        WHERE TeamID = team_id;
    END LOOP;

    -- Close the cursor
    CLOSE mentor_cursor;
END;
//
DELIMITER ;

CALL UpdateTeamMentorID();

SELECT
    Team.TeamID,
    Project.Title AS ProjectTitle,
    Project.Domain AS ProjectDomain,
    Project.Status AS ProjectStatus,
    Mentor.FirstName AS MentorFirstName,
    Mentor.LastName AS MentorLastName,
    Mentor.Email AS MentorEmail,
    GROUP_CONCAT(CONCAT(Student.FirstName, ' ', Student.LastName) ORDER BY Student.StudentID ASC) AS StudentNames,
    GROUP_CONCAT(Grades.Grade ORDER BY Student.StudentID ASC) AS StudentGrades
FROM Team
INNER JOIN Project ON Team.ProjectID = Project.ProjectID
INNER JOIN Mentor ON Team.MentorID = Mentor.MentorID
LEFT JOIN TeamStudent ON Team.TeamID = TeamStudent.TeamID
LEFT JOIN Student ON TeamStudent.StudentID = Student.StudentID
LEFT JOIN Grades ON TeamStudent.StudentID = Grades.StudentID AND Project.ProjectID = Grades.ProjectID
WHERE Team.TeamID = 1
GROUP BY Team.TeamID;

-- Insert sample values into the Grades table
INSERT INTO Grades (StudentID, ProjectID, Grade) VALUES
(1, 101, 'A'),
(2, 101, 'B'),
(3, 101, 'C'),
(4, 101, 'B');

DELIMITER //

CREATE PROCEDURE ProcessBulkStudentInsert()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE student_id INT;
    DECLARE team_id INT;

    DECLARE cur CURSOR FOR SELECT StudentID, TeamID FROM Student;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO student_id, team_id;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Insert the row into TeamStudent
        INSERT INTO TeamStudent (TeamID, StudentID) VALUES (team_id, student_id);
    END LOOP;

    CLOSE cur;
END;
//
DELIMITER ;
CALL ProcessBulkStudentInsert();


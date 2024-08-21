
-----------------------------Registeration Stored Procedures----
--------------------------------------Youssif-Tables----------------------------
---INSERT
CREATE OR ALTER PROC Register_New_Member
@email varchar(50),
@username varchar(50),
@password int,
@usertype varchar(20),
@IT_id int,
@id int
WITH ENCRYPTION
AS 
	BEGIN

	IF EXISTS(SELECT Email FROM Registeration WHERE  Email = @email)
		SELECT 'SORRY THE USER YOU ENTERED ALREADY EXIST IN THE DATABASE' AS WARNING
	ELSE
		BEGIN
			INSERT INTO Registeration (register_id,Email,UserName,Password,UserType,IT_ID)
			VALUES( (SELECT ISNULL(MAX(Register_ID), 0) + 1 FROM Registeration),@email,@username,@password,@usertype,@IT_id);
		
		DECLARE @NewRegisterID int;
        SET @NewRegisterID = (SELECT MAX(Register_ID) FROM Registeration);

		IF @usertype = 'Student'
			BEGIN
				IF EXISTS (SELECT ST_ID FROM Student WHERE ST_ID = @id )
					BEGIN
						IF EXISTS(SELECT St_ID FROM Student_Register WHERE St_ID=@id)
							SELECT 'You`ve registered before'
						ELSE
							BEGIN
								INSERT INTO Student_Register(register_id,St_ID,St_Insertion_Date)
								VALUES(@NewRegisterID, @id,GETDATE()) -- student ID must be dynamic
							END
					END
				ELSE
					SELECT 'The student with that ID doesn`t exist'
			END
		ELSE IF @usertype = 'Instructor'
			BEGIN
					IF EXISTS (SELECT Instructor_ID FROM Instructor WHERE Instructor_ID = @id)
						BEGIN
							IF EXISTS(SELECT Instructor_id FROM Instructor_Register WHERE Instructor_id=@id)
								SELECT 'You`ve registered before'
							ELSE
								BEGIN
									INSERT INTO Instructor_Register(Instructor_id,Register_ID,Ins_Insertion_Date)
									VALUES(@id,@NewRegisterID ,GETDATE()) ---Instructor ID must be dynamic
								END
						END
					ELSE
						SELECT 'The instructor with that ID doesn`t exist'
				
			END
		END;
	END


EXEC  Register_New_Member 'Ghadasayed@gmail.com','Ghadasayed',654321,'Instructor',2,15


---SELECT

CREATE PROC Select_registered_member 
@email varchar(50),
@username varchar(50)
WITH ENCRYPTION
AS
	BEGIN

	IF NOT EXISTS(SELECT UserName, Email FROM Registeration WHERE UserName=@username AND Email=@email)
		SELECT 'Sorry the user name you`re looking for doesn`t exist' AS Warning
	ELSE
		BEGIN
			SELECT * 
			FROM Registeration
			WHERE  UserName=@username AND Email=@email
		END
	END

EXEC Select_registered_member  'AmenaSaleh@gmail.com','AmenaSaleh'


--UPDATE

ALTER PROC update_registered_member_info
@reg_id int ,
@email varchar(50)=NULL,
@username  varchar(50)=NULL,
@password  int=NULL,
@usertype  varchar(20)=NULL,
@IT_id int=NULL
WITH ENCRYPTION
AS
	BEGIN
	IF NOT EXISTS(SELECT Register_ID FROM Registeration WHERE Register_ID= @reg_id )
		SELECT 'Sorry the user name you`re looking for to update doesn`t exist' AS Warning
	ELSE
		BEGIN
			UPDATE Registeration
			SET
			UserName = COALESCE(@username, UserName),   
            Email = COALESCE(@Email, Email),            
            Password = COALESCE(@password, Password),   
            Usertype = COALESCE(@usertype, Usertype),   
            IT_ID = COALESCE(@IT_id, IT_ID)   
			WHERE Register_ID = @reg_id
		END
	END


EXEC update_registered_member_info 21,'Yousef@gmail.com','Yousef'



---DELETE
ALTER PROC Delete_registered_member
@reg_id int
WITH ENCRYPTION
AS
	BEGIN
	IF NOT EXISTS(SELECT Register_ID FROM Registeration WHERE Register_ID= @reg_id )
		SELECT 'Sorry the user name you`re looking for to delete doesn`t exist' AS Warning
	ELSE
		DELETE FROM Registeration
		WHERE Register_ID = @reg_id 
	END

EXEC Delete_registered_member 21


---------------------------INTAKE PROCEDURE--------------------------

---INSERT

ALTER PROC Insert_New_Intake
@intake_id int,
@branckName varchar(50),
@startDate DATE,
@endDate DATE,
@duration int = 4
WITH ENCRYPTION
AS
	BEGIN

	IF EXISTS(SELECT intake_id FROM Intake WHERE intake_id = @intake_id )
		SELECT 'Sorry The intake ID already exists' AS WARNING
	ELSE
		BEGIN
		INSERT INTO Intake (Intake_ID,Branch_Name,Intake_StartDate,Intake_EndDate)
		VALUES(@intake_id, @branckName,@startDate, @endDate);
		END
	END


EXEC Insert_New_Intake 45, 'Menoufia','2019-03-01','2019-07-01'


----SELECT
ALTER PROC Select_Intake
@intake_id int ,
@branckName varchar(50)=NULL

WITH ENCRYPTION 
AS
	BEGIN
	IF NOT EXISTS(SELECT intake_id FROM Intake WHERE intake_id = @intake_id)
		SELECT 'Sorry the intake you`re looking for doesn`t exist' AS Warning
	ELSE
		SELECT *
		FROM
		Intake
		WHERE intake_id=@intake_id 
	END

EXEC Select_Intake 45

----UPDATE
CREATE PROC Update_intake
@intake_id int=NULL,
@branckName varchar(50)=NULL,
@startDate DATE=NULL,
@endDate DATE=NULL,
@duration int = 4
WITH ENCRYPTION
AS
	BEGIN
	IF NOT EXISTS(SELECT Intake_ID FROM Intake WHERE Intake_ID= @intake_id )
		SELECT 'Sorry the Intake you`re looking for to update doesn`t exist' AS Warning
	ELSE 
		BEGIN
		UPDATE Intake
			SET
			Branch_Name = COALESCE(@branckName, Branch_Name),   
            Intake_StartDate = COALESCE(@startDate, Intake_StartDate),            
            Intake_EndDate = COALESCE(@endDate, Intake_EndDate) 
			WHERE Intake_ID = @intake_id
		END
	END

EXEC Update_intake 45, 'Tanta'


---DELETE
CREATE PROC Delete_intake
@intake_id int
WITH ENCRYPTION
AS
	BEGIN
	IF NOT EXISTS(SELECT intake_ID FROM Intake WHERE intake_ID= @intake_id)
		SELECT 'Sorry the user name you`re looking for to delete doesn`t exist' AS Warning
	ELSE
		DELETE FROM Intake
		WHERE intake_ID = @intake_id
	END


Exec Delete_intake 45



----------------------TRACK PROCEDURE------------------
--INSERT
ALTER PROC INSERT_Track
 
@TrackName Varchar(50),
@TrackTitles Varchar(50),
@SupervisorID int
WITH ENCRYPTION 
AS 
	BEGIN
	IF EXISTS(SELECT Track_Name FROM Track WHERE Track_Name = @TrackName)
		SELECT 'sorry you cannot add this track as the ID already exist '
	ELSE
		BEGIN
			IF NOT EXISTS(SELECT Instructor_ID FROM Instructor WHERE Instructor_ID = @SupervisorID)
				SELECT 'sorry the instructor ID doesn`t exist '
			ELSE
			
				INSERT INTO Track (Track_Name,Track_Titles,Supervisor_ID,TrackID)
				VALUES(@TrackName,@TrackTitles,@SupervisorID,(SELECT ISNULL(MAX(TrackID),0)+1 FROM TRACK))
		END
	END

EXEC INSERT_Track 'MotioN','Designer',1


--SELECT
ALTER PROC SelectTrack
@TrackID int,
@trackName Varchar(50)=NULL
WITH ENCRYPTION 
AS
	BEGIN
	IF NOT EXISTS(SELECT TrackID FROM Track WHERE TrackID = @TrackID)
		SELECT 'Sorry the Track you`re looking for doesn`t exist' AS Warning
	ELSE
		SELECT *
		FROM
		Track
		WHERE TrackID = @TrackID
	END

 EXEC SelectTrack 1

 --UPDATE
 ALTER PROC UpdateTrack
 @TrackID int,
@TrackName Varchar(50)=NULL,
@TrackTitles Varchar(50)=NULL,
@SupervisorID int=NULL
 WITH ENCRYPTION
AS
	BEGIN
	IF NOT EXISTS(SELECT TrackID FROM Track WHERE TrackID = @TrackID)
		SELECT 'Sorry the Track you`re looking for doesn`t exist' AS Warning
	ELSE 
		BEGIN
		IF EXISTS(SELECT Track_Name FROM TRACK WHERE Track_Name = @TrackName)
			BEGIN
				SELECT 'The Track already exists. So you can update whether the instructor id or the track title'
				UPDATE TRACK
				SET 
				Track_Titles = COALESCE(@TrackTitles, Track_Titles),            
				Supervisor_ID = COALESCE(@SupervisorID, Supervisor_ID) 
			END
		ELSE
			BEGIN
				UPDATE Track
				SET
				Track_Name = COALESCE(@TrackName, Track_Name),   
				Track_Titles = COALESCE(@TrackTitles, Track_Titles),            
				Supervisor_ID = COALESCE(@SupervisorID, Supervisor_ID) 
				WHERE TrackID = @TrackID
			END
		END
	END

EXEC UpdateTrack 7,'Motionssssssss'


--DELETE 
ALTER PROC DeleteTrack
@TrackID int 
WITH ENCRYPTION
AS
	BEGIN
		IF NOT EXISTS(SELECT TrackID FROM Track WHERE TrackID = @TrackID)
		SELECT 'Sorry the Track you`re looking for doesn`t exist' AS Warning
	ELSE
		DELETE FROM Track
		WHERE TrackID = @TrackID
	END

EXEC DeleteTrack 7




ALTER TABLE TRACK
ADD TrackID   INT 

UPDATE TRACK
SET TrackID = Track_ID;

ALTER TABLE TRACK
DROP COLUMN Track_ID;



-------------------------- INSERT STUDENT TABLE 
CREATE OR ALTER PROC InsertStudent 
    @st_SSN INT,
    @ST_Fname VARCHAR(50),
    @ST_Lname VARCHAR(50),
    @ST_BirthDate DATE,
    @ST_City VARCHAR(20),
    @ST_Gender VARCHAR(6),
    @Intake_ID INT,
    @Track_ID INT

WITH ENCRYPTION 
AS 
BEGIN
    
    IF EXISTS(SELECT 1 FROM STUDENT WHERE st_SSN = @st_SSN)
    BEGIN
        SELECT 'The student is already found' AS Message;
    END
    ELSE
    BEGIN
		IF EXISTS(SELECT 1 FROM Intake WHERE Intake_ID = @Intake_ID)
			BEGIN
				IF EXISTS(SELECT 1 FROM Track WHERE TrackID = @Track_ID)
					BEGIN
						DECLARE @ST_Age INT;
						SET @ST_Age = DATEDIFF(YEAR, @ST_BirthDate, GETDATE());

						INSERT INTO STUDENT(ST_ID, ST_SSN, ST_Fname, ST_Lname, ST_BirthDate, ST_Age, ST_City, ST_Gender, Intake_ID, Track_ID)
						VALUES (
							(SELECT ISNULL(MAX(ST_ID), 0) + 1 FROM STUDENT), 
							@st_SSN, 
							@ST_Fname, 
							@ST_Lname, 
							@ST_BirthDate, 
							@ST_Age, 
							@ST_City, 
							@ST_Gender, 
							@Intake_ID, 
							@Track_ID
						);

						SELECT 'Student record inserted successfully' AS Message;
					END
				ELSE 
					SELECT 'The track is not found'

			END
		ELSE
		SELECT 'INTAKE IS NOT FOUND' AS WARNING
    END
END;


-------------TEST--------
EXEC InsertStudent 559862471,'Ahmed','Mohamed','1999-01-03','Cairo','Male',41,1;


---------------SELECT STUDENT----------------------------------

CREATE OR ALTER PROC SELECT_STUDENT
@ST_ID INT
WITH ENCRYPTION
AS
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM STUDENT WHERE ST_ID = @ST_ID)
			SELECT 'THE Student is not found '
		ELSE 
			BEGIN
				SELECT *
				FROM STUDENT 
				WHERE ST_ID = @ST_ID
			END
	END

---Test----
EXECUTE SELECT_STUDENT 1

----------------DELETE--------------------------------------
CREATE OR ALTER PROC DELETE_STUDENT
@ST_ID INT 
WITH ENCRYPTION 
AS
	BEGIN
		IF EXISTS(SELECT 1 FROM STUDENT WHERE ST_ID = @ST_ID)
			BEGIN
				DELETE FROM STUDENT
				WHERE ST_ID = @ST_ID
			END
		ELSE
			SELECT 'The student is not found' 
			
	END

--------TEST-----
EXEC DELETE_STUDENT 204

------UPDATE----------------------------------
CREATE OR ALTER PROC UpdateStudent
@ST_ID INT,
@st_SSN INT=NULL,
@ST_Fname VARCHAR(50)=NULL,
@ST_Lname VARCHAR(50)=NULL,
@ST_BirthDate DATE=NULL,
@ST_City VARCHAR(20)=NULL,
@ST_Gender VARCHAR(6)=NULL,
@Intake_ID INT=NULL,
@Track_ID INT=NULL

WITH ENCRYPTION 
AS
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM STUDENT WHERE ST_ID = @ST_ID)
			SELECT 'The student is not found ' AS Warning
		ELSE
			BEGIN
				DECLARE @ST_Age INT;
				SET @ST_Age = DATEDIFF(YEAR, @ST_BirthDate, GETDATE());

				UPDATE Student
				SET ST_SSN = COALESCE(@st_SSN,ST_SSN),
					ST_Fname =COALESCE(@st_Fname,ST_fname),
					ST_Lname = COALESCE(@ST_Lname,ST_Lname),
					ST_BirthDate= COALESCE(@ST_BirthDate,ST_BirthDate),
					ST_Age = @ST_Age,
					ST_City = COALESCE(@ST_City,ST_City),
					ST_Gender=COALESCE(@ST_Gender,ST_Gender),
					Intake_ID=COALESCE(@Intake_ID,Intake_ID),
					Track_ID=COALESCE(@Track_ID,Track_ID)
				WHERE ST_ID = @ST_ID
			END
	END

---TEST----------------------------
EXEC UpdateStudent 204,@ST_Fname='Mahmoud',@ST_BirthDate='2004-01-03'
-
-------------------------------------------------------------------------------------------------
--------------------------------------Khaled-Tables----------------------------------------------
--------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

USE [ Examination]
GO

-- GENERATE TABLES SP 

-- 1)-- --------------------------------------INSTRUCTOR TABLE --------------------------------------------------

SELECT * FROM Instructor
--SELECT INSTRUCTOR SP 
CREATE OR ALTER PROC SelectInstructor @ID INT 
AS 
	IF NOT EXISTS (SELECT * FROM SYS.TABLES WHERE NAME = 'INSTRUCTOR')
		BEGIN
			SELECT 'TABLE DOES NOT EXIST'
		END
	ELSE
		SELECT * FROM INSTRUCTOR WHERE INSTRUCTOR_ID = @ID
-- TEST 
EXECUTE SelectInstructor 1
---------------------------------------------------------------------------

--INSERT INSTRUCTOR SP 
CREATE OR ALTER PROC InsertInstructor @ID INT = NULL ,
							@FNAME VARCHAR(50) ,
							@LNAME VARCHAR(50) = NULL,
							@AGE INT = NULL,
							@BD DATE = NULL,
							@GENDER VARCHAR(20) = NULL,
							@SAL INT  = 2000,
							@CITY VARCHAR(20) = 'CAIRO',
							@HIREDATE DATE  , 
							@DEPTID INT = 10
AS
	
	IF @ID = NULL 
		SELECT @ID = (SELECT MAX(INSTRUCTOR_ID) FROM INSTRUCTOR) +1

	DECLARE @HHIREDATE DATE = GETDATE()

	IF EXISTS (SELECT INSTRUCTOR_ID FROM INSTRUCTOR WHERE INSTRUCTOR_ID = @ID) 
		BEGIN
			SELECT 'DUPLICATED KEY' AS ERROR_MESSAGE
			SELECT ERROR_NUMBER() AS ErrorNumber ,ERROR_LINE() as ErrorLine, ERROR_MESSAGE() as ErrorMessage
		END
	ELSE
	BEGIN TRY
		INSERT INTO INSTRUCTOR 
		VALUES (@ID,@FNAME,@LNAME,@AGE,@BD,@GENDER,@SAL,@CITY,@HIREDATE,@DEPTID)
	END TRY
	BEGIN CATCH
		SELECT 'ERROR' AS ERROR_MESSAGE
	END CATCH
							
--TEST
EXECUTE InsertInstructor 1,'KHALED','SHAKER',27,'1998-06-16','MALE',5000,'CAIRO','2024-08-15',20
----------------------------------------------------------------------------------------
-- UPDATE INSTRUCTOR SP
-- BEHARVIOR (USER INPUT THE INSTRUCTOR ID , THE TARGET COLUMN AND ITS VALUE TO UPDATE IT )
EXECUTE SelectInstructor
SELECT * FROM Instructor
UPDATE Instructor
SET Instructor_Fname= ' JO '
WHERE Instructor_ID = 1 
ALTER PROC UpdateInstructor @ID INT, @ColName varchar(20) = NULL ,@ValueInt INT = NULL, @Valuechar VARCHAR(50) = NULL
AS
	IF NOT EXISTS (SELECT INSTRUCTOR_ID FROM INSTRUCTOR WHERE INSTRUCTOR_ID = @ID)
		SELECT 'KEY IS NOT EXISTING' 
	BEGIN TRY
		IF @ValueInt IS NOT NULL  
			BEGIN
				EXECUTE (' UPDATE ' + ' instructor  ' + ' SET '+  @ColName + ' = ' + @Valueint + ' WHERE ' + ' INSTRUCTOR_ID '+ ' = ' + @ID )
			END
		IF @Valuechar IS NOT NULL 
			EXECUTE (' UPDATE ' + ' instructor ' + ' SET '+  @ColName + ' = ' + @ValueCHAR + ' WHERE ' + ' INSTRUCTOR_ID '+ ' = ' + @ID )
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
	END CATCH
--TEST 
EXECUTE UpdateInstructor 10,'salary' ,10000,NULL 
---------------------------------------------------------------------------
-- DELETE INSTRUCTOR SP

ALTER PROC DeleteInstructor @ID INT
AS
	IF EXISTS (SELECT INSTRUCTOR_ID FROM Instructor_Register WHERE INSTRUCTOR_ID = @ID)
		OR EXISTS (SELECT Supervisor_ID FROM TRACK WHERE Supervisor_ID = @ID)
		OR EXISTS (SELECT Manager_ID FROM Deptartment WHERE Manager_ID = @ID)
		SELECT ' TABLE HAS RELATION '
	ELSE 
		BEGIN
		DELETE FROM INSTRUCTOR 
		OUTPUT DELETED.INSTRUCTOR_ID , SUSER_NAME() , GETDATE()
		WHERE INSTRUCTOR_ID = @ID 
		END

--TEST
EXECUTE DeleteInstructor 1


-----------------------------------------------------------------------------------------------------------
--2) -- --------------------------------------INST_COURSE TABLE --------------------------------------------------

USE [ Examination]
GO

SELECT * FROM SYS.TABLES WHERE NAME = 'INST_COURSE'
--SELECT INSTRUCTOR_COURSE SP 
CREATE PROC SelectInstCourse 
AS 
	IF NOT EXISTS (SELECT * FROM SYS.TABLES WHERE NAME = 'INST_COURSE')
		BEGIN
			SELECT 'TABLE DOES NOT EXIST'
		END
	ELSE
		SELECT * FROM INST_COURSE  
-- TEST 
EXECUTE selectinstcourSe
------------------------------
SELECT * FROM Inst_Course
--INSERT Inst_Course SP 
Create PROC InsertInstCourse @InstID INT,
							@CourseID INT 
							
AS
	
	IF NOT EXISTS (SELECT I.Instructor_ID FROM Instructor AS I WHERE I.Instructor_ID = @InstID)
		BEGIN
			SELECT 'ID IS NOT EXISTING AT THE PARENT TABLE '
		END
	
	IF NOT EXISTS (SELECT C.Course_ID FROM Course AS C WHERE Course_ID = @CourseID )
		SELECT ' THIS COURSE ID IS NOT EXISTING ' 

	BEGIN TRY
		INSERT INTO Inst_Course (Instructor_ID,Course_ID)
		VALUES (@InstID ,@CourseID)
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ErrorMessage , ERROR_NUMBER() as ErrorNumber
	END CATCH
							
--TEST
select * from Inst_Course      -- SHOW THE TARGET TABLE
EXECUTE InsertInstCourse 1,10   -- work
EXECUTE InsertInstCourse 20,20  -- error

---------------------------------------------------------------
	
-- Update InstCourse Table SP -----
SELECT * FROM Inst_Course
ALTER PROCEDURE UpdateInstCourse
    @InstructorID INT,
    @CourseID INT,
    @NewInstructorID INT,
    @NewCourseID INT
AS
BEGIN
    IF NOT EXISTS (SELECT Instructor_ID FROM instructor WHERE instructor_id = @NewInstructorID)
    BEGIN
        SELECT'New Instructor ID does not exist'
    END

    IF NOT EXISTS (SELECT Course_ID FROM course WHERE course_id = @NewCourseID)
    BEGIN
        SELECT 'New COURSE ID does not exist'
    END
    UPDATE inst_course
    SET instructor_id = @NewInstructorID, course_id = @NewCourseID
    WHERE instructor_id = @InstructorID AND course_id = @CourseID;
END


--TEST 
SELECT * FROM Inst_Course   --- CHOOSE THE TARGET ROW FIRST
EXECUTE UpdateInstCourse 4,1 , 4,1    --WORK 
--------------------------------------------------------------
--- INSERT INST_COURSE TABLE SP

ALTER PROC InsertInstCourse @CourseID INT  ,
							@InstructorID INT
							
AS
	IF NOT EXISTS (SELECT INSTRUCTOR_ID FROM INSTRUCTOR WHERE INSTRUCTOR_ID = @InstructorID) 
		BEGIN
			SELECT 'Instructor ID is not existing'
		END
	
	IF Not EXISTS (SELECT course_id FROM course WHERE course_id = @CourseID) 
		BEGIN
			SELECT 'COURSE ID is not existing'
			SELECT ERROR_NUMBER() AS ErrorNumber ,ERROR_LINE() as ErrorLine, ERROR_MESSAGE() as ErrorMessage
		END
	ELSE
	BEGIN TRY
		INSERT INTO Inst_Course (Course_ID,Instructor_ID)
		VALUES (@CourseID,@InstructorID)
	END TRY
	BEGIN CATCH
		SELECT 'ERROR' AS ERROR_MESSAGE
	END CATCH
SELECT * FROM Inst_Course
--TEST
EXECUTE InsertInstCourse 5,5   --work
--------------------------------------------------------------
-- DELETE INST_COURSE SP

CREATE PROC DeleteInstCourse @InstID int , @CourseID int 
AS
	IF NOT EXISTS (SELECT Instructor_ID FROM Inst_Course WHERE INSTRUCTOR_ID = @InstID)
		SELECT 'INSTRUCTOR ID IS NOT EXISTING '

	IF NOT EXISTS (SELECT COURSE_ID FROM Inst_Course WHERE COURSE_ID = @CourseID )
		SELECT 'COURSE ID IS NOT EXISTING'
	 
	BEGIN TRY
		DELETE FROM Inst_Course
			OUTPUT DELETED.INSTRUCTOR_ID , DELETED.Course_ID , SUSER_NAME() , GETDATE()
		WHERE INSTRUCTOR_ID = @InstID AND Course_ID = @CourseID
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
	END CATCH

--TEST
EXECUTE SelectInstCourse   -- SHOW THE TABLE
EXECUTE DeleteInstCourse 2 ,2    --WORK

----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
--3) -- --------------------------------------TRACK_COURSE TABLE ------------------------------------------

SELECT * FROM Track_Course


---- SELECT TRACK_COURSE TABLE SP

CREATE PROC SelectTrackCourse
AS 
	IF NOT EXISTS (SELECT * FROM SYS.TABLES WHERE NAME = 'TRACK_COURSE')
		BEGIN
			SELECT 'TABLE DOES NOT EXIST'
		END
	ELSE
		SELECT * FROM TRACK_COURSE 
-- TEST 
EXECUTE SelectTrackCourse
---------------------------------------------
--INSERT Track_Course SP 

Create PROC InsertTrackCourse @TrackID INT,
							@CourseID INT 
							
AS
	
	IF NOT EXISTS (SELECT T.Track_ID FROM Track AS T WHERE T.Track_ID = @TrackID)
		BEGIN
			SELECT 'ID IS NOT EXISTING AT THE PARENT TABLE '
		END
	
	IF NOT EXISTS (SELECT C.Course_ID FROM Course AS C WHERE Course_ID = @CourseID )
		SELECT ' THIS COURSE ID IS NOT EXISTING ' 

	BEGIN TRY
		INSERT INTO Track_Course (Track_ID,Course_ID)
		VALUES (@TrackID ,@CourseID)
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ErrorMessage , ERROR_NUMBER() as ErrorNumber
	END CATCH
							
--TEST
select * from Track_Course      -- SHOW THE TARGET TABLE
EXECUTE InsertTrackCourse 1,4   -- work
EXECUTE InsertTrackCourse 20,20  -- error
-----------------------------------------------------
-- Update InstCourse Table SP -----

ALTER PROCEDURE UpdateTrackCourse
    @TrackID INT,
    @CourseID INT,
    @NewTrackID INT,
    @NewCourseID INT
AS
BEGIN
    IF NOT EXISTS (SELECT Track_ID FROM Track WHERE Track_ID = @NewTrackID)
    BEGIN
        SELECT'New Track ID does not exist'
    END

    IF NOT EXISTS (SELECT Course_ID FROM course WHERE course_id = @NewCourseID)
    BEGIN
        SELECT 'New COURSE ID does not exist'
    END
    UPDATE Track_Course 
    SET Track_ID = @NewTrackID, course_id = @NewCourseID
    WHERE Track_ID = @TrackID AND course_id = @CourseID
END


--TEST 
SELECT * FROM Track_Course   --- CHOOSE THE TARGET ROW FIRST
EXECUTE UpdateTrackCourse 1,4 , 1,8    --WORK 
------------------------------------------------------------------------------------
-- DELETE TRACK_COURSE SP

ALTER PROC DeleteTrackCourse @TrackID int , @CourseID int 
AS
	IF NOT EXISTS (SELECT Track_ID FROM Track_Course WHERE Track_ID = @TrackID)
		SELECT 'Track ID IS NOT EXISTING '

	IF NOT EXISTS (SELECT COURSE_ID FROM Track_Course WHERE COURSE_ID = @CourseID )
		SELECT 'COURSE ID IS NOT EXISTING'
	 
	BEGIN TRY
		DELETE FROM Track_Course
			OUTPUT DELETED.Track_ID, DELETED.Course_ID , SUSER_NAME() , GETDATE()
		WHERE Track_ID = @TrackID AND Course_ID = @CourseID
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
	END CATCH

--TEST
EXECUTE SelectTrackCourse-- SHOW THE TABLE
EXECUTE DeleteTrackCourse 1 ,7    --WORK
------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
--4) -- --------------------------------------STUDENT_COURSE TABLE ------------------------------------------
SELECT * FROM Stud_Course
SELECT * FROM SYS.TABLES WHERE NAME = 'INST_COURSE'
--SELECT INSTRUCTOR_COURSE SP 
CREATE PROC SelectStudCourse
AS 
	IF NOT EXISTS (SELECT * FROM SYS.TABLES WHERE NAME = 'Stud_Course')
		BEGIN
			SELECT 'TABLE DOES NOT EXIST'
		END
	ELSE
		SELECT * FROM Stud_Course  
-- TEST 
EXECUTE SelectStudCourse
------------------------------------------------------------------

--------- INSERT STUD_COURSE TABLE SP
----------------------------------
Create PROC InsertStudCourse @St_ID INT,
							@CourseID INT ,
							@ST_GRADE INT = NULL,
							@EXAM_ID INT = NULL
				
							
AS
	
	IF NOT EXISTS (SELECT T.ST_ID FROM STUDENT AS T WHERE T.ST_ID = @St_ID)
		BEGIN
			SELECT 'STUDENT ID IS NOT EXISTING AT THE PARENT TABLE '
		END
	
	IF NOT EXISTS (SELECT C.Course_ID FROM Course AS C WHERE Course_ID = @CourseID )
		SELECT ' THIS COURSE ID IS NOT EXISTING ' 

	IF NOT EXISTS (SELECT E.Exam_ID FROM EXAM AS E WHERE Exam_ID = @EXAM_ID )
		SELECT ' THIS EXAM ID IS NOT EXISTING ' 


	BEGIN TRY
		INSERT INTO STUD_COURSE (ST_ID,Course_ID,ST_GRADE,EXAM_ID)
		VALUES (@St_ID ,@CourseID , @ST_GRADE ,@EXAM_ID)
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ErrorMessage , ERROR_NUMBER() as ErrorNumber
	END CATCH
							
--TEST
select * from Stud_Course      -- SHOW THE TARGET TABLE
EXECUTE InsertStudCourse 1,4,60,1   -- work
EXECUTE InsertStudCourse 20,20  -- error
-------------------------------------------------------
-- Update STUD_COURSE Table SP -----
select * from Stud_Course
CREATE PROCEDURE UpdateStudCourse
    @StID INT,
    @CourseID INT,
	@St_Grade INT,
	@Exam_ID INT,
    @NewSt_ID INT,
    @NewCourseID INT,
	@New_St_Grade INT,
	@New_Exam_ID INT

AS
    IF NOT EXISTS (SELECT ST_ID FROM STUDENT WHERE ST_ID = @NewSt_ID)
    BEGIN
        SELECT'New STUDENT ID does not exist'
    END

    IF NOT EXISTS (SELECT Course_ID FROM course WHERE course_id = @NewCourseID)
    BEGIN
        SELECT 'New COURSE ID does not exist'
	END

    IF NOT EXISTS (SELECT EXAM_ID FROM EXAM WHERE EXAM_ID = @New_Exam_ID )
    BEGIN
        SELECT 'New EXAM ID does not exist'
    END

	BEGIN TRY
		UPDATE STUD_COURSE 
		SET ST_ID = @NewSt_ID, course_id = @NewCourseID , ST_GRADE = @New_St_Grade ,
				Exam_ID = @New_Exam_ID
		WHERE St_ID = @StID AND course_id = @CourseID
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
	END CATCH 



--TEST 
SELECT * FROM Stud_Course   --- CHOOSE THE TARGET ROW FIRST
EXECUTE UpdateStudCourse 1,4 , 60 ,1 , 1,4,80,2    --WORK 
-----------------------------------------------------------------------
-- DELETE STUD_COURSE  SP
execute SelectStudCourse

CREATE PROC DeleteStudCourse @ST_ID int , @CourseID int 
AS
	IF NOT EXISTS (SELECT ST_ID FROM STUDENT WHERE ST_ID = @ST_ID)
		SELECT 'STUDENT ID IS NOT EXISTING '

	IF NOT EXISTS (SELECT COURSE_ID FROM Track_Course WHERE COURSE_ID = @CourseID )
		SELECT 'COURSE ID IS NOT EXISTING'
	 
	BEGIN TRY
		DELETE FROM STUD_COURSE
			OUTPUT DELETED.St_ID, DELETED.Course_ID , SUSER_NAME() , GETDATE()
		WHERE St_ID = @ST_ID AND Course_ID = @CourseID
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
	END CATCH

--TEST
EXECUTE SelectStudCourse-- SHOW THE TABLE
EXECUTE DeleteStudCourse 2  ,7    --WORK

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
--5) -- --------------------------------------DEPARTMENT TABLE ----------------------------------------


--SELECT DEPARTMENT SP 
ALTER PROC SelectDepartment 
AS 
	IF NOT EXISTS (SELECT * FROM SYS.TABLES WHERE NAME = 'Deptartment')
		BEGIN
			SELECT 'TABLE DOES NOT EXIST'
		END
	ELSE
		SELECT * FROM Deptartment 
-- TEST 
EXECUTE SelectDepartment  

---------------------------------------------------------------------------
--INSERT DEPARTMENT SP 
CREATE PROC InsertDepartment @Dept_ID INT = NULL ,
							@Dept_Name VARCHAR(50) ,
							@Dept_Location VARCHAR(50) = NULL,
							@Dept_Description  VARCHAR(50) = NULL,
							@Manager_ID INT = NULL
AS					
	IF @Dept_ID = NULL 
		SELECT 'PLEASE ENTER THE DEPARTMENT  VALUE '

	IF EXISTS (SELECT DEPT_ID FROM Deptartment WHERE Dept_ID = @Dept_ID) 
		BEGIN
			SELECT 'DEPARTMENT ID DUPLICATED KEY' AS ERROR_MESSAGE
			SELECT ERROR_NUMBER() AS ErrorNumber ,ERROR_LINE() as ErrorLine, ERROR_MESSAGE() as ErrorMessage
		END

	IF NOT EXISTS (SELECT INSTRUCTOR_ID FROM Instructor WHERE Instructor_ID = @Manager_ID )
		SELECT 'INSTRUCTOR ID IS NOT EXISTING'
	
	BEGIN TRY
		INSERT INTO Deptartment 
		VALUES (@Dept_ID,@Dept_Name,@Dept_Location,@Dept_Description,@Manager_ID)
	END TRY
	BEGIN CATCH
		SELECT 'ERROR' AS ERROR_MESSAGE
	END CATCH
							
--TEST 
EXECUTE SELECTDEPARTMENT      --- TO SHOW THE DEPARTMENT TABLE
EXECUTE InsertDepartment 80 ,'SD' , 'CAIRO' , 'SYSTEM DEVELOPEMENT ' , 7
----------------------------------------------------------------------------------------
-- UPDATE DEPARTMENT  SP
EXECUTE SelectDepartment  

ALTER PROC UpdateDepartment @Dept_ID INT, @ColName varchar(20) = NULL ,@ValueInt INT = NULL, @Valuechar VARCHAR(50) = NULL
AS
	IF NOT EXISTS (SELECT Dept_ID FROM Deptartment WHERE Dept_ID = @Dept_ID)
		SELECT 'KEY IS NOT EXISTING' 
	BEGIN TRY
		IF @ValueInt IS NOT NULL  
			BEGIN
				EXECUTE (' UPDATE ' + ' Department ' + ' SET '+  @ColName + ' = ' + @Valueint + ' WHERE ' + ' Dept_ID '+ ' = ' + @Dept_ID )
			END
		IF @Valuechar IS NOT NULL 
			EXECUTE (' UPDATE ' + ' Department ' + ' SET '+  @ColName + ' = ' + @ValueCHAR + ' WHERE ' + ' INSTRUCTOR_ID '+ ' = ' + @Dept_ID )
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() , ERROR_LINE()
	END CATCH
--TEST 
EXECUTE SELECTDEPARTMENT   --TO SHOW THE TABLE
EXECUTE UpdateDepartment 80,'Dept_Name',null,'EB'
---------------------------------------------------------------------------
-- DELETE DEPARTMENT SP

ALTER PROC DeleteDepartment @Dept_ID INT
AS
	IF EXISTS (SELECT Dept_ID FROM Instructor WHERE Dept_ID = @Dept_ID)
		OR EXISTS (SELECT Dept_ID FROM Instructor WHERE Dept_ID = @Dept_ID)
		SELECT ' TABLE HAS RELATION '
	ELSE 
		BEGIN
		DELETE FROM Department  
		OUTPUT DELETED.DEPT_ID , DELETED.DEPT_NAME , SUSER_NAME() , GETDATE()
		WHERE DEPT_ID = @DEPT_ID  
		END

--TEST
EXECUTE SELECTDEPARTMENT 
EXECUTE DeleteDepartment 80   --WORK
--------------------------------------------------------------------------------
		--										THANK YOU                    -------


---------------------------------------------------------------------------


-- SELECT STUDENTEXAMINFO SP
CREATE OR ALTER PROC SelectStudentExamInfo @ST_ID INT 
AS
	IF NOT EXISTS (SELECT ST_ID FROM Student WHERE ST_ID =@ST_ID )
		SELECT ' THIS STUDENT ID IS NOT EXISTING'
	ELSE
		SELECT * FROM Student_Exam_Info WHERE ST_ID = @ST_ID 

-------- TEST
EXEC SelectStudentExamInfo 1
------------------------------------------------------------------
-- INSERT STUDENTEXAMINFO SP


Create OR ALTER PROC InsertStudExamInfo @St_ID INT,
										@ExamID INT             --- COUNT QUESTION_GRADE = 1 FROM STUDEBT_EXAM
							
							
AS
	
	IF NOT EXISTS (SELECT T.ST_ID FROM STUDENT AS T WHERE T.ST_ID = @St_ID)
		BEGIN
			SELECT 'STUDENT ID IS NOT EXISTING AT THE PARENT TABLE '
		END
	
	IF NOT EXISTS (SELECT C.Exam_ID FROM Exam AS C WHERE Exam_ID = @ExamID )
		SELECT ' THIS EXAM ID IS NOT EXISTING ' 

	DECLARE @EXAM_DATE DATETIME = GETDATE()       -----FIXED PARARMETER (EXAM TIME)

	DECLARE @ANSWERED_QUESTIONS INT 
	SELECT @ANSWERED_QUESTIONS = COUNT(Question_Grade)    FROM Student_Exam
		WHERE Question_Grade =1

	BEGIN TRY
	INSERT INTO Student_Exam_Info 
	VALUES (@St_ID , @ExamID ,@EXAM_DATE , @ANSWERED_QUESTIONS)
	END TRY
	BEGIN CATCH
		SELECT 'ERROR' AS WARNING
	END CATCH
------ TEST
EXEC InsertStudExamInfo  1, 1
-------------------------------------------------------------------------------
------- UPDATE SELECTEXAMINFO SP

SELECT * FROM Student_Exam_Info

CREATE OR ALTER PROC UpdateStudExamInfo @ST_ID INT ,
								@COLNAME VARCHAR(20) ,
								@VALUEINT INT =NULL ,
								@VALUECHAR VARCHAR(20) = NULL

AS

	BEGIN TRY

		IF NOT EXISTS (SELECT ST_ID FROM Student_Exam_Info WHERE ST_ID = @ST_ID)
			SELECT 'STUDENT ID IS NOT EXISTING'
		ELSE
			IF @VALUEINT IS NOT NULL
				BEGIN
					UPDATE Student_Exam_Info
					SET @COLNAME = @VALUEINT
					WHERE ST_ID = @ST_ID 
			IF @VALUECHAR IS NOT NULL
				UPDATE Student_Exam_Info
				SET @COLNAME = @VALUECHAR
				WHERE ST_ID = @ST_ID
				END
		END TRY
		BEGIN CATCH
			SELECT 'ERROR'
		END CATCH
---------TEST
SELECT * FROM Student_Exam_Info     --- TO SHOW THE TABLE
EXEC UpdateStudExamInfo 1 , 'EXAM_ID' , 1 , NULL  --- WORK
--------------------------------------------------------------
-- DELETE STUDEXAMINFO SP

	
CREATE OR ALTER PROC DeleteStudExamInfo @ST_ID INT , @EXAM_ID INT
AS
	BEGIN TRY
		IF EXISTS (SELECT ST_ID FROM Student WHERE ST_ID = @ST_ID)
			OR EXISTS (SELECT EXAM_ID FROM EXAM WHERE EXAM_ID = @EXAM_ID)
			SELECT ' TABLE HAS RELATION '
		ELSE 
			BEGIN
			DELETE FROM Student_Exam_Info  
			OUTPUT DELETED.ST_ID , DELETED.Exam_ID , SUSER_NAME() , GETDATE()
			WHERE ST_ID = @ST_ID AND Exam_ID = @EXAM_ID   
			END
	END TRY
	BEGIN CATCH
		SELECT 'ERROR'  , ERROR_MESSAGE() , ERROR_LINE()
	END CATCH

--TEST
SELECT * FROM Student_Exam_Info   -- TO SHOW THE TABLE
EXECUTE SelectStudSelectStudentExamInfo 1 ,1 



------------------------------Youssif Tables-----------------------------------------------
--------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------Registeration Stored Procedures----

---INSERT
ALTER PROC Register_New_Member
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






ALTER TABLE TRACK
ADD TrackID   INT 

UPDATE TRACK
SET TrackID = Track_ID;

ALTER TABLE TRACK
DROP COLUMN Track_ID;


------------------------------Khaled Tables-----------------------------------------------
--------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

USE [ Examination]
GO

-- GENERATE TABLES SP 

-- 1)-- --------------------------------------INSTRUCTOR TABLE --------------------------------------------------

--SELECT INSTRUCTOR SP 
CREATE OR ALTER PROC SelectInstructor @ID INT 
AS 
	IF NOT EXISTS (SELECT * FROM SYS.TABLES WHERE NAME = 'INSTRUCTOR')
		BEGIN
			SELECT 'TABLE DOES NOT EXIST'
		END
	ELSE
		SELECT * FROM INSTRUCTOR WHERE INSTRUCTOR_ID = @ID

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
							
----------------------------------------------------------------------------------------
-- UPDATE INSTRUCTOR SP
-- BEHARVIOR (USER INPUT THE INSTRUCTOR ID , THE TARGET COLUMN AND ITS VALUE TO UPDATE IT )

CREATE OR ALTER PROC UpdateInstructor @ID INT, @ColName varchar(20) = NULL ,@ValueInt INT = NULL, @Valuechar VARCHAR(50) = NULL
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

---------------------------------------------------------------------------
-- DELETE INSTRUCTOR SP

CREATE OR ALTER PROC DeleteInstructor @ID INT
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




-----------------------------------------------------------------------------------------------------------
--2) -- --------------------------------------INST_COURSE TABLE --------------------------------------------------

CREATE OR ALTER PROC SelectInstCourse 
AS 
	IF NOT EXISTS (SELECT * FROM SYS.TABLES WHERE NAME = 'INST_COURSE')
		BEGIN
			SELECT 'TABLE DOES NOT EXIST'
		END
	ELSE
		SELECT * FROM INST_COURSE  

------------------------------
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
							


---------------------------------------------------------------
	
-- Update InstCourse Table SP -----

CREATE OR ALTER PROCEDURE UpdateInstCourse
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


--------------------------------------------------------------
--- INSERT INST_COURSE TABLE SP

CREATE OR ALTER PROC InsertInstCourse @CourseID INT  ,
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

--------------------------------------------------------------
-- DELETE INST_COURSE SP

CREATE OR ALTER  PROC DeleteInstCourse @InstID int , @CourseID int 
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


----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
--3) -- --------------------------------------TRACK_COURSE TABLE ------------------------------------------



---- SELECT TRACK_COURSE TABLE SP

CREATE OR ALTER PROC SelectTrackCourse
AS 
	IF NOT EXISTS (SELECT * FROM SYS.TABLES WHERE NAME = 'TRACK_COURSE')
		BEGIN
			SELECT 'TABLE DOES NOT EXIST'
		END
	ELSE
		SELECT * FROM TRACK_COURSE 
---------------------------------------------
--INSERT Track_Course SP 

Create OR ALTER  PROC InsertTrackCourse @TrackID INT,
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
							
-----------------------------------------------------
-- Update InstCourse Table SP -----

CREATE OR ALTER PROCEDURE UpdateTrackCourse
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


------------------------------------------------------------------------------------
-- DELETE TRACK_COURSE SP

CREATE OR ALTER PROC DeleteTrackCourse @TrackID int , @CourseID int 
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
------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
--4) -- --------------------------------------STUDENT_COURSE TABLE ------------------------------------------

CREATE OR ALTER PROC SelectStudCourse
AS 
	IF NOT EXISTS (SELECT * FROM SYS.TABLES WHERE NAME = 'Stud_Course')
		BEGIN
			SELECT 'TABLE DOES NOT EXIST'
		END
	ELSE
		SELECT * FROM Stud_Course  

------------------------------------------------------------------

--------- INSERT STUD_COURSE TABLE SP
----------------------------------
Create OR ALTER PROC InsertStudCourse @St_ID INT,
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
							
-------------------------------------------------------
-- Update STUD_COURSE Table SP -----

CREATE OR ALTER  PROCEDURE UpdateStudCourse
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



-----------------------------------------------------------------------
-- DELETE STUD_COURSE  SP


CREATE OR ALTER PROC DeleteStudCourse @ST_ID int , @CourseID int 
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


-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
--5) -- --------------------------------------DEPARTMENT TABLE ----------------------------------------


--SELECT DEPARTMENT SP 
CREATE OR ALTER PROC SelectDepartment 
AS 
	IF NOT EXISTS (SELECT * FROM SYS.TABLES WHERE NAME = 'Deptartment')
		BEGIN
			SELECT 'TABLE DOES NOT EXIST'
		END
	ELSE
		SELECT * FROM Deptartment 


---------------------------------------------------------------------------
--INSERT DEPARTMENT SP 
CREATE OR ALTER PROC InsertDepartment @Dept_ID INT = NULL ,
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
							

----------------------------------------------------------------------------------------
-- UPDATE DEPARTMENT  SP
EXECUTE SelectDepartment  

CREATE OR ALTER  PROC UpdateDepartment @Dept_ID INT, @ColName varchar(20) = NULL ,@ValueInt INT = NULL, @Valuechar VARCHAR(50) = NULL
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

---------------------------------------------------------------------------
-- DELETE DEPARTMENT SP

CREATE OR ALTER PROC DeleteDepartment @Dept_ID INT
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

-------------------------------------------------------------------------------
------- UPDATE SELECTEXAMINFO SP


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





----------------------REPORTING PROCEDURES-------------------
/*
•	Report that returns the students information according to Department No parameter.
*/


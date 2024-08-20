
-----------------------------Registeration Stored Procedures----

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




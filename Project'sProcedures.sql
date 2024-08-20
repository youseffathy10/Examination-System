
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


----------------------REPORTING PROCEDURES-------------------
/*
•	Report that returns the students information according to Department No parameter.
*/


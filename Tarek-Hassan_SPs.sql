--Stored Procedures

--1. Course Table
--a) Select

CREATE PROCEDURE SelectCourse @id INT
AS

	IF EXISTS (SELECT 1 FROM Course WHERE Course_ID =@id) 
		BEGIN
		   SELECT * 
		   FROM Course
		   WHERE Course_ID = @id
		END
	ELSE
		BEGIN
			SELECT  'Please enter a valid Course ID.'
		END

----------
--b) Insert
CREATE PROCEDURE InsertCourse @name VARCHAR(30), @duration INT, @level VARCHAR(20), @Topic VARCHAR(50)
AS
IF EXISTS (SELECT 1 FROM Course WHERE Course_Name =@name) 
	BEGIN
		SELECT 'This Course already exists'
	END
ELSE
	BEGIN
		
		INSERT INTO Course
		VALUES((SELECT MAX(course_id)+1 FROM Course),
		@name, @duration, @level);
		
		DECLARE @CourseID INT
		SET @CourseID = (SELECT Course_ID FROM Course WHERE Course_name = @name)

		DECLARE @TopicID INT
		
		IF EXISTS (SELECT 1 FROM Topic WHERE Topic_Name = @Topic)
			BEGIN
				SET @TopicID = (SELECT topic_id FROM Topic WHERE Topic_Name = @Topic)
			END
		ELSE 
			BEGIN
				EXEC InsertTopic @Topic;
				SET @TopicID = (SELECT MAX(Topic_ID) FROM Topic)
			END;
		EXEC InsertCourseTopic @CourseID, @TopicID

	END


-----------
--c) Delete
CREATE PROCEDURE DeleteCourse @CourseID INT
AS
	IF EXISTS (SELECT 1 FROM Course WHERE Course_ID =@CourseID) 
		BEGIN
		   EXEC DeleteCourseTopic @CourseID;

		   DELETE c 
		   FROM Choice c
		   JOIN Question q
		   ON q.Question_ID = c.Choice_ID
		   JOIN Course crs
		   ON crs.Course_ID = q.Question_ID
		   WHERE crs.Course_ID = @CourseID;

		   DELETE e_q
		   FROM Exam_Quest e_q
		   JOIN Exam e
		   ON e.Exam_ID = e_q.Exam_ID
		   JOIN Course crs
		   ON crs.Course_ID = e.Course_ID
		   WHERE crs.Course_ID = @CourseID;

		   DELETE FROM Exam
		   WHERE Course_id = @CourseID;

		   DELETE q
		   FROM Question q
		   JOIN Course crs
		   ON crs.Course_ID = q.Course_ID
   		   WHERE crs.Course_ID = @CourseID;

		   DELETE i_c
		   FROM Inst_Course i_c
		   JOIN Course crs
		   ON crs.Course_ID = i_c.Course_ID
   		   WHERE crs.Course_ID = @CourseID;

		   DELETE FROM Course
		   WHERE Course_ID = @CourseID;

		END
	ELSE
		BEGIN
			SELECT  'Please enter a valid Course ID.'
		END

-----------
--d) Update
CREATE PROCEDURE UpdateCourse @id INT, @name VARCHAR(30), @duration INT, @level VARCHAR(20)
AS
	IF EXISTS (SELECT 1 FROM Course WHERE Course_ID =@id) 
		BEGIN
		   UPDATE Course
		   SET 
		   Course_Name = @name,
		   Course_Duration = @duration, 
		   Course_Level = @level
		   WHERE Course_ID = @id
		END
	ELSE
		BEGIN
			SELECT  'Please enter a valid Course ID.'
		END
	
--------------------------------------------------------------------------------------------------------------------------------
--2. Exam Table
--a) Select

CREATE PROCEDURE SelectExam @id INT
AS

	IF EXISTS (SELECT 1 FROM Exam WHERE Exam_ID =@id) 
		BEGIN
		   SELECT * 
		   FROM Exam
		   WHERE Exam_ID = @id
		END
	ELSE
		BEGIN
			SELECT  'Please enter a valid Exam ID.'
		END
----------
--b) Insert
-- Used within Exam generation
CREATE PROCEDURE InsertExam @name VARCHAR(30), @duration INT, @qs INT, @grade INT, @course_id INT
AS
IF EXISTS(SELECT 1 FROM Course WHERE Course_ID = @course_id)
	BEGIN
		DECLARE @date DATETIME
		SET @date = GETDATE()
		INSERT INTO Exam
		VALUES((SELECT MAX(Exam_id)+1 FROM Exam),
		@name, @duration, @date, @qs , @grade , @course_id )
	END
ELSE
	BEGIN
		SELECT 'Please enter a valid course ID'
	END


-----------
--c) Delete
CREATE PROCEDURE DeleteExam @id INT
AS
	IF EXISTS (SELECT 1 FROM Exam WHERE Exam_ID =@id) 
		BEGIN
		   EXEC DeleteExamQuestion @id
		   DELETE FROM Exam
		   WHERE Exam_ID = @id
		END
	ELSE
		BEGIN
			SELECT  'Please enter a valid Exam ID.'
		END

-----------
--d) Update
CREATE PROCEDURE UpdateExam @id INT, @name VARCHAR(30), @duration INT, @date DATE, @qs INT, @grade INT, @course_id INT
AS
	IF EXISTS (SELECT 1 FROM Exam WHERE Exam_ID =@id) 
		BEGIN
			IF EXISTS (SELECT 1 FROM Course WHERE Course_ID =@course_id) 
				BEGIN
				   UPDATE Exam
				   SET 
				   Exam_title = @name,
				   Exam_Duration = @duration, 
				   Exam_Date = @date,
				   Quest_Nums = @qs,
				   Exam_Grade = @grade,
				   Course_ID = @Course_id
				   WHERE Exam_ID = @id
				END
			ELSE
				BEGIN
					SELECT 'Please enter a valid Course ID'
				END
		END
	ELSE
		BEGIN
			SELECT  'Please enter a valid Exam ID.'
		END
--------------------------------------------------------------------------------------------------------------------------------
--3. Topic Table
--a) Select

CREATE PROCEDURE SelectTopic @id INT
AS

	IF EXISTS (SELECT 1 FROM Topic WHERE Topic_ID =@id) 
		BEGIN
		   SELECT * 
		   FROM Topic
		   WHERE  Topic_ID = @id
		END
	ELSE
		BEGIN
			SELECT  'Please enter a valid Topic ID.'
		END
----------
--b) Insert
CREATE PROCEDURE InsertTopic @name VARCHAR(50)
AS
IF EXISTS (SELECT 1 FROM Topic WHERE Topic_Name =@name) 
	BEGIN
		SELECT 'This Topic already exists'
	END
ELSE
	INSERT INTO Topic
	VALUES((SELECT MAX(Topic_id)+10 FROM Topic),
	@name)

-----------
--c) Delete
CREATE PROCEDURE DeleteTopic @id INT
AS
	IF EXISTS (SELECT 1 FROM Topic WHERE Topic_ID =@id) 
	BEGIN
	   DELETE FROM Topic
	   WHERE Topic_ID = @id
	END
	ELSE
	BEGIN
		SELECT  'Please enter a valid Topic ID.'
	END

-----------
--d) Update
CREATE PROCEDURE UpdateTopic @id INT, @name VARCHAR(50)
AS
	IF EXISTS (SELECT 1 FROM Topic WHERE Topic_ID =@id) 
		BEGIN
		   UPDATE Topic
		   SET 
		   Topic_Name = @name
		   WHERE Topic_ID = @id
		END
	ELSE
		BEGIN
			SELECT  'Please enter a valid Topic ID.'
		END

--------------------------------------------------------------------------------------------------------------------------------
--4. Course_Topic Table
--a) Select
CREATE PROCEDURE SelectCourseTopic @course_id INT
AS

	IF EXISTS (SELECT 1 FROM Course WHERE Course_ID =@course_id) 
		BEGIN
				SELECT * 
				FROM Course_Topic
				WHERE Course_ID = @course_id
		END
	ELSE
		BEGIN
			SELECT  'Please enter a valid Course ID.'
		END

---------
--b) Insert
CREATE PROCEDURE InsertCourseTopic @course_id INT, @topic_id INT
AS
IF EXISTS (SELECT 1 FROM Course_Topic WHERE Course_ID =@course_id)
	BEGIN	
		SELECT 'This Course already exists'
	END
ELSE
	BEGIN
		INSERT INTO Course_Topic
		VALUES(@course_id, @topic_id)
	END

-----------
--c) Delete
CREATE PROCEDURE DeleteCourseTopic @CourseID INT
AS
	IF EXISTS (SELECT 1 FROM Course_topic WHERE Course_ID =@CourseID) 
	BEGIN
	   DELETE FROM Course_Topic
	   WHERE Course_ID = @CourseID
	END
	ELSE
	BEGIN
		SELECT  'Please enter a valid Course ID.'
	END

-----------
--d) Update
CREATE PROCEDURE UpdateCourseTopic @CourseID INT, @TopicID INT
AS
	IF EXISTS (SELECT 1 FROM Course WHERE Course_ID =@CourseID) 
		BEGIN
		   UPDATE Course_Topic
		   SET Topic_ID = @TopicID
		   WHERE Course_ID = @CourseID
		END
	ELSE
		BEGIN
			SELECT  'Please enter a valid Course ID.'
		END
-------------------------------------------------------------------------------------------------------------
--5. Questions Table
--a) Select

CREATE PROCEDURE SelectQuestion @id INT
AS

	IF EXISTS (SELECT 1 FROM Question WHERE Question_ID =@id) 
		BEGIN
		   SELECT * 
		   FROM Question
		   WHERE Question_ID = @id
		END
	ELSE
		BEGIN
			SELECT  'Please enter a valid Question ID.'
		END
----------
--b) Insert
CREATE PROCEDURE InsertQuestion @Type VARCHAR(20), @ModelAnswer VARCHAR(100), @Question VARCHAR(500), @course_id INT, @Choice1 VARCHAR(100), @Choice2 VARCHAR(100),
@Choice3 VARCHAR(100), @Choice4 VARCHAR(100)
AS
	IF EXISTS (SELECT 1 FROM Course WHERE Course_ID =@course_id) 
		BEGIN
			INSERT INTO Question
			VALUES((SELECT MAX(Question_id)+1 FROM Question),
			@Type, @ModelAnswer, @Question , @course_id );

			DECLARE @QuestionID INT
			SET @QuestionID = (SELECT MAX(Question_ID) FROM Question)
			EXEC InsertChoice @QuestionID, @Choice1
			EXEC InsertChoice @QuestionID, @Choice2
			EXEC InsertChoice @QuestionID, @Choice3
			EXEC InsertChoice @QuestionID, @Choice4

		END
	ELSE
		BEGIN
			SELECT 'Please enter a valid Course ID'
		END


-----------
--c) Delete
CREATE PROCEDURE DeleteQuestion @id INT
AS
	IF EXISTS (SELECT 1 FROM Question WHERE Question_ID =@id) 
		BEGIN
		   DELETE FROM Choice
		   WHERE Question_ID=@id;
		   DELETE FROM Exam_Quest
		   WHERE Question_ID = @id;
		   DELETE FROM Question
		   WHERE Question_ID = @id;

		END
	ELSE
		BEGIN
			SELECT 'Please enter a valid Question ID.'
		END
-----------
--d) Update
CREATE PROCEDURE UpdateQuestion @id INT, @type VARCHAR(20), @ModelAnswer VARCHAR(100), @Question VARCHAR(500), @course_id INT
AS
	IF EXISTS (SELECT 1 FROM Question WHERE Question_ID =@id) 
		BEGIN
			IF EXISTS (SELECT 1 FROM Course WHERE Course_ID =@course_id) 
				BEGIN
				   UPDATE Question
				   SET 
				   Question_Type = @type,
				   Question_ModelAnswer = @ModelAnswer, 
				   Question = @Question,
				   Course_ID = @Course_id				   
				   WHERE Question_ID = @id
				END
			ELSE
				BEGIN
					SELECT 'Please enter a valid Course ID'
				END
		END
	ELSE
		BEGIN
			SELECT  'Please enter a valid Question ID.'
		END
--------------------------------------------------------------------------------------------------------------------------------
--6. Choice Table
--a) Select

CREATE PROCEDURE SelectChoice @id INT
AS

	IF EXISTS (SELECT 1 FROM Choice WHERE Choice_ID =@id) 
		BEGIN
		   SELECT * 
		   FROM Choice
		   WHERE Choice_ID = @id
		END
	ELSE
		BEGIN
			SELECT  'Please enter a valid Choice ID.'
		END
----------
--b) Insert
CREATE PROCEDURE InsertChoice @QuestionID INT, @Choice VARCHAR(100)
AS
	IF EXISTS (SELECT 1 FROM Question WHERE Question_ID =@QuestionID) 
		BEGIN
			DECLARE @Is_Correct INT
			SET @Is_Correct = (
			CASE 
				WHEN @Choice = (SELECT Question_ModelAnswer FROM Question WHERE Question_ID = @QuestionID) THEN 1
				ELSE 0
				END)
			INSERT INTO Choice
			VALUES((SELECT MAX(Choice_id)+1 FROM Choice),
			@QuestionID, @Choice, @Is_Correct)
		END
	ELSE
		BEGIN
			SELECT 'Please enter a valid Question ID'
		END

-----------
--c) Delete
CREATE PROCEDURE DeleteChoice @id INT
AS
	IF EXISTS (SELECT 1 FROM Choice WHERE Choice_ID =@id) 
		BEGIN
		   DELETE FROM Choice
		   WHERE Choice_ID = @id
		END
	ELSE
		BEGIN
			SELECT 'Please enter a valid Choice ID.'
		END
-----------
--d) Update
CREATE PROCEDURE UpdateChoice @id INT, @Question_id INT, @Choice VARCHAR(100)
AS
	IF EXISTS (SELECT 1 FROM Choice WHERE Choice_ID =@id) 
		BEGIN
			IF EXISTS (SELECT 1 FROM Question WHERE Question_ID =@Question_id) 
				BEGIN
					DECLARE @Is_Correct INT
					SET @Is_Correct = (
					CASE 
						WHEN @Choice = (SELECT Question_ModelAnswer FROM Question WHERE Question_ID = @Question_id) THEN 1
						ELSE 0
					END)
				
					   UPDATE Choice
					   SET 
					   Question_ID = @Question_id,
					   Choice = @Choice				   
					   WHERE Question_ID = @id
				END
			ELSE
				BEGIN
					SELECT 'Please enter a valid Question ID'
				END
		END
	ELSE
		BEGIN
			SELECT  'Please enter a valid Choice ID.'
		END
--------------------------------------------------------------------------------------------------------------------------------
--7. Exam_Quest Table
--a) Select
CREATE PROCEDURE SelectExamQuest @Exam_id INT
AS

	IF EXISTS (SELECT 1 FROM Exam WHERE Exam_ID =@Exam_id) 
		BEGIN
				SELECT * 
				FROM Exam_Quest
				WHERE Exam_ID = @Exam_id
		END
	ELSE
		BEGIN
			SELECT  'Please enter a valid Exam ID.'
		END

---------
--b) Insert
CREATE PROCEDURE InsertExamQuestion @Exam_id INT, @Question_id INT
AS
IF EXISTS (SELECT 1 FROM Exam_Quest WHERE Exam_ID =@exam_id)
	BEGIN	
		SELECT 'This Exam already exists'
	END
ELSE
	BEGIN
		INSERT INTO Exam_Quest
		VALUES(@Exam_id, @Question_id)
	END

-----------
--c) Delete
CREATE PROCEDURE DeleteExamQuestion @Exam_id INT
AS
	IF EXISTS (SELECT 1 FROM Exam_Quest WHERE Exam_ID =@Exam_ID) 
	BEGIN
	   DELETE FROM Exam_Quest
	   WHERE Exam_ID =@Exam_ID
	END
	ELSE
	BEGIN
		SELECT  'Please enter a valid Exam ID.'
	END

-----------
--d) Update
CREATE PROCEDURE UpdateExamQuest @ExamID INT, @QuestionID INT
AS
	IF EXISTS (SELECT 1 FROM Exam WHERE Exam_ID =@ExamID) 
		BEGIN
		   UPDATE Exam_Quest
		   SET 
		   Question_ID = @QuestionID
		   WHERE Exam_ID = @ExamID
		END
	ELSE
		BEGIN
			SELECT 'Please enter a valid Exam ID.'
		END
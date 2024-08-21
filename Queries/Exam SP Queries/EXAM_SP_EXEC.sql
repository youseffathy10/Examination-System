-- ------------------------------------------------------EXAM GENERATION SP------------------------
 
 -- CREATE A FUNCTION TO GENERATE A RANDOM NUMBER BETWEEN SPECFIC RANGE 

 --BECAUE WE CAN'T USE RAND() FUNCTION INSIDE USER-DEFINED FUNCTION
 -- CREATE VIEW FOR A RANDOM NUM
 SELECT RAND()

CREATE VIEW vRandomNumber
AS
SELECT RAND() AS RandomValue
--CREATE A FUNCTION

ALTER FUNCTION GenerateRandomNumber(@Min INT =109024 , @Max INT =990465 )
RETURNS INT
AS
BEGIN
    DECLARE @RandomValue FLOAT
    SELECT @RandomValue = RandomValue FROM vRandomNumber;
    RETURN FLOOR(@Min + (@RandomValue * (@Max - @Min + 1)))
END

SELECT DBO.GENERATERANDOMNUMBER (109024 , 990465)  --TEST THE FUNCTION
----------------------------------------------------------------------

CREATE OR ALTER PROC GenerateExam 
						@EXTITLE VARCHAR(50) = NULL ,
						@COURSEID INT ,
						@TFNUMBER INT = 5 ,
						@MCQNUMBER INT = 5
AS 
	DECLARE  @EXID INT = (SELECT MAX(EXAM_ID) +1 FROM EXAM)
		

	IF NOT EXISTS (SELECT C.Course_ID FROM Course AS C WHERE C.Course_ID = @COURSEID)
		SELECT 'THIS COURSE DOES NOT EXIST'

	IF @EXTITLE IS NULL 
		SELECT @EXTITLE = (SELECT COURSE_NAME FROM Course WHERE COURSE_ID = @COURSEID)

	-- DECLARE FIXED PARAMETERS 
	DECLARE @EXDURATION INT = 60 , @EXDATE DATE = GETDATE() , @QUESTNUM INT = 10 , @EXGRADE INT = 60 

----- ----GENERATE AN EXAM WITH 10 RANDOM QUESTIONS---------------
BEGIN TRY
	INSERT INTO EXAM 
	VALUES (@EXID , @EXTITLE , @EXDURATION ,@EXDATE , @QUESTNUM , @EXGRADE , @COURSEID)  -- INSERT INTO EXAM TABLE
	
	-- SELECT True/False QUESTIONS RELATED TO THE SAME COURSE
            INSERT INTO Exam_Quest (EXAM_ID, Question_ID)
            SELECT TOP (@TFNUMBER) @EXID , Q.Question_ID
            FROM Question Q
            WHERE Q.Course_ID  = @COURSEID AND Q.Question_Type = 'True/false'
            ORDER BY NEWID()



	-- SELECT MCQ QUESTIONS RELATED TO THE SAME COURSE
			 INSERT INTO Exam_Quest (EXAM_ID, Question_ID)
				SELECT TOP (@MCQNUMBER) @EXID , Q.Question_ID
				FROM Question Q
				WHERE Q.Course_ID  = @COURSEID AND Q.Question_Type = 'MCQ'
				ORDER BY NEWID()
	
	-- SELECT THEH EXAM MODEL
		--	SELECT   Q.Question_ID , Q.Question
        --    FROM Exam_Quest AS EQ INNER JOIN  Question AS Q
		--		ON EQ.Question_ID = Q.Question_ID
		--	JOIN EXAM AS E
		--		ON E.EXAM_ID = EQ.EXAM_ID AND EQ.EXAM_ID = @EXID
		-- SELECT THE EXAM MODEL 
			SELECT E.Exam_ID,
				Q.Question_ID,
				Q.Question,
				STRING_AGG(C.Choice, ', ') WITHIN GROUP (ORDER BY C.Choice_ID) AS Choices
			FROM 
				Exam_Quest AS EQ
			INNER JOIN Question AS Q 
				ON EQ.Question_ID = Q.Question_ID
			INNER JOIN EXAM AS E 
				ON E.EXAM_ID = EQ.EXAM_ID AND EQ.EXAM_ID = @EXID
			INNER JOIN Choice AS C
				ON C.Question_ID = Q.Question_ID
			GROUP BY 
				Q.Question_ID, Q.Question,E.Exam_ID
		
END TRY
BEGIN CATCH
	SELECT ERROR_NUMBER(),ERROR_LINE(),ERROR_MESSAGE() 
END CATCH


---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

--------------------------- EXAM ANSWERS SP -------------------------------------------------

CREATE OR ALTER PROCEDURE SaveExamAnswers
	@ST_ID INT,
    @ExAM_ID INT,
    @Question_ID INT,
	@Student_Answer VARCHAR(50)
   
AS
BEGIN TRY
	IF NOT EXISTS (SELECT * FROM Exam WHERE EXAM_ID = @EXAM_ID)
		BEGIN
            SELECT 'The EXAM DOES NOT EXIST' AS 'ErrMessage'
        END
	ELSE IF NOT EXISTS (SELECT * FROM Question WHERE QUESTION_ID = @QUESTION_ID)
	    BEGIN
            SELECT 'THE QUESTION DOES NOT EXIST' AS 'ErrMessage'
        END
	ELSE IF NOT EXISTS (SELECT * FROM Student WHERE ST_ID = @ST_ID)
	    BEGIN
            SELECT 'THIS STUDENT DOES NOT EXIST' AS 'ErrMessage'
        END
	ELSE
        BEGIN    ------------- INSERT AND SAVE THE STUDENT ANSWER
			INSERT INTO Student_Exam (ST_ID,EXAM_ID,QUESTION_ID,STUDENT_ANSWER)
			VALUES (@ST_ID,@ExAM_ID,@Question_ID,@Student_Answer)
		END
END TRY
				
BEGIN CATCH
	SELECT ERROR_MESSAGE() AS ErrorMessage
END CATCH
----------------------------



----------------------------------------------------
--------------------------- EXAM CORRECTION SP -------------------------------------------------


CREATE OR ALTER PROCEDURE ExamCorrection
    @St_ID INT,
    @Exam_ID INT
AS
BEGIN TRY
	IF NOT EXISTS (SELECT * FROM Exam WHERE EXAM_ID = @Exam_ID)
	    BEGIN
            SELECT 'THIS EXAM ID IS NOT EXISTING' AS 'ErrMessage'
        END
    ELSE IF NOT EXISTS (SELECT * FROM Student WHERE ST_ID = @ST_ID)
	    BEGIN
            SELECT 'THIS STUDENT IS NOT EXISTING' AS 'ErrMessage'
        END
    ELSE
        BEGIN
            -- Update Student_Exam (Grade) based on the student's answers
            UPDATE Student_Exam
            SET Question_Grade = IIF(Q.Question_ModelAnswer= SE.Student_Answer,1,0) 
            FROM Student_Exam SE
            INNER JOIN Choice C 
				ON SE.Question_ID = C.Question_ID
			INNER JOIN Question AS Q
				ON Q.Question_ID = C.Question_ID
            WHERE SE.Exam_ID = @Exam_ID AND SE.ST_ID= @St_ID


            -- Calculate the total number of correct answers
            DECLARE @TotalCorrectAnswers INT
            SELECT @TotalCorrectAnswers = SUM(Question_Grade)
            FROM Student_Exam 
            WHERE Exam_ID = @Exam_ID AND St_ID = @St_ID
       
            -- Calculate the grade in percentage
            DECLARE @GradePercentage DECIMAL(5, 1)
            SELECT @GradePercentage = (@TotalCorrectAnswers * 100.0) / COUNT(Question_ID)
			FROM Student_Exam
			WHERE Exam_ID = @Exam_ID AND ST_ID = @St_ID

            -- Return THE GRADE PERCENTAGE
            SELECT @GradePercentage AS GradePercentage
        END
 
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE() AS errorMessage
END CATCH



		

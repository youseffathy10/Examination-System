----------------------REPORTING PROCEDURES-------------------
/*
•	Report that returns the students information according to Department No parameter.
*/

CREATE OR ALTER PROC Get_Student_info_By_track
@track_id int
WITH ENCRYPTION 
AS
	BEGIN
	IF EXISTS(SELECT TrackID FROM TRACK WHERE  TrackID = @track_id)
		BEGIN
				SELECT st.*
				FROM Student st
				JOIN Track tr
				ON st.Track_ID = Tr.TrackID
				WHERE tr.TrackID = @track_id
		END
	ELSE
		SELECT 'Track is not found' AS WARNING
	END

EXEC Get_Student_info_By_track 


DROP PROC Get_Student_info_By_track

/*
•	Report that takes the student ID and returns the grades of the student in all courses. %
*/




CREATE OR ALTER PROC Get_St_grades
@st_id int 
WITH ENCRYPTION
AS
	BEGIN
		IF EXISTS(SELECT 1 FROM Student WHERE ST_ID = @st_id)
			BEGIN
				SELECT st.ST_Fname,st.ST_Lname, crs.Course_Name,st_crs.St_Grade
				FROM Student st
				JOIN Stud_Course st_crs
				ON st.ST_ID = st_crs.St_ID
				JOIN Course crs
				ON st_crs.Course_ID = crs.Course_ID
				WHERE st.ST_ID = @st_id
			END
	END 

EXEC Get_St_grades 1

DROP PROC Get_St_grades

/*
•Report that takes the instructor ID and returns the name of the courses that he teaches and the number of student per course.

*/

CREATE OR ALTER PROC Get_Courses_Instructor_Teaches
@ins_id INT 
AS
	BEGIN
		 
		 SELECT ins.Instructor_Fname, ins.Instructor_Lname, crs.Course_Name,COUNT(stud.ST_ID) AS [number of students]
		 FROM Instructor ins
		 JOIN Inst_Course ins_crs 
		 ON ins.Instructor_ID = ins_crs.Instructor_ID
		 JOIN Course crs
		 ON ins_crs.Course_ID = crs.Course_ID
		 JOIN Stud_Course st_crs
		 ON st_crs.Course_ID = crs.Course_ID
		 JOIN Student stud
		 ON stud.ST_ID = st_crs.St_ID
		 WHERE ins.Instructor_ID = @ins_id
		 GROUP BY ins.Instructor_Fname, ins.Instructor_Lname, crs.Course_Name
	END

EXEC Get_Courses_Instructor_Teaches 7

DROP PROC Get_Courses_Instructor_Teaches
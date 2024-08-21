
select * from Certificates
---------------------------------------------------------------------Certificate--------------------------------------------------------------------------------------------------
--Select Certificate
create or alter procedure SelectCertificates @Certification_id int
as 
Begin
	if not exists (select * from sys.tables where name = 'Certificates')
	select 'Table is Not Existing' as Warning
	else
	select * from Certificates
	where Certification_id = @Certification_id

End

exec SelectCertificates 300
----------------------------------------------
--Insert Certificates
create or alter procedure InsertCertificates
											
											@Certification_Name varchar(100),
											@Certificate_Hour int,
											@Certificate_Website varchar(50),
											@Certificate_URL varchar(120) =Null,
											@Certificate_Date date =Null
as
		declare @Certification_id int=(select max(Certification_id)+1 from dbo.Certificates)
	begin try
		insert into dbo.Certificates
		values(@Certification_id,@Certification_Name,@Certificate_Hour,@Certificate_Website,@Certificate_URL,@Certificate_Date)
		SELECT 'Insert successful' AS Result
	end try
	begin catch
		select 'error' as Warning
	end catch
exec InsertCertificates 'Excel',4,'DataCamp'
-----------------------------------------------------
--update Certificates
CREATE OR ALTER PROCEDURE UpdateCertificates
    @Certification_id int,
    @Certification_Name varchar(100) = NULL,
    @Certificate_Hour int = NULL,
    @Certificate_Website varchar(50) = NULL,
    @Certificate_URL varchar(120) = NULL,
    @Certificate_Date date = NULL
AS
BEGIN
    BEGIN TRY
        UPDATE dbo.Certificates
        SET
            Certification_Name = COALESCE(@Certification_Name, Certification_Name),
            Certificate_Hour = COALESCE(@Certificate_Hour, Certificate_Hour),
            Certificate_Website = COALESCE(@Certificate_Website, Certificate_Website),
            Certificate_URL = COALESCE(@Certificate_URL, Certificate_URL),
            Certificate_Date = COALESCE(@Certificate_Date, Certificate_Date)
        WHERE
            Certification_id = @Certification_id;

    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS Warning;
    END CATCH
END;

exec UpdateCertificates 1,null,null,null,null,'8-20-2024'
---------------------------------------------------
--Delete Certificate
create or alter procedure DeleteCertificate @Certificate_id int
as 
	if exists(select Certificate_ID from Stud_Cert where Certificate_ID=@Certificate_id)
	select 'table has a relation'
	if not exists(select Certification_ID from Certificates where Certification_ID=@Certificate_id)
	select 'This Certificate is not Existing'
	else
	delete from Certificates where Certification_ID=@Certificate_id

exec DeleteCertificate 500

-------------------------------------------------------------------StudCert------------------------------------------------------------------------------------------------------

--Select StudCert
create or alter procedure SelectStudCert @ST_ID int
as 
Begin
	if not exists (select * from sys.tables where name = 'Stud_Cert')
	select 'Table is Not Existing' as Warning
	else

	select sc.*,s.ST_Fname,c.Certification_Name
	from Certificates c join Stud_Cert sc
	on c.Certification_ID=sc.Certificate_ID
	join Student s
	on sc.ST_ID=s.ST_ID
	where sc.ST_ID = @ST_ID

End

exec SelectStudCert 5
------------------------------------------------
--Insert Stud_Cert
CREATE OR ALTER PROCEDURE InsertStudCert
    @ST_ID int,
    @Certificate_ID int
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT * FROM dbo.Student WHERE ST_ID = @ST_ID)
        BEGIN
            SELECT 'Student does not exist in the Student table' AS Warning;
            RETURN;
        END

        IF NOT EXISTS (SELECT * FROM dbo.Certificates WHERE Certification_id = @Certificate_ID)
        BEGIN
            SELECT 'Certificate does not exist in the Certificates table' AS Warning;
            RETURN;
        END

        -- Insert the record into the Stud_Cert table
        INSERT INTO dbo.Stud_Cert (ST_ID, Certificate_ID)
        VALUES (@ST_ID, @Certificate_ID);

        SELECT 'Insert successful' AS Result;
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS Warning;
    END CATCH
END;

exec InsertStudCert 5,10
-----------------------------------------------------------
--Delete Stud_Cert
create or alter procedure DeleteStudCert @st_id int=null,@Certificate_ID int=null
as 
begin
	if @st_id is null 
	begin
		if exists(select Certification_ID from Certificates where Certification_ID=@Certificate_ID)
		delete from Stud_Cert where Certificate_ID=@Certificate_ID 
	end
	if @Certificate_ID is null
	begin
		if exists(select st_id from Student where ST_ID=@st_id)
		delete from Stud_Cert where ST_ID=@st_id
	end
	else
	begin
		if exists(select st_id from Student where ST_ID=@st_id)
		if exists(select Certification_ID from Certificates where Certification_ID=@Certificate_ID)
		delete from Stud_Cert where ST_ID=@st_id and Certificate_ID=@Certificate_ID 
	end
end

exec DeleteStudCert @st_id=200

select distinct(Certification_ID) from Certificates
select * from Stud_Cert
-------------------------------------------------------------------Freelancing----------------------------------------------------------------------------------------------------
select * from Freelancing
--select freelancing
create or alter procedure SelectCertificates @Freelanc_ID int
as 
Begin
	if not exists (select * from sys.tables where name = 'Freelancing')
	select 'Table is Not Existing' as Warning
	else
	select f.*,s.ST_Fname
	from Freelancing f join Student s
	on f.ST_ID=s.ST_ID
	where Freelanc_ID = @Freelanc_ID

End
exec SelectCertificates 1
-------------------------------------------------------------
--insert freelance

create or alter procedure InsertFreelance
											
											@Job_Name varchar(50),
											@Job_Website varchar(50),
											@Job_StartDate date,
											@Job_Tools varchar(30),
											@Feedback_Rating int,
											@st_id int
as
		declare @Freelanc_ID int=(select max(Freelanc_ID)+1 from dbo.Freelancing)
	begin try
		insert into dbo.Freelancing
		values(@Freelanc_ID,@Job_Name,@Job_Website,@Job_StartDate,@Job_Tools,@Feedback_Rating,@st_id)
		SELECT 'Insert successful' AS Result
	end try
	begin catch
		select 'error' as Warning
	end catch

exec InsertFreelance 'BI','5amsat','8-20-2024','Power BI','4',5

select * from Freelancing
--------------------------------------------------------------
--update Freelancing

CREATE OR ALTER PROCEDURE UpdateFreelancing
    @Freelanc_id int,
    @Job_Name varchar(50) = NULL,
    @Job_Website varchar(50) = NULL,
    @Job_StartDate date = NULL,
    @Job_Tools varchar(30) = NULL,
    @Feedback_Rating int = NULL,
    @st_id int = NULL
AS
BEGIN
    BEGIN TRY
        UPDATE dbo.Freelancing
        SET
            Job_Name = COALESCE(@Job_Name, Job_Name),
            Job_Website = COALESCE(@Job_Website, Job_Website),
            Job_StartDate = COALESCE(@Job_StartDate, Job_StartDate),
            Job_Tools = COALESCE(@Job_Tools, Job_Tools),
            Feedback_Rating = COALESCE(@Feedback_Rating, Feedback_Rating),
            st_id = COALESCE(@st_id, st_id)
        WHERE
            Freelanc_id = @Freelanc_id;

        
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS Warning;
    END CATCH
END;

exec UpdateFreelancing 96, @Job_Website='khamsat'

select * from Freelancing
-------------------------------------------
--Delete freelance
create or alter procedure DeleteFreelance @st_id int
as 
	if not exists(select st_id from Freelancing where ST_ID=@st_id)
	select 'This Student is not Existing'
	else
	delete from Freelancing where ST_ID=@st_id

exec DeleteFreelance 5
-----------------------------------------------------------------------Hiring-----------------------------------------------------------------------------------------------------

--Select Hiring
create or alter procedure SelectHiring @Hiring_ID int
as 
Begin
	if not exists (select * from sys.tables where name = 'Hiring')
	select 'Table is Not Existing' as Warning
	else

	select h.*,s.ST_Fname
	from Hiring h join Student s
	on h.ST_ID=s.ST_ID
	where Hiring_ID = @Hiring_ID

End

exec SelectHiring 5
----------------------------------------------
--Insert Hiring
create or alter procedure InsertHiring
											
											@Position varchar(100),
											@Hiring_Date date,
											@Company varchar(50),
											@Location varchar(20) = null,
											@Positon_Type varchar(20) = null,
											@st_id int
										   
as
		declare @Hiring_ID int=(select max(Hiring_ID)+1 from dbo.Hiring)
	begin try
		insert into dbo.Hiring
		values(@Hiring_ID,@Position,@Hiring_Date,@Company,@Location,@Positon_Type,@st_id)
		SELECT 'Insert successful' AS Result
	end try
	begin catch
		select 'error' as Warning
	end catch
exec InsertHiring 'BI','8-21-2024','_VOIS',null,null,125
-----------------------------------------------------
--update Certificates
CREATE OR ALTER PROCEDURE UpdateHiring
    @Hiring_id int,
    @Position varchar(100) = NULL,
    @Hiring_Date date = NULL,
    @Company varchar(50) = NULL,
    @Location varchar(20) = NULL,
    @Positon_Type varchar(20) = NULL,
    @st_id int = NULL
AS
BEGIN
    BEGIN TRY
        UPDATE dbo.Hiring
        SET
            Position = COALESCE(@Position, Position),
            Hiring_Date = COALESCE(@Hiring_Date, Hiring_Date),
            Company = COALESCE(@Company, Company),
            Location = COALESCE(@Location, Location),
            Positon_Type = COALESCE(@Positon_Type, @Positon_Type),
            st_id = COALESCE(@st_id, st_id)
        WHERE
            Hiring_id = @Hiring_id;

        IF @@ROWCOUNT = 0
        BEGIN
            SELECT 'No rows affected' AS Warning;
        END
        ELSE
        BEGIN
            SELECT 'Update successful' AS Result;
        END
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS Warning;
    END CATCH
END;


EXEC UpdateHiring 
    @Hiring_id = 1, 
    @Position = 'Senior Data Analyst', 
    @Company = 'Updated Corp';

---------------------------------------------------
--Delete Hiring
create or alter procedure DeleteHiring @st_id int
as 
	if not exists(select st_id from Hiring where ST_ID=@st_id)
	select 'This Student is not Existing'
	else
	delete from Hiring where ST_ID=@st_id

exec DeleteHiring 500











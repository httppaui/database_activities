use midtermdb;

-- create VIEW
-- display empID, fullname, gender, birthdate, emptype
-- or replace: update view
-- if null: if the value is null it will be replaced with empty string

create or replace view vwEmployeeList 
as
select EmpID, concat(FirstName,' ',IFNULL(MiddleName,''),' ',LastName) as 'fullname', Gender, Birthdate, EmpType 
from EMPLOYEE;

-- CAN ALSO BE: select EmpID, fnGetFullName(EmpID) as fullname, Gender, Birthdate, EmpType from EMPLOYEE

select * from vwemployeelist;
select fullname from vwemployeelist;

update EMPLOYEE
set MiddleName = null
where EmpID = '10005';

-- create FUNCTION
-- delimiter: start and end point of whole function or stored procedure
-- a function can accept a parameter

delimiter $$
CREATE FUNCTION fnGetFullName
(
	EmpID varchar(5)
)
returns varchar(150) deterministic -- identify what data type to be returned

BEGIN -- begin and end: has three separate line of statements (declare, select, return)
	declare fullname varchar(150);
    select concat(FirstName,' ',IFNULL(MiddleName,''),' ',LastName)
    into fullname
    from EMPLOYEE e
    where e.EmpID = EmpID;
    -- e.EmpID is from table/ EmpID is the one to be passed to the function
    
    return fullname; -- actual output
END
$$

select fnGetFullName('10007');

-- create a function to determine if an employee is an hourly employee or salaried employee
-- based on ID number

delimiter $$
CREATE FUNCTION GetEmployeeCategory(EmpID varchar(5))
RETURNS varchar(20) DETERMINISTIC
BEGIN
	DECLARE empCategory varchar(20);
    
    IF EXISTS(SELECT 1 FROM HOURLYEMPLOYEE WHERE EmpID = EmpID) THEN
		SET empCategory = 'Hourly Employee';
	ELSEIF EXISTS(SELECT 1 FROM SALARIEDEMPLOYEE WHERE EmpID = EmpID) THEN
		SET empCategory = 'Salaried Employee';
	ELSE
		SET empCategory = 'Not Found';
	END IF;
    
    RETURN empCategory;
END
$$

select GetEmployeeCategory('10002') as EmployeeCategory;

-- create a function that returns the basic gross of an employee

delimiter $$
CREATE FUNCTION GetBasicGross(EmpID varchar(5))
RETURNS decimal(18,2) DETERMINISTIC
BEGIN
	DECLARE Gross decimal (18,2);
    DECLARE Rate decimal (8,2);
    DECLARE Hrs decimal (6,2);
    
    SELECT h.Rate, hr.HrsRendered
    INTO Rate, Hrs
    FROM HOURLYEMPLOYEE h 
    JOIN HOURSRENDERED hr 
    ON h.EmpID = hr.EmpID
    WHERE h.EmpID = hr.EmpID;
    
    SET Gross = Rate * Hrs;
    RETURN Gross;
    
END
$$

SELECT e.EmpID,
h.Rate as Rate,
hr.HrsRendered as HoursWorked,
GetBasicGross(e.EmpID) as HourlyEmployeeGrossPay
FROM EMPLOYEE e
JOIN HOURLYEMPLOYEE h ON e.EmpID = h.EmpID
JOIN HOURSRENDERED hr ON e.EmpID = hr.EmpID;

SELECT e.EmpID,
s.BasicSalary,
s.Incentive,
(s.BasicSalary + s.Incentive) as SalariedEmployeeGrossPay
FROM EMPLOYEE e
JOIN SALARIEDEMPLOYEE s ON e.EmpID = s.EmpID

-- create a function that returns the Philhealth contribution based on the Basic Gross of an Employee. Computation is based on the table Philhealth

delimiter $$
CREATE FUNCTION GetPhilHealthContribution(EmpID varchar(5))
RETURNS decimal(18,2) DETERMINISTIC
BEGIN

	DECLARE Gross decimal(18,2);
    DECLARE Rate decimal(8,2);
    DECLARE Contribution decimal(18,2);
    
    SELECT Rate * (SELECT HrsRendered FROM HOURSRENDERED WHERE EmpID = EmpID LIMIT 1)
    INTO Gross
    FROM HOURLYEMPLOYEE h
    WHERE h.EmpID = EmpID
    LIMIT 1;
    
    IF Gross IS NULL THEN
	SELECT BasicSalary + Incentive INTO Gross
    FROM SALARIEDEMPLOYEE s
    WHERE s.EmpID = EmpID
    LIMIT 1;
    
    END IF;
    
    IF Gross <= 10000 THEN
		SET Rate = 0.05;
	ELSEIF Gross <= 99999.99 THEN
		SET Rate = 0.06;
	ELSE 	
		SET Rate = 0.07;
	END IF;
    
    SET Contribution = Gross * Rate;
    RETURN Contribution;
END
$$

SELECT GetPhilHealthContribution('10002') as PhilHealthContribution;

-- Create a function that generates the PAGIBIG contribution of an employee based on its gross pay.

delimiter $$
CREATE FUNCTION GetPagibigContribution(EmpID varchar(5))
RETURNS decimal (18,2) DETERMINISTIC
BEGIN
	DECLARE Gross decimal (18,2);
    DECLARE EERate decimal (5,3);
    DECLARE ERRate decimal (5,3);
    DECLARE Contribution decimal (18,2);
    
    IF EXISTS (SELECT 1 FROM HOURLYEMPLOYEE WHERE EmpID = EmpID) THEN
        SET Gross = (SELECT Rate * HrsRendered FROM HOURLYEMPLOYEE
                     JOIN HOURSRENDERED ON HOURLYEMPLOYEE.EmpID = HOURSRENDERED.EmpID
                     WHERE HOURLYEMPLOYEE.EmpID = EmpID);
    ELSE
        SET Gross = (SELECT BasicSalary + Incentive FROM SALARIEDEMPLOYEE WHERE EmpID = EmpID);
    END IF;
    
     IF Gross <= 5000 THEN
        SET EERate = 0.02;
        SET ERRate = 0.02;
        SET Contribution = (Gross * EERate) + (Gross * ERRate);
    ELSE
        SET Contribution = 200;  
    END IF;

    RETURN Contribution;
END 
$$

-- 	Create a function that generates the SSS Contribution of an employee based on its gross pay and based on where it belongs in the salary range on the SSS table
DELIMITER $$

CREATE FUNCTION GetSSSContribution(EmpID VARCHAR(5))
RETURNS DECIMAL(18,2) DETERMINISTIC
BEGIN
    DECLARE Gross DECIMAL(18,2);
    DECLARE ERSS DECIMAL(18,2);
    DECLARE EREC DECIMAL(18,2);
    DECLARE EESS DECIMAL(18,2);
    DECLARE PFER DECIMAL(18,2);
    DECLARE PFEE DECIMAL(18,2);
    DECLARE Contribution DECIMAL(18,2);

    
    IF EXISTS (SELECT 1 FROM HOURLYEMPLOYEE WHERE EmpID = EmpID) THEN
        SET Gross = (SELECT Rate * HrsRendered 
                     FROM HOURLYEMPLOYEE
                     JOIN HOURSRENDERED ON HOURLYEMPLOYEE.EmpID = HOURSRENDERED.EmpID
                     WHERE HOURLYEMPLOYEE.EmpID = EmpID);
    ELSE
        SET Gross = (SELECT BasicSalary + Incentive FROM SALARIEDEMPLOYEE WHERE EmpID = EmpID);
    END IF;
    
    SELECT ERSS, EREC, EESS, PFER, PFEE 
    INTO ERSS, EREC, EESS, PFER, PFEE
    FROM SSS
    WHERE Gross >= SalaryMin  AND (Gross <= SalaryMax OR SalaryMax IS NULL)
    LIMIT 1;
   
    SET Contribution = ERSS + EREC + EESS + PFER + PFEE;
    
    RETURN Contribution;
END 
$$





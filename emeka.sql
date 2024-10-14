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

-- create a function to determine if an employee is an hourly employee or salaried employee based on ID number

Delimiter $$
CREATE FUNCTION SalariedOrHourly(EmpID varchar(5))
RETURNS varchar (20) DETERMINISTIC
BEGIN  
	DECLARE empCateg varchar (20);

	IF EXISTS (SELECT 1 FROM hourlyemployee h WHERE h.EmpID = EmpID) THEN
		SET empCateg = 'Hourly Employee';
	ELSEIF EXISTS (SELECT 1 FROM salariedemployee s WHERE s.EmpID = EmpID) THEN
		SET empCateg = 'Salaried Employee';
	ELSE
		SET empCateg = 'Not Found';
	END IF;
    
    RETURN empCateg;
END
$$

select SalariedOrHourly('10002') as 'Employee Category';

-- -- Create a function that returns the basic gross of an employee

Delimiter $$
CREATE FUNCTION GetBasicGross(EmpID varchar(5))
RETURNS decimal(18,2) DETERMINISTIC
BEGIN
    DECLARE rate decimal (8,2);
    DECLARE hrs decimal (6,2);
    DECLARE BasicSalary decimal (18,2);
    DECLARE gross decimal (18,2);
    
    IF EXISTS (SELECT 1 FROM hourlyemployee h WHERE h.EmpID = EmpID limit 1) THEN
		SELECT h.Rate, hr.HrsRendered INTO Rate, Hrs 
		FROM HOURLYEMPLOYEE h 
		JOIN HOURSRENDERED hr 
		ON h.EmpID = hr.EmpID
		WHERE h.EmpID = hr.EmpID limit 1;
			SET gross = Rate * Hrs;
            
	ELSEIF EXISTS (SELECT 1 FROM salariedemployee s WHERE s.EmpID = EmpID limit 1) THEN
		SELECT s.Salary INTO BasicSalary
        FROM salariedemployee s
        WHERE s.EmpID = EmpID limit 1;
			SET gross = Salary + Incentive;
	END IF;
    RETURN gross;
END
$$

select GetBasicGross('10003') as 'Basic Gross';

-- create a function that returns the Philhealth contribution based on the Basic Gross of an Employee. Computation is based on the table Philhealth

delimiter $$
CREATE FUNCTION GetPhilHealthContribution(EmpID varchar(5))
RETURNS decimal(18,2) DETERMINISTIC
BEGIN
	DECLARE Gross decimal(18,2);
    DECLARE Rate decimal(8,2);
	DECLARE Hrs decimal(6,2);
    DECLARE Contribution decimal(18,2);
	DECLARE BasicSalary decimal(18,2);
    
    IF EXISTS (SELECT 1 FROM hourlyemployee h WHERE h.EmpID = EmpID limit 1) THEN
        
	SELECT h.Rate * hr.HrsRendered
    INTO Gross
    FROM HOURLYEMPLOYEE h
    JOIN HOURSRENDERED hr 
    ON h.EmpID = EmpID
    WHERE h.EmpID = EmpID
    LIMIT 1;
   
    IF Gross <= 10000 THEN
		SET Rate = 0.05;
	ELSEIF Gross <= 99999.99 THEN
		SET Rate = 0.06;
	ELSE 	
		SET Rate = 0.07;
	END IF;
    
    SET Contribution = Gross * Rate;
               
	ELSEIF EXISTS (SELECT 1 FROM salariedemployee s WHERE s.EmpID = EmpID limit 1) THEN
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
        END IF;
    RETURN contribution;
END
$$

SELECT GetPhilHealthContribution('10003') as PhilHealthContribution;

-- Create a function that generates the PAGIBIG contribution of an employee based on its gross pay.

DELIMITER $$
CREATE FUNCTION GetPagibigContribution(EmpID varchar(5))
RETURNS decimal(18,2) DETERMINISTIC
BEGIN
    DECLARE Gross decimal(18,2);
    DECLARE EERate decimal(5,3);
    DECLARE ERRate decimal(5,3);
    DECLARE Contribution decimal(18,2);
    
    SET Gross = NULL;
    
    -- Check if hourly employee
    IF EXISTS (SELECT 1 FROM HOURLYEMPLOYEE WHERE EmpID = EmpID LIMIT 1) THEN
        SELECT Rate * HrsRendered INTO Gross
        FROM HOURLYEMPLOYEE
        JOIN HOURSRENDERED ON HOURLYEMPLOYEE.EmpID = HOURSRENDERED.EmpID
        WHERE HOURLYEMPLOYEE.EmpID = EmpID LIMIT 1;
    END IF;
    
    -- Check if salaried employee
    IF Gross IS NULL AND EXISTS (SELECT 1 FROM salariedemployee WHERE EmpID = EmpID LIMIT 1) THEN
        SELECT BasicSalary + Incentive INTO Gross
        FROM salariedemployee
        WHERE EmpID = EmpID LIMIT 1;
    END IF;
    
    -- Determine the rate and contribution
    IF Gross IS NOT NULL THEN
        IF Gross <= 5000 THEN
            SET EERate = 0.02;
            SET ERRate = 0.02;
            SET Contribution = (Gross * EERate) + (Gross * ERRate);
        ELSE
            SET Contribution = 200;
        END IF;
    ELSE
        SET Contribution = 0; -- handle case when Gross is not set
    END IF;

    RETURN Contribution;
END$$
select GetPagibigContribution('10002') as 'PAGIBIG Contribution';

-- Create a function that generates the SSS Contribution of an employee based on its basic gross pay and based on where it belongs in the salary range on the SSS table = ERSS + EREC + EESS+ PFER + PFEE

DELIMITER $$

CREATE FUNCTION GetSSSContribution(GrossPay DECIMAL(18, 2))
RETURNS DECIMAL(18, 2) DETERMINISTIC
BEGIN
    DECLARE Contribution DECIMAL(18, 2);
    
    IF GrossPay BETWEEN 0 AND 4249.99 THEN
        SET Contribution = 380.00 + 10.00 + 180.00;
    ELSEIF GrossPay BETWEEN 4250.00 AND 4749.99 THEN
        SET Contribution = 427.50 + 10.00 + 202.50;
    ELSEIF GrossPay BETWEEN 4750.00 AND 5249.99 THEN
        SET Contribution = 475.00 + 10.00 + 225.00;
    ELSEIF GrossPay BETWEEN 5250.00 AND 5749.99 THEN
        SET Contribution = 522.50 + 10.00 + 247.50;
    ELSEIF GrossPay BETWEEN 5750.00 AND 6249.99 THEN
        SET Contribution = 570.00 + 10.00 + 270.00;
    ELSEIF GrossPay BETWEEN 6250.00 AND 6749.99 THEN
        SET Contribution = 617.50 + 10.00 + 292.50;
    ELSEIF GrossPay BETWEEN 6750.00 AND 7249.99 THEN
        SET Contribution = 665.00 + 10.00 + 315.00;
    ELSEIF GrossPay BETWEEN 7250.00 AND 7749.99 THEN
        SET Contribution = 712.50 + 10.00 + 337.50;
    ELSEIF GrossPay BETWEEN 7750.00 AND 8249.99 THEN
        SET Contribution = 760.00 + 10.00 + 360.00;
    ELSEIF GrossPay BETWEEN 8250.00 AND 8749.99 THEN
        SET Contribution = 807.50 + 10.00 + 382.50;
    ELSEIF GrossPay BETWEEN 8750.00 AND 9249.99 THEN
        SET Contribution = 855.00 + 10.00 + 405.00;
    ELSEIF GrossPay BETWEEN 9250.00 AND 9749.99 THEN
        SET Contribution = 902.50 + 10.00 + 427.50;
    ELSEIF GrossPay BETWEEN 9750.00 AND 10249.99 THEN
        SET Contribution = 950.00 + 10.00 + 450.00;
    ELSEIF GrossPay BETWEEN 10250.00 AND 10749.99 THEN
        SET Contribution = 997.50 + 10.00 + 472.50;
    ELSEIF GrossPay BETWEEN 10750.00 AND 11249.99 THEN
        SET Contribution = 1045.00 + 10.00 + 495.00;
    ELSEIF GrossPay BETWEEN 11250.00 AND 11749.99 THEN
        SET Contribution = 1092.50 + 10.00 + 517.50;
    ELSEIF GrossPay BETWEEN 11750.00 AND 12249.99 THEN
        SET Contribution = 1140.00 + 10.00 + 540.00;
    ELSEIF GrossPay BETWEEN 12250.00 AND 12749.99 THEN
        SET Contribution = 1187.50 + 10.00 + 562.50;
    ELSEIF GrossPay BETWEEN 12750.00 AND 13249.99 THEN
        SET Contribution = 1235.00 + 10.00 + 585.00;
    ELSEIF GrossPay BETWEEN 13250.00 AND 13749.99 THEN
        SET Contribution = 1282.50 + 10.00 + 607.50;
    ELSEIF GrossPay BETWEEN 13750.00 AND 14249.99 THEN
        SET Contribution = 1330.00 + 10.00 + 630.00;
    ELSEIF GrossPay BETWEEN 14250.00 AND 14749.99 THEN
        SET Contribution = 1377.50 + 10.00 + 652.50;
    ELSEIF GrossPay BETWEEN 14750.00 AND 15249.99 THEN
        SET Contribution = 1425.00 + 30.00 + 675.00;
    ELSEIF GrossPay BETWEEN 15250.00 AND 15749.99 THEN
        SET Contribution = 1472.50 + 30.00 + 697.50;
    ELSEIF GrossPay BETWEEN 15750.00 AND 16249.99 THEN
        SET Contribution = 1520.00 + 30.00 + 720.00;
    ELSEIF GrossPay BETWEEN 16250.00 AND 16749.99 THEN
        SET Contribution = 1567.50 + 30.00 + 742.50;
    ELSEIF GrossPay BETWEEN 16750.00 AND 17249.99 THEN
        SET Contribution = 1615.00 + 30.00 + 765.00;
    ELSEIF GrossPay BETWEEN 17250.00 AND 17749.99 THEN
        SET Contribution = 1662.50 + 30.00 + 787.50;
    ELSEIF GrossPay BETWEEN 17750.00 AND 18249.99 THEN
        SET Contribution = 1710.00 + 30.00 + 810.00;
    ELSEIF GrossPay BETWEEN 18250.00 AND 18749.99 THEN
        SET Contribution = 1757.50 + 30.00 + 832.50;
    ELSEIF GrossPay BETWEEN 18750.00 AND 19249.99 THEN
        SET Contribution = 1805.00 + 30.00 + 855.00;
    ELSEIF GrossPay BETWEEN 19250.00 AND 19749.99 THEN
        SET Contribution = 1852.50 + 30.00 + 877.50;
    ELSEIF GrossPay BETWEEN 19750.00 AND 20249.99 THEN
        SET Contribution = 1900.00 + 30.00 + 900.00;
    ELSEIF GrossPay BETWEEN 20250.00 AND 20749.99 THEN
        SET Contribution = 1900.00 + 30.00 + 900.00 + 47.50 + 22.50;
    ELSEIF GrossPay BETWEEN 20750.00 AND 21249.99 THEN
        SET Contribution = 1900.00 + 30.00 + 900.00 + 95.00 + 45.00;
    ELSEIF GrossPay BETWEEN 21250.00 AND 21749.99 THEN
        SET Contribution = 1900.00 + 30.00 + 900.00 + 142.50 + 67.50;
    ELSEIF GrossPay BETWEEN 21750.00 AND 22249.99 THEN
        SET Contribution = 1900.00 + 30.00 + 900.00 + 190.00 + 90.00;
    ELSEIF GrossPay BETWEEN 22250.00 AND 22749.99 THEN
        SET Contribution = 1900.00 + 30.00 + 900.00 + 237.50 + 112.50;
    ELSEIF GrossPay BETWEEN 22750.00 AND 23249.99 THEN
        SET Contribution = 1900.00 + 30.00 + 900.00 + 285.00 + 135.00;
    ELSEIF GrossPay BETWEEN 23250.00 AND 23749.99 THEN
        SET Contribution = 1900.00 + 30.00 + 900.00 + 332.50 + 157.50;
    ELSEIF GrossPay BETWEEN 23750.00 AND 24249.99 THEN
        SET Contribution = 1900.00 + 30.00 + 900.00 + 380.00 + 180.00;
    ELSEIF GrossPay BETWEEN 24250.00 AND 24749.99 THEN
        SET Contribution = 1900.00 + 30.00 + 900.00 + 427.50 + 202.50;
    ELSEIF GrossPay >= 24750.00 THEN
        SET Contribution = 1900.00 + 30.00 + 900.00 + 475.00 + 225.00;
    END IF;
    
    RETURN Contribution;
END$$

DELIMITER ;

SELECT GetSSSContribution(15000) as 'SSS Contribution';



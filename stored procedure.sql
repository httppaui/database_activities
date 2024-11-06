-- STORED PROCEDURE
use midtermdb;
-- create sp that will return information of employee
DELIMITER $$
CREATE PROCEDURE spEmployeeSelect
( 
	IN EmpID varchar(5),
    IN LastName varchar(50)
)
BEGIN
	SELECT * 
	FROM Employee e
	WHERE e.EmpID = IFNULL(EmpID, e.EmpID)
	AND e.LastName = IFNULL(LastName, e.lastname);
END
$$

call spEmployeeSelect(null, null);

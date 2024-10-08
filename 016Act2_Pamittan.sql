use empmanagementdb_pamittan_final2;
	
-- Q1. Retrieve the birth date and address of the employees whose name is ‘Martyn D. Campbell’
SELECT Birthdate, Address
FROM Employee
WHERE FName = 'Martyn' AND MInit = 'D' AND LName = 'Campbell';

-- Q2.	Retrieve the name and address of all employees who work for the ‘Marketing’ Department.
SELECT Employee.FName, Employee.LName, Employee.Address FROM Employee 
INNER JOIN Department ON Employee.DNo = Department.DNo
WHERE Department.DName = 'Marketing';

-- Q3.	For every project located in ‘Lexington’, list the project number, the controlling department number and the department’s name.
SELECT Project.PNo, Project.Dno, Department.DName
FROM Project
INNER JOIN Department ON Project.Dno = Department.DNo
WHERE Project.Location = 'Lexington, KY';

-- Q4.	Select all EMPLOYEE SSNs and their Dependents’ Name. SSN of employees without any dependents must also be displayed
SELECT Employee.SSN, Dependent.DependentName
FROM Employee
LEFT JOIN Dependent ON Employee.SSN = Dependent.SSN;

-- Q5.	Retrieve all distinct salary values
select distinct Salary
from Employee;

-- Q6.	Make a list of all project numbers for projects that involve an employee whose last name is ‘Jones’
SELECT DISTINCT Project.PNo
FROM Project
INNER JOIN Workson ON Project.PNo = Workson.PNo
INNER JOIN Employee ON Workson.SSN = Employee.SSN
WHERE Employee.LName = 'Jones';

-- Q7.	Retrieve all employees whose address is in ‘Louisville, Kentucky’
SELECT * FROM Employee
WHERE Address LIKE '%Louisville, KY%';



-- Pamittan, Paula Hewlett
use empmanagementdb_pamittan_final2;

-- Q8.	Display the total number of employees per gender. Show the Gender and then number of employees as columns.
select Gender, count(Gender) as 'number of employees'
from EMPLOYEE e
group by Gender;

-- Q9.	Generate the total hours worked on by each employee in all projects assigned to him/her. 
-- Show the SSN, full name in the format FirstName Middle initial Lastname, Total Hours Rendered
select e.SSN, concat(e.FName, e.MInit, e.LName) as 'full name', sum(w.HrsRendered) as 'Total Hours Rendered'
from EMPLOYEE e
inner join WORKSON w 
on e.SSN = w.SSN
group by SSN, FName, MInit, LName;

-- Q10.	Generate the total number of projects assigned in each department. Show the department number, department name and Number of projects.
select d.DNo, d.Dname, count(p.PNo) as 'number of projects'
from DEPARTMENT d
left join PROJECT p
on d.DNo = p.DNo
group by DNo, Dname;

-- Q11.	Display the total number of dependents per relationship. Display the Relationship and then total number of dependents.
select d.Relationship, count(d.Relationship) as 'number of dependents'
from DEPENDENT d
inner join EMPLOYEE e
on d.SSN = e.SSN
group by Relationship;

-- Q12.	Generate the Number of Employees Per Department. Show the Department number, department name and total employee as columns.
select d.DNo, d.Dname, count(e.SSN) as 'total employees'
from DEPARTMENT d
inner join EMPLOYEE e
on d.DNo = e.DNo
group by DNo, Dname;



-- create a database
CREATE Database IntroDB;
use IntroDB;

-- create tables
CREATE Table Student(
	IDNumber varchar(7) Primary Key,
    FirstName varchar(50) not null,
    MiddleName varchar(50) null,
    LastName varchar(50) not null,
    Gender varchar(6) not null,
    Program varchar(50) not null,
    YearLevel int not null
);

-- populate the table
INSERT INTO Student (IDNumber, FirstName, MiddleName, LastName, Gender, Program, YearLevel)
VALUES ('1901479', 'Paula Hewlett', 'Perocho', 'Pamittan', 'Female', 'BSIT', 3);

INSERT INTO Student()
VALUES ('1901480', 'Pia Hallie', 'Perocho', 'Pamittan', 'Female', 'BSMT', 3);

SELECT * from Student;

Update Student
Set FirstName = 'Peach Hilary',
	LastName = 'Alvior',
    Program = 'SHS',
    YearLevel = 1
Where IDNumber='1901479';
	
Delete From Student 
Where IDNumber = '1901480';
CREATE database EmpManagementDB_Pamittan_Final2;

use EmpManagementDB_Pamittan_Final2;

CREATE table DEPARTMENT(
	DNo tinyint Primary Key,
    Dname varchar(15) not null
);

alter table DEPARTMENT
change column Dname Dname varchar(30) not null;

CREATE table EMPLOYEE(
	SSN char(9) Primary Key,
    Fname varchar(15) not null,
    Lname varchar(15) not null,
    MInit char(1) null,
    Birthdate date not null,
    Address varchar(50) not null,
    Gender char(1) not null,
    Salary mediumint not null,
	DNo tinyint,
	foreign key (DNo) references DEPARTMENT(DNo)
);


CREATE table PROJECT(
	PNo tinyint Primary Key,
    PName varchar(20) not null,
    Location varchar(15) not null,
    DNo tinyint,
	foreign key(DNo) references DEPARTMENT (DNo)
);

CREATE table WORKSON(
	WID tinyint primary key,
    SSN char(9),
    foreign key(SSN) references EMPLOYEE(SSN),
    PNo tinyint,
    foreign key(PNo) references PROJECT(PNo),
    HrsRendered float not null
);

CREATE table DEPLOCATION(
	DLNo tinyint Primary key,
    Location varchar(15) not null,
    DNo tinyint,
	foreign key(DNo) references DEPARTMENT (DNo)
);

CREATE table DEPENDENT(
	DepNo tinyint Primary Key,
    DependentName varchar(15) not null,
    Gender char(1) not null,
    Birthdate date not null,
	Relationship varchar(8) not null,
    SSN char(9),
	foreign key(SSN) references EMPLOYEE(SSN)
    );
    


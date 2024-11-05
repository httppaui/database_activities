use seatworkDB;


-- A.1 CRUD FOR ARTIST

-- For Insert Stored Procedures, usually, all attributes must be declared as input parameters
Delimiter //
CREATE PROCEDURE spArtistInsert
(
	IN id int,
	IN name varchar(100)
)
BEGIN
	INSERT INTO Artist(ArtistID, ArtistName)
	VALUES(id, name);
END
//

-- when executing the stored procedure, make sure that the number of values match the number of parameters declared.
-- make sure as well that you pass values in its proper order
CALL spArtistInsert(111,'Juan Luna');
CALL spArtistInsert(222,'Vicente Manansala');
CALL spArtistInsert(333,'Guillermo Tolentino');
CALL spArtistInsert(444,'Sample Lang')

-- For Select Stored Procedures, input parameters are usually the possible searchable terms or values
Delimiter //
CREATE PROCEDURE spArtistSelect
(
	IN id int,
	IN name varchar(100)
)
BEGIN
	SELECT a.ArtistID, a.ArtistName
	FROM Artist a
	WHERE a.ArtistID=IFNULL(id,a.ArtistID) -- this means that if the value passed to ID is null, then all records are generated, otherwise, it will return matching records only
	AND a.ArtistName=IFNULL(name,a.ArtistName); -- this means that id the value passed to name is null, then all records will be generated, otherwise, it will return matching records only
END
//

CALL spArtistSelect(111,null);
CALL spArtistSelect(null,'Guillermo Tolentino');
CALL spArtistSelect(222,'Vicente Manansala')

-- For Update Stored Procedures, input parameters are usually the primary keys and those updatable values(values that has possibilities to change)
-- Primary keys should not be updated and must be used only to identify specific record based on their unique identifier
Delimiter //
CREATE PROCEDURE spArtistUpdate
(
	IN id int,
	IN name varchar(100)
)
BEGIN
	UPDATE Artist
	SET ArtistName=name
	WHERE ArtistID=ID;
END
//

CALL spArtistUpdate(444,'Updated Sample');
CALL spArtistSelect(null,null); -- check records

-- For Delete Stored Procedures, input parameters are usually the primary keys
Delimiter //
CREATE PROCEDURE spArtistDelete
(
	IN id int
)
BEGIN
	DELETE From Artist
	WHERE ArtistID=ID;
END
//

CALL spArtistDelete(444);
CALL spArtistSelect(null,null); -- check records

-- A.2 CRUD FOR ARTOBJECT
Delimiter //
CREATE PROCEDURE spArtObjectInsert
(
	IN artid int,
	IN title varchar(100),
	IN `desc` varchar(250), -- the ` is used to escape reserved character
	IN artistid int
)
BEGIN
	INSERT INTO ARTOBJECT(ArtID, title, description, ArtistID)
	VALUES(artid, title, `desc`, artistid);
END
//

CALL spArtObjectInsert(1,'Spoliarium', 'The picture recreates a despoiling scene in a Roman circus where dead gladiators are stripped of weapons and garments.' , 111);
CALL spArtObjectInsert(2,'Madonna of the Slums', 'He painted an innovative mother and child, which reflected the poverty in postwar Manila.',222);
CALL spArtObjectInsert(3,'Bonifacio Monument','A group sculpture composed of numerous figures massed around a central obelisk.',333);
CALL spArtObjectInsert(4,'The Ruins','An architectural site of the remains of an ancestral Italian-styled home.',null);
CALL spArtObjectInsert(5,'Sample Art','sample description',null);

Delimiter //
CREATE PROCEDURE spArtObjectSelect
(
	IN artid int,
	IN title varchar(100)
)
BEGIN
	SELECT ao.ArtID, ao.title, ao.description, a.ArtistID, a.ArtistName
	FROM ArtObject ao
	Left JOIN Artist a on ao.ArtistID=a.ArtistID
	WHERE ao.ArtID=IFNULL(artid,ao.ArtID) 
	AND ao.title=IFNULL(title,ao.title);
END
//

CALL spArtObjectSelect(null,null);
CALL spArtObjectSelect(1,null);
CALL spArtObjectSelect(null,'The Ruins');
CALL spArtObjectSelect(3,'Bonifacio Monument');

Delimiter //
CREATE PROCEDURE spArtObjectUpdate
(
	IN artid int,
	IN title varchar(100),
	IN `desc` varchar(250),
	IN artistid int
)
BEGIN
	UPDATE ArtObject ao
	SET ao.Title=title,
		ao.description=`desc`,
		ao.ArtistID=artistid
	WHERE ao.ArtID=artid;
END
//

CALL spArtObjectUpdate(5,'SampleArt', 'sample description',111);
CALL spArtObjectSelect(null,null);

Delimiter //
CREATE PROCEDURE spArtObjectDelete
(
	IN id int
)
BEGIN
	DELETE From ArtObject
	WHERE ArtID=id;
END
//

CALL spArtObjectDelete(5);
CALL spArtObjectSelect(null,null);

-- A.3 CRUD FOR PAINTING

Delimiter //
CREATE PROCEDURE spPaintingInsert
(
	IN artid int,
	IN drawnon varchar(250)
)
BEGIN
	INSERT INTO PAINTING(ArtID, DrawnOn)
	VALUES(artid, drawnon);
END
//

call spPaintingInsert(1,'Canvass');
call spPaintingInsert(2,'Masonite Board');

Delimiter //
CREATE PROCEDURE spPaintingSelect
(
	IN artid int,
	IN title varchar(100),
	IN drawnon varchar(250)
)
BEGIN
	SELECT ao.ArtID, ao.title, ao.description, a.ArtistID, a.ArtistName, p.DrawnOn
	FROM ArtObject ao
	INNER JOIN Artist a on ao.ArtistID=a.ArtistID
	INNER JOIN Painting p on p.ArtID=ao.ArtID
	WHERE ao.ArtID=IFNULL(null,ao.ArtID) 
	AND ao.title=IFNULL( null,ao.title)
	AND p.DrawnOn=IFNULL(drawnon,p.DrawnOn);
END
//

call spPaintingSelect(null,null,null);

Delimiter //
CREATE PROCEDURE spPaintingUpdate
(
	IN artid int,
	IN drawnon varchar(250)
)
BEGIN
	UPDATE Painting
	SET DrawnOn=drawnon
	WHERE ArtID=artid;
END
//
 call spPaintingUpdate(1,'canvas');
 call spPaintingSelect(null,null,null);

Delimiter //
CREATE PROCEDURE spPaintingDelete
(
	IN id int
)
BEGIN
	DELETE From Painting
	WHERE ArtID=ID;
END
//
call spPaintingDelete(1);
call spPaintingSelect(null,null,null);

-- A.4 CRUD FOR SCULPTURE

Delimiter //
CREATE PROCEDURE spSculptureInsert
(
	IN artid int,
	IN height float,
	IN weight float
)
BEGIN
	INSERT INTO Sculpture(ArtID, Height, Weight)
	VALUES(artid, height, weight);
END
//

call spSculptureInsert(3,13.7,150.33)

Delimiter //
CREATE PROCEDURE spSculptureSelect
(
	IN artid int,
	IN title varchar(100),
	IN height float,
	IN weight float
)
BEGIN
	SELECT ao.ArtID, ao.title, ao.description, a.ArtistID, a.ArtistName, s.Height, s.Weight
	FROM ArtObject ao
	INNER JOIN Artist a on ao.ArtistID=a.ArtistID
	INNER JOIN Sculpture s on s.ArtID=ao.ArtID
	WHERE ao.ArtID=IFNULL(artid,ao.ArtID) 
	AND ao.title=IFNULL(title,ao.title)
	AND s.Weight=IFNULL(weight,s.Weight)
	AND s.Height=IFNULL(height,s.Height);
END
//

call spSculptureSelect(null,null,null,null);

Delimiter //
CREATE PROCEDURE spSculptureUpdate
(
	IN artid int,
	IN height float,
	IN weight float
)
BEGIN
	UPDATE Sculpture
	SET Height=height,
		Weight=weight
	WHERE ArtID=artid;
END
//

call spSculptureUpdate(3,23.7,150.33);
call spSculptureSelect(null,null,null,null);

Delimiter //
CREATE PROCEDURE spSculptureDelete
(
	IN id int
)
BEGIN
	DELETE From Sculpture
	WHERE ArtID=ID;
END
//

call spSculptureDelete(3);
call spSculptureSelect(null,null,null,null);


-- B. View
CREATE OR REPLACE VIEW vwArtObjectMasterlist
AS
SELECT ao.ArtID, title, description, ao.ArtistID, a.ArtistName, DrawnOn, Height, Weight
FROM ArtObject ao
LEFT JOIN Artist a on ao.ArtistID=a.ArtistID
LEFT JOIN Painting p on ao.ArtID=p.ArtID
LEFT JOIN Sculpture s on ao.ArtID=s.ArtID

-- Views are considered virtual tables therefore you can use it in a select script as a table
Select * from vwArtObjectMasterlist

-- C1 1.	a function that displays if an Art Object is a Painting, Sculpture or Others

Delimiter //
CREATE FUNCTION fnGetObjectCategory
(
	title varchar(250)
)
returns varchar(20) deterministic
BEGIN
	
	IF EXISTS(SELECT * FROM Painting p INNER JOIN ArtObject ao on p.ArtID=ao.ArtID where ao.title=title)
		THEN return 'Painting';
	
	ELSEIF EXISTS(SELECT * FROM Sculpture s INNER JOIN ArtObject ao on s.ArtID=ao.ArtID where ao.title=title)
		THEN return 'Sculpture';

	ELSE
		return 'Others';
	END IF;
END
//

Select fnGetObjectCategory('The Ruins') as Category;
Select fnGetObjectCategory('Spoliarium') as Category;

Delimiter //
CREATE FUNCTION fnGetCategoryPercentage
(
	category varchar(250)
)
returns char(20) deterministic
BEGIN
	declare total int;
    declare subtotal int;
    declare percentage decimal(5,2);
	
    Select Count(ArtID) into total from ArtObject;
    
    IF category='Painting'
		THEN Select Count(ArtID) into subtotal From painting;
	
	ELSEIF category='Sculpture'
		THEN Select Count(ArtID) into subtotal From sculpture;
	ELSE
		Select Count(ArtID) into subtotal From painting;
        set subtotal=(Select subtotal+Count(ArtID) From sculpture);
        set subtotal=total-subtotal;
	END IF;
    
    set percentage = subtotal/total*100;
    return Concat(convert(percentage,char),'%');
END
//

Select fnGetCategoryPercentage('Other') as percentage;

-- D.

Select *, fnGetObjectCategory(title) as Category
from vwArtObjectMasterlist;
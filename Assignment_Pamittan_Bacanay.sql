use seatworkdb;

-- STORED PROCEDURES FOR ARTIST
-- Insert
DELIMITER $$
CREATE PROCEDURE spInsertArtist
(
	IN p_ArtistID INT,
    IN p_ArtistName VARCHAR(100)
)
BEGIN
    INSERT INTO artist (ArtistID, ArtistName)
    VALUES (p_ArtistID, p_ArtistName);
END;
$$

-- Select
DELIMITER $$
CREATE PROCEDURE spGetArtist (
    IN p_ArtistID INT
)
BEGIN
    SELECT * FROM artist
    WHERE ArtistID = p_ArtistID;
END
$$

-- Update
DELIMITER $$
CREATE PROCEDURE spUpdateArtist (
    IN p_ArtistID INT,
    IN p_ArtistName VARCHAR(100)
)
BEGIN
    UPDATE artist
    SET ArtistName = p_ArtistName
    WHERE ArtistID = p_ArtistID;
END
$$

-- Delete
DELIMITER $$
CREATE PROCEDURE spDeleteArtist (
    IN p_ArtistID INT
)
BEGIN
    DELETE FROM artist
    WHERE ArtistID = p_ArtistID;
END
$$

-- STORED PROCEDURES ART OBJECT
-- Insert
DELIMITER $$
CREATE PROCEDURE spInsertArtObject (
    IN p_ArtID INT,
    IN p_title VARCHAR(50),
    IN p_description VARCHAR(250),
    IN p_ArtistID INT
)
BEGIN
    INSERT INTO ArtObject (ArtID, title, description, ArtistID)
    VALUES (p_ArtID, p_title, p_description, p_ArtistID);
END
$$

-- Select
DELIMITER $$
CREATE PROCEDURE spGetArtObject (
    IN p_ArtID INT
)
BEGIN
    SELECT * FROM ArtObject
    WHERE ArtID = p_ArtID;
END;
$$


-- Update
DELIMITER $$
CREATE PROCEDURE spUpdateArtObject (
    IN p_ArtID INT,
    IN p_title VARCHAR(50),
    IN p_description VARCHAR(250),
    IN p_ArtistID INT
)
BEGIN
    UPDATE ArtObject
    SET title = p_title, description = p_description, ArtistID = p_ArtistID
    WHERE ArtID = p_ArtID;
END
$$

-- Delete
DELIMITER $$
CREATE PROCEDURE spDeleteArtObject 
(
    IN p_ArtID INT
)
BEGIN
    DELETE FROM ArtObject
    WHERE ArtID = p_ArtID;
END;
$$

-- STORED PROCEDURES PAINTING
-- Insert
DELIMITER $$
CREATE PROCEDURE spInsertPainting (
    IN p_ArtID INT,
    IN p_DrawnOn VARCHAR(20)
)
BEGIN
    INSERT INTO Painting (ArtID, DrawnOn)
    VALUES (p_ArtID, p_DrawnOn);
END;
$$

-- Select
DELIMITER $$
CREATE PROCEDURE spGetPainting (
    IN p_ArtID INT,
    IN ao_ArtID INT
)
BEGIN
    SELECT * FROM Painting
    WHERE ArtID = p_ArtID;
END;
$$

-- Update
DELIMITER $$
CREATE PROCEDURE spUpdatePainting (
    IN p_ArtID INT,
    IN p_DrawnOn VARCHAR(20)
)
BEGIN
    UPDATE Painting
    SET DrawnOn = p_DrawnOn
    WHERE ArtID = p_ArtID;
END
$$

-- Delete
DELIMITER $$
CREATE PROCEDURE spDeletePainting (
    IN p_ArtID INT
)
BEGIN
    DELETE FROM Painting
    WHERE ArtID = p_ArtID;
END
$$


-- STORED PROCEDURES SCULPTURE
-- Insert
DELIMITER $$
CREATE PROCEDURE spInsertSculpture (
    IN p_ArtID INT,
    IN p_Weight FLOAT,
    IN p_Height FLOAT
)
BEGIN
    INSERT INTO Sculpture (ArtID, Weight, Height)
    VALUES (p_ArtID, p_Weight, p_Height);
END;
$$

-- Select
DELIMITER $$
CREATE PROCEDURE spGetSculpture (
    IN p_ArtID INT
)
BEGIN
    SELECT * FROM Sculpture
    WHERE ArtID = p_ArtID;
END;

$$

-- Update
DELIMITER $$
CREATE PROCEDURE spUpdateSculpture (
    IN p_ArtID INT,
    IN p_Weight FLOAT,
    IN p_Height FLOAT
)
BEGIN
    UPDATE Sculpture
    SET Weight = p_Weight, Height = p_Height
    WHERE ArtID = p_ArtID;
END;
$$

-- Delete
DELIMITER $$
CREATE PROCEDURE spDeleteSculpture (
    IN p_ArtID INT
)
BEGIN
    DELETE FROM Sculpture
    WHERE ArtID = p_ArtID;
END
$$


-- VIEW ART MASTERLIST 
CREATE OR REPLACE VIEW vwArtMasterList AS
SELECT 
    ao.ArtID,
    ao.title,
    ao.description,
    a.ArtistName,
    p.DrawnOn,
    s.Weight,
    s.Height,
    fnGetArtObjectType(ao.ArtID) AS ArtType -- 
FROM 
    ArtObject ao
LEFT JOIN 
    Artist a ON ao.ArtistID = a.ArtistID
LEFT JOIN 
    Painting p ON ao.ArtID = p.ArtID
LEFT JOIN 
    Sculpture s ON ao.ArtID = s.ArtID;


-- ART OBJECT FUNCTION
DELIMITER $$
CREATE FUNCTION fnGetArtObjectType (
    p_ArtID INT
) RETURNS VARCHAR(20) deterministic
BEGIN
    DECLARE artType VARCHAR(20);
    
   
    IF EXISTS (SELECT 1 FROM Painting WHERE ArtID = p_ArtID) THEN
        SET artType = 'Painting';
   
    ELSEIF EXISTS (SELECT 1 FROM Sculpture WHERE ArtID = p_ArtID) THEN
        SET artType = 'Sculpture';
    
    ELSE
        SET artType = 'Others';
    END IF;
    
    RETURN artType;
END
$$


DELIMITER $$
CREATE FUNCTION GetArtComposition (
    p_Type VARCHAR(20)
) RETURNS DECIMAL(5,2) DETERMINISTIC
BEGIN
    DECLARE total INT;
    DECLARE countType INT;
    DECLARE percentage DECIMAL(5,2);
    
  
    SELECT COUNT(*) INTO total FROM ArtObject;
    
  
    IF p_Type = 'Painting' THEN
        SELECT COUNT(*) INTO countType FROM Painting;
    ELSEIF p_Type = 'Sculpture' THEN
        SELECT COUNT(*) INTO countType FROM Sculpture;
    ELSE
        SELECT COUNT(*) INTO countType FROM ArtObject ao
        WHERE ao.ArtID NOT IN (SELECT ArtID FROM Painting)
          AND ao.ArtID NOT IN (SELECT ArtID FROM Sculpture);
    END IF;
    
    SET percentage = (countType / total) * 100;
    
    RETURN percentage;
END
$$

-- TEST FUNCTION FOR ART COMPOSITION
SELECT GetArtComposition('Painting') AS PaintingPercentage; 
SELECT GetArtComposition('Sculpture') AS SculpturePercentage; 
SELECT GetArtComposition('Others') AS OthersPercentage; 


-- TEST ALL STORED PROCEDURES
-- Insert Artist
call spInsertARtist(444, 'Jake Agcanas');
-- Insert ArtObject
call spInsertArtObject(5, 'Lego House', 'Lorem Ipsum', '444');
-- Insert Painting
call spInsertPainting(3, 'Vellum Board');
-- Insert Sculpture
call spInsertSculpture(1, 10.5, 10);
-- Retrieve Artist
CALL spGetArtist(111);
-- Retrieve ArtObject
CALL spGetArtObject(3);
-- Retrieve Painting
CALL spGetPainting(3);
-- Retrieve Sculpture
CALL spGetSculpture(3);
-- Update Artist
CALL spUpdateArtist(333, 'Fernando C. Amorsolo');
-- Update ArtObject 
CALL spUpdateArtObject(5, 'Planting Rice', 'A painting depicting Filipino farmers harvesting rice.', 444);
-- Update Painting 
CALL spUpdatePainting(5, 'Wooden Panel');
-- Update Sculpture 
CALL spUpdateSculpture(6, 3.0, 1.5);
-- Delete Artist 
CALL spDeleteArtist(444);
-- Delete ArtObject 
CALL spDeleteArtObject(5);
-- Delete Painting 
CALL spDeletePainting(5);
-- Delete Sculpture 
CALL spDeleteSculpture(6);


-- TEST FUNCTION FOR ART OBJECT TYPE
SELECT fnGetArtObjectType(1) AS ArtType; 
SELECT fnGetArtObjectType(2) AS ArtType; -
SELECT fnGetArtObjectType(3) AS ArtType; 
SELECT fnGetArtObjectType(4) AS ArtType; 


-- TEST VIEW FOR ART MASTERLIST
select * from vwArtMasterList;


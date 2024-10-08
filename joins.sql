USE AdvDB1;

-- list of all products
select * from Product;

-- list products with more than 20 
select * from Product
where Quantity>20;

-- quantity >20 price <400
select * from Product
where Quantity>20 AND Price <400;

-- no supplier
select * from Product
where SupplierID is null;

-- items with supplier
select * from Product 
where SupplierID is not null;

-- all products supplied by tokyo traders
SELECT * FROM Product
INNER JOIN Supplier
ON Product.SupplierID = Supplier.SupplierID
WHERE SupplierName ='Tokyo Traders'; 

-- update supplier table
Update Supplier
Set SupplierName ='Tokyo Traders'
where SupplierID = 3;

--  join (LEFT: prioritize product | RIGHT: prioritize supplies)
SELECT * FROM Product
LEFT JOIN Supplier
ON Product.SupplierID = Supplier.SupplierID;

-- productid, productname, supplierid, supplier products supplied by the tokyo traders
select ProductID, ProductName, Product.SupplierID, SupplierName
from Product INNER JOIN Supplier
ON Product.SupplierID = Supplier.SupplierID;


select ProductID, ProductName, Product.SupplierID, SupplierName, Product.CategoryID, CategoryName
from Product INNER JOIN Supplier
ON Product.SupplierID = Supplier.SupplierID
INNER JOIN Category
ON Product.CategoryID = Category.CategoryID;

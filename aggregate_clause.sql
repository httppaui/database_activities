use advdb1;

-- AGGREGATE FUNCTION

-- max/min/avg/sum/count
select max(Price)
From Product;

select min(Price)
from Product;

select avg(Price)
from Product;

select sum(Price) TotalPrice
from Product;

select count(ProductID) as 'Number of products'
from Product;

select count(ProductID) as 'Number of products'
from Product p -- aliasing
inner join Supplier s
on p.SupplierID = s.SupplierID;

-- GROUP BY CLAUSE

-- count how many product for each supplier
select p.SupplierID, SupplierName, count(ProductID) as 'number of products'
from Product p
inner join Supplier s
on p.SupplierID = s.SupplierID
group by SupplierID;





use advdb1;
-- LIKE operator (for searching)

-- % or _ 
-- %: replace any multiple characters
-- _: represents single character
select * from Product
where ProductName like 'S%S';

select * from Product
where ProductName like 'S%';

select * from Product
where ProductName like '%S';

select * from Product
where ProductName like 'S_____';

-- distinct: generate unique values
select distinct SupplierID
from Product;
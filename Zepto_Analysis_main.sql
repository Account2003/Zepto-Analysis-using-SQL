drop table if exists zepto;
create table zepto(
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock BOOLEAN,
quantity INTEGER
);
--data exploration
--count of rows
SELECT COUNT(*) from zepto;
--sample data
SELECT * FROM zepto
LIMIT 10;

--null values
SELECT * FROM zepto
WHERE name IS NULL
OR
category IS NULL
OR
mrp IS NULL
OR
discountPercent IS NULL
OR
discountSellingPrice IS NULL
OR
weightInGms IS NULL
OR
availableQuantity IS NULL
OR
outOfStock IS NULL
OR
quantity IS NULL;

--different product categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;

--products in stocks vs out of stocks
SELECT outOfStock,COUNT(sku_id)
FROM zepto
GROUP BY outOfStock;

--product name present multiple times
SELECT name, COUNT(sku_id) as "No. of SKUs"
FROM zepto
GROUP BY name
HAVING count(sku_id)>1
ORDER BY count(sku_id) DESC

--data cleanig

--product price =0
SELECT * FROM zepto
WHERE mrp = 0 OR discountSellingPrice = 0;
DELETE FROM zepto 
WHERE mrp=0;

--paisa to rupees
UPDATE zepto 
SET mrp=mrp/100.0,
discountSellingPrice =discountSellingPrice/100.0;
SELECT mrp,discountSellingPrice FROM zepto
--Top 10 best value product
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;
--High value Item but out of stock
SELECT DISTINCT name,mrp
FROM zepto
WHERE outOfStock = TRUE and mrp > 300
ORDER BY mrp DESC;
--Estimated revenue from each category 
SELECT category,
SUM (discountSellingPrice * availableQuantity) AS total_revenue
FROM zepto
Group by category
order by total_revenue;
--product mrp>500 and discount<10%
Select distinct name,mrp,discountPercent
from zepto
where mrp>500 and discountPercent <10
order by mrp desc, discountPercent desc;

--top 5 category offering highest avg discount percentage--used for marketing
select category,
Round(Avg(discountPercent),2) as avg_discount
from zepto
group by category
order by avg_discount desc
limit 5;
--price / gm above 100gm & best value
select distinct name,weightInGms, discountSellingPrice,
round(discountSellingPrice/weightInGms,2) As price_per_gram
from zepto
where weightInGms>=100
order by price_per_gram;
--group pdts by low, medium, bulk
select distinct name,weightInGms,
case when weightInGms <1000 then 'low'
     when weightInGms  < 5000 then 'medium'
	 else 'bulk'
	 end as weight_category
from zepto;
--Order by weight_category;
--total inventory weight per category
select category,
sum(weightInGms * availableQuantity) As total_weight
from zepto 
group by category
order by total_weight;--for warehouse planning

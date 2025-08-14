# Zepto-Analysis-using-SQL
Zepto Inventory & Pricing Analytics (Apr 25 – May 25)
Stack: SQL, PostgreSQL, pgAdmin 4

Overview
This project analyzes Zepto’s product catalog to uncover pricing, discount, and inventory insights.
It includes a PostgreSQL schema, data-quality checks, cleaning steps, and analysis queries for category segmentation, discount optimization, and warehouse planning.

Key Contributions
Designed and optimized a PostgreSQL schema; performed in-depth data exploration, cleaning, and transformation to ensure accuracy and integrity.

Solved 10+ business problems using advanced SQL to reveal sales trends, high-value products, and inventory/warehouse opportunities.

Delivered insights on category segmentation, discount optimization, and inventory forecasting to support strategic decisions.
A) Data Exploration

-- Row count
SELECT COUNT(*) AS total_rows FROM zepto;

-- Sample data
SELECT * FROM zepto LIMIT 10;

-- Null checks across key columns
SELECT *
FROM zepto
WHERE name IS NULL
   OR category IS NULL
   OR mrp IS NULL
   OR discountPercent IS NULL
   OR discountSellingPrice IS NULL
   OR weightInGms IS NULL
   OR availableQuantity IS NULL
   OR outOfStock IS NULL
   OR quantity IS NULL;

-- Distinct product categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;

-- In-stock vs Out-of-stock
SELECT outOfStock, COUNT(*) AS sku_count
FROM zepto
GROUP BY outOfStock
ORDER BY outOfStock DESC;

-- Product names appearing multiple times (potential duplicates)
SELECT name, COUNT(*) AS sku_count
FROM zepto
GROUP BY name
HAVING COUNT(*) > 1
ORDER BY sku_count DESC, name;
B) Data Cleaning (run once unless you reset the table)

-- Remove records with zero price (likely invalid)
DELETE FROM zepto
WHERE mrp = 0;

-- Convert paise → rupees (ONLY if your CSV is in paise; skip if already rupees)
UPDATE zepto
SET mrp = mrp / 100.0,
    discountSellingPrice = discountSellingPrice / 100.0;

-- Trim whitespace & normalize casing (optional but recommended)
UPDATE zepto SET
  category = NULLIF(BTRIM(category), ''),
  name     = NULLIF(BTRIM(name), '');

-- Guardrails: ensure non-negative numeric values
UPDATE zepto
SET mrp = GREATEST(mrp, 0),
    discountSellingPrice = GREATEST(discountSellingPrice, 0),
    discountPercent = GREATEST(discountPercent, 0);
C) Core Analytics

-- Top 10 best value products by highest discount %
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
WHERE discountPercent IS NOT NULL
ORDER BY discountPercent DESC, mrp DESC
LIMIT 10;

-- High-value items currently out of stock (threshold adjustable)
SELECT DISTINCT name, mrp
FROM zepto
WHERE outOfStock = TRUE
  AND mrp > 300
ORDER BY mrp DESC;

-- Estimated revenue per category
-- (Assumes 'availableQuantity' * 'discountSellingPrice' approximates potential revenue)
SELECT category,
       SUM(discountSellingPrice * availableQuantity)::NUMERIC(14,2) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue DESC;

-- Premium items: MRP > 500 with low discount (<10%)
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500
  AND (discountPercent < 10 OR discountPercent IS NULL)
ORDER BY mrp DESC, discountPercent NULLS LAST;
D) Marketing & Pricing Insights

-- Top 5 categories with highest average discount %
SELECT category,
       ROUND(AVG(discountPercent), 2) AS avg_discount
FROM zepto
WHERE discountPercent IS NOT NULL
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Price per gram (for items >= 100g)
SELECT DISTINCT name,
       weightInGms,
       discountSellingPrice,
       ROUND(discountSellingPrice / NULLIF(weightInGms, 0), 2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram ASC, discountSellingPrice ASC;
E) Operations & Warehouse Planning

-- Classify items by weight for pack-size strategy
SELECT DISTINCT name,
       weightInGms,
       CASE
         WHEN weightInGms < 1000 THEN 'low'
         WHEN weightInGms < 5000 THEN 'medium'
         ELSE 'bulk'
       END AS weight_category
FROM zepto;

-- Total inventory weight by category
SELECT category,
       SUM(weightInGms * availableQuantity) AS total_weight_in_grams
FROM zepto
GROUP BY category
ORDER BY total_weight_in_grams DESC;

-- 1. What are the top 5 most profitable products?

-- Why it matters:
-- Helps the company identify high-profit products to prioritize in marketing and inventory.

SELECT 
product_name,
SUM(profit) AS total_profit
FROM customer
GROUP BY product_name
ORDER BY total_profit DESC
LIMIT 5;

-- 2. Which region has the highest profit margin?

-- Why it matters:
-- Shows which geographic market is most profitable and where the business should focus expansion.


SELECT 
region,
ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM customer
GROUP BY region
ORDER BY profit_margin DESC;

-- 3. What is the profit margin by category?

-- Why it matters:
-- Identifies which product categories are most profitable, guiding pricing and product strategy.


SELECT 
category,
ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin
FROM customer
GROUP BY category
ORDER BY profit_margin DESC;


-- 4. Which sub-categories are causing losses?

-- Why it matters:
-- Helps management identify underperforming product lines that may need pricing changes or removal.

SELECT 
sub_category,
SUM(profit) AS total_profit
FROM customer
GROUP BY sub_category
HAVING SUM(profit) < 0
ORDER BY total_profit;

-- 5. What are the top 3 products in each region by sales?

-- Why it matters:
-- Reveals regional product preferences, useful for targeted marketing and inventory planning.


WITH ranked_products AS (
	SELECT region,product_name,
	SUM(sales) AS total_sales,
	ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(sales) DESC) AS rank
	FROM customer
	GROUP BY region, product_name
)
SELECT 
region,
product_name,
total_sales
FROM ranked_products
WHERE rank <= 3;


-- 6. Which customer segment has the highest average profit per order?

-- Why it matters:
-- Shows which customer group is most valuable, helping optimize marketing and customer targeting.


SELECT 
segment,
ROUND(SUM(profit) / COUNT(DISTINCT order_id),2) AS avg_profit_per_order
FROM customer
GROUP BY segment
ORDER BY avg_profit_per_order DESC;

-- 7. What is the Month-over-Month (MoM) growth in sales?

-- Why it matters:
-- Helps track sales growth trends and seasonal patterns.

WITH monthly_sales AS (
	SELECT
	EXTRACT(YEAR FROM order_date) AS years,
	EXTRACT(MONTH FROM order_date) AS months,
	SUM(sales) AS current_month_sales
	FROM customer
	GROUP BY years, months
)
SELECT
years,
months,
current_month_sales,
LAG(current_month_sales) OVER (ORDER BY years, months) AS prev_month_sales,
ROUND(
(current_month_sales - LAG(current_month_sales) OVER (ORDER BY years, months))
/ NULLIF(LAG(current_month_sales) OVER (ORDER BY years, months),0) * 100, 2
) AS mom_growth
FROM monthly_sales;


-- 8. Which states generate high sales but negative profit?

-- Why it matters:
-- Identifies regions where the company is losing money despite strong sales, indicating possible discount or cost issues.


SELECT 
state,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit
FROM customer
GROUP BY state
HAVING SUM(sales) > 50000 AND SUM(profit) < 0
ORDER BY total_sales DESC;


-- 9. What is the sales contribution percentage by category?

-- Why it matters:
-- Shows which product categories drive the majority of revenue.

SELECT 
category,
ROUND(SUM(sales) * 100 / SUM(SUM(sales)) OVER(),2) AS sales_contribution_percent
FROM customer
GROUP BY category;


-- 10. What are the top 10 highest selling products?

-- Why it matters:
-- Helps identify high-demand products for inventory planning and promotions.

SELECT 
product_name,
SUM(sales) AS total_sales
FROM customer
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;



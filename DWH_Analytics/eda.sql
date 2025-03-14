/* Exploring the data warehouse to get a more comprehensive understanding of the data. 
This EDA looked at the dimensions and measures for this */
 

-- Explore all objects in the database 
SELECT * FROM INFORMATION_SCHEMA.TABLES

--Explore All Columns in the Database 
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'

-- Explore Dimensions 
-- Explore All Countries our customers come from 
SELECT DISTINCT country FROM gold.dim_customers


-- Explore All Categories  "The major Divisions" and sub divisions 
SELECT DISTINCT category,subcategory,product_name FROM gold.dim_products
ORDER BY category,subcategory,product_name;

-- Explore Dates & Timespan 
-- Find the date of the first and last order 
SELECT 
MIN(order_date) first_order_date,
MAX(order_date) AS last_order_date,
DATEDIFF(year, MIN(order_date),MAX(order_date)) AS order_range_years
FROM gold.fact_sales

-- Find the youngest and oldest customer 
SELECT 
MIN(birth_date) AS oldest_birthdate,
DATEDIFF(year, MIN(birth_date), GETDATE()) AS oldest_age,
MAX(birth_date) AS youngest_birthdate,
DATEDIFF(year, MAX(birth_date), GETDATE()) AS youngest_age
FROM gold.dim_customers

-- Explore the measures
-- Find the Total Sales 
SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales

-- Find how many items are sold
SELECT SUM(quantity) AS total_quantity FROM gold.fact_sales

-- Find the average selling price 
SELECT AVG(price) AS avg_price FROM gold.fact_sales

-- Find the Total Number of Orders 
SELECT COUNT(order_number) AS total_orders FROM gold.fact_sales
-- Find the Total Number of Orders without any duplicates
SELECT COUNT( DISTINCT order_number) AS total_orders FROM gold.fact_sales

-- Find the total number of products 
SELECT COUNT(product_key) AS total_products FROM gold.dim_products
-- Find the total number of products without duplicates
SELECT COUNT( DISTINCT product_key) AS total_products FROM gold.dim_products

-- Find the total number of customers 
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers 

-- Find the total number of customers that has placed an order
SELECT COUNT(DISTINCT customer_key) AS total_customers_with_order FROM gold.fact_sales

-- Generate a Report that shows all key metrics of the business
SELECT 'Total Sales' as measure_name,
SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' as measure_name,
SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Average Price',
AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Orders',
COUNT( DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Products',
COUNT(product_name) FROM gold.dim_products
UNION ALL 
SELECT 'Total Nr. Customers',
COUNT(customer_key) FROM gold.dim_customers

-- Explore Magnitude [Measure by Dimension]
-- Find total number of countries by countries 
SELECT 
country, 
COUNT(customer_key) AS total_customers 
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC

-- Find the total customers by gender
SELECT 
gender, 
COUNT(customer_key) AS total_customers 
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC

-- Find total Products by category 
SELECT  
category,
COUNT(product_key) AS total_products 
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC

-- Average Cost in each category 
-- Find total Products by category 
SELECT  
category,
AVG(cost) AS avg_costs
FROM gold.dim_products
GROUP BY category
ORDER BY avg_costs DESC

-- Total revenue from each category 
SELECT 
p.category,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p 
ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC

-- Total Revenue from each customer 
SELECT 
c.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c 
ON c.customer_key = f.customer_key
GROUP BY 
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_revenue DESC

-- Distribution of sold items across countries 
-- Total Revenue from each customer 
SELECT 
c.country,
SUM(f.quantity) AS total_sold_items
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c 
ON c.customer_key = f.customer_key
GROUP BY 
c.country
ORDER BY total_sold_items DESC

-- Ranking 
-- Products that generate the highest revenue (top 5) 
SELECT TOP 5
p.product_name, 
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC

-- Subcategories that generate the highest revenue (top 5) 
SELECT TOP 5
p.subcategory, 
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.subcategory
ORDER BY total_revenue DESC

-- Products that generate the highest revenue (top 5) using the window functions*
SELECT * 
FROM
(
	SELECT 
	p.product_name, 
	SUM(f.sales_amount) total_revenue,
	ROW_NUMBER() OVER(ORDER BY SUM(f.sales_amount) DESC) AS rank_products
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON p.product_key = f.product_key
	GROUP BY p.product_name )t
WHERE rank_products <= 5



--Products that generate the lowest revenue (top 5) 
SELECT TOP 5
p.product_name, 
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue 

-- Top 10 customers who have generated the highest revenue 
SELECT TOP 10
c.customer_key, 
c.first_name, 
c.last_name ,
SUM(f.sales_amount) AS total_revenue 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY 
c.customer_key, 
c.first_name, 
c.last_name 
ORDER BY total_revenue DESC

-- Customers with the fewest orders placed 
SELECT TOP 3
c.customer_key, 
c.first_name, 
c.last_name ,
COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY 
c.customer_key, 
c.first_name, 
c.last_name 
ORDER BY total_orders









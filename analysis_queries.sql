/* =============================================================================
GLOBAL SUPERSTORE RETAIL INTELLIGENCE - MS SQL SERVER (T-SQL) SCRIPT
Description: Database setup, feature engineering, and business intelligence queries.
Author: [Your Name/GitHub Handle]
=============================================================================
*/

-- 1. DATABASE ARCHITECTURE & SCHEMA DESIGN
-- ========================================

-- Create Database if it does not exist
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'RetailAnalyticsDB')
BEGIN
    CREATE DATABASE RetailAnalyticsDB;
END
GO

USE RetailAnalyticsDB;
GO

-- Create the primary sales table
-- Note: Dropping table if it exists to allow for fresh creation during testing
IF OBJECT_ID('dbo.superstore_sales', 'U') IS NOT NULL
    DROP TABLE dbo.superstore_sales;
GO

CREATE TABLE superstore_sales (
    invoice_id VARCHAR(30) PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    vat DECIMAL(10, 4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_pct FLOAT,
    gross_income DECIMAL(12, 4),
    rating FLOAT
);
GO

-- NOTE: Data Import
-- In MS SQL Server, use the 'Import Flat File' wizard in SSMS to load the CSV data 
-- into the 'superstore_sales' table created above.


-- 2. FEATURE ENGINEERING
-- ==================================

-- A. Add 'time_of_day' column
-- Logic: Categorize transactions into Morning, Afternoon, or Evening.
ALTER TABLE superstore_sales ADD time_of_day VARCHAR(20);
GO

UPDATE superstore_sales
SET time_of_day = (
    CASE 
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening' 
    END
);
GO

-- B. Add 'day_name' column
-- Logic: Extract the day of the week (e.g., Monday, Tuesday) from the date.
ALTER TABLE superstore_sales ADD day_name VARCHAR(10);
GO

UPDATE superstore_sales
SET day_name = DATENAME(WEEKDAY, date);
GO

-- C. Add 'month_name' column
-- Logic: Extract the month (e.g., January, February) from the date.
ALTER TABLE superstore_sales ADD month_name VARCHAR(10);
GO

UPDATE superstore_sales
SET month_name = DATENAME(MONTH, date);
GO


-- 3. EXPLORATORY DATA ANALYSIS (EDA) & BUSINESS INTELLIGENCE
-- ==========================================================

-- ----------------------------------------------------------
-- I. GENERIC QUESTIONS
-- ----------------------------------------------------------

-- 1. Unique Cities
-- Objective: distinct cities present in the dataset.
SELECT DISTINCT city FROM superstore_sales;
GO

-- 2. Branch & City Mapping
-- Objective: Show which branch belongs to which city.
SELECT DISTINCT branch, city FROM superstore_sales;
GO

-- ----------------------------------------------------------
-- II. PRODUCT ANALYSIS
-- ----------------------------------------------------------

-- 1. Product Line Count
-- Objective: Count distinct product lines.
SELECT COUNT(DISTINCT product_line) AS unique_product_lines FROM superstore_sales;
GO

-- 2. Top Payment Method
-- Objective: Most common payment method.
SELECT TOP 1 payment_method, COUNT(payment_method) AS count
FROM superstore_sales 
GROUP BY payment_method 
ORDER BY count DESC;
GO

-- 3. Best Selling Product Line
-- Objective: Product line with highest sales volume.
SELECT TOP 1 product_line, COUNT(product_line) AS count
FROM superstore_sales 
GROUP BY product_line 
ORDER BY count DESC;
GO

-- 4. Monthly Revenue
-- Objective: Total revenue categorized by month.
SELECT month_name, SUM(total) AS total_revenue
FROM superstore_sales 
GROUP BY month_name 
ORDER BY total_revenue DESC;
GO

-- 5. Highest COGS Month
-- Objective: Which month had the highest Cost of Goods Sold.
SELECT TOP 1 month_name, SUM(cogs) AS total_cogs
FROM superstore_sales 
GROUP BY month_name 
ORDER BY total_cogs DESC;
GO

-- 6. Highest Revenue Product Line
-- Objective: Product line generating the most revenue.
SELECT TOP 1 product_line, SUM(total) AS total_revenue
FROM superstore_sales 
GROUP BY product_line 
ORDER BY total_revenue DESC;
GO

-- 7. Highest Revenue City
-- Objective: City generating the most revenue.
SELECT TOP 1 city, SUM(total) AS total_revenue
FROM superstore_sales 
GROUP BY city 
ORDER BY total_revenue DESC;
GO

-- 8. Highest VAT Product Line
-- Objective: Product line paying the most VAT.
SELECT TOP 1 product_line, SUM(vat) as total_vat
FROM superstore_sales 
GROUP BY product_line 
ORDER BY total_vat DESC;
GO

-- 9. Sales Classification (Good/Bad)
-- Objective: Categorize product lines as 'Good' or 'Bad' based on avg sales.
ALTER TABLE superstore_sales ADD product_category VARCHAR(20);
GO

-- Note: T-SQL update with subquery aggregation requires logical handling
WITH AvgSales AS (
    SELECT AVG(total) as avg_total FROM superstore_sales
)
UPDATE superstore_sales
SET product_category = 
    CASE 
        WHEN total >= (SELECT avg_total FROM AvgSales) THEN 'Good' 
        ELSE 'Bad' 
    END;
GO

-- 10. High Performing Branches
-- Objective: Branches selling more items than the average branch.
SELECT TOP 1 branch, SUM(quantity) AS quantity
FROM superstore_sales 
GROUP BY branch 
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM superstore_sales)
ORDER BY quantity DESC;
GO

-- 11. Gender Preferences
-- Objective: Most common product line by gender.
SELECT gender, product_line, COUNT(gender) AS total_cnt
FROM superstore_sales 
GROUP BY gender, product_line 
ORDER BY total_cnt DESC;
GO

-- 12. Average Rating
-- Objective: Average rating for each product line.
SELECT product_line, ROUND(AVG(rating), 2) AS avg_rating
FROM superstore_sales 
GROUP BY product_line 
ORDER BY avg_rating DESC;
GO

-- ----------------------------------------------------------
-- III. SALES ANALYSIS
-- ----------------------------------------------------------

-- 1. Sales by Time of Day (Weekdays)
-- Objective: Analyze sales timing excluding weekends.
SELECT day_name, time_of_day, COUNT(*) AS total_sales
FROM superstore_sales
WHERE day_name NOT IN ('Saturday', 'Sunday')
GROUP BY day_name, time_of_day
ORDER BY total_sales DESC;
GO

-- 2. Best Customer Type (Revenue)
-- Objective: Customer type generating highest revenue.
SELECT TOP 1 customer_type, SUM(total) AS total_sales
FROM superstore_sales 
GROUP BY customer_type 
ORDER BY total_sales DESC;
GO

-- 3. Highest VAT City
-- Objective: City paying the highest tax.
SELECT TOP 1 city, SUM(vat) AS total_vat
FROM superstore_sales 
GROUP BY city 
ORDER BY total_vat DESC;
GO

-- 4. Highest VAT Customer
-- Objective: Customer type paying the highest tax.
SELECT TOP 1 customer_type, SUM(vat) AS total_vat
FROM superstore_sales 
GROUP BY customer_type 
ORDER BY total_vat DESC;
GO

-- ----------------------------------------------------------
-- IV. CUSTOMER ANALYSIS
-- ----------------------------------------------------------

-- 1. Unique Customer Types
SELECT COUNT(DISTINCT customer_type) AS unique_customers FROM superstore_sales;
GO

-- 2. Unique Payment Methods
SELECT COUNT(DISTINCT payment_method) AS unique_payments FROM superstore_sales;
GO

-- 3. Most Common Customer Type
SELECT TOP 1 customer_type, COUNT(*) AS count
FROM superstore_sales 
GROUP BY customer_type 
ORDER BY count DESC;
GO

-- 4. Highest Buying Customer Type
-- Objective: Customer type with highest transaction count.
SELECT TOP 1 customer_type, COUNT(*) AS transaction_count
FROM superstore_sales 
GROUP BY customer_type 
ORDER BY transaction_count DESC;
GO

-- 5. Gender Distribution
-- Objective: Majority gender of customers.
SELECT TOP 1 gender, COUNT(*) as count
FROM superstore_sales
GROUP BY gender
ORDER BY count DESC;
GO

-- 6. Gender Distribution by Branch
SELECT branch, gender, COUNT(*) as count
FROM superstore_sales
GROUP BY branch, gender
ORDER BY branch;
GO

-- 7. Ratings by Time of Day
-- Objective: When do customers give the most ratings?
SELECT time_of_day, AVG(rating) AS avg_rating
FROM superstore_sales 
GROUP BY time_of_day 
ORDER BY avg_rating DESC;
GO

-- 8. Ratings by Time of Day (Per Branch)
SELECT branch, time_of_day, AVG(rating) AS avg_rating
FROM superstore_sales 
GROUP BY branch, time_of_day 
ORDER BY avg_rating DESC;
GO

-- 9. Best Day for Ratings
-- Objective: Day of the week with best average ratings.
SELECT TOP 1 day_name, AVG(rating) AS avg_rating
FROM superstore_sales 
GROUP BY day_name 
ORDER BY avg_rating DESC;
GO

-- 10. Best Day for Ratings (Per Branch)
-- Objective: Best rating day for each individual branch.
-- Note: Using Window Function to rank days per branch.
WITH BranchRatings AS (
    SELECT 
        branch, 
        day_name, 
        AVG(rating) as avg_rating,
        RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rnk
    FROM superstore_sales
    GROUP BY branch, day_name
)
SELECT branch, day_name, avg_rating 
FROM BranchRatings 
WHERE rnk = 1;
GO

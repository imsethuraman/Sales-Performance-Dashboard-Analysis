-- ============================================================
-- SQL PORTFOLIO PROJECT: PRODUCT SALES ANALYSIS
-- Author: Sethuraman B
-- End-to-end analytics project covering:
-- Data Cleaning, EDA, Revenue Modeling,
-- Cohort Analysis, Retention Metrics,
-- and Advanced Window Functions
-- ============================================================
Use product_data;

-- Explore the Tables
SELECT * FROM product_sales.product_data;
SELECT * FROM product_sales.product_sales;
SELECT * FROM product_sales.discount_data;

-- ============================================================
-- SQL PORTFOLIO PROJECT: PRODUCT SALES ANALYSIS
-- ============================================================


-- ============================================================
-- 🔹 COMMON CTE TEMPLATE (USED IN EVERY QUERY)
-- ============================================================

-- ============================================================
-- 🔹 1. EDA - OVERALL SUMMARY
-- ============================================================

WITH base AS (
    SELECT 
        a.Product, a.Category, a.Brand,
        CAST(REPLACE(a.`Cost Price`, '$', '') AS DECIMAL(10,2)) AS Cost_Price,
        CAST(REPLACE(a.`Sale Price`, '$', '') AS DECIMAL(10,2)) AS Sale_Price,
        STR_TO_DATE(b.Date, '%d/%m/%Y') AS order_date,
        b.Country AS customer_id,
        TRIM(b.`Discount Band`) AS Discount_Band,
        b.`Units Sold`,
        MONTH(STR_TO_DATE(b.Date, '%d/%m/%Y')) AS month_num,
        YEAR(STR_TO_DATE(b.Date, '%d/%m/%Y')) AS year,
        CAST(REPLACE(a.`Sale Price`, '$', '') AS DECIMAL(10,2)) * b.`Units Sold` AS Revenue,
        CAST(REPLACE(a.`Cost Price`, '$', '') AS DECIMAL(10,2)) * b.`Units Sold` AS Total_Cost
    FROM product_sales.product_data a
    JOIN product_sales.product_sales b
        ON a.`Product ID` = b.Product
),
final_data AS (
    SELECT 
        base.*,
        COALESCE(d.Discount, 0) AS Discount,
        (1 - COALESCE(d.Discount, 0)/100) * base.Revenue AS Discounted_Revenue,
        ((1 - COALESCE(d.Discount, 0)/100) * base.Revenue - base.Total_Cost) AS Profit
    FROM base
    LEFT JOIN product_sales.discount_data d
        ON base.Discount_Band = d.`Discount Band`
        AND base.month_num = d.Month
)
select * FROM final_data;
SELECT 
    COUNT(*) AS total_orders,
    SUM(Revenue) AS total_revenue,
    SUM(Profit) AS total_profit
FROM final_data;


-- ============================================================
-- 🔹 2. EDA - CATEGORY PERFORMANCE
-- ============================================================

WITH base AS (
    SELECT 
        a.Product, a.Category, a.Brand,
        CAST(REPLACE(a.`Cost Price`, '$', '') AS DECIMAL(10,2)) AS Cost_Price,
        CAST(REPLACE(a.`Sale Price`, '$', '') AS DECIMAL(10,2)) AS Sale_Price,
        STR_TO_DATE(b.Date, '%d/%m/%Y') AS order_date,
        b.Country AS customer_id,
        TRIM(b.`Discount Band`) AS Discount_Band,
        b.`Units Sold`,
        MONTH(STR_TO_DATE(b.Date, '%d/%m/%Y')) AS month_num,
        YEAR(STR_TO_DATE(b.Date, '%d/%m/%Y')) AS year,
        CAST(REPLACE(a.`Sale Price`, '$', '') AS DECIMAL(10,2)) * b.`Units Sold` AS Revenue,
        CAST(REPLACE(a.`Cost Price`, '$', '') AS DECIMAL(10,2)) * b.`Units Sold` AS Total_Cost
    FROM product_sales.product_data a
    JOIN product_sales.product_sales b
        ON a.`Product ID` = b.Product
),
final_data AS (
    SELECT 
        base.*,
        COALESCE(d.Discount, 0) AS Discount,
        (1 - COALESCE(d.Discount, 0)/100) * base.Revenue AS Discounted_Revenue,
        ((1 - COALESCE(d.Discount, 0)/100) * base.Revenue - base.Total_Cost) AS Profit
    FROM base
    LEFT JOIN product_sales.discount_data d
        ON base.Discount_Band = d.`Discount Band`
        AND base.month_num = d.Month
)

SELECT 
    Category,
    SUM(Revenue) AS revenue,
    SUM(Profit) AS profit
FROM final_data
GROUP BY Category
ORDER BY revenue DESC;



-- ============================================================
-- 🔹 3. EDA - TOP COUNTRIES
-- ============================================================

WITH base AS (
    SELECT 
        a.Product, a.Category, a.Brand,
        CAST(REPLACE(a.`Cost Price`, '$', '') AS DECIMAL(10,2)) AS Cost_Price,
        CAST(REPLACE(a.`Sale Price`, '$', '') AS DECIMAL(10,2)) AS Sale_Price,
        STR_TO_DATE(b.Date, '%d/%m/%Y') AS order_date,
        b.Country AS customer_id,
        TRIM(b.`Discount Band`) AS Discount_Band,
        b.`Units Sold`,
        MONTH(STR_TO_DATE(b.Date, '%d/%m/%Y')) AS month_num,
        YEAR(STR_TO_DATE(b.Date, '%d/%m/%Y')) AS year,
        CAST(REPLACE(a.`Sale Price`, '$', '') AS DECIMAL(10,2)) * b.`Units Sold` AS Revenue,
        CAST(REPLACE(a.`Cost Price`, '$', '') AS DECIMAL(10,2)) * b.`Units Sold` AS Total_Cost
    FROM product_sales.product_data a
    JOIN product_sales.product_sales b
        ON a.`Product ID` = b.Product
),
final_data AS (
    SELECT 
        base.*,
        COALESCE(d.Discount, 0) AS Discount,
        (1 - COALESCE(d.Discount, 0)/100) * base.Revenue AS Discounted_Revenue,
        ((1 - COALESCE(d.Discount, 0)/100) * base.Revenue - base.Total_Cost) AS Profit
    FROM base
    LEFT JOIN product_sales.discount_data d
        ON base.Discount_Band = d.`Discount Band`
        AND base.month_num = d.Month
)

SELECT 
    customer_id,
    SUM(Revenue) AS revenue
FROM final_data
GROUP BY customer_id
ORDER BY revenue DESC
LIMIT 10;



-- ============================================================
-- 🔹 4. COHORT ANALYSIS
-- ============================================================

WITH base AS (
    SELECT 
        a.Product, a.Category, a.Brand,
        CAST(REPLACE(a.`Cost Price`, '$', '') AS DECIMAL(10,2)) AS Cost_Price,
        CAST(REPLACE(a.`Sale Price`, '$', '') AS DECIMAL(10,2)) AS Sale_Price,
        STR_TO_DATE(b.Date, '%d/%m/%Y') AS order_date,
        b.Country AS customer_id,
        TRIM(b.`Discount Band`) AS Discount_Band,
        b.`Units Sold`,
        MONTH(STR_TO_DATE(b.Date, '%d/%m/%Y')) AS month_num,
        YEAR(STR_TO_DATE(b.Date, '%d/%m/%Y')) AS year,
        CAST(REPLACE(a.`Sale Price`, '$', '') AS DECIMAL(10,2)) * b.`Units Sold` AS Revenue,
        CAST(REPLACE(a.`Cost Price`, '$', '') AS DECIMAL(10,2)) * b.`Units Sold` AS Total_Cost
    FROM product_sales.product_data a
    JOIN product_sales.product_sales b
        ON a.`Product ID` = b.Product
),
final_data AS (
    SELECT 
        base.*,
        COALESCE(d.Discount, 0) AS Discount,
        (1 - COALESCE(d.Discount, 0)/100) * base.Revenue AS Discounted_Revenue,
        ((1 - COALESCE(d.Discount, 0)/100) * base.Revenue - base.Total_Cost) AS Profit
    FROM base
    LEFT JOIN product_sales.discount_data d
        ON base.Discount_Band = d.`Discount Band`
        AND base.month_num = d.Month
),
customer_cohort AS (
    SELECT 
        customer_id,
        MIN(DATE_FORMAT(order_date, '%Y-%m-01')) AS cohort_month
    FROM final_data
    GROUP BY customer_id
),
cohort_data AS (
    SELECT 
        f.customer_id,
        c.cohort_month,
        TIMESTAMPDIFF(MONTH, c.cohort_month, f.order_date) AS cohort_index
    FROM final_data f
    JOIN customer_cohort c
        ON f.customer_id = c.customer_id
)

SELECT 
    cohort_month,
    cohort_index,
    COUNT(DISTINCT customer_id) AS customers
FROM cohort_data
GROUP BY cohort_month, cohort_index
ORDER BY cohort_month, cohort_index;



-- ============================================================
-- 🔹 5. RETENTION
-- ============================================================

WITH base AS (
    SELECT 
        a.Product, a.Category, a.Brand,
        CAST(REPLACE(a.`Cost Price`, '$', '') AS DECIMAL(10,2)) AS Cost_Price,
        CAST(REPLACE(a.`Sale Price`, '$', '') AS DECIMAL(10,2)) AS Sale_Price,
        STR_TO_DATE(b.Date, '%d/%m/%Y') AS order_date,
        b.Country AS customer_id,
        TRIM(b.`Discount Band`) AS Discount_Band,
        b.`Units Sold`,
        MONTH(STR_TO_DATE(b.Date, '%d/%m/%Y')) AS month_num,
        YEAR(STR_TO_DATE(b.Date, '%d/%m/%Y')) AS year,
        CAST(REPLACE(a.`Sale Price`, '$', '') AS DECIMAL(10,2)) * b.`Units Sold` AS Revenue,
        CAST(REPLACE(a.`Cost Price`, '$', '') AS DECIMAL(10,2)) * b.`Units Sold` AS Total_Cost
    FROM product_sales.product_data a
    JOIN product_sales.product_sales b
        ON a.`Product ID` = b.Product
),
final_data AS (
    SELECT 
        base.*,
        COALESCE(d.Discount, 0) AS Discount,
        (1 - COALESCE(d.Discount, 0)/100) * base.Revenue AS Discounted_Revenue,
        ((1 - COALESCE(d.Discount, 0)/100) * base.Revenue - base.Total_Cost) AS Profit
    FROM base
    LEFT JOIN product_sales.discount_data d
        ON base.Discount_Band = d.`Discount Band`
        AND base.month_num = d.Month
),
customer_cohort AS (
    SELECT customer_id,
           MIN(DATE_FORMAT(order_date, '%Y-%m-01')) AS cohort_month
    FROM final_data
    GROUP BY customer_id
),
cohort_data AS (
    SELECT 
        f.customer_id,
        c.cohort_month,
        TIMESTAMPDIFF(MONTH, c.cohort_month, f.order_date) AS cohort_index
    FROM final_data f
    JOIN customer_cohort c
        ON f.customer_id = c.customer_id
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS total_customers
    FROM customer_cohort
    GROUP BY cohort_month
),
retention AS (
    SELECT 
        cohort_month,
        cohort_index,
        COUNT(DISTINCT customer_id) AS retained_customers
    FROM cohort_data
    GROUP BY cohort_month, cohort_index
)

SELECT 
    r.cohort_month,
    r.cohort_index,
    r.retained_customers,
    cs.total_customers,
    ROUND(r.retained_customers * 100.0 / cs.total_customers, 2) AS retention_rate
FROM retention r
JOIN cohort_size cs
    ON r.cohort_month = cs.cohort_month
ORDER BY r.cohort_month, r.cohort_index;
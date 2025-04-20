CREATE DATABASE pizzasales_db;
USE pizzasales_db;

-- --------------------------------------------------------------------------------------------------------------------------------------

/* Pizza Sales Trend Analysis

Techniques used throughout the task:
- `EXTRACT(MONTH FROM STR_TO_DATE(o.date, '%d/%m/%Y'))`
- `GROUP BY YEAR/MONTH`
- `SUM()` for revenue
- `COUNT(DISTINCT order_id)` for volume
- `ORDER BY` for sorting
- `WHERE` clause to limit time periods
*/
-- --------------------------------------------------------------------------------------------------------------------------------------

-- Q1. What is the total monthly revenue generated from pizza sales?

-- Query Type: Aggregate Query using `EXTRACT(YEAR FROM STR_TO_DATE(o.date, '%d/%m/%Y'))`, `SUM()`, `JOIN`, `GROUP BY`, `ORDER BY`
    
SELECT 
    EXTRACT(YEAR FROM STR_TO_DATE(o.date, '%d/%m/%Y')) AS Order_Year,
    ROUND(SUM(p.price * od.quantity), 2) AS Total_Revenue
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY Order_Year
ORDER BY Order_Year;
      
-- This aggregation shows the yearly total revenue by multiplying pizza prices and quantities.

-- --------------------------------------------------------------------------------------------------------------------------------------

-- 2. How many unique orders were placed each month?

-- Query Type: Aggregate Query using `MONTHNAME(STR_TO_DATE(o.date, '%m/%d/%Y'))`, `COUNT(DISTINCT)`, `GROUP BY`

SELECT 
    MONTHNAME(STR_TO_DATE(o.date, '%d/%m/%Y')) AS Order_Month,
    COUNT(DISTINCT o.order_id) AS Order_Volume
FROM
    orders o
WHERE
    MONTHNAME(STR_TO_DATE(o.date, '%d/%m/%Y')) IS NOT NULL
GROUP BY Order_Month
ORDER BY Order_Volume DESC;

-- This query counts unique order IDs placed in each month, showing customer volume trends.

-- --------------------------------------------------------------------------------------------------------------------------------------

-- 3. Which month had the highest revenue and which had the lowest?

-- Query Type: Subquery + Aggregation + Sorting + `LIMIT`

WITH highest_month AS (
    SELECT 
        MONTHNAME(STR_TO_DATE(o.date, '%d/%m/%Y')) AS month_name,
        ROUND(SUM(p.price * od.quantity), 2) AS total_revenue
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    WHERE MONTHNAME(STR_TO_DATE(o.date, '%d/%m/%Y')) IS NOT NULL
    GROUP BY month_name
    ORDER BY total_revenue DESC
    LIMIT 1
),
lowest_month AS (
    SELECT 
        MONTHNAME(STR_TO_DATE(o.date, '%d/%m/%Y')) AS month_name,
        ROUND(SUM(p.price * od.quantity), 2) AS total_revenue
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    WHERE MONTHNAME(STR_TO_DATE(o.date, '%d/%m/%Y')) IS NOT NULL
    GROUP BY month_name
    ORDER BY total_revenue ASC
    LIMIT 1
)

SELECT 
    h.month_name AS Highest_Revenue_Month,
    h.total_revenue AS Highest_Total_Revenue,
    l.month_name AS Lowest_Revenue_Month,
    l.total_revenue AS Lowest_Total_Revenue
FROM 
    highest_month h,
    lowest_month l;

-- This ranks months by revenue, showing peak and dip periods.

-- --------------------------------------------------------------------------------------------------------------------------------------

-- 4. How does the sales trend vary across different pizza sizes over the months?

-- Query Type: Grouped Aggregation with Additional Dimension (Size)

SELECT 
    MONTHNAME(STR_TO_DATE(o.date, '%d/%m/%Y')) AS Month_Name,
    p.size AS Pizza_Size,
    ROUND(SUM(p.price * od.quantity), 2) AS Revenue_by_Size
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY Month_Name , p.size
ORDER BY Month_Name , p.size;


-- This breaks down monthly revenue by pizza size (S, M, L, XL, etc.)

-- --------------------------------------------------------------------------------------------------------------------------------------

-- 5. What is the monthly revenue trend for each pizza category (e.g., Classic, Veggie, Chicken)?

-- Query Type: Multi-table Join + Grouped Aggregation

SELECT 
    MONTHNAME(STR_TO_DATE(o.date, '%d/%m/%Y')) AS Order_Month,
    pt.category AS Category,
    ROUND(SUM(p.price * od.quantity), 2) AS Category_Revenue
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY MONTHNAME(STR_TO_DATE(o.date, '%d/%m/%Y')), pt.category
ORDER BY Order_Month , Category;


-- This query helps understand which pizza category contributes most to monthly revenue.

-- --------------------------------------------------------------------------------------------------------------------------------------


-- ------------------------------------------------------------------------END-OF-TASK-6------------------------------------------------------------------------------------------
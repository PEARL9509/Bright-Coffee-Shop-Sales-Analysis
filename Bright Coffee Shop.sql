SELECT *
FROM `coffee_shop_project`.`coffee_shop_analysis`.`1771947830706_bright_coffee_shop_sales` limit 100;


---Checking missing values
SELECT *
FROM `coffee_shop_project`.`coffee_shop_analysis`.`1771947830706_bright_coffee_shop_sales` 
WHERE unit_price IS NULL
   OR transaction_qty IS NULL
   OR product_type IS NULL
   OR transaction_time IS NULL;


   ---Fix the unit_price format (comma to decimal)
SELECT
  REPLACE(unit_price, ',', '.') AS unit_price_clean
FROM `coffee_shop_project`.`coffee_shop_analysis`.`1771947830706_bright_coffee_shop_sales`;


---Convert unit_price to numeric
SELECT
CAST(unit_price AS DOUBLE) AS unit_price_clean,
transaction_qty
FROM `coffee_shop_project`.`coffee_shop_analysis`.`1771947830706_bright_coffee_shop_sales`;


---Checking for duplicates
SELECT *,
COUNT(*) AS duplicate_count
FROM `coffee_shop_project`.`coffee_shop_analysis`.`1771947830706_bright_coffee_shop_sales`
GROUP BY ALL
HAVING COUNT(*) > 1;


---Checking for incorrect values
SELECT transaction_qty,
       unit_price
FROM `coffee_shop_project`.`coffee_shop_analysis`.`1771947830706_bright_coffee_shop_sales`
WHERE unit_price <= 0
   OR transaction_qty <= 0;


---Creating the total_amount column
SELECT 
    unit_price * transaction_qty AS total_amount
FROM `coffee_shop_project`.`coffee_shop_analysis`.`1771947830706_bright_coffee_shop_sales`;


---Creating the time bucket column
SELECT
Date_Format(transaction_time, 'HH:mm:ss') AS time_bucket
FROM `coffee_shop_project`.`coffee_shop_analysis`.`1771947830706_bright_coffee_shop_sales`;

---Creating the sum of quantity column
SELECT
    product_category,
    SUM(transaction_qty) AS sum_of_quantity
FROM coffee_shop_project.coffee_shop_analysis.`1771947830706_bright_coffee_shop_sales`
GROUP BY product_category;

---Revenue by product
SELECT product_type,
SUM(unit_price * transaction_qty) AS total_revenue
FROM `coffee_shop_project`.`coffee_shop_analysis`.`1771947830706_bright_coffee_shop_sales`
GROUP BY product_type
ORDER BY total_revenue DESC;
 

---Peak sales time
SELECT
Date_Format(transaction_time, 'HH:mm:ss') AS time_bucket,
SUM(unit_price * transaction_qty) AS revenue
FROM coffee_shop_project.coffee_shop_analysis.`1771947830706_bright_coffee_shop_sales`
GROUP BY transaction_time
ORDER BY revenue DESC;


---Quantity sold per product
SELECT
product_type,
SUM(transaction_qty) AS total_units
FROM `coffee_shop_project`.`coffee_shop_analysis`.`1771947830706_bright_coffee_shop_sales`
GROUP BY product_type
ORDER BY total_units DESC;


---Max and min time 
---Min time = 06:00:00 and Max time = 20:59:32
SELECT
    MIN(DATE_FORMAT(transaction_time, 'HH:mm:ss')) AS min_time,
    MAX(DATE_FORMAT(transaction_time, 'HH:mm:ss')) AS max_time
FROM coffee_shop_project.coffee_shop_analysis.1771947830706_bright_coffee_shop_sales;

  

---Combining SQL queries
SELECT 
--DATES
transaction_date,
Dayname(transaction_date) AS day_name,
Monthname(transaction_date) AS month_name,

CASE 
WHEN Dayname(transaction_date) = 'Sat' OR Dayname(transaction_date) = 'Sun' THEN 'Weekend'
ELSE 'Weekday'
END AS day_type,

--TIME
Date_Format(transaction_time, 'HH:mm:ss') AS purchase_time,

    CASE
        WHEN Date_Format(transaction_time, 'HH:mm:ss') BETWEEN '06:00:00' AND '09:59:59' THEN '01. Morning'
        WHEN Date_Format(transaction_time, 'HH:mm:ss') BETWEEN '10:00:00' AND '13:59:59' THEN '02. Late_Morning'
        WHEN Date_Format(transaction_time, 'HH:mm:ss') BETWEEN '14:00:00' AND '17:59:59' THEN '03. Afternoon'
        WHEN Date_Format(transaction_time, 'HH:mm:ss') BETWEEN '18:00:00' AND '20:59:59' THEN '04. Evening'
    END AS time_bucket,

transaction_qty AS quantity_sold,

-- Calculating revenue by day
SUM(transaction_qty*unit_price) AS revenue_by_day,

--- CASE statement for spending levels 
CASE 
    WHEN (transaction_qty*unit_price) <= 50 THEN 'Low spend'
    WHEN (transaction_qty*unit_price) BETWEEN 51 AND 100 THEN 'Medium spend'
    WHEN (transaction_qty*unit_price) BETWEEN 101 AND 250 THEN 'High spend'
    ELSE 'Ballers'
END AS spend_bucket, 

--- Categorical columns 
store_location,
product_category,
product_detail,
product_type

FROM `coffee_shop_project`.`coffee_shop_analysis`.`1771947830706_bright_coffee_shop_sales`
GROUP BY transaction_date, day_name, month_name, day_type, purchase_time, time_bucket, store_location, product_category, product_detail, product_type, transaction_qty, unit_price
ORDER BY transaction_date;



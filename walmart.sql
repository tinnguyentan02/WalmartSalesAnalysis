CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6, 4) NOT NULL,
    total DECIMAL (12, 4) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15),
    cogs DECIMAL (10, 2) NOT NULL,
    gross_margin_percentage FLOAT(11, 9),
    gross_income DECIMAL(12, 4) NOT NULL,
    rating FLOAT(2, 1)
);

-- ----------------------------------------------------------------------------------
-- ---------------------------- Feature Engineering ---------------------------------

SELECT * FROM sales;

-- time_of_day --
SELECT 
	time,
	(CASE 
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time`BETWEEN "12:00:01" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_date
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE 
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time`BETWEEN "12:00:01" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END);

SET SQL_SAFE_UPDATES = 0;

-- day_name --
SELECT
	date,
    DAYNAME(date) as day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);

ALTER TABLE sales DROP COLUMN day_name;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);

-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- ------------------------------ Generic -------------------------------------

-- How many unique cities does the data have?
SELECT
	DISTINCT city
FROM sales;

-- In which city is each branch?
SELECT 
	DISTINCT city, branch
FROM sales;


-- ----------------------------------------------------------------------------
-- ------------------------------ Product -------------------------------------
-- How many unique product lines does the data have?
SELECT 
	COUNT(DISTINCT(product_line))
FROM 
	sales;
    
-- What is the most common payment method?
SELECT
	payment_method,
	COUNT(branch) as count
FROM 
	sales
GROUP BY 
	payment_method
ORDER BY count DESC
LIMIT 1
;

-- What is the most selling product line?

SELECT
	product_line,
    COUNT(product_line) as cnt
FROM 
	sales
GROUP BY 
	product_line
ORDER BY 
	cnt DESC;
    
-- What is the total revenue by month?

SELECT 
	month_name as month,
    SUM(total) as revenue
FROM 
	sales
GROUP BY
	month_name;
    
-- What month had the largest COGS?

SELECT
	month_name,
    SUM(cogs) as cogs
FROM 
	sales
GROUP BY 
	month_name
ORDER BY cogs DESC;

-- What product line had the largest revenue?
SELECT
	product_line,
    SUM(total) as revenue
FROM 
	sales
GROUP BY 
	product_line
ORDER BY 
	revenue DESC;
    
-- What is the city with the largest revenue?
SELECT
	city,
    SUM(total) as revenue
FROM 
	sales
GROUP BY 
	city
ORDER BY 
	revenue DESC;
    
-- What product line had the largest VAT?
SELECT
	product_line,
    SUM(VAT) as VAT
FROM 
	sales
GROUP BY 
	product_line
ORDER BY 
	VAT DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

SELECT
	branch,
    (CASE
		WHEN AVG(quantity) > (SELECT AVG(quantity) FROM sales) THEN 'good'
        ELSE 'bad'
	END) as performance
FROM 
	sales
GROUP BY
	branch;

-- Which branch sold more products than average product sold?
SELECT AVG(quantity) FROM sales;

SELECT
	branch,
    AVG(quantity) as avg
FROM 
	sales
GROUP BY
	branch
HAVING avg > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender?
SELECT
	gender,
    product_line,
    COUNT(gender) as qty
FROM sales
GROUP BY gender, product_line
ORDER BY qty DESC;

-- What is the average rating of each product line?
SELECT
	product_line,
    ROUND(AVG(rating), 2) as average_rating
FROM sales
GROUP BY product_line
ORDER BY average_rating DESC;


-- ----------------------------------------------------------------------------
-- -------------------------------- Sales -------------------------------------

-- Number of sales made in each time of the day per weekday
SELECT
	day_name,
    COUNT(day_name) as number_of_sales
FROM
	sales
GROUP BY 
	day_name
ORDER BY 
	number_of_sales DESC;

-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
    SUM(total) as revenue
FROM 
	sales
GROUP BY 
	customer_type
ORDER BY 
	revenue DESC
LIMIT 1;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT
	city,
    SUM(VAT) as vat
FROM 
	sales
GROUP BY 
	city
ORDER BY
	vat DESC;
    
-- Which customer type pays the most in VAT?
SELECT
	customer_type,
    SUM(VAT) as vat
FROM 
	sales
GROUP BY 
	customer_type
ORDER BY
	vat DESC;

-- ----------------------------------------------------------------------------
-- -------------------------------- Customer ----------------------------------
-- How many unique customer types does the data have?
SELECT
	COUNT(DISTINCT customer_type)
FROM 
	sales;
    
-- How many unique payment methods does the data have?
SELECT
	COUNT(DISTINCT payment_method)
FROM 
	sales;

-- What is the most common customer type?
SELECT
	customer_type,
    COUNT(customer_type) as cnt
FROM
	sales
GROUP BY customer_type
ORDER BY cnt DESC;

-- Which customer type buys the most?
SELECT
	customer_type,
    SUM(total) as sum
FROM
	sales
GROUP BY customer_type
ORDER BY sum DESC;

-- What is the gender of most of the customers?
SELECT
	gender,
    COUNT(gender) as cnt
FROM 
	sales
GROUP BY gender
ORDER BY cnt DESC;

-- What is the gender distribution per branch?
SELECT
	branch, gender,
    count(branch) / (SELECT COUNT(*) FROM sales WHERE branch = s.branch)
FROM sales s
GROUP BY branch, gender
ORDER BY branch, gender;

-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
    AVG(rating)
FROM sales
GROUP BY time_of_day;

-- Which time of the day do customers give most ratings per branch?
SELECT
	branch,
    time_of_day,
    AVG(rating) as rating_average
FROM sales
GROUP BY branch, time_of_day
ORDER BY branch, rating_average DESC;

-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
    AVG(rating) as average_rating
FROM sales
GROUP BY day_name
ORDER BY average_rating DESC;

-- Which day of the week has the best average ratings per branch?
SELECT
	branch,
    day_name,
    AVG(rating) as average_rating
FROM sales
GROUP BY branch, day_name
ORDER BY branch, average_rating DESC








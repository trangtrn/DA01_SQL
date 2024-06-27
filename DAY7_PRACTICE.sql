--ex1:
SELECT name 
FROM students
WHERE marks > 75
ORDER BY RIGHT(name, 3), id

--ex2:
SELECT user_id, 
CONCAT(UPPER(LEFT(name,1)), LOWER(SUBSTRING(name from 2))) AS name
FROM users
ORDER BY user_id

--ex3:
SELECT manufacturer, 
'$' || ROUND(CAST(SUM(total_sales) / 10^6 AS decimal) ,0) || ' million' AS sale
FROM pharmacy_sales
GROUP BY manufacturer
ORDER BY SUM(total_sale) DESC

--ex4:
SELECT EXTRACT(MONTH FROM submit_date) AS mth,
product_id AS product,
ROUND(AVG(stars),2) AS avg_stars
FROM reviews
GROUP BY mth, product
ORDER BY mth, product 

--ex5:
SELECT sender_id,
COUNT(*) AS message_count
FROM messages
WHERE EXTRACT(YEAR FROM sent_date) = 2022 AND EXTRACT(MONTH FROM sent_date) = 8
GROUP BY sender_id
ORDER BY message_count DESC
LIMIT 2

--ex6:
SELECT tweet_id
FROM tweets
WHERE LENGTH(content) > 15

--ex7:
SELECT activity_date AS day, 
COUNT(DISTINCT user_id) AS active_users
FROM activity
WHERE activity_date BETWEEN '2019-06-27' AND '2019-07-28'
GROUP BY activity_date

--ex8:
select COUNT(id) 
from employees
WHERE EXTRACT(YEAR FROM joining_date) = 2022 AND 
EXTRACT(MONTH FROM joining_date) BETWEEN 1 AND 7

--ex9:
select POSITION('a' IN first_name) 
from worker
WHERE first_name = 'Amitah'

--ex10:
select title, 
SUBSTRING(title FROM LENGTH(winery) +2 FOR 4) AS year
from winemag_p2
WHERE country = 'Macedonia'

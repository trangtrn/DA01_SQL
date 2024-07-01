--ex1:
WITH duplicate AS
(SELECT company_id, title, description
FROM job_listings 
GROUP BY company_id, title, description
HAVING COUNT(*) > 1)
  
SELECT COUNT(company_id) AS duplicate_companies FROM duplicate

--ex2:
WITH total_spend AS
(SELECT category, product, SUM(spend) AS total_spend,
RANK() OVER (PARTITION BY category ORDER BY SUM(spend) DESC) AS rank
FROM product_spend 
WHERE EXTRACT(YEAR FROM CAST(transaction_date AS DATE)) = 2022
GROUP BY category, product
ORDER BY category, total_spend)
  
SELECT category, product, total_spend
FROM total_spend 
WHERE rank <=2
ORDER BY category, total_spend DESC

--ex3:
WITH calls_per_holder AS
(SELECT policy_holder_id, count(*) AS calls_no
FROM callers
GROUP BY policy_holder_id)
  
SELECT COUNT(*) AS policy_holder_count
FROM calls_per_holder
WHERE calls_no >= 3

--ex4:
SELECT page_id
FROM pages p
WHERE NOT EXISTS (SELECT page_id FROM page_likes
                  WHERE page_id = p.page_id)

--ex5:
WITH users_in_june AS
(SELECT user_id 
FROM user_actions
WHERE EXTRACT(MONTH FROM event_date) = 6 
AND EXTRACT(YEAR FROM event_date) = 2022)
  
SELECT EXTRACT(MONTH FROM event_date) as month, 
COUNT(DISTINCT a.user_id) as monthly_active_users 
FROM user_actions a
JOIN users_in_june b ON a.user_id = b.user_id
WHERE EXTRACT(MONTH FROM event_date) = 7
GROUP BY EXTRACT(MONTH FROM event_date)

--ex6:
SELECT LEFT(trans_date,7) as month,
country, 
COUNT(*) AS trans_count,
COUNT(CASE WHEN state = 'approved' THEN amount END) AS approved_count,
SUM(amount) AS trans_total_amount,
SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_total_amount
FROM transactions
GROUP BY LEFT(trans_date,7), country

--ex7:
WITH new_table AS 
(SELECT product_id, 
MIN(year) AS first_year
FROM sales
GROUP BY product_id)
  
SELECT n.product_id, n.first_year, 
s.quantity AS quantity, 
s.price AS price 
FROM sales s
JOIN new_table n ON s.product_id = n.product_id AND s.year = n.first_year

-ex8:
SELECT customer_id
FROM customer
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (SELECT COUNT(*) FROM product)

--ex9:
SELECT employee_id
FROM employees
WHERE salary < 30000
AND manager_id NOT IN (SELECT employee_id FROM employees)
ORDER BY employee_id

--ex10:
WITH duplicate AS
(SELECT company_id, title, description
FROM job_listings 
GROUP BY company_id, title, description
HAVING COUNT(*) > 1)
  
SELECT COUNT(company_id) AS duplicate_companies FROM duplicate

--ex11:
WITH most_ratings AS
(SELECT u.name
FROM movierating mr
JOIN users u ON mr.user_id = u.user_id
GROUP BY u.name
ORDER BY COUNT(*) DESC, u.name LIMIT 1), 
highest_rating AS
(SELECT m.title
FROM movierating mr
JOIN movies m ON mr.movie_id = m.movie_id
WHERE MONTH(mr.created_at) = 2 
AND YEAR(mr.created_at) = 2020
GROUP BY m.title
ORDER BY AVG(mr.rating) DESC, m.title LIMIT 1)
  
SELECT name AS results FROM most_ratings
UNION ALL
SELECT title FROM highest_rating

--ex12:
WITH total AS
(SELECT requester_id, accepter_id FROM requestaccepted
UNION ALL
SELECT accepter_id, requester_id FROM requestaccepted)

SELECT requester_id AS id,
COUNT(*) AS num 
FROM total
GROUP BY requester_id
ORDER BY num DESC LIMIT 1

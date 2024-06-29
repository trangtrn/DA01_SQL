--ex1:
SELECT country.continent, FLOOR(AVG(city.population))
FROM country
INNER JOIN city 
ON country.code = city.countrycode
GROUP BY country.continent

--ex2:
SELECT ROUND(SUM(CASE WHEN texts.signup_action = 'Confirmed' THEN 1 END)*1.0
/COUNT(DISTINCT emails.*),2)
FROM emails
LEFT JOIN texts
ON emails.email_id = texts.email_id

--ex3:
SELECT age.age_bucket,
ROUND(SUM(CASE WHEN act.activity_type = 'send' THEN act.time_spent ELSE 0 END)
/SUM(act.time_spent)*100.0, 2)  AS send_perc,
ROUND(SUM(CASE WHEN act.activity_type = 'open' THEN act.time_spent ELSE 0 END)
/SUM(act.time_spent)*100.0, 2)  AS open_perc
FROM activities act  
INNER JOIN age_breakdown age
ON act.user_id = age.user_id
WHERE act.activity_type IN ('send', 'open')
GROUP BY age.age_bucket,open_perc,send_perc

--ex4:
SELECT customer_id
FROM customer_contracts c
LEFT JOIN products p 
ON c.product_id = p.product_id
GROUP BY customer_id
HAVING COUNT(DISTINCT p.product_category) = (SELECT COUNT(DISTINCT product_category) FROM products)

--ex5:
SELECT man.employee_id, man.name, 
COUNT(*) AS reports_count, 
ROUND(AVG(emp.age), 0) AS average_age
FROM employees emp
JOIN employees man
ON emp.reports_to = man.employee_id
GROUP BY man.employee_id, man.name

--ex6:
SELECT p.product_name,
SUM(o.unit) AS unit
FROM products p 
JOIN orders o
ON p.product_id = o.product_id
WHERE EXTRACT(YEAR FROM o.order_date) = 2020 AND EXTRACT(MONTH FROM o.order_date) = 2
GROUP BY p.product_name
HAVING SUM(o.unit) >= 100

--ex7:
SELECT p.page_id
FROM pages p
LEFT JOIN page_likes l
ON p.page_id = l.page_id
WHERE l.page_id IS NULL

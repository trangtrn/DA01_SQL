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

--**MID COURSE TEST**
--Q1:
SELECT DISTINCT replacement_cost FROM film
ORDER BY replacement_cost

--Q2:
SELECT
CASE WHEN replacement_cost BETWEEN 9.99 AND 19.99 THEN 'low' 
	WHEN replacement_cost BETWEEN 20.00 AND 24.99 THEN 'medium'
	WHEN replacement_cost BETWEEN 25.00 AND 29.99 THEN 'high'
END category,
COUNT(*) AS quantity
FROM film
GROUP BY category

--Q3:
SELECT f.title, f.length, c.name 
FROM film f
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
WHERE c.name IN ('Drama', 'Sports')
ORDER BY f.length DESC

--Q4: 
SELECT c.name, 
COUNT(*) AS quantity
FROM film f
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY quantity DESC

--Q5:
SELECT a.first_name || ' '|| a.last_name AS actor_name, 
COUNT(*) AS no_of_movies
FROM film f
INNER JOIN film_actor fa ON f.film_id = fa.film_id
INNER JOIN actor a ON fa.actor_id = a.actor_id
GROUP BY actor_name
ORDER BY no_of_movies DESC

--Q6:
SELECT COUNT(*)
FROM address a
LEFT JOIN customer c ON a.address_id = c.address_id
WHERE c.address_id IS NULL 

--Q7:
SELECT city.city, 
SUM(p.amount) AS total_revenue
FROM payment p 
INNER JOIN customer c ON p.customer_id = c.customer_id
INNER JOIN address a ON c.address_id = a.address_id
INNER JOIN city ON a.city_id = city.city_id
GROUP BY city.city
ORDER BY total_revenue DESC

--Q8:
SELECT city.city ||', '|| country.country AS city_country, 
SUM(p.amount) AS total_revenue
FROM payment p 
INNER JOIN customer c ON p.customer_id = c.customer_id
INNER JOIN address a ON c.address_id = a.address_id
INNER JOIN city ON a.city_id = city.city_id
INNER JOIN country ON city.country_id = country.country_id
GROUP BY city_country
ORDER BY total_revenue 

--ex1:
WITH first AS
(SELECT *,
FIRST_VALUE(delivery_id) OVER(PARTITION BY customer_id ORDER BY order_date) AS first_delivery_id,
CASE WHEN order_date = customer_pref_delivery_date THEN 1 ELSE 0 END as status
FROM delivery)

SELECT round(SUM(status)/COUNT(*)*100.0,2) AS immediate_percentage
FROM first
WHERE delivery_id = first_delivery_id

--ex2:
WITH next AS
(SELECT *,
LEAD(event_date) OVER(PARTITION BY player_id ORDER BY event_date) AS next_login,
RANK() OVER(PARTITION BY player_id ORDER BY event_date) AS first_login
FROM activity)

SELECT round(count(distinct player_id)/(select count(distinct player_id)from activity),2) AS fraction
FROM next
WHERE  next_login = event_date + interval 1 DAY 
AND first_login = 1

--ex3:
WITH a AS
(SELECT *, 
CASE WHEN id % 2 = 0 THEN LAG(student) OVER(ORDER BY id) 
ELSE LEAD(student, 1, student) OVER(ORDER BY id) END new
FROM seat) 

SELECT id, new AS student FROM a

--ex4:
WITH a AS
(SELECT visited_on,
SUM(amount) AS amount
FROM customer
GROUP BY visited_on)

SELECT visited_on,
SUM(amount) OVER(ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS amount,
ROUND(AVG(amount) OVER(ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) AS average_amount
FROM a
ORDER BY visited_on 
LIMIT 100
OFFSET 6

--ex5:
WITH dup AS
(SELECT *,
COUNT(*) OVER(PARTITION BY lat,lon) AS location_dup,
COUNT(*) OVER(PARTITION BY tiv_2015) AS amount_dup
FROM insurance)

SELECT ROUND(SUM(tiv_2016),2) AS tiv_2016 
FROM dup
WHERE location_dup = 1
AND amount_dup > 1

--ex6:
WITH highest_salary AS
(SELECT e.*,
DENSE_RANK() OVER(PARTITION BY e.departmentId ORDER BY e.salary DESC) AS salary_rank,
d.name AS Department
FROM employee e
JOIN department d ON e.departmentId = d.id)

SELECT Department, name AS Employee, salary AS Salary
FROM highest_salary
WHERE salary_rank <= 3

--ex7:
WITH total_weight AS
(SELECT *,
SUM(weight) OVER(ORDER BY turn) AS acc_weight
FROM queue)

SELECT person_name
FROM total_weight
WHERE acc_weight <= 1000
ORDER BY acc_weight DESC LIMIT 1

--ex8:
SELECT product_id, new_price AS price
FROM products
WHERE (product_id, change_date) IN (SELECT product_id, MAX(change_date)
                                    FROM products
                                    WHERE change_date <= '2019-08-16'
                                    GROUP BY product_id)
UNION ALL
SELECT product_id, 10 AS price
FROM products
GROUP BY product_id
HAVING MIN(change_date) > '2019-08-16'

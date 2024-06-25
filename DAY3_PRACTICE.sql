--ex1: 
SELECT NAME FROM CITY 
WHERE COUNTRYCODE = 'USA' AND POPULATION > 120000

--ex2: 
SELECT * FROM CITY
WHERE COUNTRYCODE = 'JPN' 

--ex3:
SELECT CITY, STATE FROM STATION

--ex4:
SELECT DISTINCT CITY FROM STATION
WHERE LOWER(LEFT(CITY, 1)) IN ('a', 'e', 'i', 'o', 'u')

--ex5:
SELECT DISTINCT CITY FROM STATION
WHERE LOWER(RIGHT(CITY, 1)) IN ('a', 'e', 'i', 'o', 'u')

--ex6:
SELECT DISTINCT CITY FROM STATION 
WHERE NOT LOWER(LEFT(CITY, 1)) IN ('a', 'u', 'o', 'i', 'e')

--ex7:
SELECT name FROM Employee
ORDER BY name 

--ex8:
SELECT name FROM Employee
WHERE salary > 2000 AND months < 10
ORDER BY employee_id

--ex9:
SELECT product_id FROM Products
WHERE low_fats = 'Y' AND recyclable = 'Y'

--ex10:
SELECT name FROM Customer
WHERE referee_id <> 2 OR referee_id IS NULL

--ex11:
SELECT name, population, area FROM World
WHERE area >= 3000000 OR population >= 25000000

--ex12:
SELECT DISTINCT author_id AS id FROM Views
WHERE author_id = viewer_id 
ORDER BY author_id

--ex13:
SELECT part, assembly_step FROM parts_assembly
WHERE finish_date IS NULL

--ex14:
SELECT * FROM lyft_drivers
WHERE NOT yearly_salary BETWEEN 30000 AND 70000

-ex15:
SELECT advertising_channel FROM uber_advertising
WHERE year = 2019 AND money_spent > 100000

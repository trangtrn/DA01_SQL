--ex1:
SELECT 
COUNT(CASE WHEN device_type = 'laptop' THEN 0 END) AS laptop_views,
COUNT(CASE WHEN device_type IN ('tablet','phone') THEN 0 END) AS mobile_views
FROM viewership

--ex2:
SELECT x,y,z,
CASE WHEN x+y>z AND y+z>x AND x+z>y THEN 'Yes' ELSE 'No' END triangle
FROM Triangle

--ex3:
SELECT 
ROUND(CAST(SUM(CASE WHEN call_category = 'n/a' OR call_category IS NULL THEN 1 END) AS decimal)
/COUNT(*)*100,1) AS uncategorised_call_pct
FROM callers

--ex4:
SELECT name FROM Customer
WHERE referee_id <> 2 OR referee_id IS NULL

--ex5:
SELECT  
CASE 
    WHEN pclass = 1 THEN 'first_class'
    WHEN pclass = 2 THEN 'second_class'
    ELSE 'third_class' END class,
SUM(CASE WHEN survived = 1 THEN 1 END) AS survivors,
SUM(CASE WHEN survived = 0 THEN 1 END) AS non_survivors
FROM titanic
GROUP BY class

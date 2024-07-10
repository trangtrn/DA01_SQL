--TASK 1:  Số lượng đơn hàng và số lượng khách hàng mỗi tháng
SELECT FORMAT_DATE('%Y - %m',created_at) AS order_month,
COUNT(DISTINCT user_id) AS total_users,
COUNT(DISTINCT order_id) AS total_orders
FROM bigquery-public-data.thelook_ecommerce.orders
WHERE status = 'Complete' AND created_at BETWEEN '2019-01-01' AND '2022-05-01'
GROUP BY FORMAT_DATE('%Y - %m',created_at)
ORDER BY order_month

/*---INSIGHT: 
#1 Lượng đơn hàng và lượng người mua mỗi tháng có xu hướng tăng dần đều, trung bình 118% mỗi tháng trong thời gian quan sát.
#2 Lượng đơn hàng và lượng người mua mỗi tháng phần lớn có giá trị bằng nhau, cho thấy 1 người mua thường chỉ đặt 1 đơn hàng mỗi tháng 
---*/

--TASK 2: Giá trị đơn hàng trung bình (AOV) và số lượng khách hàng mỗi tháng
SELECT FORMAT_DATE('%Y - %m',created_at) AS order_month,
COUNT(DISTINCT user_id) AS total_users,
SUM(sale_price)/COUNT(DISTINCT order_id) AS avg_amount
FROM bigquery-public-data.thelook_ecommerce.order_items
WHERE status = 'Complete' AND created_at BETWEEN '2019-01-01' AND '2022-05-01'
GROUP BY FORMAT_DATE('%Y - %m',created_at)
ORDER BY order_month

/*---INSIGHT
#1 Lượng khách hàng duy trì và tăng dần đều qua thời gian
#2 Giá trị trung bình của các đơn hàng biến động mạnh trong năm 2019 là khoảng thời gian đầu hoạt đông, thấp nhất vào tháng 5 với AOV $61 và cao nhất vào tháng 7 với AOV $105. Từ năm 2020, AOV biến động ổn định hơn với biên độ dao động $80-96
---*/

--TASK 3: Nhóm khách hàng theo độ tuổi
WITH min_max AS (
SELECT *,
MIN(age) OVER(PARTITION BY gender) AS min_age,
MAX(age) OVER(PARTITION BY gender) AS max_age
FROM bigquery-public-data.thelook_ecommerce.users)
, age AS (
SELECT first_name, last_name, gender, age, 'youngest' AS tag
FROM min_max 
WHERE age = min_age
UNION ALL
SELECT first_name, last_name, gender, age, 'oldest' AS tag
FROM min_max 
WHERE age = max_age
ORDER BY age)

--DANH SÁCH NHỎ TUỔI NHẤT & LỚN TUỔI NHẤT
SELECT * FROM age

-- PIVOT SỐ LƯỢNG THEO TUỔI NHỎ, LỚN VÀ GIỚI TÍNH
SELECT tag,
SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) AS female,
SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END) AS male
FROM age
GROUP BY tag

/*---INSIGHT
Tại tuổi 12, có 842 khách female và 913 khách male. Tại tuổi 70, có 882 khách female và 849 khách male 
#1 Lượng khách không bị phân hoá bởi yếu tố giới tính do số lượng khá cân bằng giữa cả 2 giới
#2 Lượng khách nhỏ tuổi nhỉnh hơn lượng khách lớn tuổi, tuy nhiên không quá đáng kể
---*/

--TASK 4: Top 5 sản phẩm mỗi tháng.
WITH products_sold AS (
SELECT FORMAT_DATE('%Y - %m',created_at) AS month,
product_id, count(*) AS quantity
FROM bigquery-public-data.thelook_ecommerce.order_items
WHERE status = 'Complete' AND created_at BETWEEN '2019-01-01' AND '2022-05-01'
GROUP BY FORMAT_DATE('%Y - %m',created_at), product_id
ORDER BY month)
, profit_rank AS (
SELECT ps.month, p.id, p.name, 
round(p.retail_price * ps.quantity,2) AS sales,
round(p.cost * ps.quantity,2) AS cogs,
round((p.retail_price - p.cost) * ps.quantity,2) AS profit,
DENSE_RANK() OVER(PARTITION BY month ORDER BY (p.retail_price - p.cost) * ps.quantity DESC) AS rank_per_month
FROM bigquery-public-data.thelook_ecommerce.products p
JOIN products_sold ps ON p.id = ps.product_id)

SELECT * FROM profit_rank 
WHERE rank_per_month <= 5 
ORDER BY month

--TASK 5: Doanh thu tính đến thời điểm hiện tại trên mỗi danh mục
WITH product_3_month AS 
(SELECT FORMAT_DATE('%Y-%m-%d',created_at) AS date,
product_id, count(*) AS quantity
FROM bigquery-public-data.thelook_ecommerce.order_items
WHERE status = 'Complete' AND created_at BETWEEN '2022-01-15' AND '2022-04-16' 
GROUP BY FORMAT_DATE('%Y-%m-%d',created_at), product_id
ORDER BY date)

SELECT p3m.date, p.category, 
ROUND(SUM(p.retail_price * p3m.quantity),2) AS revenue
FROM bigquery-public-data.thelook_ecommerce.products p
JOIN product_3_month p3m ON p.id = p3m.product_id
GROUP BY p3m.date, p.category
ORDER BY p3m.date, revenue DESC

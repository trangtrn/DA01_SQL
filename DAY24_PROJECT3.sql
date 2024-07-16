--TASK 1: DEAL SIZE BY PRODUCT LINE AND YEAR
SELECT productline, year_id,
SUM(sales) AS deal_size
FROM public.sales_dataset_rfm_prj
WHERE status IN ('Shipped', 'Resolved')
GROUP BY productline, year_id
ORDER BY productline, year_id

--TASK 2: MONTH WITH BEST REVENUE EVERY YEAR
WITH rev_per_mnth AS (
SELECT year_id, month_id, 
SUM(sales) AS revenue,
COUNT(DISTINCT ordernumber) AS order_number,
RANK() OVER(PARTITION BY year_id ORDER BY SUM(sales) DESC)
FROM public.sales_dataset_rfm_prj
WHERE status IN ('Shipped', 'Resolved')
GROUP BY year_id, month_id)

SELECT year_id, month_id, revenue, order_number
FROM rev_per_mnth
WHERE rank = 1

/*
#1 - Kết quả các tháng doanh thu cao nhất mỗi năm:
2003: Tháng 11 với doanh thu $1.029.838
2004: Tháng 11 với doanh thu $1.062.788
2005 (tính đến tháng 5): Tháng 3 với doanh thu $374.263

#2 - Phân tích biến động doanh thu
Trong 2003, xu hướng doanh thu dao động ổn định quanh $200k trong suốt 9 tháng đầu, sau đó tăng mạnh và lập đỉnh vào tháng 11.
Trong 2004, xu hướng nửa năm đầu diễn biến giống 2003 với doanh thu $200-300k mỗi tháng. Từ tháng 6 doanh thu tăng dần và ổn định, 
xu hướng tiếp tục cho đến khi lập đỉnh vào tháng 11.
Trong 2005, doanh thu ghi nhận 3 tháng đầu khá nhất quán với 2 năm trước đó. Tuy nhiên, vào tháng 4 doanh thu giảm mạnh xuống $130k, 
mức doanh thu thấp nhất kể từ tháng 1/2003 >> cần tìm hiểu nguyên nhân suy giảm
*/
  
--TASK 3: BEST-SELLING PRODUCT LINE IN NOVEMBER
WITH rev_nov_productline AS (
SELECT year_id, productline, 
SUM(sales) AS revenue,
RANK() OVER(PARTITION BY year_id ORDER BY SUM(sales) DESC)
FROM public.sales_dataset_rfm_prj
WHERE month_id = 11 AND status IN ('Shipped', 'Resolved')
GROUP BY year_id, productline)

SELECT year_id, productline, revenue
FROM rev_nov_productline
WHERE rank = 1
/* Kết quả cho thấy vào tháng 11 năm 2003 và 2004, dòng Classic Cars tạo ra doanh thu lớn nhất */
  
--TASK 4: PRODUCT LINE WITH BEST REVENUE IN UK PER YEAR
WITH uk_productline_rev AS (
SELECT year_id, productline, 
SUM(sales) AS revenue,
RANK() OVER(PARTITION BY year_id ORDER BY SUM(sales) DESC)
FROM public.sales_dataset_rfm_prj
WHERE country = 'UK' AND status IN ('Shipped', 'Resolved')
GROUP BY year_id, productline)

SELECT year_id, productline, revenue, 
RANK() OVER(ORDER BY revenue DESC)
FROM uk_productline_rev
WHERE rank = 1

/* 2003 - Classic Cars; 2004 - Vintage Cars; 2005 - Motorcycles */

--TASK 5: SEGMENTATION ANALYSYS USING RFM METHOD
WITH rfm_per_customer AS (
SELECT customername,
CURRENT_DATE - MAX(orderdate) AS R,
COUNT(DISTINCT ordernumber) AS F,
SUM(sales) AS M
FROM public.sales_dataset_rfm_prj
WHERE status IN ('Shipped', 'Resolved')
GROUP BY customername)
, grouped_rfm AS (
SELECT customername, 
NTILE(5) OVER(ORDER BY r DESC) AS r,
NTILE(5) OVER(ORDER BY f) AS f,
NTILE(5) OVER(ORDER BY m) AS m
FROM rfm_per_customer)
, customer_rfm_score AS (
SELECT customername, 
r::varchar||f::varchar||m::varchar AS rfm
FROM grouped_rfm)
, segment_customer as (
SELECT c.customername, ss.segment
FROM customer_rfm_score c
JOIN segment_score ss ON c.rfm = ss.scores)

SELECT segment, count(*)
FROM segment_customer
GROUP BY segment
ORDER BY count

/* 
1. Trong tổng số 92 khách hàng, nhóm Hibernating customers chiếm 22 (~25% tổng KH). 
Tuy nhiên đây là nhóm có customer value thấp, đóng góp khoảng 5% doanh thu >> không nên tập trung nhiều nguồn lực quảng cáo cho nhóm này.
2. Trong tổng số 92 khách hàng, nhóm Loyal (11) và nhóm Champions (14) chiếm 25 (~27% tổng KH).
Đây là 2 nhóm khách hàng quan trọng tạo nên phần lớn doanh thu cho công ty >> nên có những chương trình chăm sóc KH đặc biệt như discount/quà tặng limited
Đặc biệt, do nhóm New customers và Promising đang rất thấp, chỉ 1-3 người >> có thể offer nhóm Champions thêm mức ưu đãi nếu họ giới thiệu được thêm KH mới.
*/

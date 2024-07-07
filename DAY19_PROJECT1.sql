--#1: CHUYỂN ĐỔI DATA TYPE CÁC CỘT

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER quantityordered TYPE integer USING (TRIM(quantityordered)::integer)

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER priceeach TYPE numeric USING (TRIM(priceeach)::numeric)

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER sales TYPE numeric USING (TRIM(sales)::numeric)

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER orderdate TYPE date USING (TRIM(orderdate)::date)

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER msrp TYPE integer USING (TRIM(msrp)::integer)

--#2: TÌM NULL & EMPTY VALUES
SELECT * FROM SALES_DATASET_RFM_PRJ
WHERE ordernumber IS NULL or ordernumber = ''

SELECT * FROM SALES_DATASET_RFM_PRJ
WHERE quantityordered IS NULL or quantityordered::varchar = ''

SELECT * FROM SALES_DATASET_RFM_PRJ
WHERE priceeach IS NULL or priceeach::varchar = ''

SELECT * FROM SALES_DATASET_RFM_PRJ
WHERE orderlinenumber IS NULL or orderlinenumber = ''

SELECT * FROM SALES_DATASET_RFM_PRJ
WHERE orderdate IS NULL or orderdate::varchar = ''

--#3: THÊM CỘT HỌ TÊN
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD COLUMN contactfirstname VARCHAR,
ADD COLUMN contactlastname VARCHAR

--Tách và format họ tên
UPDATE SALES_DATASET_RFM_PRJ
SET contactlastname = left(contactfullname, POSITION('-' IN contactfullname)-1), 
contactfirstname = substring(contactfullname from POSITION('-' IN contactfullname)+1)

UPDATE SALES_DATASET_RFM_PRJ
SET contactlastname = UPPER(left(contactlastname,1))||LOWER(substring(contactlastname FROM 2)),
contactfirstname = UPPER(left(contactfirstname,1))||LOWER(substring(contactfirstname FROM 2))

--#4: THÊM CỘT QUÝ, THÁNG, NĂM
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD COLUMN qtr_id INT,
ADD COLUMN month_id INT,
ADD COLUMN year_id INT

UPDATE SALES_DATASET_RFM_PRJ
SET month_id = EXTRACT(MONTH FROM orderdate),
year_id = EXTRACT(YEAR FROM orderdate),

UPDATE SALES_DATASET_RFM_PRJ
SET qtr_id = (CASE WHEN month_id IN (1,2,3) THEN 1
		  WHEN month_id IN (4,5,6) THEN 2 
		  WHEN month_id IN (7,8,9) THEN 3 
		  ELSE 4 END)
		  
--#5: TÌM OUTLIER CHO QUANTITYORDERED
--cách 1: boxplot
WITH min_max_quant AS
(SELECT Q1-1.5*(Q3-Q1) AS min_quant, Q3+1.5*(Q3-Q1) AS max_quant
FROM 
(SELECT percentile_cont(0.25) WITHIN GROUP (ORDER BY quantityordered) AS Q1,
percentile_cont(0.5) WITHIN GROUP (ORDER BY quantityordered) AS Q2,
percentile_cont(0.75) WITHIN GROUP (ORDER BY quantityordered) AS Q3
FROM SALES_DATASET_RFM_PRJ) AS percentile),
outliers AS
(SELECT * FROM SALES_DATASET_RFM_PRJ
WHERE quantityordered < (SELECT min_quant FROM min_max_quant)
OR quantityordered > (SELECT max_quant FROM min_max_quant))

DELETE FROM SALES_DATASET_RFM_PRJ
WHERE (ordernumber, quantityordered) IN (SELECT ordernumber, quantityordered FROM outliers)

--cách 2: z-score
WITH avg_stddev AS 
(SELECT AVG(quantityordered) AS avg,
 STDDEV(quantityordered) AS stddev
FROM SALES_DATASET_RFM_PRJ), 
outliers AS
(SELECT *,
(quantityordered-(SELECT avg FROM avg_stddev))/(SELECT stddev FROM avg_stddev) AS z_score
FROM SALES_DATASET_RFM_PRJ
WHERE ABS((quantityordered-(SELECT avg FROM avg_stddev))/(SELECT stddev FROM avg_stddev)) > 3)

DELETE FROM SALES_DATASET_RFM_PRJ
WHERE (ordernumber, quantityordered) IN (SELECT ordernumber, quantityordered FROM outliers)


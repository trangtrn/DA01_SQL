--ex1:
WITH current_year_transactions AS
(SELECT EXTRACT(YEAR FROM transaction_date) AS year, 
product_id,
spend AS curr_year_spend,
LAG(spend) OVER(PARTITION BY product_id ORDER BY EXTRACT(YEAR FROM transaction_date)) AS prev_year_spend
FROM user_transactions)

SELECT *,
ROUND((curr_year_spend - prev_year_spend)/prev_year_spend*100,2) AS yoy_rate
FROM current_year_transactions

--ex2:
SELECT DISTINCT card_name,
FIRST_VALUE(issued_amount) OVER(PARTITION BY card_name ORDER BY issue_year,issue_month) AS issued_amount
FROM monthly_cards_issued 
ORDER BY issued_amount DESC

--ex3:
WITH ranked_transactions AS
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY transaction_date) AS rank
FROM transactions)

SELECT user_id, spend, transaction_date
FROM ranked_transactions
WHERE rank = 3

--ex4:
WITH ranks AS
(SELECT * ,
RANK() OVER(PARTITION BY user_id ORDER BY transaction_date DESC) AS rank
FROM user_transactions) 

SELECT transaction_date, user_id, 
COUNT(*) AS purchase_count
FROM ranks
WHERE rank = 1
GROUP BY transaction_date, user_id
ORDER BY transaction_date

--ex5:
SELECT user_id, tweet_date,
round(AVG(tweet_count) OVER(PARTITION BY user_id ORDER BY tweet_date 
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS rolling_avg_3d
FROM tweets

--ex6:
WITH rank AS
(SELECT *,
EXTRACT(EPOCH FROM transaction_timestamp-LAG(transaction_timestamp) OVER(PARTITION BY merchant_id, credit_card_id, amount 
ORDER BY transaction_timestamp))/60 AS interval_after_previous,
COUNT(*) OVER(PARTITION BY merchant_id, credit_card_id, amount ORDER BY transaction_timestamp) AS alike_trans
FROM transactions)

SELECT COUNT(*) AS payment_count
FROM rank 
WHERE interval_after_previous <= 10

--ex7:
WITH total_spend AS
(SELECT category, product, SUM(spend) AS total_spend,
RANK() OVER (PARTITION BY category ORDER BY SUM(spend) DESC) AS rank
FROM product_spend 
WHERE EXTRACT(YEAR FROM CAST(transaction_date AS DATE)) = 2022
GROUP BY category, product
ORDER BY category, total_spend )

SELECT category, product, total_spend
FROM total_spend 
WHERE rank <=2
ORDER BY category, total_spend DESC

--ex8:
WITH all_data AS
(SELECT a.artist_name, 
COUNT(s.song_id) AS hit_count,
DENSE_RANK() OVER(ORDER BY COUNT(s.song_id) DESC) AS artist_rank
FROM global_song_rank sr
JOIN songs s ON sr.song_id = s.song_id
JOIN artists a ON a.artist_id = s.artist_id
WHERE rank BETWEEN 1 AND 10
GROUP BY a.artist_name)

SELECT artist_name, artist_rank
FROM all_data
WHERE artist_rank <= 5


1. SELECT
  instrument_id, price_date, close_price AS today,
  LAG(close_price) OVER (PARTITION BY instrument_id ORDER BY price_date) AS yesterday,
  close_price - LAG(close_price) OVER (PARTITION BY instrument_id ORDER BY price_date) AS change,
  CASE WHEN close_price = LAG(close_price) OVER (PARTITION BY instrument_id ORDER BY price_date)
            AND volume = 0 THEN TRUE ELSE FALSE END AS is_stale
FROM instrument_prices WHERE source='bloomberg'
ORDER BY instrument_id, price_date;
 instrument_id | price_date |  today   | yesterday | change  | is_stale 
---------------+------------+----------+-----------+---------+----------
 AAPL          | 2024-01-02 | 185.2000 |           |         | f
 AAPL          | 2024-01-03 | 184.2500 |  185.2000 | -0.9500 | f
 AAPL          | 2024-01-05 | 187.0000 |  184.2500 |  2.7500 | f
 MSFT          | 2024-01-02 | 374.0200 |           |         | f
 MSFT          | 2024-01-03 | 374.0200 |  374.0200 |  0.0000 | t
 MSFT          | 2024-01-04 | 375.5000 |  374.0200 |  1.4800 | f


2. SELECT instrument_id, price_date, close_price,
  RANK()       OVER (PARTITION BY price_date ORDER BY close_price DESC) AS rnk,
  DENSE_RANK() OVER (PARTITION BY price_date ORDER BY close_price DESC) AS dense_rnk,
  ROW_NUMBER() OVER (PARTITION BY price_date ORDER BY close_price DESC) AS rn
FROM instrument_prices WHERE source='bloomberg'
ORDER BY price_date, rnk;
 instrument_id | price_date | close_price | rnk | dense_rnk | rn 
---------------+------------+-------------+-----+-----------+----
 MSFT          | 2024-01-02 |    374.0200 |   1 |         1 |  1
 AAPL          | 2024-01-02 |    185.2000 |   2 |         2 |  2
 MSFT          | 2024-01-03 |    374.0200 |   1 |         1 |  1
 AAPL          | 2024-01-03 |    184.2500 |   2 |         2 |  2
 MSFT          | 2024-01-04 |    375.5000 |   1 |         1 |  1
 AAPL          | 2024-01-05 |    187.0000 |   1 |         1 |  1

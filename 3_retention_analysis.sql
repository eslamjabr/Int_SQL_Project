WITH customer_last_purchase AS (
SELECT 
	customerkey,
	cleaned_name,
	orderdate,
	row_number() OVER(PARTITION BY customerkey ORDER BY orderdate DESC ) AS rn, 
	first_purchase_date,
	cohort_year
FROM 
	cohort_analysis
), churned_customers AS (
SELECT 
	customerkey,
	cleaned_name,
	first_purchase_date,
	orderdate AS  last_purchase_date,
	CASE 
		WHEN orderdate < (SELECT MAX(orderdate) FROM sales)- INTERVAL '6 months' THEN 'Churned'
		ELSE 'Active'
	END AS customer_status,
	cohort_year
FROM customer_last_purchase 
WHERE rn = 1
	AND first_purchase_date < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months'
)

SELECT 
	cohort_year,
	customer_status,
	count(customerkey) AS num_customers,
	sum(count(customerkey)) OVER(PARTITION BY cohort_year ) AS total_customers,
	round(100*count(customerkey) / sum(count(customerkey)) OVER( PARTITION BY cohort_year ) ,2) AS status_percentage
FROM churned_customers 
group BY cohort_year,customer_status
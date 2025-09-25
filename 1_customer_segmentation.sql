WITH customer_ltv AS (
	SELECT 
		customerkey,
		cleaned_name,
		sum(total_net_revenue) AS total_ltv
	FROM
		cohort_analysis
	GROUP BY 
		customerkey,
		cleaned_name
),
customer_segments AS (
	SELECT 
		PERCENTILE_CONT(0.25) WITHIN GROUP (
		ORDER BY
			total_ltv
		) AS ltv_25th_percentil,
		PERCENTILE_CONT(0.75) WITHIN GROUP (
		ORDER BY
			total_ltv
		) AS ltv_75th_percentil
	FROM
		customer_ltv
), segment_values AS (
	SELECT
		c.*,
		CASE
			WHEN c.total_ltv < cs.ltv_25th_percentil THEN '1 - low-Value'
			WHEN c.total_ltv <= cs.ltv_75th_percentil THEN '2 - Mid-Value'
			ELSE '3 - High-Value'
		END AS customer_segment
	FROM
		customer_ltv c,
		customer_segments cs
	
)
SELECT 
	customer_segment,
	sum(total_ltv) AS total_ltv,
	count(customerkey) AS  customer_count,
	sum(total_ltv) / count(customerkey) AS avg_ltv
FROM segment_values 
GROUP BY 
	customer_segment
ORDER BY customer_segment DESC 
	
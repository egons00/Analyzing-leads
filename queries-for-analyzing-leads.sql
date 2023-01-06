--// 1st query

SELECT
        date::date      AS date,
        source          AS source,
        country         AS country_name,
        count(lead_id)  AS lead_count
FROM leads
GROUP BY 1,2,3
ORDER BY 1,2,3;
 

--// 2nd query

SELECT
    country                   					AS country,
--cast(avg(redirect_count)  AS DEC (10, 2))     AS avarage_redirects_2,----(different way of showcasing)
    round(avg(redirect_count), 2)				AS avg_redirects_per_lead
FROM(
    SELECT
    	lead_id,
        country,
        COUNT(redirect_id) 						AS redirect_count
    FROM Redirects
    GROUP BY 1, 2
    ) b
GROUP BY 1
ORDER BY 1;


--// 3rd query

SELECT
       partner_event_date::date         AS date,
       country                          AS country,
       count(postback_id)               AS event_count
FROM partner_events
GROUP BY 1,2
ORDER BY 1,2;


--// 4th query

WITH redirect_revenue_avg AS (
	SELECT	redirect_source,
			sum(redirect_count)								AS redirects_per_source,
			sum(rev_max)									AS revenue_per_source,
			round(sum(rev_max) / sum(redirect_count), 2) 	AS avg_revenue_per_redirect_source
	FROM (
			SELECT
				redirect_source,
				lead_id,
				count(lead_id)						    	AS redirect_count,
				max(revenue_total)					 		AS rev_max
			FROM(

					SELECT
						source								AS redirect_source,
						rd.lead_id							AS lead_id,
						redirect_date,
						redirect_id,
						revenue_total
					FROM Redirects rd
					LEFT JOIN (
							SELECT	lead_id,
									sum(revenue)			AS revenue_total
							FROM partner_events
							GROUP BY 1
					) ptnr
					ON ptnr.lead_id = rd.lead_id
			) pv_jn
			GROUP BY 1, 2
	) agg_rvn
	GROUP BY 1
),

lead_revenue_avg AS (
SELECT
	lead_source,
	count(lead_id)									AS lead_count,
	sum(revenue_total)								AS rev_sum,
	round(sum(revenue_total)/count(lead_id), 2)		AS avg_revenue_per_lead_source
FROM(
		SELECT
			source									AS lead_source,
			ld.lead_id								AS lead_id,
			revenue_total
		FROM Leads ld
		LEFT JOIN (
					SELECT	lead_id,
							sum(revenue)			AS revenue_total
					FROM partner_events
					GROUP BY 1
		) ptnr
		ON ptnr.lead_id = ld.lead_id
) pv_jn
GROUP BY 1
)

SELECT	lead_source,
		avg_revenue_per_lead_source,
		redirect_source,
		avg_revenue_per_redirect_source
FROM lead_revenue_avg lra
FULL OUTER JOIN redirect_revenue_avg rra
ON lead_source = redirect_source;



--// 5th query

WITH redirect_revenue AS (
SELECT
	partner_id,
	SUM(revenue)								AS rev_sum,
	SUM(redir_count)							AS redir_count
FROM(

		SELECT
			partner_id,
			revenue,
			pe.lead_id							AS lead_id,
			rd_id								AS redir_count
		FROM partner_events pe
		LEFT JOIN (
				SELECT	lead_id,
						COUNT(redirect_id)		AS rd_id
				FROM Redirects
				GROUP BY 1
		) rdr
		ON pe.lead_id = rdr.lead_id
) pv_jn
GROUP BY 1
)

SELECT	partner_id,
		rev_sum,
		redir_count,
		round(rev_sum / redir_count, 2)			AS avg_rev
FROM redirect_revenue;

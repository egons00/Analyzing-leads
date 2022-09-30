--// FOR COHORTS REDIRECTS

SELECT DISTINCT
	lds.lead_id					AS lead,
	date::date					AS reg_date,
	redirect_date::date			AS redirect_date,
	REDIRECT_DATE - DATE 		AS DIFF
FROM Leads lds
LEFT JOIN Redirects rdr
ON lds.lead_id = rdr.lead_id
ORDER BY 1
;




--// FOR COHORTS REVENUE

SELECT DISTINCT
	lds.lead_id					AS lead,
	date::date					AS reg_date,
	prt_date					AS revenue_date,
	revenue_day			 		AS revenue,
	prt_Date - date     		AS diff
FROM Leads lds
LEFT JOIN (
		SELECT
			lead_id						AS lead_id,
			partner_event_date::date 	AS prt_date,
			SUM(revenue)				AS revenue_day
		FROM "partner_events"
		GROUP BY 1, 2
) prtnr
ON lds.lead_id = prtnr.lead_id
ORDER BY 1
;

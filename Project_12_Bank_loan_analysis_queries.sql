CREATE TABLE bank_loan (
	id INT PRIMARY KEY,
	address_state VARCHAR(50),
	application_type VARCHAR(50),
	emp_length VARCHAR(50),
	emp_title VARCHAR(200),
	grade VARCHAR(50),
	home_ownership VARCHAR(50),
	issue_date DATE,
	last_credit_pull_date DATE,	
	last_payment_date DATE,
	loan_status	VARCHAR(50),
	next_payment_date DATE,
	member_id INT,
	purpose	VARCHAR(200),
	sub_grade VARCHAR(50),
	term VARCHAR(50),
	verification_status	VARCHAR(50),
	annual_income FLOAT,
	dti	FLOAT,
	installment FLOAT,	
	int_rate FLOAT,
	loan_amount	INT,
	total_acc INT,
	total_payment INT
)

SELECT * FROM bank_loan;

SELECT COUNT(*) AS total_loan_applications FROM bank_loan;

SELECT COUNT(*) AS MTD_loan_application FROM bank_loan
WHERE EXTRACT(MONTH FROM issue_date) = 12 
	  AND
	  EXTRACT(YEAR FROM issue_date) = 2021;

SELECT COUNT(*) AS PMTD_loan_application FROM bank_loan
WHERE EXTRACT(MONTH FROM issue_date) = 11 
	  AND
	  EXTRACT(YEAR FROM issue_date) = 2021;

WITH month_on_month AS
	(SELECT 
		EXTRACT(YEAR FROM issue_date) AS year,
		EXTRACT(MONTH FROM issue_date) AS month,
		COUNT(*) AS loan_applications
	 FROM bank_loan
	 WHERE EXTRACT(YEAR FROM issue_date) = 2021
	 	AND
		   EXTRACT(MONTH FROM issue_date) IN (11,12)
	 GROUP BY 1 , 2
	)
SELECT
	MAX(CASE WHEN month = 12 THEN loan_applications END) AS MTD_loan_application,
	MAX(CASE WHEN month = 11 THEN loan_applications END) AS PMTD_loan_application,
	ROUND(((
		 MAX(CASE WHEN month = 12 THEN loan_applications END)::NUMERIC - MAX(CASE WHEN month = 11 THEN loan_applications END)::NUMERIC)
		 /
		 MAX(CASE WHEN month = 11 THEN loan_applications END)::NUMERIC)*100 , 2) AS MoM_change_percent
FROM month_on_month;

SELECT * FROM bank_loan;

SELECT SUM(loan_amount) AS total_funded_amount
FROM bank_loan;

SELECT SUM(loan_amount) AS PMTD_total_funded_amount
FROM bank_loan
WHERE EXTRACT(MONTH FROM issue_date) = 11 AND EXTRACT(YEAR FROM issue_date) = 2021; 

WITH MoM_funded_amt AS
(
	SELECT 
		EXTRACT(MONTH FROM issue_date) AS month,
		EXTRACT(YEAR FROM issue_date) AS year,
		SUM(loan_amount) AS total_funded_amount
	FROM bank_loan
	WHERE EXTRACT(YEAR FROM issue_date) = 2021
		AND
		  EXTRACT(MONTH FROM issue_date) IN (11,12)
	GROUP BY 1,2
)
SELECT 
	MAX(CASE WHEN month = 12 THEN total_funded_amount END) AS MTD_total_funded_amount,
	MAX(CASE WHEN month = 11 THEN total_funded_amount END) AS PMTD_total_funded_amount,
	ROUND(((
		MAX(CASE WHEN month = 12 THEN total_funded_amount END)::NUMERIC - MAX(CASE WHEN month = 11 THEN total_funded_amount END)::NUMERIC)
		/
		MAX(CASE WHEN month = 11 THEN total_funded_amount END)::NUMERIC)*100,2) AS MoM_funded_amt_rate
FROM MoM_funded_amt;

SELECT * FROM bank_loan;

SELECT SUM(total_payment) AS total_amt_received
FROM bank_loan;

SELECT SUM(total_payment) AS MTD_total_amt_received
FROM bank_loan
WHERE EXTRACT(MONTH FROM issue_date) = 12 AND EXTRACT(YEAR FROM issue_date) = 2021;

SELECT SUM(total_payment) AS PMTD_total_amt_received
FROM bank_loan
WHERE EXTRACT(MONTH FROM issue_date) = 11 AND EXTRACT(YEAR FROM issue_date) = 2021;

WITH mom_rec_amth AS
(
	SELECT
		EXTRACT(YEAR FROM issue_date) AS year,
		EXTRACT(MONTH FROM issue_date) AS month,
		SUM(total_payment) AS total_amt_rec
	FROM bank_loan
	WHERE EXTRACT(YEAR FROM issue_date) = 2021 AND EXTRACT(MONTH FROM issue_date) IN (11,12)
	GROUP BY 1,2
)
SELECT 
	MAX(CASE WHEN month = 12 THEN total_amt_rec END) AS MTD_amt_rec,
	MAX(CASE WHEN month = 11 THEN total_amt_rec END) AS PMTD_amt_rec,
	ROUND(((
	MAX(CASE WHEN month = 12 THEN total_amt_rec END)::NUMERIC - MAX(CASE WHEN month = 11 THEN total_amt_rec END)::NUMERIC
	)/
	MAX(CASE WHEN month = 11 THEN total_amt_rec END)::NUMERIC
	)*100 ,2) AS MoM_rec_amt
FROM mom_rec_amth;

SELECT * FROM bank_loan;

SELECT 
	ROUND((AVG(int_rate::NUMERIC)*100),2) AS Avg_int_rate
FROM bank_loan
WHERE EXTRACT(MONTH FROM issue_date) = 12 AND EXTRACT(YEAR FROM issue_date) = 2021;

SELECT * FROM bank_loan;

SELECT ROUND((AVG(dti)::NUMERIC)*100, 2) AS average_dti
FROM bank_loan;

SELECT * FROM bank_loan;

SELECT 
	ROUND(((COUNT(CASE WHEN loan_status ILIKE 'fully paid' OR loan_status ILIKE 'Current' THEN id END))::NUMERIC
	/
	COUNT(*)::NUMERIC)*100, 2) AS good_loan_percentage
FROM bank_loan;

SELECT * FROM bank_loan;
SELECT 
	COUNT(id) AS Good_loan_Applications
FROM bank_loan
WHERE loan_status ILIKE 'Fully Paid' OR loan_status ILIKE 'Current';

SELECT 
	COUNT(id) AS bad_loan_Applications
FROM bank_loan
WHERE loan_status ILIKE 'Charged off';

SELECT * FROM bank_loan;

SELECT 
	SUM(loan_amount) AS Good_loan_funded_amt
FROM bank_loan
WHERE loan_status NOT ILIKE 'Charged Off';

SELECT 
	SUM(total_payment) AS total_good_loan_amt_rec
FROM bank_loan
WHERE loan_status NOT ILIKE 'Charged off';


SELECT
	loan_status,
	COUNT(id) AS Total_applications,
	SUM(total_payment) AS total_amt_received,
	SUM(loan_amount) AS total_funded_amount,
	ROUND(((AVG(int_rate)::NUMERIC)*100),2) AS Average_interest_rate,
	ROUND(((AVG(dti)::NUMERIC)*100),2) AS Average_dti
FROM bank_loan
GROUP BY 1;

SELECT
	loan_status,
	COUNT(id) AS MTD_Total_applications,
	SUM(total_payment) AS MTD_total_amt_received,
	SUM(loan_amount) AS MTD_total_funded_amount,
	ROUND(((AVG(int_rate)::NUMERIC)*100),2) AS MTD_Average_interest_rate,
	ROUND(((AVG(dti)::NUMERIC)*100),2) AS MTD_Average_dti
FROM bank_loan
WHERE EXTRACT(MONTH FROM issue_date) = 12 AND EXTRACT(YEAR FROM issue_date) = 2021
GROUP BY 1;

SELECT 
	issue_date,
	COUNT(id) AS Total_loan_applications,
	SUM(loan_amount) AS total_funded_amount,
	SUM(total_payment) AS total_amount_receieved
FROM bank_loan
GROUP BY 1;

SELECT 
	EXTRACT(WEEK FROM issue_date) AS week,
	COUNT(id) AS Total_loan_applications,
	SUM(loan_amount) AS total_funded_amount,
	SUM(total_payment) AS total_amount_receieved
FROM bank_loan
GROUP BY 1
ORDER BY 1;

SELECT 
	TO_CHAR(issue_date, 'Month') AS Month,
	COUNT(id) AS Total_loan_applications,
	SUM(loan_amount) AS total_funded_amount,
	SUM(total_payment) AS total_amount_receieved
FROM bank_loan
GROUP BY 1, EXTRACT(MONTH FROM issue_date)
ORDER BY EXTRACT(MONTH FROM issue_date) ASC;

SELECT 
	address_state,
	COUNT(id) AS Total_loan_applications,
	SUM(loan_amount) AS total_funded_amount,
	SUM(total_payment) AS total_amount_receieved
FROM bank_loan
GROUP BY 1;

SELECT 
	term,
	COUNT(id) AS Total_loan_applications,
	SUM(loan_amount) AS total_funded_amount,
	SUM(total_payment) AS total_amount_receieved
FROM bank_loan
GROUP BY 1;

SELECT 
	emp_length,
	COUNT(id) AS Total_loan_applications,
	SUM(loan_amount) AS total_funded_amount,
	SUM(total_payment) AS total_amount_receieved
FROM bank_loan
GROUP BY 1;

SELECT 
	purpose,
	COUNT(id) AS Total_loan_applications,
	SUM(loan_amount) AS total_funded_amount,
	SUM(total_payment) AS total_amount_receieved
FROM bank_loan
GROUP BY 1;

SELECT 
	home_ownership,
	COUNT(id) AS Total_loan_applications,
	SUM(loan_amount) AS total_funded_amount,
	SUM(total_payment) AS total_amount_receieved
FROM bank_loan
GROUP BY 1;

SELECT * FROM bank_loan;


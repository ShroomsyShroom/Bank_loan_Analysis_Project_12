<h1>Bank Loan Analysis Project</h1>

<p>
This project focuses on analyzing bank loan data to extract meaningful insights for business and credit risk decision-making.
The analysis is performed using PostgreSQL for data querying, Excel for data handling, and Tableau for dashboard visualization.
</p>

<hr>

<h2>Problem Statement</h2>

<p>
The objective of this project is to analyze loan application data and build interactive dashboards that provide insights into:
</p>

<ul>
  <li>Loan application trends</li>
  <li>Funded and received loan amounts</li>
  <li>Loan performance (Good vs Bad loans)</li>
  <li>Customer demographics and loan attributes</li>
</ul>

<hr>

<h2>Key Performance Indicators (KPIs)</h2>

<h3>Dashboard 1: Summary</h3>
<ul>
  <li>Total Loan Applications</li>
  <li>Total Funded Amount</li>
  <li>Total Amount Received</li>
  <li>Average Interest Rate</li>
  <li>Average Debt-to-Income Ratio (DTI)</li>
  <li>Good Loan vs Bad Loan KPIs</li>
</ul>

<h3>Dashboard 2: Overview</h3>
<ul>
  <li>Monthly Trends</li>
  <li>Regional Analysis by State</li>
  <li>Loan Term Analysis</li>
  <li>Employee Length Analysis</li>
  <li>Loan Purpose Breakdown</li>
  <li>Home Ownership Analysis</li>
</ul>

<h3>Dashboard 3: Details</h3>
<ul>
  <li>Complete loan-level grid for detailed inspection</li>
</ul>

<hr>

<h2>Tools & Technologies Used</h2>

<ul>
  <li>MS Excel 2021 – Data Cleaning & CSV Handling</li>
  <li>PostgreSQL (PgAdmin) – Data Storage & Querying</li>
  <li>Tableau Desktop 2024.3 – Dashboard Visualization</li>
</ul>

<hr>

<h2>Database Setup</h2>

<h3>Step 1: Create Database</h3>
<p>
Create a new PostgreSQL database named <strong>Bank Loan DB</strong> (or any preferred name).
</p>

<h3>Step 2: Create Table</h3>
<p>
The following SQL query creates the main table used for analysis:
</p>

<pre>
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
    loan_status VARCHAR(50),
    next_payment_date DATE,
    member_id INT,
    purpose VARCHAR(200),
    sub_grade VARCHAR(50),
    term VARCHAR(50),
    verification_status VARCHAR(50),
    annual_income FLOAT,
    dti FLOAT,
    installment FLOAT,
    int_rate FLOAT,
    loan_amount INT,
    total_acc INT,
    total_payment INT
);
</pre>

<h3>Step 3: Import Data</h3>
<p>
Import data from an Excel or CSV file into the <strong>bank_loan</strong> table using PgAdmin's import feature.
</p>

<h3>Step 4: Validate Data</h3>

<pre>
SELECT * FROM bank_loan;
</pre>

<hr>

<h2>Dashboard 1: Summary Analysis</h2>

<h3>Total Loan Applications</h3>

<p>Total overall loan applications:</p>
<pre>
SELECT COUNT(*) AS total_loan_applications FROM bank_loan;
</pre>

<p>Month-to-Date (December 2021) loan applications:</p>
<pre>
SELECT COUNT(*) AS MTD_loan_application
FROM bank_loan
WHERE EXTRACT(MONTH FROM issue_date) = 12
AND EXTRACT(YEAR FROM issue_date) = 2021;
</pre>

<p>Previous Month-to-Date (November 2021):</p>
<pre>
SELECT COUNT(*) AS PMTD_loan_application
FROM bank_loan
WHERE EXTRACT(MONTH FROM issue_date) = 11
AND EXTRACT(YEAR FROM issue_date) = 2021;
</pre>

<p>Month-over-Month (MoM) Growth:</p>
<pre>
WITH month_on_month AS (
    SELECT
        EXTRACT(YEAR FROM issue_date) AS year,
        EXTRACT(MONTH FROM issue_date) AS month,
        COUNT(*) AS loan_applications
    FROM bank_loan
    WHERE EXTRACT(YEAR FROM issue_date) = 2021
    AND EXTRACT(MONTH FROM issue_date) IN (11,12)
    GROUP BY 1,2
)
SELECT
    MAX(CASE WHEN month = 12 THEN loan_applications END) AS MTD,
    MAX(CASE WHEN month = 11 THEN loan_applications END) AS PMTD,
    ROUND(
        ((MAX(CASE WHEN month = 12 THEN loan_applications END)::NUMERIC -
        MAX(CASE WHEN month = 11 THEN loan_applications END)::NUMERIC)
        /
        MAX(CASE WHEN month = 11 THEN loan_applications END)::NUMERIC) * 100, 2
    ) AS MoM_change_percent
FROM month_on_month;
</pre>

<hr>

<h3>Total Funded Amount</h3>

<p>Total funded amount:</p>
<pre>
SELECT SUM(loan_amount) AS total_funded_amount FROM bank_loan;
</pre>

<hr>

<h3>Total Amount Received</h3>

<p>Total received amount:</p>
<pre>
SELECT SUM(total_payment) AS total_amt_received FROM bank_loan;
</pre>

<hr>

<h3>Average Interest Rate</h3>

<pre>
SELECT ROUND(AVG(int_rate::NUMERIC) * 100, 2) AS Avg_int_rate
FROM bank_loan;
</pre>

<hr>

<h3>Average Debt-to-Income Ratio</h3>

<pre>
SELECT ROUND(AVG(dti)::NUMERIC * 100, 2) AS Avg_DTI
FROM bank_loan;
</pre>

<hr>

<h2>Good Loan vs Bad Loan Analysis</h2>

<h3>Loan Percentage Distribution</h3>

<pre>
SELECT
ROUND(
    COUNT(CASE WHEN loan_status ILIKE 'Fully Paid' OR loan_status ILIKE 'Current' THEN id END)::NUMERIC
    / COUNT(*)::NUMERIC * 100, 2
) AS good_loan_percentage
FROM bank_loan;
</pre>

<hr>

<h2>Dashboard 2: Overview Analysis</h2>

<h3>Monthly Loan Trends</h3>

<pre>
SELECT
TO_CHAR(issue_date, 'Month') AS month,
COUNT(id),
SUM(loan_amount),
SUM(total_payment)
FROM bank_loan
GROUP BY month, EXTRACT(MONTH FROM issue_date)
ORDER BY EXTRACT(MONTH FROM issue_date);
</pre>

<h3>Regional Analysis by State</h3>

<pre>
SELECT
address_state,
COUNT(id),
SUM(loan_amount),
SUM(total_payment)
FROM bank_loan
GROUP BY address_state;
</pre>

<h3>Loan Purpose Breakdown</h3>

<pre>
SELECT
purpose,
COUNT(id),
SUM(loan_amount),
SUM(total_payment)
FROM bank_loan
GROUP BY purpose;
</pre>

<hr>

<h2>Dashboard 3: Detailed View</h2>

<p>
This dashboard presents a holistic grid view containing all loan attributes for in-depth analysis and validation.
</p>

<hr>

<h2>Final Outcome</h2>

<p>
This project delivers a complete end-to-end loan analytics solution using SQL and Tableau.
It provides actionable insights into loan performance, customer behavior, and financial risk.
</p>

<p>
Feel free to fork this repository and extend the analysis further.
</p>


--Check total records
Select * from External_Cibil
Select * from Internal_Bank

--Check Data Types of Entire Table
Select COLUMN_NAME, DATA_TYPE from INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME= 'Internal_Bank'

Select COLUMN_NAME, DATA_TYPE from INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME= 'External_Cibil'

--Quick validation Of Data
Select COUNT(*) from Internal_Bank
Where PROSPECTID <> FLOOR(PROSPECTID)

Select COUNT(*) from External_Cibil
Where PROSPECTID <> FLOOR(PROSPECTID)

Select COUNT(*) from External_Cibil
Where AGE <> FLOOR(AGE)

Select COUNT(*) from External_Cibil
Where Credit_Score <> FLOOR(Credit_Score)

--Fix Data Types
Alter Table External_Cibil ALTER COLUMN PROSPECTID INT;
Alter Table Internal_bank ALTER COLUMN PROSPECTID INT;
Alter Table External_Cibil ALTER COLUMN Credit_Score INT;
Alter Table External_Cibil ALTER COLUMN AGE INT;
Alter Table External_Cibil ALTER COLUMN CC_Flag INT;
Alter Table External_Cibil ALTER COLUMN PL_Flag INT;
Alter Table External_Cibil ALTER COLUMN HL_Flag INT;
Alter Table External_Cibil ALTER COLUMN GL_Flag INT;

--Check Null values
Select * from Internal_Bank
WHERE PROSPECTID IS NULL;

Select * from External_Cibil
WHERE PROSPECTID IS NULL;

Select * from External_Cibil
WHERE Credit_Score IS NULL;

--Check Duplicates
Select ProspectID, Count(*) cnt from Internal_Bank
Group By Prospectid
Having count(*)>1

Select ProspectID, Count(*) cnt from External_Cibil
Group By Prospectid
Having count(*)>1

--Check Outliers
Select * From External_Cibil
WHERE AGE < 18 OR AGE > 100

Select * From External_Cibil
WHERE Credit_Score < 300 OR Credit_Score > 900


--Find Missing Matches
Select * from External_Cibil ec
Left join Internal_Bank ib
ON ib.PROSPECTID=ec.PROSPECTID
WHERE ib.PROSPECTID IS NULL;

--Basic Data Exploration
Select AVG(Credit_Score) avg_score, MAX(Credit_Score) max_score, MIN(Credit_Score) min_score 
from External_Cibil

--Data Consistency Checks
SELECT * FROM Internal_Bank
WHERE Total_TL <>(Tot_Active_TL+Tot_Closed_TL);

--Convert -99999 → NULL (Time & Ratio Columns)
Select * from External_Cibil

UPDATE External_Cibil
SET
time_since_recent_payment= NUllIF(time_since_recent_payment, -99999),
time_since_first_deliquency= NUllIF(time_since_first_deliquency, -99999),
time_since_recent_deliquency= NUllIF(time_since_recent_deliquency, -99999),
max_delinquency_level= NUllIF(max_delinquency_level, -99999),
max_deliq_6mts = NULLIF(max_deliq_6mts, -99999),
max_deliq_12mts= NULLIF(max_deliq_12mts, -99999),
CC_utilization = NULLIF(CC_utilization, -99999),
PL_utilization = NULLIF(PL_utilization, -99999),
pct_currentBal_all_TL = NULLIF(pct_currentBal_all_TL, -99999),
max_unsec_exposure_inPct = NULLIF(max_unsec_exposure_inPct, -99999)
time_since_recent_enq= NUllIF(time_since_recent_enq, -99999)

----Convert -99999 → 0 (Count based Columns)

UPDATE External_Cibil
SET
tot_enq= CASE WHEN tot_enq= -99999 THEN 0 ELSE tot_enq END,
CC_enq=  CASE WHEN CC_enq= -99999 THEN 0 ELSE CC_enq END,
CC_enq_L6m= CASE WHEN CC_enq_L6m= -99999 THEN 0 ELSE CC_enq_L6m END,
CC_enq_L12m= CASE WHEN CC_enq_L12m= -99999 THEN 0 ELSE CC_enq_L12m END,
PL_enq= CASE WHEN PL_enq= -99999 THEN 0 ELSE PL_enq END,
PL_enq_L6m= CASE WHEN PL_enq_L6m= -99999 THEN 0 ELSE PL_enq_L6m END,
PL_enq_L12m= CASE WHEN PL_enq_L12m= -99999 THEN 0 ELSE PL_enq_L12m END,
enq_L12m= CASE WHEN enq_L12m= -99999 THEN 0 ELSE enq_L12m END,
enq_L6m= CASE WHEN enq_L6m= -99999 THEN 0 ELSE enq_L6m END,
enq_L3m= CASE WHEN enq_L3m= -99999 THEN 0 ELSE enq_L3m END;

--Sorting Data
SELECT * from External_Cibil
order by Credit_Score DESC;

--Filtering Data
SELECT COUNT(*) from External_Cibil
WHERE Credit_Score <600




-- AGE
SELECT AGE, COUNT(*) total from External_Cibil
Group by AGE
Order by AGE DESC;

--Join Tables

Select *
from Internal_Bank ib
join External_Cibil ec
ON  ib.PROSPECTID= ec.PROSPECTID

--Feature creation
SELECT * from External_Cibil


SELECT PROSPECTID, Credit_Score,
CASE
	WHEN Credit_Score <500 THEN 'High Risk'
	WHEN Credit_Score BETWEEN 500 AND 700 THEN 'Medium Risk'
	ELSE 'Low Risk'
	END AS Risk_category
from External_Cibil

ALTER TABLE External_Cibil
ADD Risk_category VARCHAR(20)

UPDATE External_Cibil
SET Risk_category= 
CASE
	WHEN Credit_Score <600 THEN 'High Risk'
	WHEN Credit_Score BETWEEN 600 AND 700 THEN 'Medium Risk'
	ELSE 'Low Risk'
END;

-- Create column called Default Flag
ALTER TABLE External_Cibil
ADD Default_flag INT;

UPDATE External_Cibil
SET Default_flag =
CASE 
    WHEN num_times_60p_dpd > 1 
      OR num_sub > 0 
      OR num_dbt > 0 
      OR num_lss > 0 
    THEN 1 
    ELSE 0 
END;

SELECT Default_flag, COUNT(*) 
from External_Cibil
Group by Default_flag

SELECT * INTO Loan_risk_data
FROM Internal_Bank ib
JOIN External_Cibil ec
ON ib.PROSPECTID = ec.PROSPECTID

---------------KPI Queries------------
--Average Credit Score

SELECT AVG(Credit_Score) avg_credit_score
FROM External_Cibil

--Total Customers
SELECT COUNT(*) Total_customer
FROM External_Cibil

--High Risk Customers
SELECT COUNT(*) Total FROM External_Cibil
WHERE Risk_category = 'High Risk'

--% of High Risk Customers
SELECT ROUND((COUNT(CASE WHEN Credit_Score <600 THEN 1 END) * 100.0)/ count(*),2) High_risk_percentage
From External_Cibil

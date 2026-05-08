SELECT TOP 1 * FROM EXTERNAL_CIBIL_DATA1
SELECT TOP 1 * FROM INTERNAL_BANK_DATA2

-- Column and Datatype Check
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CibilData'

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'BankData'


/* Several columns are stored as NVARCHAR instead of appropriate numeric types, 
which may lead to incorrect comparisons. This will be addressed in the data processing phase. */
-- Primary Key Check
SELECT PROSPECTID,COUNT(*) FROM EXTERNAL_CIBIL_DATA1
GROUP BY PROSPECTID
HAVING COUNT(*)>1
SELECT PROSPECTID,COUNT(*) FROM INTERNAL_BANK_DATA2
GROUP BY PROSPECTID
HAVING COUNT(*)>1

/* No duplicate PROSPECTID values were found, indicating that the column can be treated as a unique identifier. */
-- Duplicates Check
WITH cte AS(
   SELECT *,ROW_NUMBER() OVER (
                PARTITION BY PROSPECTID ORDER BY PROSPECTID) AS rn
   FROM INTERNAL_BANK_DATA2
    )
SELECT * FROM cte
WHERE rn>1

WITH cte AS(
   SELECT *,ROW_NUMBER() OVER (
                PARTITION BY PROSPECTID ORDER BY PROSPECTID) AS rn
   FROM INTERNAL_BANK_DATA2
    )
SELECT * FROM cte
WHERE rn>1

/* No duplicate records were identified based on PROSPECTID using ROW_NUMBER(). */
-- checking null values
SELECT
SUM(CASE WHEN PROSPECTID IS NULL THEN 1 ELSE 0 END) AS missing_PROSPECTID,
SUM(CASE WHEN MARITALSTATUS IS NULL THEN 1 ELSE 0 END) AS missing_MARITALSTATUS,
SUM(CASE WHEN EDUCATION IS NULL THEN 1 ELSE 0 END) AS missing_EDUCATION,
SUM(CASE WHEN AGE IS NULL THEN 1 ELSE 0 END) AS missing_AGE,
SUM(CASE WHEN GENDER IS NULL THEN 1 ELSE 0 END) AS missing_GENDER,
SUM(CASE WHEN NETMONTHLYINCOME IS NULL THEN 1 ELSE 0 END) AS missing_NETMONTHLYINCOME
FROM EXTERNAL_CIBIL_DATA1
SELECT 
SUM(CASE WHEN PROSPECTID IS NULL THEN 1 ELSE 0 END) AS missing_PROSPECTID,
SUM(CASE WHEN Total_TL IS NULL THEN 1 ELSE 0 END) AS missing_Total_TL,
SUM(CASE WHEN Tot_Active_TL IS NULL THEN 1 ELSE 0 END) AS missing_Active_TL,
SUM(CASE WHEN Tot_Closed_TL IS NULL THEN 1 ELSE 0 END) AS missing_Closed_TL,
SUM(CASE WHEN Tot_Missed_Pmnt IS NULL THEN 1 ELSE 0 END) AS missing_Missed_Payments,
SUM(CASE WHEN Age_Oldest_TL IS NULL THEN 1 ELSE 0 END) AS missing_Oldest_TL,
SUM(CASE WHEN Age_Newest_TL IS NULL THEN 1 ELSE 0 END) AS missing_Newest_TL,
SUM(CASE WHEN pct_active_tl IS NULL THEN 1 ELSE 0 END) AS missing_pct_active,
SUM(CASE WHEN pct_closed_tl IS NULL THEN 1 ELSE 0 END) AS missing_pct_closed
FROM INTERNAL_BANK_DATA2

/* No null values were observed in the selected key columns. 
A full column-level null audit will be performed during detailed data processing. */
-- Join Check
SELECT COUNT(*) 
FROM EXTERNAL_CIBIL_DATA1 c
LEFT JOIN INTERNAL_BANK_DATA2 b
ON c.PROSPECTID = b.PROSPECTID
WHERE b.PROSPECTID IS NULL;
SELECT COUNT(*) 
FROM INTERNAL_BANK_DATA2 b
LEFT JOIN EXTERNAL_CIBIL_DATA1 c
ON b.PROSPECTID = c.PROSPECTID
WHERE c.PROSPECTID IS NULL;

/* No unmatched records were found between CibilData and BankData, indicating consistency in PROSPECTID across both datasets. */
-- Data Consistency Checks
-- CibilData
--Deleinquency Logic
SELECT *
FROM EXTERNAL_CIBIL_DATA1
WHERE TRY_CAST(num_times_delinquent AS INT) < TRY_CAST(num_deliq_12mts AS INT);
-- 6M / 12M logic
SELECT *
FROM EXTERNAL_CIBIL_DATA1
WHERE TRY_CAST(num_deliq_6mts AS INT) > TRY_CAST(num_deliq_12mts AS INT);
-- Enquiry Logic
SELECT *
FROM EXTERNAL_CIBIL_DATA1
WHERE 
TRY_CAST(enq_L3m AS INT) > TRY_CAST(enq_L6m AS INT)
OR 
TRY_CAST(enq_L6m AS INT) > TRY_CAST(enq_L12m AS INT);
--Time consistency
SELECT *
FROM EXTERNAL_CIBIL_DATA1
WHERE 
TRY_CAST(time_since_recent_deliquency AS INT) > TRY_CAST(time_since_first_deliquency AS INT);
--Flag vs Value check
SELECT *
FROM EXTERNAL_CIBIL_DATA1
WHERE TRY_CAST(CC_utilization AS FLOAT) > 0 AND TRY_CAST(CC_Flag AS INT) = 0;

--Distinct Values Check
SELECT DISTINCT GENDER FROM EXTERNAL_CIBIL_DATA1;
SELECT DISTINCT MARITALSTATUS FROM EXTERNAL_CIBIL_DATA1;
SELECT DISTINCT EDUCATION FROM EXTERNAL_CIBIL_DATA1;
SELECT DISTINCT Approved_Flag FROM EXTERNAL_CIBIL_DATA1;
SELECT DISTINCT last_prod_enq2 FROM EXTERNAL_CIBIL_DATA1;
SELECT DISTINCT first_prod_enq2 FROM EXTERNAL_CIBIL_DATA1;
SELECT *
FROM EXTERNAL_CIBIL_DATA1
WHERE TRY_CAST(Credit_Score AS INT) IS NULL;

---Invalid Numeric data check
-- Credit Score
SELECT COUNT(*)
FROM EXTERNAL_CIBIL_DATA1
WHERE TRY_CAST(Credit_Score AS INT) IS NULL 
AND Credit_Score IS NOT NULL;
-- Income
SELECT COUNT(*)
FROM EXTERNAL_CIBIL_DATA1
WHERE TRY_CAST(NETMONTHLYINCOME AS FLOAT) IS NULL 
AND NETMONTHLYINCOME IS NOT NULL;
-- BankData
--Total TL logic
SELECT *
FROM INTERNAL_BANK_DATA2
WHERE TRY_CAST(Total_TL AS INT) <> (TRY_CAST(Tot_Active_TL AS INT) + TRY_CAST(Tot_Closed_TL AS INT));
-- L6M/ L12M 
SELECT *
FROM INTERNAL_BANK_DATA2
WHERE TRY_CAST(Total_TL_opened_L6M AS INT) > TRY_CAST(Total_TL_opened_L12M AS INT);
-- Loan Sum Check
SELECT *
FROM INTERNAL_BANK_DATA2
WHERE 
(TRY_CAST(Auto_TL AS INT) +TRY_CAST(CC_TL AS INT) +TRY_CAST(Consumer_TL AS INT) +TRY_CAST(Gold_TL AS INT) +TRY_CAST(Home_TL AS INT) +TRY_CAST(PL_TL AS INT))
>TRY_CAST(Total_TL AS INT);
-- Secured/Unsecured 
SELECT *
FROM INTERNAL_BANK_DATA2
WHERE (TRY_CAST(Secured_TL AS INT) +TRY_CAST(Unsecured_TL AS INT))>TRY_CAST(Total_TL AS INT);
--TL Age Consistency
SELECT *
FROM INTERNAL_BANK_DATA2
WHERE TRY_CAST(Age_Oldest_TL AS INT) < TRY_CAST(Age_Newest_TL AS INT);

/* Consistency checks were performed to validate logical relationships between related 
   variables such as delinquency counts, enquiry timelines, and tradeline totals. */
-- Outlier Check 
-- CibilData
-- For Age
SELECT *
FROM EXTERNAL_CIBIL_DATA1
WHERE TRY_CAST(AGE AS INT) < 18 OR TRY_CAST(AGE AS INT) > 100;
-- For Income
SELECT *
FROM EXTERNAL_CIBIL_DATA1
WHERE TRY_CAST(NETMONTHLYINCOME AS FLOAT) < 0 OR TRY_CAST(NETMONTHLYINCOME AS FLOAT) > 10000000;
-- For Credit Score
SELECT *
FROM EXTERNAL_CIBIL_DATA1
WHERE TRY_CAST(Credit_Score AS INT) < 300 OR TRY_CAST(Credit_Score AS INT) > 900;
-- For Percentages
SELECT * FROM EXTERNAL_CIBIL_DATA1
WHERE TRY_CAST(pct_of_active_TLs_ever AS FLOAT) < 0 OR TRY_CAST(pct_of_active_TLs_ever AS FLOAT) > 1
   OR TRY_CAST(pct_opened_TLs_L6m_of_L12m AS FLOAT) < 0 OR TRY_CAST(pct_opened_TLs_L6m_of_L12m AS FLOAT) > 1
   OR TRY_CAST(pct_currentBal_all_TL AS FLOAT) < 0 OR TRY_CAST(pct_currentBal_all_TL AS FLOAT) > 1

SELECT MAX(TRY_CAST(pct_currentBal_all_TL AS FLOAT)) from EXTERNAL_CIBIL_DATA1

-- Delinquency Counts
SELECT * FROM EXTERNAL_CIBIL_DATA1
WHERE 
TRY_CAST(num_times_delinquent AS INT) < 0
OR TRY_CAST(num_times_30p_dpd AS INT) < 0
OR TRY_CAST(num_times_60p_dpd AS INT) < 0
OR TRY_CAST(num_deliq_6mts AS INT) < 0
OR TRY_CAST(num_deliq_12mts AS INT) < 0;

-- Enquiries
SELECT * FROM EXTERNAL_CIBIL_DATA1
WHERE TRY_CAST(tot_enq AS INT) < 0 OR TRY_CAST(CC_enq AS INT) < 0 OR TRY_CAST(PL_enq AS INT) < 0;
-- Time variables
SELECT * FROM EXTERNAL_CIBIL_DATA1
WHERE 
TRY_CAST(time_since_recent_payment AS INT) < 0 
OR TRY_CAST(time_since_recent_deliquency AS INT) < 0 
OR TRY_CAST(time_since_recent_enq AS INT) < 0;	
-- Flag Variables
SELECT * FROM EXTERNAL_CIBIL_DATA1
WHERE 
TRY_CAST(CC_Flag AS INT) NOT IN (0,1)
OR TRY_CAST(PL_Flag AS INT) NOT IN (0,1)
OR TRY_CAST(HL_Flag AS INT) NOT IN (0,1)
OR TRY_CAST(GL_Flag AS INT) NOT IN (0,1);

-- BankData

-- Tradeline counts
SELECT * FROM INTERNAL_BANK_DATA2
WHERE 
TRY_CAST(Total_TL AS INT) < 0
OR TRY_CAST(Tot_Active_TL AS INT) < 0
OR TRY_CAST(Tot_Closed_TL AS INT) < 0;

-- L6M/L12M counts

SELECT * FROM INTERNAL_BANK_DATA2
WHERE 
TRY_CAST(Total_TL_opened_L6M AS INT) < 0
OR TRY_CAST(Tot_TL_closed_L6M AS INT) < 0
OR TRY_CAST(Total_TL_opened_L12M AS INT) < 0
OR TRY_CAST(Tot_TL_closed_L12M AS INT) < 0;

-- Loan Type Counts

SELECT * FROM INTERNAL_BANK_DATA2
WHERE 
TRY_CAST(Auto_TL AS INT) < 0
OR TRY_CAST(CC_TL AS INT) < 0
OR TRY_CAST(Consumer_TL AS INT) < 0
OR TRY_CAST(Gold_TL AS INT) < 0
OR TRY_CAST(Home_TL AS INT) < 0
OR TRY_CAST(PL_TL AS INT) < 0;

-- Percentages 

SELECT * FROM INTERNAL_BANK_DATA2
WHERE TRY_CAST(pct_active_tl AS FLOAT) < 0 OR TRY_CAST(pct_active_tl AS FLOAT) > 1
   OR TRY_CAST(pct_closed_tl AS FLOAT) < 0 OR TRY_CAST(pct_closed_tl AS FLOAT) > 1
   OR TRY_CAST(pct_tl_open_L6M AS FLOAT) < 0 OR TRY_CAST(pct_tl_open_L6M AS FLOAT) > 1
   OR TRY_CAST(pct_tl_closed_L6M AS FLOAT) < 0 OR TRY_CAST(pct_tl_closed_L6M AS FLOAT) > 1

--Age of Trade Lines

SELECT * FROM INTERNAL_BANK_DATA2
WHERE 
TRY_CAST(Age_Oldest_TL AS INT) < 0
OR TRY_CAST(Age_Newest_TL AS INT) < 0
OR TRY_CAST(Age_Oldest_TL AS INT) < TRY_CAST(Age_Newest_TL AS INT);


-- Secured/Unsecured 

SELECT * FROM INTERNAL_BANK_DATA2
WHERE 
TRY_CAST(Secured_TL AS INT) < 0
OR TRY_CAST(Unsecured_TL AS INT) < 0
OR TRY_CAST(Other_TL AS INT) < 0;


-- Missed Payments

SELECT * FROM INTERNAL_BANK_DATA2
WHERE TRY_CAST(Tot_Missed_Pmnt AS INT) < 0;



/* Outlier analysis revealed a large number of extreme values. 
   Further investigation indicates that many of these values (e.g., -99999) are placeholder entries
   representing missing or unavailable data rather than true outliers. */


/*
Summary:
- Data is largely consistent across tables with respect to PROSPECTID
- Several columns contain incorrect data types (NVARCHAR instead of numeric)
- No major duplication or null issues found in key columns
- Significant presence of placeholder values (-99999) indicating missing data
- Data cleaning and type correction will be required before analysis
*/

-- Data Cleaning 

-- Cibil Data


SELECT *
INTO Cibil_Data_Clean
FROM EXTERNAL_CIBIL_DATA1;

/*   
   - A copy of raw CibilData is created to preserve original data
   - All transformations are performed on CibilData_Clean to ensure data safety
*/

SELECT TOP 5 * FROM Cibil_Data_Clean


SELECT 
COLUMN_NAME,
DATA_TYPE,
IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Cibil_Data_Clean';


/*   Column Type Standardization
   - Several numeric fields are stored as NVARCHAR
   - These columns are altered to allow proper conversion and NULL handling
*/

ALTER TABLE Cibil_Data_Clean ALTER COLUMN time_since_recent_deliquency NVARCHAR(50) NULL;
ALTER TABLE Cibil_Data_Clean ALTER COLUMN time_since_recent_enq NVARCHAR(50) NULL;
ALTER TABLE Cibil_Data_Clean ALTER COLUMN time_since_first_deliquency NVARCHAR(50) NULL;

ALTER TABLE Cibil_Data_Clean ALTER COLUMN num_times_delinquent NVARCHAR(50) NULL;
ALTER TABLE Cibil_Data_Clean ALTER COLUMN num_deliq_6mts NVARCHAR(50) NULL;
ALTER TABLE Cibil_Data_Clean ALTER COLUMN num_deliq_12mts NVARCHAR(50) NULL;
ALTER TABLE Cibil_Data_Clean ALTER COLUMN num_deliq_6_12mts NVARCHAR(50) NULL;

ALTER TABLE Cibil_Data_Clean ALTER COLUMN num_times_30p_dpd NVARCHAR(50) NULL;
ALTER TABLE Cibil_Data_Clean ALTER COLUMN num_times_60p_dpd NVARCHAR(50) NULL;

ALTER TABLE Cibil_Data_Clean ALTER COLUMN num_std NVARCHAR(50) NULL;
ALTER TABLE Cibil_Data_Clean ALTER COLUMN num_sub NVARCHAR(50) NULL;
ALTER TABLE Cibil_Data_Clean ALTER COLUMN num_dbt NVARCHAR(50) NULL;
ALTER TABLE Cibil_Data_Clean ALTER COLUMN num_lss NVARCHAR(50) NULL;

ALTER TABLE Cibil_Data_Clean ALTER COLUMN tot_enq NVARCHAR(50) NULL;
ALTER TABLE Cibil_Data_Clean ALTER COLUMN CC_enq NVARCHAR(50) NULL;
ALTER TABLE Cibil_Data_Clean ALTER COLUMN PL_enq NVARCHAR(50) NULL;
ALTER TABLE Cibil_Data_Clean ALTER COLUMN enq_L3m NVARCHAR(50) NULL;
ALTER TABLE Cibil_Data_Clean ALTER COLUMN enq_L6m NVARCHAR(50) NULL;
ALTER TABLE Cibil_Data_Clean ALTER COLUMN enq_L12m NVARCHAR(50) NULL;

ALTER TABLE Cibil_Data_Clean ALTER COLUMN NETMONTHLYINCOME NVARCHAR(50) NULL;

ALTER TABLE Cibil_Data_Clean ALTER COLUMN pct_of_active_TLs_ever NVARCHAR(50) NULL;
ALTER TABLE Cibil_Data_Clean ALTER COLUMN pct_opened_TLs_L6m_of_L12m NVARCHAR(50) NULL;
ALTER TABLE Cibil_Data_Clean ALTER COLUMN pct_currentBal_all_TL NVARCHAR(50) NULL;
ALTER TABLE Cibil_Data_Clean ALTER COLUMN CC_utilization NVARCHAR(50) NULL;
ALTER TABLE Cibil_Data_Clean ALTER COLUMN PL_utilization NVARCHAR(50) NULL;

ALTER TABLE Cibil_Data_Clean ALTER COLUMN pct_PL_enq_L6m_of_L12m NVARCHAR(50) NULL;
ALTER TABLE Cibil_Data_Clean ALTER COLUMN pct_CC_enq_L6m_of_L12m NVARCHAR(50) NULL;
ALTER TABLE Cibil_Data_Clean ALTER COLUMN pct_PL_enq_L6m_of_ever NVARCHAR(50) NULL;
ALTER TABLE Cibil_Data_Clean ALTER COLUMN pct_CC_enq_L6m_of_ever NVARCHAR(50) NULL;

ALTER TABLE Cibil_Data_Clean ALTER COLUMN max_unsec_exposure_inPct NVARCHAR(50) NULL;


/* 
   Handling Placeholder Values (-99999)
   - In banking datasets, -99999 represents missing/invalid data
   - These values are replaced with NULL using NULLIF for accurate analysis
   
   Feature-wise Type Conversion
   - All key variables (delinquency, enquiries, income, utilization, flags)
     are converted into INT or FLOAT using TRY_CAST
   - Prevents query failure due to invalid datatype conversion
*/

SELECT 
PROSPECTID,

-- Time Variables
TRY_CAST(NULLIF(time_since_recent_payment, '-99999') AS INT) AS time_since_recent_payment,
TRY_CAST(NULLIF(time_since_first_deliquency, '-99999') AS INT) AS time_since_first_deliquency,
TRY_CAST(NULLIF(time_since_recent_deliquency, '-99999') AS INT) AS time_since_recent_deliquency,
TRY_CAST(NULLIF(time_since_recent_enq, '-99999') AS INT) AS time_since_recent_enq,

-- Delinquency Counts
TRY_CAST(NULLIF(num_times_delinquent, '-99999') AS INT) AS num_times_delinquent,
TRY_CAST(NULLIF(num_deliq_6mts, '-99999') AS INT) AS num_deliq_6mts,
TRY_CAST(NULLIF(num_deliq_12mts, '-99999') AS INT) AS num_deliq_12mts,
TRY_CAST(NULLIF(num_deliq_6_12mts, '-99999') AS INT) AS num_deliq_6_12mts,

-- Delinquency Severity
TRY_CAST(NULLIF(max_delinquency_level, '-99999') AS INT) AS max_delinquency_level,
TRY_CAST(NULLIF(max_deliq_6mts, '-99999') AS INT) AS max_deliq_6mts,
TRY_CAST(NULLIF(max_deliq_12mts, '-99999') AS INT) AS max_deliq_12mts,
TRY_CAST(NULLIF(max_recent_level_of_deliq, '-99999') AS INT) AS max_recent_level_of_deliq,
TRY_CAST(NULLIF(recent_level_of_deliq, '-99999') AS INT) AS recent_level_of_deliq,

-- DPD
TRY_CAST(NULLIF(num_times_30p_dpd, '-99999') AS INT) AS num_times_30p_dpd,
TRY_CAST(NULLIF(num_times_60p_dpd, '-99999') AS INT) AS num_times_60p_dpd,

-- Credit Classification
TRY_CAST(NULLIF(num_std, '-99999') AS INT) AS num_std,
TRY_CAST(NULLIF(num_sub, '-99999') AS INT) AS num_sub,
TRY_CAST(NULLIF(num_dbt, '-99999') AS INT) AS num_dbt,
TRY_CAST(NULLIF(num_lss, '-99999') AS INT) AS num_lss,

-- 6M / 12M
TRY_CAST(NULLIF(num_std_6mts, '-99999') AS INT) AS num_std_6mts,
TRY_CAST(NULLIF(num_std_12mts, '-99999') AS INT) AS num_std_12mts,
TRY_CAST(NULLIF(num_sub_6mts, '-99999') AS INT) AS num_sub_6mts,
TRY_CAST(NULLIF(num_sub_12mts, '-99999') AS INT) AS num_sub_12mts,
TRY_CAST(NULLIF(num_dbt_6mts, '-99999') AS INT) AS num_dbt_6mts,
TRY_CAST(NULLIF(num_dbt_12mts, '-99999') AS INT) AS num_dbt_12mts,
TRY_CAST(NULLIF(num_lss_6mts, '-99999') AS INT) AS num_lss_6mts,
TRY_CAST(NULLIF(num_lss_12mts, '-99999') AS INT) AS num_lss_12mts,

-- Enquiries
TRY_CAST(NULLIF(tot_enq, '-99999') AS INT) AS tot_enq,
TRY_CAST(NULLIF(CC_enq, '-99999') AS INT) AS CC_enq,
TRY_CAST(NULLIF(CC_enq_L6m, '-99999') AS INT) AS CC_enq_L6m,
TRY_CAST(NULLIF(CC_enq_L12m, '-99999') AS INT) AS CC_enq_L12m,
TRY_CAST(NULLIF(PL_enq, '-99999') AS INT) AS PL_enq,
TRY_CAST(NULLIF(PL_enq_L6m, '-99999') AS INT) AS PL_enq_L6m,
TRY_CAST(NULLIF(PL_enq_L12m, '-99999') AS INT) AS PL_enq_L12m,
TRY_CAST(NULLIF(enq_L3m, '-99999') AS INT) AS enq_L3m,
TRY_CAST(NULLIF(enq_L6m, '-99999') AS INT) AS enq_L6m,
TRY_CAST(NULLIF(enq_L12m, '-99999') AS INT) AS enq_L12m,

-- Demographics
MARITALSTATUS,
EDUCATION,
AGE,
GENDER,

-- Income
TRY_CAST(NULLIF(NETMONTHLYINCOME, '-99999') AS FLOAT) AS NETMONTHLYINCOME,
Time_With_Curr_Empr,
-- Percentages
TRY_CAST(NULLIF(pct_of_active_TLs_ever, '-99999') AS FLOAT) AS pct_of_active_TLs_ever,
TRY_CAST(NULLIF(pct_opened_TLs_L6m_of_L12m, '-99999') AS FLOAT) AS pct_opened_TLs_L6m_of_L12m,
TRY_CAST(NULLIF(pct_currentBal_all_TL, '-99999') AS FLOAT) AS pct_currentBal_all_TL,

-- Utilization
TRY_CAST(NULLIF(CC_utilization, '-99999') AS FLOAT) AS CC_utilization,
TRY_CAST(NULLIF(PL_utilization, '-99999') AS FLOAT) AS PL_utilization,

-- Ratio Features
TRY_CAST(NULLIF(pct_PL_enq_L6m_of_L12m, '-99999') AS FLOAT) AS pct_PL_enq_L6m_of_L12m,
TRY_CAST(NULLIF(pct_CC_enq_L6m_of_L12m, '-99999') AS FLOAT) AS pct_CC_enq_L6m_of_L12m,
TRY_CAST(NULLIF(pct_PL_enq_L6m_of_ever, '-99999') AS FLOAT) AS pct_PL_enq_L6m_of_ever,
TRY_CAST(NULLIF(pct_CC_enq_L6m_of_ever, '-99999') AS FLOAT) AS pct_CC_enq_L6m_of_ever,

-- Exposure
TRY_CAST(NULLIF(max_unsec_exposure_inPct, '-99999') AS FLOAT) AS max_unsec_exposure_inPct,

-- Flags
TRY_CAST(CC_Flag AS INT) AS CC_Flag,
TRY_CAST(PL_Flag AS INT) AS PL_Flag,
TRY_CAST(HL_Flag AS INT) AS HL_Flag,
TRY_CAST(GL_Flag AS INT) AS GL_Flag,

-- Target
Credit_Score,
Approved_Flag,
last_prod_enq2,
first_prod_enq2

INTO Cibil_Data_Final
FROM Cibil_Data_Clean;

/* Structured Feature Engineering Dataset Creation
   - A cleaned, analysis-ready dataset (CibilData_Final) is created.
*/
SELECT TOP 5 * FROM Cibil_Data_Final

--Bank Data

SELECT *
INTO Bank_Data_Clean
FROM INTERNAL_BANK_DATA2;

/* 
   - Raw BankData is copied into BankData_Clean
   - Ensures original dataset remains unchanged
*/

SELECT TOP 5 * FROM Bank_Data_Clean

SELECT 
COLUMN_NAME,
DATA_TYPE,
IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Bank_Data_Clean';

/*   Data Type Correction
   - Percentage and count-based columns stored as NVARCHAR
   - Altered to support numeric conversion
*/

ALTER TABLE Bank_Data_Clean
ALTER COLUMN Age_Oldest_TL NVARCHAR(50) NULL;

ALTER TABLE Bank_Data_Clean
ALTER COLUMN Age_Newest_TL NVARCHAR(50) NULL;

ALTER TABLE Bank_Data_Clean
ALTER COLUMN pct_tl_open_L6M NVARCHAR(50) NULL;

ALTER TABLE Bank_Data_Clean
ALTER COLUMN pct_tl_closed_L6M NVARCHAR(50) NULL;

ALTER TABLE Bank_Data_Clean
ALTER COLUMN pct_active_tl NVARCHAR(50) NULL;

ALTER TABLE Bank_Data_Clean
ALTER COLUMN pct_closed_tl NVARCHAR(50) NULL;

ALTER TABLE Bank_Data_Clean
ALTER COLUMN pct_tl_open_L12M NVARCHAR(50) NULL;

ALTER TABLE Bank_Data_Clean
ALTER COLUMN pct_tl_closed_L12M NVARCHAR(50) NULL;

ALTER TABLE Bank_Data_Clean
ALTER COLUMN Tot_Missed_Pmnt NVARCHAR(50) NULL;

/*   Handling Missing Placeholder Values (-99999)
   - -99999 values are replaced with NULL
   - Ensures statistical calculations (min/max/ratios) are not distorted
*/

SELECT *
FROM Bank_Data_Clean
WHERE 
Age_Oldest_TL = '-99999'
OR Age_Newest_TL = '-99999'
OR pct_active_tl = '-99999'
OR pct_closed_tl = '-99999'
OR pct_tl_open_L6M = '-99999'
OR pct_tl_closed_L6M = '-99999'
OR pct_tl_open_L12M = '-99999'
OR pct_tl_closed_L12M = '-99999'
OR Tot_Missed_Pmnt = '-99999';


UPDATE Bank_Data_Clean
SET  
Age_Oldest_TL = NULLIF(Age_Oldest_TL, '-99999'),
Age_Newest_TL = NULLIF(Age_Newest_TL, '-99999'),
pct_active_tl = NULLIF(pct_active_tl, '-99999'),
pct_closed_tl = NULLIF(pct_closed_tl, '-99999'),
pct_tl_open_L6M = NULLIF(pct_tl_open_L6M, '-99999'),
pct_tl_closed_L6M = NULLIF(pct_tl_closed_L6M, '-99999'),
pct_tl_open_L12M = NULLIF(pct_tl_open_L12M, '-99999'),
pct_tl_closed_L12M = NULLIF(pct_tl_closed_L12M, '-99999'),
Tot_Missed_Pmnt = NULLIF(Tot_Missed_Pmnt, '-99999');


SELECT *
FROM Bank_Data_Clean
WHERE TRY_CAST(Total_TL AS INT) IS NULL
AND Total_TL IS NOT NULL;

/*   Data Validation (Pre-Clean Check)
   - Checked for records still containing placeholder values
   - Helps identify incomplete cleaning coverage
*/

/*   Statistical Range Analysis
   - Min/Max checks performed on:
     • Trade line counts
     • Loan type counts
     • Percentage variables
     • Age variables
   - Ensures values fall within realistic financial boundaries
*/

SELECT 
MIN(TRY_CAST(pct_active_tl AS FLOAT)) AS min_pct_active,
MAX(TRY_CAST(pct_active_tl AS FLOAT)) AS max_pct_active,

MIN(TRY_CAST(pct_closed_tl AS FLOAT)) AS min_pct_closed,
MAX(TRY_CAST(pct_closed_tl AS FLOAT)) AS max_pct_closed,

MIN(TRY_CAST(pct_tl_open_L6M AS FLOAT)) AS min_open_L6M,
MAX(TRY_CAST(pct_tl_open_L6M AS FLOAT)) AS max_open_L6M,

MIN(TRY_CAST(pct_tl_closed_L6M AS FLOAT)) AS min_closed_L6M,
MAX(TRY_CAST(pct_tl_closed_L6M AS FLOAT)) AS max_closed_L6M,

MIN(TRY_CAST(pct_tl_open_L12M AS FLOAT)) AS min_open_L12M,
MAX(TRY_CAST(pct_tl_open_L12M AS FLOAT)) AS max_open_L12M,

MIN(TRY_CAST(pct_tl_closed_L12M AS FLOAT)) AS min_closed_L12M,
MAX(TRY_CAST(pct_tl_closed_L12M AS FLOAT)) AS max_closed_L12M

FROM Bank_Data_Clean;

SELECT 
MIN(TRY_CAST(Age_Oldest_TL AS INT)) AS min_oldest,
MAX(TRY_CAST(Age_Oldest_TL AS INT)) AS max_oldest,

MIN(TRY_CAST(Age_Newest_TL AS INT)) AS min_newest,
MAX(TRY_CAST(Age_Newest_TL AS INT)) AS max_newest
FROM Bank_Data_Clean;


SELECT 
MIN(TRY_CAST(Total_TL AS INT)) AS min_total,
MAX(TRY_CAST(Total_TL AS INT)) AS max_total,

MIN(TRY_CAST(Tot_Active_TL AS INT)) AS min_active,
MAX(TRY_CAST(Tot_Active_TL AS INT)) AS max_active,

MIN(TRY_CAST(Tot_Closed_TL AS INT)) AS min_closed,
MAX(TRY_CAST(Tot_Closed_TL AS INT)) AS max_closed
FROM Bank_Data_Clean;


SELECT 
MIN(TRY_CAST(Auto_TL AS INT)) AS min_auto,
MAX(TRY_CAST(Auto_TL AS INT)) AS max_auto,

MIN(TRY_CAST(CC_TL AS INT)) AS min_cc,
MAX(TRY_CAST(CC_TL AS INT)) AS max_cc,

MIN(TRY_CAST(Consumer_TL AS INT)) AS min_consumer,
MAX(TRY_CAST(Consumer_TL AS INT)) AS max_consumer,

MIN(TRY_CAST(Gold_TL AS INT)) AS min_gold,
MAX(TRY_CAST(Gold_TL AS INT)) AS max_gold,

MIN(TRY_CAST(Home_TL AS INT)) AS min_home,
MAX(TRY_CAST(Home_TL AS INT)) AS max_home,

MIN(TRY_CAST(PL_TL AS INT)) AS min_pl,
MAX(TRY_CAST(PL_TL AS INT)) AS max_pl
FROM Bank_Data_Clean;


SELECT 
MIN(TRY_CAST(Secured_TL AS INT)) AS min_secured,
MAX(TRY_CAST(Secured_TL AS INT)) AS max_secured,

MIN(TRY_CAST(Unsecured_TL AS INT)) AS min_unsecured,
MAX(TRY_CAST(Unsecured_TL AS INT)) AS max_unsecured,

MIN(TRY_CAST(Other_TL AS INT)) AS min_other,
MAX(TRY_CAST(Other_TL AS INT)) AS max_other
FROM Bank_Data_Clean;



SELECT DISTINCT Tot_Missed_Pmnt 
FROM Bank_Data_Clean
ORDER BY Tot_Missed_Pmnt;

SELECT DISTINCT Total_TL_opened_L6M FROM Bank_Data_Clean;
SELECT DISTINCT Total_TL_opened_L12M FROM Bank_Data_Clean;

/*   Final Structured Dataset Creation
   - BankData_Final created with cleaned numeric conversions
   - Ensures consistency across all financial variables
*/

SELECT 
PROSPECTID,

-- Trade Line Counts
TRY_CAST(Total_TL AS INT) AS Total_TL,
TRY_CAST(Tot_Active_TL AS INT) AS Tot_Active_TL,
TRY_CAST(Tot_Closed_TL AS INT) AS Tot_Closed_TL,

-- Recent Activity (6M / 12M)
TRY_CAST(Total_TL_opened_L6M AS INT) AS Total_TL_opened_L6M,
TRY_CAST(Tot_TL_closed_L6M AS INT) AS Tot_TL_closed_L6M,
TRY_CAST(Total_TL_opened_L12M AS INT) AS Total_TL_opened_L12M,
TRY_CAST(Tot_TL_closed_L12M AS INT) AS Tot_TL_closed_L12M,

-- Percentages
TRY_CAST(pct_tl_open_L6M AS FLOAT) AS pct_tl_open_L6M,
TRY_CAST(pct_tl_closed_L6M AS FLOAT) AS pct_tl_closed_L6M,
TRY_CAST(pct_active_tl AS FLOAT) AS pct_active_tl,
TRY_CAST(pct_closed_tl AS FLOAT) AS pct_closed_tl,
TRY_CAST(pct_tl_open_L12M AS FLOAT) AS pct_tl_open_L12M,
TRY_CAST(pct_tl_closed_L12M AS FLOAT) AS pct_tl_closed_L12M,

-- Missed Payments
TRY_CAST(Tot_Missed_Pmnt AS INT) AS Tot_Missed_Pmnt,

-- Loan Type Counts
TRY_CAST(Auto_TL AS INT) AS Auto_TL,
TRY_CAST(CC_TL AS INT) AS CC_TL,
TRY_CAST(Consumer_TL AS INT) AS Consumer_TL,
TRY_CAST(Gold_TL AS INT) AS Gold_TL,
TRY_CAST(Home_TL AS INT) AS Home_TL,
TRY_CAST(PL_TL AS INT) AS PL_TL,

-- Secured / Unsecured
TRY_CAST(Secured_TL AS INT) AS Secured_TL,
TRY_CAST(Unsecured_TL AS INT) AS Unsecured_TL,
TRY_CAST(Other_TL AS INT) AS Other_TL,

-- Age of Trade Lines
TRY_CAST(Age_Oldest_TL AS INT) AS Age_Oldest_TL,
TRY_CAST(Age_Newest_TL AS INT) AS Age_Newest_TL

INTO Bank_final_data
FROM Bank_Data_Clean;

SELECT TOP 10 * FROM Bank_final_data

/*   FINAL FEATURE ENGINEERING AND DATASET CREATION
   - CibilData_Final and BankData_Final are merged using PROSPECTID
   - Only matched records are retained (INNER JOIN)
*/

/*
FINAL FEATURE ENGINEERING AND DATASET CREATION
- CibilData_Final and BankData_Final are merged using PROSPECTID
- Only matched records are retained (INNER JOIN)
*/

SELECT 
    c.*, 

    b.Total_TL,
    b.Tot_Active_TL,
    b.Tot_Closed_TL,
    b.Total_TL_opened_L6M,
    b.Tot_TL_closed_L6M,
    b.Total_TL_opened_L12M,
    b.Tot_TL_closed_L12M,
    b.pct_tl_open_L6M,
    b.pct_tl_closed_L6M,
    b.pct_active_tl,
    b.pct_closed_tl,
    b.pct_tl_open_L12M,
    b.pct_tl_closed_L12M,
    b.Tot_Missed_Pmnt,
    b.Auto_TL,
    b.CC_TL,
    b.Consumer_TL,
    b.Gold_TL,
    b.Home_TL,
    b.PL_TL,
    b.Secured_TL,
    b.Unsecured_TL,
    b.Other_TL,
    b.Age_Oldest_TL,
    b.Age_Newest_TL

INTO Final_Table_

FROM Cibil_Data_Final c
INNER JOIN Bank_final_data b
ON c.PROSPECTID = b.PROSPECTID;

/* CORE RISK KPI ENGINEERING
   - Default_Flag: Identifies risky customers based on missed payments
   - Delinquency_Ratio: Measures loan stress per customer
   - Recent_Delinquency_Flag: Captures recent credit risk behavior
*/


-- Default Flag (Target Variable)

/* Default_Flag is a derived target variable.
   Customers with at least one missed payment are treated as default-risk customers.
   This is used for predictive modeling, while Approved_Flag is retained for business approval analysis. */

SELECT
    c.*,

    b.Age_Newest_TL,

    -- Default Flag (Target Variable)
    CASE 
        WHEN b.Tot_Missed_Pmnt > 0 THEN 1 
        ELSE 0 
    END AS Default_Flag,

    -- Overall Delinquency Risk
    CAST(c.num_times_delinquent AS FLOAT) / NULLIF(b.Total_TL,0)
    AS Delinquency_Ratio,

    -- Recent Risk Indicator
    CASE 
        WHEN c.num_deliq_6mts > 0 THEN 1 
        ELSE 0 
    END AS Recent_Delinquency_Flag

FROM Cibil_Data_Final c
INNER JOIN Bank_Data_Final b
ON c.PROSPECTID = b.PROSPECTID;

/* EXPOSURE KPIs
   - Unsecured_Exposure: From CIBIL credit utilization behavior
   - Unsecured_Loan_Ratio: Bank-level unsecured loan dependency
*/

-- Unsecured Exposure from CIBIL
c.max_unsec_exposure_inPct AS Unsecured_Exposure,


-- Ratio of Unsecured Loans
CAST(b.Unsecured_TL AS FLOAT) / NULLIF(b.Total_TL,0)
AS Unsecured_Loan_Ratio

/* CUSTOMER STABILITY KPIs
   - Income: Monthly financial strength indicator
   - Employment_Stability: Time with current employer
*/

-- Monthly Income
c.NETMONTHLYINCOME AS Income,

-- Employment Stability
c.Time_With_Curr_Empr AS Employment_Stability,

/* CREDIT BEHAVIOR KPIs
   - Total_Enquiries: Measures credit hunger
   - Recent_Loan_Activity: Recent borrowing behavior from bank data
*/

-- Total Enquiries (Credit Hunger)
c.tot_enq AS Total_Enquiries,

-- Recent Loan Activity
CAST(b.Total_TL_opened_L6M AS FLOAT) / NULLIF(b.Total_TL,0) 
AS Recent_Loan_Activity

INTO FinalData
FROM CibilData_Final c
INNER JOIN BankData_Final b
ON c.PROSPECTID = b.PROSPECTID;

/* FINAL MODEL READY DATASET
   - FinalData contains:
     • Cleaned CIBIL + Bank features
     • Engineered KPIs
     • Target variable (Default_Flag)
   - Ready for descriptive, diagnostic, and predictive modeling
*/

SELECT TOP 5 * FROM FinalData

SELECT 
COLUMN_NAME,
DATA_TYPE,
IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FinalData';


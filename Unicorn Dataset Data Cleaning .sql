-- Data Cleaning for Startup Unicorns Analytics Project
--------------------------------------------------------------------------------------------------------

USE StartupUnicorns;

--------------------------------------------------------------------------------------------------------
-- General Data Cleaning
--------------------------------------------------------------------------------------------------------

-- 1. Identify and Handle Missing Values
-- Check for missing values in the startup_info table
SELECT *
FROM StartupUnicorns.dbo.startup_info
WHERE CompanyName IS NULL OR YearFounded IS NULL;

-- Impute missing values for YearFounded with the average
UPDATE StartupUnicorns.dbo.startup_info
SET YearFounded = (SELECT AVG(YearFounded) FROM StartupUnicorns.dbo.startup_info WHERE YearFounded IS NOT NULL)
WHERE YearFounded IS NULL;

-- 2. Identify and Remove Duplicates in startup_info
-- Remove duplicates by keeping the most recent entry based on YearFounded
WITH DuplicateCompanies AS (
    SELECT 
        CompanyName,
        YearFounded,
        ROW_NUMBER() OVER (PARTITION BY CompanyName ORDER BY YearFounded DESC) AS RowNum
    FROM StartupUnicorns.dbo.startup_info
)

-- Delete duplicates, keeping only the most recent entry
DELETE FROM DuplicateCompanies
WHERE RowNum > 1; 

--------------------------------------------------------------------------------------------------------
-- Specific Data Cleaning for the Unicorn Companies Dataset
--------------------------------------------------------------------------------------------------------

-- Display all records from the startup information table
SELECT *
FROM StartupUnicorns.dbo.startup_info
ORDER BY 1 ASC;

-- Display all records from the startup finance table
SELECT *
FROM StartupUnicorns.dbo.startup_finance
ORDER BY 1 ASC;

--------------------------------------------------------------------------------------------------------

-- Check for duplicate company names in the startup finance table
SELECT CompanyName, COUNT(CompanyName) AS CompanyCount
FROM StartupUnicorns.dbo.startup_finance
GROUP BY CompanyName
HAVING COUNT(CompanyName) > 1;

----------------------------------------------------------------------------------------

-- Rename columns for better readability
EXEC sp_rename 'dbo.startup_info.[Year Founded]', 'YearFounded', 'COLUMN';
EXEC sp_rename 'dbo.startup_finance.[Date Joined]', 'DateJoined', 'COLUMN';
EXEC sp_rename 'dbo.startup_finance.[Select Investors]', 'SelectedInvestors', 'COLUMN';

-- Confirm the renaming of columns
SELECT *
FROM StartupUnicorns.dbo.startup_finance;

--------------------------------------------------------------------------------------------------------

-- Standardize the format of the 'Date Joined' column and separate it into Year, Month, and Day
ALTER TABLE StartupUnicorns.dbo.startup_finance
ADD ConvertedDateJoined DATE;

-- Convert the original date format into a standardized date format
UPDATE StartupUnicorns.dbo.startup_finance
SET ConvertedDateJoined = CONVERT(DATE, DateJoined);

-- Add Year column based on the converted date
ALTER TABLE StartupUnicorns.dbo.startup_finance
ADD JoinYear INT;
UPDATE StartupUnicorns.dbo.startup_finance
SET JoinYear = DATEPART(YEAR, ConvertedDateJoined);

-- Add Month column based on the converted date
ALTER TABLE StartupUnicorns.dbo.startup_finance
ADD JoinMonth INT;
UPDATE StartupUnicorns.dbo.startup_finance
SET JoinMonth = DATEPART(MONTH, ConvertedDateJoined);

-- Add Day column based on the converted date
ALTER TABLE StartupUnicorns.dbo.startup_finance
ADD JoinDay INT;
UPDATE StartupUnicorns.dbo.startup_finance
SET JoinDay = DATEPART(DAY, ConvertedDateJoined);

-- Confirm the updates to the startup finance table
SELECT *
FROM StartupUnicorns.dbo.startup_finance;

--------------------------------------------------------------------------------------------------------

-- Remove rows where the Funding column is either $0 or Unknown
DELETE FROM StartupUnicorns.dbo.startup_finance 
WHERE Funding IN ('$0M', 'Unknown');

-- Display unique funding values remaining in the table
SELECT DISTINCT Funding
FROM StartupUnicorns.dbo.startup_finance
ORDER BY Funding DESC;

--------------------------------------------------------------------------------------------------------

-- Reformat currency values in the 'Valuation' and 'Funding' columns
-- Remove currency symbols and convert values into numeric format

-- Process the Valuation column
UPDATE StartupUnicorns.dbo.startup_finance
SET Valuation = RIGHT(Valuation, LEN(Valuation) - 1);  -- Remove currency symbol ('$')

UPDATE StartupUnicorns.dbo.startup_finance
SET Valuation = REPLACE(REPLACE(Valuation, 'B', '000000000'), 'M', '000000');  -- Convert 'B' to billions and 'M' to millions

-- Process the Funding column
UPDATE StartupUnicorns.dbo.startup_finance
SET Funding = RIGHT(Funding, LEN(Funding) - 1);  -- Remove currency symbol ('$')

UPDATE StartupUnicorns.dbo.startup_finance
SET Funding = REPLACE(REPLACE(Funding, 'B', '000000000'), 'M', '000000');  -- Convert 'B' to billions and 'M' to millions

-- Confirm the updates to the startup finance table
SELECT *
FROM StartupUnicorns.dbo.startup_finance;

--------------------------------------------------------------------------------------------------------

-- Remove unused columns from the startup finance table
ALTER TABLE StartupUnicorns.dbo.startup_finance
DROP COLUMN DateJoined;  -- Drop the original 'Date Joined' column

-- Rename the converted date column back to 'Date Joined'
EXEC sp_rename 'dbo.startup_finance.ConvertedDateJoined', 'DateJoined', 'COLUMN';

-- Confirm the final state of the startup finance table
SELECT *
FROM StartupUnicorns.dbo.startup_finance;



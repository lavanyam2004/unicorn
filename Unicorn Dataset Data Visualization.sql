------- Queries for Data Visualization -----
--------------------------------------------------------------------------------------------------------

USE StartupUnicorns;

-- Table 1
-- Total Unicorn Companies
WITH StartupCom AS (
    SELECT inf.ID, inf.CompanyName, inf.Industry, inf.City, inf.Country, inf.Continent, 
           fin.Valuation, fin.Funding, inf.YearFounded, fin.Year, fin.SelectedInvestors
    FROM StartupUnicorns.dbo.startup_info AS inf
    INNER JOIN StartupUnicorns.dbo.startup_finance AS fin 
        ON inf.ID = fin.ID
)
SELECT COUNT(1) AS UnicornCount
FROM StartupCom
WHERE (Year - YearFounded) >= 0;

--------------------------------------------------------------------------------------------------------

-- Table 2
-- Total Countries with Unicorn Companies
SELECT COUNT(DISTINCT Country) AS CountryCount
FROM StartupCom
WHERE (Year - YearFounded) >= 0;

--------------------------------------------------------------------------------------------------------

-- Table 3
-- Unicorn Companies by Country
SELECT CompanyName, Country
FROM StartupCom
WHERE (Year - YearFounded) >= 0;

--------------------------------------------------------------------------------------------------------

-- Table 4
-- Return on Investment (ROI) for Unicorn Companies
SELECT CompanyName, 
       (CONVERT(BIGINT, Valuation) - CONVERT(BIGINT, Funding)) / CONVERT(BIGINT, Funding) AS Roi
FROM StartupUnicorns.dbo.startup_finance
ORDER BY Roi DESC;

--------------------------------------------------------------------------------------------------------

-- Table 5
-- Unicorn Age by Year Founded
SELECT CompanyName, (Year - YearFounded) AS UnicornAge
FROM StartupCom
WHERE (Year - YearFounded) >= 0;

--------------------------------------------------------------------------------------------------------

-- Table 6
-- Frequency of Unicorns by Year Founded
SELECT (Year - YearFounded) AS UnicornAge, COUNT(1) AS Frequency
FROM StartupCom
WHERE (Year - YearFounded) >= 0
GROUP BY (Year - YearFounded)
ORDER BY Frequency DESC;

--------------------------------------------------------------------------------------------------------

-- Table 7
-- Frequency of Unicorns by Industry
SELECT Industry, COUNT(1) AS Frequency, 
       CAST(COUNT(1) * 100.0 / (SELECT COUNT(*) FROM StartupCom) AS INT) AS Percentage
FROM StartupCom
WHERE (Year - YearFounded) >= 0
GROUP BY Industry
ORDER BY Frequency DESC;

--------------------------------------------------------------------------------------------------------

-- Table 8
-- Average Valuation by Industry
SELECT Industry, AVG(CONVERT(BIGINT, Valuation)) AS AverageValuation
FROM StartupCom
WHERE (Year - YearFounded) >= 0
GROUP BY Industry
ORDER BY AverageValuation DESC;

--------------------------------------------------------------------------------------------------------

-- Table 9
-- Distribution of Unicorn Companies by Year Founded
SELECT YearFounded, COUNT(1) AS NumberOfUnicorns
FROM StartupCom
WHERE (Year - YearFounded) >= 0
GROUP BY YearFounded
ORDER BY YearFounded ASC;

--------------------------------------------------------------------------------------------------------

-- Table 10
-- Total Funding by Country
SELECT Country, SUM(CONVERT(BIGINT, Funding)) AS TotalFunding
FROM StartupCom
WHERE (Year - YearFounded) >= 0
GROUP BY Country
ORDER BY TotalFunding DESC;

--------------------------------------------------------------------------------------------------------

-- Table 11
-- Investors Distribution across Unicorn Companies
SELECT value AS Investors, COUNT(*) AS UnicornsInvested 
FROM StartupUnicorns.dbo.startup_finance
CROSS APPLY STRING_SPLIT(SelectedInvestors, ',')  
GROUP BY value  
ORDER BY COUNT(*) DESC;

--------------------------------------------------------------------------------------------------------



-- Full view of the dataframe: crimedata
SELECT *
FROM dbo.crimedata_csv_all_years$
ORDER BY INCIDENT_NUMBER

-- Change from Central Business District to Downtown
UPDATE dbo.crimedata_csv_all_years$
SET NEIGHBOURHOOD = 'Downtown'
WHERE NEIGHBOURHOOD = 'Central Business District'

-- Change from Arbutus Ridge to Arbutus-Ridge
UPDATE dbo.crimedata_csv_all_years$
SET NEIGHBOURHOOD = 'Arbutus-Ridge'
WHERE NEIGHBOURHOOD = 'Arbutus Ridge'

-- Print all rows for any Null values in HUNDRED_BLOCK, NEIGHBOURHOOD, X or Y
SELECT *
FROM dbo.crimedata_csv_all_years$
WHERE HUNDRED_BLOCK IS NULL 
	OR NEIGHBOURHOOD IS NULL 
	OR X IS NULL 
	OR Y IS NULL

-- Will be ignoring rows with NULL in any attributes
-- Total number of incidents for each Neighbourhood
SELECT 
	NEIGHBOURHOOD,
	CAST(COUNT(NEIGHBOURHOOD) AS float) AS Total_Crime_by_Neighbourhood
FROM dbo.crimedata_csv_all_years$
GROUP BY NEIGHBOURHOOD
HAVING NEIGHBOURHOOD IS NOT NULL
ORDER BY Total_Crime_by_Neighbourhood DESC


-- The crime frequencies by type in Vancouver
SELECT 
	TYPE,
	CAST(Count(TYPE) AS float) AS Crime_Type
FROM dbo.crimedata_csv_all_years$
GROUP BY TYPE
HAVING TYPE IS NOT NULL
ORDER BY Crime_Type DESC

-- Breakdown of the incident counts and ratio by Neighbourhood then Type
-- Ignore Musqueam and Stanley Park incidents
SELECT 
	NEIGHBOURHOOD,
	TYPE,
	COUNT(TYPE) AS Crime_Count,
	ROUND(CAST(COUNT(TYPE) AS float)*100/(CAST(SUM(COUNT(NEIGHBOURHOOD)) OVER (PARTITION BY NEIGHBOURHOOD) AS float)),2) AS Ratio
FROM 
	(SELECT *
	FROM dbo.crimedata_csv_all_years$
	WHERE HUNDRED_BLOCK IS NOT NULL OR NEIGHBOURHOOD IS NOT NULL OR X IS NOT NULL OR Y IS NOT NULL) nonull
WHERE NEIGHBOURHOOD != 'Musqueam' AND NEIGHBOURHOOD != 'Stanley Park'
GROUP BY NEIGHBOURHOOD, TYPE
--HAVING NEIGHBOURHOOD IS NOT NULL
ORDER BY NEIGHBOURHOOD, Crime_Count DESC

-- Crime Per Year/ Month
SELECT
	YEAR,
	MONTH,
	COUNT(NEIGHBOURHOOD) AS Crime_Count
FROM (	SELECT *
		FROM dbo.crimedata_csv_all_years$
		WHERE HUNDRED_BLOCK IS NOT NULL OR NEIGHBOURHOOD IS NOT NULL OR X IS NOT NULL OR Y IS NOT NULL  ) nonull
GROUP BY YEAR, MONTH
ORDER BY YEAR, MONTH

-- Yearly Crime by Neighbourhood
SELECT
	NEIGHBOURHOOD, YEAR,
	COUNT(NEIGHBOURHOOD) AS Crime_Count,
	ROUND(CAST(COUNT(NEIGHBOURHOOD) AS float) * 100/CAST(SUM(COUNT(NEIGHBOURHOOD)) OVER (PARTITION BY NEIGHBOURHOOD) AS float),2) AS Yearly_Ratio
FROM  
	(SELECT *
	FROM dbo.crimedata_csv_all_years$
	WHERE HUNDRED_BLOCK IS NOT NULL OR NEIGHBOURHOOD IS NOT NULL OR X IS NOT NULL OR Y IS NOT NULL) nonull
GROUP BY NEIGHBOURHOOD, YEAR
HAVING NEIGHBOURHOOD IS NOT NULL
ORDER BY NEIGHBOURHOOD, YEAR

-- Crime counted by Neighbourhood, Type then by YEAR 
SELECT 
	NEIGHBOURHOOD,
	TYPE,
	YEAR,
	COUNT(TYPE) AS Crime_Count
FROM 
	(SELECT *
	FROM dbo.crimedata_csv_all_years$
	WHERE HUNDRED_BLOCK IS NOT NULL OR NEIGHBOURHOOD IS NOT NULL OR X IS NOT NULL OR Y IS NOT NULL) nonull
WHERE NEIGHBOURHOOD != 'Musqueam' AND NEIGHBOURHOOD != 'Stanley Park'
GROUP BY NEIGHBOURHOOD, TYPE, YEAR
HAVING NEIGHBOURHOOD IS NOT NULL
ORDER BY NEIGHBOURHOOD, TYPE, YEAR

-- Derive Day of week from Full Date
SELECT  
	INCIDENT_NUMBER,
	DATENAME(WEEKDAY, CAST(CONCAT(YEAR,'-', RIGHT(CONCAT('0',MONTH), 2),'-',RIGHT(CONCAT('0',DAY), 2), ' ', RIGHT(CONCAT('0',HOUR), 2),':', RIGHT(CONCAT('0',MINUTE),2)) AS datetime)) AS Crime_Day
	--CAST(CONCAT(RIGHT(CONCAT('0',HOUR), 2),':', RIGHT(CONCAT('0',MINUTE),2)) AS time) AS Full_Time
FROM dbo.crimedata_csv_all_years$
ORDER BY INCIDENT_NUMBER

-- Crime Day vs Number of Crimes reported
SELECT
	NEIGHBOURHOOD,
	DATENAME(WEEKDAY, CAST(CONCAT(YEAR,'-', RIGHT(CONCAT('0',MONTH), 2),'-',RIGHT(CONCAT('0',DAY), 2), ' ', RIGHT(CONCAT('0',HOUR), 2),':', RIGHT(CONCAT('0',MINUTE),2)) AS datetime)) AS Crime_Day
FROM dbo.crimedata_csv_all_years$


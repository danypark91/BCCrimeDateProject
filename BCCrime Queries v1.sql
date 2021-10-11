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

-- PRIVACY PROTECTION, X and Y coordinates are 0
select *
from dbo.crimedata_csv_all_years$
where X = 0 or Y = 0

-- OVERVIEW
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

-- Last date of the report: distinguish 
select 
	MAX(DAY)   AS LAST_DAY
from dbo.crimedata_csv_all_years$
where YEAR = 2021 AND MONTH = 7

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
	WHERE HUNDRED_BLOCK IS NOT NULL AND NEIGHBOURHOOD IS NOT NULL AND X IS NOT NULL AND Y IS NOT NULL) nonull
WHERE NEIGHBOURHOOD != 'Musqueam' AND NEIGHBOURHOOD != 'Stanley Park'
GROUP BY NEIGHBOURHOOD, TYPE
--HAVING NEIGHBOURHOOD IS NOT NULL
ORDER BY NEIGHBOURHOOD, Crime_Count DESC

-- Crime Per Year/ Month,
-- Better to see by wide table
SELECT
	YEAR,
	MONTH,
	COUNT(NEIGHBOURHOOD) AS Crime_Count
FROM (	SELECT *
		FROM dbo.crimedata_csv_all_years$
		WHERE HUNDRED_BLOCK IS NOT NULL AND NEIGHBOURHOOD IS NOT NULL AND X IS NOT NULL AND Y IS NOT NULL  ) nonull
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
	WHERE HUNDRED_BLOCK IS NOT NULL AND NEIGHBOURHOOD IS NOT NULL AND X IS NOT NULL AND Y IS NOT NULL) nonull
GROUP BY NEIGHBOURHOOD, YEAR
--HAVING NEIGHBOURHOOD IS NOT NULL
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
	WHERE HUNDRED_BLOCK IS NOT NULL AND NEIGHBOURHOOD IS NOT NULL AND X IS NOT NULL AND Y IS NOT NULL) nonull
WHERE NEIGHBOURHOOD != 'Musqueam' AND NEIGHBOURHOOD != 'Stanley Park'
GROUP BY NEIGHBOURHOOD, TYPE, YEAR
--HAVING NEIGHBOURHOOD IS NOT NULL
ORDER BY NEIGHBOURHOOD, TYPE, YEAR

-- PRIOR POST COVID19
-- Full date format
SELECT  
	INCIDENT_NUMBER,
	CAST(CONCAT(YEAR,'-', RIGHT(CONCAT('0',MONTH), 2),'-',RIGHT(CONCAT('0',DAY), 2), ' ', RIGHT(CONCAT('0',HOUR), 2),':', RIGHT(CONCAT('0',MINUTE),2)) AS datetime) AS Full_Date,
	DATENAME(WEEKDAY, CAST(CONCAT(YEAR,'-', RIGHT(CONCAT('0',MONTH), 2),'-',RIGHT(CONCAT('0',DAY), 2), ' ', RIGHT(CONCAT('0',HOUR), 2),':', RIGHT(CONCAT('0',MINUTE),2)) AS datetime)) AS Crime_Day
	--CAST(CONCAT(RIGHT(CONCAT('0',HOUR), 2),':', RIGHT(CONCAT('0',MINUTE),2)) AS time) AS Full_Time
FROM dbo.crimedata_csv_all_years$
ORDER BY INCIDENT_NUMBER

-- Add a column: full date, datetime form and add data fo YEAR MONTH DAY HOUR and MINUTE by concat
alter table dbo.crimedata_csv_all_years$ add FULL_DATE datetime

update dbo.crimedata_csv_all_years$
set FULL_DATE = CAST(CONCAT(YEAR,'-', RIGHT(CONCAT('0',MONTH), 2),'-',RIGHT(CONCAT('0',DAY), 2), ' ', RIGHT(CONCAT('0',HOUR), 2),':', RIGHT(CONCAT('0',MINUTE),2)) AS datetime)


-- Prior Covid Lockdown
select *
from dbo.crimedata_csv_all_years$
where FULL_DATE < '2020-03-18'
order by FULL_DATE DESC

-- Post Covid Lockdown
select *
from dbo.crimedata_csv_all_years$
where FULL_DATE >= '2020-03-18'
order by FULL_DATE DESC

-- Prior Covid, by NEIGHBOURHOOD/YEAR/MONTH
-- Possible Bar Graph for data viz.
select 
	NEIGHBOURHOOD,
	YEAR,
	MONTH,
	CAST(COUNT(NEIGHBOURHOOD) AS float) AS NUMBER_OF_INC
from 
	(SELECT *
	FROM dbo.crimedata_csv_all_years$
	WHERE HUNDRED_BLOCK IS NOT NULL AND NEIGHBOURHOOD IS NOT NULL AND X IS NOT NULL AND Y IS NOT NULL) nonull
where FULL_DATE < '2020-03-18'
group by NEIGHBOURHOOD, YEAR, MONTH
--having NEIGHBOURHOOD IS NOT NULL
order by NEIGHBOURHOOD, YEAR, MONTH


-- Post Covid, by TYPE/YEAR/MONTH
select 
	TYPE,
	YEAR,
	MONTH,
	CAST(COUNT(TYPE) AS float) AS NUMBER_OF_INC
from 
	(SELECT *
	FROM dbo.crimedata_csv_all_years$
	WHERE HUNDRED_BLOCK IS NOT NULL AND NEIGHBOURHOOD IS NOT NULL AND X IS NOT NULL AND Y IS NOT NULL) nonull
where FULL_DATE >= '2020-03-18'
group by TYPE, YEAR, MONTH
--having TYPE IS NOT NULL
order by TYPE, YEAR, MONTH

-- Yearly average number of incident per neighbourhood and type (Prior, None Vehicle Related)
select	
	NEIGHBOURHOOD,
	TYPE,
	cast(count(TYPE) as float) as Total_Incident,
	round(cast(count(TYPE) as float)/18, 2) as Incident_per_Year
from 
	(SELECT *
	FROM dbo.crimedata_csv_all_years$
	WHERE HUNDRED_BLOCK IS NOT NULL AND NEIGHBOURHOOD IS NOT NULL AND X IS NOT NULL AND Y IS NOT NULL AND FULL_DATE < '2020-03-18') nonull_prior
where TYPE NOT LIKE '%Vehicle%' AND TYPE NOT LIKE '%Bicycle%'
group by NEIGHBOURHOOD, TYPE
--having NEIGHBOURHOOD IS NOT NULL AND TYPE IS NOT NULL
order by NEIGHBOURHOOD, TYPE

-- not full of the month for March-2020 and July-2021.
-- Daily Avg of the months *# days to estimate the number of incidents
select
	TYPE,
	YEAR,
	MONTH,
	count(TYPE) as Actual_Incident,
	round(cast(count(TYPE) as float)/cast(datediff(day, '2020-03-18', '2020-04-01') as float)*31, 2) as Predicted_Incident
from
	(SELECT *
	FROM dbo.crimedata_csv_all_years$
	WHERE HUNDRED_BLOCK IS NOT NULL AND NEIGHBOURHOOD IS NOT NULL AND X IS NOT NULL AND Y IS NOT NULL AND FULL_DATE >= '2020-03-18') nonull_prior
where TYPE NOT LIKE '%Vehicle%' AND TYPE NOT LIKE '%Bicycle%' AND YEAR(FULL_DATE) = 2020 AND MONTH(FULL_DATE) = 3
group by TYPE, YEAR, MONTH
order by TYPE, YEAR, MONTH


--       ############        --
--         pre-code          --
--       ############        --
DECLARE @d DATETIME = '2020-03-18 00:00:00';
SELECT 
   DATEPART(day, @d) day

select FULL_DATE
from dbo.crimedata_csv_all_years$
where FULL_DATE >= '2020-03-18'
order by FULL_DATE

SELECT DATEDIFF(day, '2020-03-18', '2020-04-01') AS DateDif;
SELECT DATEDIFF(DAY, 2020-18-03, 2020-01-03)      AS 'DateDif'

select
	count(distinct YEAR)
from dbo.crimedata_csv_all_years$
where FULL_DATE <= '2020-03-17'

select
	count(distinct DAY)
from dbo.crimedata_csv_all_years$
where YEAR = 2020 AND MONTH = 3 AND FULL_DATE <= '2020-03-17'

select
	MAX(FULL_DATE)
from
	(SELECT *
	FROM dbo.crimedata_csv_all_years$
	WHERE HUNDRED_BLOCK IS NOT NULL AND NEIGHBOURHOOD IS NOT NULL AND X IS NOT NULL AND Y IS NOT NULL AND FULL_DATE <= '2020-03-17') none

SELECT MAX(FULL_DATE)
FROM dbo.crimedata_csv_all_years$
WHERE X IS NOT NULL AND FULL_DATE <= '2020-03-17'
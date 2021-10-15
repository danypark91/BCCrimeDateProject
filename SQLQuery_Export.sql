-- Export to Excel
-- Changes made: Central Business District -> Downtown
-- Selected rows without NULL
-- Ignore Musqueam and Stanley Park Neighbourhood
SELECT *
FROM dbo.crimedata_csv_all_years$
WHERE NEIGHBOURHOOD NOT LIKE 'Musqueam'
	AND NEIGHBOURHOOD NOT LIKE 'Stanley Park'
	AND 
	(
	NEIGHBOURHOOD IS NOT NULL 
	OR HUNDRED_BLOCK IS NOT NULL 
	OR X IS NOT NULL 
	OR Y IS NOT NULL
	)
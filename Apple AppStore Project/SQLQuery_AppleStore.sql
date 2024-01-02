/* EXPLORATORY DATA ANALYSIS*/

-- Check the number of unique apps 

USE AppleStoreProject
SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM dbo.AppleStore;

-- Check for any missing values in key fields

SELECT COUNT(*) AS MissingValues
FROM dbo.AppleStore
WHERE track_name IS null OR user_rating IS null OR prime_genre IS null

--Find out the number of apps per category

SELECT prime_genre, COUNT(*) AS NumAPPS
FROM dbo.AppleStore
GROUP BY prime_genre
ORDER By NumAPPS DESC

--Get an Overview of the app ratings


SELECT min(user_rating) AS MinRating,
	   max(user_rating) AS MaxRating,
	   avg(user_rating) AS AvgRating
FROM dbo.Applestore

/**DATA ANALYSIS**/

--Determine whether paid apps have higher ratings than free apps

WITH AppTypes AS (
    SELECT *, CASE
                WHEN price > 0 THEN 'Paid'
                ELSE 'Free'
            END AS App_Type
    FROM dbo.AppleStore
)
SELECT App_Type, avg(user_rating) AS Avg_Rating
FROM AppTypes
GROUP BY App_Type

--Check if apps with more supported languages have higher ratings

WITH Languages AS (
	SELECT *,CASE
				WHEN lang_num < 10 THEN '<10 languages'
				WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
				ELSE '>30 languages'
			END AS Language_Bucket
	FROM dbo.AppleStore
)
SELECT Language_Bucket,	avg(user_rating) AS Average_Rating
FROM Languages
GROUP BY Language_Bucket
ORDER BY Average_Rating DESC

--Check genres with low ratings

SELECT TOP 25 prime_genre,
	   avg(user_rating) AS Average_Rating
FROM dbo.AppleStore
GROUP BY prime_genre
ORDER BY Average_Rating ASC

--Check if there is correlation between the length of the app and the user rating

WITH DescriptionLength AS (
	SELECT a.id,
		   b.app_desc,	
		   CASE
				WHEN len(b.app_desc) < 500 THEN 'Short'
				WHEN len(b.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
				ELSE 'Long'
			END AS Description_Length_Bucket
FROM 
	AppleStore AS a
JOIN
	appleStore_description AS b
ON
	a.id = b.id
)
SELECT DescriptionLength.Description_Length_Bucket, avg(AppleStore.user_rating) AS Average_Rating
FROM DescriptionLength
JOIN AppleStore
ON DescriptionLength.id = AppleStore.id  
GROUP BY DescriptionLength.Description_Length_Bucket
ORDER BY Average_Rating DESC;

--Check the top-rated apps for each genre

SELECT
	prime_genre,
	track_name,
	user_rating
FROM (
	   SELECT
	   prime_genre,
	   track_name,
	   user_rating,
	   RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
	   FROM
	   dbo.AppleStore
	  ) AS a
WHERE
a.rank = 1


SELECT * FROM dbo.appleStore_description

SELECT rating_count_tot  FROM dbo.AppleStore
Use openclassroom


-- get number of fans over time period
SELECT Date,sum(NumberOfFans)
FROM FanPerCity
GROUP BY Date
ORDER BY Date ASC;

-- get dailypostreach and dailynewlikes over time period
SELECT Date, SUM(DailyPostsReach) AS DailyPostsReachTotal, SUM(NewLikes) AS DailyNewLikesTotal
FROM GlobalPage
GROUP BY Date
ORDER BY Date ASC;

-- get top 10 countries in terms of number of fans
SELECT CountryName,SUM(NumberofFans) as NumberOfTansTotal
FROM FanPerCountry
INNER JOIN PopStats ON FanPerCountry.CountryCode = PopStats.CountryCode
GROUP BY CountryName
ORDER BY NumberOfTansTotal DESC
OFFSET 10 ROWS
FETCH NEXT 10 ROWS ONLY;

-- get top 10 countries in terms of penetration ratios(fans vs population)
SELECT PopStats.CountryName,SUM(NumberofFans) as NumberOfFansTotal, Population,SUM(NumberofFans)/Population*100 AS PenetrationRatio
FROM FanPerCity
INNER JOIN PopStats ON FanPerCity.CountryCode = PopStats.CountryCode
GROUP BY PopStats.CountryName, Population
ORDER BY PenetrationRatio DESC
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY;

-- 10 cities with lowest number of fans, among countries population over 20mil
SELECT SUM(FanPerCity.NumberOfFans), FanPerCity.City
FROM PopStats
INNER JOIN FanPerCity ON FanPerCity.CountryCode = PopStats.CountryCode
WHERE PopStats.Population>20000000
GROUP BY FanPerCity.City
ORDER BY SUM(FanPerCity.NumberOfFans) ASC;

-- analysis on age group of fans
SELECT AgeGroup,SUM(NumberOfFans)
FROM FanPerGenderAge
GROUP BY AgeGroup;

-- analysis on gender of fans 
SELECT Gender, SUM(NumberOfFans)
FROM FanPerGenderAge
GROUP BY Gender;

-- analysis on lanauge variety of fans - english speaking popluation and percentage
SELECT Language, SUM(NumberOfFans) as NumberofFansTotal, SUM(NumberOfFans)*100/ (select SUM(NumberOfFans) from FanPerLanguage) As LanaugePercentage
FROM FanPerLanguage
WHERE Language = 'en'
GROUP BY Language;

-- english speaking population living in US and their potential market potential based on average income
SELECT AVG(AverageIncome) AS Avgincome,PopStats.CountryName,Language, SUM(FanPerLanguage.NumberOfFans) as NumberofFansTotal, SUM(FanPerLanguage.NumberOfFans)*100/ (select SUM(NumberOfFans) from FanPerLanguage) As LanaugePercentage
FROM FanPerLanguage
INNER Join PopStats ON FanPerLanguage.CountryCode=PopStats.CountryCode
WHERE Language = 'en' 
GROUP BY Language, PopStats.CountryName;

-- analysis on engagement of the week
WITH CTE AS
(SELECT CreatedTime, 
  SUM(EngagedFans)/SUM(Reach) AS EngagementRatio,
  FORMAT(CreatedTime, 'dddd') AS DayofWeek
  FROM PostInsights
  GROUP BY CreatedTime)
 SELECT DayofWeek, SUM(EngagementRatio) as EngagementRatioTotal
 FROM CTE
 GROUP BY DayofWeek
 ORDER BY
 CASE
          WHEN DayofWeek = 'Monday' THEN 1
          WHEN DayofWeek = 'Tuesday' THEN 2
          WHEN DayofWeek = 'Wednesday' THEN 3
          WHEN DayofWeek = 'Thursday' THEN 4
          WHEN DayofWeek = 'Friday' THEN 5
          WHEN DayofWeek = 'Saturday' THEN 6
		  WHEN DayofWeek = 'Sunday' THEN 7
     END ASC;

-- analysis on engagement ratio based on time group

;WITH cte AS
(
    SELECT FORMAT(CreatedTime, 'hh:mm') AS Hourminute, EngagedFans,Reach
    FROM PostInsights
), 
cte2 AS
(
   SELECT CASE WHEN Hourminute >= '05:00' AND Hourminute <= '08:59' THEN '05:00 - 08:59'
    WHEN Hourminute >= '09:00' AND Hourminute <= '11:59' THEN '09:00 -11:59'
    WHEN Hourminute >= '12:00' AND Hourminute <= '14:59' THEN '12:00 - 14:59'
    WHEN Hourminute >= '15:00' AND Hourminute <= '18:59' THEN '15:00 - 18:59'
    WHEN Hourminute >= '19:00' AND Hourminute <= '21:59' THEN '19:00 - 21:59'
    ELSE '22:00 or later' END AS TimeInterval,
	EngagedFans,
	Reach
    FROM cte
)
SELECT TimeInterval, SUM(EngagedFans) AS EngagedFansTotal,SUM(Reach) AS ReachTotal
FROM cte2
GROUP BY TimeInterval ;



 SELECT FORMAT(CreatedTime, 'hh:mm') AS Hourminute, EngagedFans,Reach,CreatedTime
 FROM PostInsights

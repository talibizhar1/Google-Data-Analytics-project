/****** Google-Capstone-Data-Analytics-prject  ******/

/*While importing the file I changed the data type of station id from int to varchar as some file had alpha-numeric id while other integer*/

/*First I joined all the 12 month files from April-2022 to  March-2021*/

USE Cyclistics
GO
SELECT * INTO Combined_table FROM [Cyclistics].[dbo].[202004-divvy-tripdata]
  UNION ALL 
  SELECT * FROM [Cyclistics].[dbo].[202005-divvy-tripdata]
  UNION ALL 
   SELECT * FROM [Cyclistics].[dbo].[202006-divvy-tripdata]
 UNION ALL 
   SELECT * FROM [Cyclistics].[dbo].[202007-divvy-tripdata]
 UNION ALL 
   SELECT * FROM [Cyclistics].[dbo].[202008-divvy-tripdata]
 UNION ALL 
   SELECT * FROM [Cyclistics].[dbo].[202009-divvy-tripdata] 
 UNION ALL 
   SELECT * FROM [Cyclistics].[dbo].[202010-divvy-tripdata]
 UNION ALL 
   SELECT * FROM [Cyclistics].[dbo].[202011-divvy-tripdata]
 UNION ALL 
   SELECT * FROM [Cyclistics].[dbo].[202012-divvy-tripdata]
 UNION ALL 
   SELECT * FROM [Cyclistics].[dbo].[202101-divvy-tripdata]
 UNION ALL 
   SELECT * FROM [Cyclistics].[dbo].[202102-divvy-tripdata]
 UNION ALL 
   SELECT * FROM [Cyclistics].[dbo].[202103-divvy-tripdata]

/*checking data*/
   SELECT * FROM   [Cyclistics].[dbo].Combined_table
 
 /*count number of rows result 3489748 */
  SELECT COUNT(*) FROM  [Cyclistics].[dbo].Combined_table
 /*checking null values*/
 SELECT rideable_type,count(*)
FROM  [Cyclistics].[dbo].Combined_table
WHERE start_station_name  IS NULL
 OR end_station_name IS NULL
 GROUP BY rideable_type;

 /*checking distinct values of member_casual column*/
 SELECT DISTINCT(member_casual) FROM  [Cyclistics].[dbo].Combined_table 
 /*only 2 types member & casual*/
 
 /*check duplicates*/
 SELECT  COUNT(DISTINCT ride_id) FROM  [Cyclistics].[dbo].Combined_table 
 /*result 3489539  it means duplicate present*/

 /*checking duplicate rows*/
 SELECT ride_id, COUNT(ride_id)
FROM [Cyclistics].[dbo].Combined_table
GROUP BY ride_id
HAVING COUNT(ride_id) > 1

/*checking if all rows are same & it looked liked they are so i decided to delete these rows*/
select * from [Cyclistics].[dbo].Combined_table where ride_id = 'E3BA43F13E5D2B60' OR
ride_id ='6026FEA994087456'


/*Deleting duplicate rows*/
With cte as (SELECT  ride_id, row_number()
Over (PARTITION BY ride_id order by ride_id) as counts
From [Cyclistics].[dbo].Combined_table)
Select * from CTE where counts >1 order by ride_id;

/*delete statement*/
WITH cte AS (SELECT ride_id, ROW_NUMBER()
OVER ( PARTITION BY ride_id ORDER BY  ride_id) AS counts
FROM [Cyclistics].[dbo].Combined_table)
DELETE FROM cte
WHERE counts > 1;

/*checking start&end station names*/
SELECT  * 
FROM  [Cyclistics].[dbo].Combined_table
WHERE 
start_station_name IS NULL 
OR end_station_name IS NULL


/*Deleting these rows*/
DELETE FROM  [Cyclistics].[dbo].Combined_table
WHERE start_station_name IS NULL 
OR end_station_name IS NULL

/*checking rows count again*/
SELECT count(*) FROM [Cyclistics].[dbo].Combined_table
##result 3489539 rows ##

/*Checking Null_values in started & ended column*/
SELECT  * 
FROM  [Cyclistics].[dbo].Combined_table
WHERE  
started_at IS NULL
OR ended_at IS NULL
##there is no null values##



/*check_if_trimming_is_required_in_station_names*/
SELECT ended_at,started_at
FROM  [Cyclistics].[dbo].Combined_table
WHERE ended_at LIKE ' ' OR
started_at LIKE ' '
/*No whitespace hence trimming not required*/

/////****CREATING COLUMNS FOR ANALYSIS****/////

/*creating a ride_length column*/
SELECT member_casual,started_at, ended_at, DATEDIFF(MINUTE,started_at,ended_at) FROM  [Cyclistics].[dbo].Combined_table
WHERE  DATEDIFF(MINUTE,started_at,ended_at)<=1
AND  DATEDIFF(MINUTE,started_at,ended_at) >= 1440 
GROUP BY member_casual,started_at, ended_at


ALTER TABLE [Cyclistics].[dbo].Combined_table
  ADD ride_length int 
UPDATE [Cyclistics].[dbo].Combined_table
SET ride_length =  DATEDIFF(MINUTE,started_at,ended_at)
WHERE DATEDIFF(MINUTE,started_at,ended_at)>=1
AND  DATEDIFF(MINUTE,started_at,ended_at) <= 1440  ;

/*deleting rows less than 1 & greater than 1440*/
select count(*) from [Cyclistics].[dbo].Combined_table ##3489539 rows ##
DELETE FROM [Cyclistics].[dbo].Combined_table
WHERE ride_length IS NULL ;


/*Counting rows after cleaning*/
SELECT COUNT(*) FROM  [Cyclistics].[dbo].Combined_table

/*Creating Weekday column*/
ALTER TABLE [Cyclistics].[dbo].Combined_table
  ADD week_day varchar(10) 
UPDATE  [Cyclistics].[dbo].Combined_table
SET week_day = CASE DATEPART(WEEKDAY,started_at)  
    WHEN 1 THEN 'SUNDAY' 
    WHEN 2 THEN 'MONDAY' 
    WHEN 3 THEN 'TUESDAY' 
    WHEN 4 THEN 'WEDNESDAY' 
    WHEN 5 THEN 'THURSDAY' 
    WHEN 6 THEN 'FRIDAY' 
    WHEN 7 THEN 'SATURDAY' 
END

select week_day from  [Cyclistics].[dbo].Combined_table
/*Creating month column*/
ALTER TABLE [Cyclistics].[dbo].Combined_table
  ADD months varchar(10) 
UPDATE  [Cyclistics].[dbo].Combined_table
SET months = CASE DATEPART(MONTH,started_at)
         WHEN  1 THEN 'January'
         WHEN  2 THEN 'February'
         WHEN  3 THEN 'March'
         WHEN  4 THEN 'April'
         WHEN  5 THEN 'May'
         WHEN  6 THEN 'June'
         WHEN  7 THEN 'July'
         WHEN  8 THEN 'August'
         WHEN  9 THEN 'September'
         WHEN  10 THEN 'October'
         WHEN  11 THEN 'November'
         WHEN  12 THEN 'December'
      END 
/*season_column*/
ALTER TABLE [Cyclistics].[dbo].Combined_table
ADD Season varchar(15)
UPDATE  [Cyclistics].[dbo].Combined_table
SET Season = CASE months 
          WHEN  'January' THEN 'Winter'
         WHEN  'February' THEN 'Winter'
         WHEN  'March' THEN 'Spring'
         WHEN  'April' THEN 'Spring'
         WHEN  'May' THEN 'Spring'
         WHEN  'June' THEN 'Summer'
         WHEN  'July' THEN 'Summer'
         WHEN  'August' THEN 'Summer'
         WHEN  'September' THEN 'Autumn'
         WHEN  'October' THEN 'Autumn'
         WHEN  'November' THEN 'Autumn'
         WHEN  'December' THEN 'Winter'
      END 

	  /*temp table of time_of_day*/
SELECT member_casual,count(*) AS ride_count,
 CASE DATEPART(HOUR,started_at)  
    WHEN 0 THEN '12 AM'    
    WHEN 1 THEN '1 AM' 
    WHEN 2 THEN '2 AM' 
    WHEN 3 THEN '3 AM' 
    WHEN 4 THEN '4 AM' 
    WHEN 5 THEN '5 AM' 
    WHEN 6 THEN '6 AM' 
	WHEN 7 THEN '7 AM' 
	WHEN 8 THEN '8 AM'
	WHEN 9 THEN '9 AM'
	WHEN 10 THEN '10 AM'
	WHEN 11 THEN '11 AM'
	WHEN 12 THEN '12 PM'
	WHEN 13 THEN '1 PM'
	WHEN 14 THEN '2 PM'
	WHEN 15 THEN '3 PM'
	WHEN 16 THEN '4 PM'
	WHEN 17 THEN '5 PM'
	WHEN 18 THEN '6 PM'
	WHEN 19 THEN '7 PM'
	WHEN 20 THEN '8 PM'
	WHEN 21 THEN '9 PM'
	WHEN 22 THEN '10 PM'
	WHEN 23 THEN '11 PM'
END AS Time_of_day
FROM [Cyclistics].[dbo].Combined_table
GROUP BY member_casual,DATEPART(HOUR,started_at) 

/**Sorting, aggregating columns for further analysis and visualization**/

 /*Num of rides by weekday*/
SELECT member_casual, week_day, count(*) AS number_of_rides
FROM  [Cyclistics].[dbo].Combined_table
GROUP BY member_casual,week_day


/*avg ride_length by weekday*/
SELECT member_casual,started_at, week_day, AVG(ride_length) AS avg_ride_length
FROM  [Cyclistics].[dbo].Combined_table
GROUP BY member_casual,week_day,started_at
ORDER BY week_day 

/*rides by season*/
SELECT member_casual, season, count(ride_id) AS num_of_rides2
FROM  [Cyclistics].[dbo].Combined_table
GROUP BY member_casual,season
ORDER BY season 

/*ride length by season*/
SELECT member_casual, Season, AVG(ride_length) AS avg_ride_length
FROM  [Cyclistics].[dbo].Combined_table
GROUP BY member_casual,Season
ORDER BY Season 

/*month wise count*/
SELECT member_casual, months, count(ride_id) AS num_of_rides2
FROM  [Cyclistics].[dbo].Combined_table
GROUP BY member_casual,months
ORDER BY months 

/*month wise ride_length*/
SELECT member_casual, months, AVG(ride_length) AS avg_ride_length
FROM  [Cyclistics].[dbo].Combined_table
GROUP BY member_casual,months
ORDER BY months

/*Mean_ride_length by users*/
SELECT member_casual, AVG(ride_length) as avg_ride_length
FROM [Cyclistics].[dbo].Combined_table
GROUP BY member_casual;


/*Ride Count by users*/
SELECT member_casual, count(*) as Num_of_Rides
FROM [Cyclistics].[dbo].Combined_table
GROUP BY member_casual;

/*type of ride by members*/
SELECT rideable_type, member_casual, count(*) AS amount_of_rides
   FROM [Cyclistics].[dbo].Combined_table
   GROUP BY rideable_type, member_casual
   ORDER BY member_casual, amount_of_rides DESC

/*rides count per hour*/
SELECT member_casual, DATEPART(HOUR,  started_at) time_of_day, count(*) AS rides
   FROM [Cyclistics].[dbo].Combined_table
   GROUP BY member_casual, DATEPART(HOUR,started_at)
   ORDER BY DATEPART(HOUR,started_at) 


/*ride length per hour*/
   SELECT member_casual, DATEPART(HOUR,  started_at) time_of_day, AVG(ride_length) AS rides
   FROM [Cyclistics].[dbo].Combined_table
   GROUP BY member_casual, DATEPART(HOUR,started_at)
   ORDER BY DATEPART(HOUR,started_at) 

/*counts of rides by start_station_name*/
 SELECT start_station_name, member_casual,  
      count(*) AS count_of_rides
   FROM [Cyclistics].[dbo].Combined_table  
   GROUP BY start_station_name, member_casual
   ORDER BY start_station_name
 
 /*counts of rides by end_station_name*/
   SELECT end_station_name, member_casual,  
      count(*) AS count_of_rides
   FROM [Cyclistics].[dbo].Combined_table  
   GROUP BY end_station_name, member_casual
   ORDER BY end_station_name

  


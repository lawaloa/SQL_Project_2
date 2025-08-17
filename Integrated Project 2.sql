/*Ok, bring up the employee table. It has info on all of our workers, but note that the email addresses have not been added. We will have to send
them reports and figures, so let's update it. Luckily the emails for our department are easy: first_name.last_name@ndogowater.gov.*/

-- Replace the space with a full stop; Make it all lower case; Add it together

SELECT
	CONCAT(
	LOWER(REPLACE(employee_name, '','.')), '@ndogowater.gov') AS new_email
FROM
	md_water_services.employee;
    
SET SQL_SAFE_UPDATES = 0;
    
UPDATE md_water_services.employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),

'@ndogowater.gov');

/*I picked up another bit we have to clean up. Often when databases are created and updated, or information is collected from different sources,
errors creep in. For example, if you look at the phone numbers in the phone_number column, the values are stored as strings. The phone numbers should be 12 characters long, consisting of the plus sign, area code (99), and the phone number digits. However, when we use
the LENGTH(column) function, it returns 13 characters, indicating there's an extra character.*/

SELECT
	length(phone_number)
FROM
md_water_services.employee;

/*Use TRIM() to write a SELECT query again, make sure we get the string without the space, and then UPDATE the record like you just did for the
emails. If you need more information about TRIM(), Google "TRIM documentation MySQL".*/

UPDATE md_water_services.employee
SET phone_number = TRIM(phone_number);

/*Use the employee table to count how many of our employees live in each town. Think carefully about what function we should use and how we
should aggregate the data.*/

SELECT
	town_name,
   COUNT(town_name) AS num_of_employees
FROM
	md_water_services.employee
GROUP BY town_name;

/*Pres. Naledi has asked we send out an email or message congratulating the top 3 field surveyors. So let's use the database to get the
employee_ids and use those to get the names, email and phone numbers of the three field surveyors with the most location visits.*/

SELECT
	assigned_employee_id,
    COUNT(visit_count) AS num_of_visits
FROM md_water_services.visits
GROUP BY assigned_employee_id
ORDER BY num_of_visits DESC
LIMIT 3;

-- Using the results of above query to retrieve the info of the 3 best field surveyors

SELECT
	assigned_employee_id,
	employee_name,
    phone_number,
    email
FROM md_water_services.employee
WHERE assigned_employee_id IN (1, 30, 34);

/*Analysing locations. Looking at the location table, let’s focus on the province_name, town_name and location_type to understand where the water sources are in
Maji Ndogo.*/

-- Create a query that counts the number of records per town

SELECT
	COUNT(town_name) AS records_per_town,
    town_name
FROM md_water_services.location
GROUP BY town_name
ORDER BY records_per_town DESC;

-- Records per province

SELECT
	COUNT(province_name) AS records_per_province,
    province_name
FROM md_water_services.location
GROUP BY province_name
ORDER BY records_per_province DESC;


/*Can you find a way to do the following:
1. Create a result set showing:
• province_name
• town_name
• An aggregated count of records for each town (consider naming this records_per_town).
• Ensure your data is grouped by both province_name and town_name.
2. Order your results primarily by province_name. Within each province, further sort the towns by their record counts in descending order.*/

SELECT
    province_name,
    town_name,
    COUNT(town_name) AS records_per_town
FROM
    md_water_services.location
GROUP BY
    province_name,
    town_name
ORDER BY
    province_name ASC,
    records_per_town DESC;


-- Finally, look at the number of records for each location type

SELECT
	COUNT(location_type) AS num_sources,
    location_type
FROM md_water_services.location
GROUP BY location_type;

/*The way I look at this table; we have access to different water source types and the number of people using each source.
These are the questions that I am curious about.
1. How many people did we survey in total?
2. How many wells, taps and rivers are there?
3. How many people share particular types of water sources on average?
4. How many people are getting water from each type of source?*/

-- 1
SELECT 
	SUM(number_of_people_served) AS num_of_surveyed
FROM md_water_services.water_source;

-- 2. Count how many of each of the different water source types there are, and remember to sort them.

SELECT
	type_of_water_source,
    COUNT(type_of_water_source) AS num_of_source
FROM
	md_water_services.water_source
GROUP BY
	type_of_water_source
ORDER BY num_of_source DESC;

-- Question 3: What is the average number of people that are served by each water source?

SELECT 
	type_of_water_source,
	ROUND(AVG(number_of_people_served)) AS avg_served_per_source
FROM md_water_services.water_source
GROUP BY type_of_water_source;

/* 4. Calculate the total number of people served by each type of water source in total, to make it easier to interpret, order them so the most
people served by a source is at the top.*/

SELECT 
    type_of_water_source,
    SUM(number_of_people_served) AS Total_served_per_source,
    ROUND((SUM(number_of_people_served) * 100.0 / 
        (SELECT SUM(number_of_people_served) FROM md_water_services.water_source))
    ) AS Pct_served_per_source
FROM 
    md_water_services.water_source
GROUP BY 
    type_of_water_source;
    
-- So use a window function on the total people served column, converting it into a rank.

SELECT
    type_of_water_source,
    SUM(number_of_people_served) AS Total_served_per_source,
    RANK() OVER (
        ORDER BY SUM(number_of_people_served) DESC
    ) AS Rank_by_population
FROM 
    md_water_services.water_source
GROUP BY 
    type_of_water_source;
    
/*So create a query to do this, and keep these requirements in mind:
1. The sources within each type should be assigned a rank.
2. Limit the results to only improvable sources.
3. Think about how to partition, filter and order the results set.
4. Order the results to see the top of the list.*/

SELECT
	source_id,
    type_of_water_source,
    number_of_people_served,
    RANK() OVER (
        ORDER BY number_of_people_served DESC
    ) AS priority_rank
FROM 
    md_water_services.water_source;
    
-- Using DENSE_RANK

SELECT
	source_id,
    type_of_water_source,
    number_of_people_served,
	DENSE_RANK() OVER (
        ORDER BY number_of_people_served DESC
    ) AS priority_rank
FROM 
    md_water_services.water_source;
    
-- Using ROW_NUMBER

SELECT
	source_id,
    type_of_water_source,
    number_of_people_served,
    ROW_NUMBER() OVER (
        ORDER BY number_of_people_served DESC
    ) AS priority_rank
FROM 
    md_water_services.water_source;
    
/*Ok, these are some of the things I think are worth looking at:
1. How long did the survey take?
2. What is the average total queue time for water?
3. What is the average queue time on different days?
4. How can we communicate this information efficiently?*/

/*Question 1:
To calculate how long the survey took, we need to get the first and last dates (which functions can find the largest/smallest value), and subtract
them. Remember with DateTime data, we can't just subtract the values. We have to use a function to get the difference in days.*/

SELECT 
    DATEDIFF(MAX(time_of_record), MIN(time_of_record)) AS survey_duration_days
FROM 
    md_water_services.visits;
    
/*Question 2:
Let's see how long people have to queue on average in Maji Ndogo. Keep in mind that many sources like taps_in_home have no queues. These
are just recorded as 0 in the time_in_queue column, so when we calculate averages, we need to exclude those rows. Try using NULLIF() do to
this.*/

SELECT
    AVG(NULLIF(time_in_queue, 0)) AS avg_time_in_queue
FROM
    md_water_services.visits;
    
/*Question 3:
So let's look at the queue times aggregated across the different days of the week.*/

SELECT 
	DAYNAME(time_of_record) AS day_of_week,
    ROUND(AVG(time_in_queue)) AS avg_queue_time
FROM 
    visits
WHERE 
    time_in_queue != 0
    AND time_in_queue IS NOT NULL
GROUP BY 
    day_of_week;
    
/*Question 4:
We can also look at what time during the day people collect water. Try to order the results in a meaningful way.*/

SELECT 
	TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
    ROUND(AVG(time_in_queue)) AS avg_queue_time
FROM 
    visits
GROUP BY 
    hour_of_day;
    
    /*Can you see that mornings and evenings are the busiest? It looks like people collect water before and after work. Wouldn't it be nice to break down
the queue times for each hour of each day? In a spreadsheet, we can just create a pivot table.
Pivot tables are not widely used in SQL, despite being useful for interpreting results. So there are no built-in functions to do this for us. Sometimes
the dataset is just so massive that it is the only option.

To filter a row we use WHERE, but using CASE() in SELECT can filter columns. We can use a CASE() function for each day to separate the queue
time column into a column for each day. Let’s begin by only focusing on Sunday. So, when a row's DAYNAME(time_of_record) is Sunday, we
make that value equal to time_in_queue, and NULL for any days.*/

SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- Sunday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END
),0) AS Sunday,
-- Monday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
ELSE NULL
END
),0) AS Monday,
-- Tuesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
ELSE NULL
END
), 0) AS Tuesday,
-- Wednesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
ELSE NULL
END
),0) AS Wednesday,
-- Thursday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
ELSE NULL
END
),0) AS Thursday,
-- Friday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
ELSE NULL
END
),0) AS Friday,
-- Saturday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
ELSE NULL
END
),0) AS Saturday
FROM
visits
WHERE
time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
hour_of_day
ORDER BY
hour_of_day;

/*See if you can spot these patterns:
1. Queues are very long on a Monday morning and Monday evening as people rush to get water.
2. Wednesday has the lowest queue times, but long queues on Wednesday evening.
3. People have to queue pretty much twice as long on Saturdays compared to the weekdays. It looks like people spend their Saturdays queueing
for water, perhaps for the week's supply?
4. The shortest queues are on Sundays, and this is a cultural thing. The people of Maji Ndogo prioritise family and religion, so Sundays are spent
with family and friends.*/

-- TEST

SELECT
	assigned_employee_id,
    COUNT(visit_count) AS num_of_visits
FROM md_water_services.visits
GROUP BY assigned_employee_id
ORDER BY num_of_visits ASC
LIMIT 3;

-- Using the results of above query to retrieve the info of the 3 worst field surveyors

SELECT
	assigned_employee_id,
	employee_name,
    phone_number,
    email
FROM md_water_services.employee
WHERE assigned_employee_id IN (20, 22, 44);

-- How many employees live in Harare, Kilimani? Modify one of your queries from the project to answer this question.
SELECT
	DISTINCT(town_name),
	province_name,
   COUNT(province_name) OVER (PARTITION BY town_name)AS num_of_employees
FROM
	md_water_services.employee;

/*Consider the query we used to calculate the total number of people served:

SELECT
SUM(number_of_people_served) AS population_served
FROM
water_source
ORDER BY
population_served

The following lines of code will calculate the total number of people using some sort of tap*/
SELECT
    SUM(number_of_people_served) AS population_served
FROM
    water_source
WHERE
    type_of_water_source LIKE '%tap%';
    

/*Use the pivot table we created to answer the following question. What are the average queue times for the following times?

Saturday from 12:00 to 13:00
Tuesday from 18:00 to 19:00
Sunday from 09:00 to 10:00*/
SELECT 
    DAYNAME(time_of_record) AS day_of_week,
    TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
    ROUND(AVG(time_in_queue), 0) AS avg_queue_time
FROM 
    visits
WHERE 
    time_in_queue != 0
    AND (
        (DAYNAME(time_of_record) = 'Saturday' AND TIME(time_of_record) >= '12:00:00' AND TIME(time_of_record) < '13:00:00') OR
        (DAYNAME(time_of_record) = 'Tuesday' AND TIME(time_of_record) >= '18:00:00' AND TIME(time_of_record) < '19:00:00') OR
        (DAYNAME(time_of_record) = 'Sunday' AND TIME(time_of_record) >= '09:00:00' AND TIME(time_of_record) < '10:00:00')
    )
GROUP BY 
    day_of_week, hour_of_day
ORDER BY 
    day_of_week, hour_of_day;

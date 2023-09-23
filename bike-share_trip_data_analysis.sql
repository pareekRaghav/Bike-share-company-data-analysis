-- Combined all 6 months datasets into a single dataset for comprehensive analysis 
create table complete_trip_data_2023 as(
	select * from trip_data_202301
	union
	select * from trip_data_202302
	union
	select * from trip_data_202303
	union
	select * from trip_data_202304
	union
	select * from trip_data_202305
	union
	select * from trip_data_202306
)

--Checking first 100 rows of the new table
select * from complete_trip_data_2023
order by started_at
limit 100;

--Creating a view with a new column of start date weekday
create view start_weekday_trip_data as
(select 
	ride_id, rideable_type, to_char(started_at, 'Day') as start_weekday, member_casual 
from
	complete_trip_data_2023)

--Which day of the week do casual riders take the most trips
select 
	start_weekday, count(start_weekday) as number_of_trips
from 
	start_weekday_trip_data
where member_casual = 'casual'
group by start_weekday
order by number_of_trips

--Which day of the week do member riders take the most trips
select 
	start_weekday, count(start_weekday) as number_of_trips
from 
	start_weekday_trip_data
where member_casual = 'member'
group by start_weekday
order by number_of_trips

--Which rideable_type do casual riders prefer the most
select 
	rideable_type, count(member_casual) as number_of_trips
from 
	complete_trip_data_2023
where member_casual = 'casual'
group by rideable_type
order by number_of_trips

--Which rideable_type do member riders prefer the most
select 
	rideable_type, count(member_casual) as number_of_trips
from 
	complete_trip_data_2023
where member_casual = 'member'
group by rideable_type
order by number_of_trips

--Total trips done by member and casual riders
select 
	member_casual, count(member_casual) as num_of_trips, 
	sum(count(member_casual))over() as total_trips,
	cast((count(member_casual)/sum(count(member_casual))over())*100 as decimal(4,2)) percentage_of_total_trips
from 
	complete_trip_data_2023
group by member_casual;

select * from complete_trip_data_2023 limit 100;

--Average duration of trips taken by riders
select 
	member_casual, to_char(avg(ended_at-started_at),'MI:SS') as Average_trip_duration
from 
	complete_trip_data_2023
group by
	member_casual;



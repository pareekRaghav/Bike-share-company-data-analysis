# Loading relevant packages 

library(tidyverse)
library(skimr)
library(janitor)

# importing data of first half of 2023 into various data frames

trip_data_202301 <- read_csv("202301-divvy-tripdata.csv")
trip_data_202302 <- read_csv("202302-divvy-tripdata.csv")
trip_data_202303 <- read_csv("202303-divvy-tripdata.csv")
trip_data_202304 <- read_csv("202304-divvy-tripdata.csv")
trip_data_202305 <- read_csv("202305-divvy-tripdata.csv")
trip_data_202306 <- read_csv("202306-divvy-tripdata.csv")

View(trip_data_202301)

# Data cleaning and manipulation

# combining multiple data frames into single data frame

combined_trip_data_2023 <- rbind(trip_data_202301,trip_data_202302, trip_data_202303, trip_data_202304, trip_data_202305, trip_data_202306)

# ordering complete_trip_data using started_at column

combined_trip_data_2023<- combined_trip_data_2023 %>% 
  arrange(started_at)

# Checking for null values in member_casual column

View(combined_trip_data_2023 %>% 
  select(member_casual) %>% 
  filter(is.na(member_casual)))

# creating a data frame for analysis with ride_id, rideable_type, started_at, ended_at and member_casual columns
# Filtered out rows where ended_at is less than or equal to the started_at

relevant_trip_data <- combined_trip_data_2023 %>% 
  select(ride_id, rideable_type, started_at, ended_at, member_casual) %>% 
  filter(ended_at > started_at)

# creating a new column for calculating bike ride duration

relevant_trip_data <- relevant_trip_data %>% 
  mutate(ride_duration = NULL, ride_duration_in_mins= as.numeric(round((ended_at-started_at)/60,2)))

# Creating a new column for storing the weekday of started_at column

relevant_trip_data <- relevant_trip_data %>% 
  mutate(start_weekday = weekdays(started_at))

# Data Analysis

# Number of rides and average duration of rides taken by each rider type

member_casual_trips <- relevant_trip_data %>% 
  group_by(member_casual) %>% 
  summarize(number_of_trips = n(), average_trip_duration = mean(ride_duration_in_mins))

# Weekday wise number of rides for casual and member riders

weekday_wise_trips_casual <- relevant_trip_data %>% 
  filter(member_casual == 'casual') %>% 
  group_by(start_weekday) %>%
  summarize(casual_riders_trips = n()) %>% 
  arrange(casual_riders_trips)


weekday_wise_trips_member <- relevant_trip_data %>% 
  filter(member_casual == 'member') %>% 
  group_by(start_weekday) %>%
  summarize(member_riders_trips = n()) %>% 
  arrange(member_riders_trips)
  
merged_weekday_wise_trips <- merge(x= weekday_wise_trips_casual, y=weekday_wise_trips_member, by = "start_weekday" )

# Famous rideable type among riders

rideable_type_trips_casual <- relevant_trip_data %>% 
  filter(member_casual == 'casual') %>% 
  group_by(rideable_type) %>% 
  summarise(casual_riders = n())

rideable_type_trips_member <- relevant_trip_data %>% 
  filter(member_casual == 'member') %>% 
  group_by(rideable_type) %>% 
  summarise(member_trips = n())

merged_rideable_type_preferrence <- merge(x= rideable_type_trips_casual, y=rideable_type_trips_member, by= "rideable_type", all.x = TRUE)


# Data visualization 

ggplot(relevant_trip_data)+
  geom_bar(mapping = aes(x=member_casual, fill = member_casual))+
  labs(title = "Rider type and number of trips")

ggplot(member_casual_trips)+
  geom_count(mapping = aes(x=average_trip_duration, y=number_of_trips, color = member_casual))+
  labs(title = "Average trip duration VS number of trips")

ggplot(relevant_trip_data)+
  geom_bar(mapping = aes(x=rideable_type, fill = rideable_type ))+
  facet_wrap(~member_casual)+
  theme(axis.text.x = element_text(angle = 45))+
  labs(x= "Ride type", y="Number of rides")




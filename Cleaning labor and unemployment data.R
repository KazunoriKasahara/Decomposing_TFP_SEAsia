library(tidyverse)

labor <- read.csv("data/laborforce.csv",skip = 4)
unemployment <- read.csv("data/umemployment.csv",skip = 4)

# subset data only for the countries and periods
index <- c(2,35:62)
countries <- c("MMR","VNM","KHM","LAO")
labor <- select(labor,index) %>%
  filter(unemployment$Country.Code %in% countries)
unemployment <- select(unemployment,index) %>%
  filter(unemployment$Country.Code %in% countries)

# make panel data
# basically transpose the data set and gather it. But t(dataframe) needs some manual fixes for tidy data frame
labor.t <- t(labor)
names <- names(labor)
labor.t2 <- cbind(names,labor.t)
labor.t3 <- as.data.frame(labor.t2)
colnames(labor.t3) <- c("year","KHM","LAO","MMR","VNM")
labor.t4 <- filter(labor.t3,1:nrow(labor.t3) == c(0,2:nrow(labor.t3)))
labor_panel = labor.t4 %>%
  gather(key = country, value = labor, -year)
labor_panel$year <- substr(labor_panel$year,2,5)
labor_panel$year <- as.numeric(labor_panel$year)
labor_panel$labor <- as.numeric(labor_panel$labor)

unemployment.t <- t(unemployment)
names <- names(unemployment)
unemployment.t2 <- cbind(names,unemployment.t)
unemployment.t3 <- as.data.frame(unemployment.t2)
colnames(unemployment.t3) <- c("year","KHM","LAO","MMR","VNM")
unemployment.t4 <- filter(unemployment.t3,1:nrow(unemployment.t3) == c(0,2:nrow(unemployment.t3)))
unemployment_panel = unemployment.t4 %>%
  gather(key = country, value = unemployment, -year)
unemployment_panel$year <- substr(unemployment_panel$year,2,5)
unemployment_panel$year <- as.numeric(unemployment_panel$year)
unemployment_panel$unemployment <- as.numeric(unemployment_panel$unemployment)

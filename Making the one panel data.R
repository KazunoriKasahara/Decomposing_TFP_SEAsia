unemployment <- readRDS("data/unemployment")
labor <- readRDS("data/labor_panel")

GDP <- readxl::read_xlsx("data/GDP_adjustedforinflation_currentUS.xlsx")
names(GDP) <- c('year','country','GDP')
GDP$country <- GDP$country %>% 
  str_replace("CAM","VNM")
GDP$GDP <- as.numeric(GDP$GDP)

capital <- readxl::read_xlsx("data/Actual Capital Stock .xlsx")
names(capital) <- c('year','country','capital')
capital$country <- capital$country %>%
  str_replace_all(c("CAM" = "KHM","LAOPDR" = "LAO","VIETNAM" = "VNM"))

# Now make the one panel data
onepanel <- left_join(GDP,labor) %>%
  left_join(capital) %>%
  left_join(unemployment)
onepanel <- onepanel %>% select(2,1,3,4,5,6)



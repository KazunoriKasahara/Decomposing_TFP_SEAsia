# prepare data
panel <- readxl::read_xlsx('data/PWTdata.xlsx')
panel_efficiency_factor <- readxl::read_xlsx('data/efficiencybreakdown.xlsx')

names(panel_efficiency_factor) <- c('country','year','lngovshare','lntradeshare','lnreer')
names(panel) <- c('country','year',"gdp",'stock','labor')
panel$lngdp <- log(panel$gdp)
panel$lnstock <- log(panel$stock)
panel$lnlabor <- log(panel$labor)

library(plm)
library(frontier)
library(tidyverse)

# execute sfa
panel <-  pdata.frame( panel, c("country","year"))
result_sfa <- sfa(lngdp ~ lnstock + lnlabor, data = panel,timeEffect = TRUE)


# visualize efficiencies
efficiencies <- efficiencies(result_sfa)
efficiencies_df <- as.data.frame(t(efficiencies))
efficiencies_df$year <- rownames(efficiencies_df)
efficiencies_df <- gather(efficiencies_df,key = country, value = efficiency, -year)
efficiencies_df$year <- as.integer(efficiencies_df$year)
ggplot(data = efficiencies_df, aes(year,efficiency,color = country)) + 
  geom_line() + 
  ggtitle("Technical efficiencies by countries")

# explain efficiencies
panel_efficiency_factor <- left_join(panel_efficiency_factor,efficiencies_df,by = c('year','country'))
panel_efficiency_factor <- pdata.frame(panel_efficiency_factor,c('country','year'))

equation <- efficiency ~ lngovshare + lntradeshare + lnreer
model_fixed <- plm(equation,data = panel_efficiency_factor,model = "within",effect = "time")
model_random <- plm(equation,data = panel_efficiency_factor, model = "random",effect = "time")
phtest(model_fixed,model_random)
## H_0: Cov(x_{itj},a_i) = 0 is rejected. Therefore,fixed effect model would be more efficient.
summary(model_fixed)




##################### the code below is not used for the final output


# see TFPC
lnTC <- coef(result_sfa)['time']
## get TEC
KHM_efficiency <- efficiencies_df %>%
  filter(country == 'KHM') 
LAO_efficiency <- efficiencies_df %>%
  filter(country == 'LAO')
VNM_efficiency <- efficiencies_df %>%
  filter(country == 'VNM')
MMR_efficiency <- efficiencies_df %>%
  filter(country == 'MMR')
efficiencies_df$TEC<-c(
  c(NA,diff(KHM_efficiency$efficiency)),
  c(NA,diff(LAO_efficiency$efficiency)),
  c(NA,diff(VNM_efficiency$efficiency)),
  c(NA,diff(MMR_efficiency$efficiency))
)
efficiencies_df$lnTEC <- log(efficiencies_df$TEC)
## get TFPC
efficiencies_df$lnTFPC <- efficiencies_df$lnTEC + lnTC
## visualize TFPC
ggplot(efficiencies_df,aes(color = countries)) +
  geom_line(aes(x = year,y = lnTEC)) + 
  geom_line(aes(x = year,y = lnTFPC)) + 
  geom_line(aes(x = year,y = lnTC))





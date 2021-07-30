library(tidyverse)
library(ggplot2)
library(here)
theme_set(theme_minimal())

age_gen <- read_csv(here("data/NDOP_age_gen_Jul_2021.csv"))
reg <- read_csv(here("data/NDOP_reg_geo_Jul_2021.csv"))
res <- read_csv(here("data/NDOP_res_geo_Jul_2021.csv"))

# age and gender summary --------------------------------------------------
age_gen_edited <- age_gen %>%
  mutate_if(is.character, ~stringr::str_to_lower(.)) %>%
  janitor::clean_names() %>%
  filter(gender == "male" | gender == "female") %>%
  filter(!str_detect(age_band, "all")) %>%
  mutate_at("age_band", ~ifelse(. == "oct-19", "10-19", .)) %>%
  mutate(age_band = factor(age_band)) %>% 
  mutate_at("ach_date", ~lubridate::as_date(., format = "%d/%m/%Y"))

age_gen_edited %>%
  ggplot(aes(ach_date, list_size, colour = age_band)) +
  geom_line() +
  facet_wrap(~gender, ncol = 1) 

#list_size is very consistent over the study period so take initial(list_size) as denominator
#and sum(opt_outs as numerator)

## Gender
age_gen_denom <- age_gen_edited %>% 
  filter(ach_date == min(ach_date)) %>% 
  group_by(gender) %>%
  summarise(denom = sum(list_size)) 
age_gen_edited %>%
  group_by(gender) %>%
  summarise(opt_out = sum(opt_out)) %>%
  left_join(age_gen_denom, by = "gender") %>%
  mutate(pc = (opt_out/denom)*100)

## Age_band  
age_gen_denom <- age_gen_edited %>% 
  filter(ach_date == min(ach_date)) %>% 
  group_by(age_band) %>%
  summarise(denom = sum(list_size)) 
age_gen_edited %>%
  group_by(age_band) %>%
  summarise(opt_out = sum(opt_out)) %>%
  left_join(age_gen_denom, by = "age_band") %>%
  mutate(pc = (opt_out/denom)*100)

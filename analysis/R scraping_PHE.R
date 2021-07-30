library(rvest)
library(ggplot2)
library(reshape2)

# The data source
# https://www.gov.uk/government/publications/respiratory-infections-laboratory-reports-2020


# Relevant weeks
weeks_2020 <- data.frame(
  start = c(3,7,11,16,20,24,29,33,38,42,46),
  end = c(6,10,15,19,23,28,32,37,41,45,49)
)

storage_2020 <- data.frame(matrix(ncol=7))
colnames(storage_2020) <- c("Adenovirus", "Coronavirus", "Parainfluenza", "Rhinovirus", "RSV","Year", "Week")


for(page in 1:nrow(weeks_2020)){

# Specify webpage
week_from <- weeks_2020[page,"start"]
week_to <- weeks_2020[page,"end"]
url <- paste0("https://www.gov.uk/government/publications/respiratory-infections-laboratory-reports-2020/reports-of-respiratory-infections-made-to-phe-from-phe-and-nhs-laboratories-in-england-and-wales-weeks-",
                week_from,"-to-",week_to,"-2020")
# read in the webpage
webpage <- read_html(url)
# select the required elements
phe_data_html <- html_nodes(webpage, "td")
# Converting the html d to text
phe_data <- html_text(phe_data_html)
# Specify start of the table
strt_num <- which(phe_data == "Adenovirus*")[1]
# Specify the end of the table
end_num <- (which(phe_data == "RSV" | phe_data == "Respiratory Syncytial Virus (RSV)" |
                    phe_data == "Respiratory syncytial virus") + (week_to - week_from) +2)[1]
# extract into an R matrix
viruses <- data.frame(matrix(phe_data[strt_num:end_num], ncol = 5, byrow=F))
# remove total row
viruses <- viruses[2:(week_to-week_from+2),]
# Add date information
viruses$Year <- 2020
viruses$Weeks <- week_from:week_to
# label columns
colnames(viruses) <- c("Adenovirus", "Coronavirus", "Parainfluenza", "Rhinovirus", "RSV","Year", "Week")

storage_2020 <- rbind(storage_2020, viruses)
}

# format the table
storage_2020 <- na.omit(storage_2020)
storage_2020_m <- melt(storage_2020, id.vars=c("Year", "Week"))
storage_2020_m$value <- as.numeric(storage_2020_m$value)

ggplot(storage_2020_m, aes(x = Week, y = value, colour = variable)) + 
  geom_line()

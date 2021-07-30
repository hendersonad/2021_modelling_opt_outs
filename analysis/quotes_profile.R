message(paste0("Today's date: ", Sys.Date()))

# Load R scraping package
suppressPackageStartupMessages(library(rvest))

# specify the webpage
url <- "https://www.brainyquote.com/quote_of_the_day"
# read webpage
webpage <- read_html(url)
# subset the required element
quote_html <- html_nodes(webpage, ".b-qt")[1]
# convert from html to text
quote <- html_text(quote_html)
# author html
author_html <- html_nodes(webpage, ".bq-aut")[1]
# author 
author <- html_text(author_html)
# print the quote
print(quote)
print(author)
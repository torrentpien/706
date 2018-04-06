library(XML)
library(plyr)
library(RCurl)
library(httr)
library(vcd)
library(lubridate)

myheader <- c(
  "User-Agent"="Mozilla/5.0(Windows;U;Windows NT 5.1;zh-CN;rv:1.9.1.6",
  "Accept"="text/htmal,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
  "Accept-Language"="en-us",
  "Connection"="keep-alive",
  "Accept-Charset"="big5,utf-8;q=0.7,*;q=0.7"
)

setwd("/media/torrent/Database/Users/Torrent/Google 雲端硬碟/stat/R/706/")

#eventtable <- list()

for (pages in 0:92) {
  eventlistpage <- getURL(paste('https://site.douban.com/143466/widget/events/7053889/?start=', pages, '0', sep = ''))
  eventlistpage_parse <- htmlParse(eventlistpage)
  eventname <- xpathSApply(eventlistpage_parse, "//div[@class='info']", xmlValue)
  eventhref <- xpathSApply(eventlistpage_parse, "//div[@class='info']//a[@href]", xmlGetAttr, 'href')
  eventlist <- data.frame(eventname, eventhref)
  eventtable <- rbind(eventtable, eventlist)
}

#event_table_all <- list()

for (event in 801:914) {
  eventurl <- getURL(eventtable$eventhref[event], useragent="curl/7.39.0 Rcurl/1.95.4.5")
  event_parse <- htmlParse(eventurl)
  
  eventname <- xpathSApply(event_parse, "//div[@class='event-info']//h1[@itemprop='summary']", xmlValue) #提取所需資料  
  
  eventdate <- xpathSApply(event_parse, "//time[@itemprop='startDate']", xmlGetAttr, 'datetime')
  timestart <- regexpr('T', eventdate)
  eventtime <- substr(eventdate, timestart + 1, nchar(eventdate))
  eventdate <- substr(eventdate, 1, timestart - 1)
  
  eventplace <- xpathSApply(event_parse, "//div[@class='event-detail']//span[@itemprop='street-address']", xmlValue)
  
  eventlines <- xpathSApply(event_parse, "//div[@class='event-detail']", xmlValue)
  
  feestart <- regexpr('费用', eventlines[3])
  feeend <- regexpr('元', eventlines[3])
  eventfee <- substr(eventlines[3], feestart + 5, feeend - 1)
  
  eventorg <- xpathSApply(event_parse, "//div[@class='event-detail']//a[@itemprop='name']", xmlValue)
  
  eventcontext <- xpathSApply(event_parse, "//div[@id='link-report']", xmlValue)
  
  eventdetail_table <- data.frame(eventname, eventdate, eventtime, eventplace, eventfee, eventorg, eventcontext)
  event_table_all <- rbind(event_table_all, eventdetail_table)
  
}

write.csv(event_table_all, file = "706events.CSV")

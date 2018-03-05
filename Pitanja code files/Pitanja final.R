# start Selenium server
startServer() #>java -jar selenium-server-standalone.jar // C:\Users\filip.rodik\Desktop\RSelenium
remDr <- remoteDriver(browser = "firefox", port=4444)

# open browser
remDr$open()

# starting url
home_url <- "http://edoc.sabor.hr/ZastupnickaPitanja.aspx"

# navigate page
remDr$navigate(home_url)

pitanja_final <- readSvaDostupnaPitanja(remDr)

write.csv(pitanja_final, file = "deveti.csv", fileEncoding = "Windows-1252")

##### ovo ispod je dodano u readSvaDostupnaPitanja funkciju
# oznaci grupna pitanja
# pitanja_final$Grupno <- 0 
# pitanja_final[grep(";", pitanja_final$Zastupnik),]$Grupno <- 1 
# 
# 
# # dodaj klub zastupnika
# pitanja_final$Klub <- sub("\\).*", "", sub(".*\\(", "", pitanja_final$Zastupnik)) 
# 
# # pretvori datum u datumski tip
# pitanja_final$Date <- as.Date(pitanja_final$Datum, format = "%d.%m.%Y")
# pitanja_final$Datum <- NULL
# 
# # set ID
# pitanja_final$ID <- as.integer(sub(".*id=", "", pitanja_final$URL))
# 
# # pretvori saziv u integer
# pitanja_final$Saziv <- as.integer(pitanja_final$Saziv)


# grep(";", pitanja_final$Zastupnik, value = T)
# grep("*\\(.*?\\) *", head(pitanja_final$Zastupnik,20), value = TRUE)
# gsubfn::strapplyc(head(pitanja_final$Zastupnik,20), "*\\(.*?\\) *", simplify = T)
# gsub("*\\(.*?\\) *","\\1", head(pitanja_final$Zastupnik,20))
# gsub("[\\(\\)]", "", regmatches(head(pitanja_final$Zastupnik,20), gregexpr("\\(.*?\\)", head(pitanja_final$Zastupnik,20))))
# sub("\\).*", "", sub(".*\\(", "", pitanja_final[pitanja_final$Grupno == T,]$Zastupnik)) 
# pitanja_final[pitanja_final$Grupno == T,]$Zastupnik

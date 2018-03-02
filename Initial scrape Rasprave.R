
# start Selenium server
startServer() #>java -jar selenium-server-standalone.jar // C:\Users\Administrator\Desktop\RSelenium
remDr <- remoteDriver(browser = "firefox", port=4444)

# open browser
remDr$open()

# starting url
home_url <- "http://edoc.sabor.hr/Fonogrami.aspx"

# navigate page
remDr$navigate(home_url)

# start scraping
rasprave8 <- readSveDostupneRasprave(remDr)

rasprave_final$Sjednica <- as.integer(rasprave_final$Sjednica)
rasprave_final$RedniBroj <- as.integer(rasprave_final$RedniBroj)
rasprave_final$ImaSnimku <- ifelse(rasprave_final$ImaSnimku == TRUE, 1, 0)

# extract ID from URL # prebaceno u funkciju readSveDostupneRasprave
# rasprave9$ID <- as.integer(substr(rasprave9$URL, unlist(gregexpr(pattern = "id=", text = rasprave9$URL)) + 3, nchar(rasprave9$URL)))

head(rasprave_final)


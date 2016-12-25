
# start Selenium server
startServer() #>java -jar selenium-server-standalone.jar // C:\Users\Administrator\Desktop\RSelenium
remDr <- remoteDriver(browser = "firefox", port=4444)

# open browser
remDr$open()

# starting url
url <- "http://edoc.sabor.hr/Fonogrami.aspx"

# navigate page
remDr$navigate(url)

# start scraping
rasprave <- readSveDostupneRasprave(remDr)

# extract ID from URL
rasprave$ID <- substr(rasprave$URL, unlist(gregexpr(pattern = "id=", text = rasprave$URL)) + 3, nchar(rasprave$URL))

rasprave
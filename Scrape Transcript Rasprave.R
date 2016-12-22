# Scrape Rasprave content


remDr <- remoteDriver(browser = "firefox", port=4444)

# open browser
remDr$open()

# test url
rUrl <- "http://edoc.sabor.hr/Views/FonogramView.aspx?tdrid=2012749"

# scrape transcript
citav_transkript <- readRaspravaTranskript(remDr, rUrl)


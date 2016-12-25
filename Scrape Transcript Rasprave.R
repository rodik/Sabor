# Scrape Rasprave content


remDr <- remoteDriver(browser = "firefox", port=4444)

# open browser
remDr$open()

# test url
rUrl <- "http://edoc.sabor.hr/Views/FonogramView.aspx?tdrid=2012741"

# test scrape transcript
citav_transkript <- readRaspravaTranskript(remDr, rUrl)


if(exists("transkripti")) rm("transkripti")

for (url in rasprave$URL) {
    # scrape transcripts one by one
    
    if (!exists("transkripti")) 
        transkripti <- readRaspravaTranskript(remDr, url)
    else
        transkripti <- rbind(transkripti, readRaspravaTranskript(remDr, url))
}


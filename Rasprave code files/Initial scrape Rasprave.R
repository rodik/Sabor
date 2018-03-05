library(RSelenium)
# start Selenium server
# startServer() #>java -jar selenium-server-standalone.jar // C:\Users\Administrator\Desktop\RSelenium
remDr <- remoteDriver(browser = "chrome", port=4444)

# open browser
remDr$open()

# starting url
home_url <- "http://edoc.sabor.hr/Fonogrami.aspx"

# navigate page
remDr$navigate(home_url)

# start scraping
rasprave_5 <- readSveDostupneRasprave(remDr)

# transkripti_5 <- data.frame()
for (i in 1:nrow(rasprave_5)) {
    r <- rasprave_5[i,]
    transkripti_5 <- rbind(transkripti_5, readRaspravaTranskript(remDr, r$URL))
    print(paste("Parsed", i, "of", nrow(rasprave_5), Sys.time())) 
}


# saveRDS(r_8, "RDS files/saziv_8_headeri.rds")
# saveRDS(transkripti_5, "RDS files/saziv_5_transkripti.rds")

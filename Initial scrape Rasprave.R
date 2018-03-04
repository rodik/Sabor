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
rasprave_8 <- readSveDostupneRasprave(remDr)
rasprave_8_ostalo <- readSveDostupneRasprave(remDr)

rasprave_7_nastavak <- readSveDostupneRasprave(remDr)

transkripti_8 <- data.frame()
for (i in 1:nrow(rasprave_8)) {
    r <- rasprave_8[i,]
    transkripti_8 <- rbind(transkripti_8, readRaspravaTranskript(remDr, r$URL))
    print(paste("Parsed", i, "of", nrow(rasprave_8), Sys.time())) 
}


saveRDS(rasprave_8, "RDS files/saziv_8_headeri.rds")
saveRDS(transkripti_8, "RDS files/saziv_8_transkripti.rds")

transkripti_9 <- readRDS("RDS files/saziv_9_transkripti.rds")
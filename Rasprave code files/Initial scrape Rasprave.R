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

# transkripti_SVI_nova <- data.frame()
for (i in 5547:nrow(sve_rasprave)) {
    r <- sve_rasprave[i,]
    transkripti_SVI_nova <- rbind(transkripti_SVI_nova, readRaspravaTranskript(remDr, r$URL))
    print(paste("Parsed", i, "of", nrow(sve_rasprave), Sys.time())) 
}
# TODO  usli su sigurno duplikati!!!

# saveRDS(r_8, "RDS files/saziv_8_headeri.rds")
# saveRDS(transkripti_5, "RDS files/saziv_5_transkripti.rds")
saveRDS(transkripti_SVI_nova, "RDS files/transkripti_cisti_bkp.rds")
saveRDS(sve_rasprave,"RDS files/sve_raspave_dedupl_bkp.rds")
saveRDS(transkripti_svi, "RDS files/transkripti_dedupl_bkp.rds")
# 147, 148, 188

## ugraditi svo ciscenje u funkcije?
# TODO rastaviti na CSV prema sazivu, gurnuti na github

nastavak_rasprava <- readSveDostupneRasprave(remDr, 2013541)

ttest <- data.frame()
for (k in 1:nrow(nastavak_rasprava)) {
    r <- nastavak_rasprava[k,]
    ttest <- rbind(ttest, readRaspravaTranskript(remDr, r$URL))
    print(paste("Parsed", k, "of", nrow(nastavak_rasprava), Sys.time()))
}
    

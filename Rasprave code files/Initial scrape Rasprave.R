library(RSelenium)
# start Selenium server
# startServer() #>java -jar selenium-server-standalone.jar 
# // C:\Users\Administrator\Desktop\RSelenium
remDr <- remoteDriver(browser = "chrome", port=4444)

# open browser
remDr$open()

# starting url
home_url <- "http://edoc.sabor.hr/Fonogrami.aspx"

# navigate page
remDr$navigate(home_url)

# start scraping
tst_9 <- readSveDostupneRasprave(remDr)
razlika <- tst_9 %>% anti_join(r_9, by="ID")
# razlika_ostatak <- razlika[440:476,]

# razlika$Sjednica <- as.integer(razlika$Sjednica)
# razlika$RedniBroj <- as.integer(razlika$RedniBroj)
# razlika$ImaSnimku <- ifelse(razlika$ImaSnimku == TRUE, 1, 0)

transkripti_9_ost <- data.frame()

for (i in 1:nrow(razlika)) {
    r <- razlika[i,]
    transkripti_9_ost <- rbind(transkripti_9_ost, readRaspravaTranskript(remDr, r$URL))
    print(paste("Parsed", i, "of", nrow(razlika), Sys.time())) 
}

transkripti_SVI <- data.frame()
for (i in 1:20) {
    r <- sve_rasprave[i,]
    transkripti_SVI <- rbind(transkripti_SVI, readRaspravaTranskript(remDr, r$URL))
    print(paste("Parsed", i, "of", nrow(sve_rasprave), Sys.time())) 
}



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
    

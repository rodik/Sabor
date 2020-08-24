r_5 <- sve_rasprave %>% filter(Saziv == 'V')
r_6 <- sve_rasprave %>% filter(Saziv == 'VI')
r_7 <- sve_rasprave %>% filter(Saziv == 'VII')
r_8 <- sve_rasprave %>% filter(Saziv == 'VIII')
r_9 <- sve_rasprave %>% filter(Saziv == 'IX')

t_5 <- svi_transkripti %>% semi_join(r_5, by=c("Rasprava_ID"="ID"))
t_6 <- svi_transkripti %>% semi_join(r_6, by=c("Rasprava_ID"="ID"))
t_7 <- svi_transkripti %>% semi_join(r_7, by=c("Rasprava_ID"="ID"))
t_8 <- svi_transkripti %>% semi_join(r_8, by=c("Rasprava_ID"="ID"))
t_9 <- svi_transkripti %>% semi_join(r_9, by=c("Rasprava_ID"="ID"))

# load RDS
r_5 <- readRDS("RDS files/saziv_5_headeri.rds")
r_6 <- readRDS("RDS files/saziv_6_headeri.rds")
r_7 <- readRDS("RDS files/saziv_7_headeri.rds")
r_8 <- readRDS("RDS files/saziv_8_headeri.rds")
r_9 <- readRDS("RDS files/saziv_9_headeri.rds")

t_5 <- readRDS("RDS files/saziv_5_transkripti.rds")
t_6 <- readRDS("RDS files/saziv_6_transkripti.rds")
t_7 <- readRDS("RDS files/saziv_7_transkripti.rds")
t_8 <- readRDS("RDS files/saziv_8_transkripti.rds")
t_9 <- readRDS("RDS files/saziv_9_transkripti.rds")

# pocisti transkripte
# t_5 <- PocistiTranscriptDF(t_5)
# t_6 <- PocistiTranscriptDF(t_6)
# t_7 <- PocistiTranscriptDF(t_7)
# t_8 <- PocistiTranscriptDF(t_8)
# t_9 <- PocistiTranscriptDF(t_9)

# SPREMI RDS
saveRDS(t_5, "RDS files/saziv_5_transkripti.rds")
saveRDS(t_6, "RDS files/saziv_6_transkripti.rds")
saveRDS(t_7, "RDS files/saziv_7_transkripti.rds")
saveRDS(t_8, "RDS files/saziv_8_transkripti.rds")
saveRDS(t_9, "RDS files/saziv_9_transkripti.rds")

saveRDS(r_5, "RDS files/saziv_5_headeri.rds")
saveRDS(r_6, "RDS files/saziv_6_headeri.rds")
saveRDS(r_7, "RDS files/saziv_7_headeri.rds")
saveRDS(r_8, "RDS files/saziv_8_headeri.rds")
saveRDS(r_9, "RDS files/saziv_9_headeri.rds")

# spremi kao csv
spremiCSV(r_5, "CSV/rasprave_saziv_5.csv")
spremiCSV(r_6, "CSV/rasprave_saziv_6.csv")
spremiCSV(r_7, "CSV/rasprave_saziv_7.csv")
spremiCSV(r_8, "CSV/rasprave_saziv_8.csv")
spremiCSV(r_9, "CSV/rasprave_saziv_9.csv")

spremiCSV(t_5, "CSV/transkripti_saziv_5.csv")
spremiCSV(t_6, "CSV/transkripti_saziv_6.csv")
spremiCSV(t_7, "CSV/transkripti_saziv_7.csv")
spremiCSV(t_8, "CSV/transkripti_saziv_8.csv")
spremiCSV(t_9, "CSV/transkripti_saziv_9.csv")


# zipaj
zip(zipfile = 'CSV/saziv_5_csv', 
    files = c('CSV/rasprave_saziv_5.csv','CSV/transkripti_saziv_5.csv'),
    flags = '-j')
zip(zipfile = 'CSV/saziv_6_csv', 
    files = c('CSV/rasprave_saziv_6.csv','CSV/transkripti_saziv_6.csv'),
    flags = '-j')
zip(zipfile = 'CSV/saziv_7_csv', 
    files = c('CSV/rasprave_saziv_7.csv','CSV/transkripti_saziv_7.csv'),
    flags = '-j')
zip(zipfile = 'CSV/saziv_8_csv', 
    files = c('CSV/rasprave_saziv_8.csv','CSV/transkripti_saziv_8.csv'),
    flags = '-j')
zip(zipfile = 'CSV/saziv_9_csv', 
    files = c('CSV/rasprave_saziv_9.csv','CSV/transkripti_saziv_9.csv'),
    flags = '-j')

# spoji po potrebi za analizu
sve_rasprave <- rbind(r_5,r_6,r_7,r_8,r_9)
svi_transkripti <- rbind(t_5,t_6,t_7,t_8,t_9)

spremiCSV(sve_rasprave, "Export/sve_rasprave.csv")
spremiCSV(svi_transkripti, "Export/svi_transkripti.csv")

# broj rijeci = 71.235.660
# chars = 443.390.085

# TODO maknuti dvostruke navodnike iz CSV-a




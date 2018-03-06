# TODO
# urediti datasetove

PocistiTranscriptDF <- function(transkripti) {
    
    # ukloni dvostruki navodnik iz transkripta jer stvara
    ## probleme prilikom citanja CSV-a
    transkripti$transcript <- gsub(pattern = '"', 
                                   replacement = "'", 
                                   transkripti$transcript, 
                                   fixed = TRUE)
    
    # rename kolona, izdvoji zastupnicki klub
    transkripti %>%
        select(
            Osoba = speaker,
            Transkript = transcript,
            RedniBrojIzjave = statement_id,
            Rasprava_ID = transcript_id
        ) %>%
        mutate(ZastupnickiKlub = regmatches(Osoba, gregexpr("\\(.+?\\)", Osoba))) %>% # klub
        mutate(ZastupnickiKlub = gsub('[()]', '', ZastupnickiKlub)) %>% # mkni zagrade
        mutate(ZastupnickiKlub = if_else( # govornik bez kluba mora imati NA
            ZastupnickiKlub == 'character0',
            as.character(NA),
            ZastupnickiKlub
        )) %>%
        mutate(Rasprava_ID = as.integer(Rasprava_ID)) %>% # pretvori ID rasprave u int
        mutate(Osoba = gsub("\\(.+?\\)","",Osoba))
}


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
t_5 <- PocistiTranscriptDF(t_5)
t_6 <- PocistiTranscriptDF(t_6)
t_7 <- PocistiTranscriptDF(t_7)
t_8 <- PocistiTranscriptDF(t_8)
t_9 <- PocistiTranscriptDF(t_9)

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





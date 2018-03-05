# priprema za obradu teksta
# library(stringr)

spremiCSV <- function(df, fileName, encoding="UTF-8", sep = ';', na ='', row.names = FALSE){
    con<-file(fileName,encoding=encoding)
    # KORISTITI WRITE TABLE
    write.table(df, file=con, na=na, sep = sep, row.names = row.names)
}

rasprave_9 <- readRDS("RDS files/saziv_9_headeri.rds")
transkripti_9 <- readRDS("RDS files/saziv_9_transkripti.rds")

hdr <- rasprave_9 %>% select(Saziv, Sjednica, Naziv, ID)
trn <- transkripti_9 %>%
    select(
        Osoba = speaker,
        Transkript = transcript,
        RedniBrojIzjave = statement_id,
        Rasprava_ID = transcript_id
    ) %>%
    filter(Osoba != '-') %>% # makni najave
    mutate(ZastupnickiKlub = regmatches(Osoba, gregexpr("\\(.+?\\)", Osoba))) %>% # klub
    mutate(ZastupnickiKlub = gsub('[()]', '', ZastupnickiKlub)) %>% # mkni zagrade
    mutate(ZastupnickiKlub = if_else( # govornik bez kluba mora imati NA
        ZastupnickiKlub == 'character0',
        as.character(NA),
        ZastupnickiKlub
    )) %>%
    mutate(Rasprava_ID = as.integer(Rasprava_ID)) %>% # pretvori ID rasprave u int
    mutate(Osoba = gsub("\\(.+?\\)","",Osoba))

za_obradu <- trn %>%
    inner_join(hdr, by=c("Rasprava_ID"="ID")) %>%
    mutate(
        Transkript = gsub('…/.+?/…','', Transkript) # makni didaskalije
    )

spremiCSV(za_obradu, 'deveti_saziv_transkripti.csv')

za_obradu %>% 
    filter(
        grepl("reform", Transkript) #| grepl("komunjar", Transkript) 
    ) %>% 
    group_by(Osoba, ZastupnickiKlub) %>% 
    summarise(broj = n()) %>%
    arrange(desc(broj)) %>%
    View() %>%
    spremiCSV("reforme.csv")


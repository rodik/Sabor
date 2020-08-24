# priprema za obradu teksta
# library(stringr)

spremiXLSX <- function(data, fileName){
    if (is.data.frame(data)) {
        df <- data
        wb <- createWorkbook()
        addWorksheet(wb = wb, sheetName = "Sheet 1", gridLines = FALSE)
        writeDataTable(wb = wb, sheet = 1, x = df)
        saveWorkbook(wb, fileName, overwrite = TRUE)
    }
    else if (is.list(data)) {
        wb <- createWorkbook()
        for(i in 1:length(data)){
            df <- data[i]
            df_name <- names(df)
            addWorksheet(wb = wb, sheetName = df_name, gridLines = FALSE)
            writeDataTable(wb = wb, sheet = df_name, x = as_data_frame(df[[1]]))
        }
        saveWorkbook(wb, fileName, overwrite = TRUE)
    }
}

spremiCSV <- function(df, fileName, encoding="UTF-8", sep = ';', na ='', row.names = FALSE){
    con<-file(fileName, encoding=encoding)
    # KORISTITI WRITE TABLE
    write.table(df, file=con, na=na, sep = sep, row.names = row.names, qmethod = "double" )
    # close.connection(con)
}

sve_rasprave #<- readRDS("RDS files/saziv_9_headeri.rds")
svi_transkripti #<- readRDS("RDS files/saziv_9_transkripti.rds")

hdr <- sve_rasprave %>% select(Saziv, Sjednica, Naziv, ID)
trn <- svi_transkripti %>%
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

spremiCSV(za_obradu, 'svi_podaci.csv')

za_obradu %>% 
    filter(
        grepl("reform", Transkript) #| grepl("komunjar", Transkript) 
    ) %>% 
    group_by(Osoba, ZastupnickiKlub) %>% 
    summarise(broj = n()) %>%
    arrange(desc(broj)) %>%
    View() %>%
    spremiCSV("reforme.csv")


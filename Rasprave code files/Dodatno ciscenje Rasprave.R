<<<<<<< HEAD
<<<<<<< HEAD

dohvati_potencijalne_duplikate <- function(t,r) {
    
    r_stats <- t %>%
        filter(Je_najava == FALSE) %>%
        group_by(Rasprava_ID) %>%
        summarise(
            broj_izjava = n(),
            unique_govornika = n_distinct(Osoba),
            unique_izjava = n_distinct(Transkript)
        ) %>%
        mutate( 
            omjer_originalnih = unique_izjava/broj_izjava
        )
    
    # grupiraj prema govoru sa svih sjednica
    duple <- t %>% 
        filter(Je_najava == FALSE) %>%
        group_by(Transkript, Osoba) %>%
        mutate(cnt = n()) %>%
        filter(cnt > 1) %>%
        ungroup() %>%
        inner_join(r, by=c("Rasprava_ID"="ID")) %>%
        arrange(Transkript, Datum, Rasprava_ID, Sjednica, RedniBroj)
    
    # duple grupiraj prema rasprava_id
    duple %>% group_by(Rasprava_ID) %>%
        summarise(
            broj_duplih = n(),
            avg_duljina_duple = mean(nchar(Transkript))
        ) %>% 
        arrange(Rasprava_ID) %>% #View()
        inner_join(r_stats, by="Rasprava_ID") %>% 
        mutate(
            next_rasp_id = lead(Rasprava_ID, order_by = Rasprava_ID),
            next_rasp_dupli = lead(broj_duplih, order_by = Rasprava_ID),
            omjer_duplih_vanjski = broj_duplih/broj_izjava
        ) %>% # View()
        filter(
            Rasprava_ID + 1 == next_rasp_id & 
                broj_duplih == next_rasp_dupli &
                omjer_duplih_vanjski > 0.5
        ) #%>% View()
}

r_8_stats <- t_8 %>%
    filter(Je_najava == FALSE) %>%
    group_by(Rasprava_ID) %>%
    summarise(
        broj_izjava = n(),
        unique_govornika = n_distinct(Osoba),
        unique_izjava = n_distinct(Transkript)
    ) %>%
    mutate( 
        omjer_originalnih = unique_izjava/broj_izjava
    )

# grupiraj prema govoru sa svih sjednica
duple <- t_8 %>% 
    filter(Je_najava == FALSE) %>%
    group_by(Transkript, Osoba) %>%
    mutate(cnt = n()) %>%
    filter(cnt > 1) %>%
    ungroup() %>%
    inner_join(r_8, by=c("Rasprava_ID"="ID")) %>%
    arrange(Transkript, Datum, Rasprava_ID, Sjednica, RedniBroj)

# duple grupiraj prema rasprava_id
duple %>% group_by(Rasprava_ID) %>%
    summarise(
        broj_duplih = n(),
        avg_duljina_duple = mean(nchar(Transkript))
    ) %>% 
    arrange(Rasprava_ID) %>% #View()
    inner_join(r_8_stats, by="Rasprava_ID") %>% 
    mutate(
        next_rasp_id = lead(Rasprava_ID, order_by = Rasprava_ID),
        next_rasp_dupli = lead(broj_duplih, order_by = Rasprava_ID),
        omjer_duplih_vanjski = broj_duplih/broj_izjava
    ) %>% # View()
    filter(
        Rasprava_ID + 1 == next_rasp_id & 
        broj_duplih == next_rasp_dupli &
        omjer_duplih_vanjski > 0.5
    ) %>% View()
    # dodati usporedbu s prosla_rasp_dupl_cnt i id

    
    
    
    
    
    
=======
# deduplikacija
>>>>>>> 1b9b0f75e0b94189fc7d4acc1af4a2df895d56dd
=======
# deduplikacija
>>>>>>> 1b9b0f75e0b94189fc7d4acc1af4a2df895d56dd

# transkripti
transkripti_SVI_nova <- transkripti_SVI_nova %>% 
    group_by(transcript_id, statement_id) %>%
    mutate(cnt = row_number()) %>% 
    ungroup() %>%
    filter(cnt == 1) %>%
    select(-cnt)

# rasprave    
sve_rasprave <- sve_rasprave %>% 
    group_by(ID) %>%
    mutate(cnt = n()) %>%
    ungroup() %>%
    filter(cnt == 1) %>%
    select(-cnt)


# dodaj najava flag
transkripti_SVI_nova <- transkripti_SVI_nova %>% mutate(
    is_najava = if_else(is.na(date), FALSE, TRUE)
)

# vremenski atribut
transkripti_datum <- data.frame()
for (rasprava_id in sve_rasprave$ID) {
    
    trns <- transkripti_SVI_nova %>% 
                filter(transcript_id == rasprava_id) %>%
                arrange(statement_id)
    
    trns <- PoveziDatume(trns)
    
    transkripti_datum <- rbind(transkripti_datum, trns)    
}

# dodatno pocisti
transkripti_svi <- PocistiTranscriptDF(transkripti_datum)




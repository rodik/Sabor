# deduplikacija

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




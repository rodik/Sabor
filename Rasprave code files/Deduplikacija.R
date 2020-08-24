# deduplikacija

### PROBLEM: 
# Rasprave se ponekad spajaju ALI na edoc.sabor.hr portalu kreiraju se
# dva ili vise zaglavlja u kojima se onda ponove sve izjave iz originalne
# rasprave uz minimalnu razliku u najavi i zavrsnim rijecima (cesto i
# rezultatima glasovanja).
###
# Sto napraviti?
# Prvo rijesiti duplikate unutar iste rasprave. Provjeriti koliko puta se
# ponavlja identican govor u jednoj raspravi

dedupliciraj.transkripte.rasprava2 <-function(transkripti, rasprave) {
    # izracunaj mjere na razini rasprava
    rasprava_stats <- transkripti %>%
        filter(Je_najava == FALSE) %>% # uzmi samo izjave
        group_by(Rasprava_ID) %>% # grupiraj prema ID-u rasprave
        summarise(
            # ukupan broj izjava
            broj_izjava = n(),
            # broj jedinstvenih govornika
            unique_govornika = n_distinct(Osoba),
            # broj jedinstvenih izjava
            unique_izjava = n_distinct(Transkript)
        ) %>%
        mutate(# udio jedinstvenih izjava u ukupnom broju izjava
            # ako je sve OK trebalo bi biti 1.0
            # moguce je da broj bude oko 0.9 zbog ponavljanja kratkih izjava
            # u slucaju greske u njihovom unosu podataka, udio je osjetno manji!
            udio_unique_izjava = unique_izjava / broj_izjava)
    
    # dodaj kolonu u koju ce se pisati broj zajednickih izjava s iducom raspravom
    rasprave$broj_istih_izjava_iduca_rasp <- 0
    # dodaj kolonu u koju ce pisati ID iduce rasprave
    rasprave$iduca_rasprava_id <- NA
    # sortiraj ih po rasprava_id
    rasprave <- rasprave %>% arrange(ID)
    
    for (i in 2:nrow(rasprave)) {
        
        trenutna_rasprava_id <- rasprave[i-1, "ID"] %>% as.integer()
        iduca_rasprava_id <- rasprave[i, "ID"] %>% as.integer()
        
        trenutna <- transkripti %>% 
            filter(Rasprava_ID == trenutna_rasprava_id)
        
        iduca <- transkripti %>% 
            filter(Rasprava_ID == iduca_rasprava_id)
        
        broj_istih <- trenutna %>%
            inner_join(iduca, by = c(
                "Transkript"="Transkript",
                "Osoba"="Osoba"
            )) %>% nrow()
        
        rasprave[i-1,]$broj_istih_izjava_iduca_rasp <- broj_istih
        rasprave[i-1,]$iduca_rasprava_id <- iduca_rasprava_id
    }
    
    duple_rasprave <- rasprave %>%
        filter(broj_istih_izjava_iduca_rasp > 0)
    
    # ovo je sada popis originalnih rasprava i pripadajucih duplikata
    duple_rasprave <- duple_rasprave %>% 
        inner_join(rasprava_stats %>% select(Rasprava_ID, broj_izjava),
                   by=c("ID"="Rasprava_ID")) %>%
        inner_join(rasprava_stats %>% select(Rasprava_ID, broj_izjava),
                   by=c("iduca_rasprava_id"="Rasprava_ID")) %>%
        mutate(
            udio_duplih.x = broj_istih_izjava_iduca_rasp / broj_izjava.x,
            udio_duplih.y = broj_istih_izjava_iduca_rasp / broj_izjava.y
        ) %>%
        filter(
            udio_duplih.y > 0.5 # ovo je odokativno ali OK
        )
    
    # proci jednu po jednu i pocistiti anti_joinom
    for (i in 1:nrow(duple_rasprave)) {
        d <- duple_rasprave[i,]
        # uzmi oba transkripta
        t1 <- transkripti %>% filter(Rasprava_ID == d$ID)
        t2 <- transkripti %>% filter(Rasprava_ID == d$iduca_rasprava_id)
        # iz drugog makni sve 'duple' izjave
        t2 <- t2 %>% anti_join(t1, by = c(
            "Transkript"="Transkript",
            "Osoba"="Osoba"
        ))
        # ukloni citav transkript iz glavne kolekcije
        transkripti <- transkripti %>% filter(Rasprava_ID != d$iduca_rasprava_id)
        # dodaj ociscenu verziju
        transkripti <- rbind(transkripti, t2)
    }
    
    # 2. korak deduplikacije
    # makni dupli niz izjava unutar iste rasprave
    transkripti_visestruke_izjave <- transkripti %>%
        group_by(Rasprava_ID, Osoba, Transkript) %>%
        mutate(dup_rnk = row_number()) %>%
        filter(dup_rnk > 1)
    
    transkripti_visestruke_izjave
}

# rucna provjera za scenarij 1
dedupliciraj.transkripte.rasprava <- function(transkripti, rasprave){
    
    # izracunaj mjere na razini rasprava
    rasprava_stats <- transkripti %>%
        filter(Je_najava == FALSE) %>% # uzmi samo izjave
        group_by(Rasprava_ID) %>% # grupiraj prema ID-u rasprave
        summarise(
            # ukupan broj izjava
            broj_izjava = n(),
            # broj jedinstvenih govornika
            unique_govornika = n_distinct(Osoba),
            # broj jedinstvenih izjava
            unique_izjava = n_distinct(Transkript)
        ) %>%
        mutate( 
            # udio jedinstvenih izjava u ukupnom broju izjava
            # ako je sve OK trebalo bi biti 1.0
            # moguce je da broj bude oko 0.9 zbog ponavljanja kratkih izjava
            # u slucaju greske u njihovom unosu podataka, udio je osjetno manji!
            udio_unique_izjava = unique_izjava/broj_izjava
        )
    
    # sve s malin omjerom_jedinstvenih poslati na dodatno ciscenje unutar rasprave
    # TODO
    
    # srediti ponavljajuce izjave u slijednim raspravama
    visestruke_izjave <- transkripti %>% 
        filter(Je_najava == FALSE) %>% # uzmi samo izjave
        group_by(Transkript, Osoba) %>% # grupiraj prema izjavi i govorniku
        mutate(cnt = n()) %>% # izracunaj broj izjava
        filter(cnt > 1) %>% # uzmi samo visestruke
        ungroup() %>% # vrati se na originalnu razinu
        inner_join(rasprave, by=c("Rasprava_ID"="ID")) %>% # spoji rasprave
        arrange(Transkript, Datum, Rasprava_ID, Sjednica, RedniBroj) # sort
    
    # 
    grupirane_izjave <- visestruke_izjave %>% 
        group_by(Rasprava_ID) %>%
        summarise(
            broj_duplih = n(),
            avg_duljina_duple = mean(nchar(Transkript))
        ) %>% 
        arrange(Rasprava_ID) %>% #View()
        inner_join(rasprava_stats, by="Rasprava_ID") %>% 
        mutate(
            prev_rasp_id = lag(Rasprava_ID, order_by = Rasprava_ID, default = 0),
            prev_rasp_dupli = lag(broj_duplih, order_by = Rasprava_ID),
            omjer_duplih_vanjski = broj_duplih/broj_izjava
        ) %>% mutate(
            pocetak_nove_grupe = if_else(
                Rasprava_ID - 1 == prev_rasp_id,
                0, # vrati 1 ako krece nova grupa, u suprotnom nula
                1
                # if_else(prev_rasp_id == 0, 1, 0) # iznimka za prvi red
            )
        ) %>% mutate( # dodaj identifikator grupe window funkcijom
            group_id = order_by(Rasprava_ID, cumsum(pocetak_nove_grupe))
        )
    
    group_ids <- unique(grupirane_izjave$group_id)
    
    for (gid in group_ids) {
        # dohvati izjave iz grupe
        kandidati_grupe <- grupirane_izjave %>% filter(group_id == gid)
        
        if (nrow(kandidati_grupe) == 1) # ako samo jedna izjava cini grupu
            next # to je OK, odi na iducu
        
        # kreiraj dataset kopiranjem vodece rasprave (prve iz grupe) 
        vodeca_rasprava <- transkripti %>%
            semi_join(kandidati_grupe[1,], by=c("Rasprava_ID"))
        
        # Iz svake iduce pobrisi sve izjave koje vec postoje u prvoj
        for (i in 2:nrow(kandidati_grupe)) {
            # uzmi promatrane transkripte
            promatrana_rasprava <- transkripti %>% 
                semi_join(kandidati_grupe[i,], by=c("Rasprava_ID"))
            
            # ocisti duple izjave iz promatrane
            ociscena_rasprava <- ocisti.duple.izjave(vodeca_rasprava,
                                                     promatrana_rasprava)
            
            if (nrow(promatrana_rasprava) != nrow(ociscena_rasprava)) {
                # makni transkripte iz te rasprave
                transkripti <- transkripti %>% filter(
                    Rasprava_ID == min(ociscena_rasprava$Rasprava_ID)
                )
                # dodaj ociscenu verziju u glavnu kolekciju
                transkripti <- rbind(transk, ociscena_rasprava)
            }
        }
    }
    # return
    transkripti
}

ocisti.duple.izjave <- function(prva, druga){
    
    # TODO: dodatna kontrola, provjeriti range duplih u obje rasprave !!!
    
    # izvuci samo originalne iz druge
    originalne <- druga %>% anti_join(prva, by=c(
      "Transkript",
      "Osoba"
    ))
    
    # sredi RedniBrojIzjave
    originalne <- originalne %>% mutate(
        # RedniBrojIzjave = order_by(RedniBrojIzjave, row_number())
        RedniBrojIzjave = row_number()
    )
    # return
    originalne
}
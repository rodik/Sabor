# funkcije za parsiranje rasprava



# jedan redak iz tablice headera rasprava pretvara u data.frame row
readRaspravaRow <- function(r) {
    if (unlist(r$getElementAttribute("id")) != "ctl00_ContentPlaceHolder_gvFilters_DXDataRow0" ) {
        # get a href
        a <- r$findChildElement(using = "tag name", value = "a")
        tdr_link <- a$getElementAttribute(attrName = "href")
        
        # get cell values
        tds <- r$findChildElements(using = "tag name", value = "td")
        cell_list <- sapply(unlist(tds), function(x) x$getElementText())
        
        d <- data.frame(matrix(unlist(cell_list)[1:4], nrow = 1, byrow = TRUE), stringsAsFactors = FALSE)
        
        names(d) <- c("Saziv", "Sjednica", "RedniBroj", "Naziv")
        
        # if (is.na(d$Sjednica)) {
        #     stranica <- remDr$findElements(using = "class", value = "dxp-current")
        # }
        
        # pretvori dvostruke navodnike u jednostruke
        d$Naziv <- gsub('"',"'",d$Naziv)
        d$URL <- unlist(tdr_link)
        d$ImaSnimku <- unlist(cell_list)[6] == "Snimka rasprave"
        
        d
    } 
}

# cita jednu stranicu
readRasprave <- function(rows) {
    dat <- data.frame()
    
    for (row in rows) {
        rrow <- readRaspravaRow(row)
        
        dat <- rbind(dat, rrow)
    }
    # kreiraj ID
    dat$ID <- as.integer(substr(dat$URL, 
                                unlist(gregexpr(pattern = "id=", text = dat$URL)) + 3,
                                nchar(dat$URL)))
    
    dat
}


# rm(dat)

<<<<<<< HEAD
# cita sve headere rasprava od ZADNJE do prve dostupne stranice
readSveDostupneRasprave <- function(remDr, zadnja_procitana_rasprava_id = 0) {
=======
# cita sve headere rasprava od prve do zadnje dostupne stranice
readSveDostupneRasprave <- function(remDr, zadnja_procitana_rasprava_id = 0) {
    
    # # get Next button
    # btnList <- remDr$findElements(using = "partial link text", value = "> >")
    # if (length(btnList) == 0) 
    #     return(NA)
    # else
    #     btnNext <- btnList[[1]]
>>>>>>> 1b9b0f75e0b94189fc7d4acc1af4a2df895d56dd
    
    rasprave <- data.frame()
    current_page_num <- 0
    
    out <- tryCatch(
        {
            # until the first page is reached
            while (current_page_num != 1) {
                
                # get table rows containing data (using default table sort) returned as a list of web elements
                rows_we <- remDr$findElements(using = "class", value = "dxgvDataRow_SaborPurpleTheme")    
                # procitaj stranicu
                rasprave <- rbind(rasprave, readRasprave(rows_we))
                
                # log current page
                current_page <- remDr$findElement(using = 'css', value = '#ctl00_ContentPlaceHolder_gvFonogrami_PagerBarB_GotoBox_I')
                current_page_num <- current_page$getElementAttribute('value')
                print(paste('Finished reading page:', current_page_num))
                
<<<<<<< HEAD
                # get Previous button
                btnPrev <- remDr$findElement(using = 'css', value = '#ctl00_ContentPlaceHolder_gvFonogrami_PagerBarB_PrevButton_CD')
                
                
                # stani ako si dosao do zadnjeg procitanog
                # if (min(rasprave$ID) <= zadnja_procitana_rasprava_id) {
                #     print(
                #         paste0(
                #             "Zaustavljam se, dosao sam do zadnje procitane: ",
                #             zadnja_procitana_rasprava_id
                #         )
                #     )
                #     # pobrisi sve vece
                #     rasprave <- rasprave %>%
                #         filter(ID > zadnja_procitana_rasprava_id)
                #     # izadi iz iteriranja po stranicama
                #     break
                # }
=======
                # reload Next button status
                btnList <- remDr$findElements(using = "partial link text", value = "> >")
                if (length(btnList) == 0) {
                    break
                }
                else
                    btnNext <- btnList[[1]]
>>>>>>> 1b9b0f75e0b94189fc7d4acc1af4a2df895d56dd
                
                # stani ako si dosao do zadnjeg procitanog
                if (min(rasprave$ID) <= zadnja_procitana_rasprava_id) {
                    print(
                        paste0(
                            "Zaustavljam se, dosao sam do zadnje procitane: ",
                            zadnja_procitana_rasprava_id
                        )
                    )
                    # pobrisi sve vece
                    rasprave <- rasprave %>%
                        filter(ID > zadnja_procitana_rasprava_id)
                    # izadi iz iteriranja po stranicama
                    break
                }
                
                # click Next page
                btnPrev$clickElement()
                # wait for reload
                Sys.sleep(20)
            }
            return(as_data_frame(rasprave)) # convert to tibble
        },
        error=function(cond) {
            message("Here's the original error message:")
            message(cond)
            # Choose a return value in case of error
            return(as_data_frame(rasprave)) # convert to tibble
        }
        # finally={
            
        # }
    )    
    out$Sjednica <- as.integer(out$Sjednica)
    out$RedniBroj <- as.integer(out$RedniBroj)
    out$ImaSnimku <- ifelse(out$ImaSnimku == TRUE, 1, 0)
    return(out)
}

# cita kompletni transkript jedne rasprave
readRaspravaTranskript <- function(remDr, url) {
    
    # navigate to page
    remDr$navigate(url)
    
    # wait for reload
    Sys.sleep(2)
    
    # get transcript_id from URL
    ts_id = substr(url, unlist(gregexpr(pattern = "id=", text = url)) + 3, nchar(url))
    
    # get all text containers
    # text_rows <- remDr$findElements(using = "css selector", value = ".singleContentContainer+ .singleContentContainer")
<<<<<<< HEAD
    text_rows <- remDr$findElements(using = "css selector", 
        value = "#ctl00_ContentPlaceHolder_rptMain_ctl00_divTileShape0 , .singleContentContainer+ .singleContentContainer")
=======
    text_rows <- remDr$findElements(using = "css selector", value = "#ctl00_ContentPlaceHolder_rptMain_ctl00_divTileShape0 , .singleContentContainer+ .singleContentContainer")
>>>>>>> 1b9b0f75e0b94189fc7d4acc1af4a2df895d56dd
    
    transcript_rows <- data.frame()
    
    for (row in text_rows) {
        transcript_rows <- rbind(transcript_rows, readTranskriptRow(row))
    }
    
    # convert to tibble
    transcript_rows <- as_data_frame(transcript_rows)
    
    # add statement_id column
    transcript_rows <- mutate(transcript_rows, statement_id = as.integer(rownames(transcript_rows)))
    
    # add transcript_id
    transcript_rows$transcript_id = ts_id
    
    # oznaci najave rasprava i sortiraj prema statement_id
    transcript_rows <- transcript_rows %>% 
        mutate(
            is_najava = if_else(is.na(date), FALSE, TRUE)
        ) %>% 
        arrange(statement_id)
    
    # upisi svim recordima datume prema najavama
    transcript_rows <- PoveziDatume(transcript_rows)
    
    # dodatno pocisti kolone i daj im smislene nazive
    transcript_rows <- PocistiTranscriptDF(transcript_rows)
    
    # report
    print(ts_id)
    
    # return
    transcript_rows
}

# pretvara jedan redak (govor) transkripta u data.frame row
readTranskriptRow <- function(row) {
    # get speaker data
    speaker_node <- row$findChildElement(using = "tag name", value = "h2")
    speaker <- speaker_node$getElementText()
    speaker <- unlist(speaker)
    speaker <- gsub("[\r\n]", " ", speaker) # remove newline chars
    
    # get transcript data
    transcript_node <- row$findChildElement(using = "tag name", value = "dd")
    transcript <- transcript_node$getElementText()
    transcript <- unlist(transcript)
    transcript <- gsub("[\r\n]", " ", transcript)
    transcript <- gsub('"',"'",transcript)
    
    date <- as.Date(NA)
    # ako je specijalni redak u kojem se krije datum, izvadi ga
    if (unlist(row$getElementAttribute('class')) == 'singleContentContainer tileShape') {
        date_node <- row$findChildElement(using = "class", value = "dateString")
        date_txt <- date_node$getElementText()
        date_txt <- unlist(date_txt)
        date_txt <- gsub("[\r\n]", " ", date_txt)
        date <- as.Date(date_txt, '%d.%m.%Y.')
    }
    
    # return as df
    data.frame(speaker, transcript, date, stringsAsFactors = FALSE)
}




# cita prvi redak transkripta zbog datuma (to sam greskom inicijalno izostavio)
# todo, ova se funkcija moze pobrisati naknadno
readRaspravaTranskript_fix <- function(remDr, url) {
    
    # navigate to page
    remDr$navigate(url)
    
    # wait for reload
    Sys.sleep(2)
    
    # get transcript_id from URL
    ts_id = substr(url, unlist(gregexpr(pattern = "id=", text = url)) + 3, nchar(url))
    
    # get all text containers
    text_rows <- remDr$findElements(using = "css selector", value = "#ctl00_ContentPlaceHolder_rptMain_ctl00_divTileShape0")
    
    transcript_rows <- data.frame()
    
    for (row in text_rows) {
        transcript_rows <- rbind(transcript_rows, readTranskriptRow(row))
    }
    
    # convert to tibble
    transcript_rows <- as_data_frame(transcript_rows)
    
    # add statement_id column
    transcript_rows <- mutate(transcript_rows, statement_id = as.integer(0))
    
    # add transcript_id
    transcript_rows$transcript_id = ts_id
    
    # report
    print(ts_id)
    
    # return
    transcript_rows
}

PoveziDatume <- function(ts){
    # napravi kopiju citavog transkripta
    ts_novi <- ts
    
    for (i in 1:nrow(ts_novi)) {
        # uzmi redak
        record <- ts_novi[i,]
        # ako nema datum, pisi prethodni
        if (is.na(record$date)) {
            ts_novi[i,]$date <- ts_novi[i-1,]$date
        } else {
            ts_novi[i,]$date <- record$date
        }
    }
    ts_novi
}

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
            Rasprava_ID = transcript_id,
            Datum = date,
            Je_najava = is_najava
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




















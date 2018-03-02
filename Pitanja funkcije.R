# funkcije


readPitanjeRow <- function(r) {
    # r <- rows_we[[8]]
    if (unlist(r$getElementAttribute("id")) != "ctl00_ContentPlaceHolder_gvFilters_DXDataRow0" ) {
        # get a href
        a <- r$findChildElement(using = "tag name", value = "a")
        tdr_link <- a$getElementAttribute(attrName = "href")
        
        # get cell values
        tds <- r$findChildElements(using = "tag name", value = "td")
        cell_list <- sapply(unlist(tds), function(x) x$getElementText())
        
        d <- data.frame(matrix(unlist(cell_list)[1:6], nrow = 1, byrow = TRUE), stringsAsFactors = FALSE)
        
        names(d) <- c("Zastupnik", "OpisPitanja", "Duznosnik", "Datum", "NacinPostavljanja", "Podrucje")
        
        d$URL <- unlist(tdr_link)
        
        d
    } 
}


readPitanja <- function(rows) {
    if(exists("dat")) rm("dat")
    
    for (row in rows) {
        
        if (!exists("dat")) 
            dat <- readPitanjeRow(row)
        else
            dat <- rbind(dat, readPitanjeRow(row))
    }
    dat
}



readSvaDostupnaPitanja <- function(remDr, saziv) {
    
    # get Next button
    btnList <- remDr$findElements(using = "partial link text", value = "> >")
    if (length(btnList) == 0) 
        return(NA)
    else
        btnNext <- btnList[[1]]
    
    if(exists("pitanja")) rm("pitanja", envir = globalenv())
    
    # until the last page is reached and the "Next" button is disabled
    while (TRUE) {
        
        # get table rows containing data (using default table sort) returned as a list of web elements
        rows_we <- remDr$findElements(using = "class", value = "dxgvDataRow_SaborPurpleTheme")    
        # get data
        if(!exists("pitanja")) 
            pitanja <- readPitanja(rows_we)
        else
            pitanja <- rbind(pitanja, readPitanja(rows_we))
        # click Next page
        btnNext$clickElement()
        # wait for reload
        Sys.sleep(5)
        # reload Next button status
        btnList <- remDr$findElements(using = "partial link text", value = "> >")
        if (length(btnList) == 0) 
            break
        else
            btnNext <- btnList[[1]]
        
        # print ("#####################################################")
        if (btnNext$getElementAttribute("class") == "dxp-button dxp-bt dxp-disabledButton") 
            break
    }
    
    # oznaci grupna pitanja
    pitanja$Grupno <- 0 
    pitanja[grep(";", pitanja$Zastupnik),]$Grupno <- 1 
    
    
    # dodaj klub zastupnika
    pitanja$Klub <- sub("\\).*", "", sub(".*\\(", "", pitanja$Zastupnik)) 
    
    # pretvori datum u datumski tip
    pitanja$Date <- as.Date(pitanja$Datum, format = "%d.%m.%Y")
    pitanja$Datum <- NULL
    
    # set ID
    pitanja$ID <- as.integer(sub(".*id=", "", pitanja$URL))
    
    # pretvori saziv u integer kolonu
    pitanja$Saziv <- saziv
    
    as_data_frame(pitanja) # convert to tibble
}


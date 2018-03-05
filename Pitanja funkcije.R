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
    dat <- data.frame()
    
    for (row in rows) {
        dat <- rbind(dat, readPitanjeRow(row))
    }
    dat
}



readSvaDostupnaPitanja <- function(remDr, saziv) {
    
    pitanja <- data.frame()
    
    out <- tryCatch(
        {
            # until the last page is reached and the "Next" button is disabled
            while (TRUE) {
                # get table rows containing data (using default table sort) returned as a list of web elements
                rows_we <- remDr$findElements(using = "class", value = "dxgvDataRow_SaborPurpleTheme")
                # get data
                pitanja <- rbind(pitanja, readPitanja(rows_we))
                
                # log current page
                current_page <- remDr$findElement(using = 'css', value = '.dxp-current')
                print(paste('Finished reading page:',current_page$getElementText()))
                
                # reload Next button status
                btnList <- remDr$findElements(using = "partial link text", value = "> >")
                if (length(btnList) == 0)
                    break
                else
                    btnNext <- btnList[[1]]
                
                # click Next page
                btnNext$clickElement()
                # wait for reload
                Sys.sleep(3)
                
                # # print ("#####################################################")
                # if (btnNext$getElementAttribute("class") == "dxp-button dxp-bt dxp-disabledButton")
                #     break
            }
            return(as_data_frame(pitanja)) # convert to tibble
        },
        error=function(cond) {
            message("Here's the original error message:")
            message(cond)
            # Choose a return value in case of error
            return(as_data_frame(pitanja)) # convert to tibble
        }
        # finally={
           
        # }
    )
    # oznaci grupna pitanja
    out$Grupno <- 0 
    out[grep(";", out$Zastupnik),]$Grupno <- 1 
    
    
    # dodaj klub zastupnika
    out$Klub <- sub("\\).*", "", sub(".*\\(", "", out$Zastupnik)) 
    
    # pretvori datum u datumski tip
    out$Date <- as.Date(out$Datum, format = "%d.%m.%Y")
    out$Datum <- NULL
    
    # set ID
    out$ID <- as.integer(sub(".*id=", "", out$URL))
    
    # pretvori saziv u integer kolonu
    out$Saziv <- saziv
    return(out)
}


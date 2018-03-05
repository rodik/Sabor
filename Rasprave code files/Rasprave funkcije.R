# funkcije za parsiranje rasprava



# jedan redak iz tablice headera rasprava pretvara u data.frame row
readRaspravaRow <- function(r) {
    # r <- rows_we[[8]]
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
        
        d$URL <- unlist(tdr_link)
        d$ImaSnimku <- unlist(cell_list)[6] == "Snimka rasprave"
        
        d
    } 
}

# cita jednu stranicu
readRasprave <- function(rows) {
    dat <- data.frame()
    
    for (row in rows) {
        dat <- rbind(dat, readRaspravaRow(row))
    }
    dat
}


# rm(dat)

# cita sve headere rasprava od prve do zadnje dostupne stranice
readSveDostupneRasprave <- function(remDr) {
    
    # # get Next button
    # btnList <- remDr$findElements(using = "partial link text", value = "> >")
    # if (length(btnList) == 0) 
    #     return(NA)
    # else
    #     btnNext <- btnList[[1]]
    
    rasprave <- data.frame()
    
    out <- tryCatch(
        {
            # until the last page is reached and the "Next" button is disabled
            while (TRUE) {
                
                # get table rows containing data (using default table sort) returned as a list of web elements
                rows_we <- remDr$findElements(using = "class", value = "dxgvDataRow_SaborPurpleTheme")    
                # get data
                rasprave <- rbind(rasprave, readRasprave(rows_we))
                
                # log current page
                current_page <- remDr$findElement(using = 'css', value = '.dxp-current')
                print(paste('Finished reading page:', current_page$getElementText()))
                
                
                # reload Next button status
                btnList <- remDr$findElements(using = "partial link text", value = "> >")
                if (length(btnList) == 0) {
                    break
                }
                else
                    btnNext <- btnList[[1]]
                
                # click Next page
                btnNext$clickElement()
                # wait for reload
                Sys.sleep(4)
                
                # # print ("#####################################################")
                # if (btnNext$getElementAttribute("class") == "dxp-button dxp-bt dxp-disabledButton") 
                #     break
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
    out$ID <- as.integer(substr(out$URL, unlist(gregexpr(pattern = "id=", text = out$URL)) + 3, nchar(out$URL)))
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
    Sys.sleep(3)
    
    # get transcript_id from URL
    ts_id = substr(url, unlist(gregexpr(pattern = "id=", text = url)) + 3, nchar(url))
    
    # get all text containers
    text_rows <- remDr$findElements(using = "css selector", value = ".singleContentContainer+ .singleContentContainer")
    
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
    
    # return as df
    data.frame(speaker, transcript, stringsAsFactors = FALSE)
}
































# funkcije

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

readRasprave <- function(rows) {
    if(exists("dat")) rm("dat")
    
    for (row in rows) {
        
        if (!exists("dat")) 
            dat <- readRaspravaRow(row)
        else
            dat <- rbind(dat, readRaspravaRow(row))
    }
    dat
}


# rm(dat)

readSveDostupneRasprave <- function(remDr) {
    
    # get Next button
    btnList <- remDr$findElements(using = "partial link text", value = "> >")
    if (length(btnList) == 0) 
        return(NA)
    else
        btnNext <- btnList[[1]]
    
    if(exists("rasprave")) rm("rasprave", envir = globalenv())
    
    # until the last page is reached and the "Next" button is disabled
    while (TRUE) {
        
        # get table rows containing data (using default table sort) returned as a list of web elements
        rows_we <- remDr$findElements(using = "class", value = "dxgvDataRow_SaborPurpleTheme")    
        # get data
        if(!exists("rasprave")) 
            rasprave <- readRasprave(rows_we)
        else
            rasprave <- rbind(rasprave, readRasprave(rows_we))
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
    
    rasprave$ID <- as.integer(substr(rasprave$URL, unlist(gregexpr(pattern = "id=", text = rasprave$URL)) + 3, nchar(rasprave$URL)))
    
    as_data_frame(rasprave) # convert to tibble
}

readRaspravaTranskript <- function(remDr, url) {
    
    # navigate to page
    remDr$navigate(url)
    
    # get transcript_id from URL
    ts_id = substr(url, unlist(gregexpr(pattern = "id=", text = url)) + 3, nchar(url))
    
    # get all text containers
    text_rows <- remDr$findElements(using = "css selector", value = ".singleContentContainer+ .singleContentContainer")
    
    for (row in text_rows) {
        
        if (!exists("transcript_rows")) 
            transcript_rows <- readTranskriptRow(row)
        else
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
































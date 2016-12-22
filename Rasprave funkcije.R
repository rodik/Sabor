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
        
        d$URL <- tdr_link
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
    
    as_data_frame(rasprave) # convert to tibble
}
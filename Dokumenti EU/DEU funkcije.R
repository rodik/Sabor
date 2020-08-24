
# pozicioniraj se na tocnu stranicu!!

# svi_DEU_scraped_9 <- ProcitajRedoveTablice()
# svi_DEU_scraped_8 <- ProcitajRedoveTablice()
# svi_DEU_scraped_7 <- ProcitajRedoveTablice()

# svi_DEU_scraped <- rbind(
#     svi_DEU_scraped_9,
#     svi_DEU_scraped_8,
#     svi_DEU_scraped_7
# )

# svi_DEU_detalji_scraped <- Iteriraj_DEU(svi_DEU_scraped)

# svi_DEU_detalji_scraped
# svi_DEU_scraped %>% inner_join(
#     svi_DEU_detalji_scraped, by = c('akt_url'='DEU_url')
# ) %>% spremiXLSX('Dokumenti EU/Export/deu_20191021.XLSX')


InitSelenium <- function(home_url = "http://edoc.sabor.hr/DEU.aspx") {
    
    remDr <- remoteDriver(browser = "chrome", port=4444)
    # open browser
    remDr$open()
    
    # navigate page
    remDr$navigate(home_url)
    # wait for load
    Sys.sleep(5)
}


ProcitajRedoveTablice <- function(){
    
    # InitSelenium()
    
    svi_DEU <- tibble()
    
    # get page number element
    max_page_element <- remDr$findElement('css', '#ctl00_ContentPlaceHolder_gvDeu_tcPagerBarB td:nth-child(4) span')
    # extract total page number
    max_pages <- max_page_element$getElementText() %>% 
        gsub(pattern = "[^0-9.-]", replacement = "") %>% as.integer()
    
    i <- 1
    for (i in 1:(max_pages)) {
        
        rows_we <- remDr$findElements(using = "class", value = "dxgvDataRow_SaborPurpleTheme")
        
        # procitaj stranicu
        svi_DEU <- rbind(svi_DEU, ReadDEU_table(rows_we))
        
        # log current page
        current_page <- remDr$findElement(using = 'css', value = '#ctl00_ContentPlaceHolder_gvDeu_PagerBarB_GotoBox_I')
        current_page_num <- current_page$getElementAttribute('value')
        print(paste('Finished reading page:', current_page_num))
        
        # get NEXT PAGE button
        btnPrev <- remDr$findElement(using = 'css', value = '#ctl00_ContentPlaceHolder_gvDeu_PagerBarB_NextButton_CD .dx-vam')
        
        if(current_page_num < max_pages) { 
            # click Next page
            btnPrev$clickElement() 
            # wait for reload
            Sys.sleep(5)
        }
        
    }
    
    return(svi_DEU)
}

# cita jednu stranicu
ReadDEU_table <- function(rows) {
    dat <- data.frame()
    
    for (row in rows[1:(length(rows)-1)]) {
        rrow <- ReadDEU_row(row)
        
        dat <- rbind(dat, rrow)
    }
    dat
}

# pretvara jedan redak (dokument) u data.frame row
ReadDEU_row <- function(row) {
    # get naziv akta and URL ID
    naziv_akta_node <- row$findChildElements(using = "css", value = ".dxgv")[[1]]
    naziv_akta <- naziv_akta_node$getElementText() %>% unlist()
    akt_url <- naziv_akta_node$findChildElement('tag name', 'a')$getElementAttribute('href') %>% unlist()
    
    # get Broj DEU
    broj_DEU_node <- row$findChildElements(using = "css", value = ".dxgv")[[2]]
    broj_DEU <- broj_DEU_node$getElementText() %>% unlist()
    
    # get Saziv
    saziv_node <- row$findChildElements(using = "css", value = ".dxgv")[[3]]
    saziv <- saziv_node$getElementText() %>% unlist()
    
    # get Satus
    status_node <- row$findChildElements(using = "css", value = ".dxgv")[[4]]
    status <- status_node$getElementText() %>% unlist()
    
    # return as df
    tibble(akt_url, naziv_akta, broj_DEU, saziv, status)
}

ReadDEU_summary <- function(url){
    remDr$navigate(url)
    
    
    vrsta_akta <- remDr$findElement('css', '#ctl00_ContentPlaceHolder_ctrlDEUAktView_glava_lblVrstaAkta')$getElementText() %>% unlist()
    predlagatelj <- remDr$findElement('css', '#ctl00_ContentPlaceHolder_ctrlDEUAktView_glava_lblPredlagatelj')$getElementText() %>% unlist()
    podrucje <- remDr$findElement('css', '#ctl00_ContentPlaceHolder_ctrlDEUAktView_glava_lblPodrucje')$getElementText() %>% unlist()
    signatura <- remDr$findElement('css', '#ctl00_ContentPlaceHolder_ctrlDEUAktView_glava_lblSignatura')$getElementText() %>% unlist()
    
    pdf_url <- remDr$findElements('css', '#ctl00_ContentPlaceHolder_ctrlDEUAktView_glava_lnkNazivAkta')
    if (length(pdf_url) == 1 && !is.null(pdf_url[[1]]$getElementAttribute('href') %>% unlist())) {
        pdf_url <- pdf_url[[1]]$getElementAttribute('href') %>% unlist()
    } else {
        pdf_url <- as.character(NA)
    }
    
    EU_oznaka_akta <- remDr$findElements('css', '#ctl00_ContentPlaceHolder_ctrlDEUAktView_glava_lblEUOznakaAkta')
    if (length(EU_oznaka_akta) == 1) {
        EU_oznaka_akta <- EU_oznaka_akta[[1]]$getElementText() %>% unlist()
    } else {
        EU_oznaka_akta <- as.character(NA)
    }
    
        
    tibble(
        PDF_url = pdf_url,
        Vrsta_akta = vrsta_akta,
        EU_oznaka_akta = EU_oznaka_akta,
        Predlagatelj = predlagatelj,
        Podrucje = podrucje,
        Signatura = signatura,
        DEU_url = url
    )
}

Iteriraj_DEU <- function(svi_DEU) {
    
    svi_DEU_detalji <- tibble()
    
    i <- 1
    for (url in svi_DEU$akt_url) {
        print(paste('Scraping:',url))
        
        svi_DEU_detalji <- rbind(svi_DEU_detalji, ReadDEU_summary(url))
        
        print(paste('Finished reading akt:', i, 'of', nrow(svi_DEU)))
        Sys.sleep(1)
        i <- i + 1
    }
    
    return(svi_DEU_detalji)
}
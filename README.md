# Saborski transkripti scraper
[RSelenium](https://github.com/ropensci/RSelenium) scraper za rasprave i zastupnička pitanja

Projekt sadržava funkcije potrebne za programski pristup podacima s edoc.sabor portala. Trenutno je moguće pristupati saborskim raspravama i zastupničkim pitanjima.

Saborske rasprave za 7.,8. i 9. saziv dostupne su u CSV formatu u folderu CSV export. Opis datoteka:

* _rasprave_saziv_N.csv_ = zaglavlja rasprava (kolona **ID** je identifikator rasprave)
* _transkripti_saziv_N.csv_ = transkripti rasprava (kolona **transcript_id** je veza na zaglavlje)


Projekt je nastao kao nadogradnja postojećeg scrapera u sklopu [Open Data Day 2018 hackathona](https://www.meetup.com/HrOpen/events/247705753/)

Izvor podataka: http://edoc.sabor.hr/

Datum pristupanja: 2018-03-04

  

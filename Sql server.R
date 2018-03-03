
# open connection using RODBC package
conn <- odbcDriverConnect('driver={SQL Server};
                          server=localhost;
                          database=TestDB;
                          trusted_connection=true')


# get croatian lexicon from local SQL Server
# previously downloaded from - http://nlp.ffzg.hr/resources/corpora/hrwac/
hrlex <- sqlQuery(conn, 
                  query = "SELECT * FROM [TestDB].[dbo].[hrLex_v1_2]",
                  stringsAsFactors=F, 
                  as.is=T)

# close connection
odbcClose(conn)
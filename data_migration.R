# TODO
# urediti datasetove

r_5 <- readRDS("RDS files/saziv_5_headeri.rds")
r_6 <- readRDS("RDS files/saziv_6_headeri.rds")
r_7 <- readRDS("RDS files/saziv_7_headeri.rds")
r_8 <- readRDS("RDS files/saziv_8_headeri.rds")
r_9 <- readRDS("RDS files/saziv_9_headeri.rds")

t_5 <- readRDS("RDS files/saziv_5_transkripti.rds")
t_6 <- readRDS("RDS files/saziv_6_transkripti.rds")
t_7 <- readRDS("RDS files/saziv_7_transkripti.rds")
t_8 <- readRDS("RDS files/saziv_8_transkripti.rds")
t_9 <- readRDS("RDS files/saziv_9_transkripti.rds")

# spremiCSV(r_5, "CSV export/rasprave_saziv_5.csv")
# spremiCSV(r_6, "CSV export/rasprave_saziv_6.csv")
# spremiCSV(r_7, "CSV export/rasprave_saziv_7.csv")
# spremiCSV(r_8, "CSV export/rasprave_saziv_8.csv")
# spremiCSV(r_9, "CSV export/rasprave_saziv_9.csv")
# 
# spremiCSV(t_5, "CSV export/transkripti_saziv_5.csv")
# spremiCSV(t_6, "CSV export/transkripti_saziv_6.csv")
# spremiCSV(t_7, "CSV export/transkripti_saziv_7.csv")
# spremiCSV(t_8, "CSV export/transkripti_saziv_8.csv")
# spremiCSV(t_9, "CSV export/transkripti_saziv_9.csv")

sve_rasprave <- rbind(r_5,r_6,r_7,r_8,r_9)
svi_transkripti <- rbind(t_5,t_6,t_7,t_8,t_9)






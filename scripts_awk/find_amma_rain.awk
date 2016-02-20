 #some examples of awk syntax for pulling out relevant columns of AMMA rainfall data.
 #call the awk program, format ";" semicolon delimited, when column $N gt -1 then print columns 
 #$N from file X.csv, print to screen or to a file. 

#check on the LIS7-Noah3.3 spinups
awk '$1=="Evap(kg" {print $4}' SURFACEMODEL.d01.stats>evapS1.txt


 awk -F";" '$23 > -1 {print $1, $2, $3, $23}' 132-CE.Rain_up*.csv | more
 awk -F";" '$18 > -1 {print $1, $2, $3, $18}' 132-CE.Rain_up*.csv > 132-CE.Rain_wankama1hr.csv
#the OFS denotes the output delimiter I guess
 awk -F";" -v OFS=',' '$18 > -1 {print $1, $2, $3, $18}' 132-CE.Rain_up*.csv > 132-CE.Rain_wankama1hr.csv 

#in this example I just wanted to pull out the lat lons that I was interested in and ignore all the header junk
awk -F";" -v OFS=',' '$3 ==-1.48 && !/#/ {print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11}' 171-CL.Rain_G.csv > Agoufou_171-CL.Rain_G.csv

#and then it turned out that many of the columns did not have data in them so i just kept col $6 with discharge/flow m3/s
awk -F";" -v OFS=',' '$3 ==2.6313 && !/#/ {print $1,$2,$3,$4,$6}' 163-CE.Run_Nc.csv > Wan_Zeamont_discharge.csv

#extract the rainfall values out of the Noahstats text file. Sheesh, should have figured this out sooner..
awk '$1=="Rainf_f(kg/m2s)" {print $1,$2}' NOAH32stats.d01.stats > rainstats.txt

#and to get the associated dates....
awk '$1=="Statistical" {print $7,$8,$9,$10,$11}' NOAH32stats.d01.stats | more

#and get rid of studpid inbetweeen stuff from ENVI output (this is how you get it..what is 'not'?)
awk '$1=="Histogram" || $5==1 {print $1, $2, $3, $4, $5}' testout.txt | more

#find out which sites are in one of the crazy text files
 awk '$2=="Platform:" {print $1,$2,$3,$4,$5,$6}' 108-CE.SWc_Nc.csv 

#apparently sed is better for extracting whole rows if you know the row number
sed -n '32682, 41199p' 210-CE.Swsan_Nc.csv > wankama_millet.csv
OR sed -n '1,57278p' SofiaBush15cm.csv> SofiaBush15cm_v2.csv

#pulling out specific depths and put them in individual files
awk -F";" -v OFS=',' '$5=="-0.68" {print $1,$2,$3,$5,$7}' WK1_gully108.csv>WK1_gully108_68cm.csv
awk -F";" -v OFS=',' '$5=="-0.97" {print $1,$2,$3,$5,$6}' WK1_gully108.csv | more

#just seeing in which columns the data is: '
awk -F";" '{print $1,$2,$3,$4,$5,$7}' TK_field.csv | more
awk -F";" '{print $1,$2,$3,$4,$16}' Belefoungou_131.csv | more

#now just give me specific depths, TK_filed has -0.7,-0.4,-1.0,-0.05,-1.35
awk -F";" -v OFS=',' '$5=="-0.05" {print $1,$2,$3,$5,$7}' TK_field.csv>TK_field108_05cm.csv

#in this example I just wanted to pull out the lat lons that I was interested in and ignore all the header junk
awk -F";" -v OFS=',' '$3 ==2.64920 && !/#/ {print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11}' 132-CE.Rain_Nc.csv | more 

#oh look this is almost exactly what I had in line3
awk -F";" -v OFS=',' '$3 ==2.64920 && !/#/ && $18 > -1 {print $1,$2,$3,$18}' 132-CE.Rain_Nc.csv>132-CE.Rain_wankama1hrv2.csv

awk -F";" -v OFS=',' '$3 ==2.64920 && !/#/ && $13 > -1 {print $1,$2,$3,$13}' 132-CE.Rain_Nc.csv>132-CE.Rain_wankama24hr_WKE.csv

#extracting soil moisture from the txt file to check on my spinup...same as the rainf_f example above #6
awk '$1=="SoilMoist(kg/m2)" {print $1,$2}' NOAH32stats.d01.stats>../spinupcheck/RF0soil.txt

#extract latent and sensible heat flux from the station rainfall runs. 
awk '$1=="Qle(W/m2)" {print $2}' NOAH32stats.d01.stats>../spinupcheck/WK3_Qle.txt

#extracting Evapotranspiration from the txt file to check on my spinup...same as the rainf_f example above #6
awk '$1=="Evap(kg/m2s)" {print $2}' NOAH32stats.d01.stats>../spinupcheck/WK3_evap.txt

#extracting Evapotranspiration from the txt file to check on my spinup...same as the rainf_f example above #6
awk '$1=="Rainf_f(kg/m2s)" {print $2}' NOAH32stats.d01.stats>../spinupcheck/WK3_rain.txt

#extract lines from the LIS-WRSI output file
awk '$1=="Rainf(kg/m2)" {print $2}' WRSIstats.d01.stats>../runcheck/EAchirps_rain_Pclim83.txt
awk '$1=="WRSI(-)" {print $2}' WRSIstats.d01.stats>../runcheck/EAchirps_wrsi_Pclim83.txt
awk '$1=="SWI(%)" {print $2}' WRSIstats.d01.stats>../runcheck/EAchirps_swi_Pclim83.txt
awk '$1=="PotEvap(kg/m2)" {print $2}' WRSIstats.d01.stats>../runcheck/EAchirps_pet_exp083.txt

awk '$1=="Rainf(kg/m2)" {print $2}' WRSIstats.d01.stats>/home/almcnall/EAka_rain.txt
awk '$1=="WRSI(-)" {print $2}' WRSIstats.d01.stats>/home/almcnall/EAka_wrsi.txt
awk '$1=="SWI(%)" {print $2}' WRSIstats.d01.stats>/home/almcnall/EAka_swi.txt

awk '$1=="Rainf(kg/m2)" {print $2}' WRSIstats.d01.stats>./EAtest_rain.txt
awk '$1=="WRSI(-)" {print $2}' WRSIstats.d01.stats>./EAtest_wrsi.txt
awk '$1=="SWI(%)" {print $2}' WRSIstats.d01.stats>./EAtest_swi.txt
awk '$1=="PotEvap(kg/m2)" {print $2}' WRSIstats.d01.stats>./EAtest_pet.txt
#Extracting the Belefoungou data using sed
sed -n '372268, 536859p' 131-CL.Rain_Od.csv

#try using wildcards in awk to get rid of unwanted rows
awk '$9 ~ /^9[0-2]/ { print $9 }' infile > outfile
awk '$2 ~ /00.00/' Belefoungou_131_daily.csv > Belefoungou_131_daily.csv


awk '$1 ~ /J/' inventory-shipped
awk '$2 ~ /00.00/' Belefoungou_131_daily.csv > Belefoungou_131_daily.csv

#use awk to help make the ENVI classmaps work in IDL
awk -F '[=)]' '{print $(NF-1)}' admin2_names
awk -F '[=)]' '{print $(NF-1)}' admin2_names>names.out
history | grep awk
awk -F '[=)]' '{print $(NF-1)}' Kenya_Admin2_namelist.txt 
awk -F '[=)]' '{print $(NF-1)}' temp_namelist.txt > Kenya_Admin2_namelist.txt


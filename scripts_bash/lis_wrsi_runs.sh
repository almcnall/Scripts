awk '$1=="Evap(kg" {print $4}' SURFACEMODEL.d01.stats > EA_OCTtest_evapS2.txt





#for the postprocessing bash script
sed -i 's/'EXPL12'/'EXPL13'/g' run_daily_list_EAwrsi.sh
sed -i 's/'year=2012'/'year=2013'/g' run_daily_list_EAwrsi.sh
grep "year=" run_daily_list_EAwrsi.sh
grep "EXPL13'" run_daily_list_EAwrsi.sh
source run_daily_list_EAwrsi.sh

#then for the OND forecast runs i need to run in the 2013, 2014 directories
#that are linked to 3013,14  3015,16  3017,18
#for the MAM hindcasts I can just use the 2014 climatology but then need to fill in Aug 2014 (with 2013?)
# I will have questions on this for greg and shrad but i guess get it set up for now.

#do this for the odd numbers 
y=2014
oldyr=2013
cd $oldyr
  for i in $( ls all_products.bin.2013{04,05,06,07}*); do
    mmdd=${i:21:4}
    ln -s ../$oldyr/$i "../$y/all_products.bin.2014$mmdd"
  done





#make 2014 link to each of the sims that greg made
#then link Aug-Dec with 2013.

#12/30/13: copy files to new dir
#remove the 2013 estimates (first 48 line) 
sed -i '2,47d' sim_link_sim0*
#fill out the rest of the year with 2003, I guess I do this in the next step

#so this line should fill in the sim links where i want them aye?
for i in $(ls sim/sim_link_sim????.bsh);do source $i; done
#first make the links in the first(odd) simulation folders (3013, 3015, 3017..)
#then fill in with links from simulations 

#so i think that this loop will fill in the end of 2014 with values from 2003
#I don't neeed to do two years for this. but maybe i should just to stay consistant.

#first have to mkdirs 3014 thru 3072 (I usu. delete these when i am over quota) 
for y in {3013..3072};do
  mkdir $y
done

#do this for the even numbers 
for y in `seq 3014 2 3072`; do
 oldyr=2003
  cd $oldyr
  for i in $( ls all_products.bin.2003{08,09,10,11,12}*); do
    mmdd=${i:21:4}
    ln -s ../$oldyr/$i "../$y/all_products.bin.2014$mmdd"
  done
  cd ..
done

#do this for the odd numbers 
for y in `seq 3013 2 3072`; do
 oldyr=2003
  cd $oldyr
  for i in $( ls all_products.bin.2003{01,02}*); do
    mmdd=${i:21:4}
    ln -s ../$oldyr/$i "../$y/all_products.bin.2015$mmdd"
  done
  cd ..
done

#then just make the soft links to 2014, 2015?
rm ../input/CHIRPS/Africa/2014 ../input/CHIRPS/Africa/2015

SY=3071 #start year
EY=`expr $SY + 1` #end year
PY=`expr $SY - 1` #previous year 
ln -s $SY 2013
ln -s $EY 2014
l 2013 2014



#remove the first 10 days of November 
sed -i '2,6d' sim_link_sim0*
# source all of the sim links 
for i in $(ls sim/sim_link_sim????.bsh);do source $i; done
#first make the links in the first(odd) simulation folders (3013, 3015, 3017..)
#then fill in with links from simulations 
for y in `seq 3013 2 3072`; do
 oldyr=2013_org
  cd $oldyr
  for i in $( ls all_products.bin.2013{06,07,08,09,10,11}*); do
    mmdd=${i:21:4}
    ln -s ../$oldyr/$i "../$y/all_products.bin.2013$mmdd"
  done
  cd ..
done
#ok, all my source files are. now i just need to change what is 2013/14
#increment
#In the CHIRPS directory

rm ../input/CHIRPS/Africa/2013 ../input/CHIRPS/Africa/2014
SY=3071 #start year
EY=`expr $SY + 1` #end year
PY=`expr $SY - 1` #previous year 
ln -s $SY 2013
ln -s $EY 2014
l 2013 2014

#SOS RUN
 i=29
 j=`expr $i - 1`
 sed -i 's/'N$j'/'N$i'/g' lis.config_sos_OND
 sed -i 's/\(WRSI model CalcSOS lsm run mode: \+\) 0/\1 1/g' lis.config_sos_OND
 grep CalcSOS lis.config
 grep code lis.config
 qsub lis.job
 
#WRSI RUN
 sed -i 's/WRSI model CalcSOS lsm run mode:  1/WRSI model CalcSOS lsm run mode:  0/g' lis.config_sos_OND
 grep CalcSOS lis.config
qsub lis.job


awk '$1=="Rainf(kg/m2)" {print $2}' WRSIstats.d01.stats>./EAtest_rain.txt
 sed -i 's/'N$j'/'N$i'/g' lis.config_sos_OND
 sed -i 's/\(WRSI model CalcSOS lsm run mode: \+\) 0/\1 1/g' lis.config_sos_OND
 grep CalcSOS lis.config
 grep code lis.config
 qsub lis.job
 
#WRSI RUN
 sed -i 's/WRSI model CalcSOS lsm run mode:  1/WRSI model CalcSOS lsm run mode:  0/g' lis.config_sos_OND
 grep CalcSOS lis.config
qsub lis.job


awk '$1=="Rainf(kg/m2)" {print $2}' WRSIstats.d01.stats>./EAtest_rain.txt
awk '$1=="WRSI(-)" {print $2}' WRSIstats.d01.stats>./EAtest_wrsi.txt
awk '$1=="SWI(%)" {print $2}' WRSIstats.d01.stats>./EAtest_swi.txt
awk '$1=="PotEvap(kg/m2)" {print $2}' WRSIstats.d01.stats>./EAtest_pet.txt
vi EAtest_wrsi.txt

 y=2013
 ym1=`expr $y - 1`
 ym2=`expr $y - 2`
 yp1=`expr $y + 1`
 yy=${y:2:2}
 yym1=`expr $yy - 1`
 sed -i 's/InitialYear '$ym1'/InitialYear '$y'/g' ../input/GeoWRSI_OUTPUT/EA_May2Nov_2009_maize/GeoWRSI_userSettings.txt
 sed -i 's/'L$yym1'/'L$yy'/g' lis.config_long
 sed -i 's/\(Starting year: \+\)'$ym1'/\1'$y'/g' lis.config_long
 sed -i 's/\(Ending year: \+\)'$y'/\1'$yp1'/g' lis.config_long
 sed -i 's/\(WRSI last current year: \+\)'$y'/\1'$yp1'/g' lis.config_long
 sed -i 's/\(WRSI model CalcSOS lsm run mode: \+\) 0/\1 1/g' lis.config_long

grep code lis.config
grep Initial lis.config
grep Starting lis.config
grep Ending lis.config
grep CalcSOS lis.config
grep Initial ../input/GeoWRSI_OUTPUT/EA_May2Nov_2009_maize/GeoWRSI_userSettings.txt

#and when you mess up this file....
# sed -i 's/InitialYear '$y'/InitialYear '$ym1'/g' ../input/GeoWRSI_OUTPUT/EA_May2Nov_2009_maize/GeoWRSI_userSettings.txt

qsub lis.job
tail -f lisdiag.0000
 sed -i 's/WRSI model CalcSOS lsm run mode:  1/WRSI model CalcSOS lsm run mode:  0/g' lis.config_long
grep CalcSOS lis.config

qsub lis.job

awk '$1=="Rainf(kg/m2)" {print $2}' WRSIstats.d01.stats>./EAtest_rain2.txt
awk '$1=="WRSI(-)" {print $2}' WRSIstats.d01.stats>./EAtest_wrsi2.txt
awk '$1=="SWI(%)" {print $2}' WRSIstats.d01.stats>./EAtest_swi.txt
awk '$1=="PotEvap(kg/m2)" {print $2}' WRSIstats.d01.stats>./EAtest_pet.txt
vi EAtest_wrsi.txt

#older stuff
#this is how i had it before ian regular expressioned it up
sed -i 's/Starting year:                      '$ym2'/Starting year:                      '$ym1'/g' lis.config_MAM
sed -i 's/Ending year:                        '$ym1'/Ending year:                        '$y'/g' lis.config_MAM
sed -i 's/WRSI last current year:          '$ym1'/WRSI last current year:          '$y'/g' lis.config_MAM
sed -i 's/WRSI model CalcSOS lsm run mode:  0/WRSI model CalcSOS lsm run mode:  1/g' lis.config_MAM


rm lis.config
ln -s lis.config_sos lis.config
vi lis.config
#how do i change specific lines in a text file?
(line number:)
 42:Experiment code:                 '084'
 58:Starting year:                      2084
 64:Ending year:                        2085
143: WRSI user input settings file:  ../input/GeoWRSI_OUTPUT/EA_Oct2Feb_208485/GeoWRSI_userSettings.txt
152: WRSI last current year:          2085

#update the GeoWRSI_userSettings.txt
cp -r ../input/GeoWRSI_OUTPUT/EA_Oct2Feb_400910/ ../input/GeoWRSI_OUTPUT/EA_Oct2Feb_200304/
vi ../input/GeoWRSI_OUTPUT/EA_Oct2Feb_200304/GeoWRSI_userSettings.txt
#
19: InitialYear 2084
##make sure the last run was a wrsi run
tail -20 lisdiag.0000
#
##submit sos_run
qsub lis.job
#change the wrsi/sos swtich 0-1
vi lis.config
qsub lis.job
#
#CHECK on the previous run before submitting SOS
cd OUTPUT/
cd EXP085/

awk '$1=="Rainf(kg/m2)" {print $2}' WRSIstats.d01.stats>./EAtest_rain.txt
awk '$1=="WRSI(-)" {print $2}' WRSIstats.d01.stats>./EAtest_wrsi.txt
awk '$1=="SWI(%)" {print $2}' WRSIstats.d01.stats>./EAtest_swi.txt
awk '$1=="PotEvap(kg/m2)" {print $2}' WRSIstats.d01.stats>./EAtest_pet.txt
152: WRSI last current year:          2085

#check on the sos run before the wrsi run
tail -f lisdiag.0000

#then run the wrsi part
rm lis.config
ln -s lis.config_wrsi lis.config
qsub lis.job


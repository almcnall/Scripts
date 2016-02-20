#!/bin/bash

#this file is used to make a list of year/dates for the files
#that need to be read into the 'daily_total_gs4r_v3.pro' and 'flip_'


exp_num='EXPL00'
nx=285           #the more i can put in this bash file the less will need to be replicated between idl scripts 
ny=339
nbands=40

v=${exp_num:3:5} #last two digits

out_file='run_daily_'$v'.pro' #the idl scrip that will feed preprocess
out_file=${out_file//[[:space:]]} #rm the spaces

echo 'pro run_daily_'$v'' > /home/source/mcnally/scripts_idl/$out_file #first line of script

#for year in {2093..2094};do #years in exp
year=2000
  #cd /gibber/lis_data/RFE2_UMDVeg/output/$exp_num/NOAH32/$year
   # cd /jower/LIS/OUTPUT/$exp_num/NOAH271/$year
   cd /raid/chg-mcnally/LISWRSI_OUTPUT/longrains/$exp_num/WRSI/$year 
    for i in $( ls );do #look at the list
      year=${i:0:4} #extract the year
      date=$i       #extract the date
      echo "flip_af_gs4r_wrsi,\" $year\", \" $date\",\"$exp_num\", $nx,$ny,$nbands " >> /home/source/mcnally/scripts_idl/$out_file #write to file

    done #ls
 # done  #yr

echo "end" >> /home/source/mcnally/scripts_idl/$out_file

cd /home/source/mcnally/scripts_bash/

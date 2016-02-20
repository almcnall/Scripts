#!/bin/bash

#this file is used to make a list of year/dates for the files
#that need to be read into the 'daily_total_gs4r_v3.pro' and 'flip_'


exp_num='EXPN01' #dealing with output from which exp?
nx=300           #the more i can put in this bash file the less will need to be replicated between idl scripts 
ny=320
nbands=17

v=${exp_num:3:5} #last two digits

out_file='run_daily_'$v'.pro' #the idl scrip that will feed preprocess
out_file=${out_file//[[:space:]]} #rm the spaces

echo 'pro run_daily_'$v'' > /home/source/mcnally/scripts_idl/$out_file #first line of script

 for year in {2004..2006};do #years in exp
   #cd /gibber/lis_data/RFE2_UMDVeg/output/$exp_num/NOAH32/$year
    cd /gibber/lis_data/OUTPUT/$exp_num/NOAH/$year
    for i in $( ls );do #look at the list
      year=${i:0:4} #extract the year
      date=$i       #extract the date
      echo "daily_total_gs4r_NLSM01,\" $year\", \" $date\",\"$exp_num\", $nx,$ny,$nbands " >> /home/source/mcnally/scripts_idl/$out_file #write to file

    done #ls
  done  #yr

echo "end" >> /home/source/mcnally/scripts_idl/$out_file

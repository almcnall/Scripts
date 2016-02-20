#!/bin/bash

#******updated on April 16,2014 to grab ARC2 data*******

#********Aug 12,2010***********
# script to retrieve the CPC/Famine Early Warning System
# Daily Estimates from ftp://ftp.cpc.ncep.noaa.gov/fews/newalgo_est/
# start with Spetember 2009 and then add more if it works

#Made separate year directories and downloaded all of 2008 (AM 8/16)
#Separate dir don't work. All need to be in one file
#Downloaded Jan-Feb 2009 to be able to look at a full year for cmap,gdas,rfe comparison
#****************************

cd /home/sandbox/people/mcnally/ARC2/

#year="2001"
file="ftp://ftp.cpc.ncep.noaa.gov/fews/fewsdata/africa/arc2/bin/daily_clim.bin."

for year in {2011..2013}; do
#for year in 2012; do
 for i in {1..12}; do 
     month="$i"
     if [ "$month" -lt "10" ]; then #double digit month
      wget $file$year"0"$month*
     else
       wget $file$year$month*
     fi
  done #month 
done  #year


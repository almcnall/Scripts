#!/bin/bash

#********May4 2012***********
# script to retrieve the CPC/Famine Early Warning System
# hazards assessments from 2001 to present
#****************************

cd /jabber/sandbox/mcnally/africa_hazards/

file="ftp://ftp.cpc.ncep.noaa.gov/fews/threats/"
wget $file*

#for year in {2008..2010}; do
for year in {2011..2012}; do
 for i in {1..12}; do 
     month="$i"
     if [ "$month" -lt "10" ]; then #double digit month
      wget $file$year"0"$month*
     else
       wget $file$year$month*
     fi
  done #month 
done  #year


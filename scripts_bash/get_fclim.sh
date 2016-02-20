#!/bin/bash

#********Aug 12,2010***********
# script to retrieve the CPC/Famine Early Warning System
# Daily Estimates from ftp://ftp.cpc.ncep.noaa.gov/fews/newalgo_est/
# start with Spetember 2009 and then add more if it works

#Made separate year directories and downloaded all of 2008 (AM 8/16)
#Separate dir don't work. All need to be in one file
#Downloaded Jan-Feb 2009 to be able to look at a full year for cmap,gdas,rfe comparison
#****************************

cd /jabber/LIS/Data/FCLIMv4

#year="2001"
file='ftp://hollywood.geog.ucsb.edu/pub/andrew/amy/FCLIMv4/amy/'

wget $file*
  
 





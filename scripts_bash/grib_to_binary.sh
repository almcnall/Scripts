#!/bin/bash

#********Aug 5, 2010****************
# This script extracts the relevant records into indv binary files
# and ACII text I'll test it on Nov 11, 2009
# for the variables needed for RefET equation
#**********************************
year="2009"
month="11"
day="11"

cd /jower/LIS/RUN/GDAS/$year$month

 for i in $( ls $year$month$day*); do 
   #binary (intel (little) float 1152x576, no header -nh)
    wgrib $i | grep "^1:" | wgrib -i -nh $i -o binary/$i.DLWRF
    wgrib $i | grep "^3:" | wgrib -i -nh $i -o binary/$i.DSWRF
    wgrib $i | grep "^7:" | wgrib -i -nh $i -o binary/$i.UGRD
    wgrib $i | grep "^9:" | wgrib -i -nh $i -o binary/$i.VGRD
    wgrib $i | grep "^11:" | wgrib -i -nh $i -o binary/$i.TEMP
    wgrib $i | grep "^12:" | wgrib -i -nh $i -o binary/$i.SPFH
    wgrib $i | grep "^13:" | wgrib -i -nh $i -o binary/$i.PRES
    wgrib $i | grep "^29:" | wgrib -i -nh $i -o binary/$i.ULWRF
    wgrib $i | grep "^31:" | wgrib -i -nh $i -o binary/$i.USWRF
    wgrib $i | grep "^36:" | wgrib -i -nh $i -o binary/$i.PEVPR

   #and ACII
    wgrib $i | grep "^1:" | wgrib -i -text -nh $i -o ASCII/$i.DLWRF
    wgrib $i | grep "^3:" | wgrib -i -text -nh $i -o ASCII/$i.DSWRF
    wgrib $i | grep "^7:" | wgrib -i -text -nh $i -o ASCII/$i.UGRD
    wgrib $i | grep "^9:" | wgrib -i -text -nh $i -o ASCII/$i.VGRD
    wgrib $i | grep "^11:" | wgrib -i -text -nh $i -o ASCII/$i.TEMP
    wgrib $i | grep "^12:" | wgrib -i -text -nh $i -o ASCII/$i.SPFH
    wgrib $i | grep "^13:" | wgrib -i -text -nh $i -o ASCII/$i.PRES
    wgrib $i | grep "^29:" | wgrib -i -text -nh $i -o ASCII/$i.ULWRF
    wgrib $i | grep "^31:" | wgrib -i -text -nh $i -o ASCII/$i.USWRF
    wgrib $i | grep "^36:" | wgrib -i -text -nh $i -o ASCII/$i.PEVPR
 done

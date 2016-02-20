#!/bin/bash

#*****Oct 21, 2010************
# this script makes the monthly cubes i.e. cat all jauarys from 2001-2009
#***************************

exp=020
name='trmm'
#code=prcp #cmap month cube

output=/gibber/lis_data/OUTPUT/EXP$exp/NOAH/janfeb_cube_$name
mkdir $output
wkdir=/gibber/lis_data/OUTPUT/EXP$exp/NOAH/month_total_units


month=(01 02)
var=(airtem evap rain)
for (( j=0;j<${#var[@]}; j++));do #for each variable
 for (( i=0; i<${#month[@]}; i++ )); do  #for jan-feb
  cd $wkdir
  cp $(ls ${var[j]}*${month[i]}_tot.img) $output
  #cp $(ls *${month[i]}.1gd4r) $output
  cd $output
  rm -f ${var[j]}_2009* #Jan and Feb 2009 need to be removed from cube
  cat $( ls ${var[j]}*_tot.img ) > ${var[j]}_$name.img
  #cat $( ls *${month[i]}.1gd4r) > 'prcp03_08_'${month[i]}_$name.img
 done
rm *tot.img
done

#!/bin/bash

#*****Oct 21, 2010************
# this script makes the monthly cubes i.e. cat all jauarys from 2001-2009
#***************************

#exp='EXPORC'
#name='RFE2_DynCrop'

#exp='EXPORS'
#name='RFE2_StaticRoot'

exp='EXPORU'
name='RFE2_UMDVeg'
#code=prcp #cmap month cube

wkdir=/gibber/lis_data/$name/output/$exp/NOAH32/month_total_units/
output=/gibber/lis_data/$name/output/$exp/NOAH32/monthcube_$name/
#output=/gibber/lis_data/OUTPUT/EXP$exp/NOAH/month_cube_$name
#mkdir $output

month=(01 02 03 04 05 06 07 08 09 10 11 12)
var=(rain evap root sm01 sm02 sm03 sm04 tair PoET)

for (( j=0;j<${#var[@]}; j++));do #for each variable
 for (( i=0; i<${#month[@]}; i++ )); do  #for all the months
  cd $wkdir
  cp $(ls ${var[j]}*${month[i]}_tot.img) $output
  #cp $(ls *${month[i]}.1gd4r) $output
  cd $output
  #rm -f ${var[j]}_2009* #Jan and Feb 2009 need to be removed from cube
  cat $( ls ${var[j]}*${month[i]}_tot.img ) > ${var[j]}${month[i]}_$name.img
  #cat $( ls *${month[i]}.1gd4r) > 'prcp03_08_'${month[i]}_$name.img
 done
rm *tot.img
done

#!/bin/bash

wkdir=/jabber/LIS/Data/CPCOriginalRFE2/
output=/jabber/LIS/Data/CPCOriginalRFE2/monthcubie/

month=(01 02 03 04 05 06 07 08 09 10 11 12)
year=(2001 2002 2003 2004 2005 2006 2007 2008 2009 2010)

 for (( i=0; i<${#month[@]}; i++ )); do  #for all the months
  for ((j=0; j<${#year[@]}; j++));do # for all years
    cd $wkdir
    cp all_products.bin.${year[j]}${month[i]}* $output
    cd $output
    cat all_products.bin.${year[j]}${month[i]}*>RFE2_${year[j]}${month[i]}.img
    rm -f all_products.bin.${year[j]}${month[i]}
   done
done

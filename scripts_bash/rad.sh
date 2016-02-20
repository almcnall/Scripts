#!/bin/bash

#the purpose of this program is to get the rad data in a format that I 
#can deal with > from 3 hrly to DOYearly

wave='shortwave' #or longwave

wkdir=/gibber/sandbox/mcnally/$wave
cd $wkdir

for yr in {2001..2009};do
  for d in {100..366}; do
    cat 3HGLDAS$yr$d* >> daycubie/3HGLDAS$yr$d.img
  done
done

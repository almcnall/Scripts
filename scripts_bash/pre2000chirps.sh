#!/bin/bash

#***this renames the CHIRPS pre-2000 to 2083, 2084 etc 

for y in {2091..2099}; do
  oldyr='19'${y:2:2}
  cd $oldyr
  for i in $( ls all*); do
    mmdd=${i:21:4}
    ln -s ../$oldyr/$i "../$y/all_products.bin.$y$mmdd"
  done
  cd ..
done

# special case for 1999-2000
 y=2015
  oldyr=2000
  cd $oldyr
  for i in $( ls all*); do
    mmdd=${i:21:4}
    ln -s ../$oldyr/$i "../$y/all_products.bin.$y$mmdd"
  done

# filling in the forecast folders....
for y in {3013..3015}; do 
y=3014
 oldyr=2013_org
  cd $oldyr
  for i in $( ls all_products.bin.2013{06,07,08,09,10,11}*); do
    mmdd=${i:21:4}
    ln -s ../$oldyr/$i "../$y/all_products.bin.2013$mmdd"
  done
  cd ..
done












#********************************
#make links for pet directories 1985 to 1999
ln -s 1985 2085
ln -s 1986 2086
ln -s 1987 2087
ln -s 1988 2088
ln -s 1989 2089
ln -s 1990 2090
ln -s 1991 2091
ln -s 1992 2092
ln -s 1993 2093
ln -s 1994 2094
ln -s 1995 2095
ln -s 1996 2096
ln -s 1997 2097
ln -s 1998 2098
ln -s 1999 2099
ln -s 2000 2100


#********************************************
for i in $( ls et*.bil );do 
#  for y in {1983..2013};do 
y=2014
    yr=${y:2:2} 
    mmdd=${i:4:8}
    ln -s ../$i $y/et$yr$mmdd
  done
done

#for the hdr file 
j=et010101.hdr
for i in $( ls et*.bil );do
  y=2014
    yr=${y:2:2}
    mmdd=${i:4:5}'hdr'
    ln -s ../$j $y/et$yr$mmdd
  done

for i in $( ls et*.bil );do
  y=2016
    yr=${y:2:2}
    mmdd=${i:4:8}
    ln -s ../$i $y/et$yr$mmdd
  done


#for the leap years
#for the bil file....
#leap=[1984,1988,1992,1996,2000,2004,2008,2012]
i=etXX0229.bil_leap
  for y in {1984,1998,1992,1996,2000,2004,2008,2012};do
    yr=${y:2:2}
    mmdd=${i:4:8}
    ln -s ../$i $y/et$yr$mmdd
  done

#for the hdr file 
j=et010101.hdr
for i in $( ls et??0229.bil_leap );do
  for y in {1984,1998,1992,1996,2000,2004,2008,2012};do
    yr=${y:2:2}
    mmdd=${i:4:5}'hdr'
    ln -s ../$j $y/et$yr$mmdd
  done
done

#change everything pre-2000 to post-2000 becasue LIS won't read it :(
#actaull it is from Oct. 30 2000 onwards. I think make 1983 into 2083?

#
mv 1984 2084
cd 2084
for i in $( ls all*); do
  mmdd=${i:21:4}
  YYYY=2084
  ln -s $i all_products.bin.$YYYY$mmdd
done  

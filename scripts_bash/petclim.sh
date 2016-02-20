#!/bin/bash

#***this renames the climatological PET for each chirps year 1983-present

petIN=/discover/nobackup/projects/lis/Projects/FEWSNET/GeoWRSI_FORCING/pet/

#I should either match up the dek and mmdd or make sure
#that there are 36 deks per year. 

#for the bil file....
for i in $( ls et*.bil );do 
  for y in {1983..2013};do 
    yr=${y:2:2} 
    mmdd=${i:4:8}
    ln -s ../$i $y/et$yr$mmdd
  done
done

#for the hdr file 
j=et010101.hdr
for i in $( ls et*.bil );do
  for y in {1983..2013};do
    yr=${y:2:2}
    mmdd=${i:4:5}'hdr'
    ln -s ../$j $y/et$yr$mmdd
  done
done

#for the leap years
#for the bil file....
#leap=[1984,1988,1992,1996,2000,2004,2008,2012]
i=etXX0229.bil_leap
  for y in {1984,1998,1992,1996,2000,2004,2008,2012};do
    y=2016
    yr=${y:2:2}
    mmdd=${i:4:8}
    ln -s ../$i $y/et$yr$mmdd
  done

#for the hdr file 
j=et010101.hdr
for i in $( ls et??0229.bil_leap );do
  for y in {1984,1998,1992,1996,2000,2004,2008,2012};do
    y=2016
    yr=${y:2:2}
    mmdd=${i:4:5}'hdr'
    ln -s ../$j $y/et$yr$mmdd
  done
done

#****2000 to 2100******
#for the bil file....
for i in $( ls et*.bil );do
  y=2000
    yr=00
    mmdd=${i:4:8}
    ln -s ../$i $y/et$yr$mmdd
done

#for the hdr file 
j=et010101.hdr
for i in $( ls et*.bil );do
   y=2000
    yr=00
    mmdd=${i:4:5}'hdr'
    ln -s ../$j $y/et$yr$mmdd
  done




#2000 is a leap year too...
i=etXX0229.bil_leap
  for y in {1984,1988,1992,1996,2000,2004,2008,2012};do
    y=1988
    yr=${y:2:2}
    mmdd=${i:4:8}
    ln -s ../$i $y/et$yr$mmdd
  done

#2000 to 2100 for the hdr file 
j=et010101.hdr
for i in $( ls et??0229.bil_leap );do
  for y in {1984,1988,1992,1996,2000,2004,2008,2012};do
    y=1988
    yr=${y:2:2}
    mmdd=${i:4:5}'hdr'
    ln -s ../$j $y/et$yr$mmdd
  done
done


#change everything pre-2000 to post-2000 becasue LIS won't read it :(
#actaull it is from Oct. 30 2000 onwards. I think make 1983 into 2083?

#
mv 1984 2084
cd 4009
for i in $( ls all*); do
  mmdd=${i:21:4}
  YYYY=1999
  ln -s $i all_products.bin.$YYYY$mmdd
done  

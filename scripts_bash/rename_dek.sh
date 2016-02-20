#!/bin/bash


exp=EXP015
name=cmap

wkdir=/gibber/lis_data/OUTPUT/$exp/TEMPLATE/dekads_$name
outdir=/gibber/lis_data/OUTPUT/$exp/TEMPLATE/$name_year_dek

deks=[dek1 dek2 dek3]

cd $wkdir

for i in {2001...2009}
  dek=0
 
for j in $( ls $i*.img);do
  dek=dek+1 #needs to restart every year
  ln -s $wkdir$ 
#for i in {2001..2009}; do
#    for j in 01 02 03 04 05 06 07 08 09 10 11 12; do 
#      mkdir $i$j
#    done
#done

trmmdir=/jower/dews/Data/TRMM/3B42/3-hourly

cd $trmmdir

for k in {2007..2009};do   
  cd y$k  #pete's dirs are called e.g. y2001
  
  # the l loop takes care of the two digit hours and the m loop does
  # the one digit hours, year 2001-2007/04 need the "A" in 6A but 
  # 2007/05-2009 do. 
  
 # for l in $( ls *12.6A.HDF *15.6A.HDF *18.6A.HDF *21.6A.HDF );do   #for each file 
  #   YY=${l:5:2}             #extract the year, month, day, hr
  #   MM=${l:7:2}
  #   DD=${l:9:2}
  #   HH=${l:12:2}
    
     
  # ln -s $trmmdir/y$k/$l $wkdir/$k$MM/3B42V6.20$YY$MM$DD$HH
  # cd $trmmdir
  # done #l loop
   
   for m in $( ls *0.6A.HDF *3.6A.HDF *6.6A.HDF *9.6A.HDF );do   #for each file
     YY=${m:5:2}             #extract the year, month, day, hr
     MM=${m:7:2}
     DD=${m:9:2}
     H1=${m:12:1}
 
    ln -s $trmmdir/y$k/$m $wkdir/$k$MM/3B42V6.20$YY$MM$DD'0'$H1
      cd $trmmdir
   done #m loop
done #k loop

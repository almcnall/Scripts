#!/bin/bash

#***Aug 17,2011****
# this script soft links ubrfe2 files into the gridded rain directory
# /jabber/LIS/Data/AMMArfe_grid where I have replaced some pixels with
# station averages. 
#*****************

indir=/jabber/LIS/Data/ubRFE2/
outdir=/jabber/LIS/Data/AMMArfe_grid/
cd $indir
#cd $outdir
 for i in {20..31};do
   for j in $( ls *200312$i*);do
  ln -s $indir$j $outdir$j
  # rm -f $j
 done
done

#!/bin/bash

#********May 30 2012***********
# script to retrieve Bo's data that I can then convert to img files from 
# ftp://chg-ftpout.geog.ucsb.edu/pub/org/chg/people/bo_romero/Global_Eval/RESULTS/Precip/
# not sure what all these directories are. Opps, turns out that things that say 'chg-ftpout' are actually
# rain already...no we have duplicates..
#****************************

cd '/raid/sandbox/mcnally/bils_from_bo/01'
file="ftp://chg-ftpout.geog.ucsb.edu/pub/org/chg/people/bo_romero/Global_Eval/RESULTS/Precip/01"
wget $file/*

#change i to match the month directory.....
i=12
cd '/raid/sandbox/mcnally/bils_from_bo/'$i 
file="ftp://chg-ftpout.geog.ucsb.edu/pub/org/chg/people/bo_romero/Global_Eval/RESULTS/Precip/"$i
wget $file/*




#!/bin/bash

#***Aug 17,2011****
# this script soft links ubrfe2 files into the gridded rain directory
# /jabber/LIS/Data/AMMArfe_grid where I have replaced some pixels with
# station averages. 
#*****************
#modified on April 12, 2012 to make trmm symbolic links to the dir where I have the gridded station data. 
#might be more trouble to change it, not sure why the code looks like this just for days 20-31..

#indir=/jower/LIS/data/TRMM_amy/
#outdir=/jabber/Data/mcnally/AMMARain/WankamaEast_grid/
#cd $indir
#cd $outdir

# for i in {20..31};do
#   for j in $( ls *2001*$i*);do
#    ln -s $indir$j $outdir$j
#    rm -f $j
#   done
# done


ln -s	 /jower/LIS/data/TRMM_amy/200101/	./200101
ln -s	 /jower/LIS/data/TRMM_amy/200102/	./200102
ln -s	 /jower/LIS/data/TRMM_amy/200103/	./200103
ln -s	 /jower/LIS/data/TRMM_amy/200104/	./200104
ln -s	 /jower/LIS/data/TRMM_amy/200105/	./200105
ln -s	 /jower/LIS/data/TRMM_amy/200106/	./200106
ln -s	 /jower/LIS/data/TRMM_amy/200107/	./200107
ln -s	 /jower/LIS/data/TRMM_amy/200108/	./200108
ln -s	 /jower/LIS/data/TRMM_amy/200109/	./200109
ln -s	 /jower/LIS/data/TRMM_amy/200110/	./200110
ln -s	 /jower/LIS/data/TRMM_amy/200111/	./200111
ln -s	 /jower/LIS/data/TRMM_amy/200112/	./200112
ln -s	 /jower/LIS/data/TRMM_amy/200201/	./200201
ln -s	 /jower/LIS/data/TRMM_amy/200202/	./200202
ln -s	 /jower/LIS/data/TRMM_amy/200203/	./200203
ln -s	 /jower/LIS/data/TRMM_amy/200204/	./200204
ln -s	 /jower/LIS/data/TRMM_amy/200205/	./200205
ln -s	 /jower/LIS/data/TRMM_amy/200206/	./200206
ln -s	 /jower/LIS/data/TRMM_amy/200207/	./200207
ln -s	 /jower/LIS/data/TRMM_amy/200208/	./200208
ln -s	 /jower/LIS/data/TRMM_amy/200209/	./200209
ln -s	 /jower/LIS/data/TRMM_amy/200210/	./200210
ln -s	 /jower/LIS/data/TRMM_amy/200211/	./200211
ln -s	 /jower/LIS/data/TRMM_amy/200212/	./200212
ln -s	 /jower/LIS/data/TRMM_amy/200301/	./200301
ln -s	 /jower/LIS/data/TRMM_amy/200302/	./200302
ln -s	 /jower/LIS/data/TRMM_amy/200303/	./200303
ln -s	 /jower/LIS/data/TRMM_amy/200304/	./200304
ln -s	 /jower/LIS/data/TRMM_amy/200305/	./200305
ln -s	 /jower/LIS/data/TRMM_amy/200306/	./200306
ln -s	 /jower/LIS/data/TRMM_amy/200307/	./200307
ln -s	 /jower/LIS/data/TRMM_amy/200308/	./200308
ln -s	 /jower/LIS/data/TRMM_amy/200309/	./200309
ln -s	 /jower/LIS/data/TRMM_amy/200310/	./200310
ln -s	 /jower/LIS/data/TRMM_amy/200311/	./200311
ln -s	 /jower/LIS/data/TRMM_amy/200312/	./200312
ln -s	 /jower/LIS/data/TRMM_amy/200401/	./200401
ln -s	 /jower/LIS/data/TRMM_amy/200402/	./200402
ln -s	 /jower/LIS/data/TRMM_amy/200403/	./200403
ln -s	 /jower/LIS/data/TRMM_amy/200404/	./200404
ln -s	 /jower/LIS/data/TRMM_amy/200405/	./200405
ln -s	 /jower/LIS/data/TRMM_amy/200406/	./200406
ln -s	 /jower/LIS/data/TRMM_amy/200407/	./200407
ln -s	 /jower/LIS/data/TRMM_amy/200408/	./200408
ln -s	 /jower/LIS/data/TRMM_amy/200409/	./200409
ln -s	 /jower/LIS/data/TRMM_amy/200410/	./200410
ln -s	 /jower/LIS/data/TRMM_amy/200411/	./200411
ln -s	 /jower/LIS/data/TRMM_amy/200412/	./200412
ln -s	 /jower/LIS/data/TRMM_amy/200901/	./200901
ln -s	 /jower/LIS/data/TRMM_amy/200902/	./200902
ln -s	 /jower/LIS/data/TRMM_amy/200903/	./200903
ln -s	 /jower/LIS/data/TRMM_amy/200904/	./200904
ln -s	 /jower/LIS/data/TRMM_amy/200905/	./200905
ln -s	 /jower/LIS/data/TRMM_amy/200906/	./200906
ln -s	 /jower/LIS/data/TRMM_amy/200907/	./200907
ln -s	 /jower/LIS/data/TRMM_amy/200908/	./200908
ln -s	 /jower/LIS/data/TRMM_amy/200909/	./200909
ln -s	 /jower/LIS/data/TRMM_amy/200910/	./200910
ln -s	 /jower/LIS/data/TRMM_amy/200911/	./200911


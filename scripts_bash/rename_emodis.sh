#!/bin/bash
#not the ideal renaming system -- for cmorph it made mmyyyy files, weird
wkdir='/jabber/LIS/Data/CMORPH/'
cd $wkdir

for i in $( ls *1gd4r); do
 mv $i ${i//jan/01}
 mv $i ${i//feb/02}
 mv $i ${i//mar/03}
 mv $i ${i//apr/04}
 mv $i ${i//may/05}
 mv $i ${i//jun/06}
 mv $i ${i//jul/07}
 mv $i ${i//aug/08}
 mv $i ${i//sep/09}
 mv $i ${i//oct/10}
 mv $i ${i//nov/11}
 mv $i ${i//dec/12}

 yy=${i:2:4} 
 mm=${i:0:2}

 mv $i $yy$mm
done



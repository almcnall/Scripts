#!/bin/bash

#******Sept 11,2010********
#script to concatinate output from experiments that have been 
#averaged by month. This will also rename the files w.r.t. the experiment
#current output has all the same file names but it different directories
# e.g. EXP006, EXP007
#*************************

#what exp are you working on and which dir?
exp=EXP009
wkdir=month_avg_units

cd /jabber/LIS/Data/OUTPUT/$exp/NOAH/$wkdir

#name the variables
vars=(airtem evap lhtfl rain runoff soilm1 soilm2 soilm3 soilm4)

#use for loop to concatinate 12 months of the same variable
for (( i=0; i<${#vars[@]}; i++ )); do  #for all the variable names
  cat $( ls ${vars[i]}*.img ) > all_${vars[i]}_$exp.img # cat and rename e.g. all_soilm1_exp006
done



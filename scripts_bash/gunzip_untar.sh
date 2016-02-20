#!/bin/bash

#***********Aug 2, 2010 AMc**********************
# this script doesn't work perfectly
# I need to figure out how to change directories
# and maybe use an if statement to for the gunzip/untar 
# specific files
#*************************************************

cd /jower/LIS/Data/PET.BIL/pet_200911

for i in $( ls );do
     tar -xfz $i
done

for j in $( ls );do 
    gunzip $j
    for k in $( ls *.tar); do
        tar -xf $k
    done
done



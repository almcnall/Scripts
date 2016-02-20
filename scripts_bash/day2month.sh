#!/bin/bash
#proper bash scipt header

#I don't think that this script works for anything
#************************************************

#concatenating the daily files into a monthly file

#the output directory that has 'daily' and 'month' subdirs
#EXP_DIR= /jower/LIS/Code/src/OUTPUT/Zounds/NOAH
#mkdir month_script


#var1 = 'soilm1'
#var2 = 'soilm2'
#var3 = 'soilm4'
#var4 = 'runoff'
#var5 = 'lhtfl'
#var6 = 'rain'
#var7 = 'airtem'
#var8 = 'evap'
for i in $( ls daily/soilm1* ); do 
#echo $i
cat $i >> month_script/${i:5:14}.img
done

#cat daily/soilm1_200909??.img > month_script/soilm1_2009_09_dly.img
#cat daily/soilm2_200909??.img > month_script/soilm2_2009_09_dly.img
#cat daily/soilm3_200909??.img > month_script/soilm3_2009_09_dly.img 

#cat daily/soilm4_200909??.img > month_script/soilm4_2009_09_dly.img 
#cat daily/soilm4_200910??.img > month_script/soilm4_2009_10_dly.img
#cat daily/soilm4_200911??.img > month_script/soilm4_2009_11_dly.img
#cat daily/soilm4_200912??.img > month_script/soilm4_2009_12_dly.im
#cat daily/soilm4_200901??.img > month_script/soilm4_2010_01_dly.img




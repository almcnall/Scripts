
#concatenating the daily files into a monthly file

#the output directory that has 'daily' and 'month' subdirs
#EXP_DIR=/jabber/LIS/OUTPUT/EXP000/postprocess/daily/ 

var=evap

#var1 = 'soilm1'
#var2 = 'soilm2'
#var3 = 'soilm4'
#var4 = 'runoff'
#var5 = 'lhtfl'
#var6 = 'evap'
#var7 = 'airtem'
#var8 = 'evap'
yr=('2002' '2003' '2004' '2005' '2006' '2007' '2008' '2009' '2010')

cat evap_200206*>/home/mcnally/EROS_test/evap_200206.img
cat evap_200207*>/home/mcnally/EROS_test/evap_200207.img
cat evap_200208*>/home/mcnally/EROS_test/evap_200208.img
cat evap_200209*>/home/mcnally/EROS_test/evap_200209.img
cat evap_200210*>/home/mcnally/EROS_test/evap_200210.img
cat evap_200306*>/home/mcnally/EROS_test/evap_200306.img
cat evap_200307*>/home/mcnally/EROS_test/evap_200307.img
cat evap_200308*>/home/mcnally/EROS_test/evap_200308.img
cat evap_200309*>/home/mcnally/EROS_test/evap_200309.img
cat evap_200310*>/home/mcnally/EROS_test/evap_200310.img
cat evap_200406*>/home/mcnally/EROS_test/evap_200406.img
cat evap_200407*>/home/mcnally/EROS_test/evap_200407.img
cat evap_200408*>/home/mcnally/EROS_test/evap_200408.img
cat evap_200409*>/home/mcnally/EROS_test/evap_200409.img
cat evap_200410*>/home/mcnally/EROS_test/evap_200410.img
cat evap_200506*>/home/mcnally/EROS_test/evap_200506.img
cat evap_200507*>/home/mcnally/EROS_test/evap_200507.img
cat evap_200508*>/home/mcnally/EROS_test/evap_200508.img
cat evap_200509*>/home/mcnally/EROS_test/evap_200509.img
cat evap_200510*>/home/mcnally/EROS_test/evap_200510.img


#cat daily/soilm1_200909??.img > month_script/soilm1_2009_09_dly.img
#cat daily/soilm2_200909??.img > month_script/soilm2_2009_09_dly.img
#cat daily/soilm3_200909??.img > month_script/soilm3_2009_09_dly.img 

#cat daily/soilm4_200909??.img > month_script/soilm4_2009_09_dly.img 
#cat daily/soilm4_200910??.img > month_script/soilm4_2009_10_dly.img
#cat daily/soilm4_200911??.img > month_script/soilm4_2009_11_dly.img
#cat daily/soilm4_200912??.img > month_script/soilm4_2009_12_dly.im
#cat daily/soilm4_200901??.img > month_script/soilm4_2010_01_dly.img




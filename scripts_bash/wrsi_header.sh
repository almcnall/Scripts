#!/bin/bash

#**************************
# This script creates header files for images so that they can 
# be opened in ENVI

#*************************

#enter the experiment and working directory

wkdir=/jabber/LIS/Data/ubRFE2_dekads
#wkdir=/gibber/lis_data/OUTPUT/$exp/TEMPLATE/dekads_$name
cd $wkdir

startyr=2001
endyr=2009+1 #add one because we use all of 2008
run_length=$(($endyr-$startyr))
echo $run_length

#for i in {0..8}; do
#  for j in {1..12}; do
#     month="$j"
#     if [ "$month" -lt "10" ]; then #double digit month
#      dates[j]="${years[i]}"0"$month"
#     else
#      dates[j]="${years[i]}$month"
#     fi
#   done # j  
# echo ${dates[*]}

# enter the ENVI std header info
  samples=751 #pete's trmm are 300 lis are 301
  lines=801   #pete's trmm are 320 lis are 321
  bands=1 #
  header_offset=0
  file_type='ENVI Standard'
  data_type=4
  interleave='bsq'
  sensor_type='Unknown'
  byte_order='0' #0=little/Intel 1=big/IEEE
  wavelength_units='Unknown'
  #band_names=''
  map_info='Geographic Lat/Lon, 1.5000, 1.5000, -20.00000000, 40.00000000, 1.000000000e-01, 1.000000000e-01, WGS-84, units=Degrees'
  coordinate_system_string='GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137.0,298.257223563]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]]'



#this creates the txt file and writes to a file with the
#same name with the .hdr extension.
for i in $(ls *img );do
#for i in $(ls *.1gd4r );do
  echo "ENVI    
  description = {
  File Imported into ENVI.}
  samples= $samples
  lines= $lines
  bands= $bands
  header offset= $header_offset
  file type= $file_type
  data type= $data_type
  interleave= $interleave
  sensor type= $sensor_type
  byte order= $byte_order
  map info={$map_info}
  coordinate system string={$coordinate_system_string}
  wavelength units= $wavelenght_units
  band names = {$i}"> $i.hdr

 done #i

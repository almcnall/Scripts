#!/bin/bash

#**************************
# This script creates header files for images so that they can 
# be opened in ENVI
# Initial specification is for the daily LIS output single band images
# AM Aug 18. 2010

# Updated Sept.14: now each variable has a band for each monthly average of the run
# Now, the header is only created of the 'all_/variable/_exp file with as many bands as there are 
# number of months.

# updated 10/18/10: added the loop for the band names when the bandnames are months  
#*************************

#enter the experiment and working directory
#exp=EXP009  #009=rfe2 only 10/01/03-4/1/06
#wkdir=month_avg_units #variables separated
#cd /jabber/LIS/Data/OUTPUT/$exp/NOAH/$wkdir

#years=(2001 2002 2003 2004 2005 2006 2007 2008 2009)
#cd /gibber/lis_data/OUTPUT/TRMM_3B42/Africa_yearly

files=$(ls all*.img )

for i in {0..8}; do
  for j in {1..12}; do
     month="$j"
     if [ "$month" -lt "10" ]; then #double digit month
      dates[j]="${years[i]}"0"$month"
     else
      dates[j]="${years[i]}$month"
     fi
   done # j  
 echo ${dates[*]}

# enter the ENVI std header info
  samples=300 #pete's trmm are 300 lis are 301
  lines=320   #pete's trmm are 320 lis are 321
  bands=12 #
  header_offset=0
  file_type='ENVI Standard'
  data_type=4
  interleave='bsq'
  sensor_type='Unknown'
  byte_order='0' #0=little/Intel 1=big/IEEE
  wavelength_units='Unknown'
  band_names=${dates[*]}
  map_info='Geographic Lat/Lon, 1.5000, 1.5000, -20.00000000, 40.00000000, 2.5000000000e-01, 2.5000000000e-01, WGS-84, units=Degrees'
  coordinate_system_string='GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137.0,298.257223563]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]]'

#this creates the txt file and writes to a file with the
#same name with the .hdr extension.

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
  band names = {$band_names}"> ${files[i]}.hdr
echo ${files[i]}.hdr
 done #i

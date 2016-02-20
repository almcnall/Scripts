#!/bin/bash

#**************************
# This script creates header files for the EROS PET .bil images so that they can 
# be opened in ENVI with map info and then stacked.

#*************************

#enter the experiment and working directory
wkdir=/jabber/Data/mcnally/pet_2007
cd $wkdir

#startyr=2001
#endyr=2008+1 #add one because we use all of 2008
#run_length=$(($endyr-$startyr))
#echo $run_length

# enter the ENVI std header info
samples=360
lines=181
bands=1 #
header_offset=0
file_type='ENVI Standard'
data_type=12
interleave='bsq'
sensor_type='Unknown'
byte_order='1'
wavelength_units='Unknown'
map_info='{Geographic Lat/Lon, 1.5000, 1.5000, -180.00000000, 90.00000000, 1.0000000000e+00, 1.0000000000e+00, WGS-84, units=Degrees}'
coordinate_system_string='{GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137.0,298.257223563]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]]}'



#this creates the txt file and writes to a file with the
#same name with the .hdr extension.
for i in $(ls *bil );do
#for i in $(ls *.1gd4r );do
  echo "ENVI    
description = {
  File Imported into ENVI.}
samples = $samples
lines =   $lines
bands =   $bands
header offset = $header_offset
file type = $file_type
data type = $data_type
interleave = $interleave
sensor type = $sensor_type
byte order = $byte_order
map info = $map_info
coordinate system string = $coordinate_system_string
wavelength units = $wavelength_units">$i.hdr

 done #i

#!/bin/bash

#**************************
# This script creates header files for images so that they can 
# be opened in ENVI

#*************************

wkdir=/jabber/Data/mcnally/trmm4diego/
cd $wkdir
echo $wkdir

# enter the ENVI std header info
samples=364
  lines=400 
  bands=1 #
  header_offset=0
  file_type='ENVI Standard'
  data_type=5
  interleave='bsq'
  sensor_type='Unknown'
  byte_order='0'
  wavelength_units='Unknown'
  x_start='213'  
  y_start='199'  
 map_info='Geographic Lat/Lon, 1.0000, 1.0000, -125.00000000, 50.00000000, 2.5000000000e-01, 2.5000000000e-01, WGS-84, units=Degrees'
coordinate_system_string='GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137.0,298.257223563]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]]'

#this creates the txt file and writes to a file with the
#same name with the .hdr extension.
for i in $(ls WHem*img );do
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
  x start=$x_start
  y start=$y_start
  map info={$map_info}
  coordinate system string={$coordinate_system_string}
  wavelength units= $wavelenght_units
  band names = {$i}"> $i.hdr

 done #i

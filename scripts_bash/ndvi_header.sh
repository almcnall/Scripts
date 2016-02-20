#!/bin/bash

#**************************
# This script creates header files for images so that they can 
# be opened in ENVI

#*************************

#enter the experiment and working directory
exp='EXP017'
name=ndvi
wkdir=/gibber/lis_data/febmar_ndvi
cd $wkdir

#startyr=2001
#endyr=2008+1 #add one because we use all of 2008
#run_length=$(($endyr-$startyr))
#echo $run_length

# enter the ENVI std header info
samples=683
  lines=1636 
  bands=1 #
  header_offset=0
  file_type='ENVI Standard'
  data_type=1
  interleave='bsq'
  sensor_type='Unknown'
  byte_order='0'
  wavelength_units='Unknown'
  x_start='2601'  
 #band_names=''
 map_info='GEOTIFF (Albers Conical Equal Area), 1.0000, 1.0000, 1332395.8183, -1275922.9749, 5.0000000000e+002, 5.0000000000e+002, WGS-84, units=Meters'
coordinate_system_string='PROJCS["Albers",GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137.0,298.257223563]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Albers"],PARAMETER["False_Easting",0.0],PARAMETER["False_Northing",0.0],PARAMETER["Central_Meridian",20.0],PARAMETER["Standard_Parallel_1",-19.0],PARAMETER["Standard_Parallel_2",21.0],PARAMETER["Latitude_Of_Origin",1.0],UNIT["Meter",1.0]]'




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
  x start=$x_start
  map info={$map_info}
  coordinate system string={$coordinate_system_string}
  wavelength units= $wavelenght_units
  band names = {$i}"> $i.hdr

 done #i

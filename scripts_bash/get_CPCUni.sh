#!/bin/bash

#********May 31 2012***********
# script to retrieve CPC unified  data
# ftp://ftp.cpc.ncep.noaa.gov/precip/CPC_UNI_PRCP/GAUGE_GLB/
# get both the real time(2006-present) and the v1 (retrospective 1979-2005)


#****************************

cd '/raid/Data/CPC-Unif/'

for year in {1980..2005}; do
  file="ftp://ftp.cpc.ncep.noaa.gov/precip/CPC_UNI_PRCP/GAUGE_GLB/V1.0"
  wget $file/$year/*
done




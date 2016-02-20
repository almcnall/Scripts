#!/bin/bash

#**************************
# This script creates header files for trmm images so that they can 
# be opened in ARCmap...the files are the same data as what is found in 
# /jabber/Data/TRMM_3B42/WHem/pentads/ but I used the script 
# /source/mcnally/scripts_idl/rotate4diego so rotate and transpose the images since
# they are upsidedown in pete/idl-land. The rotates files are in 
# /jabber/Data/mcnally/trmm4diego/

#*************************

#enter the name of working directory

wkdir=/jabber/Data/mcnally/trmm4diego/
cd $wkdir
echo $wkdir
#enter in the standard ArcView Image Information
NCOLS=364
NROWS=400
NBANDS=1
NBITS=8
LAYOUT='BIL'
BYTEORDER='I'
SKIPBYTES=0
MAPUNITS='DEGREES'
ULXMAP=-124.87500000
ULYMAP=49.87500000
XDIM=0.25000000
YDIM=0.25000000


for i in $(ls *img );do
echo ";ArcView Image Information
      ;
  NCOLS        $NCOLS
  NROWS        $NROWS
  NBANDS       $NBANDS
  NBITS        $NBITS
  LAYOUT       $LAYOUT
  BYTEORDER    $BYTEORDER
  SKIPBYTES    $SKIPBYTES
  MAPUNITS     $MAPUNITS
  ULXMAP       $ULXMAP
  ULYMAP       $ULYMAP
  XDIM         $XDIM
  YDIM         $YDIM">$i.hdr
done


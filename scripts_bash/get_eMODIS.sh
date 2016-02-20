#!/bin/bash

#********Nov 8 2012***********
# script to retrieve the eMODIS files fromt the EROS server
#pete says: The wrinkle here was in excluding  "/pub" from the path which I only figured out by going to the ftp site.
#****************************

cd /jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/

#file=" edcftp.cr.usgs.gov/pub/edcuser/rsmith/emodis/"

wget -r -nd --ftp-user=anonymous --ftp-password=letmein   ftp://edcftp.cr.usgs.gov/edcuser/rsmith/emodis/*

#or
#ftp edcftp.cr.usgs.gov
#username:  anonymous
#password:  whatever


#cd edcuser/rsmith/emodis
#prompt
#hash
#mget *

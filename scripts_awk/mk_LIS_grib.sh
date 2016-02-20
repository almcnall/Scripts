#(4') How do I extract records 34-66 from a file as a grib file?
#     Here is an example of an awk filter.
#        wgrib -s grib_file | awk '{if ($1 > 33 && $1 < 67) print $0}'
#            FS=':' | wgrib -i grib_file -o new_file -grib

#so i need to grab the relevant vars from the fnl files and make them look like NASA's GDAS
#see ftp://ftp.cpc.ncep.noaa.gov/wd51we/wgrib/tricks.wgrib for tricks, it is nice that it is awk manipulate-able
# for info on the GDAS/fnl files see these and associated links: 
# http://rda.ucar.edu/datasets/ds083.2/#docs/more.html
# http://rda.ucar.edu/datasets/ds083.2/index.html?hash=sfol-wl-/data/ds083.2&g=12013#!description

# FNL data looks like this:
# rec 201:20094106:date 2013010100 PRES kpds5=1 kpds6=1 kpds7=0 levels=(0,0) grid=3 sfc anl:
#  PRES=Pressure [Pa]
#  timerange 10 P1 0 P2 0 TimeU 1  nx 360 ny 181 GDS grid 0 num_in_ave 0 missing 0
#  center 7 subcenter 0 process 82 Table 2 scan: WE:NS winds(N/S) 
#  latlon: lat  90.000000 to -90.000000 by 1.000000  nxny 65160
#          long 0.000000 to -1.000000 by 1.000000, (360 x 181) scan 0 mode 128 bdsgrid 1
#  min/max data 50718.3 104193  num bits 20  BDS_Ref 507183  DecScale 1 BinScale 0


#  LIS GDAS looks like this:
#  rec 2:3097684:date 2011123118 DLWRF kpds5=205 kpds6=1 kpds7=0 levels=(0,0) grid=255 sfc 9hr fcst:
#  DLWRF=Downward long wave flux [W/m^2]
#  timerange 10 P1 0 P2 9 TimeU 1  nx 1760 ny 880 GDS grid 4 num_in_ave 0 missing 0
#  center 7 subcenter 0 process 82 Table 2 scan: WE:NS winds(N/S) 
#  gaussian: lat  89.844000 to -89.844000
#            long 0.000000 to 359.795000 by 0.205000, (1760 x 880) scan 0 mode 128 bdsgrid 1
#  min/max data 80.4013 498.623  num bits 16  BDS_Ref 8.04013e+06  DecScale 5 BinScale 10

# my second attempt at CDO regridding looked like this....
#rec 212:534311208:date 2013010100 WEASD kpds5=65 kpds6=1 kpds7=0 levels=(0,0) grid=255 sfc anl:
#  WEASD=Accum. snow [kg/m^2]
#  timerange 10 P1 0 P2 0 TimeU 1  nx 1760 ny 880 GDS grid 4 num_in_ave 0 missing 0
#  center 7 subcenter 0 process 82 Table 2 scan: WE:NS winds(N/S) 
#  gaussian: lat  89.844000 to -89.844000
#            long 0.000000 to 360.595000 by 0.205000, (1760 x 880) scan 0 mode 128 bdsgrid 1
#  min/max data 0 271  num bits 9  BDS_Ref 0  DecScale 0 BinScale 0

#this line o' code seems to rebin the grib data correctly. except for 1extra pixel. hope that is ok...
cdo remapbil,gdasgrid /raid/chg-mcnally/fnl_20130101_00_00_c /home/mcnally/fnl_20130101_00_00_c.remapbil 

#and then I looked at the verbose output for one GDAS var to match with
wgrib -V -d 212 fnl_20130101_00_00_c* 

wgrib -s fnl_20130101_00_00_c | awk '{if ($1 == 201 && $1 > 202 && $1 < 223) print $0}' FS=':' | wgrib -i grib_file -o new_file -grib

#also try, nope this does every 8th entry.
 wgrib fnl_20130101_00_00_c | awk '{if ($1 % 8 == 1) print $0}' FS=':'

#how about extracting rows by sed?
 wgrib fnl_20130101_00_00_c | sed -n '203, 215p'

#yay, this gets the vars of interest, now i need to put them in order...
wgrib fnl_20130101_00_00_c | sed -n -e 201p -e  203,215p -e 219,222p -e 225p -e 230,232p -e 260,263p -e 311p

#will it spit them out in the order that i ask for? NO....but it looks like it does't matter since the LIS goes by ID
cd /raid/chg-mcnally
wgrib fnl_20130101_00_00_c | sed -n -e 261p  -e 260p  -e 222p  -e 221p  -e 219p  -e 220p  -e 214p  -e 215p  -e 201p  -e 311p

#what are the dimensions and the grid size of the FNL? how does this compare to the LIS-GDAS? what does the file name convention need to be? what other issues might i run into?

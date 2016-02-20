pro FLDAS_EVAL_LVT

;this script makes plots of the LIS-WRSI (CHIRPS) similar to what is found on the USGS website
;calls the function get_nc for reading in the netcdf files more cleanly.

indir = '/home/sandbox/people/mcnally/FLDAS_EVAL/'
shapefile = '/home/code/idl_user_contrib/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'
;this function reads a netcdf file (var of interest, ifile name)
.compile /home/source/mcnally/scripts_idl/get_nc.pro

;for all of the anomaly correlations with mw soil moisture use the following VOI
VOI = 'SoilMoist_v_SoilMoist' ;variable of interest 'SoilMoist_v_Rainf', SoilMoist_v_NDVI

;ifile = file_search(indir+'LVT_ACORR_CCISM_NOAHSM01_CHIRPSGDAS_2001_2013_EA.nc') & print, ifile ;this needs to be re-done

ifile = file_search(indir+'LVT_ACORR_FINAL.201401010000.d01_CM_FIX_EA_2001.nc') & print, ifile
;ifile = file_search(indir+'LVT_ACORR_FINAL.201401010000.d01_CM_FIX_WA_2001.nc')
;ifile = file_search(indir+'LVT_ACORR_FINAL.201401010000.d01_CM_FIX_SA_2001.nc')
ACORR_fix = get_nc(VOI, ifile)
ACORR_fix(where(ACORR_fix lt -10))=!values.f_nan

ifile = file_search(indir+'LVT_ACORR_FINAL.201401010000.d01_CM_OLD_EA_2001.nc') & print, ifile
;ifile = file_search(indir+'LVT_ACORR_FINAL.201401010000.d01_CM_OLD_WA_2001.nc')
;ifile = file_search(indir+'LVT_ACORR_FINAL.201401010000.d01_CM_OLD_SA_2001.nc')
ACORR_old = get_nc(VOI, ifile)
ACORR_old(where(ACORR_old lt -10))=!values.f_nan

ifile = file_search(indir+'LVT_ACORR_CCISM_NOAHSM01_RFEGDAS_2001_2014_EA.nc') & print, ifile
;ifile = file_search(indir+'LVT_ACORR_CCISM_NOAHSM01_RFEGDAS_2001_2014_WA.nc') & print, ifile
;ifile = file_search(indir+'LVT_ACORR_CCISM_NOAHSM01_RFEGDAS_2001_2014_SA.nc')
ACORR_RG = get_nc(VOI, ifile)
ACORR_RG(where(ACORR_RG lt -10))=!values.f_nan

VOI = 'SoilMoist_v_NDVI'
;ifile = file_search(indir+'LVT_RCORR_NDVI_NOAHSM01_CHIRPSGDAS_2001_2013_EA.nc') & print, ifile ;this needs to be re-done

ifile = file_search(indir+'LVT_RCORR_NDVI_NOAHSM01_RFEGDAS_2001_2013_EA.nc') & print, ifile ;LVT_RCORR_NDVI_NOAHSM01_CHIRPSGDAS_2001_2013_EA.nc
;ifile = file_search(indir+'LVT_RCORR_NDVI_NOAHSM01_RFEGDAS_2001_2013_WA.nc') & print, ifile
;ifile = file_search(indir+'LVT_RCORR_NDVI_NOAHSM01_RFEGDAS_2001_2013_SA.nc')
RCORR_RG = get_nc(VOI, ifile)
RCORR_RG(where(RCORR_RG lt -10))=!values.f_nan

;;;;;all these need to be redone with the correlations from 2001 rather than 1992
ifile = file_search(indir+'LVT_RCORR_NDVI_NoahSM01fix_1992_2013_EA.nc') & print, ifile ;this needs to re-do from
;ifile = file_search(indir+'LVT_RCORR_FINAL.201401010000.d01_CM_FIX_WA.nc') & print, ifile ;redo from 2001
;ifile = file_search(indir+'LVT_RCORR_FINAL.201401010000.d01_CM_FIX_SA.nc') ;redo from 2001
RCORR_CMfix = get_nc(VOI, ifile)
RCORR_CMfix(where(RCORR_CMfix lt -10))=!values.f_nan

ifile = file_search(indir+'old/LVT_RCORR_NDVI_NoahSM01_1992_2013_EA.nc') & print, ifile ;this needs to re-do from 2001 if comparing..
;ifile = file_search(indir+'old/LVT_RCORR_NDVI_NoahSM01_1992_2013_WA.nc') & print, ifile ;this one should be re-done from 2001
;ifile = file_search(indir+'old/LVT_RCORR_NDVI_NoahSM01_1992_2013_SA.nc') & print, ifile ;this one should be re-done from 2001
RCORR_CMold = get_nc(VOI, ifile)
RCORR_CMold(where(RCORR_CMold lt -10))=!values.f_nan

;both NDVI and MW soil moisture highlight errors in rainfall.

;other variations (changes in time period etc have to be re-done since the Sept/Oct fix)
;ifile = file_search(indir+'LVT_ACORR_CCISM_NoahSM01_1992_2013_SA.nc');
;ifile = file_search(indir+'LVT_ACORR_CHIRPS_NoahSM01_1992_2013_SA.nc');
;ifile = file_search(indir+'LVT_RCORR_NDVI_NoahSM01_1992_2013_SA.nc')
;
;nx = 486, ny = 443, nz = 33
dims = size(ACORR_RG, /dimensions)
NX = dims[0]
NY = dims[1]

;South africa domain
;map_ulx = 6.05 & map_lrx = 54.55
;map_uly = 6.35 & map_lry = -37.85

; west africa domain
;map_ulx = -18.65 & map_lrx = 25.85
;map_uly = 17.65 & map_lry = 5.35

; East africa domain
map_ulx = 22.05 & map_lrx = 51.35
map_uly = 22.95 & map_lry = -11.75

;greg's way of nx, ny-ing
ulx = (180.+map_ulx)*10. & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10. & lry = (50.-map_lry)*10.-1
gNX = lrx - ulx + 2 ;not sure why i have to add 2...
gNY = lry - uly + 2
  
  ncolors=5
  w = window(DIMENSIONS=[1000,600])

;for some reason EA needs a plus 0.25 to get the grid to alighn (map_lry+0.25)
  p1 = image(congrid(RCORR_RG,NX*3,NY*3), image_dimensions=[nx/10,ny/10],image_location=[map_ulx+0.25,map_lry+0.25], $
            RGB_TABLE=64, layout = [2,1,2], /current) &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  ;rgbdump[*,255] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  rgbdump[*,0] = [190,190,190] &$
  rgbdump[*,255] = [190,190,190] &$
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.MAX_VALUE=0.9 &$
  p1.min_value=-0.1
  c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON);, $
            ; POSITION=[0.3,0.04,0.7,0.07], font_size=16) &$
  tmpclr = p1.rgb_table &$
  ;tmpclr[*,0] = [211,211,211] &$ ;different color oceans
  ;tmpclr[*,0] = [102,178,255] &$
  p1.rgb_table = tmpclr &$ 
  p1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot) &$
  p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  ;mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2)
  p1.title = 'Noah33+RFE2+GDAS anom corr. with CCI-SMv2.0'
  p1.title = 'Noah33+RFE2+GDAS rank corr. with lagged NDVI'

 
    
    ;plot the CSV time series files;;;;;;;;;;;;;;;;;;;
    indir = '/home/sandbox/people/mcnally/FLDAS_EVAL/'

  ifile1 = file_search(indir+'MEAN_GABARONE_NOAH_CCI.dat')
  ifile1 = file_search(indir+'MEAN_KRUGER_NOAH_CCI.dat');MEAN_ALL_SA_CCI.dat
  ifile1 = file_search(indir+'MEAN_ALL_SA_CCI.dat');

  ifile1 = file_search(indir+'MEAN_WANKAMA_NOAH_CCI.dat')
  ifile1 = file_search(indir+'MEAN_NIORO_NOAH_CCI.dat')
  ifile1 = file_search(indir+'MEAN_ALL_WA_CCI.dat')& print, ifile1
  ifile1 = file_search(indir+'MEAN_HORN_NOAH_VIC.dat')& print, ifile1
  
  ifile1 = file_search(indir+'MEAN_HORN_NOAHSM01_CHIRPS.dat')& print, ifile1
  ifile1 = file_search(indir+'MEAN_HORN_VICSM01_CHIRPS.dat')& print, ifile1
  
  ;ifile1 = file_search(indir+'MEAN_KUT_MERRA_01.dat')& print, ifile1
  ifile1 = file_search(indir+'MEAN_KABAN_MERRA_01.dat')& print, ifile1
  
  ;ifile2 = file_search(indir+'MEAN_KUT_CHIRPS_01.dat')& print, ifile1
  ifile2 = file_search(indir+'MEAN_KABAN_CHIRPS_01.dat')& print, ifile1
  
  ;ifile3 = file_search(indir+'MEAN_KUT_GDAS_01.dat')& print, ifile1
  ifile3 = file_search(indir+'MEAN_KABAN_GDAS_01.dat')& print, ifile1
  
  indat1 = read_ascii(ifile1, dlimiter=" ") & help, indat1
  indat1.field01(where(indat1.field01 lt -100))=!values.f_nan
  
  indat2 = read_ascii(ifile2, dlimiter=" ") & help, indat1
  indat2.field01(where(indat2.field01 lt -100))=!values.f_nan
  
  indat3 = read_ascii(ifile3, dlimiter=" ") & help, indat1
  indat3.field01(where(indat3.field01 lt -100))=!values.f_nan
  
  CCISM = reform(indat1.field01[11,0:4744],365,13)
  SM01C = reform(indat2.field01[5,0:4744],365,13);2=chirps
  SM01G = reform(indat3.field01[5,0:4744],365,13);3=gdas
  SM01M = reform(indat1.field01[5,0:4744],365,13);1=merra


  
 ; CCISM = reform(indat1.field01[11,0:8029],365,22)
 ; SM01 = reform(indat1.field01[5,0:8029],365,22)
  ; NDVI = reform(indat2.field01[10,0:8029],365,22)
  
  ;;;;;Shorter GDAS time series;;;;;;;;
  ifile1 = file_search(indir+'MEAN_HORN_GDAS_CHIRPS_2001_2014_EA.dat')& print, ifile1
  ifile1 = file_search(indir+'MEAN_HORN_GDAS_RFE_2001_2014_EA.dat')& print, ifile1
  
  ifile1 = file_search(indir+'MEAN_MPALA_GDAS_RFE_2001_2014_EA.dat')& print, ifile1
  ifile1 = file_search(indir+'MEAN_MPALA_GDAS_CHIRPS_2001_2014_EA.dat')& print, ifile1

  ifile1 = file_search(indir+'MEAN_SHEKA_GDAS_RFE_2001_2014_EA.dat')& print, ifile1
  ifile1 = file_search(indir+'MEAN_SHEKA_GDAS_CHIRPS_2001_2014_EA.dat')& print, ifile1
  
  ifile1 = file_search(indir+'MEAN_TIGRAY_GDAS_RFE_2001_2014_EA.dat')& print, ifile1
  ifile1 = file_search(indir+'MEAN_TIGRAY_GDAS_CHIRPS_2001_2014_EA.dat')& print, ifile1
  
  
  
  indat2 = read_ascii(ifile1, dlimiter=" ") & help, indat2
  indat2.field01(where(indat2.field01 lt -100))=!values.f_nan
  CCISM = reform(indat2.field01[11,0:4744],365,13)
  SM01 = reform(indat2.field01[5,0:4744],365,13)


  w=window()
  p1 = plot(mean(ccism,dimension=2,/nan),/current,'orange', name= 'CCI-SM')
  p2 = plot(mean(SM01M,dimension=2), 'b', linestyle=0, /overplot, name = 'NOAH-MERRA SM01')
  p3 = plot(mean(SM01C,dimension=2), 'g', linestyle=0, /overplot, name = 'NOAH-CHIRPS SM01')
  p4 = plot(mean(SM01G,dimension=2), 'c', linestyle=0, /overplot, name = 'NOAH-GDAS SM01')

  p2.xrange=[0,360]
  p2.xtickinterval=30
  p2.xtitle='DOY'
  p2.ytitle='m3/m3'
  p2.title = 'SM/MW climatology Keban, Turkey'
  ;p3 = plot(mean(SM01,dimension=2), 'b', linestyle=2, /overplot, name = 'NOAH-MERRA SM01')
  !null = legend(target=[p1,p2,p3,p4], orientation=1, shadow=0)

  
  w = window(DIMENSIONS=[1400,500])
  p1 = plot(indat1.field01[11,0:8029]*86400, 'orange', name = 'CHIRPS', /current)
  p2 = plot(indat1.field01[5,0:8029], 'b', /overplot,name = 'VICSM01')
  p1.xrange=[0,8029]
  p1.xtickinterval=365
  p1.xtickname=string(indgen(22)+1992)
  p1.title = 'VIC and Noah soil mositure East Africa'
  p1.font_size=14
  !null = legend(target=[p1,p2], orientation=1, shadow=0)
  p1.xminor=3
  p1.ytitle='m3/m3'
  
 
;;;DIFFERENCE MAPS
  w = window(DIMENSIONS=[1200,800])
  ncolors=10
  p1 = image(congrid(ACORR2-ACORR,NX*3,NY*3), image_dimensions=[nx/10,ny/10],image_location=[map_ulx+0.25,map_lry], $
    RGB_TABLE=66, layout = [1,1,1], /current) &$
    ;p1.title = 'LIS-Noah33 SM01-GIMMS NDVI lag-1 rank correlation'
    p1.title = 'FIX-OLD CCISM anom correlation'
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
    rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
    ;rgbdump[*,255] = [255,255,255] &$ ; set map values of zero to white, you can change the color
    rgbdump[*,0] = [190,190,190] &$
    rgbdump[*,255] = [190,190,190] &$
    p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
    p1.MAX_VALUE=0.2 &$
    p1.min_value=-0.2
  c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON)
  ;POSITION=[0.3,0.04,0.7,0.07], font_size=16) &$
  tmpclr = p1.rgb_table &$
    ;tmpclr[*,0] = [211,211,211] &$ ;different color oceans
    ;tmpclr[*,0] = [102,178,255] &$
    p1.rgb_table = tmpclr &$
    p1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot) &$
    p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
    p1.mapgrid.color = [150, 150, 150] &$
    mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
    m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2)

 ;;;;;;VIC at 0.25 deg resolution;;;;;;

 indir = '/home/sandbox/people/mcnally/FLDAS_EVAL/'
 ifile = file_search(indir+'LVT_RCORR_NDVI_VICSM01_1992_2013_EA.nc')

 fileID = ncdf_open(ifile, /nowrite) &$
   wrsiID = ncdf_varid(fileID,'SoilMoist_v_NDVI') &$
   ncdf_varget,fileID, wrsiID, RCORR

 ifile = file_search(indir+'LVT_ACORR_CCISM_VICSM01_1992_2013_EA.nc');LVT_ACORR_CCISM_VICSM01_1992_2013_EAv2.nc
 fileID = ncdf_open(ifile, /nowrite) &$
   wrsiID = ncdf_varid(fileID,'SoilMoist_v_SoilMoist') &$
   ncdf_varget,fileID, wrsiID, ACORR
   

 ifile = file_search(indir+'LVT_ACORR_CCISM_VICSM01_1992_2013_EAv2.nc');LVT_ACORR_CCISM_VICSM01_1992_2013_EAv2.nc
 fileID = ncdf_open(ifile, /nowrite) &$
   wrsiID = ncdf_varid(fileID,'SoilMoist_v_SoilMoist') &$
   ncdf_varget,fileID, wrsiID, ACORR2
   
 ifile = file_search(indir+'LVT_ACORR_NOAHSM01_VICSM01_1992_2013.nc')
 fileID = ncdf_open(ifile, /nowrite) &$
   wrsiID = ncdf_varid(fileID,'SoilMoist_v_SoilMoist') &$
   ncdf_varget,fileID, wrsiID, ACORR
 
 ifile = file_search(indir+'LVT_ACORR_CHIRPS_VICSM01_1992_2014.nc')
 fileID = ncdf_open(ifile, /nowrite) &$
   wrsiID = ncdf_varid(fileID,'SoilMoist_v_Rainf') &$
   ncdf_varget,fileID, wrsiID, ACORR   
  

 dims = size(ACORR, /dimensions)
 NX = dims[0]
 NY = dims[1]
 ; East africa domain
 map_ulx = 21.875 & map_lrx = 51.125
 map_uly = 23.125 & map_lry = -11.875
 ;greg's way of nx, ny-ing
 ulx = (180.+map_ulx)*4 & lrx = (180.+map_lrx)*4.-1
 uly = (50.-map_uly)*4 & lry = (50.-map_lry)*4.-1
 gNX = lrx - ulx + 2 ;not sure why i have to add 2...
 gNY = lry - uly + 2

 RCORR(where(RCORR lt -100))=!values.f_nan
 ACORR(where(ACORR lt -100))=!values.f_nan

 w = window(DIMENSIONS=[1200,800])
 ncolors=9
 p1 = image(congrid(ACORR,NX*3,NY*3), image_dimensions=[nx/4,ny/4],image_location=[map_ulx+0.5,map_lry], $
   RGB_TABLE=64, layout = [2,1,1], /current) &$
   ;p1.title = 'LIS-VIC412 SM01-GIMMS NDVI lag-1 rank correlation'
   p1.title = 'LIS-VIC412 SM01- CCI anomaly correlation v2'
 rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
   rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
   ;rgbdump[*,255] = [255,255,255] &$ ; set map values of zero to white, you can change the color
   rgbdump[*,0] = [190,190,190] &$
   rgbdump[*,255] = [190,190,190] &$
   p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
   p1.MAX_VALUE=0.8 &$
   p1.min_value=-0.1
 c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON)
 ;POSITION=[0.3,0.04,0.7,0.07], font_size=16) &$
 tmpclr = p1.rgb_table &$
   ;tmpclr[*,0] = [211,211,211] &$ ;different color oceans
   ;tmpclr[*,0] = [102,178,255] &$
   p1.rgb_table = tmpclr &$
   p1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot) &$
   p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
   p1.mapgrid.color = [150, 150, 150] &$
   mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
   m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2)
   
   
;;;;;;;SA;;;;;;;
 indir = '/home/sandbox/people/mcnally/FLDAS_EVAL/'
 ifile = file_search(indir+'LVT_RCORR_NDVI_VICSM01_1992_2013_SA.nc')

 fileID = ncdf_open(ifile, /nowrite) &$
   wrsiID = ncdf_varid(fileID,'SoilMoist_v_NDVI') &$
   ncdf_varget,fileID, wrsiID, RCORR

 ifile = file_search(indir+'LVT_ACORR_CCISM_VICSM01_1992_2013_SA.nc')
 fileID = ncdf_open(ifile, /nowrite) &$
   wrsiID = ncdf_varid(fileID,'SoilMoist_v_SoilMoist') &$
   ncdf_varget,fileID, wrsiID, ACORR

 dims = size(RCORR, /dimensions)
 NX = dims[0]
 NY = dims[1]
;South africa domain
map_ulx = 5.875 & map_lrx = 51.125
map_uly = 6.625 & map_lry = -34.625
 ;greg's way of nx, ny-ing
 ulx = (180.+map_ulx)*4 & lrx = (180.+map_lrx)*4.-1
 uly = (50.-map_uly)*4 & lry = (50.-map_lry)*4.-1
 gNX = lrx - ulx + 2 ;not sure why i have to add 2...
 gNY = lry - uly + 2

 RCORR(where(RCORR lt -100))=!values.f_nan
 ACORR(where(ACORR lt -100))=!values.f_nan

 w = window(DIMENSIONS=[1200,800])
 ncolors=5
 p1 = image(congrid(ACORR,NX*3,NY*3), image_dimensions=[nx/4,ny/4],image_location=[map_ulx+0.25,map_lry+0.25], $
   RGB_TABLE=64, layout = [2,1,1], /current) &$
 ;  p1.title = 'LIS-VIC412 SM01-GIMMS NDVI lag-1 rank correlation'
 p1.title = 'LIS-VIC412 SM01- CCI-SM anomaly correlation'
 rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
   rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
   ;rgbdump[*,255] = [255,255,255] &$ ; set map values of zero to white, you can change the color
   rgbdump[*,0] = [190,190,190] &$
   rgbdump[*,255] = [190,190,190] &$
   p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
   p1.MAX_VALUE=0.9 &$
   p1.min_value=-0.1
 c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON)
 ;POSITION=[0.3,0.04,0.7,0.07], font_size=16) &$
 tmpclr = p1.rgb_table &$
   ;tmpclr[*,0] = [211,211,211] &$ ;different color oceans
   ;tmpclr[*,0] = [102,178,255] &$
   p1.rgb_table = tmpclr &$
   p1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot) &$
   p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
   p1.mapgrid.color = [150, 150, 150] &$
   mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
   m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2)
   
   
 ;;;;;;; west africa domain
 indir = '/home/sandbox/people/mcnally/FLDAS_EVAL/'
 ifile = file_search(indir+'LVT_RCORR_NDVI_VICSM01_1992_2013_WA.nc')

 fileID = ncdf_open(ifile, /nowrite) &$
   wrsiID = ncdf_varid(fileID,'SoilMoist_v_NDVI') &$
   ncdf_varget,fileID, wrsiID, RCORR

 ifile = file_search(indir+'LVT_ACORR_CCISM_VICSM01_1992_2013_WA.nc');LVT_ACORR_CCISM_VICSM01_1992_2013_WAv2.nc
 fileID = ncdf_open(ifile, /nowrite) &$
   wrsiID = ncdf_varid(fileID,'SoilMoist_v_SoilMoist') &$
   ncdf_varget,fileID, wrsiID, ACORR
   
 ifile = file_search(indir+'LVT_ACORR_CCISM_VICSM01_1992_2013_WAv2.nc');LVT_ACORR_CCISM_VICSM01_1992_2013_WAv2.nc
 fileID = ncdf_open(ifile, /nowrite) &$
   wrsiID = ncdf_varid(fileID,'SoilMoist_v_SoilMoist') &$
   ncdf_varget,fileID, wrsiID, ACORR2

 dims = size(ACORR, /dimensions)
 NX = dims[0]
 NY = dims[1]
 map_ulx = -17.125 & map_lrx = 25.625
 map_uly = 17.875 & map_lry = 5.125
 ;greg's way of nx, ny-ing
 ulx = (180.+map_ulx)*4. & lrx = (180.+map_lrx)*4.-1
 uly = (50.-map_uly)*4. & lry = (50.-map_lry)*4.-1
 gNX = lrx - ulx + 2 ;not sure why i have to add 2...
 gNY = lry - uly + 2

 RCORR(where(RCORR lt -100))=!values.f_nan
 ACORR(where(ACORR lt -100))=!values.f_nan
 ACORR2(where(ACORR2 lt -100))=!values.f_nan


 w = window(DIMENSIONS=[1000,500])
 ncolors=5
 p1 = image(congrid(ACORR2,NX*3,NY*3), image_dimensions=[nx/4,ny/4],image_location=[map_ulx+0.25,map_lry], $
   RGB_TABLE=64, layout = [2,1,1], /current) &$
   ;p1.title = 'LIS-Noah33 SM01-GIMMS NDVI lag-1 rank correlation'
   p1.title = 'LIS-VIC412 SM01v2- CCI-SM anomaly correlation'
 rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
   rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
   ;rgbdump[*,255] = [255,255,255] &$ ; set map values of zero to white, you can change the color
   rgbdump[*,0] = [190,190,190] &$
   rgbdump[*,255] = [190,190,190] &$
   p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
   p1.MAX_VALUE=0.9 &$
   p1.min_value=-0.1
 c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON);, $
 ; POSITION=[0.3,0.04,0.7,0.07], font_size=16) &$
 tmpclr = p1.rgb_table &$
   ;tmpclr[*,0] = [211,211,211] &$ ;different color oceans
   ;tmpclr[*,0] = [102,178,255] &$
   p1.rgb_table = tmpclr &$
   p1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot) &$
   p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
   p1.mapgrid.color = [150, 150, 150] &$
   mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
   m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2)
   
 ;;RMSE GLDAS comparisons = what is the sensitivity to rainfall?
 
 indir = '/home/sandbox/people/mcnally/FLDAS_EVAL/'
 ifile = file_search(indir+'LVT_RMSE_GLDAS_NOAH_SM_QLE_QH.nc')

 fileID = ncdf_open(ifile, /nowrite) &$
   wrsiID = ncdf_varid(fileID,'Qle_v_Qle') &$
   ncdf_varget,fileID, wrsiID, QLE

   wrsiID = ncdf_varid(fileID,'SoilMoist_v_SoilMoist') &$
   ncdf_varget,fileID, wrsiID, SM
     
   wrsiID = ncdf_varid(fileID,'Qh_v_Qh') &$
   ncdf_varget,fileID, wrsiID, QH
   
 dims = size(QH, /dimensions)
 NX = dims[0]
 NY = dims[1]
 ; East africa domain
 map_ulx = 22.05 & map_lrx = 51.35
 map_uly = 22.95 & map_lry = -11.75
 ;greg's way of nx, ny-ing
 ulx = (180.+map_ulx)*10. & lrx = (180.+map_lrx)*10.-1
 uly = (50.-map_uly)*10. & lry = (50.-map_lry)*10.-1
 gNX = lrx - ulx + 2 ;not sure why i have to add 2...
 gNY = lry - uly + 2

 SM(where(SM lt -100))=!values.f_nan
 QLE(where(QLE lt -100))=!values.f_nan
 QH(where(QH lt -100))=!values.f_nan

 w = window(DIMENSIONS=[1500,700])
 ncolors=5
 ;p1 = image(congrid(SM[*,*,0],NX*3,NY*3), image_dimensions=[nx/10,ny/10],image_location=[map_ulx+0.25,map_lry+0.5], $
 p1 = image(congrid(QH,NX*3,NY*3), image_dimensions=[nx/10,ny/10],image_location=[map_ulx+0.25,map_lry+0.5], $
   RGB_TABLE=64, layout = [3,1,3], /current) &$
   ;p1.title = 'LIS-Noah33 SM01-GIMMS NDVI lag-1 rank correlation'
   p1.title = 'RMSE GLDAS(Princeton) v FLDAS(CHIRPS) Noah QH'
 rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
   rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
   ;rgbdump[*,255] = [255,255,255] &$ ; set map values of zero to white, you can change the color
   rgbdump[*,0] = [190,190,190] &$
   rgbdump[*,255] = [190,190,190] &$
   p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
   p1.MAX_VALUE=60 &$ ;0.15 for soil mositure
   ;p1.MAX_VALUE=0.15 &$ ;0.15 for soil mositure
   ;p1.min_value=-0.1
 c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON)
 ;POSITION=[0.3,0.04,0.7,0.07], font_size=16) &$
 tmpclr = p1.rgb_table &$
   ;tmpclr[*,0] = [211,211,211] &$ ;different color oceans
   ;tmpclr[*,0] = [102,178,255] &$
   p1.rgb_table = tmpclr &$
   p1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot) &$
   p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
   p1.mapgrid.color = [150, 150, 150] &$
   mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
   m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2)
   
   
 ;;;;;tigris euphrates;;;;
 
 ;Tigris-Euphrates domain
 map_ulx = 34.05 & map_lrx = 53.95
 map_uly = 41.95 & map_lry = 27.05

 ulx = (180.+map_ulx)*10. & lrx = (180.+map_lrx)*10.-1
 uly = (50.-map_uly)*10. & lry = (50.-map_lry)*10.-1
 gNX = lrx - ulx + 2 ;not sure why i have to add 2...
 gNY = lry - uly + 2


 ncolors=6
 w = window(DIMENSIONS=[1000,600])

 p1 = image(congrid(ACORRC,NX*3,NY*3), image_dimensions=[nx/10,ny/10],image_location=[map_ulx+0.25,map_lry], $
   RGB_TABLE=64, title ='LIS-Noah33 Anom Corr ESA CCI-SM 2001 CHIRPS', /current) &$
   rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
   rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
   ;rgbdump[*,255] = [255,255,255] &$ ; set map values of zero to white, you can change the color
   rgbdump[*,0] = [190,190,190] &$
   rgbdump[*,255] = [190,190,190] &$
   p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
   p1.MAX_VALUE=0.8 &$
   p1.min_value=0.2
 c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON);, $
 ; POSITION=[0.3,0.04,0.7,0.07], font_size=16) &$
 tmpclr = p1.rgb_table &$
   ;tmpclr[*,0] = [211,211,211] &$ ;different color oceans
   ;tmpclr[*,0] = [102,178,255] &$
   p1.rgb_table = tmpclr &$
   p1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot) &$
   p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
   p1.mapgrid.color = [150, 150, 150] &$
   mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
   m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2)
 
 ifile = file_search(indir+'LVT_ACORR_CCISM_NOAHSM01_1981_2013_TE.nc');LVT_RCORR_NDVI_NoahSM01_1981_2013_TE.nc
 fileID = ncdf_open(ifile, /nowrite) &$
   wrsiID = ncdf_varid(fileID,'SoilMoist_v_SoilMoist') &$
   ncdf_varget,fileID, wrsiID, ACORR

 ifile = file_search(indir+'LVT_ACORR_CCISM_NOAHSM01_1992_2014_TE_CHIRPS.nc');LVT_RCORR_NDVI_NoahSM01_1981_2013_TE.nc
 fileID = ncdf_open(ifile, /nowrite) &$
   wrsiID = ncdf_varid(fileID,'SoilMoist_v_SoilMoist') &$
   ncdf_varget,fileID, wrsiID, ACORR92

 ifile = file_search(indir+'LVT_ACORR_CCISM_NOAHSM01_1992_2014_TE_MERRA.nc');LVT_ACORR_CCISM_NOAHSM01_2001_2014_TE_GDAS.nc
 fileID = ncdf_open(ifile, /nowrite) &$
   wrsiID = ncdf_varid(fileID,'SoilMoist_v_SoilMoist') &$
   ncdf_varget,fileID, wrsiID, ACORR

 ifile = file_search(indir+'LVT_ACORR_CCISM_NOAHSM01_2001_2014_TE_GDAS.nc');LVT_ACORR_CCISM_NOAHSM01_2001_2014_MERRA.nc
 fileID = ncdf_open(ifile, /nowrite) &$
   wrsiID = ncdf_varid(fileID,'SoilMoist_v_SoilMoist') &$
   ncdf_varget,fileID, wrsiID, ACORRG

 ifile = file_search(indir+'LVT_ACORR_CCISM_NOAHSM01_TE_2001_2014_MERRA.nc');LVT_ACORR_CCISM_NOAHSM01_2001_2014_TE_CHIRPS.nc
 fileID = ncdf_open(ifile, /nowrite) &$
   wrsiID = ncdf_varid(fileID,'SoilMoist_v_SoilMoist') &$
   ncdf_varget,fileID, wrsiID, ACORRM

 ifile = file_search(indir+'LVT_ACORR_CCISM_NOAHSM01_2001_2014_TE_CHIRPS.nc')
 fileID = ncdf_open(ifile, /nowrite) &$
   wrsiID = ncdf_varid(fileID,'SoilMoist_v_SoilMoist') &$
   ncdf_varget,fileID, wrsiID, ACORRC


 ifile = file_search(indir+'LVT_RCORR_NDVI_NoahSM01_1981_2013_TE.nc');LVT_RCORR_NDVI_NoahSM01_1992_2014_TE_MERRA.nc
 fileID = ncdf_open(ifile, /nowrite) &$
   wrsiID = ncdf_varid(fileID,'SoilMoist_v_NDVI') &$
   ncdf_varget,fileID, wrsiID, RCORR

 ifile = file_search(indir+'LVT_RCORR_NDVI_NoahSM01_1992_2014_TE_MERRA.nc');
 fileID = ncdf_open(ifile, /nowrite) &$
   wrsiID = ncdf_varid(fileID,'SoilMoist_v_NDVI') &$
   ncdf_varget,fileID, wrsiID, RCORRM

 ifile = file_search(indir+'LVT_RCORR_NDVI_NoahSM01_2001_2014_TE_GDAS.nc')
 fileID = ncdf_open(ifile, /nowrite) &$
   wrsiID = ncdf_varid(fileID,'SoilMoist_v_NDVI') &$
   ncdf_varget,fileID, wrsiID, RCORRG
 
pro FLDAS_EVAL_LVT

;this script makes plots of the LIS-WRSI (CHIRPS) similar to what is found on the USGS website
;calls the function get_nc for reading in the netcdf files more cleanly.
;3/3/2016 update mv to discover
;5/2/2016 add mask and some other stuff to plots.
;5/5/2016 continuing mask effort after LDT issues.
;06/06/2016 revist to fix up figures for the paper. I need anom correlation for all domains.
;for paths on chg rain and different old plots see fldas_eval_lvtv1
;10/21/2016 figures for revisions, where are the SSEB data?

indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/LVT_test/'
shapefile ='/discover/nobackup/almcnall/G2013_2012_0.shp' 
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
.compile /home/almcnall/Scripts/scripts_idl/get_domain25.pro

;for all of the ANOM COR with MW SMv2.2 use the following VOI
VOI = 'SoilMoist_v_SoilMoist' ;variable of interest 'SoilMoist_v_Rainf', SoilMoist_v_NDVI, Rainf, SoilMoist_v_SoilMoist


ifileE = file_search(indir+'ESACCI/STATS_EA_CM2_v2.2_92_14/LVT_ACORR_FINAL.201501010000.d01.nc') & print, ifileE
;ifileE = file_search(indir+'SPI/STATS_SPI1/SPI_TS.201105010000.d01.nc') & print, ifileE
;ifileE3 = file_search(indir+'SPI/STATS_SPI3/SPI_TS.201105010000.d01.nc') & print, ifileE3

ifileS = file_search(indir+'ESACCI/STATS_SA_CM2_v2.2_92_14/LVT_ACORR_FINAL.201501010000.d01.nc') & print, ifileS
ifileW = file_search(indir+'ESACCI/STATS_WA_CM2_v2.2_92_14/LVT_ACORR_FINAL.201501010000.d01.nc') & print, ifileW

ACORR_E = get_nc(VOI, ifileE)
ACORR_E(where(ACORR_E lt -10))=!values.f_nan

;ACORR_E3 = get_nc(VOI, ifileE3)
;ACORR_E3(where(ACORR_E3 lt -10))=!values.f_nan

ACORR_S= get_nc(VOI, ifileS)
ACORR_S(where(ACORR_S lt -10))=!values.f_nan

ACORR_W = get_nc(VOI, ifileW)
ACORR_W(where(ACORR_W lt -10))=!values.f_nan

;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
params = get_domain01('SA')

sNX = params[0]
sNY = params[1]
smap_ulx = params[2]
smap_lrx = params[3]
smap_uly = params[4]
smap_lry = params[5]

params = get_domain01('EA')

eNX = params[0]
eNY = params[1]
emap_ulx = params[2]
emap_lrx = params[3]
emap_uly = params[4]
emap_lry = params[5]

params = get_domain01('WA')

wNX = params[0]
wNY = params[1]
wmap_ulx = params[2]
wmap_lrx = params[3]
wmap_uly = params[4]
wmap_lry = params[5]

;;;read in landcover MODE to grab sparse veg mask;;;
;;;;eastern, southern africa;;;;;;
indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/'
mfile_E = file_search(indir+'lis_input.MODISmode_ea.nc')
mfile_S = file_search(indir+'lis_input_sa_elev_mode.nc')
mfile_W = file_search(indir+'lis_input_wa_elev_mode.nc')


VOI = 'LANDCOVER'
LC = get_nc(VOI, mfile_E)
bare = where(LC[*,*,15] eq 1, complement=other)
water = where(LC[*,*,16] eq 1, complement=other)
Emask = fltarr(eNX,eNY)+1.0
Emask(bare)=!values.f_nan
Emask(water)=!values.f_nan

LC = get_nc(VOI, mfile_S)
bare = where(LC[*,*,15] eq 1, complement=other)
water = where(LC[*,*,16] eq 1, complement=other)
Smask = fltarr(sNX,sNY)+1.0
Smask(bare)=!values.f_nan
Smask(water)=!values.f_nan

LC = get_nc(VOI, mfile_W)
bare = where(LC[*,*,15] eq 1, complement=other)
water = where(LC[*,*,16] eq 1, complement=other)
Wmask = fltarr(wNX,wNY)+1.0
Wmask(bare)=!values.f_nan
Wmask(water)=!values.f_nan

;;;;;FIGURES FOR FLDAS PAPER DON"T MESS THESE UP;;;;
;need this to get the colobar right
acorr_w[95:99]=1.0
help, acorr_e, acorr_s, acorr_w
;specify east, south or west here
;min_lon = MIN(lon)      & max_lon = MAX(lon)
;min_lat = MIN(lat)      & max_lat = MAX(lat)
acorr = acorr_w
map_ulx = wmap_ulx & min_lon = map_ulx
map_lry = wmap_lry & min_lat = map_lry
map_uly = wmap_uly & max_lat = map_uly
map_lrx = wmap_lrx & max_lon = map_lrx
mask = wmask
NX = wNX
NY = wNY
;;;;;;;;;this is a CONTOUR plot;;;;;;;;;;;
;N=23 at 0.352 (0.433 for two tail). 
;Add significance, greg's plot updates, and south sudanw = WINDOW(DIMENSIONS=[400,600])
shapefile = '/discover/nobackup/almcnall/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'
;w = WINDOW(DIMENSIONS=[700,900]);works for EA 700x900
w = WINDOW(DIMENSIONS=[1200,500]);works for EA 700x900

mlim = [min_lat,min_lon,max_lat,max_lon]
m1 = MAP('Geographic',LIMIT=mlim,/CURRENT,horizon_thick=1)
xsize=0.10
ysize=0.10
;index = [-0.1,0,0.3,0.5,0.7,0.9]
index = [-0.1,0.35,0.45,0.55,0.65,0.75,0.85]

ncolors = n_elements(index) ;is this right or do i add some?
tmpgr = CONTOUR(ACORR*mask, $
  FINDGEN(NX)*(xsize) + min_lon, FINDGEN(NY)*(ysize) + min_lat, $
  RGB_TABLE=64, /FILL, ASPECT_RATIO=1, BACKGROUND_COLOR='white', $
  C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./(ncolors-1)), $
  MAP_PROJECTION='Geographic', XSTYLE=1, YSTYLE=1, /OVERPLOT)
  tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
  ;position = x1,y1, x2, y2
  cb = COLORBAR(TARGET=tmpgr, POSITION=[0.05,0.05,0.95,0.09],FONT_SIZE=11,/BORDER)
  ;cb = COLORBAR(TARGET=tmpgr, POSITION=[0.05,0.2,0.95,0.25],FONT_SIZE=11,/BORDER)

  mc = MAPCONTINENTS(shapefile, /COUNTRIES,COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=mlim)
  tmpgr.save,'/home/almcnall/figs4SciData/SM_CCI_ACORR_WA_1026.png'
close

    
    ;;;;;;plot the CSV time series files;;;;;;;;;;;;;;;;;;;
    ;indir = '/home/sandbox/people/mcnally/FLDAS_EVAL/'
    indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/LVT_test/'

  ifile1 = file_search(indir+'MEAN_GABARONE_NOAH_CCI.dat')
  ifile1 = file_search(indir+'MEAN_KRUGER_NOAH_CCI.dat');MEAN_ALL_SA_CCI.dat
  ifile1 = file_search(indir+'MEAN_ALL_SA_CCI.dat');

  ifile1 = file_search(indir+'ESACCI/STATS_WA_CM2_v2.2_92_14/MEAN_WANKAMA.dat')
  ifile2 = file_search(indir+'ESACCI/STATS_WA_CM2_v2.2_92_14/MEAN_NIORO.dat')
  ifile3 = file_search(indir+'ESACCI/STATS_WA_CM2_v2.2_92_14/MEAN_ALL.dat')
  ;ifile1 = file_search(indir+'MEAN_HORN_NOAH_VIC.dat')& print, ifile1
  
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
  N = (2015-1992)*365
  CCISMw = reform(indat1.field01[11,0:n-1],365,23)
  niro = reform(indat2.field01[5,0:n-1],365,23);2=niro
  CCISMn = reform(indat2.field01[11,0:n-1],365,23);2=niro
  all = reform(indat3.field01[5,0:n-1],365,23);3=all
  CCISMa = reform(indat3.field01[11,0:n-1],365,23);3=all
  wank = reform(indat1.field01[5,0:n-1],365,23);1=wank


  
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
  
  ;soil moisture
  ifile1=file_search('/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/LVT_test/GIMMS/STATS_EA_0817/MEAN_EAST.dat')
  ifile1=file_search('/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/LVT_test/GIMMS/STATS_EA_0817/MEAN_SHEKA.dat')

  ;evapotranspiration..why no outputs for this?
  ifile1=file_search('/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/LVT_test/GIMMS/STATS_EA_0817et/MEAN_EAST.dat')
  ;ifile1=file_search('/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/LVT_test/GIMMS/STATS_EA_0817et/MEAN_SHEKA.dat')
  
  indat2 = read_ascii(ifile1, dlimiter=" ") & help, indat2
  indat2.field01(where(indat2.field01 lt -100))=!values.f_nan
  CCISM = reform(indat2.field01[11,0:4744],365,13)
  SM01 = reform(indat2.field01[5,0:4744],365,13)

;NDVI vs ET plots
ET = indat2.field01[5,*]
NDVI = indat2.field01[11,*]
p1=plot(ET)
p1=plot(NDVI, /overplot, 'b')

  w=window()
  p1 = plot(mean(ccismW,dimension=2,/nan),'c', name= 'CCI-SM')
  p2 = plot(mean(wank,dimension=2), 'b', linestyle=0, /overplot, name = 'wankama')
  ;p3 = plot(mean(niro,dimension=2), 'r', linestyle=0, /buffer, /overplot, name = 'niro')
  ;p4 = plot(mean(ccismN,dimension=2), 'orange', linestyle=0, /buffer, /overplot, name = 'niro')
  p5 = plot(mean(all,dimension=2), 'g', linestyle=0,  /overplot, name = 'all')
  p6 = plot(mean(ccismA,dimension=2), 'yellow', linestyle=0,/buffer,  /overplot, name = 'all')
  
  ;this suggests that they both tend to get the same clim but something happend yr to year?
  print, correlate(mean(ccismW,dimension=2,/nan),mean(wank,dimension=2,/nan))
  p1=plot(ccismW, wank, '*')
  
  
p6.save,'/home/almcnall/test.png'

  p2.xrange=[0,360]
  p2.xtickinterval=30
  p2.xtitle='DOY'
  p2.ytitle='m3/m3'
  p2.title = 'SM/MW climatology Keban, Turkey'
  ;p3 = plot(mean(SM01,dimension=2), 'b', linestyle=2, /overplot, name = 'NOAH-MERRA SM01')
  !null = legend(target=[p1,p2,p5,p6], orientation=0, shadow=0)

  
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
  
 params = get_domain25('EA')

 NX = params[0]
 NY = params[1]
 map_ulx = params[2]
 map_lrx = params[3]
 map_uly = params[4]

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

 params = get_domain25('SA')

 NX = params[0]
 NY = params[1]
 map_ulx = params[2]
 map_lrx = params[3]
 map_uly = params[4]
 map_lry = params[5]

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
;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
params = get_domain25('WA')

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

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
 

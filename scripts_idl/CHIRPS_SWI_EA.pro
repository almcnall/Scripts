;; THIS WORKSHEET IS DESIGNED TO DEVELOP DATA AND GRAPHICS TO SUPPORT THE
;; MANUSCRIPT SUBMISSION TO GLOBAL ENVIRONMENTAL CHANGE

;; 7/21 AM looking at the code, added &$ to for loops, note start and end months.
;; re-ran the code with updated CHIRPS, and looking at the Noah-EA domain too...
;; I don't totally trust this CHIRPS versioning 0 - probably best to agregate to month from the .nc file.
;; 7/31 revisiting. Mostly just need to make similar plots.
;; 8/5 made a copy for looking at the SWI from Noah and WRSI using making the same plots with the LIS7 output
;; 8/6 mapping the WRSI, SWI and SOS trends over last 30 yrs
;; 8/13 fixing up map for gary visit.

;FIGURE 1. Show that we can replicate EROS WRSI

;make the wrsi color table available
wkdir = '/home/source/mcnally/scripts_idl/'
cd, wkdir
.compile make_wrsi_cmap.pro

indir = '/home/chg-mcnally/LISWRSI_OUTPUT/LIS7/'
ifile = file_search(indir+'EA_OCT2FEB_WRSI_gw2_RFE_201011_FEB20.nc')

fileID = ncdf_open(ifile, /nowrite) &$
  wrsiID = ncdf_varid(fileID,'WRSI_inst') &$
  ncdf_varget,fileID, wrsiID, EOSwrsi

;nx = 294, ny = 348, nz = 33
dims = size(EOSwrsi, /dimensions)
NX = dims[0]
NY = dims[1]

;East africa domain
map_ulx = 22.05 & map_lrx = 51.35
map_uly = 22.95 & map_lry = -11.75

p1 = image(EOSwrsi, image_dimensions=[nx/10,ny/10],image_location=[map_ulx+0.35,map_lry+0.5], $
  RGB_TABLE=make_wrsi_cmap(),MIN_VALUE=0, title ='RFE2 FLDAS WRSI Short Rains (OND) 2010-2011') &$
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
  POSITION=[0.3,0.04,0.7,0.07], font_size=24) &$

  tmpclr = p1.rgb_table &$
  tmpclr[*,0] = [102,178,255] &$

  p1.rgb_table = tmpclr &$

  p1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot) &$
  p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FIGURE 2 - SHOW WRSI WITH CHIRPS TO COMPARE WITH FIG1'S RFE-WRSI 
wkdir = '/home/source/mcnally/scripts_idl/'
cd, wkdir
.compile make_wrsi_cmap.pro

indir = '/home/chg-mcnally/LISWRSI_OUTPUT/LIS7/'
ifile = file_search(indir+'EA_OCT2FEB_WRSI_inst_CHIRPS_8114.nc')

fileID = ncdf_open(ifile, /nowrite) &$
  wrsiID = ncdf_varid(fileID,'WRSI_inst') &$
  ncdf_varget,fileID, wrsiID, EOSwrsi

;nx = 294, ny = 348, nz = 33
dims = size(EOSwrsi, /dimensions)
NX = dims[0]
NY = dims[1]
NZ = dims[2]

;East africa domain
map_ulx = 22.05 & map_lrx = 51.35
map_uly = 22.95 & map_lry = -11.75

year = indgen(33)+1982
year = 2011

i = 29 ;THIS IS FEB 2011
i = 32 ; FEB 2014
p1 = image(EOSwrsi[*,*,i], image_dimensions=[nx/10,ny/10],image_location=[map_ulx+0.35,map_lry+0.5], $
  RGB_TABLE=make_wrsi_cmap(),MIN_VALUE=0, title ='CHIRPS FLDAS WRSI Short Rains (OND) 2013-2014')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
  POSITION=[0.3,0.04,0.7,0.07], font_size=24) &$

  tmpclr = p1.rgb_table &$
  tmpclr[*,0] = [102,178,255] &$
  p1.rgb_table = tmpclr &$

  p1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot) &$
  p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$

  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], THICK=2) &$

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FIGURE 3 - SHOW MOST RECENT EOS WRSI FOR THE DIFFERENT REGIONS. GO TO REGION SPP SCRIPT (E.G. WRSI_USGS_PLOTS_xxxxx.PRO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FIGURE 4 - TRENDS IN SOS AND FREQ OF NO STARTS -- this section is not complete 8/13
;; AND THIS IS THE SOS/WRSI SECTION

startyr = 1981
endyr = 2014
nyrs = endyr-startyr+1

;East Africa WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

ulx = (180.+map_ulx)*10.  & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10.   & lry = (50.-map_lry)*10.-1
;THIS PART MIGHT DIFFER BETWEEN GEOWRSI AND NOAH
NX = lrx - ulx + 1.5
NY = lry - uly + 2

;these are EAMay2Nov start-of-seasons
data_dir = '/home/sandbox/people/mcnally/SOS_GW2_YR/'

START = FLTARR(NX,NY,nyrs)
;this loop reads in the selected months only
for yr=startyr,endyr do begin &$
  fileID = ncdf_open(data_dir+STRING(FORMAT='(''SOS_GW2_'',I4.4,''.nc'')',yr), /nowrite) &$  
  SOSID = ncdf_varid(fileID,'SOS_inst') &$

  ncdf_varget,fileID, SOSID,SOS &$

  START[*,*,yr-startyr] =  SOS &$
endfor

start(where(start eq -9999.0))= !values.f_nan

;start(where(start ge 253.0)) = 1
;
;;no start freq...
;freq = start*!values.f_nan
;nostart = where(start ge 253)
;freq(nostart) = 1
;sum = total(freq,3,/nan)
;sum(where(sum eq 31))=!values.f_nan
;
;temp = image(sum, rgb_table=4)
;c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;  POSITION=[0.3,0.04,0.7,0.07], font_size=24)

;for the SOS file:
;start(where(start eq 60.0))=!values.f_nan

;map = MAP('Geographic',LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
;map.erase
;;MAX_VALUE = 1000
;tmpgr = IMAGE(CONGRID(MEAN(byte(START),DIMENSION=3,/NAN),4*NX,4*NY), MIN_VALUE=0., $
;  TITLE='avg LIS GEOWRSI (2000-2012)',FONT_SIZE=14,/ORDER,/CURRENT, $
;  MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
;  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry])
;;tmpgr.rgb_table=64
;tmpgr.rgb_table=make_wrsi_cmap()
;tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
;tmpgr.mapgrid.FONT_SIZE = 10
;m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
;cb = colorbar(target=tmpgr,ORIENTATION=1,FONT_SIZE=12)


;*********
; accumulated precip == go to CHIRPS_NDVI_EA.pro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SWI stuff.....

startyr = 2000
endyr = 2013
nyrs = endyr-startyr+1

startmo = 3
endmo = 6
nmos = endmo - startmo+1

;;Yemen
;map_ulx = 42.	& map_lrx = 48.
;map_uly = 18.	& map_lry = 12.

;East Africa WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

;CHIRPS at 0.05
;ulx = (180.+map_ulx)*20.	& lrx = (180.+map_lrx)*20.-1
;uly = (50.-map_uly)*20.		& lry = (50.-map_lry)*20.-1
;NX = lrx - ulx + 1
;NY = lry - uly + 1

ulx = (180.+map_ulx)*10.  & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10.   & lry = (50.-map_lry)*10.-1
NX = lrx - ulx + 1.5
NY = lry - uly + 2

;data_dir = '/home/sandbox/people/mcnally/SM02_YRMO/'
;data_dir = '/home/sandbox/people/mcnally/SWI_YRMO/'
data_dir = '/home/sandbox/people/mcnally/SWI_GW2_YRMO/'

;what is the best way to treat the SWI? like soil moisture/rainfall or NDVI 
;data_dir = '/home/ftp_out/products/CHIRPS-latest/global_monthly/tifs/'
chirp = FLTARR(NX,NY,nyrs)
;this loop reads in the selected months only
for yr=startyr,endyr do begin &$
   for i=0,nmos-1 do begin &$
      y = yr &$
      m = startmo + i &$
      if m gt 12 then begin &$
         m = m-12 &$
         y = y+1 &$
      endif &$
      ;full_globe = READ_TIFF(data_dir+STRING(FORMAT='(''chirps-v1.8.'',I4.4,''.'',I2.2,''.tif'')',y,m)) &$
      ;fileID = ncdf_open(data_dir+STRING(FORMAT='(''CHIRPS_'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
     ; fileID = ncdf_open(data_dir+STRING(FORMAT='(''SWI_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
      fileID = ncdf_open(data_dir+STRING(FORMAT='(''SWI_GW2_'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$


      ;RainID = ncdf_varid(fileID,'TotalPrecip_tavg') &$
      NSWIID = ncdf_varid(fileID,'SWI_inst') &$
     ; ncdf_varget,fileID, RainID, RAIN &$
      ncdf_varget,fileID, NSWIID,NSWI &$

      ;chirp[*,*,yr-startyr] = RAIN &$
      ;ah, this generates the seasonal total for months of interest
      ;chirp[*,*,yr-startyr] = chirp[*,*,yr-startyr] + full_globe[ulx:lrx,uly:lry] &$
      ; chirp[*,*,yr-startyr] = chirp[*,*,yr-startyr] + RAIN*864000 &$
      nswi(where(nswi eq 255.)) = 1 &$
       chirp[*,*,yr-startyr] = chirp[*,*,yr-startyr] + NSWI &$

   endfor &$
endfor
chirp = reverse(chirp,2)

chirp(where(chirp lt 0)) = !values.f_nan
;dims = size(RAIN, /dimensions)
dims = size(NSWI, /dimensions)

NX = dims[0]
NY = dims[1]
;NZ = dims[2]

;I went from dek to month...what is the unit conversion? I think I am totaling so 864000 is good?
;these are upside-down i guess, which is suprising...

map = MAP('Geographic',LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
map.erase
;MAX_VALUE = 1000
tmpgr = IMAGE(CONGRID(MEAN(chirp,DIMENSION=3),4*NX,4*NY),RGB_TABLE=64, MIN_VALUE=0., $
   TITLE='LIS-SWI Mar-Sep Total (2000-2013)',FONT_SIZE=14,/ORDER,/CURRENT, $
   MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
   IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry])
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
tmpgr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=tmpgr,ORIENTATION=1,FONT_SIZE=12)

; convert CHIRP to SPI
chspi = FLTARR(SIZE(chirp,/DIMENSIONS))
for y=0,NY-1 do begin &$
   for x=0,NX-1 do begin &$
      if MEAN(CHIRP[x,y,*]) gt 0.0 then chspi[x,y,*] = PRECIP_2_SPI_GH(chirp[x,y,*]) &$
   endfor &$
endfor

ncolors = 10
tmpdif = IMAGE(CONGRID(MEAN(chspi[*,*,6:11],DIMENSION=3)-MEAN(chspi[*,*,0:5],DIMENSION=3),4*NX,4*NY), $
   RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), MAX_VALUE=1.25,MIN_VALUE=-1.25, $
   TITLE='CHIRPS Mar-Sep SPI Difference !C 2000-2006 Mean Minus 2007-2013 Mean',FONT_SIZE=16,/ORDER,/CURRENT, $
   MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
   IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry])
tmpdif.mapgrid.linestyle = 6 & tmpdif.mapgrid.label_position = 0
tmpdif.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=tmpdif,ORIENTATION=1,/BORDER,FONT_SIZE=12)

;;; GET MAMJ TREND MAP FOR FOR EAST AFRICA 
nskip = 0	; skip the first n-years of the timeseries when calculating the trend
trendmap = FLTARR(NX,NY) 
trendcor = FLTARR(NX,NY)
for y=0,NY-1 do begin &$
   for x=0,NX-1 do begin &$
      if MEAN(CHIRP[x,y,*]) gt 0.0 then begin &$
         trendmap[x,y] = REGRESS(INDGEN(nyrs-nskip),REFORM(CHIRP[x,y,nskip:nyrs-1]),MCORRELATION=r) &$
         trendcor[x,y] = r &$
      endif &$
   endfor &$
endfor

;changed max/min from 10 to 0.1

ncolors = 15
tmptr = IMAGE(CONGRID(trendmap,4*NX,4*NY),RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),MIN_VALUE=-70., MAX_VALUE=70., $
   TITLE=STRING(FORMAT='(''CHIRPS geoWRSI-SWI Mar-Sep Trend '',I4.4,''-2013 (percent/year)'')',startyr+nskip),FONT_SIZE=16,/ORDER,/CURRENT, $
   MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
   IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry])
tmptr.mapgrid.linestyle = 6 & tmptr.mapgrid.label_position = 0
tmptr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=tmptr,ORIENTATION=1,/BORDER)

;do you use the trend cor to mask out signficance?
tmpcr = IMAGE(CONGRID(trendcor,4*NX,4*NY),RGB_TABLE=8,MAX_VALUE=1.,MIN_VALUE=0., $
   TITLE='Trend Correlation',FONT_SIZE=14,/ORDER,/CURRENT, $
   MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
   IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry])
colors = 10 & rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))
rgbdump = tmpcr.rgb_table & tmpcr.rgb_table = CONGRID(rgbdump[*,rgbind],3,256)
tmpcr.mapgrid.linestyle = 6 & tmpcr.mapgrid.label_position = 0
tmpcr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[250,250,250],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=tmpcr,ORIENTATION=1,/BORDER)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;AND THIS IS THE GEOWRSI SWI SECTION. 

startyr = 2000
endyr = 2013
nyrs = endyr-startyr+1

startmo = 3
endmo = 6
nmos = endmo - startmo+1

;;Yemen
;map_ulx = 42.  & map_lrx = 48.
;map_uly = 18.  & map_lry = 12.

;East Africa WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

ulx = (180.+map_ulx)*10.  & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10.   & lry = (50.-map_lry)*10.-1
;THIS PART MIGHT DIFFER BETWEEN GEOWRSI AND NOAH
NX = lrx - ulx + 1.5
NY = lry - uly + 2

data_dir = '/home/sandbox/people/mcnally/SWI_GW2_YRMO/'

;what is the best way to treat the SWI? like soil moisture/rainfall or NDVI
;data_dir = '/home/ftp_out/products/CHIRPS-latest/global_monthly/tifs/'
chirp = FLTARR(NX,NY,nyrs)
;this loop reads in the selected months only
for yr=startyr,endyr do begin &$
  for i=0,nmos-1 do begin &$
  y = yr &$
  m = startmo + i &$
  if m gt 12 then begin &$
  m = m-12 &$
  y = y+1 &$
endif &$

fileID = ncdf_open(data_dir+STRING(FORMAT='(''SWI_GW2_'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$

;RainID = ncdf_varid(fileID,'TotalPrecip_tavg') &$
GSWIID = ncdf_varid(fileID,'SWI_inst') &$
; ncdf_varget,fileID, RainID, RAIN &$
ncdf_varget,fileID, GSWIID,GSWI &$

GSWI(where(GSWI eq 255)) = !values.f_nan &$
;chirp[*,*,yr-startyr] = RAIN &$
;ah, this generates the seasonal total for months of interest
;chirp[*,*,yr-startyr] = chirp[*,*,yr-startyr] + full_globe[ulx:lrx,uly:lry] &$
; chirp[*,*,yr-startyr] = chirp[*,*,yr-startyr] + RAIN*864000 &$
;this is adding them....but not the cray numbs
chirp[*,*,yr-startyr] = chirp[*,*,yr-startyr] + GSWI &$

endfor &$
endfor
chirp(where(chirp lt 0)) = !values.f_nan
;dims = size(RAIN, /dimensions)
dims = size(GSWI, /dimensions)

NX = dims[0]
NY = dims[1]
;NZ = dims[2]

;I went from dek to month...what is the unit conversion? I think I am totaling so 864000 is good?
;these are upside-down i guess, which is suprising...

map = MAP('Geographic',LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
map.erase
chirp = reverse(chirp,2)
;MAX_VALUE = 1000
tmpgr = IMAGE(CONGRID(MEAN(chirp,DIMENSION=3,/NAN),4*NX,4*NY),RGB_TABLE=64, MIN_VALUE=0., MAX_VALUE=400., $
  TITLE='LIS GEOWRSI-SWI Mar-Sep Total (2001-2013)',FONT_SIZE=14,/ORDER,/CURRENT, $
  MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry])
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
tmpgr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=tmpgr,ORIENTATION=1,FONT_SIZE=12)


;;; GET MAMJ TREND MAP FOR FOR EAST AFRICA
nskip = 0 ; skip the first n-years of the timeseries when calculating the trend
trendmap = FLTARR(NX,NY)
trendcor = FLTARR(NX,NY)
for y=0,NY-1 do begin &$
  for x=0,NX-1 do begin &$
  if MEAN(CHIRP[x,y,*]) gt 0.0 then begin &$
  trendmap[x,y] = REGRESS(INDGEN(nyrs-nskip),REFORM(CHIRP[x,y,nskip:nyrs-1]),MCORRELATION=r) &$
  trendcor[x,y] = r &$
endif &$
endfor &$
endfor

;changed max/min from 10 to 0.1

ncolors = 15
tmptr = IMAGE(CONGRID(trendmap,4*NX,4*NY),RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),MIN_VALUE=-75., MAX_VALUE=75., $
  TITLE=STRING(FORMAT='(''geoWRSI SWI Mar-Sep Trend '',I4.4,''-2013 (mm/year)'')',startyr+nskip),FONT_SIZE=16,/ORDER,/CURRENT, $
  MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry])
tmptr.mapgrid.linestyle = 6 & tmptr.mapgrid.label_position = 0
tmptr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=tmptr,ORIENTATION=1,/BORDER)

;do you use the trend cor to mask out signficance?
tmpcr = IMAGE(CONGRID(trendcor,4*NX,4*NY),RGB_TABLE=8,MAX_VALUE=1.,MIN_VALUE=0., $
  TITLE='Trend Correlation',FONT_SIZE=14,/ORDER,/CURRENT, $
  MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry])
colors = 10 & rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))
rgbdump = tmpcr.rgb_table & tmpcr.rgb_table = CONGRID(rgbdump[*,rgbind],3,256)
tmpcr.mapgrid.linestyle = 6 & tmpcr.mapgrid.label_position = 0
tmpcr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[250,250,250],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=tmpcr,ORIENTATION=1,/BORDER)

;; AND THIS IS THE SOS/WRSI SECTION

startyr = 2001
endyr = 2014
nyrs = endyr-startyr+1

;;Yemen
;map_ulx = 42.  & map_lrx = 48.
;map_uly = 18.  & map_lry = 12.

;East Africa WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

ulx = (180.+map_ulx)*10.  & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10.   & lry = (50.-map_lry)*10.-1
;THIS PART MIGHT DIFFER BETWEEN GEOWRSI AND NOAH
NX = lrx - ulx + 1.5
NY = lry - uly + 2

;which run did i pull these from? EAMay2Nov...where are the ONDs?
;data_dir = '/home/sandbox/people/mcnally/SOS_GW2_YR/'
;data_dir = '/home/sandbox/people/mcnally/WRSI_May2Nov_GW2_YR/'
data_dir = '/home/sandbox/people/mcnally/WRSI_OND_Noah/' ;feb 2001-feb 2014 (I think...)
;data_dir = '/home/sandbox/people/mcnally/WRSI_OND_GW2_YR/' ;feb 1982-feb2014


;what is the best way to treat the SWI? like soil moisture/rainfall or NDVI
;data_dir = '/home/ftp_out/products/CHIRPS-latest/global_monthly/tifs/'
START = FLTARR(NX,NY,nyrs)
;this loop reads in the selected months only
for yr=startyr,endyr do begin &$
;  fileID = ncdf_open(data_dir+STRING(FORMAT='(''WRSI_OND_GW2_'',I4.4,''.nc'')',yr), /nowrite) &$
;  SOSID = ncdf_varid(fileID,'WRSI_inst') &$

  fileID = ncdf_open(data_dir+STRING(FORMAT='(''WRSI_OND_Noah'',I4.4,''.nc'')',yr), /nowrite) &$
  SOSID = ncdf_varid(fileID,'WRSI_TimeStep_inst') &$

  ;SOSID = ncdf_varid(fileID,'SOS_inst') &$

  ncdf_varget,fileID, SOSID,SOS &$

  ;START[*,*,yr-startyr] =  SOS &$
  START[*,*,yr-startyr] =  SOS*reverse(oceanmask,2) &$

endfor
start = reverse(start,2)

;this is not quite right. somehow both of these make null land blue when i want the ocean to be blue.
start(where(start eq -9999.9))=!values.f_nan
start(where(start eq -9999.0))=0

;start(where(start ge 253.0)) = 1
;
;;no start freq...
;freq = start*!values.f_nan
;nostart = where(start ge 253)
;freq(nostart) = 1
;sum = total(freq,3,/nan)
;sum(where(sum eq 31))=!values.f_nan
;
;temp = image(sum, rgb_table=4)
;c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;  POSITION=[0.3,0.04,0.7,0.07], font_size=24)

;for the SOS file:
;start(where(start eq 60.0))=!values.f_nan

;I went from dek to month...what is the unit conversion? I think I am totaling so 864000 is good?
;these are upside-down i guess, which is suprising...

;map = MAP('Geographic',LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
;map.erase
;;MAX_VALUE = 1000
;tmpgr = IMAGE(CONGRID(MEAN(byte(START),DIMENSION=3,/NAN),4*NX,4*NY), MIN_VALUE=0., $
;  TITLE='avg LIS GEOWRSI (2000-2012)',FONT_SIZE=14,/ORDER,/CURRENT, $
;  MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
;  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry])
;;tmpgr.rgb_table=64
;tmpgr.rgb_table=make_wrsi_cmap()
;tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
;tmpgr.mapgrid.FONT_SIZE = 10
;m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
;cb = colorbar(target=tmpgr,ORIENTATION=1,FONT_SIZE=12)

;make the oceanmask with the geoWRSI (not Noah)
oceanmask = start[*,*,10]
land = where(finite(oceanmask), complement=mar)
oceanmask(land)=1
oceanmask(mar)=-9999.9

;******or just for one year.******
;2011 doesn't look how i expect it to...compare to Noah's WRSI...
;tmpgr = IMAGE(CONGRID(byte(START[*,*,10]),4*NX,4*NY), $
;  TITLE='EROS WRSI Feb 2011',FONT_SIZE=14,/ORDER,/CURRENT, $
;  MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
;  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry])
;;tmpgr.rgb_table=64
;tmpgr.rgb_table=make_wrsi_cmap()
;rgbdump = tmpgr.rgb_table 
; ;rgbdump[*,0] = [200,200,200]
; rgbdump[*,0] = [102,178,255]
;
;tmpgr.rgb_table = rgbdump
;cb = colorbar(target=tmpgr,ORIENTATION=1,FONT_SIZE=12)
;tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
;tmpgr.mapgrid.FONT_SIZE = 10
;m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])

;ah, what is SUM?
ncolors=16
tmpgr = IMAGE(CONGRID(SUM,4*NX,4*NY),RGB_TABLE=64, MIN_VALUE=0, MAX_VALUE=16., $
  TITLE='Frequency of No Start of Season',FONT_SIZE=14,/ORDER,/CURRENT, $
  MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry])
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
    rgbdump = tmpgr.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
    rgbdump[*,0] = [200,200,200]
    tmpgr.rgb_table = rgbdump
    cb = colorbar(target=tmpgr,ORIENTATION=1,FONT_SIZE=12)

tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
tmpgr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])

;;; GET MAMJ TREND MAP FOR FOR EAST AFRICA
nskip = 0 ; skip the first n-years of the timeseries when calculating the trend
trendmap = FLTARR(NX,NY)
trendcor = FLTARR(NX,NY)
for y=0,NY-1 do begin &$
  for x=0,NX-1 do begin &$
  if MEAN(start[x,y,*]) gt 0.0 then begin &$
  trendmap[x,y] = REGRESS(INDGEN(nyrs-nskip),REFORM(start[x,y,nskip:nyrs-1]),MCORRELATION=r) &$
  trendcor[x,y] = r &$
endif &$
endfor &$
endfor

;go back to the old colorscheme for WRSI.
ncolors = 11
tmptr = IMAGE(CONGRID(trendmap,4*NX,4*NY),MIN_value=-10, max_value=10, $
  TITLE=STRING(FORMAT='(''geoWRSI WRSI Trend '',I4.4,''-2013 (pnts/year)'')',startyr+nskip),FONT_SIZE=16,/ORDER,/CURRENT, $
  MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry])
;tmptr.RGB_TABLE = 67
tmptr.RGB_TABLE = CONGRID(make_cmap(ncolors),3,256)
tmptr.mapgrid.linestyle = 6 & tmptr.mapgrid.label_position = 0
tmptr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=tmptr,ORIENTATION=1,/BORDER)

;do you use the trend cor to mask out signficance?
tmpcr = IMAGE(CONGRID(trendcor,4*NX,4*NY),RGB_TABLE=8,MAX_VALUE=1.,MIN_VALUE=0., $
  TITLE='Trend Correlation',FONT_SIZE=14,/ORDER,/CURRENT, $
  MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry])
colors = 10 & rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))
rgbdump = tmpcr.rgb_table & tmpcr.rgb_table = CONGRID(rgbdump[*,rgbind],3,256)
tmpcr.mapgrid.linestyle = 6 & tmpcr.mapgrid.label_position = 0
tmpcr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[250,250,250],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=tmpcr,ORIENTATION=1,/BORDER)


;; map only significant areas...KEEP WORKING ON THIS.
sig_thresh = 0.5
tmptrnd = FLTARR(NX,NY) & tmptrnd[WHERE(trendcor gt sig_thresh)] = trendmap[WHERE(trendcor gt sig_thresh)]
scrtr = IMAGE(CONGRID(tmptrnd/10000.,500,500),RGB_TABLE=66,MAX_VALUE=0.01,MIN_VALUE=-0.01, $
  TITLE=STRING(FORMAT='(''NDVI Trend '',I4.4,''-2011 (NDVI/year)'')',startyr+nskip),FONT_SIZE=16,/ORDER, $
  MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry],/CURRENT)
ncolors = 10 & rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))
rgbdump = scrtr.rgb_table & scrtr.rgb_table = CONGRID(rgbdump[*,rgbind],3,256)
scrtr.mapgrid.linestyle = 6 & scrtr.mapgrid.label_position = 0
scrtr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=scrtr,ORIENTATION=1,/BORDER)









;;; AND THIS IS THE NDVI SECTION - what time period is this for?? i dunno why this has nz=720
afrNX = 900
afrNY = 960
afrNZ = 720
startyr = 2001
endyr = 2011
nyrs = endyr - startyr +1

ulx = (map_ulx + 20.) *12.
lrx = (map_lrx + 20.) *12. -1
uly = (40. - map_lry) *12. -1
lry = (40. - map_uly) *12. 
ghax = lrx - ulx +1   & ghay = uly - lry +1


molist = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec']
startmo = 5
endmo = 9
npers = (endmo - startmo +1) *2

;I am not sure what time step the GIMMS is in/. weird. 
;where is the script that uses eMODIS?
;data_dir = '/home/jower/Data/LTDR_NDVI/GIMMS/regional_cubes/'
data_dir = '/raid2/riff/jower/Data/LTDR_NDVI/GIMMS/regional_cubes/'

tmpafr = INTARR(afrNX,afrNY,afrNZ)
close,1
openr,1,data_dir+'GIMMS3g_africa.img'
readu,1,tmpafr
close,1

tmpafr = tmpafr[ulx:lrx,lry:uly,*]

ndvi = tmpafr[*,*,(startmo-1)*2:(endmo*2)-1]
for i=1,nyrs-1 do begin &$
  ndvi = [[[ndvi]],[[tmpafr[*,*,(i*24)+(startmo-1)*2:(i*24)+(endmo*2)-1]]]] &$
  print, i &$
endfor
delvar,tmpafr

;; data is read in, subset for horn and given months, now look at max composite, and mean
nave = FLTARR(ghax,ghay,nyrs)
nmax = INTARR(ghax,ghay,nyrs)
for x=0,ghax-1 do begin &$
   for y=0,ghay-1 do begin &$
      for z=0,nyrs-1 do begin &$
         nave[x,y,z] = MEAN(ndvi[x,y,(z*npers):((z+1)*npers)-1]) &$
	       nmax[x,y,z] = MAX(ndvi[x,y,(z*npers):((z+1)*npers)-1]) &$
      endfor &$
   endfor &$
endfor

; normalized NDVI...or does this actaully do something with SPI?
ndspi = FLTARR(SIZE(nmax,/DIMENSIONS))
for y=0,ghaY-1 do begin &$
   for x=0,ghaX-1 do begin &$
      if MEAN(nmax[x,y,*]) gt 0.0 then ndspi[x,y,*] = PRECIP_2_SPI_GH(nmax[x,y,*]) &$
   endfor &$
endfor

; map the change in max NDVI over 2 periods
tmpdif = IMAGE(CONGRID((MEAN(nmax[*,*,5:9],DIMENSION=3) - MEAN(nmax[*,*,0:4],DIMENSION=3))/10000.,6*ghax,6*ghay), $
   RGB_TABLE=66,MAX_VALUE=0.1,MIN_VALUE=-0.1, $;LAYOUT=[2,1,1], $
   TITLE='GIMMS Max MJJAS NDVI !C 2006-2011 Mean Minus 2002-2005 Mean',FONT_SIZE=16,/ORDER, $
   MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
   IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry],/CURRENT)
ncolors = 10 & rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))
rgbdump = tmpdif.rgb_table & tmpdif.rgb_table = 67 & rgbdump2 = tmpdif.rgb_table & rgbdump[*,128:255] = rgbdump2[*,128:255]
tmpdif.rgb_table = CONGRID(rgbdump[*,rgbind],3,256)
tmpdif.mapgrid.linestyle = 6 & tmpdif.mapgrid.label_position = 0
tmpdif.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=tmpdif,ORIENTATION=1,/BORDER)

tmpdif = IMAGE(CONGRID(MEAN(ndspi[*,*,5:9],DIMENSION=3) - MEAN(ndspi[*,*,0:4],DIMENSION=3),6*ghax,6*ghay), $
   RGB_TABLE=66,MAX_VALUE=1.25,MIN_VALUE=-1.25, $
   TITLE='GIMMS Normalized Max MJJA NDVI !C 1999-2011 Mean Minus 1982-1998 Mean',FONT_SIZE=16,/ORDER, $
   MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
   IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry],/CURRENT)
ncolors = 10 & rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))
rgbdump = tmpdif.rgb_table & tmpdif.rgb_table = 67 & rgbdump2 = tmpdif.rgb_table & rgbdump[*,128:255] = rgbdump2[*,128:255]
tmpdif.rgb_table = CONGRID(rgbdump[*,rgbind],3,256)
tmpdif.mapgrid.linestyle = 6 & tmpdif.mapgrid.label_position = 0
tmpdif.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=tmpdif,ORIENTATION=1,/BORDER)
 
;; get the trend and correlations
nskip = 0       ; skip the first n-years of the timeseries when calculating the trend
trendmap = FLTARR(ghax,ghay)
trendcor = FLTARR(ghax,ghay)
for y=0,ghay-1 do begin &$
   for x=0,ghax-1 do begin &$
      if MEAN(nave[x,y,*]) gt 0.0 then begin &$
         trendmap[x,y] = REGRESS(INDGEN(nyrs-nskip),REFORM(nmax[x,y,nskip:nyrs-1]),MCORRELATION=r) &$
         trendcor[x,y] = r &$
      endif &$
   endfor &$
endfor

tmptr = IMAGE(CONGRID(trendmap/10000.,6*ghax,6*ghay),RGB_TABLE=66,MAX_VALUE=0.01,MIN_VALUE=-0.01, $;LAYOUT=[2,1,1], $
   TITLE=STRING(FORMAT='(''Trend in Max May-Sep NDVI '',I4.4,''-2011 (NDVI/year)'')',startyr+nskip),FONT_SIZE=16,/ORDER, $
   MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
   IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry],/CURRENT)
ncolors = 9 & rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))
rgbdump = tmptr.rgb_table & tmptr.rgb_table = 67 & rgbdump2 = tmptr.rgb_table & rgbdump[*,128:255] = rgbdump2[*,128:255]
tmptr.rgb_table = CONGRID(rgbdump[*,rgbind],3,256)
tmptr.mapgrid.linestyle = 6 & tmptr.mapgrid.label_position = 0
tmptr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=tmptr,ORIENTATION=1,/BORDER,FONT_SIZE=10)

tmpcr = IMAGE(trendcor,RGB_TABLE=8,MAX_VALUE=0.5,MIN_VALUE=0., LAYOUT=[2,1,2], $
   TITLE='Trend Correlation',FONT_SIZE=14,/ORDER, $
   MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
   IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry],/CURRENT)
ncolors = 10 & rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))
rgbdump = tmpcr.rgb_table & tmpcr.rgb_table = CONGRID(rgbdump[*,rgbind],3,256)
tmpcr.mapgrid.linestyle = 6 & tmpcr.mapgrid.label_position = 0
tmpcr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[250,250,250],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=tmpcr,ORIENTATION=1,/BORDER)

;; map only significant areas
sig_thresh = 0.5
tmptrnd = FLTARR(ghax,ghay)	& tmptrnd[WHERE(trendcor gt sig_thresh)] = trendmap[WHERE(trendcor gt sig_thresh)]
scrtr = IMAGE(CONGRID(tmptrnd/10000.,500,500),RGB_TABLE=66,MAX_VALUE=0.01,MIN_VALUE=-0.01, $
   TITLE=STRING(FORMAT='(''NDVI Trend '',I4.4,''-2011 (NDVI/year)'')',startyr+nskip),FONT_SIZE=16,/ORDER, $
   MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
   IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry],/CURRENT)
ncolors = 10 & rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))
rgbdump = scrtr.rgb_table & scrtr.rgb_table = CONGRID(rgbdump[*,rgbind],3,256)
scrtr.mapgrid.linestyle = 6 & scrtr.mapgrid.label_position = 0
scrtr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=scrtr,ORIENTATION=1,/BORDER)

;;; GET NDVI AND RAINFALL TO LINE UP AND DO SOME COMPARISONS
rn2nd = CONGRID(chirp[*,*,0:10],ghax,ghay,11)

;; get the trend and correlations
nskip = 20       ; skip the first n-years of the timeseries when calculating the trend
nrcor = FLTARR(ghax,ghay)
for y=0,ghay-1 do begin &$
   for x=0,ghax-1 do begin &$
      if MEAN(nave[x,y,*]) gt 0.0 AND MEAN(rn2nd[x,y,*]) gt 0.0 then begin &$
         nrcor[x,y] = CORRELATE(rn2nd[x,y,nskip:nyrs-1],nmax[x,y,nskip:nyrs-1]) &$
      endif &$
   endfor &$
endfor

tmpcr = IMAGE(CONGRID(nrcor,500,500),RGB_TABLE=73,MAX_VALUE=1.0,MIN_VALUE=-1.0, $
   TITLE=STRING(FORMAT='(''CHIRPS/NDVI Correlation '',I4.4,''-2011'')',startyr+nskip),FONT_SIZE=16,/ORDER, $
   MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
   IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry],/CURRENT)
ncolors = 11 & rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))
rgbdump = tmpcr.rgb_table & tmpcr.rgb_table = CONGRID(rgbdump[*,rgbind],3,256)
tmpcr.mapgrid.linestyle = 6 & tmpcr.mapgrid.label_position = 0
tmpcr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=tmpcr,ORIENTATION=1,/BORDER)




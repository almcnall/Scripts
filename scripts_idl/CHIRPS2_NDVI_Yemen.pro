;; THIS WORKSHEET IS DESIGNED TO DEVELOP DATA AND GRAPHICS TO SUPPORT THE
;; MANUSCRIPT SUBMISSION TO GLOBAL ENVIRONMENTAL CHANGE
;; 7/21 AM looking at the code, added &$ to for loops, note start and end months.
;
; Africa Check
startyr = 1981
endyr = 2013 
nyrs = endyr-startyr+1
startmo = 3
endmo = 5
nmos = endmo - startmo+1

map_ulx = 42.	& map_lrx = 48.
map_uly = 18.	& map_lry = 12.
ulx = (180.+map_ulx)*20.	& lrx = (180.+map_lrx)*20.-1
uly = (50.-map_uly)*20.		& lry = (50.-map_lry)*20.-1
NX = lrx - ulx + 1
NY = lry - uly + 1

;data_dir = '/home/CHIRPS/monthly/v8/'
data_dir = '/home/CHIRPS/monthly/v2.0/'

;chirps-v2.0.2015.06.tif

chirp = FLTARR(NX,NY,nyrs)
for yr=startyr,endyr do begin &$
   for i=0,nmos-1 do begin &$
      y = yr &$
      m = startmo + i &$
      if m gt 12 then begin &$
         m = m-12 &$
         y = y+1 &$
      endif &$
      full_globe = READ_TIFF(data_dir+STRING(FORMAT='(''chirps-v2.0.'',I4.4,''.'',I2.2,''.tif'')',y,m)) &$
      chirp[*,*,yr-startyr] = chirp[*,*,yr-startyr] + full_globe[ulx:lrx,uly:lry] &$
   endfor &$
endfor

map = MAP('Geographic',LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
map.erase

tmpgr = IMAGE(CONGRID(MEAN(chirp,DIMENSION=3),4*NX,4*NY),RGB_TABLE=64,MAX_VALUE=400, MIN_VALUE=0., $
   TITLE='CHIRPS Mar-Sep Total (1981-2013)',FONT_SIZE=14,/ORDER,/CURRENT, $
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
tmpdif = IMAGE(CONGRID(MEAN(chspi[*,*,18:32],DIMENSION=3)-MEAN(chspi[*,*,4:17],DIMENSION=3),4*NX,4*NY), $
   RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), MAX_VALUE=1.25,MIN_VALUE=-1.25, $
   TITLE='CHIRPS MAM SPI Difference !C 1999-2013 Mean Minus 1985-1998 Mean',FONT_SIZE=16,/ORDER,/CURRENT, $
   MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
   IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry])
tmpdif.mapgrid.linestyle = 6 & tmpdif.mapgrid.label_position = 0
tmpdif.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=tmpdif,ORIENTATION=1,/BORDER,FONT_SIZE=12)

;;; GET MAMJ TREND MAP FOR FOR EAST AFRICA 
nskip = 10	; skip the first n-years of the timeseries when calculating the trend
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

ncolors = 14
tmptr = IMAGE(CONGRID(trendmap,4*NX,4*NY),RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),MAX_VALUE=7.,MIN_VALUE=-7., $
   TITLE=STRING(FORMAT='(''CHIRPS MAM Trend '',I4.4,''-2013 (mm/year)'')',startyr+nskip),FONT_SIZE=16,/ORDER,/CURRENT, $
   MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
   IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry])
tmptr.mapgrid.linestyle = 6 & tmptr.mapgrid.label_position = 0
tmptr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=tmptr,ORIENTATION=1,/BORDER)

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


;;; AND THIS IS THE NDVI SECTION
;the GIMMS East Africa file has changed, and need to clip to yemen domain.
;afrNX = 900, now 281
;afrNY = 960, now 382
;afrNZ = 720, now 780
startyr = 1982
endyr = 2013
nyrs = endyr - startyr +1


map_ulx = 42. & map_lrx = 48.
map_uly = 18. & map_lry = 12.
ulx = (180.+map_ulx)*20.  & lrx = (180.+map_lrx)*20.-1
uly = (50.-map_uly)*20.   & lry = (50.-map_lry)*20.-1
NX = lrx - ulx + 1
NY = lry - uly + 1


;this part is nottt right, i need the dims on this ndvi file
ulx = (map_ulx - 28.) *12.
lrx = (map_lrx - 28.) *12. -1
uly = (12. + map_lry) *12. -1
lry = (12. + map_uly) *12. 
ghax = lrx - ulx +1   & ghay = lry - uly +1


molist = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec']
startmo = 4
endmo = 6
npers = (endmo - startmo +1) *2

;data_dir = '/home/jower/Data/LTDR_NDVI/GIMMS/regional_cubes/'
;data_dir = '/raid2/riff/jower/Data/LTDR_NDVI/GIMMS/regional_cubes/'

;tmpafr = INTARR(afrNX,afrNY,afrNZ)
;close,1
;openr,1,data_dir+'GIMMS3g_africa.img'
;readu,1,tmpafr
;close,1
;tmpafr = tmpafr[ulx:lrx,lry:uly,*]

data_dir = '/home/sandbox/people/mcnally/'
;;read in and sub/superset the data
fileID = ncdf_open(data_dir+'/GIMMS-3g_EastAfrica_AM.nc') &$
  ndviID = ncdf_varid(fileID,'NDVI3g') &$
  ncdf_varget,fileID,ndviID, GIMMS
GIMMS = reverse(GIMMS,2)



ndvi = GIMMS[*,*,(startmo-1)*2:(endmo*2)-1]
for i=1,nyrs-1 do ndvi = [[[ndvi]],[[GIMMS[*,*,(i*24)+(startmo-1)*2:(i*24)+(endmo*2)-1]]]]
delvar,tmpafr

;subset for yemen:
ndviY = ndvi[ulx:lrx,uly:lry,*]

;; data is read in, subset for horn and given months, now look at max composite, and mean
nave = FLTARR(ghax,ghay,nyrs)
nmax = INTARR(ghax,ghay,nyrs)
for x=0,ghax-1 do begin &$
   for y=0,ghay-1 do begin &$
      for z=0,nyrs-1 do begin &$
         nave[x,y,z] = MEAN(ndviY[x,y,(z*npers):((z+1)*npers)-1])&$
	       nmax[x,y,z] = MAX(ndviY[x,y,(z*npers):((z+1)*npers)-1])&$
      endfor&$
   endfor&$
endfor

; normalized NDVI
ndspi = FLTARR(SIZE(nmax,/DIMENSIONS))
for y=0,ghaY-1 do begin&$
   for x=0,ghaX-1 do begin&$
      if MEAN(nmax[x,y,*]) gt 0.0 then ndspi[x,y,*] = PRECIP_2_SPI_GH(nmax[x,y,*])&$
   endfor&$
endfor

; map the change in max NDVI over 2 periods
tmpdif = IMAGE(CONGRID((MEAN(nmax[*,*,17:31],DIMENSION=3) - MEAN(nmax[*,*,0:16],DIMENSION=3))/10000.,6*ghax,6*ghay), $
   RGB_TABLE=66,MAX_VALUE=0.1,MIN_VALUE=-0.1, $;LAYOUT=[2,1,1], $
   TITLE='GIMMS Max MAMJ NDVI !C 1999-2011 Mean Minus 1982-1998 Mean',FONT_SIZE=16, $
   MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
   IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry],/CURRENT)
ncolors = 10 & rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))
rgbdump = tmpdif.rgb_table & tmpdif.rgb_table = 67 & rgbdump2 = tmpdif.rgb_table & rgbdump[*,128:255] = rgbdump2[*,128:255]
tmpdif.rgb_table = CONGRID(rgbdump[*,rgbind],3,256)
tmpdif.mapgrid.linestyle = 6 & tmpdif.mapgrid.label_position = 0
tmpdif.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=tmpdif,ORIENTATION=1,/BORDER)

tmpdif = IMAGE(CONGRID(MEAN(ndspi[*,*,17:29],DIMENSION=3) - MEAN(ndspi[*,*,0:16],DIMENSION=3),6*ghax,6*ghay), $
   RGB_TABLE=66,MAX_VALUE=1.25,MIN_VALUE=-1.25, $
   TITLE='GIMMS Normalized Max MJJA NDVI !C 1999-2011 Mean Minus 1982-1998 Mean',FONT_SIZE=16, $
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
nskip = 5       ; skip the first n-years of the timeseries when calculating the trend
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
   TITLE=STRING(FORMAT='(''Trend in Max Mar-June NDVI '',I4.4,''-2011 (NDVI/year)'')',startyr+nskip),FONT_SIZE=16, $
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
   TITLE='Trend Correlation',FONT_SIZE=14, $
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
   TITLE=STRING(FORMAT='(''NDVI Trend '',I4.4,''-2011 (NDVI/year)'')',startyr+nskip),FONT_SIZE=16, $
   MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
   IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry],/CURRENT)
ncolors = 10 & rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))
rgbdump = scrtr.rgb_table & scrtr.rgb_table = CONGRID(rgbdump[*,rgbind],3,256)
scrtr.mapgrid.linestyle = 6 & scrtr.mapgrid.label_position = 0
scrtr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=scrtr,ORIENTATION=1,/BORDER)

;;; GET NDVI AND RAINFALL TO LINE UP AND DO SOME COMPARISONS
rn2nd = CONGRID(chirp[*,*,1:32],ghax,ghay,32)

;; get the trend and correlations
nskip = 15       ; skip the first n-years of the timeseries when calculating the trend
nrcor = FLTARR(ghax,ghay)
for y=0,ghay-1 do begin &$
   for x=0,ghax-1 do begin &$
      if MEAN(nave[x,y,*]) gt 0.0 AND MEAN(rn2nd[x,y,*]) gt 0.0 then begin &$
         nrcor[x,y] = CORRELATE(rn2nd[x,y,nskip:nyrs-1],nmax[x,y,nskip:nyrs-1]) &$
      endif &$
   endfor &$
endfor

tmpcr = IMAGE(CONGRID(nrcor,500,500),RGB_TABLE=73,MAX_VALUE=1.0,MIN_VALUE=-1.0, $
   TITLE=STRING(FORMAT='(''CHIRPS/NDVI Correlation '',I4.4,''-2013'')',startyr+nskip),FONT_SIZE=16,/ORDER, $
   MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
   IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry],/CURRENT)
ncolors = 11 & rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))
rgbdump = tmpcr.rgb_table & tmpcr.rgb_table = CONGRID(rgbdump[*,rgbind],3,256)
tmpcr.mapgrid.linestyle = 6 & tmpcr.mapgrid.label_position = 0
tmpcr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=tmpcr,ORIENTATION=1,/BORDER)




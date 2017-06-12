;; THIS WORKSHEET WILL EXPLORE SOME OF THE RAIN DATA FOR YEMEN


map_ulx = 42.	& map_lrx = 48.
map_uly = 18.	& map_lry = 12.

NX = (180.+map_lrx)*20. - (180.+map_ulx)*20.
NY = (50. +map_uly)*20. - (50. +map_lry)*20.

;;; RUN DATA FOR FCLIM
data_dir = '/home/FCLIM/2012.01.18/monthly/'
fnames = FILE_SEARCH(data_dir,'FCLIM_5050_wOceans.??.tif')
fnames = fnames[0:11]
NZ = N_ELEMENTS(fnames)

YemClim = FLTARR(NX,NY,NZ)

for i=0,N_ELEMENTS(fnames)-1 do begin &$
   tmp = READ_TIFF(fnames[i]) &$
   YemClim[*,*,i] = tmp[(180.+map_ulx)*20.:(180.+map_lrx)*20.-1,(50.+map_lry)*20.:(50.+map_uly)*20.-1] &$
endfor

map = MAP('Geographic',LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
map.erase

mo_name = ['January','February','March','April','May','June', $
           'July','August','September','October','November','December']
ncolors = 8
index = [0, 10, 20, 30, 50, 75, 100, 150, 200]
for i=0,NZ-1 do begin
tmpgr = CONTOUR(YemClim[*,*,i],FINDGEN(NX)/20. + map_ulx,FINDGEN(NY)/20. +map_lry, $
   RGB_TABLE=33,MAX_VALUE=MAX(index),MIN_VALUE=0, $
   /FILL, ASPECT_RATIO=1, C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./ncolors), $
   TITLE=mo_name[i]+' FCLIM Monthly Average',FONT_SIZE=16,/CURRENT, $
   MAP_PROJECTION='Geographic')
tmpgr.rgb_table = REVERSE(tmpgr.rgb_table,2)
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
tmpgr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],THICK=2,FILL_BACKGROUND=0, $
   LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
cb = colorbar(target=tmpgr,ORIENTATION=1,TAPER=3,/BORDER)
tmpgr.save,STRING(FORMAT='(''YemGraphs/FCLIM_mn.'',I2.2,''.png'')',i+1),RESOLUTION=150
;wait,3
tmpgr.erase
endfor

;; make one graphic with all the months
map = MAP('Geographic',LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
map.erase

for i=0,NZ-1 do begin
tmpgr = CONTOUR(YemClim[*,*,i],FINDGEN(NX)/20. + map_ulx,FINDGEN(NY)/20. +map_lry, $
   LAYOUT=[4,3,i+1],RGB_TABLE=33,MAX_VALUE=MAX(index),MIN_VALUE=0, $
   /FILL, ASPECT_RATIO=1, C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./ncolors), $
   TITLE=mo_name[i]+' FCLIM Monthly Average',FONT_SIZE=16,/CURRENT, $
   MAP_PROJECTION='Geographic')
tmpgr.rgb_table = REVERSE(tmpgr.rgb_table,2)
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
tmpgr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],THICK=2,FILL_BACKGROUND=0, $
   LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
endfor
cb = colorbar(target=tmpgr,POSITION=[0.49,0.4,0.51,0.6],FONT_SIZE=12,ORIENTATION=1,TAPER=3,/BORDER)
tmpgr.save,'YemGraphs/FCLIM_mn.all.png',RESOLUTION=100

;;; NOW FOR CHIRP DATA
startyr = 1981
endyr = 2013 
nyrs = endyr-startyr+1
startmo = 1
endmo = 12
nmos = endmo - startmo+1

chirp = FLTARR(NX,NY,nmos,nyrs)

data_dir = '/home/CHIRP/monthly/'

for yr=startyr,endyr do begin &$
   for i=0,nmos-1 do begin &$
      y = yr &$
      m = startmo + i  &$
      if m gt 12 then begin &$
         m = m-12 &$
         y = y+1 &$
      endif &$
      full_globe = READ_TIFF(data_dir+STRING(FORMAT='(''CHIRP.'',I4.4,''.'',I2.2,''.tif'')',y,m)) &$
      chirp[*,*,i,yr-startyr] = full_globe[(180.+map_ulx)*20.:(180.+map_lrx)*20.-1,(50.-map_uly)*20.:(50.-map_lry)*20.-1] &$
   endfor &$
endfor &$

;; map out the chirp monthly means
mo_name = ['January','February','March','April','May','June', $
   'July','August','September','October','November','December']
ncolors = 8
index = [0, 10, 20, 30, 50, 75, 100, 150, 200]
;for i=0,NZ-1 do begin
;tmpgr = CONTOUR(REVERSE(MEAN(chirp[*,*,i,*],DIMENSION=4),2),FINDGEN(NX)/20. + map_ulx,FINDGEN(NY)/20. +map_lry, $
;   RGB_TABLE=33,MAX_VALUE=MAX(index),MIN_VALUE=0, $
;   /FILL, ASPECT_RATIO=1, C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./ncolors), $
;   TITLE=mo_name[i]+' CHIRP Monthly Average',FONT_SIZE=16,/CURRENT, $
;   MAP_PROJECTION='Geographic')
;tmpgr.rgb_table = REVERSE(tmpgr.rgb_table,2)
;tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
;tmpgr.mapgrid.FONT_SIZE = 10
;m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],THICK=2,FILL_BACKGROUND=0, $
;   LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
;cb = colorbar(target=tmpgr,ORIENTATION=1,TAPER=3,/BORDER)
;tmpgr.save,STRING(FORMAT='(''YemGraphs/CHIRP_mn.'',I2.2,''.png'')',i+1),RESOLUTION=150
;;wait,3
;tmpgr.erase
;endfor

; make one graphic for all the months
for i=0,NZ-1 do begin &$
tmpgr = CONTOUR(REVERSE(MEAN(chirp[*,*,i,*],DIMENSION=4),2),FINDGEN(NX)/20. + map_ulx,FINDGEN(NY)/20. +map_lry, $
   LAYOUT=[4,3,i+1],RGB_TABLE=33,MAX_VALUE=MAX(index),MIN_VALUE=0, $
   /FILL, ASPECT_RATIO=1, C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./ncolors), $
   TITLE=mo_name[i]+' ',FONT_SIZE=16,/CURRENT, $
   MAP_PROJECTION='Geographic') &$
tmpgr.rgb_table = REVERSE(tmpgr.rgb_table,2) &$
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0 &$
tmpgr.mapgrid.FONT_SIZE = 0 &$
;m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],THICK=2,FILL_BACKGROUND=0, $
 ;  LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
endfor
cb = colorbar(target=tmpgr,POSITION=[0.49,0.4,0.51,0.6],FONT_SIZE=12,ORIENTATION=1,TAPER=3,/BORDER)
tmpgr.save,'YemGraphs/CHIRP_mn.all.png',RESOLUTION=100

;;; NOW FOR CHIRPS DATA
startyr = 1981
endyr = 2014
nyrs = endyr-startyr+1
startmo = 1
endmo = 12
nmos = endmo - startmo+1

chirps = FLTARR(NX,NY,nmos,nyrs)

data_dir = '/home/CHIRPS/monthly/v2.0/'

for yr=startyr,endyr do begin  &$
   for i=0,nmos-1 do begin &$
      y = yr &$
      m = startmo + i &$
      if m gt 12 then begin &$
         m = m-12 &$
         y = y+1 &$
      endif &$
;update this...
      full_globe = READ_TIFF(data_dir+STRING(FORMAT='(''chirps-v2.0.'',I4.4,''.'',I2.2,''.tif'')',y,m)) &$
      chirps[*,*,i,yr-startyr] = full_globe[(180.+map_ulx)*20.:(180.+map_lrx)*20.-1,(50.-map_uly)*20.:(50.-map_lry)*20.-1] &$
   endfor &$
endfor

;; map out the chirps monthly means
mo_name = ['January','February','March','April','May','June', $
   'July','August','September','October','November','December']
ncolors = 8
index = [0, 10, 20, 30, 50, 75, 100, 150, 200]
;for i=0,NZ-1 do begin
;tmpgr = CONTOUR(REVERSE(MEAN(chirps[*,*,i,*],DIMENSION=4),2),FINDGEN(NX)/20. + map_ulx,FINDGEN(NY)/20. +map_lry, $
;   RGB_TABLE=33,MAX_VALUE=MAX(index),MIN_VALUE=0, $
;   /FILL, ASPECT_RATIO=1, C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./ncolors), $
;   TITLE=mo_name[i]+' CHIRPS Monthly Average',FONT_SIZE=16,/CURRENT, $
;   MAP_PROJECTION='Geographic')
;tmpgr.rgb_table = REVERSE(tmpgr.rgb_table,2)
;tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
;tmpgr.mapgrid.FONT_SIZE = 10
;m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],THICK=2,FILL_BACKGROUND=0, $
;   LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
;cb = colorbar(target=tmpgr,ORIENTATION=1,TAPER=3,/BORDER)
;tmpgr.save,STRING(FORMAT='(''YemGraphs/CHIRPS_mn.'',I2.2,''.png'')',i+1),RESOLUTION=150
;wait,3
;tmpgr.erase
;endfor

; make one graphic for all the months
for i=0,NZ-1 do begin  &$
tmpgr = CONTOUR(REVERSE(MEAN(chirps[*,*,i,*],DIMENSION=4),2),FINDGEN(NX)/20. + map_ulx,FINDGEN(NY)/20. +map_lry, $
   LAYOUT=[4,3,i+1],RGB_TABLE=33,MAX_VALUE=MAX(index),MIN_VALUE=0, $
   /FILL, ASPECT_RATIO=1, C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./ncolors), $
   TITLE=mo_name[i]+' ',FONT_SIZE=0,/CURRENT, $
   MAP_PROJECTION='Geographic')  &$
tmpgr.rgb_table = REVERSE(tmpgr.rgb_table,2) &$
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0 &$
tmpgr.mapgrid.FONT_SIZE = 0 &$
;m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],THICK=2,FILL_BACKGROUND=0, $
 ;  LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
endfor
cb = colorbar(target=tmpgr,POSITION=[0.49,0.4,0.51,0.6],FONT_SIZE=12,ORIENTATION=1,TAPER=3,/BORDER)
tmpgr.save,'YemGraphs/CHIRPS_mn.all.png',RESOLUTION=100

;;;MEANS ARE MAPPED LET'S LOOK AT STDDEVS (CHIRP AND CHIRPS ONLY)
ncolors = 8
index = [0, 2, 4, 7, 10, 15, 20, 25, 50]
for i=0,NZ-1 do begin
tmpgr = CONTOUR(REVERSE(STDDEV(chirps[*,*,i,*],DIMENSION=4),2),FINDGEN(NX)/20. + map_ulx,FINDGEN(NY)/20. +map_lry, $
   RGB_TABLE=52,MAX_VALUE=MAX(index),MIN_VALUE=0, $
   /FILL, ASPECT_RATIO=1, C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./ncolors), $
   TITLE=mo_name[i]+' CHIRPS Monthly StDev',FONT_SIZE=16,/CURRENT, $
   MAP_PROJECTION='Geographic')
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
tmpgr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],THICK=2,FILL_BACKGROUND=0, $
   LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
cb = colorbar(target=tmpgr,ORIENTATION=1,TAPER=3,/BORDER)
tmpgr.save,STRING(FORMAT='(''YemGraphs/CHIRPS_sd.'',I2.2,''.png'')',i+1),RESOLUTION=150
wait,3
tmpgr.erase
endfor

; make one graphic for all the months
for i=0,NZ-1 do begin
tmpgr = CONTOUR(REVERSE(STDDEV(chirps[*,*,i,*],DIMENSION=4),2),FINDGEN(NX)/20. + map_ulx,FINDGEN(NY)/20. +map_lry, $
   LAYOUT=[4,3,i+1],RGB_TABLE=52,MAX_VALUE=MAX(index),MIN_VALUE=0, $
   /FILL, ASPECT_RATIO=1, C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./ncolors), $
   TITLE=mo_name[i]+' CHIRPS Monthly StDev',FONT_SIZE=16,/CURRENT, $
   MAP_PROJECTION='Geographic')
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
tmpgr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],THICK=2,FILL_BACKGROUND=0, $
   LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
endfor
cb = colorbar(target=tmpgr,POSITION=[0.49,0.4,0.51,0.6],FONT_SIZE=12,ORIENTATION=1,TAPER=3,/BORDER)
tmpgr.save,'YemGraphs/CHIRPS_sd.all.png',RESOLUTION=100


;;;LETS LOOK AT THE TRENDS IN THE RAINS
month = 9	; month in absolute space [Jan=1, Feb=2...]
for month = 1,12 do begin &$
nskip = 3	 &$; skip the first n-years of the timeseries when calculating the trend
trendmap = FLTARR(NX,NY)  &$
trendcor = FLTARR(NX,NY) &$
for y=0,NY-1 do begin  &$
   for x=0,NX-1 do begin  &$
      if MEAN(chirps[x,y,*]) gt 0.0 then begin &$
         trendmap[x,y] = REGRESS(INDGEN(nyrs-nskip),REFORM(chirps[x,y,month-1,nskip:nyrs-1]),MCORRELATION=r) &$
         trendcor[x,y] = r &$
      endif &$
   endfor &$
endfor &$

ncolors = 14 &$
tmptr = IMAGE(CONGRID(trendmap,NX*3,NY*3)*10.,RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),MAX_VALUE=7.,MIN_VALUE=-7., $
   TITLE=STRING(mo_name[month-1]), $
   FONT_SIZE=16,/ORDER,layout=[4,3,month], /current, $
   MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
   IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry]) &$
tmptr.mapgrid.linestyle = 6 & tmptr.mapgrid.label_position = 0 &$
tmptr.mapgrid.FONT_SIZE = 0 &$
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0, $
   LIMIT=[map_lry, map_ulx, map_uly, map_lrx]) &$
   if month eq 12 then cb = colorbar(target=tmptr,ORIENTATION=1,/BORDER) &$
endfor
cb = colorbar(target=tmptr,ORIENTATION=0,/BORDER)


;;; MAKE A 2x2 PLOT OF KEY MONTHLY VARIABLES
month = 7	; month in absolute space [Jan=1, Feb=2...]
mo_name = ['January','February','March','April','May','June', $
   'July','August','September','October','November','December']

; mean
ncolors = 8
index = [0, 10, 20, 30, 50, 75, 100, 150, 200]
i=month-1
tmpgr = CONTOUR(REVERSE(MEAN(chirps[*,*,i,*],DIMENSION=4),2),FINDGEN(NX)/20. + map_ulx,FINDGEN(NY)/20. +map_lry, $
   LAYOUT=[2,2,1],RGB_TABLE=33,MAX_VALUE=MAX(index),MIN_VALUE=0, $
   /FILL, ASPECT_RATIO=1, C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./(ncolors-1)), $
   TITLE=mo_name[i]+' CHIRPS Monthly Average',FONT_SIZE=16,/CURRENT, $
   MAP_PROJECTION='Geographic')
tmpgr.rgb_table = REVERSE(tmpgr.rgb_table,2)
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
tmpgr.mapgrid.FONT_SIZE = 1
;m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],THICK=2,FILL_BACKGROUND=0, $
 ;  LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
cb = colorbar(target=tmpgr,ORIENTATION=1,TAPER=3,/BORDER)

; standard deviation
ncolors = 8
index = [0, 2, 4, 7, 10, 15, 20, 25, 50]
i=month-1
tmpgr = CONTOUR(REVERSE(STDDEV(chirps[*,*,i,*],DIMENSION=4),2),FINDGEN(NX)/20. + map_ulx,FINDGEN(NY)/20. +map_lry, $
   LAYOUT=[2,2,2],RGB_TABLE=52,MAX_VALUE=MAX(index),MIN_VALUE=0, $
   /FILL, ASPECT_RATIO=1, C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./(ncolors-1)), $
   TITLE=mo_name[i]+' CHIRPS Monthly StDev',FONT_SIZE=16,/CURRENT, $
   MAP_PROJECTION='Geographic')
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
tmpgr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],THICK=2,FILL_BACKGROUND=0, $
   LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
cb = colorbar(target=tmpgr,ORIENTATION=1,TAPER=3,/BORDER)

; trends in absolute magnitude
nskip = 3       ; skip the first n-years of the timeseries when calculating the trend
trendmap = FLTARR(NX,NY)  
trendcor = FLTARR(NX,NY) 
for y=0,NY-1 do begin  &$
   for x=0,NX-1 do begin &$
      if MEAN(chirps[x,y,*]) gt 0.0 then begin &$
         trendmap[x,y] = REGRESS(INDGEN(nyrs-nskip),REFORM(chirps[x,y,month-1,nskip:nyrs-1]),MCORRELATION=r) &$
         trendcor[x,y] = r &$
      endif &$
   endfor &$
endfor

ncolors = 9
index = [-40, -10, -7, -5, -2, 2, 5, 7, 10, 40]
tmptr = CONTOUR(REVERSE(trendmap*10.,2),FINDGEN(NX)/20. + map_ulx,FINDGEN(NY)/20. +map_lry, $
   LAYOUT=[2,2,3], RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),MAX_VALUE=MAX(index),MIN_VALUE=MIN(index), $
   /FILL, ASPECT_RATIO=1, C_VALUE=index, RGB_INDICES=ROUND(FINDGEN(ncolors)*255./(ncolors-1)), $
   TITLE=STRING(FORMAT='(''CHIRPS '',A,'' Trend '',I4.4,''-2013 (mm/decade)'')',mo_name[month-1],startyr+nskip), $
   FONT_SIZE=16,/CURRENT,MAP_PROJECTION='Geographic')
tmptr.mapgrid.linestyle = 6 & tmptr.mapgrid.label_position = 0
tmptr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],THICK=2,FILL_BACKGROUND=0, $
   LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
cb = colorbar(target=tmptr,ORIENTATION=1,TAPER=3,/BORDER)

; trends in standard dev space
ncolors = 9
index = [-4, -1, -0.75, -0.5, -0.25, 0.25, 0.5, 0.75, 1., 40]
tmptr = CONTOUR(REVERSE(trendmap*10./STDDEV(chirps[*,*,i,*],DIMENSION=4),2), $
   FINDGEN(NX)/20. + map_ulx,FINDGEN(NY)/20. +map_lry, $
   LAYOUT=[2,2,4], RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),MAX_VALUE=MAX(index),MIN_VALUE=MIN(index), $
   /FILL, ASPECT_RATIO=1, C_VALUE=index, RGB_INDICES=FLOOR(FINDGEN(ncolors)*255./(ncolors-1)), $
   TITLE=STRING(FORMAT='(''CHIRPS '',A,'' Trend '',I4.4,''-2013 (SPI/decade)'')',mo_name[month-1],startyr+nskip), $
   FONT_SIZE=16,/CURRENT,MAP_PROJECTION='Geographic')
tmptr.mapgrid.linestyle = 6 & tmptr.mapgrid.label_position = 0
tmptr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],THICK=2,FILL_BACKGROUND=0, $
   LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
cb = colorbar(target=tmptr,ORIENTATION=1,TAPER=3,/BORDER)

tmptr.save,STRING(FORMAT='(''YemGraphs/CHIRPS_all.'',I2.2,''.png'')',month),RESOLUTION=100


;;; LOOK AT THE UPDATED FCLIM PRODUCED BY A.VERDIN 
map_ulx = 42.   & map_lrx = 54.
map_uly = 22.   & map_lry = 12.5

NX = (180.+map_lrx)*20. - (180.+map_ulx)*20.
NY = (50. +map_uly)*20. - (50. +map_lry)*20.

;;; RUN DATA FOR FCLIM
data_dir = '/home/sandbox/people/husak/YemGraphs/'
fnames = FILE_SEARCH(data_dir,'??-Yemen.tif')
fnames = fnames[0:11]
NZ = N_ELEMENTS(fnames)

NewClim = FLTARR(NX,NY,NZ)

for i=0,N_ELEMENTS(fnames)-1 do begin  &$
   tmp = READ_TIFF(fnames[i]) &$
   NewClim[*,*,i] = tmp &$
endfor

map = MAP('Geographic',LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
map.erase

mo_name = ['January','February','March','April','May','June', $
   'July','August','September','October','November','December']
ncolors = 8
index = [0, 10, 20, 30, 50, 75, 100, 150, 200]
;for i=0,NZ-1 do begin  &$
;tmpgr = CONTOUR(REVERSE(NewClim[*,*,i],2),FINDGEN(NX)/20. + map_ulx,FINDGEN(NY)/20. +map_lry, $
;   RGB_TABLE=33,MAX_VALUE=MAX(index),MIN_VALUE=0, $
;   /FILL, ASPECT_RATIO=1, C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./ncolors), $
;   TITLE=mo_name[i]+' FCLIM Monthly Average',FONT_SIZE=16, $
;   MAP_PROJECTION='Geographic') &$
;tmpgr.rgb_table = REVERSE(tmpgr.rgb_table,2) &$
;tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0  &$
;tmpgr.mapgrid.FONT_SIZE = 0  &$
;;m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],THICK=2,FILL_BACKGROUND=0, $
; ;  LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
;cb = colorbar(target=tmpgr,ORIENTATION=1,TAPER=3,/BORDER) &$
;;tmpgr.save,STRING(FORMAT='(''YemGraphs/NewClim_mn.'',I2.2,''.png'')',i+1),RESOLUTION=150
;;wait,3
;;tmpgr.erase
;endfor

;; make one graphic with all the months
map = MAP('Geographic',LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
map.erase

for i=0,NZ-1 do begin  &$
tmpgr = CONTOUR(REVERSE(NewClim[*,*,i],2),FINDGEN(NX)/20. + map_ulx,FINDGEN(NY)/20. +map_lry, $
   LAYOUT=[4,3,i+1],RGB_TABLE=33,MAX_VALUE=MAX(index),MIN_VALUE=0, $
   /FILL, ASPECT_RATIO=1, C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./ncolors), $
   TITLE=mo_name[i]+' FCLIM Monthly Average',FONT_SIZE=16,/CURRENT, $
   MAP_PROJECTION='Geographic') &$
tmpgr.rgb_table = REVERSE(tmpgr.rgb_table,2) &$
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0 &$
tmpgr.mapgrid.FONT_SIZE = 0 &$
;m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],THICK=2,FILL_BACKGROUND=0, $
;   LIMIT=[map_lry, map_ulx, map_uly, map_lrx]) &$
endfor
cb = colorbar(target=tmpgr,POSITION=[0.49,0.4,0.51,0.6],FONT_SIZE=12,ORIENTATION=1,TAPER=3,/BORDER)
tmpgr.save,'YemGraphs/FCLIM_mn.all.png',RESOLUTION=100

;; THIS Section WILL EXPLORE SOME OF THE RAIN DATA FOR Greater Horn


map_ulx = 30.   & map_lrx = 55.
map_uly = 25.   & map_lry = -10.

NX = (180.+map_lrx)*20. - (180.+map_ulx)*20.
NY = (50. +map_uly)*20. - (50. +map_lry)*20.

;;; RUN DATA FOR FCLIM
data_dir = '/home/FCLIM/2012.01.18/monthly/'
fnames = FILE_SEARCH(data_dir,'FCLIM_5050_wOceans.??.tif')
fnames = fnames[0:11]
NZ = N_ELEMENTS(fnames)

YemClim = FLTARR(NX,NY,NZ)

for i=0,N_ELEMENTS(fnames)-1 do begin
   tmp = READ_TIFF(fnames[i])
   YemClim[*,*,i] = tmp[(180.+map_ulx)*20.:(180.+map_lrx)*20.-1,(50.+map_lry)*20.:(50.+map_uly)*20.-1]
endfor

map = MAP('Geographic',LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
map.erase

mo_name = ['January','February','March','April','May','June', $
   'July','August','September','October','November','December']
ncolors = 9
index = [0, 5, 10, 20, 30, 50, 75, 100, 150, 300]
for i=0,NZ-1 do begin
tmpgr = CONTOUR(YemClim[*,*,i],FINDGEN(NX)/20. + map_ulx,FINDGEN(NY)/20. +map_lry, $
   RGB_TABLE=33,MAX_VALUE=MAX(index),MIN_VALUE=0, $
   /FILL, ASPECT_RATIO=1, C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./ncolors), $
   TITLE=mo_name[i]+' FCLIM Monthly Average',FONT_SIZE=16,/CURRENT, $
   MAP_PROJECTION='Geographic')
tmpgr.rgb_table = REVERSE(tmpgr.rgb_table,2)
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
tmpgr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],THICK=1,FILL_BACKGROUND=0, $
   LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
cb = colorbar(target=tmpgr,ORIENTATION=1,TAPER=3,/BORDER)
wait,3
tmpgr.erase
endfor

;; make one graphic with all the months
map = MAP('Geographic',LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
map.erase

for i=0,NZ-1 do begin
tmpgr = CONTOUR(YemClim[*,*,i],FINDGEN(NX)/20. + map_ulx,FINDGEN(NY)/20. +map_lry, $
   LAYOUT=[4,3,i+1],RGB_TABLE=33,MAX_VALUE=MAX(index),MIN_VALUE=0, $
   /FILL, ASPECT_RATIO=1, C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./ncolors), $
   TITLE=mo_name[i]+' FCLIM',FONT_SIZE=16,/CURRENT, $
   MAP_PROJECTION='Geographic')
tmpgr.rgb_table = REVERSE(tmpgr.rgb_table,2)
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
tmpgr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],THICK=1,FILL_BACKGROUND=0, $
   LIMIT=[map_lry, map_ulx, map_uly, map_lrx])
endfor
cb = colorbar(target=tmpgr,POSITION=[0.49,0.4,0.51,0.6],FONT_SIZE=12,ORIENTATION=1,TAPER=3,/BORDER)


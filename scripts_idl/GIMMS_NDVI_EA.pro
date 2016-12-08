
;; 7/21 AM looking at the code, added &$ to for loops, note start and end months.
;; re-ran the code with updated CHIRPS, and looking at the Noah-EA domain too...
;; 3/21/15 trying with new GIMMS data
;; 11/20/15 revist to get to the bottom of some of these trends.
;; 12/21/15 back for minor revisions
;; 11/15/16 moved the GIMMS NDVI to discover, incase we want to update the code.
;*********
startyr = 1982
endyr = 2013
nyrs = endyr-startyr+1


;;;;;;;;;;;; AND THIS IS THE NDVI SECTION;;;;;;;;;;;;
afrNX = 900
afrNY = 960

;East Africa WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

ulx = (180.+map_ulx)*12.  & lrx = (180.+map_lrx)*12.-1
uly = (50.-map_uly)*12.   & lry = (50.-map_lry)*12.-1
NX = lrx - ulx + 1
NY = lry - uly + 1

;ulx = (map_ulx + 20.) *12.
;lrx = (map_lrx + 20.) *12. -1
;uly = (40. - map_lry) *12. -1
;lry = (40. - map_uly) *12.
;ghax = lrx - ulx +1   & ghay = uly - lry +1

molist = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec']
startmo = 1
endmo = 12
nmos = endmo - startmo+1
npers = (endmo - startmo +1) *2

;data_dir = '/home/sandbox/people/mcnally/'
data_dir = '/discover/nobackup/almcnall/LIS7runs/'

;read in and sub/superset the data
fileID = ncdf_open(data_dir+'/GIMMS-3g_EastAfrica_AM.nc') &$
ndviID = ncdf_varid(fileID,'NDVI3g') &$
ncdf_varget,fileID,ndviID, GIMMS
GIMMS = reverse(GIMMS,2)
;remove 1981 Jul-Dec 6mo*2 = 12
GIMMS = GIMMS[*,*,12:779]

left = fltarr((28-22)*12,382,nyrs*24)*!values.f_nan ;add 72 pixels
top = fltarr(353,(22.95-20)*12,nyrs*24)*!values.f_nan ;add 35

a = [left, gimms]
b = [ [a],[top] ]
NX = 117
NY = 139
;this is the full data record.
gimms25 = congrid(b,NX,NY,nyrs*24)


;use this loop if you don't want all mo in yr
;initialize the ndvi var
ndvi = gimms25[*,*,(startmo-1)*2:(endmo*2)-1]
for i=1,nyrs-1 do begin &$
  ;just getting the months of interest
  ndvi = [[[ndvi]],[[gimms25[*,*,(i*24)+(startmo-1)*2:(i*24)+(endmo*2)-1]]]] &$
  print, i &$
endfor
delvar,gimms25

;i want to look at the max/avg for each month for the ECV paper.
ndvicube = reform(ndvi,NX,NY,2,12,nyrs)
ndvicube2 = max(ndvicube,dimension=3)
;ndvicube2 = mean(ndvicube,dimension=3)

;; data is read in, subset for horn and given months, now look at max composite, and mean
nave = FLTARR(NX,NY,nyrs)
nmax = INTARR(NX,NY,nyrs)
for x=0,nx-1 do begin &$
   for y=0,ny-1 do begin &$
      for z=0,nyrs-1 do begin &$
         nave[x,y,z] = MEAN(ndvi[x,y,(z*npers):((z+1)*npers)-1]) &$
	       nmax[x,y,z] = MAX(ndvi[x,y,(z*npers):((z+1)*npers)-1]) &$
      endfor &$
   endfor &$
endfor

;; normalized NDVI.How does the SPI code do this?
ndspi = FLTARR(SIZE(nmax,/DIMENSIONS))
for y=0,NY-1 do begin &$
   for x=0,NX-1 do begin &$
      if MEAN(nmax[x,y,*]) gt 0.0 then ndspi[x,y,*] = PRECIP_2_SPI_GH(nmax[x,y,*]) &$
   endfor &$
endfor
nmax = reverse(nmax,2)
ndspi = reverse(ndspi,2)

ofile1 = '/home/sandbox/people/mcnally/NDSPI_MAM.tif'
ofile2 = '/home/sandbox/people/mcnally/NDSPI_JAS.tif'
ofile3 = '/home/sandbox/people/mcnally/NDSPI_OND.tif'
;
write_tiff, ofile1, ndspi, /float
write_tiff, ofile2, ndspi, /float
write_tiff, ofile3, ndspi, /float


nskip = (1992-1982)+1      ; skip the first n-years of the timeseries when calculating the trend
; map the change in max NDVI over 2 periods
tmpdif = IMAGE(CONGRID(ndspi[*,*,nskip-1],6*NX,6*NY), $
  RGB_TABLE=66,MAX_VALUE=4,MIN_VALUE=-4, $;LAYOUT=[2,1,1], $
  TITLE='GIMMS NDVI Z-score 1992',FONT_SIZE=16,/ORDER, $
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
trendmap = FLTARR(NX,NY)
trendcor = FLTARR(NX,NY)
for y=0,NY-1 do begin &$
   for x=0,NX-1 do begin &$
      if MEAN(nave[x,y,*]) gt 0.0 then begin &$
         trendmap[x,y] = REGRESS(INDGEN(nyrs-nskip),REFORM(nmax[x,y,nskip:nyrs-1]),MCORRELATION=r) &$
         trendcor[x,y] = r &$
      endif &$
   endfor &$
endfor

tmptr = IMAGE(CONGRID(trendmap/10000.,6*NX,6*NY),RGB_TABLE=66,MAX_VALUE=0.01,MIN_VALUE=-0.01, $;LAYOUT=[2,1,1], $
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

tmpcr = IMAGE(reverse(play,2),RGB_TABLE=8,MAX_VALUE=0.5,MIN_VALUE=0., LAYOUT=[2,1,2], $
   TITLE='Trend Correlation',FONT_SIZE=14,/ORDER, $
   MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], AXIS_STYLE=0, $
   IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry],/CURRENT)
ncolors = 10 & rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))
rgbdump = tmpcr.rgb_table & tmpcr.rgb_table = CONGRID(rgbdump[*,rgbind],3,256)
tmpcr.mapgrid.linestyle = 6 & tmpcr.mapgrid.label_position = 0
tmpcr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[250,250,250],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
;m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])

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

;;;;;;;;;additional maps to show change over time.
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

;;;;;;;calculate the rainfall percentiles for each year then look at the trends
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
per67 = fltarr(nx, ny)
per33 = fltarr(nx, ny)
for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
  ;skip nans
  test = where(finite(chirp[x,y,*]),count) &$
  if count eq -1 then continue &$

  ;look at one pixel time series at a time
  pix = chirp[x,y,*] &$
  ;this sorts the historic timeseries from smallest to largest
  index = sort(pix) &$
  sorted = pix(index) &$

  ;then find the index of the 67th percentile
  index50 = (n_elements(sorted)-1)*0.50 &$
  index67 = (n_elements(sorted)-1)*0.67 &$
  index33 = (n_elements(sorted)-1)*0.33 &$

  ;return the value
  per67[x,y] = sorted(index67) &$
  ;h67[x,y] = per67 &$

  ;per50 = sorted(index50) &$
  ;h50[x,y] = per50 &$

  per33[x,y] = sorted(index33) &$
  ;h33[x,y] = per33 &$

  ;****now count the number of ensemble members that are above/below****
  ;  wet1 = where(SM[x,y,*] ge per67, count1) &$
  ;  dry1 = where(SM[x,y,*] le per33, dcount1) &$
  ;  prob67_1[x,y] = float(count1)/33. &$
  ;  prob33_1[x,y] = float(dcount1)/33. &$

endfor  &$;x
endfor;y


;;make percentile...this is a more simple version of what is below...
;using SM the stack of 1981-2013 soil moisture.
pc = fltarr(nx,ny,nyrs)
;sm(where(sm lt -999.))=!values.f_nan

;there is something not right about this....
for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
  ;skip nans
  test = where(finite(chirp[x,y,*]),count) &$
  ;print, count &$
  if count eq 0 then continue &$

  ;in 2011 (or any year)
  for i = 0, nyrs-1 do begin &$
  if chirp[x,y,i] lt per33[x,y] then PC[x,y,i] = 25 &$
  if chirp[x,y,i] lt per67[x,y] AND chirp[x,y,i] gt per33[x,y] then PC[x,y,i] = 50 &$
  if chirp[x,y,i] gt per67[x,y] then PC[x,y,i] = 75 &$
endfor &$
endfor &$
endfor

pc = reverse(pc,2)
chirps_pc = pc
;;;plot it...how do these compare to rainfall percentiles? and other combo of months? how does this compare to GDAS?
;;; having a suite of different months would be more like what they do for the hazards call, and more like what bala does
ncolors=3
for yyyy = 1981,2013 do begin &$
  yyyy = 2009
yr = 33-(2013-yyyy)-1 &$
  p1 = image(chirps_pc[*,*,yr], image_dimensions=[nx/10,ny/10],image_location=[map_ulx+0.25,map_lry+0.5], $
  RGB_TABLE=72,MIN_VALUE=0,max_value=100)  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.title = string(yyyy)+' MAM rainfall Percentiles' &$
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
  POSITION=[0.3,0.04,0.7,0.07], font_size=24, tickvalues=[25,50,75]) &$
  m1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  m1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0, 0, 0], THICK = 2) &$
  ;p1.save,strcompress('/home/sandbox/people/mcnally/jpg4gary_Aug14/'+p1.title.string+'.jpg', /remove_all),RESOLUTION=200 &$
endfor

;Yemen Highland window
hmap_ulx = 43. & hmap_lrx = 45.
hmap_uly = 17. & hmap_lry = 12.5

hulx = (hmap_ulx-22)*10.  & hlrx = (hmap_lrx-22)*10.-1
huly = (11.75+hmap_uly)*10.   & hlry = (11.75+hmap_lry)*10.-1

hNX = hlrx - hulx + 1.5
hNY = hlry - huly + 2
tmpplt=plot(mean(mean(PC[hulx:hlrx,hlry:huly,*], dimension=1,/nan),dimension=1,/nan), thick=3, xrange=[0,32])
xticks = indgen(33)+1981 & print, xticks
tmpplt.xTICKNAME = string(xticks)
tmpplt.xminor = 0
tmpplt.yminor = 0
tmpplt.xtickinterval = 2





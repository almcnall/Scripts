;; THIS WORKSHEET IS DESIGNED TO DEVELOP DATA AND GRAPHICS TO SUPPORT THE
;; MANUSCRIPT SUBMISSION TO GLOBAL ENVIRONMENTAL CHANGE

;; 7/21 AM looking at the code, added &$ to for loops, note start and end months.
;; re-ran the code with updated CHIRPS, and looking at the Noah-EA domain too...
;; I don't totally trust this CHIRPS versioning 0 - probably best to agregate to month from the .nc file.
;; 7/31 revisiting. Mostly just need to make similar plots.
;; 8/5 using making the same plots with the LIS7 output
;; 9/8 revisit for MERRA runs, now plotting rainfall, soil moisture and ndvi timeseries for yemen
;; 9/10 standardized anomalies, correlations and trends
;; 9/28 getting organized for ICBA meeting, there might be an extra dry bias in the 6hrly CHIRPS
;; 10/7/14 this script now compares ARC and CHIRPS seasonal totals
;*********
startyr = 1992
endyr = 2013
nyrs = endyr-startyr+1

;for east africa use 3-6 for yemen use 3-9
startmo = 1
endmo = 12
nmos = endmo - startmo+1

;mask by ROIs
;ifile = file_search('/home/sandbox/people/mcnally/yemen_shp/YM_agzone_294x384')
ifile = file_search('/home/sandbox/people/mcnally/yemen_shp/YM_agzone_300x320')
nx = 300
ny = 320

agzn = bytarr(nx,ny)
openr,1,ifile
readu,1,agzn
close,1
agzn = reverse(agzn,2)

;1=arabian sea
;2=desert
;3=highlands
;4=temperate highlands
;5=internal plateau
;6=redsea
;subset the areas in the red& highx2
mask = fltarr(nx,ny)
good = where(agzn eq 3 OR agzn eq 4 OR agzn eq 6, complement=other)
mask(good)=1
mask(other)=!values.f_nan
mask = rebin(mask,nx,ny,nyrs)
;;;;;chirps output from LIS (Rainf_f_inst (different from totprecip not sure why)


;East Africa WRSI/Noah window
;map_ulx = 22.  & map_lrx = 51.35
;map_uly = 22.95  & map_lry = -11.75
;
;ulx = (180.+map_ulx)*10.  & lrx = (180.+map_lrx)*10.-1
;uly = (50.-map_uly)*10.   & lry = (50.-map_lry)*10.-1
;NX = lrx - ulx + 1.5
;NY = lry - uly + 2

;RFE2 0.25 degree window
map_ulx = -20.  & map_lrx = 55.
map_uly = 40  & map_lry = -40

ulx = (180.+map_ulx)*4.  & lrx = (180.+map_lrx)*4.-1
uly = (50.-map_uly)*4.   & lry = (50.-map_lry)*4.-1
NX = lrx - ulx + 1
NY = lry - uly + 1

;Yemen Highland window
hmap_ulx = 43. & hmap_lrx = 45.
hmap_uly = 17. & hmap_lry = 12.5

;broader yemen window
hmap_ulx = 42.5 & hmap_lrx = 48.
hmap_uly = 17.5 & hmap_lry = 12.5

;hulx = (hmap_ulx-22)*10.  & hlrx = (hmap_lrx-22)*10.-1
;huly = (11.75+hmap_uly)*10.   & hlry = (11.75+hmap_lry)*10.-1

hulx = (hmap_ulx-map_ulx)*4.  & hlrx = (hmap_lrx-map_ulx)*4.-1
huly = (hmap_uly-map_lry)*4.   & hlry = (hmap_lry-map_lry)*4.-1

;yemen box 20.5 x 48
hNX = hlrx - hulx + 1.5
hNY = huly -hlry + 2

;6-hrly chirps have an extra low bias for these low the day2month agregates
;data_dir = '/home/sandbox/people/mcnally/NOAH_CHIRP_MERRA/CHIRPS_YRMO/'
data_dir = '/home/sandbox/people/mcnally/CHIRPS_eval/';chirps_mon_* 201012.bil
NX = 300
NY = 320

chirp = FLTARR(NX,NY,nyrs)
arc2 = FLTARR(NX,NY,nyrs)
RAIN = fltarr(300,320)
RAIN2 = fltarr(300,320)

;this loop reads in the selected months only
for yr=startyr,endyr do begin &$
   for i=0,nmos-1 do begin &$
      y = yr &$
      m = startmo + i &$
      if m gt 12 then begin &$
         m = m-12 &$
         y = y+1 &$
      endif &$
      ;for the netcdf chirps
      ;fileID = ncdf_open(data_dir+STRING(FORMAT='(''CHIRPS_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
      ;RainID = ncdf_varid(fileID,'Rainf_f_inst') &$
      ;ncdf_varget,fileID, RainID, RAIN &$
      
      ifile = file_search(data_dir+STRING(FORMAT='(''chirps_mon_'',I4.4,I2.2,''.bil'')',y,m)) &$
      openr,1,ifile &$
      readu,1, RAIN &$
      close,1 &$
      
      ifile = file_search(data_dir+STRING(FORMAT='(''arc2_mon_'',I4.4,I2.2,''.bil'')',y,m)) &$
      openr,1,ifile &$
      readu,1, RAIN2 &$
      close,1 &$
      ;generates the seasonal total for months of interest
      ;chirp[*,*,yr-startyr] = chirp[*,*,yr-startyr] + RAIN*864000 &$  
      ;is this right? i guess it sums months m and then increments yr
      chirp[*,*,yr-startyr] = chirp[*,*,yr-startyr] + RAIN &$
      arc2[*,*,yr-startyr] = arc2[*,*,yr-startyr] + RAIN2 &$

   endfor &$
endfor
chirp(where(chirp lt 0)) = !values.f_nan
arc(where(arc lt 0)) = !values.f_nan

dims = size(RAIN, /dimensions)
NX = dims[0]
NY = dims[1]

;Africa mean annual rainfall figure
  ncolors=12
  p1 = image(congrid(mean(chirp, dimension=3, /NAN), NX*3, NY*3), image_dimensions=[nx/4,ny/4],image_location=[map_ulx,map_lry]) &$
  p2 = image(congrid(mean(mask, dimension=3, /NAN), NX*3, NY*3), image_dimensions=[nx/4,ny/4],image_location=[map_ulx,map_lry], /overplot, transparency=80) &$

  p1.RGB_TABLE=64  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.title = 'avg rainfall' &$
  ;p1.max_value=1200; GHA
  p1.max_value=300 ; yemen
  c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,font_size=18) &$
 ; m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot) &$
  m1 = MAP('Geographic',LIMIT = [hmap_lry,hmap_ulx,hmap_uly ,hmap_lrx], /overplot) &$

  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  m1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0, 0, 0], THICK = 2)
  

ym_avg8114 = mean(mean(chirp*mask, dimension=1,/nan),dimension=1,/nan)
m1 = mean(ym_avg8114)
m2 = stddev(ym_avg8114)

tmpplt=barplot(ym_avg8114-m1, thick=3, xrange=[0,29])
xticks = indgen(30)+1984 & print, xticks
tmpplt.xTICKNAME = string(xticks)
tmpplt.xminor = 1
tmpplt.yminor = 0
tmpplt.xtickinterval = 2
tmpplt.yrange = [-75,75]

ym_arc = mean(mean(arc2*mask, dimension=1,/nan),dimension=1,/nan)
am1 = mean(ym_arc)
tmpplt=barplot(ym_arc-am1, thick=3, xrange=[0,29])
xticks = indgen(30)+1984 & print, xticks
tmpplt.xTICKNAME = string(xticks)
tmpplt.xminor = 1
tmpplt.yminor = 0
tmpplt.xtickinterval = 2
tmpplt.yrange = [-125,125]



;;;;;
; convert CHIRP to SPI
chspi = FLTARR(SIZE(chirp,/DIMENSIONS))
for y=0,NY-1 do begin &$
  for x=0,NX-1 do begin &$
  if MEAN(CHIRP[x,y,*]) gt 0.0 then chspi[x,y,*] = PRECIP_2_SPI_GH(chirp[x,y,*]) &$
endfor &$
endfor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;now for the soil moisture
startyr = 1981
endyr = 2013
nyrs = endyr-startyr+1

;March-June is fine for EA but should use March-Sept for Yemen.
startmo = 3
endmo = 9
nmos = endmo - startmo+1

;East Africa WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

ulx = (180.+map_ulx)*10.  & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10.   & lry = (50.-map_lry)*10.-1
NX = lrx - ulx + 1.5
NY = lry - uly + 2

;Yemen window
;ymap_ulx = 42. & ymap_lrx = 48.
;ymap_uly = 18. & ymap_lry = 12.

;broader Yemen window
ymap_ulx = 42.5 & ymap_lrx = 48.
ymap_uly = 17.5 & ymap_lry = 12.5

yulx = (180.+ymap_ulx)*10.  & ylrx = (180.+ymap_lrx)*10.-1
yuly = (50.-ymap_uly)*10.   & ylry = (50.-ymap_lry)*10.-1
yNX = ylrx - yulx + 1.5
yNY = ylry - yuly + 2

;data_dir = '/home/sandbox/people/mcnally/NOAH_CHIRP_GDAS/SM01_YRMO/'
;data_dir = '/home/sandbox/people/mcnally/NOAH_CHIRP_GDAS/SM02_YRMO/'
data_dir = '/home/sandbox/people/mcnally/NOAH_CHIRP_MERRA/SM01_YRMO/'


SM = FLTARR(NX,NY,nyrs)
;this loop reads in the selected months only
for yr=startyr,endyr do begin &$
  for i=0,nmos-1 do begin &$
  y = yr &$
  m = startmo + i &$
  if m gt 12 then begin &$
    m = m-12 &$
    y = y+1 &$
  endif &$
  fileID = ncdf_open(data_dir+STRING(FORMAT='(''SM01_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
  SoilID = ncdf_varid(fileID,'SoilMoist_tavg') &$
  ncdf_varget,fileID, SoilID, SM01 &$
;generates the seasonal total for months of interest it is a percent...
  SM[*,*,yr-startyr] = SM01 &$
  endfor &$
endfor
sm(where(sm lt 0)) = !values.f_nan
dims = size(SM01, /dimensions)

NX = dims[0]
NY = dims[1]

;GDASSM = SM
MERRSM = SM

cormap = fltarr(nx,ny)
for x = 0,NX-1 do begin &$
  for y =0, NY-1 do begin &$
  cormap[x,y] = correlate(gdassm[x,y,*], merrsm[x,y,*]) &$
  endfor &$
endfor

;ofile = '/home/sandbox/people/mcnally/yemen_Oct14/GDAS_MERR_SM01_CORRmap_294x348.img'
;openw,1,ofile
;writeu,1,cormap
;close,1
;1. Mean spring-summer rainfall total YEMEN (1981-2013)

;Yemen Highland window
hmap_ulx = 42.5 & hmap_lrx = 48.
hmap_uly = 17.5 & hmap_lry = 12.5

hulx = (hmap_ulx-22)*10.  & hlrx = (hmap_lrx-22)*10.-1
huly = (11.75+hmap_uly)*10.   & hlry = (11.75+hmap_lry)*10.-1

hNX = hlrx - hulx + 1.5
hNY = hlry - huly + 2

;Africa mean annual SM figure
ncolors=6
;p1 = image(congrid(mean(SM, dimension=3, /NAN), NX*3, NY*3), image_dimensions=[nx/10,ny/10],image_location=[map_ulx+0.25,map_lry+0.5],RGB_TABLE=64)  &$
p1 = image(congrid(cormap, NX*3, NY*3), image_dimensions=[nx/10,ny/10],image_location=[map_ulx+0.25,map_lry+0.5],RGB_TABLE=64)  &$
  p2 = image(congrid(agzn, NX*3, NY*3), image_dimensions=[nx/10,ny/10],image_location=[map_ulx+0.25,map_lry+0.5],RGB_TABLE=64, /overplot, transparency=50, max_value=6) 

  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.title = 'merra+chirps 2001-2013 mar-sept sm01' &$
  p1.max_value=1
  p1.min_value=0.4
c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,font_size=18) &$
  ;m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot) &$
  m1 = MAP('Geographic',LIMIT = [hmap_lry,hmap_ulx,hmap_uly ,hmap_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  m1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0, 0, 0], THICK = 2)
;all of thse figures would benefit from the ag boundaries...

;mask by ROIs
ifile = file_search('/home/sandbox/people/mcnally/yemen_shp/YM_agzone_294x384')
agzn = bytarr(nx,ny)
openr,1,ifile
readu,1,agzn
close,1
agzn = reverse(agzn,2)

;1=arabian sea
;2=desert
;3=highlands
;4=temperate highlands
;5=internal plateau
;6=redsea
;subset the areas in the red& highx2
mask = fltarr(nx,ny)
good = where(agzn eq 3 OR agzn eq 4 OR agzn eq 6, complement=other)
mask(good)=1
mask(other)=!values.f_nan
mask = rebin(mask,nx,ny,33)

;kinda silly to do with on the rainfall output that look funny.
;merraTS = sm*mask & help, merraTS
;chirpTS = chirp*mask & help, chirpTS
;
;tmpplt=plot(mean(mean(merraTS, dimension=1,/nan),dimension=1,/nan)*100, thick=3, xrange=[0,32])
;tmpplt=plot(mean(mean(chirpTS, dimension=1,/nan),dimension=1,/nan)/20+12, thick=3, xrange=[0,32], linestyle=2, /overplot,'c')
;
;xticks = indgen(33)+1981 & print, xticks
;tmpplt.xTICKNAME = string(xticks)
;tmpplt.xminor = 2
;tmpplt.xtickinterval = 3
;
;;ymsm_avg8114 = mean(mean(chirpTS, dimension=1,/nan),dimension=1,/nan)
;ymsm_avg8114 = mean(mean(merraTS, dimension=1,/nan),dimension=1,/nan)
;smm1 = mean(ymsm_avg8114)
;smm2 = stddev(ymsm_avg8114)
;
;tmpplt=barplot((ymsm_avg8114-smm1)/smm2, thick=3, xrange=[0,32])
;xticks = indgen(33)+1981 & print, xticks
;tmpplt.xTICKNAME = string(xticks)
;tmpplt.xminor = 2
;tmpplt.yminor = 0
;tmpplt.xtickinterval = 3
;tmpplt.yrange = [-2.5,2.5]
;tmpplt.font_size = 16

;;;;;;;calculate the soil moisture percentile
;1. MAM in 2011
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
per67 = fltarr(nx, ny)
per33 = fltarr(nx, ny)
for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
  ;skip nans
  test = where(finite(SM[x,y,*]),count) &$
  if count eq -1 then continue &$

  ;look at one pixel time series at a time
  pix = SM[x,y,*] &$
  ;this sorts the historic timeseries from smallest to largest
  index = sort(pix) &$
  sorted = pix(index) &$
  
  ;then find the index of the 67th percentile
  index50 = (n_elements(sorted)-1)*0.50 &$
  index67 = (n_elements(sorted)-1)*0.67 &$
  index33 = (n_elements(sorted)-1)*0.33 &$
  ;return the value
  per67[x,y] = sorted(index67) &$
  per33[x,y] = sorted(index33) &$
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
  test = where(finite(SM[x,y,*]),count) &$
  if count eq 0 then continue &$
  ;map the percentiles for each year
  for i = 0, nyrs-1 do begin &$
    if SM[x,y,i] lt per33[x,y] then PC[x,y,i] = 25 &$
    if SM[x,y,i] lt per67[x,y] AND SM[x,y,i] gt per33[x,y] then PC[x,y,i] = 50 &$
    if SM[x,y,i] gt per67[x,y] then PC[x,y,i] = 75 &$
  endfor &$
endfor &$
endfor

;;;plot it...how do these compare to rainfall percentiles? and other combo of months? how does this compare to GDAS?
;;; having a suite of different months would be more like what they do for the hazards call, and more like what bala does
ncolors=3
for yyyy = 1981,2013 do begin &$
  yyyy = 1981
  yr = 33-(2013-yyyy)-1 &$
  p1 = image(pc[*,*,yr], image_dimensions=[nx/10,ny/10],image_location=[map_ulx+0.25,map_lry+0.5], $
  RGB_TABLE=72,MIN_VALUE=0,max_value=100)  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.title = string(yyyy)+' MAM SM Percentiles' &$
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
  POSITION=[0.3,0.04,0.7,0.07], font_size=24, tickvalues=[25,50,75]) &$
  m1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  m1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0, 0, 0], THICK = 2) &$
  p1.save,strcompress('/home/sandbox/people/mcnally/jpg4gary_Aug14/'+p1.title.string+'.jpg', /remove_all),RESOLUTION=200 &$
endfor

;;;;;;;;;;;;;;;YEMEN;;;;;;;;;;;;;;;;;;;;;;;;;;
ncolors=3
for yyyy = 1981,2013 do begin &$
  ;yyyy = 1981
yr = 33-(2013-yyyy)-1 &$
  p1 = image(congrid(pc[*,*,yr], NX*3, NY*3), image_dimensions=[nx/10,ny/10],image_location=[map_ulx+0.25,map_lry+0.5], $
  RGB_TABLE=72,MIN_VALUE=0,max_value=100)  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.title = string(yyyy)+' MAM SM Percentiles' &$
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
  POSITION=[0.3,0.04,0.7,0.07], font_size=24, tickvalues=[25,50,75]) &$
  m1 = MAP('Geographic',LIMIT = [ymap_lry,ymap_ulx,ymap_uly ,ymap_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  m1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0, 0, 0], THICK = 2) &$
  p1.save,strcompress('/home/sandbox/people/mcnally/jpg4gary_Aug14/yemen_'+p1.title.string+'.jpg', /remove_all),RESOLUTION=200 &$
endfor

sm01_pc = pc
;make a timeseries plot of ROI in yemen.

;Yemen Highland window
hmap_ulx = 43. & hmap_lrx = 45.
hmap_uly = 17. & hmap_lry = 12.5

hulx = (hmap_ulx-22)*10.  & hlrx = (hmap_lrx-22)*10.-1
huly = (11.75+hmap_uly)*10.   & hlry = (11.75+hmap_lry)*10.-1

hNX = hlrx - hulx + 1.5
hNY = hlry - huly + 2

smym = mean(mean(sm01_PC[hulx:hlrx,hlry:huly,*], dimension=1,/nan),dimension=1,/nan)
prym = mean(mean(chirps_PC[hulx:hlrx,hlry:huly,*], dimension=1,/nan),dimension=1,/nan)
spiym = mean(mean(chspi[hulx:hlrx,hlry:huly,*], dimension=1,/nan),dimension=1,/nan)

print, correlate(smym,prym);0.56
print, correlate(smym,spiym);0.53
print, correlate(prym,spiym);0.96


p1 = plot(smym, thick=3, xrange=[0,32], /overplot, 'b', name = 'avg sm percentile')
p2 = plot(prym, thick=3, xrange=[0,32], linestyle=2,/overplot, name = 'avg pr percentile')
p3 = plot([0,ymn_avg8210]*20+40, thick=3, xrange=[0,32], linestyle=2,'c',/overplot, name = 'NDVI anom')


!null = legend(target=[p1,p2,p3], position=[0.2,0.3]) 
xticks = indgen(33)+1981 & print, xticks
tmpplt.xTICKNAME = string(xticks)
tmpplt.xminor = 0
tmpplt.xtickinterval = 3

tmpplt=plot(mean(mean(chspi[hulx:hlrx,hlry:huly,*], dimension=1,/nan),dimension=1,/nan)*20+40, thick=3, xrange=[0,32], /overplot)

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

ncolors = 14
tmptr = IMAGE(CONGRID(reverse(trendmap,2),4*NX,4*NY),RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), $
   TITLE=STRING(FORMAT='(''SM02 Mar-Sep Trend '',I4.4,''-2013 (mm/year)'')',startyr+nskip),FONT_SIZE=16,/ORDER,/CURRENT, $
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


;;;;;;;;;;;; AND THIS IS THE NDVI SECTION;;;;;;;;;;;;
afrNX = 900
afrNY = 960
afrNZ = 720
startyr = 1992
endyr = 2011
nyrs = endyr - startyr +1


;East Africa WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

;where was the map_ulx and lrx defined?
ulx = (map_ulx + 20.) *12.
lrx = (map_lrx + 20.) *12. -1
uly = (40. - map_lry) *12. -1
lry = (40. - map_uly) *12. 
ghax = lrx - ulx +1   & ghay = uly - lry +1

molist = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec']
startmo = 1
endmo = 12
npers = (endmo - startmo +1) *2

;I am not sure what time step the GIMMS is in/. weird. 
;where is the script that uses eMODIS?
;data_dir = '/home/jower/Data/LTDR_NDVI/GIMMS/regional_cubes/'
;data_dir = '/home/NDVI/GIMMS-3g_v_2015_RegionalCubes/'

tmpafr = INTARR(afrNX,afrNY,afrNZ)
close,1
openr,1,data_dir+'GIMMS3g_africa.img'
readu,1,tmpafr
close,1

;what is this doing?
tmpafr = tmpafr[ulx:lrx,lry:uly,*]

;;;;;;;regrid to match with LIS output;;;;;;;;
tmpafr = congrid(tmpafr,294,348,720)

seasonal = mean(reverse(reform(tmpafr,294,348,24,30),2),dimension=4,/nan)
yem = seasonal*mask

;East Africa WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

ulx = (180.+map_ulx)*10.  & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10.   & lry = (50.-map_lry)*10.-1
NX = lrx - ulx + 1.5
NY = lry - uly + 2
;;;;;;;;;;;;;;;
ndvi = tmpafr[*,*,(startmo-1)*2:(endmo*2)-1]
for i=1,nyrs-1 do begin &$
  ndvi = [[[ndvi]],[[tmpafr[*,*,(i*24)+(startmo-1)*2:(i*24)+(endmo*2)-1]]]] &$
  print, i &$
endfor
delvar,tmpafr

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

;map and timeseries for GHA and Yemen
;Yemen Highland window
hmap_ulx = 43. & hmap_lrx = 45.
hmap_uly = 17. & hmap_lry = 12.5

hulx = (hmap_ulx-22)*10.  & hlrx = (hmap_lrx-22)*10.-1
huly = (11.75+hmap_uly)*10.   & hlry = (11.75+hmap_lry)*10.-1

hNX = hlrx - hulx + 1.5
hNY = hlry - huly + 2

;plot normalizes anomalies for SM, CHIRPS, NDVI
flip_ndspi = reverse(ndspi,2)
ymn_avg8210 = mean(mean(flip_ndspi[hulx:hlrx,hlry:huly,*], dimension=1,/nan),dimension=1,/nan)

tmpplt=barplot(ymn_avg8210, thick=3, xrange=[0,29])
xticks = indgen(30)+1982 & print, xticks
tmpplt.xTICKNAME = string(xticks)
tmpplt.xminor = 0
tmpplt.yminor = 0
tmpplt.xtickinterval = 2
tmpplt.yrange = [-1.3,1.3]

;correlate
smym30 = mean(mean(sm01_PC[hulx:hlrx,hlry:huly,1:30], dimension=1,/nan),dimension=1,/nan)
prym30 = mean(mean(chirps_PC[hulx:hlrx,hlry:huly,1:30], dimension=1,/nan),dimension=1,/nan)
spiym30 = mean(mean(chspi[hulx:hlrx,hlry:huly,1:30], dimension=1,/nan),dimension=1,/nan)

print, correlate(smym30,prym30);0.57
print, correlate(smym30,ymn_avg8210);0.46
print, correlate(smym30,spiym30);0.53

print, correlate(prym30,ymn_avg8210);0.46
print, correlate(prym30,spiym30);0.97

print, correlate(spiym30,ymn_avg8210);0.46




;Africa mean annual NDVI figure
ncolors=16
p1 = image(congrid(mean(flip_nmax, dimension=3, /NAN), NX*3, NY*3), image_dimensions=[nx/10,ny/10],image_location=[map_ulx,map_lry], $
  RGB_TABLE=63)  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.title = 'avg NDVI mositure' &$
  p1.max_value=10000
p1.min_value=0
c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,font_size=18) &$
  m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot) &$
  ;m1 = MAP('Geographic',LIMIT = [hmap_lry,hmap_ulx,hmap_uly ,hmap_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  m1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0, 0, 0], THICK = 2)

;YEMEN mean annual SM figure
ncolors=16
p1 = image(congrid(mean(flip_nmax, dimension=3, /NAN), NX*3, NY*3), image_dimensions=[nx/10,ny/10],image_location=[map_ulx,map_lry], $
  RGB_TABLE=63)  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.title = 'avg Max NDVI' &$
  p1.max_value=10000
p1.min_value=0
c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,font_size=18) &$
  ;m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot) &$
  m1 = MAP('Geographic',LIMIT = [hmap_lry,hmap_ulx,hmap_uly ,hmap_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  m1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0, 0, 0], THICK = 2)


;; get the trend and correlations
nskip = 0       ; skip the first n-years of the timeseries when calculating the trend
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





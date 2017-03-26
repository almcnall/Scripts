pro CS2M2_vs_CG 

;plot some time series to show transition from Cs2M2 to CG runs
;ugh, is this what i am supposed to be doing right now?

;read in Jan16-Jan17 CHIRPS SM from 
help, nx, ny

;readin jan-feb CHIRP-GDAS estimates from first try (and second try) and the RFE2+GDAS runs (maybe I can just use them)
indir = '/discover/nobackup/projects/fame/MODEL_RUNS/EA_Noah33/ESPvanilla/Noah33_CG_ESPV_EA/Feb15/SURFACEMODEL/'
indir = '/discover/nobackup/projects/fame/MODEL_RUNS/EA_Noah33/ESPvanilla/Noah33_CG_ESPV_EA/Feb20/SURFACEMODEL/'
indir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_RFE_GDAS_EA/SURFACEMODEL/'

ifile = file_search(strcompress(indir+'2017{01,02}/LIS_HIST*', /remove_all))  & help, ifile &$
ingrid3 = fltarr(nx, ny, n_elements(ifile))

for f = 0, n_elements(ifile)-1 do begin &$
  VOI = 'SoilMoist_tavg' &$
  ;read in all soil layers
  SM = get_nc(VOI, ifile[f]) &$
  ;just keep the top layer
  SM0_10 = SM[*,*,0] &$
  ingrid3[*,*,f] = SM0_10 &$
endfor 

help, smday ;from read in noah_sm_daily

mxind = FLOOR( (36.8701 - map_ulx)/ 0.1)
myind = FLOOR( (0.4856 - map_lry) / 0.1)

;Haramka Somalia 0.793458, 43.383063
mxind = FLOOR( (43.383063 - map_ulx)/ 0.1)
myind = FLOOR( (0.793458 - map_lry) / 0.1)

;plot the overlap between the two time series
cat = [[ [smday[mxind, myind, 1:30]]],[[ingrid2[mxind, myind, *]]] ] & help, cat
p1 = plot(ingrid[mxind, myind, *])
p3 = plot(cat, 'g', /overplot)
p2 = plot(smday[mxind,myind,1:30], /overplot, 'b')

p4 = plot(ingrid3[mxind, myind, *], /overplot, 'c')

;;ok, so CHIRP is prob the way to go. And will inspire propoer list of experiment eventually
;so, what do i need to see?
;check the countmap - it looks too extreme - what are the values for thresholds?
;how are the data distributed around these thresholds?

;plot the seasonal mean
help, sm01
temp = plot(mean(sm01[mxind,myind,*,*],dimension=4,/nan))
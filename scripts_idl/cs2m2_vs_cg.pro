pro CS2M2_vs_CG 

;plot some time series to show transition from Cs2M2 to CG runs
;ugh, is this what i am supposed to be doing right now? (yes!)
;update to be CHIRPS-prelim+GDAS vs CHIRPS-final+MERRA2 rainfall then figure out how that changes for soil moisture/other

;read in Jan16-Jan17 CHIRPS SM from 
.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro

;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
domain = 'EA'
params = get_domain01(domain)
print, params

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

;readin jan-feb CHIRP-GDAS estimates from first try (and second try) and the RFE2+GDAS runs (maybe I can just use them)
;run both of these thru LIS for Jan-March for the 'paper'

;indir = '/discover/nobackup/projects/fame/MODEL_RUNS/EA_Noah33/ESPvanilla/Noah33_CG_ESPV_EA/Feb15/SURFACEMODEL/'
;indir = '/discover/nobackup/projects/fame/MODEL_RUNS/EA_Noah33/ESPvanilla/Noah33_CG_ESPV_EA/Feb20/SURFACEMODEL/'
;indir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_RFE_GDAS_EA/SURFACEMODEL/'

indirP = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/ESPvanilla/Noah33_CG_ESPV_EA/20170413/SURFACEMODEL/'
ifile = file_search(strcompress(indirP+'201702/LIS_HIST*', /remove_all))  & help, ifile ;28daysx4per day
ingrid1 = fltarr(nx, ny, n_elements(ifile))

for f = 0, n_elements(ifile)-1 do begin &$
  VOI = 'SoilMoist_tavg' &$
  ;read in all soil layers
  SM = get_nc(VOI, ifile[f]) &$
  ;just keep the top layer
  SM0_10 = SM[*,*,1] &$
  ingrid1[*,*,f] = SM0_10 &$
endfor 

indirF = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/SURFACEMODEL/'
ifile = file_search(strcompress(indirF+'201702/LIS_HIST*', /remove_all))  & help, ifile ;28daysx4per day
ingrid2 = fltarr(nx, ny, n_elements(ifile))
for f = 0, n_elements(ifile)-1 do begin &$
  VOI = 'SoilMoist_tavg' &$
  ;read in all soil layers
  SM = get_nc(VOI, ifile[f]) &$
  ;just keep the top layer
  SM0_10 = SM[*,*,1] &$
  ingrid2[*,*,f] = SM0_10 &$
endfor

totCF = total(ingrid2, 3,/nan)
totCP = total(ingrid1,3,/nan)
p1 = image(totCP, rgb_table=66) & c = colorbar()
p1 = image(totCF-totCP, rgb_table=66, min_value=-2,max_value=2)
c=colorbar()

;read in/plot the historic
;read in/plot CHIRPS-final Jan-Feb, 
;plot CHIRPS-prelim Jan-Mar, CHIRPS-prelim restart, spegetti
help, smday ;from read in noah_sm_daily

mxind = FLOOR( (36.8701 - map_ulx)/ 0.1)
myind = FLOOR( (0.4856 - map_lry) / 0.1)

;Haramka Somalia 0.793458, 43.383063
mxind = FLOOR( (43.383063 - map_ulx)/ 0.1)
myind = FLOOR( (0.793458 - map_lry) / 0.1)

;plot the overlap between the two time series
cat = [[ [smday[mxind, myind, 1:30]]],[[ingrid2[mxind, myind, *]]] ] & help, cat
p1 = plot(ingrid3[mxind, myind, *], /overplot,linestyle=3)
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
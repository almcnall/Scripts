pro make_spagetti

;;;forecast intialization date
startd = '20170331'
;startd = '20170228'

;yrs used for the ESPing
startyr = 1982
endyr = 2015 ;do i have 2016 estimates?
nyrs = endyr-startyr+1

yr = indgen(nyrs)+1982 & print, yr


NOAHdir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/'
indir2 = NOAHdir+'Noah33_CHIRPS_MERRA2_EA/ESPvanilla/Noah33_CM2_ESPV_EA/'+string(startd)+'/'
;indir2 = NOAHdir+'Noah33_RFE_GDAS_EA/ESPvanilla/Noah33_RG_ESPV_EA/'+string(startd)


;where did 208 come from? 11 because 12 months, starting in feb
;is there a reason to start this in jan?
;enter month of intitialzation 1 = 20170131, 3 = march, output for april though...
initmo = 2
nmos = 12
espgrid = fltarr(NX, NY, nmos,nyrs)*!values.f_nan
;go into the outter directory...
cnt = 0
for i = 0, nyrs-1 do begin &$
  ;just read in all the LIS_HISTFILES for a given run...super pasgetti
  ifile = file_search(strcompress(indir2+string(yr[i])+'/SURFACEMODEL/??????/LIS_HIST*', /remove_all))  & help, ifile &$
  for f = 0, n_elements(ifile)-1 do begin &$
    VOI = 'SoilMoist_tavg' &$
    ;read in all soil layers
    SM = get_nc(VOI, ifile[f]) &$
    ;just keep the top layer
    SM0_10 = SM[*,*,0] &$
    ;start on the intialization month to keep the first months empty...ESPout on first of month?
    espgrid[*,*,f+initmo,cnt] = SM0_10 &$
  endfor &$
  cnt++ &$
  print, cnt &$
endfor 
;make a stack of all of the data and then pull out a point.
;ifile = file_search(strcompress(indir2+'/????/SURFACEMODEL/????01/LIS_HIST*.nc', /remove_all))
help, ifile

;;for the time series we want to plot these by yr...i guess i only need to read in the current yr FLDAS
;1. plot the given season for a point/region
;mpala kenya
mxind = FLOOR( (36.8701 - map_ulx)/ 0.1)
myind = FLOOR( (0.4856 - map_lry) / 0.1)

;Haramka Somalia 0.793458, 43.383063
mxind = FLOOR( (43.383063 - map_ulx)/ 0.1)
myind = FLOOR( (0.793458 - map_lry) / 0.1)

;this wants SMO1 from readin_FLDAS_noah.pro
help, sm01
;inlude the ensemble mean (try median), use percentiles rather than median
;ensmean = median(espgrid, dimension = 4) & help, ensmean
;also include the historic mean
histmean = median(sm01, dimension = 4) & help, histmean
;concatinate Dec31 as Jan1 to fix alighnment
;this doesn't work so great if i need to plot more than a point.
histshift = [ [[histmean[*,*,11]]], [[histmean[*,*,0:10]]] ]

sm01shift = [ [[sm01[mxind,myind,11,34]]], [[sm01[mxind,myind,0:10,35]]] ]

;these shifts don't auto shift correctly!

;compute percentiles of the ensembles
;not yet tested
permap = fltarr(nx, ny, 12, 3)
for m = 0,11 do begin &$
  for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
  ;skip nans
  test = where(finite(espgrid[x,y,m,*]),count) &$
  if count eq -1 then continue &$
  ;look at one pixel time series at a time
  pix = espgrid[x,y,m,*] &$
  ;then find the index of the Xth percentile, how would i fit a distribution?
  permap[x,y,m,*] = cgPercentiles(pix , PERCENTILES=[0.33,0.5,0.67]) &$
endfor  &$
endfor

w = window(DIMENSIONS=[1900,900])
;;plot the timeseries for this yr
for n = 0, n_elements(espgrid[0,0,0,*])-1 do begin &$
  p1 = plot(espgrid[mxind, myind, *, n], /overplot, color='cyan', name = 'ESP ENS') &$
  ;p1.save, '/home/almcnall/IDLplots/ts_mxing2.png' &$
endfor
p2 = plot(permap[mxind, myind, *, 0], /overplot, color='cyan', thick=2, name = 'ENS <33rd')
p3 = plot(permap[mxind, myind, *, 1], /overplot, color='blue', thick=2, name = 'ENS median')
p4 = plot(permap[mxind, myind, *, 2], /overplot, color='cyan', thick=2, name = 'ENS >67rd')

;hist mean off by 1 b/c end of month vs 1st of month issue. 
p5 = plot(histshift[mxind, myind,0:11], /overplot, color='green', thick=2, name = 'historical median')

; so, jan/feb exsist here. March comes from CHIRP...so i have CHIRP from March-1 to March-15
; seems like i am still a month off...
p6 = plot(sm01shift, /overplot, color = 'grey', thick = 2, linestyle=2, name = 'obs')
p7 = plot(espgrid[mxind, myind, *, 2004-1982], /overplot, color='orange', name = '2004', thick=3)
p8 = plot(espgrid[mxind, myind, *, 2012-1982], /overplot, color='red', name = '2012', thick=3)

;add month tickmarks...how do I do this again?
p1.xminor = 0
p1.xrange = [0, 11]
p1.yrange = [0,0.35]
p1.xtickvalues = indgen(12)
xticks = ['jan', 'feb', 'mar', 'apr', 'may', 'jun','jul','aug','sep','oct','nov','dec']
p1.xtickname = xticks
p1.font_name='times'
null = legend(target=[p1,p2,p3,p4,p5,p6,p7,p8], position=[0.8,0.35],font_size=14, font_name='times', color='w', shadow=0)
;p1.save, '/home/almcnall/IDLplots/ts_mxing2.png' 
p1.title = 'Init. March30, 2017 Mpala Kenya';Haramka Somalia'



;;;;;read in the daily estimate;;;;
countmap = fltarr(NX,NY,3)*0
dry = fltarr(NX, NY)*0
for i = 0, n_elements(ifile)-1 do begin &$
  ;for m = 0, 11 do begin &$
  VOI = 'SoilMoist_tavg' &$
  ;read in all soil layers
  SM = get_nc(VOI, ifile[i]) &$
  ;just keep the top layer
  SM01 = SM[*,*,0] &$
  dry = SM01 lt permap[*,*,M,0] &$
  countmap[*,*,0] = countmap[*,*,0] + dry &$
  ;i shouldn't have to do the between since i can subtract at the end since it should equal 100.
  avg = SM01 lt permap[*,*,M,2] &$
  countmap[*,*,1] = countmap[*,*,1] + avg &$
endfor
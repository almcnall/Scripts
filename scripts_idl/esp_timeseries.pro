pro ESP_timeseries
;read in all historic soil moisture

.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
;.compile /home/almcnall/Scripts/scripts_idl/nve.pro
;.compile /home/almcnall/Scripts/scripts_idl/mve.pro

rainfall = 'CHIRPS'
;if rainfall eq 'RFE2' then startyr = 2001 else startyr = 1982

startyr = 1982
endyr = 2017
nyrs = endyr-startyr+1

;re-do for all months
startmo = 1
endmo = 12
nmos = endmo - startmo+1

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


;coordinates for Mpala
;mxind = FLOOR( (36.8701 - map_ulx)/ 0.1)
;myind = FLOOR( (0.4856 - map_lry) / 0.1)

;Haramka Somalia 0.793458, 43.383063
;mxind = FLOOR( (43.383063 - map_ulx)/ 0.1)
;myind = FLOOR( (0.793458 - map_lry) / 0.1)

;Bay Region Somalia 2.660781, 43.530140
mxind = FLOOR( (43.530140 - map_ulx)/ 0.1)
myind = FLOOR( (2.660781 - map_lry) / 0.1)

;;;monthly plots;;;;;;;
histmean = median(sm01, dimension = 4) & help, histmean
p0=plot(histmean[mxind,myind,*], thick = 3, /overplot, title='c2m2 clim')
;
;for i = 0, n_elements(sm01[mxind,myind,0,*])-1 do begin &$
;  p2=plot(sm01[mxind,myind,*,i], /overplot, 'grey') &$
;  if i eq 0 then p2.title='c2m2' &$
;endfor
;;then plot monthly C2final - M2 for this year
;p3=plot(SM01[mxind,myind,*,35], thick = 3, 'orange', /overplot, title='2017')

;;;daily plots;;;;;;;
rundir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/ESPvanilla/'
;then plot Cprelim for this year...daily then monthly
indirP = rundir+'Noah33_CG_ESPV_EA/20170413_CP/SURFACEMODEL/'
ingridP = fltarr(nx, ny, 31, 12)*!values.f_nan

for m = 1,3 do begin &$
  y = 2017 &$
  YYYYMM = STRING(FORMAT='(I4.4,I2.2)',y,m) &$
  ifile = file_search(strcompress(indirP+YYYYMM+'/LIS_HIST*', /remove_all))  & help, ifile &$ ;28daysx4per day
  for f = 0, n_elements(ifile)-1 do begin &$
    VOI = 'SoilMoist_tavg' &$
    ;VOI = 'Evap_tavg' &$

    ;read in all soil layers
    SM = get_nc(VOI, ifile[f]) &$
    ;just keep the top layer
    SM0_10 = SM[*,*,0] &$
    ingridP[*,*,f,m-1] = SM0_10 &$
  endfor &$
endfor

;daily CHIRPS-prelim
;reform to elimate the gap
jfm = [ reform(ingridP[mxind, myind,0:30,0], 31), reform(ingridP[mxind, myind,0:27,1],28), reform(ingridP[mxind, myind,0:30,2],31) ]
p1=plot(jfm, thick=3,'red', name = 'Cprelim', /overplot)
delvar, ingridP
;monthly plots
Cprelim = mean(ingridP,dimension=3,/nan)
p1 = plot(Cprelim[mxind,myind,*], 'red', thick=3, name='Cprelim', /overplot)

;;;;read in Jan, Feb daily CHIRPS-final, so i can see intial conditions for CPrelim
indirF = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/SURFACEMODEL/'
ingridF = fltarr(nx, ny, 31, 12)*!values.f_nan

for m = 1,3 do begin &$
  y = 2017 &$
  YYYYMM = STRING(FORMAT='(I4.4,I2.2)',y,m) &$
  ifile = file_search(strcompress(indirF+YYYYMM+'/LIS_HIST*', /remove_all))  & help, ifile &$ ;28daysx4per day
  for f = 0, n_elements(ifile)-1 do begin &$
  VOI = 'SoilMoist_tavg' &$
  ;read in all soil layers
  SM = get_nc(VOI, ifile[f]) &$
  ;just keep the top layer
  SM0_10 = SM[*,*,0] &$
  ingridF[*,*,f,m-1] = SM0_10 &$
endfor &$
endfor

Fjfm = [ reform(ingridF[mxind, myind,0:30,0], 31), reform(ingridF[mxind, myind,0:27,1],28), reform(ingridF[mxind, myind,0:30,2],31) ]
p2=plot(Fjfm, thick=3,'orange', name = 'Cfinal', /overplot)
;monthly plots
Cfinal = mean(ingridF,dimension=3,/nan)
p2 = plot(Cfinal[mxind,myind,*], 'orange', thick=3, name='Cfinal', /overplot)

;now plot combo, Cfinalial intialized + Cprelim
ifile = file_search(strcompress(rundir+'/Noah33_CG_ESPV_EA/201703/SURFACEMODEL/201703/LIS_HIST*', /remove_all))
ingridC = fltarr(nx, ny, 31)
for f = 0, n_elements(ifile)-1 do begin &$
  VOI = 'SoilMoist_tavg' &$
  ;read in all soil layers
  SM = get_nc(VOI, ifile[f]) &$
  ;just keep the top layer
  SM0_10 = SM[*,*,0] &$
  ingridC[*,*,f] = SM0_10 &$
endfor

;march = mean(ingrid, dimension=3,/nan)
march = reform(ingridC[mxind, myind,*],31)
a = fltarr(28+31)*!values.f_nan

intial = [ a , march ]
;intial = [ [[sm01[*,*,0:1,35]]], [[march]] ]

p3 = plot(intial, thick=3, 'green', /overplot, name = 'intial combo')
;monthly plots
Ccombo = mean(ingridC,dimension=3,/nan)
b = fltarr(2)*!values.f_nan
initial_m = [ b, ccombo[mxind, myind] ]
p3 = plot(initial_m,  '*', sym_size=4, sym_thick=3, name='Ccombo', xrange=[0,11], yrange=[0.1,0.3], /overplot)

;;then plot the ESP results from CHIRPS-final + CHIRPS-prelim - how do i do this?
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
initmo = 3
nmos = 12
;espgrid = fltarr(NX, NY, nmos,nyrs)*!values.f_nan
espgrid = fltarr(NX, NY, 31,12,nyrs)*!values.f_nan

cnt = 0
for i = 0, nyrs-1 do begin &$
    y = i+1982 &$
    print, y &$
    for m = 4,6 do begin &$
    ;m = 4 &$
    YYYYMM = STRING(FORMAT='(I4.4,I2.2)',y,m) &$
    ;just read in all the LIS_HISTFILES for a given run...super pasgetti
    ifile = file_search(strcompress(indir2+string(yr[i])+'/SURFACEMODEL/'+string(YYYYMM)+'/LIS_HIST*', /remove_all))  & help, ifile &$
    for f = 0, n_elements(ifile)-1 do begin &$
      VOI = 'SoilMoist_tavg' &$
      ;read in all soil layers
      SM = get_nc(VOI, ifile[f]) &$
      ;just keep the top layer
      SM0_10 = SM[*,*,0] &$
      ;start on the intialization month to keep the first months empty...ESPout on first of month?
      espgrid[*,*,f,m-1,i] = SM0_10 &$
    endfor &$
  endfor &$
  cnt++ &$
  print, cnt &$
endfor

m_espgrid = mean(espgrid, dimension=3, /nan)
;what did i do with the intial condition??

for i = 0, nyrs-1 do begin &$
  m_espgrid[mxind, myind, 0:2,i] = initial_m &$
  p4 = plot(m_espgrid[mxind, myind, *,i], 'cyan', /overplot) &$
endfor
p5 = plot(m_espgrid[mxind, myind, *,0], 'cyan', /overplot, name='ESP')
null = legend(target=[p1,p2,p3, p5])

;pad = fltarr(31+28+31)*!values.f_nan
for n = 0, n_elements(espgrid[0,0,0,*])-1 do begin &$
  Ejfm = [ reform(espgrid[mxind, myind,0:30,0,n], 31), reform(espgrid[mxind, myind,0:27,1,n],28), $
          reform(espgrid[mxind, myind,0:30,2,n],31), reform(espgrid[mxind, myind,0:29,3,n],30) ] &$
  ;combo = [ pad, reform(espgrid[mxind, myind, *, n],109) ]  &$
  p7 = plot(Ejfm, /overplot, color='cyan', name = 'ESP ENS') &$
  ;if p7 eq 0 then p7.name='ESP ENS' &$
  ;p1.save, '/home/almcnall/IDLplots/ts_mxing2.png' &$
endfor


;add month tickmarks...how do I do this again?
p1.xminor = 0
p1.xrange = [0, 11]
p1.yrange = [0,0.35]
p1.xtickvalues = indgen(12)
xticks = ['jan', 'feb', 'mar', 'apr', 'may', 'jun','jul','aug','sep','oct','nov','dec']
p1.xtickname = xticks
p1.font_name='times'





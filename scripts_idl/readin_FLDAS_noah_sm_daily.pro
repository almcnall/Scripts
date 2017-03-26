pro readin_FLDAS_NOAH_SM_daily
;this reads in the CHIPRS+NOAH monthly time series 1982-present at 0.1 degree
;can this also do the RFE2 if I change the filename? where was that?
;can i just add the continental africa plots to this or do i need a new version?
;make this daily so i don't deal with monthly values in the ESP runs
; just do this once so i can create the percentile thresholds??

.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
.compile /home/almcnall/Scripts/scripts_idl/nve.pro
.compile /home/almcnall/Scripts/scripts_idl/mve.pro

rainfall = 'CHIRPS'
;if rainfall eq 'RFE2' then startyr = 2001 else startyr = 1982

startyr = 1982
endyr = 2017
nyrs = endyr-startyr+1

;re-do for all months
startmo = 1
endmo = 1
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

;;;;;;update data directory here for RFE, CHIRPS, EA, SA, WA;;;;;;;;;;;;;;
indir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/ESPvanilla/'
data_dir = strcompress(indir+'Noah33_CHIRPS_MERRA2_'+domain+'/SURFACEMODEL/', /remove_all)
;data_dir = strcompress(indir+'Noah33_RFE_GDAS_'+domain+'/post/', /remove_all)
if rainfall eq 'CHIRPS' then V = 'C' else V = 'A'
;fname = 'FLDAS_NOAH01_'+V+'_'+domain+'_M.A'

SMday = FLTARR(NX,NY,31,nmos,nyrs)*!values.f_nan
SM01 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
;SM02 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
;SM03 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
;SM04 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan


;this loop reads in the selected months only
for YR = startyr,endyr do begin &$
  for i=0,nmos-1 do begin &$
    y = yr &$
    m = startmo + i &$
    YYYYM = STRING(format='(I4.4,I2.2)', YR, M) & print, YYYYM &$
    if m gt 12 then begin &$
      m = m-12 &$
      y = y+1 &$
    endif &$
    fnames = file_search(strcompress(data_dir+YYYYM+'/LIS_HIST_'+YYYYM+'*.d01.nc', /remove_all)) &$
    print, fnames &$
    for f = 0, n_elements(fnames)-1 do begin &$
      ifile = fnames[f] &$
      ;variable of interest
      VOI = 'SoilMoist_tavg' &$ 
      SM = get_nc(VOI, ifile) &$
      ;just get the top layer
      SM01 = SM[*,*,0] &$
      ;print, ifile, VOI &$
      SMday[*,*,f,i,yr-startyr] = SM01 &$
    endfor &$
  endfor &$
endfor
;SMP(where(SMP lt 0)) = 0
SM01(where(SM01 lt 0)) = 0
;SM02(where(SM02 lt 0)) = 0
;SM03(where(SM03 lt 0)) = 0
;SM04(where(SM04 lt 0)) = 0

delvar, Qs

;convert to m3 per 10km2 pixel (how does this differ with VIC?)
SMm3 = SM01*10+SM02*30+SM03*60+SM04*100
delvar,  SM02, SM03, SM04, SMP
SMtot_annual = mean(SMtot, dimension=3, /nan)
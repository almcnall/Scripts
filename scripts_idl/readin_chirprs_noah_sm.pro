pro readin_CHIRPRS_NOAH_SM
;this reads in the CHIPRS+NOAH monthly time series 1982-present at 0.1 degree
;taken from noahvSSEB
;can i just add the continental africa plots to this or do i need a new version?

.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
;.compile /home/almcnall/Scripts/scripts_idl/nve.pro
;.compile /home/almcnall/Scripts/scripts_idl/mve.pro
;.compile /home/source/mcnally/scripts_idl/get_nc.pro

startyr = 1982 ;start with 1982 since no data in 1981
endyr = 2016
nyrs = endyr-startyr+1

;re-do for all months
startmo = 1
endmo = 12
nmos = endmo - startmo+1

;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
params = get_domain01('EA')
;params = get_domain01('AF')


NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

;;;;;;use SM01 vs SM02 percentiles;;;;
data_dir='/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/post/'
;continental africa doens't work here since the soil layers are still stacked - it hasn't been post-processed.
;data_dir='/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/AFRICA/LSM_run/OUTPUT/SURFACEMODEL/'

;data_dir='/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_WA/post/'

SMP = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
SM01 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
SM02 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
SM03 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
SM04 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan


;this loop reads in the selected months only
for yr=startyr,endyr do begin &$
  for i=0,nmos-1 do begin &$
  y = yr &$
  m = startmo + i &$
  if m gt 12 then begin &$
  m = m-12 &$
  y = y+1 &$
endif &$
  ifile = file_search(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_C_EA_M.A'',I4.4,I2.2,''.001.nc'')',y,m)) &$
  
  ;variable of interest
  VOI = 'SM01_Percentile' &$ 
  Qs = get_nc(VOI, ifile) &$
  ;print, ifile, VOI &$
  SMP[*,*,i,yr-startyr] = Qs &$
  
  VOI = 'SoilMoi00_10cm_tavg' &$
  Qs = get_nc(VOI, ifile) &$
  ;print, ifile, VOI &$
  SM01[*,*,i,yr-startyr] = Qs &$
  
  VOI = 'SoilMoi10_40cm_tavg' &$
  Qs = get_nc(VOI, ifile) &$
  ;print, ifile, VOI &$
  SM02[*,*,i,yr-startyr] = Qs &$
    
  VOI = 'SoilMoi40_100cm_tavg' &$
  Qs = get_nc(VOI, ifile) &$
  ;print, ifile, VOI &$
  SM03[*,*,i,yr-startyr] = Qs &$
  
  VOI = 'SoilMoi100_200cm_tavg' &$  
  Qs = get_nc(VOI, ifile) &$
  ;print, ifile, VOI &$
  SM04[*,*,i,yr-startyr] = Qs &$

endfor &$
endfor
SMP(where(SMP lt 0)) = 0
SM01(where(SM01 lt 0)) = 0
SM02(where(SM02 lt 0)) = 0
SM03(where(SM03 lt 0)) = 0
SM04(where(SM04 lt 0)) = 0

delvar, Qs

;convert to m3 per 10km2 pixel (how does this differ with VIC?)
SMm3 = SM01*10+SM02*30+SM03*60+SM04*100
delvar,  SM02, SM03, SM04, SMP
SMtot_annual = mean(SMtot, dimension=3, /nan)
pro readin_MODIS_NDVI
;this reads in the CHIPRS+NOAH time series 1982-present at 0.1 degree
;taken from noahvSSEB

.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
;.compile /home/almcnall/Scripts/scripts_idl/nve.pro
;.compile /home/almcnall/Scripts/scripts_idl/mve.pro

startyr = 2003 ;start with 1982 since no data in 1981, or 2003 if for SSEB compare
endyr = 2016
nyrs = endyr-startyr+1

;re-do for all months
startmo = 1
endmo = 12
nmos = endmo - startmo+1

;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
params = get_domain01('EA')

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

;;;;;;read in monthly GIMMS MODIS NDVI from LVT;;;;
data_dir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/LVT_test/GIMMS/EAST/STATS_EA_C2M2_MOD_ET_monthly3/'


ndvi = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
;this loop reads in the selected months only
for yr=startyr,endyr do begin &$
  for i=0,nmos-1 do begin &$
  y = yr &$
  m = startmo + i &$
  if m gt 12 then begin &$
  m = m-12 &$
  y = y+1 &$
endif &$
  ifile = file_search(data_dir+STRING(FORMAT='(''MEAN_TS.'',I4.4,I2.2,''010000.d01.nc'')',y,m)) &$
  
  ;variable of interest
  VOI = 'NDVI_from_Evap_v_NDVI_ds2' &$ 
  var = get_nc(VOI, ifile) &$
  NDVI[*,*,i,yr-startyr] = var &$

endfor &$
endfor

NDVI(where(NDVI lt 0)) = 0

delvar, var
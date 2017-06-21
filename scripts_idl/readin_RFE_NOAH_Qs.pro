pro readin_RFE_NOAH_Qs
;this reads in the RFE2+CHIRPS time series 2001-present at 0.1 degree
;taken from aqueductv4.pro


.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro

;.compile /home/almcnall/Scripts/scripts_idl/nve.pro
;.compile /home/almcnall/Scripts/scripts_idl/mve.pro
;.compile /home/source/mcnally/scripts_idl/get_nc.pro

startyr = 2001 ;start with 1982 since no data in 1981
endyr = 2016
nyrs = endyr-startyr+1

;re-do for all months
startmo = 1
endmo = 12
nmos = endmo - startmo+1

;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
params = get_domain01('SA')

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

;read in the NOAH-RFE2_GDAS run
;data_dir='/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_RFE_GDAS_SA/post/'
data_dir='/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Noah33_HYMAP_postprocess/HYMAP/OUTPUT_SA_RG2016/post/

Qsub = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
Qsuf = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan

;this loop reads in the selected months only
for yr=startyr,endyr do begin &$
  for i=0,nmos-1 do begin &$
  y = yr &$
  m = startmo + i &$
  if m gt 12 then begin &$
  m = m-12 &$
  y = y+1 &$
endif &$
;ifile = file_search(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_A_SA_M.A'',I4.4,I2.2,''.001.nc'')',y,m)) &$
ifile = file_search(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_HA_SA_M.A'',I4.4,I2.2,''.001.nc'')',y,m)) &$

VOI = 'RiverStor_tavg' &$ ;Qsb_tavg
;VOI = 'Qs_tavg' &$
Qs = get_nc(VOI, ifile) &$
Qsuf[*,*,i,yr-startyr] = Qs &$

VOI = 'FloodStor_tavg' &$ ;
;VOI = 'Qsb_tavg' &$
Qsb = get_nc(VOI, ifile) &$
Qsub[*,*,i,yr-startyr] = Qsb &$

endfor &$
endfor
Qsuf(where(Qsuf lt 0)) = !values.f_nan
Qsub(where(Qsub lt 0)) = !values.f_nan

RO = Qsuf+Qsub
RO_RFE01 = RO

delvar, RO, Qsuf, Qsub, qs, qsb
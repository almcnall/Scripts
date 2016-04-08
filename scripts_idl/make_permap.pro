; this script is to calculate plot the seasonal forecast senarios.
; using the basics from aqueductv4 script for reading in files.
; 03/31/16 Organized into ens directories.
; 04/05/16 separate out the percentile threshold map

.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro

;.compile /home/source/mcnally/scripts_idl/get_nc.pro

startyr = 1982 ;start with 1982 since no data in 1981
endyr = 2015
nyrs = endyr-startyr+1

;read in all months and then just select the ones I want. Doesn't deal with subsets well. Although a lot of that data doesn't exsit.
startmo = 1
endmo = 12
nmos = endmo - startmo+1
ens = 100

;West Africa (5.35 N - 17.65 N; 18.65 W - 25.85 E)
; west africa domain
;map_ulx = -18.65 & map_lrx = 25.85
;map_uly = 17.65 & map_lry = 5.35

;East Africa WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

;Southern Africa WRSI/Noah window
;Southern Africa (37.85 S - 6.35 N; 6.05 E - 54.55 E) 
;NX = 486, NY = 443
;map_ulx = 6.05  & map_lrx = 54.55
;map_uly = 6.35  & map_lry = -37.85

ulx = (180.+map_ulx)*10.  & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10.   & lry = (50.-map_lry)*10.-1
NX = lrx - ulx + 2 
NY = lry - uly + 2

;data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_RFE2_GDAS_SA/';FLDAS_NOAH01_B_SA_M.A201507.001.nc
;data_dir='/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Noah33_CHIRPS_MERRA2_SA/post/'
data_dir='/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/post/'
;data_dir='/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/ESPtest/Noah33_CM2_ESPboot_OCT2015JAN2016/ENS/'


Qsub = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
Qsuf = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
SM01 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
SM02 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan

;read in the daily data
for yr = startyr,endyr do begin &$
  for i = 0,nmos-1 do begin &$
  y = yr &$
  m = startmo + i &$
  if m gt 12 then begin &$
    m = m-12 &$
    y = y+1 &$
  endif &$
  ;fileID = ncdf_open(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_B_EA_M.A'',I4.4,I2.2,''.001.nc'')',y,m), /nowrite) &$
  ifile = file_search(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_C_EA_M.A'',I4.4,I2.2,''.001.nc'')',y,m)) &$
  ;ifile = file_search(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_H_SA_M.A'',I4.4,I2.2,''.001.nc'')',y,m)) &$

;    VOI = 'Qs_tavg' &$
;    Qs = get_nc(VOI, ifile) &$
;    Qsuf[*,*,i,yr-startyr] = Qs &$
;  
;    VOI = 'Qsb_tavg' &$
;    Qsb = get_nc(VOI, ifile) &$
;    Qsub[*,*,i,yr-startyr] = Qsb &$
  
    VOI = 'SoilMoi00_10cm_tavg' &$
    SM = get_nc(VOI, ifile) &$
    SM01[*,*,i,yr-startyr] = SM &$
  
;    VOI = 'SoilMoi10_40cm_tavg' &$
;    SM = get_nc(VOI, ifile) &$
;    SM02[*,*,i,yr-startyr] = SM &$
    
  endfor &$ ;i
endfor ;yr
;Qsuf(where(Qsuf lt 0)) = 0
;Qsub(where(Qsub lt 0)) = 0
SM01(where(SM01 lt 0)) = 0
;SM02(where(SM02 lt 0)) = 0

;RO = Qsuf+Qsub

help, Qsuf, Qsub, SM01, SM02, RO

;these are the averages, but I want percentiles
climRO = mean(RO,dimension=4,/nan)
climSM01 = mean(SM01,dimension=4,/nan)
climSM02 = mean(SM02,dimension=4,/nan)

help, climRO, climSM01, climSM02

;ok, now define the thresholds with the percenitle function
VAR = SM01;CMPPcube
permap = fltarr(nx,ny,12,3)
for m = 0, 11 do begin &$
  for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
  ;skip nans
  ;test = where(finite(smMar2Sep[x,y,*]),count) &$
  test = where(finite(VAR[x,y,*,*]),count) &$

  if count eq -1 then continue &$
  ;look at one pixel time series at a time
  ;Npix = smMar2Sep[x,y,*] &$
  Npix = VAR[x,y,m,*] &$

  ;what thresholds did Greg (85<X<115% of normal) and Nick use?
  ;get threshold values that represent these percentiles.
  permap[x,y,m,*] = cgPercentiles(Npix, PERCENTILES=[0.33, 0.5, 0.67]) &$

endfor  &$;x
endfor  &$
endfor

ofile = '/home/almcnall/SM01_permap_294_348_12_3.bin'
openw, 1, ofile
writeu, 1, permap
close,1

permap = fltarr(nx, ny, 12, 3)
ifile3 = file_search('/home/almcnall/permap_294_348_12_3.bin')
openr, 1, ifile3
readu, 1, permap
close,1

delvar, sm, sm01, sm02, qsub, qsuf, var, npix


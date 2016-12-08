; this script is to calculate plot the seasonal forecast senarios.
; using the basics from aqueductv4 script for reading in files.
; 03/31/16 Organized into ens directories.
; 04/05/16 separate out the percentile threshold map
; 11/02/16 what was going on here?

.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
.compile /home/almcnall/Scripts/scripts_idl/cgpercentiles.pro

;.compile /home/source/mcnally/scripts_idl/get_nc.pro

startyr = 1982 ;start with 1982 since no data in 1981
endyr = 2015
nyrs = endyr-startyr+1

;read in all months and then just select the ones I want. Doesn't deal with subsets well. Although a lot of that data doesn't exsit.
startmo = 1
endmo = 12
nmos = endmo - startmo+1
ens = 100

;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
params = get_domain01('EA')

eNX = params[0]
eNY = params[1]
emap_ulx = params[2]
emap_lrx = params[3]
emap_uly = params[4]
emap_lry = params[5]

NX = eNX
NY = eNY

;;readin CHIRPS soil moisture with readin_chirps_noah_sm.pro only to 2015! 
help, sm01, sm02, sm03, sm04, smp, smtot

;readin CHIRPS runoff with readin_chirps_noah_qs.pro
help, RO
;these are the averages, but I want percentiles (oh, now you want runoff?)
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

;ofile = '/home/almcnall/SM01_permap_294_348_12_3.bin'
;openw, 1, ofile
;writeu, 1, permap
;close,1
;
;permap = fltarr(nx, ny, 12, 3)
;ifile3 = file_search('/home/almcnall/permap_294_348_12_3.bin')
;openr, 1, ifile3
;readu, 1, permap
;close,1

delvar, sm, sm01, sm02, qsub, qsuf, var, npix


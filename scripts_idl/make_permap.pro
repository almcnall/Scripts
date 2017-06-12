; this script is to calculate plot the seasonal forecast senarios.
; using the basics from aqueductv4 script for reading in files.
; 03/31/16 Organized into ens directories.
; 04/05/16 separate out the percentile threshold map
; 11/02/16 what was i doing?
; 01/27/17 make percentiles rather than averages?
; 02/16/17 make the percentile map from monthly...daily too complicated.

.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
.compile /home/almcnall/Scripts/scripts_idl/cgpercentiles.pro

;.compile /home/source/mcnally/scripts_idl/get_nc.pro

;;;date info should come with the readin_FLDAS_noah_sm.pro;;;;;;;
;startyr = 1982 ;start with 1982 since no data in 1981
;endyr = 2015
;nyrs = endyr-startyr+1
;startmo = 1
;endmo = 12
;nmos = endmo - startmo+1
;ens = 100

;; domain info should come from readin_FLDAS_noah_sm.pro
;;params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
;params = get_domain01('EA')
;eNX = params[0]
;eNY = params[1]
;emap_ulx = params[2]
;emap_lrx = params[3]
;emap_uly = params[4]
;emap_lry = params[5]
;
;NX = eNX
;NY = eNY

;;readin CHIRPS/RFE2 soil moisture with readin_FLDAS_noah_sm.pro
help, sm01, smday
;ok, now define the thresholds with the percenitle function
;now i want to look at all days x all yrs (31*31) to generate the percentiles...
;I think i should do this one month at at time...and save it so i don't have to do it again!
VAR = SM01;CMPPcube
permap = fltarr(nx,ny,12,3)
for m = 0, 11 do begin &$
; m = 0 &$
  for x = 0, nx-1 do begin &$
    print, x &$
    for y = 0, ny-1 do begin &$
      ;reshape to an nx, ny, m, nday*nyr
      ;this is one month and 31*nyrs days...did it reform properly?
      ;var = reform(smday[*, *, *, 0, *], nx, ny, 1, nyrs*31) &$
      ;skip nans 
      test = where(finite(VAR[x,y,*,*]),count) &$
      if count eq -1 then continue &$
      ;look at one pixel time series at a time. nans seem ok.
      Npix = VAR[x,y,m,*] &$
      ;get threshold values that represent these percentiles.
      permap[x,y,m,*] = cgPercentiles(Npix, PERCENTILES=[0.33,0.50, 0.67]) &$
    endfor  &$;x
  endfor &$ 
endfor

;what do these maps look like (without crashing?)
p1 = image(permap[*,*,0,2], /buffer, max_value=0.25, rgb_table=20, title = 'jan .033' )
c=colorbar()
p1.save, '/home/almcnall/test67.png'

;;;;write out the file to skip this step;;;
;ofile = '/home/almcnall/IDLplots/SM01_NOAH_RFE2_permap_294_348_12_3.bin'
ofile = '/discover/nobackup/projects/fame/MODEL_RUNS/EA_Noah33/ESPvanilla/SM01_NOAH_permap_294_348_12_3_1982_2016.bin'

openw, 1, ofile
writeu,1, permap
close, 1

delvar, VAR, Npix


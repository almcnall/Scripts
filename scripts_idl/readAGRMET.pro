PRO readAgGRMET
;modified from M.Marshall's PETwrsi code 
;mostly I want to check out the net rad from Agrmet to compare with GDAS/FNL rad.
; this might be better to do with a bash script...maybe I'll come back to this script later. AM 2/11
;sets working directories
;ndir    = '/jower/LTDR_NDVI/climate/modern/3HOURLY/netrad/' 

indir = '/gibber/sandbox/mcnally/' ;right now this just has rad for 2003
odir  = '/gibber/lis_data/OUTDIR/rad/'

;file_mkdir, odir

cd, indir
;intializes variables

nx = 1440   ;# of columns
ny = 600    ;# of rows
ox = 300.
oy = 320.


;gulx    = -180.0  ;eastings
;guly    =  90.0   ;northings
LL_res   =  0.05   ;pixel size
flag     = -999.0  ;flag for climate data
numfiles =  8      ;# of 3 hourly files per day
days     =  365    ;# of days in a year

;intializes arrays

SWn    = FLTARR(nx, ny) ;three hourly average net shortwave radiation (Wm^-2)
LWday  = FLTARR(nx, ny, numfiles) ;three hourly average net longwave radiation (Wm^-2)
RN     = FLTARR(nx, ny) ;3 hourly net radiation (Wm^-2)

LWfiles  = file_search('*.netlw')
SWfiles   = file_search('*.netsw')
help, LWfiles
buffer   = fltarr(nx,ny)
nfiles   = n_elements(LWfiles)
data_in  = fltarr(nx,ny,nfiles)

i=0
for i=0, (n_elements(LWfiles)-2) do begin
  ; read all of the data (all days all bands) into data_in
  openr,1,LWfiles[i]
  readu,1,buffer
  data_in[*,*,i] = buffer
  close, 1
end




count=0
for i=0, n_elements(LWfiles)+n_elements(SWfiles)-1
      
      
      
      
      
      spawn, strcompress('cp ' + ndir + LWfiles[i] + ' ' + sandman +'/' +LWfiles[i])
      spawn, strcompress('gunzip ' + sandman +'/'+ LWfiles[i])
      close, 1
      openr, 1, strcompress(sandman + '/'+strmid(LWfiles[i],0,25))
      readu, 1, buffer
      LWday[*,*,count]=buffer 
      close, 1
      count=count+1
      
      if (count eq 7) then openw,1, strcompress(odir+strmid(LWfiles[i],0,11)+'img', /remove_all) & writeu,1,LWday & count=0
         
  
    
      
      
      
      
      
      ;spawn, strcompress('rm ' + sandman + strmid(LWfiles[i],0,25 )

;IF (((year MOD 4) EQ 0) AND ((year MOD 100) NE 0)) THEN days = 366 ;leap years

;q = 0 ;place holder for endtime

;outer loop performs daily processes and inner loop performs 3 hourly processes

;FOR julian = 1, days DO BEGIN
;
;	;resets temporary variables
;;
;;	petsum [*,*]  = 0.0
;;	pcnt   [*,*]  = 0
;;	petasum[*,*]  = 0.0
;;	apcnt  [*,*]  = 0
;;	petrsum[*,*]  = 0.0
;;	rpcnt  [*,*]  = 0
;;	n             = 0
;	
;	FOR hour = 0, numfiles - 1 DO BEGIN
;
;		;resets temporary variables
;
;		pcount [*,*] = 0
;		rpcount[*,*] = 0
;		apcount[*,*] = 0
;
;		;this section reads in 0000 (previous 3 hours) for true daily statistics
;
;		n    = 3*hour
;		juln = julian
;		yrn  = year
;
;		IF n EQ 0 THEN BEGIN
;
;			IF julian EQ days THEN BEGIN
;
;				yrn = year + 1
;				juln = 1
;
;			ENDIF ELSE BEGIN
;
;				juln = julian + 1
;
;			ENDELSE
;
;		ENDIF

		;string arrays for image in
		RSW_r  = strcompress('3HGLDAS' + STRING(yrn) + STRING(format='(I3.3)', juln) + '.' + STRING(format='(I2.2)', n) + STRING(format='(I2.2)', q) + '.netsw', /remove_all) ;net shortwave radiation
		RLW_r  = strcompress('3HGLDAS' + STRING(yrn) + STRING(format='(I3.3)', juln) + '.' + STRING(format='(I2.2)', n) + STRING(format='(I2.2)', q) + '.netlw', /remove_all) ;net longwave radiation
  	;this section decompresses, reads, and assigns image in to variable in

		;IF(file_test(strcompress(vdir + SH_r + '*.gz'))) THEN BEGIN

			print, strcompress('3HGLDAS' + STRING(yrn) + STRING(format='(I3.3)', juln) + '.' + STRING(format='(I2.2)', n), /remove_all) ;process tracker

			spawn, strcompress('cp ' + ndir + RSW_r + '.gz' + ' ' + sandman + RSW_r + '.gz')
			spawn, strcompress('gunzip ' + sandman + RSW_r + '.gz')
			close, 4
			openr, 4, strcompress(sandman + RSW_r)
			readu, 4, SWn 
			close, 4
			spawn, strcompress('rm ' + sandman + RSW_r)

			spawn, strcompress('cp ' + ndir + RLW_r + '.gz' + ' ' + sandman + RLW_r + '.gz')
			spawn, strcompress('gunzip ' + sandman + RLW_r + '.gz')
			close, 5
			openr, 5, strcompress(sandman + RLW_r)
			readu, 5, LWn
			close, 5
			spawn, strcompress('rm ' + sandman + RLW_r)

			;verifies the existence of non-NAN data within each image

			good = 0
			bad = 0
			good = where(SWn GT flag AND LWn GT flag AND , count, complement = bad)

			IF count GT 0 THEN BEGIN

				;converts variables to proper units
				;this section calculates pressure and temperature related components

	
				RN = SWn + LWn ;computes net radiation
				RN = 3.0 * 0.0036 * RN ;converts Wm^-2 to MJ m^-2 3hr^-1 
				RN[bad] = flag

				;this section identifies/computes day and night components

				dayind = 0
				nightind = 0
				dayflag = where(RN GT 0, count, complement = nightflag)
				IF count GT 0 THEN BEGIN

					;soil heat flux
					G[dayind] = 0.1 * RN[dayind] 
					G[nightind] = 0.5 * RN[nightind]

					;bulk surface resistance and aerodynamic resistance coefficient
					bulk[dayind] = 0.24
					bulk[nightind] = 0.96

				ENDIF

				G[bad] = flag
				bulk[bad] = flag

				;this section computes potential evapotranspiration according to CIMIS (http://www.cimis.water.ca.gov/cimis/infoEtoPmEquation.jsp) over three hour period

;				radPET = 3.0 * delta * (RN - G) / (lamda * (delta + psi * (1.0 + bulk * wind))) ;radiation driven component of PET
;				advecPET = 3.0 * (37.0 * psi * wind * (vapsat - vap) / (tmp + 273.16)) / (delta + psi * (1.0 + bulk * wind)) ;advection driven component of PET
;				radPET[bad] = 0.0
;				advecPET[bad] = 0.0
;
;				PETtot = radPET + advecPET ;sums components
;				PETtot[bad] = 0.0

				;this section sums 3 hourly values to yield daily PET

				rpcount[good] = 1
				rpcount[bad]  = 0
				apcount[good] = 1
				apcount[bad]  = 0	
				pcount[good]  = 1
				pcount[bad]   = 0	
				
				petsum = PETtot + petsum
				petasum = advecPET + petasum
				petrsum = radPET + petrsum

				pcnt = pcount + pcnt
				apcnt = apcount + apcnt
				rpcnt = rpcount + rpcnt
				
			ENDIF
					
		ENDIF

	ENDFOR

	;this section forces any remaning NAN's to flag

;	pind = 0
;	pind = where(pcnt EQ 0, count)
;	IF count GT 0 THEN petsum[pind] = flag
;
;	apind = 0
;	apind = where(apcnt EQ 0, count)
;	IF count GT 0 THEN petasum[apind] = flag
;	
;	rpind = 0
;	rpind = where(rpcnt EQ 0, count)
;	IF count GT 0 THEN petrsum[rpind] = flag		
;		
	;string arrays for image out
;
;	petr_w = strcompress(petdir + 'DGLDAS' + STRING(format = '(I4.4,I3.3)', year, julian) + '.rdpet', /remove_all)
;	peta_w = strcompress(petdir + 'DGLDAS' + STRING(format = '(I4.4,I3.3)', year, julian) + '.adpet', /remove_all)
;	pet_w = strcompress(petdir + 'DGLDAS' + STRING(format = '(I4.4,I3.3)', year, julian) + '.pet', /remove_all)

	;this section writes image out and assigns string arrays

	close, 8
	openw, 8, petr_w
	writeu, 8, petrsum
	close, 8
	spawn, strcompress('gzip -f ' + petr_w)

	close, 9
	openw, 9, peta_w
	writeu, 9, petasum
	close, 9
	spawn, strcompress('gzip -f ' + peta_w)

	close, 10
	openw, 10, pet_w
	writeu, 10, petsum
	close, 10
	spawn, strcompress('gzip -f ' + pet_w)

ENDFOR 

END
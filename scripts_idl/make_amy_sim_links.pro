;;; THIS WORKSHEET WILL CREATE RANDOM NUMBERS AND THEN WRITE OUT A 
;;; BASH-SHELL SCRIPT THAT WILL CREATE SYMBOLIC LINKS FOR THE RANDOM
;;; SIMULATION.
;;; original code from greg modified by me June 11, 2014

; set some basic timing parameters
startyr = 1981
endyr = 2013
nyrs = endyr - startyr +1
start_mo = 6         ; month of the start of season
start_dek = ((start_mo-1) * 3) + 1   ; dekad number of the first dekad of start_mo
end_mo = 12           ; last month to look at rainfall
end_dek = (end_mo * 3)               ; dekad number of the third dekad of end_mo
if end_mo gt start_mo then nmos = end_mo-start_mo+1 else $
   nmos = end_mo-start_mo+13
if end_dek gt start_dek then ndeks = end_dek-start_dek+1 else $
   ndeks = end_dek-start_dek+37
ndays = [10,10,11,10,10, 8,10,10,11,10,10,10,10,10,11,10,10,10, $
         10,10,11,10,10,11,10,10,10,10,10,11,10,10,10,10,10,11]

; DEVELOP SIMULATIONS FOR THE CLIMATOLOGY CONDITION WITH ALL YEARS WEIGHTED EVENLY
nsims = 100
seed = 83L
wt_yrs = INDGEN(nyrs)+startyr
wts = FLTARR(nyrs) + (1./FLOAT(nyrs))
wt_cum = TOTAL(wts,/CUMULATIVE)		; get the cumulative total of wts
wt_cum = wt_cum / MAX(wt_cum)		; divide by max cum so the total wts is 1.0
rnd_num = RANDOMU(seed,ndeks,nsims) 	; random numbers used to determine index
rnd_ind = BYTARR(ndeks,nsims)		; index values associated with random 

; write a quick loop to fill in rnd_ind
; skip case where rnd_num is lt wt_cum[0] because that will stay as a value of zero
for i=1,N_ELEMENTS(wt_cum)-1 do $
   rnd_ind(WHERE(rnd_num gt wt_cum[i-1] AND rnd_num le wt_cum[i])) = BYTE(i)

outyrs = wt_yrs[rnd_ind]

; now write out the shell script file
outdir = '/home/ftp_out/people/mcnally/lis/CHIRPS/clim_sims/'
;i added an extra year since LIS-WRSI has a long run time
for i=0,30 do begin
   outfile = outdir+STRING(FORMAT='(''sim_link_sim'',I4.4,''.bsh'')',i)
   startyr = 2014
   close,1
   openw,1,outfile
   printf,1,'#!/bin/bash'

   yr = startyr		; calendar year
   mo = start_mo-1	; calendar month
   for m=0,nmos-1 do begin
      mo = mo+1
      if mo gt 12 then begin
         mo = 1
         yr = yr+1
      endif
      
      for d=1,TOTAL(ndays[(mo-1)*3:(mo*3)-1]) do begin
         case (d le 10) + (d le 20) of	; create dek_num to find which dekad we're in
            0: dek_num = 2
            1: dek_num = 1
            2: dek_num = 0
            ELSE: print,'we have a problem. weird day.'
         endcase
         target_name = STRING(FORMAT='(''../'',I4.4,''/all_products.bin.'',I4.4,I2.2,I2.2)', $
            outyrs[(m)*3+dek_num,i],outyrs[(m)*3+dek_num,i],mo,d)
         link_name = STRING(FORMAT='(I4.4,''/all_products.bin.'',I4.4,I2.2,I2.2)',yr+i,yr+i,mo,d)

         printf,1,'ln -s '+target_name+' '+link_name
      endfor
   endfor
   close,1
endfor
print, 'hold'
end


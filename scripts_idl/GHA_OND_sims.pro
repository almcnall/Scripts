;;; THIS WORKSHEET IS DESIGNED TO MAKE AND WRITE OUT SOME SYNTHETIC
;;; SEASONS FOR USE IN SEAONAL FORECASTING.  THIS DOESN'T INCLUDE ANY SOS OR 
;;; EOS INFORMATION IN THE CALCULATION, IT'S JUST WRITING OUT WEIGHTED
;;; PERMUTAIONS OF RAINFALL

startyr = 1993
endyr = 2012
nyrs = endyr - startyr + 1
wt_yrs = INDGEN(nyrs)+startyr
nsims = 100             ; number of simulations
seed = 83L

;;;SET UP THE WEIGHTED FORECASTS FOR THE DESIGNATED PERIOD
; set some basic parameters
start_mo1 = 11         ; month of the start of season
start_dek1 = ((start_mo1-1) * 3) + 1   ; dekad number of the first dekad of start_mo
end_mo1 = 12           ; last month to look at rainfall
end_dek1 = (end_mo1 * 3)               ; dekad number of the third dekad of end_mo
if end_dek1 gt start_dek1 then ndeks1 = end_dek1-start_dek1+1 else $
   ndeks1 = end_dek1-start_dek1+37

; create output from permutations of combinations of previous years
wts1 = [0.0809415, 0.0273653, 0.0404284, 0.0358311, 0.0165605, 0.0259314, 0.0310721, $
       0.0496348, 0.0643471, 0.0272003, 0.137671,  0.0472929, 0.0432166, 0.0248825, $
       0.0620890, 0.115014,  0.0315857, 0.0274941, 0.0657532, 0.0456885]
wt_cum1 = TOTAL(wts1,/CUMULATIVE)		; get the cumulative total of wts
wt_cum1 = wt_cum1 / MAX(wt_cum1)		; divide by max cum so the total wts is 1.0
rnd_num1 = RANDOMU(seed,ndeks1,nsims) 	; random numbers used to determine index
rnd_ind1 = BYTARR(ndeks1,nsims)		; index values associated with random 

; write a quick loop to fill in rnd_ind
; skip case where rnd_num is lt wt_cum[0] because that will stay as a value of zero
for i=1,N_ELEMENTS(wt_cum1)-1 do $
   rnd_ind1(WHERE(rnd_num1 gt wt_cum1[i-1] AND rnd_num1 le wt_cum1[i])) = BYTE(i)
outyrs1 = wt_yrs[rnd_ind1]

;;;THEN DO THE SIMULATIONS FOR THE CLIMATOLOGY PERIOD (TO BE ADDED TO THE WEIGHTED)
; set some basic parameters
start_mo2 = 1         ; month of the start of season
start_dek2 = ((start_mo2-1) * 3) + 1   ; dekad number of the first dekad of start_mo
end_mo2 = 7           ; last month to look at rainfall
end_dek2 = (end_mo2 * 3)               ; dekad number of the third dekad of end_mo
if end_dek2 gt start_dek2 then ndeks2 = end_dek2-start_dek2+1 else $
   ndeks2 = end_dek2-start_dek2+37

; create output from permutations of combinations of previous years
wts2 = FLTARR(nyrs) + (1./FLOAT(nyrs))  ; set climatology weights
wt_cum2 = TOTAL(wts2,/CUMULATIVE)         ; get the cumulative total of wts
wt_cum2 = wt_cum2 / MAX(wt_cum2)           ; divide by max cum so the total wts is 1.0
rnd_num2 = RANDOMU(seed,ndeks2,nsims)     ; random numbers used to determine index
rnd_ind2 = BYTARR(ndeks2,nsims)           ; index values associated with random 

; write a quick loop to fill in rnd_ind
; skip case where rnd_num is lt wt_cum[0] because that will stay as a value of zero
for i=1,N_ELEMENTS(wt_cum2)-1 do $
   rnd_ind2(WHERE(rnd_num2 gt wt_cum2[i-1] AND rnd_num2 le wt_cum2[i])) = BYTE(i)

outyrs2 = wt_yrs[rnd_ind2]

;;;NOW COMBINE THE WEIGHTED FORECAST AND CLIMATE FORECAST AND WRITE OUT APPROPRIATE STUFF
out_prnt = [outyrs1, outyrs2]

;write out shrad file
write_csv,'shrad_2013OND.csv',out_prnt

;write out amy bash scripts
nmos = (ndeks1 + ndeks2) / 3
ndays = [10,10,11,10,10, 8,10,10,11,10,10,10,10,10,11,10,10,10, $
         10,10,11,10,10,11,10,10,10,10,10,11,10,10,10,10,10,11]

for i=0,29 do begin
   outfile = STRING(FORMAT='(''sim_link_sim'',I4.4,''.bsh'')',i)
   startyr = 2013
   close,1
   openw,1,outfile
   printf,1,'#!/bin/bash'

   yr = startyr		; calendar year
   mo = start_mo1-1	; calendar month
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
            out_prnt[(m)*3+dek_num,i],out_prnt[(m)*3+dek_num,i],mo,d)
         link_name = STRING(FORMAT='(I4.4,''/all_products.bin.'',I4.4,I2.2,I2.2)',yr+1000+(2*i),yr,mo,d)

         printf,1,'ln -s '+target_name+' '+link_name
      endfor
   endfor
   close,1
endfor


;this script calls the function "quick_amy_wrapper" and Afr05_to_Afr10
; to reformat Pete's africa chirps tiffs to look like RFE2 so that they can 
; 1/21/15 
wkdir = '/home/source/mcnally/Scripts/scripts_idl/'
cd, wkdir 

.compile Afr05_to_Afr10.pro
.compile quick_amy_wrapper.pro

ndays_28 = [31,28,31,30,31,30,31,31,30,31,30,31]
ndays_29 = [31,29,31,30,31,30,31,31,30,31,30,31]

;for y = 2015,2016 do begin &$
y=2016  
  if y MOD 4 eq 0 then print, string(y)+' leap!' &$
  if y MOD 4 eq 0 then ndays = ndays_29 else ndays = ndays_28 &$
   for m=1,12 do begin &$
      for d=1,ndays[m-1] do dump = quick_amy_wrapper(y,m,d) &$   
   endfor 
;endfor

;******leap years, climatology modifications,updating the last month of data
;wkdir = '/home/source/mcnally/scripts_idl/'
;cd, wkdir 

;.compile Afr05_to_Afr10.pro
;.compile quick_amy_wrapper.pro

;.compile quick_amy_wrapper_vCLIM.pro

;ndays_28 = [31,28,31,30,31,30,31,31,30,31,30,31]
;ndays_29 = [31,29,31,30,31,30,31,31,30,31,30,31]

;for y = 1981,2013 do begin &$
;what about the clim (no year)  
;  if y MOD 4 ne 0 then print, string(y)+' leap!' &$
;  if y MOD 4 ne 0 then ndays = ndays_29 else ndays = ndays_28 &$
;  y = 2014
;   m= 5
   ;for m=1,12 do begin &$
;       for d=1,ndays_28[m-1] do dump = quick_amy_wrapper(y,m,d)
      ;for d=1,ndays_29[m-1] do dump = quick_amy_wrapper_vCLIM(m,d) &$   
  ; endfor
;endfor


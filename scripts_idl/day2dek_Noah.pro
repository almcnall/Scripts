pro day2dek_Noah

;the purpose of this script is to make dekads from daily Noah outputs
;modified on 6/20/2013 for latest runs
;modified on 7/17/2013 to include evapotranpirtation components

;ifile=file_search('/jower/LIS/OUTPUT/EXPA46/daily/Sm03_*')
;ifile1 = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/daily/Sm01*.img')
;ifile2 = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/daily/Sm02*.img')
;ifile3 = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/daily/Sm03*.img')
;ifile4 = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/daily/Sm04*.img')
;ifile5 = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/daily/Evap*.img')
;ifile6 = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/daily/PoET*.img')
ifile6 = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/daily/TVeg_*.img')

nx = 720
ny = 250
ingrid=fltarr(nx,ny)

dek1   = fltarr(nx,ny)
dek2   = fltarr(nx,ny)
dek3   = fltarr(nx,ny)

cnt1=0
cnt2=0
cnt3=0

;make Noah soil moisture dekads.
for yr = 2001,2011 do begin
  
  for mm=1,12 do begin
    sdek = file_search(strcompress('/jower/sandbox/mcnally/fromKnot/EXP02/daily/TVeg_' $
                      +STRING(yr)+STRING(FORMAT='(I2.2)',mm)+'*.img', /remove_all))
    for d=0,n_elements(sdek)-1 do begin
      openr,1,sdek[d]
      readu,1,ingrid
      close,1
      day=strmid(sdek[d],55,2)
      ;for the 5 character variable names...
      ;day=strmid(sdek[d],56,2)
     
       ;finally - i learned to nest these silly things...
       if (float(day) lt 11.) then begin
       dek1=dek1+ingrid & cnt1++ 
       endif else if (float(day) gt 10.) AND  (float(day) lt 21.) then begin
         dek2=dek2+ingrid & cnt2++  
       endif else if (float(day) gt 20.) then begin
         dek3=dek3+ingrid & cnt3++  
       endif else begin
         break 
       endelse   
  
    endfor;d
    ;what does this do? find the average?
    print, cnt1,cnt2,cnt3
;     dek1 = dek1/cnt1
;     dek2 = dek2/cnt2
;     dek3 = dek3/cnt3 
;for rainfall/evap/runoff totals rather than averages?
      dek1 = dek1
      dek2 = dek2
      dek3 = dek3
     
     ;write out the dekad files
     ;odir = '/jower/sandbox/mcnally/EXPA46_dekads/sm03/'
     odir = '/jower/sandbox/mcnally/fromKnot/EXP02/dekadal/'+strmid(sdek[0],44,4)
     ;change from 7 to 8 for the 5 character var name
     ofile1 = strcompress(odir+strmid(sdek[0],48,7)+'_01.img',/remove_all) & print, ofile1
     ofile2 = strcompress(odir+strmid(sdek[0],48,7)+'_02.img',/remove_all) & print, ofile2
     ofile3 = strcompress(odir+strmid(sdek[0],48,7)+'_03.img',/remove_all) & print, ofile3
;     
     openw,1,ofile1
     writeu,1,dek1
     close,1
     
     openw,1,ofile2
     writeu,1,dek2
     close,1
     
     openw,1,ofile3
     writeu,1,dek3
     close,1    
;reset the counter for averaging the dekads     
  cnt1=0
  cnt2=0
  cnt3=0
  
  ;why didn't i need to reset the deks before?? better double check SM data
      dek1 = 0
      dek2 = 0
      dek3 = 0

  endfor;mm
endfor;yr   
   print, 'hold'
end
     
;open up the writen out dek and see if it matches...
;
;lon = 3
;lat = 14
;xx = floor((lon+19.95)*10) 
;yy = floor((29.95-lat)*10)
;
;
;;checking out my anomalies. it should be a nice smooth curve
;yr=['2005','2006','2007','2008','2009','2010']
;cube = fltarr(nx,ny,36,6)
;ingrid=fltarr(nx,ny) 
;for y=0,n_elements(yr)-1 do begin &$
;  ;ifile = file_search(strcompress('/jabber/sandbox/mcnally/EXPA02_dekads/evap/2005*img',/remove_all)) &$
;  ifile = file_search(strcompress('/jabber/sandbox/mcnally/EXPA02_dekads/evap/'+yr[y]+'*img',/remove_all)) &$
;  
;  ;for some reason dek1 and dek1 doesn't match...do they not match b/c one is the stm?
;  for i=0,n_elements(ifile)-1 do begin &$
;    openr,1,ifile[i] &$
;    readu,1,ingrid &$
;    close,1 &$
;    ingrid=reverse(ingrid,2) &$
;    ;temp=image(ingrid, rgb_table=4)
;    cube[*,*,i,y]=ingrid &$
;   endfor &$
; endfor ;y
; ;avg = mean(cube[xx,yy,*,*],/nan,dimension=4)
; avg = mean(cube,/nan,dimension=4)
; p1=plot(avg[xx,yy,*],'r')
; 
;; for i=0,n_elements(avg[xx,yy,*])-1 do begin &$
;;   out = avg[*,*,i] &$
;;   ofile=strcompress('/jabber/sandbox/mcnally/EXPA02_dekads/evap/evap.stm_dek'+string(format='(i2.2)',i+1),/remove_all)  &$
;;   openw,1,ofile &$
;;   writeu,1,out &$
;;   close,1 &$
;; endfor
;; 
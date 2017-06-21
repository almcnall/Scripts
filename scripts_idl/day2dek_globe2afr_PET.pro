pro day2dek_globe2afr_PET
;making adjustments to v_2 for the second round of unbiasing of the raw, rather than lis-processed data -AM 4/4/11
;In addition to summing up dekads of rainfall this multiplies them (?)
;9/19/12 making dekads for the ubRFE2 created in 02/2012 -- going to calculate API with them
;11/3/12 making dekads for the RFE2 -- for cacluating API
;11/23/12 aand updating to include 2011-12

;first clip down to the africa window and write out as daily files....
;indir= strcompress("/jabber/sandbox/mcnally/EROSPET/",/remove_all)
;odir = strcompress("/jabber/chg-mcnally/EROSPET/pet_binary/afr/", /remove_all)
;;
;nx = 360
;ny = 181
;;
;ifile = file_search(indir+'*{2001,2002,2003,2004}/*.bil') 
;ingrid  = uintarr(nx,ny) ; the .bil are unsigned integers 
;;
;for i=0, n_elements(ifile)-1 do begin &$
;  openr,1,ifile[i]     &$        ;opens one file at a time   
;  readu,1,ingrid       &$        ;reads the file into ingrid
;  close,1   &$
;  byteorder,ingrid,/XDRTOF   &$ ;these things come in big endian, not idl friendlu
;  ingrid=reverse(ingrid,2) &$
;;  
;;  ;clip out africa, use this later for now just figure out what is my pixel of interest
;;west = 360 - 180 - 20 
;;east = 360 - 180 + 55 
;;south = 180 - 90 - 40
;;north = 180 - 90 + 40
;
;afr = ingrid[160:234,50:129] &$ ;75x80 -- how will rebin/congrid deal with this?
;;  
;  ofile = strcompress(odir+strmid(ifile[i],41,9)+'img', /remove_all) & print, ofile &$
;  openw,1,ofile &$
;  writeu,1,afr &$
;  close,1 &$
;endfor 

idir = "/jabber/chg-mcnally/EROSPET/pet_binary/afr/"
odir = '/jabber/chg-mcnally/EROSPET/pet_binary/afr/dekads/'

nx = 75
ny = 80

ox = 751
oy = 801
  ;initialize arrays
  buffer = uintarr(nx,ny)
  dek1   = fltarr(ox,oy)
  dek2   = fltarr(ox,oy)
  dek3   = fltarr(ox,oy)

;year   = ['2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011']
;year   = ['2005','2006','2007','2008'] 
;year   = ['2009','2010','2011','2012'] 
year   = ['2001','2002','2003','2004'] 



 
;for each yr and each month files for days 1-10 will open,read, and sum precip\
;then days 11-20 and finally the rest of the month 
;crap, this should be more like dekadal soil moisture (AVG) rather than dek rainfall (TOT)
cnt1 = 0
cnt2 = 0
cnt3 = 0
for j = 0, n_elements(year)-1 do begin      ;year loop
  dek = 0                        
    
  for k = 1,12 do begin   ;month loop
    mm = STRING(FORMAT='(I2.2)',k)   ;two digit month
    files = file_search(idir+'/et'+strmid(year[j],2,2)+mm+'*') ;find all files from given month
     
    for h = 0,n_elements(files)-1 do begin              ;day loop (max)
     buffer = uintarr(nx,ny)
     openr,1,files[h]           
     readu,1,buffer                ;reads the file into the buffer      
     close,1
     
     buffer = congrid(buffer,751,801)       
       ;finally - i learned to nest these silly things...
       if (h lt 11.) then begin
       dek1 = dek1+buffer & cnt1++ & print, cnt1 
       endif else if (h gt 10.) AND  (h lt 21.) then begin
         dek2 = dek2+buffer & cnt2++ & print, cnt2 
       endif else if (h gt 20.) then begin
         dek3 = dek3+buffer & cnt3++  & print, cnt3
       endif else begin
         break 
       endelse   
   
    endfor ;h 
     dek1 = dek1/cnt1
     dek2 = dek2/cnt2
     dek3 = dek3/cnt3
             
   ; open and write dekads in subdirectory -- I should merge this with re-format step...
   dek=dek+1
   ;print, strcompress(+odir+year[j]+STRING(FORMAT='(I2.2)',dek)+".img",/remove_all) ; first time should be 1,2,3 then 4,5,6 then 7,8,9
   
   openw,2, strcompress(+odir+year[j]+STRING(FORMAT='(I2.2)',dek)+".img",/remove_all) ; first time should be 1,2,3 then 4,5,6 then 7,8,9
   writeu,2,dek1/100
   close,2
;     
   dek=dek+1
   openw,3, strcompress(+odir+year[j]+STRING(FORMAT='(I2.2)',dek)+".img",/remove_all)
   writeu,3,dek2/100
   close,3
;     
   dek=dek+1
   openw,4, strcompress(+odir+year[j]+STRING(FORMAT='(I2.2)',dek)+".img",/remove_all)      
   writeu,4,dek3/100
   close,4
   
   dek1 = fltarr(ox,oy)
   dek2 = fltarr(ox,oy)
   dek3 = fltarr(ox,oy)
   
   ;reset the counter for averaging the dekads     
  cnt1 = 0
  cnt2 = 0
  cnt3 = 0
   
 endfor ;end k
 print, 'writing'+strcompress(+odir+year[j]+STRING(FORMAT='(I2.2)',dek)+".img",/remove_all);just to see something happening
endfor ;end j
print, 'hold'
end
;
;;;see if they look ok....YES!
;ifile = file_search('/jabber/chg-mcnally/EROSPET/binary/afr/dekads/2005*.img')
;
;nx = 751
;ny = 801
;ingrid = fltarr(nx,ny)
;stack = fltarr(nx,ny,36)
;
;for i = 0,n_elements(ifile)-1 do begin &$
;  openr,1,ifile[i]  &$
;  readu,1,ingrid &$
;  close,1 &$
;  ;mve, ingrid &$
;
; stack[*,*,i] = ingrid  &$
;
;endfor 
;
;;end
;;
;;;Wankama Niger (prolly should double check this...)
;xind = FLOOR((2.633 + 20.05) * 10.0)
;yind = FLOOR((13.6454 + 40.05) * 10.0)
;
;;temp = image(total(stack,3))
;p1 = plot(stack[xind,yind,*]);shape looks ok, magnitude looks too big. b/c in integers?

;****map it***********
;  p1 = image(ingrid, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
;           rgb_table=20)
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07])
;  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
;  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

 
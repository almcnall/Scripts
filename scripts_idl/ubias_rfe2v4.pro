pro ubias_rfe2v4

; this script takes daily CPC RFE2 data (mm/day, 0.1 degree), finds the average monthly 
; values in the time series (2001-2011)
; and calculates a scaling factor using the FCLIM_04.28.11 monthly climatology (~60yrs) field. 
; This factor is then applied to the original daily data yielding 'unbiased' 
; RFE2 daily rainfall estimates.  I think that the original 
; data can be found here on zippy 'binaryFCLIM/FCLIM_2011-04-28.'+mm+'.bin'

indir    = strcompress("/jabber/LIS/Data/CPCOriginalRFE2/",/remove_all);
fclimdir = strcompress("/jabber/LIS/Data/FCLIM_Afr/", /remove_all)
outdir   = strcompress("/jabber/LIS/Data/ubRFE04.19.2013/", /remove_all)

;FILE_MKDIR,outdir
cd,indir

;dimensions of the original CPC data (in big endian)
nx = 751.
ny = 801.
nbands = 1. 
small = 10

;dimensions of FCLIM_Afr
fx = 1501
fy = 1601
fz = 12 ;12 month cube

buffer = fltarr(nx,ny)
data_in = fltarr(nx,ny,fz); do i need this one?
ingrid = lonarr(fx,fy,fz)
fclim10 = fltarr(nx,ny,fz)

;***rebin the fclim data to 0.1 degree, change int to float and missing***
;values from -9999 to NaN so that it matches the CPC-RFE2*****************

fclim05 = file_search(fclimdir+'*.img')
close,1
openr,1,fclim05
readu,1,ingrid
close,1

;btw, at this point it is still upside-down
fclim10 = float(congrid(ingrid,nx,ny,fz))
nulls = where(fclim10 lt 0.)
fclim10(nulls) = !values.f_nan
;free up the ingrid memory
delvar, ingrid
;********************************************************************
;create the short term (12yr) monthly means from the 2001-2012 data.
;vector of two digit month strings
mo = ['01','02','03','04','05','06','07','08','09','10','11','12']

  stm = fltarr(nx,ny,n_elements(mo))
  PON = fltarr(nx,ny,n_elements(mo))
  
for i = 0,n_elements(mo)-1 do begin &$
  ;find all daily files for month[i] from 2001-2011
  files = file_search('all_products.bin.20{01,02,03,04,05,06,07,08,09,10,11,12}'+mo[i]+'*') &$
  
  ;initialize the output array depending on number of yrs and days in month[i]
  tmpout = fltarr(nx,ny,n_elements(files),n_elements(mo))  &$
  
  totrain = fltarr(nx,ny,n_elements(mo)) &$
  ; read in each file change to little endian, rotate image, and 
  ; replace -9999 with NaN to match fclim format and stack it so I can take the mean
  for j=0,n_elements(files)-1 do begin  &$
    openr,1, files[j]  &$
    readu,1, buffer &$
    close,1 &$
    byteorder,buffer,/XDRTOF    &$
    buffer = reverse(buffer,2)   &$
    buffer(where(buffer gt 500.)) = 500. &$
    buffer(where(buffer lt 0.00)) = !values.f_nan &$
    tmpout(*,*,j,i) = buffer     &$
  endfor   &$;j
    yrs = 12  &$
    ;total up tmpout over the third dimension (days in month[i] over all the years)
    totrain[*,*,i] = total(tmpout[*,*,*,i],3,/NAN)  &$
    stm[*,*,i] = totrain[*,*,i]/yrs  &$
   ; mve, stm
    ;does this not work with NANs?
    PON[*,*,i] = fclim10[*,*,i]/(stm[*,*,i]+small)  &$ ;Soni's correction> fclim/stm+e, to avoid dividing by zero

 ;not sure what is happening but stopped working at 10pm
 print,'hold here'  &$
endfor;i
;I split this up for trouble shooting
;Now go though and do the unbiasing of the original files, month by month[i]
for i = 0, n_elements(mo)-1 do begin  &$
  files = file_search('all_products.bin.20{01,02,03,04,05,06,07,08,09,10,11,12}'+mo[i]+'*') &$
  for j = 0,n_elements(files)-1 do begin &$ 
    ; read all of the data (all days all bands) into data_in
    openr,1, files[j]  &$
    readu,1, buffer &$
    close,1 &$
    byteorder,buffer,/XDRTOF    &$
    ;I guess we want it to be upside-down
    buffer = reverse(buffer,2)   &$
    buffer(where(buffer gt 500.)) = 500. &$
    buffer(where(buffer lt 0.00)) = !values.f_nan &$
    
    buffer = (buffer+small*yrs/n_elements(files))*PON[*,*,i] &$ ; How to deal with 'small': see notes from 3/29
    
    ;switch back to match original rfe files (big endian) & match original rfe files (upsidedown)[but these are rightside up...]
    byteorder,buffer,/XDRTOF    &$
    buffer=reverse(buffer,2)   &$
    
    openw,1,strcompress(outdir+files[j], /remove_all) &$
    writeu,1,buffer &$
    close,1 &$
    print, 'writing ub '+files[j] &$
    
  endfor  &$;j
endfor ;i

print, 'hold here'
; end program
end


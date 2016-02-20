pro ubias_rfe2v2

; this script takes daily CPC RFE2 data (mm/day, 0.1 degree), finds the average monthly values in the time series (2001-2010)
; and calculates a scaling facotor using the FCLIMv4 monthly climatology (~60yrs) field. This factor is then applied
; to the original daily data yielding 'unbiased' RFE2 daily rainfall estimates.  

indir    = strcompress("/jabber/LIS/Data/CPCOriginalRFE2/",/remove_all)
fclimdir = strcompress("/jabber/LIS/Data/FCLIMv4_0.1_bin/", /remove_all)
outdir   = strcompress("/jabber/LIS/Data/ubRFE2_sonitest2/", /remove_all)

FILE_MKDIR,outdir

cd,indir

nx     = 751.
ny     = 801.
nbands = 1. 
small  = 10

buffer   = fltarr(nx,ny)
data_in  = fltarr(nx,ny)
PON      = fltarr(nx,ny)    


;get rid of envi header files
;file_delete,(file_search('*/*.hdr', /fold_case))

;loop throught month directories
for i=1,12 do begin

  mm    = STRING(FORMAT='(I2.2)',i)   ;two digit month
  files = file_search('*20??'+mm+'*') ;find all files from given month
  data_in = data_in*0                 ; initalizes array to zeros
  tmpout  = fltarr(nx,ny,n_elements(files))
  
  for j=0,n_elements(files)-1 do begin
    ; read all of the data (all hrs,all days) into data_in
    openr,1, files[j]
    readu,1, buffer
    close,1
    
    byteorder,buffer,/XDRTOF   ;change to little endian to match fclim
    buffer=reverse(buffer,2)   ;transpose to match fclim
    buffer(where(buffer lt 0.00)) = !values.f_nan
    tmpout(*,*,j)=buffer    ;changes 3hrly units to hrs, makes 3D array of all 3hrly maps

  endfor
    
  yrs     = 10
  totrain = total(tmpout,3,/NAN)
  data_in = totrain/yrs ;this is the stm for month i
  
  ;data_in= data_in/n_elements(yrs) ;average monthly total (short term mean) this doesn't work b/c of nans
   
  for j=0,n_elements(files)-1 do begin
    ; read all of the data (all days all bands) into data_in
    openr,3,files[j] ; still looking at only month i....
    readu,3,buffer
    close,3
    
    byteorder,buffer,/XDRTOF   ;change to little endian to match fclim
    buffer=reverse(buffer,2)   ;transpose to match fclim
    buffer(where(buffer lt 0.00)) = !values.f_nan
    
    PON=(buffer+small)/(data_in+small);this won't work becasue datain is the month and these are days....
    
    ;byteorder,PON,/XDRTOF   ;change to little endian to match fclim
   ; buffer=reverse(PON,2)   ;transpose to match fclim
    
    openr,2,strcompress(fclimdir+mm+'africa.bin', /remove_all)
    readu,2,buffer ;fclim
    close,2

    buffer= buffer*PON ;fclim with no small added and *PON
  
   ;is this working?
    openw,1,strcompress('/home/mcnally/PON'+mm+'.img', /remove_all)
    writeu,1,PON
    close, 1
  
      
    byteorder,buffer,/XDRTOF   ;switch back to match original trmm files (big endian)
    buffer=reverse(buffer,2)   ;switch back to match original trmm files (upsidedown)
    
    file_mkdir,strcompress(outdir+strmid(files[j],0,7), /remove_all)
    
    openw,4,strcompress(outdir+files[j], /remove_all)
    writeu,4,buffer
    close,4
    print, 'writing ub '+files[j]
    
  endfor;j
endfor;i

; end program
end


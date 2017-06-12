pro ubias_trmm

; this script takes three hourly TRMM-v6 data (mm/hr), finds the average monthly values in the time series (2000-2009)
; and calculates a scaling facotor using the FCLIMv4 monthly climatology (~60yrs) field. This factor is then applied
; to the original three hourly data yielding 'unbiased' TRMM v6 3hrly rainfall estimates.  

indir    = strcompress("/jabber/LIS/Data/TrmmAfr/",/remove_all)
fclimdir = strcompress("/jabber/LIS/Data/FCLIMv4_0.25_bin/", /remove_all)
outdir   = strcompress("/jabber/LIS/Data/ubTRMM-tester/", /remove_all)

FILE_MKDIR,outdir

cd,indir

nx     = 301.
ny     = 321.
nbands = 1. 
small  = 10

buffer   = fltarr(nx,ny)
data_in  = fltarr(nx,ny)
PON      = fltarr(nx,ny)    


;get rid of envi header files
;file_delete,(file_search('*/*.hdr', /fold_case))

;loop throught month directories
for i=1,12 do begin

  mm=STRING(FORMAT='(I2.2)',i)   ;two digit month
  files=file_search('*'+mm+'/*') ;find all files from given month
  data_in=data_in*0              ; initalizes array to zeros
  tmpout   = fltarr(nx,ny,n_elements(files))
  
  for j=0,n_elements(files)-1 do begin
    ; read all of the data (all hrs,all days) into data_in
    openr,1, files[j]
    readu,1, buffer
    close,1
    
    byteorder,buffer,/XDRTOF   ;change to little endian to match fclim
    buffer=reverse(buffer,2)   ;transpose to match fclim
    buffer(where(buffer lt 0.00)) = !values.f_nan
    tmpout(*,*,j)=buffer*3     ;changes 3hrly units to hrs, makes 3D array of all 3hrly maps

  endfor
    
  yrs     = n_elements(file_search('*'+mm))
  totrain = total(tmpout,3,/NAN)
  data_in = totrain/yrs
  
  ;data_in= data_in/n_elements(yrs) ;average monthly total (short term mean) this doesn't work b/c of nans
  
;    ;is this working?
;    openw,1,strcompress('/home/mcnally/dataout.img', /remove_all)
;    writeu,1,data_in
;    close, 1
  
  openr,2,strcompress(fclimdir+mm+'africa.bin', /remove_all)
  readu,2,buffer ;fclim
  close,2

  PON = buffer/(data_in+small) ;fclim/stm > Soni's correction 3/39
  
   ;is this working?
    openw,1,strcompress('/home/mcnally/PONt'+mm+'.img', /remove_all)
    writeu,1,PON
    close, 1
  

  for j=0,n_elements(files)-1 do begin
    ; read all of the data (all days all bands) into data_in
    openr,3,files[j]
    readu,3,buffer
    close,3
    
    byteorder,buffer,/XDRTOF   ;change to little endian to match fclim
    buffer=reverse(buffer,2)   ;transpose to match fclim
    buffer(where(buffer lt 0.00)) = !values.f_nan
    
    buffer=(buffer+small*yrs/n_elements(files))*PON ; How to deal with 'small': see notes from 3/29
    
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


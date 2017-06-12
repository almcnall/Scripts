pro arcview2binFCLIM
;this script was been used when adrew's files were in arc format..he switched to tiff
;see tiff_to_bin
;...to regrid fclimv4 to both 0.25 degree (301x321)
;used for e.g., for TRMMv6 unbiasing. This script was also used to rebin to 0.1 deg (751x801)
;used for e.g., for RFE2 unbiasing. 

wkdir= strcompress("/jabber/LIS/Data/FCLIMv4",/remove_all)
odir = strcompress("/jabber/LIS/Data/FCLIMv4_0.1_bin/", /remove_all)
cd, wkdir

file_mkdir, odir

filter  = '*.bil' 
infiles = file_search(filter)
regrid  = uintarr(751,801) 
ingrid  = uintarr(1379,1452) ; the .bil are unsigned integers 
fltgrid = fltarr(751,801)  ;the array where the converted data will go...

for i=0, n_elements(infiles)-1 do begin
  
  openr,1,infiles[i]            ;opens one file at a time   
  readu,1,ingrid              ;reads the file into ingrid
  close,1  
  
  regrid = congrid(ingrid, 301,321) ;regrids the 0.1 degree to 0.25
  fltgrid= float(regrid)
  ;fltgrid[WHERE(fltgrid lt 0.)] = !VALUES.F_NAN
  
  ofile   = strcompress(strmid(infiles[i],0,10)+'.img',/remove_all)
  outgrid = strcompress(odir+ofile,/remove_all)
  
  openw,2,outgrid
  writeu,2,fltgrid
  close,2
  
endfor

;
end

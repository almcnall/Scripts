PRO janfeb_AETannomWRSI

;this program averages the months of january and february for
; each year in the run. The result should be X files.

name  = 'Ubcmap'

wdir = strcompress("/gibber/lis_data/OUTPUT/UBwrsiaet/",/remove_all)
odir = strcompress("/gibber/lis_data/OUTPUT/UBwrsiaet/jfmalawi_evap_annom/"+name,/remove_all)
FILE_MKDIR,odir ;changed from avg to total 10/24

print,wdir
cd,wdir 

nx    = 31.
ny    = 77.
bands = 7. ;7 for malawi wrsi stack, 9 for exp0XX stacks

avgfile = fltarr(nx,ny) ;floats for the EXP data
;buffer = fltarr(nx,ny)   ;each jan and feb file for a yr
;datain = fltarr(nx,ny,bands)
;dataout= fltarr(nx,ny,bands)


;buffer = uintarr(nx,ny)   ;each jan and feb file for a yr
datain = uintarr(nx,ny,bands) ;integers for the WRSI
dataout= fltarr(nx,ny,bands)

;FOR yr = 2001, 2007 DO BEGIN
;   stack  = file_search(strcompress('Mal'+exp+'JFevap',/remove_all));finds all the files in a month for a particular variable
;   malmean= file_search(strcompress('AvgMal'+exp+'JFevap',/remove_all))
   
 stack  = file_search(strcompress('Mal'+name+'JFevap',/remove_all));finds all the files in a month for a particular variable
 malmean= file_search(strcompress('AvgMal'+name+'JFevap',/remove_all))
  
   openr,1,stack
   openr,2,malmean 
   readu,1,datain
   readu,2,avgfile   
  
  for i=0, bands-1 do begin
   for x=0,nx-1 do for y=0,ny-1 do begin ;take mean
    dataout[x,y,i] = datain[x,y,i]-avgfile[x,y]; eak, not sure which goes first?
   endfor ;the mean loop  
   dataout[WHERE(dataout eq 0.)] = !VALUES.F_NAN
   
   of1 = strcompress(odir+'/AnomMal'+name+'JFevap.img',/remove_all)
   openw,3,of1
   writeu,3,dataout
   
   close,/all
   print,"wrote " + of1 
   
   endfor ;bands
 end
   
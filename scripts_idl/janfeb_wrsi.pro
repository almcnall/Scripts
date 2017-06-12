PRO janfeb_wrsi

;this program averages the months of january and february for
; each year in the run. The result should be X files.

name  = 'TRMM'

wdir = strcompress("/gibber/lis_data/OUTPUT/BiasWRSI_from_Hari/"+name+"/binary",/remove_all)
odir = strcompress("/gibber/lis_data/OUTPUT/BiasWRSI_from_Hari/"+name+"/janfeb_mean/",/remove_all)
;wdir = strcompress("/gibber/lis_data/OUTPUT/wrsi"+name+"/binary",/remove_all)
;odir = strcompress("/gibber/lis_data/OUTPUT/wrsi"+name+"/janfeb_mean/",/remove_all)
FILE_MKDIR,odir ;changed from avg to total 10/24

print,wdir
cd,wdir 

nx    = 486
ny    = 390
bands = 2 ;for jan and feb for each year

buffer = fltarr(nx,ny)   ;each jan and feb file for a yr
datain = fltarr(nx,ny,2)
dataout= fltarr(nx,ny)

 FOR yr = 2001, 2007 DO BEGIN
   jan= file_search(strcompress('w'+string(yr)+'vr_e'+name+'01.img',/remove_all));finds all the files in a month for a particular variable
   feb= file_search(strcompress('w'+string(yr)+'fr_e'+name+'02.img',/remove_all))
  
   openr,1,jan
   openr,2,feb 
   readu,1,buffer
   datain[*,*,0]=buffer
   readu,2,buffer
   datain[*,*,1]=buffer
   
    
   for x=0,nx-1 do for y=0,ny-1 do begin ;take mean
    dataout[x,y] = mean(datain[x,y,*],/NAN);
   endfor ;the mean loop  
   
   of1 = strcompress(+odir+'wr'+string(yr)+name+'_janfeb.img',/remove_all)
   openw,3,of1
   writeu,3,dataout
   
   close,/all
   print,"wrote " + of1 
   
   endfor ;year
 end
   
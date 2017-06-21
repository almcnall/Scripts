PRO janfeb_mean

;this program averages the months of january and february for
; each year in the run. The result should be 8 files.

expdir = 'EXP025'
name  =  'rfe2'
;wdir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/TEMPLATE/rainmonthMal/",/remove_all)
;odir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/TEMPLATE/janfeb_meanMal/",/remove_all)

wdir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/month_total_units/",/remove_all)
odir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/janfeb_mean/",/remove_all)
FILE_MKDIR,odir ;changed from avg to total 10/24

print,wdir
cd,wdir 

nx    = 301.
ny    = 321.
bands = 2. ;for jan and feb for each year

vars = strarr(3); length = 9 ;change this when running lsm this is for the template runs
vars[0] = 'airtem'
vars[1] = 'evap'
;vars[0] = 'soilm1'
;vars[3] = 'soilm2' 
;vars[4] = 'soilm3'
vars[2] = 'rain' ;order doesn't matter since I am string matching
;vars[6]=  'soilm4' 
;vars[7] = 'runoff'
;vars[8] = 'lhtfl'

buffer = fltarr(nx,ny)   ;each jan and feb file for a yr
datain = fltarr(nx,ny,bands)
dataout= fltarr(nx,ny)

  FOR j =0, n_elements(vars)-1 DO BEGIN
   FOR yr = 2001, 2009 DO BEGIN
   jan= file_search(strcompress(+vars[j]+'_'+string(yr)+'01_tot.img',/remove_all));finds all the files in a month for a particular variable
   feb= file_search(strcompress(+vars[j]+'_'+string(yr)+'02_tot.img',/remove_all))
   ;jan= file_search(strcompress('evap_'+string(yr)+'01.img',/remove_all));finds all the files in a month for a particular variable
   ;feb= file_search(strcompress('evap_'+string(yr)+'02.img',/remove_all))
   
   openr,1,jan
   openr,2,feb 
   readu,1,buffer
   datain[*,*,0]=buffer
   readu,2,buffer
   datain[*,*,1]=buffer
   
    
   for x=0,nx-1 do for y=0,ny-1 do begin ;take mean
    ;if (vars[j] EQ 'runoff') then dataout[x,y] = mean((datain[x,y,*]*86400.0),/NAN);
   dataout[x,y] = mean(datain[x,y,*],/NAN);
   ;if (vars[i] EQ 'rain')   then buffer[x,y] = total((data_in[x,y,*]*86400.0), /NAN); converts rain to mm/month   
   endfor ;the mean loop  
   
   of1 = strcompress(+odir+vars[j]+string(yr)+'_janfeb.img',/remove_all)
   openw,3,of1
   writeu,3,dataout
   
   close,/all
   print,"wrote " + of1 
   
   endfor ;year
 endfor ;vars
 end
   
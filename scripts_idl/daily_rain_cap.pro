PRO daily_rain_cap

;this program caps rainfall at 0.01 kg/m2/day (864.00mm) to elimiate the outliers 
;in the cmap data that are impossible (0.3kg/m2/day). Problems with cmap seem to be
;mostly in 11/2007. Problems with 2007 were discovered by Hari when tring to use the unbiased
;cmap data to run wrsi. 
;I chose 0.01 becasue it is still higher than the max fclim and close to the max rfe2.
;This may be reconsidered in the future...AM 11/21/2010

expdir = 'EXP015' 
name = 'cmap'

FILE_MKDIR, strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/TEMPLATE/daily_cap",/remove_all)
odir  = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/TEMPLATE/daily_cap",/remove_all)
indir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/TEMPLATE/daily",/remove_all)

print,indir
cd,indir 

files = file_search('*img') ;all the .img files in the daily dir (ignore .hdr)
nx    = 301. 
ny    = 321.

;initialize arrays

;capped   = fltarr(nx,ny)

for i=0, n_elements(files)-1 do begin
  cd, indir
  buffer = fltarr(nx,ny)
  openu,1,files[i]
  readu,1,buffer
  
  ;buffer([where(buffer gt 0.10)] = 0.10, /NAN) 
  ;where do I have nans and then where are these bad values
  ;good = 0
  ;bad  = 0
  nan   = 0
  other = 0
  count = 0
  ;nan  = WHERE(finite(buffer,/NAN),complement=other) ;these are the indices where there are nan's, other are the good/bads 96621
  index=where(buffer gt 0.01, count)
  if count ne 0 then buffer[index]= !VALUES.F_NAN 
  
  ofile = strcompress(+odir+'/'+files[i], /remove_all)
  print, ofile
  cd, odir
  openw,2,ofile
  writeu,2,buffer
 
 print, 'writing capped '+files[i] 
 close, /all

endfor

end
 
pro month_avg_malawi
;

;name   = 'RFE2_UMDVeg'
;expdir = 'EXPORU'

;name   = 'RFE2_StaticRoot'
;expdir = 'EXPORS'

;name   = 'RFE2_DynCrop'
;expdir = 'EXPORC'
;
;name   = 'RFE2Unbiased_DynCrop' ;these runs were bad 4/12...double check rainfall formats
;expdir = 'EXPURC'

;name   = 'RFE2Unbiased_UMDVeg'
;expdir = 'EXPURU'

wdir = strcompress("/gibber/lis_data/"+name+"/output/"+expdir+"/NOAH32/daily",/remove_all)
odir = strcompress("/gibber/lis_data/"+name+"/output/"+expdir+"/NOAH32/month_total_units/",/remove_all)

FILE_MKDIR,odir ;changed from avg to total 10/24

print,wdir
cd,wdir 

vars = strarr(9); length = 9
vars= ['rain','evap','root','sm01','sm02','sm03','sm04','tair','PoET']   

nx = 31.
ny = 77.

dates=strarr(108) ;12*9
count = 0 ; initialize counter
mask=bytarr(nx,ny)
fltmask=fltarr(nx,ny)
;
;do I need the lake mask too? yes. 
mal_mask=strcompress("/gibber/lis_data/shp/southmalawi_mask", /remove_all)
openr,1,mal_mask
readu,1,mask
fltmask=float(mask)
index  = WHERE(fltmask eq 0) ;change zeros to nans
fltmask[index]= !VALUES.F_NAN
print, fltmask
close,1

;this creates file names for all the months....or does this just count them??
FOR yr = 2001, 2008 DO BEGIN  
  FOR m = 1,12 DO BEGIN
    IF (yr EQ 2008) AND (m EQ 5) THEN BREAK ;exp02X runs end 2007/05
    filename=STRCOMPRESS(STRING(yr)+STRING(FORMAT='(I2.2)',m), /REMOVE_ALL) ;two digit day
    dates(count)=filename  
    print, count
    count = (count+1)
  ENDFOR
print, dates
ENDFOR


FOR i = 0, n_elements(vars)-1 DO BEGIN

   FOR j = 0,count-1  DO BEGIN 
     files = file_search(vars[i]+'_'+dates[j]+'*.img') ;finds all the files in a month for a particular variable
     print, files    
     nbands = float(n_elements(files)) ;how every many days are in a particular month
     buffer = fltarr(nx,ny)
     data_in = fltarr(nx,ny,nbands); data_in is an array...a map with a full month of values

 ;Since I have to average and total data below I have to change the NaNs to -999, 
 ;then change back to NaN for spatial averaging in envi that I do later.   
   
      FOR k = 0, nbands-1 do begin ; for each day
           ; open up file and read unformatted into 'data_in'
           openr,lun,files[k],/get_lun
           readu,lun,buffer
           data_in[*,*,k] = buffer*fltmask ;open up all the files, multiply by mask in a month and read into data_in
         close,/ALL
      endfor ; end k
      
   
     of1 = strcompress(+odir+vars[i]+"_"+dates[j]+ "_tot.img",/remove_all)
      openw,lun,of1, /get_lun

      for x=0,nx-1 do for y=0,ny-1 do begin ;convert units
         
        if (vars[i] EQ 'tair') then buffer[x,y] = mean((data_in[x,y,*]-273.15), /NAN)   ;use this to covert kg*m-2*s-1 to mm/day
        if (vars[i] EQ 'rain') then buffer[x,y] = total((data_in[x,y,*]*86400.0))   ;converts rain from mm/sec to mm/month
        if (vars[i] EQ 'root') then buffer[x,y] = total((data_in[x,y,*]*86400.0)) 
        if (vars[i] EQ 'sm01')  then buffer[x,y] = total((data_in[x,y,*])); kg/m2 (not a flux!)
        if (vars[i] EQ 'sm02')  then buffer[x,y] = total((data_in[x,y,*]))
        if (vars[i] EQ 'sm03')  then buffer[x,y] = total((data_in[x,y,*]))
        if (vars[i] EQ 'sm04')  then buffer[x,y] = total((data_in[x,y,*]))
        if (vars[i] EQ 'evap') then buffer[x,y] = total((data_in[x,y,*]*86400.0))
        if (vars[i] EQ 'PoET') then buffer[x,y] = total((data_in[x,y,*]*86400.0)) 
     endfor ;end x and y:
     
   writeu,lun,buffer
   close,/ALL
   print,"wrote " + of1
endfor; end j
endfor ;end  i

close, 1
;end program
end 

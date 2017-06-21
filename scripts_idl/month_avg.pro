pro month_avg
; fixed the script 9/28/10
expdir = 'EXP028' ;this is unbias rfe2

wdir = wdir = strcompress("/gibber/lis_data/"+name+"/output/"+expdir+"/NOAH32/daily",/remove_all)
odir = wdir = strcompress("/gibber/lis_data/"+name+"/output/"+expdir+"/NOAH32/month_total_units/",/remove_all)

FILE_MKDIR,odir ;changed from avg to total 10/24

print,wdir
cd,wdir 

vars = strarr(9); length = 9
vars= ['rain','evap','root','sm01','sm02','sm03','sm04','tair','PoET']   

nx     = 31.
ny     = 77.

dates=strarr(108) ;12*9
count = 0 ; initialize counter
;mask=fltarr(nx,ny)
;
;afrlake_mask=strcompress("/gibber/lis_data/OUTPUT/afrlake_mask.img", /remove_all)
;openr,1,afrlake_mask
;readu,1,mask

;this creates file names for all the months....or does this just count them??
FOR yr = 2001, 2009 DO BEGIN  
  FOR m = 1,12 DO BEGIN
    IF (yr EQ 2002) AND (m lt 9) THEN CONTINUE ; exp027 runs from 09/01/02-5/1/07
    IF (yr EQ 2007) AND (m EQ 5) THEN BREAK ;exp02X runs end 2007/05
    filename=STRCOMPRESS(STRING(yr)+STRING(FORMAT='(I2.2)',m), /REMOVE_ALL) ;two digit day
    dates(count)=filename  
    print, count
    count = (count+1)
  ENDFOR
print, dates
ENDFOR

;FILE_MKDIR, strcompress("/jabber/LIS/Data/OUTPUT/"+expdir+"/NOAH/month_avg_units/",/remove_all)

FOR i = 0, n_elements(vars)-1 DO BEGIN
   FOR j = 0,count-1  DO BEGIN 
     files = file_search(vars[i]+'_'+dates[j]+'*.img') ;finds all the files in a month for a particular variable
      print, files     
       nx     = 301.
       ny     = 321.
       nbands = float(n_elements(files)) ;how every many days are in a particular month

       buffer   = fltarr(nx,ny)

       data_in  = fltarr(nx,ny,nbands); data_in is an array...a map with a full month of values

 ;Since I have to average and total data below I have to change the NaNs to -999, 
 ;then change back to NaN for spatial averaging in envi that I do later.   
   
      FOR k = 0, nbands-1 do begin ; for each day
           ; open up file and read unformatted into 'data_in'
           openr,lun,files[k],/get_lun
           readu,lun,buffer
           index  = WHERE(finite(buffer,/NAN),complement=other) ;these are the indices where there are nan's, other are the goods
           buffer[index]= -999.
           data_in[*,*,k] = buffer ;open up all the files, multiply by mask in a month and read into data_in
         close,/ALL
      endfor ; end k
   
     of1 = strcompress(+odir+vars[i]+"_"+dates[j]+ "_tot.img",/remove_all) ;names the output file
     openw,lun,of1, /get_lun ;opens the out file

      for x=0,nx-1 do for y=0,ny-1 do begin ;convert units
         
        if (vars[i] EQ 'airtem') then buffer[x,y] = mean((data_in[x,y,*]-273.15),   /NAN)   ;use this to covert kg*m-2*s-1 to mm/day
        if (vars[i] EQ 'rain')   then buffer[x,y] = total((data_in[x,y,*]*86400.0), /NAN)   ;converts rain from mm/sec to mm/month
        if (vars[i] EQ 'runoff') then buffer[x,y] = total((data_in[x,y,*]*86400.0), /NAN) 
        if (vars[i] EQ 'Qsub')   then buffer[x,y] = total((data_in[x,y,*]*86400.0), /NAN)
        if (vars[i] EQ 'evap')   then buffer[x,y] = total((data_in[x,y,*]*86400.0), /NAN)
        if (vars[i] EQ 'PoET')   then buffer[x,y] = mean((data_in[x,y,*]*86400.0), /NAN) 
     endfor ;end x and y:
     
     index  = WHERE(buffer le -999) ;these are the indices where the crazy negative numbers are
     buffer[index]= !VALUES.F_NAN

   writeu,lun,buffer ;writes the outfile
   close,/ALL
   print,"wrote " + of1
endfor; end j
endfor ;end  i

close, 1
;end program
end 

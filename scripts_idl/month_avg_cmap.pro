pro month_avg
;not a real script yet

wdir = strcompress("/jabber/LIS/Data/CPCOriginalRFE2",/remove_all)
odir =strcompress("/jabber/LIS/Data/CPCOriginalRFE2/month_total_units/",/remove_all)

FILE_MKDIR,odir ;

print,wdir
cd,wdir 

nx = 301.
ny = 321.

yrs    = ['00','01', '02', '03', '04', '05', '06', '07', '08', '09','10']
months = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11','12' ]

dates=strarr(120) ;12*10
files = file_search('all_products.bin.*') ;finds all the files in a month for a particular variable

for i=0, n_elements(files)-1 do begin
  FOR j = 0, n_elements(yrs)-1 DO BEGIN
     FOR k = 0,n_elements(months)-1 DO BEGIN 
   ;put all the days in a month into an array
   openu,1,files[ 
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
   
     of1 = strcompress(+odir+vars[i]+"_"+dates[j]+ "_tot.img",/remove_all)
      openw,lun,of1, /get_lun

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

   writeu,lun,buffer
   close,/ALL
   print,"wrote " + of1
endfor; end j
endfor ;end  i

close, 1
;end program
end 

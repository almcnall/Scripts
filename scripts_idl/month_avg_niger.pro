pro month_avg_niger
;the purpose of this program is to aggregate daily totals to monthly totals/averages. This script is modified from the month_avg_niger script
;that was writen 4/9/11. It will have to be adjusted for the west africa domain that I chose and the outputs that I selected. I guess I need
;to fix this. Right now the outputs are: 
;snowf,rainf,evap,Qsb (subsurface flow), AirSurfT, albedo, swe,snow depth,snowcover,soilmoist,soiltemp,canopInt, wind_f (wind forcing)
;rainf_f, Tair_f,Qair_f,Psurf_f,SWdown_f,LWdown_f 
;I'll look at rain, evap, Qs (surface flow), Qsub (subsurface flow), soil moisture (x4 layers), Tair, Qair (humidity? units?)

;name   = 'RFE2Unbiased_UMDVeg'
expdir = 'EXPA02'

wdir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/daily",/remove_all)
odir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/month_total_units/",/remove_all)

FILE_MKDIR,odir ;changed from avg to total 10/24

print,wdir
cd,wdir 

vars = strarr(19); length = 9
vars= ['evap','sm01' ,'sm02', 'sm03','sm04', 'Qsuf','Qsub', 'rain','tair', $
       'Qair','Qlhf','Swet','PoET','Tveg','Esol','Rsmc','Evfr','Bown','Qshf']   

nx = 720.
ny = 350.
;nbands = 37.
dates=strarr(60) ;12*5
count = 0 ; initialize counter

;this creates file names for all the months....or does this just count them??
FOR yr = 2004, 2008 DO BEGIN  
  FOR m = 1,12 DO BEGIN
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
      if  (vars[i]  EQ  'evap')  then  buffer[x,y] = total((data_in[x,y,*]*86400.0))
      if  (vars[i]  EQ  'sm01')  then  buffer[x,y] = mean((data_in[x,y,*])); maybe divide by 10
      if  (vars[i]  EQ  'sm02')  then  buffer[x,y] = mean((data_in[x,y,*])); divide by 30
      if  (vars[i]  EQ  'sm03')  then  buffer[x,y] = mean((data_in[x,y,*])); divide by 60
      if  (vars[i]  EQ  'sm04')  then  buffer[x,y] = mean((data_in[x,y,*])) ;divide by 100, or average point measures over depth...
      if  (vars[i]  EQ  'Qsuf')  then  buffer[x,y] = total((data_in[x,y,*]))
      if  (vars[i]  EQ  'Qsub')  then  buffer[x,y] = total((data_in[x,y,*]))
      if  (vars[i]  EQ  'rain')  then  buffer[x,y] = total((data_in[x,y,*]*86400.0))
      if  (vars[i]  EQ  'tair')  then  buffer[x,y] = total((data_in[x,y,*]-273.15), /NAN)
      if  (vars[i]  EQ  'Qair')  then  buffer[x,y] = total((data_in[x,y,*]))
      if  (vars[i]  EQ  'Qlhf')  then  buffer[x,y] = total((data_in[x,y,*]))
      if  (vars[i]  EQ  'Swet')  then  buffer[x,y] = total((data_in[x,y,*]))
      if  (vars[i]  EQ  'PoET')  then  buffer[x,y] = total((data_in[x,y,*]*86400.0));this gives huge monthly valuwa...
      if  (vars[i]  EQ  'Tveg')  then  buffer[x,y] = total((data_in[x,y,*]))
      if  (vars[i]  EQ  'Esol')  then  buffer[x,y] = total((data_in[x,y,*]))
      if  (vars[i]  EQ  'Rsmc')  then  buffer[x,y] = total((data_in[x,y,*]))
      if  (vars[i]  EQ  'Evfr')  then  buffer[x,y] = total((data_in[x,y,*]))
      if  (vars[i]  EQ  'Bown')  then  buffer[x,y] = total((data_in[x,y,*]))
      if  (vars[i]  EQ  'Qshf')  then  buffer[x,y] = total((data_in[x,y,*]))
         
;        if (vars[i] EQ 'tair') then buffer[x,y] = mean((data_in[x,y,*]-273.15), /NAN)   ;use this to covert kg*m-2*s-1 to mm/day
;        if (vars[i] EQ 'rain') then buffer[x,y] = total((data_in[x,y,*]*86400.0))   ;converts rain from mm/sec to mm/month
;        if (vars[i] EQ 'root') then buffer[x,y] = total((data_in[x,y,*]*86400.0)) 
;        if (vars[i] EQ 'sm01')  then buffer[x,y] = total((data_in[x,y,*])); kg/m2 (not a flux!)
;        if (vars[i] EQ 'sm02')  then buffer[x,y] = total((data_in[x,y,*]))
;        if (vars[i] EQ 'sm03')  then buffer[x,y] = total((data_in[x,y,*]))
;        if (vars[i] EQ 'sm04')  then buffer[x,y] = total((data_in[x,y,*]))
;        if (vars[i] EQ 'evap') then buffer[x,y] = total((data_in[x,y,*]*86400.0))
;        if (vars[i] EQ 'PoET') then buffer[x,y] = total((data_in[x,y,*]*86400.0)) 
     endfor ;end x and y:
     
   writeu,lun,buffer
   close,/ALL
   print,"wrote " + of1
endfor; end j
endfor ;end  i

close, 1
;end program
end 

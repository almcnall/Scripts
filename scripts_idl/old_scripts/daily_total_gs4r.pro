pro daily_total_gs4r,year,date

flip_AF_gs4r,date,year

close,/ALL

wdir = strcompress("/jower/LIS/Code/src/OUTPUT/Zoundsb/NOAH/"+year+"/"+date+"/deyuk/",/remove_all)
print,wdir
cd,wdir 

files = file_search('*gs4r')
; flip direction
direction = 2

nfiles = n_elements(files)

nx     = 301.
ny     = 321.
nbands = 31.

buffer   = fltarr(nx,ny,nbands)

data_in  = fltarr(nx,ny,nbands,nfiles)

for i=0,n_elements(files)-1 do begin
  ; open up file and read unformatted into 'data_in'
  openr,lun,files[i],/get_lun
  readu,lun,buffer
  byteorder,buffer,/XDRTOF
  data_in[*,*,*,i] = buffer
end

data_in[where(data_in lt -9998)] = !VALUES.F_NAN

of1 = strcompress("/jower/LIS/Code/src/OUTPUT/Zoundsb/NOAH/daily/lhtfl_" +date+".img",/remove_all)
of2 = strcompress("/jower/LIS/Code/src/OUTPUT/Zoundsb/NOAH/daily/rain_"  +date+".img",/remove_all)
of3 = strcompress("/jower/LIS/Code/src/OUTPUT/Zoundsb/NOAH/daily/evap_"  +date+".img",/remove_all)
of4 = strcompress("/jower/LIS/Code/src/OUTPUT/Zoundsb/NOAH/daily/runoff_"+date+".img",/remove_all)
of5 = strcompress("/jower/LIS/Code/src/OUTPUT/Zoundsb/NOAH/daily/soilm1_"+date+".img",/remove_all)
of6 = strcompress("/jower/LIS/Code/src/OUTPUT/Zoundsb/NOAH/daily/soilm2_"+date+".img",/remove_all)
of7 = strcompress("/jower/LIS/Code/src/OUTPUT/Zoundsb/NOAH/daily/soilm3_"+date+".img",/remove_all)
of8 = strcompress("/jower/LIS/Code/src/OUTPUT/Zoundsb/NOAH/daily/soilm4_"+date+".img",/remove_all)
of9 = strcompress("/jower/LIS/Code/src/OUTPUT/Zoundsb/NOAH/daily/airtem_"+date+".img",/remove_all)

close,/ALL

openw,1,of1
openw,2,of2
openw,3,of3
openw,4,of4
openw,5,of5
openw,6,of6
openw,7,of7
openw,8,of8
openw,9,of9

lhtfl  = fltarr(nx,ny)
rain   = fltarr(nx,ny)
evap   = fltarr(nx,ny)
runoff = fltarr(nx,ny)
soilm1 = fltarr(nx,ny)
soilm2 = fltarr(nx,ny)
soilm3 = fltarr(nx,ny)
soilm4 = fltarr(nx,ny)
airtem = fltarr(nx,ny)

for x=0,nx-1 do for y=0,ny-1 do begin

   lhtfl[x,y]  = mean(data_in[x,y,2, *],/NAN) 
   rain[x,y]   = mean(data_in[x,y,6, *],/NAN)  
   evap[x,y]   = mean(data_in[x,y,7, *],/NAN)   
   runoff[x,y] = mean(data_in[x,y,8, *],/NAN) 
   soilm1[x,y] = mean(data_in[x,y,15,*],/NAN) 
   soilm2[x,y] = mean(data_in[x,y,16,*],/NAN) 
   soilm3[x,y] = mean(data_in[x,y,17,*],/NAN) 
   soilm4[x,y] = mean(data_in[x,y,18,*],/NAN) 
   airtem[x,y] = mean(data_in[x,y,26,*],/NAN) 

end

writeu,1,lhtfl
writeu,2,rain
writeu,3,evap
writeu,4,runoff
writeu,5,soilm1
writeu,6,soilm2
writeu,7,soilm3
writeu,8,soilm4
writeu,9,airtem

print,"wrote " + of1
print,"wrote " + of2
print,"wrote " + of3
print,"wrote " + of4
print,"wrote " + of5
print,"wrote " + of6
print,"wrote " + of7
print,"wrote " + of8

; end program
end

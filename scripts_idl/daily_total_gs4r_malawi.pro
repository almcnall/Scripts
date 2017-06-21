pro daily_total_gs4r_malawi,year,date

;this program calls 'flip..' which removes the header and rotates the image. Instead of a loop
;it calls the file run_daily_total which has a list of the year and date arguments that are needed
; as input both here and 'flip_'. That list is created with /source/mcnally/scripts_bash/run_daily_list.sh (4/9/11?)

flip_AF_gs4r_malawi,date,year 

;name   = 'RFE2_UMDVeg'
;expdir = 'EXPORU'

;name   = 'RFE2_StaticRoot'
;expdir = 'EXPORS'

;name   = 'RFE2_DynCrop'
;expdir = 'EXPORC'

;name   = 'RFE2Unbiased_DynCrop'
;expdir = 'EXPURC'

name   = 'RFE2Unbiased_UMDVeg'
expdir = 'EXPURU'


close,/ALL

wdir = strcompress("/gibber/lis_data/"+name+"/output/"+expdir+"/NOAH32/"+year+"/"+date+"/deyuk/",/remove_all)
;FILE_MKDIR,wdir

cd,wdir 

files = file_search('*gs4r')
; flip direction
direction = 2

nfiles = n_elements(files)

nx     = 31.
ny     = 77.
nbands = 9 ; 9 for soni's runs soilx4, ETx2, root, airtemp,rain

buffer   = fltarr(nx,ny,nbands)
data_in  = fltarr(nx,ny,nbands,nfiles)

for i=0,n_elements(files)-1 do begin
  ; read all of the data (all days all bands) into data_in
  openr,lun,files[i],/get_lun
  readu,lun,buffer
  byteorder,buffer,/XDRTOF
  data_in[*,*,*,i] = buffer
end

day_file=strcompress("/gibber/lis_data/"+name+"/output/"+expdir+"/NOAH32/daily")
FILE_MKDIR,day_file
;cd, day_file

data_in[where(data_in lt -9998)] = !VALUES.F_NAN


of1 = strcompress("/gibber/lis_data/"+name+"/output/"+expdir+"/NOAH32/daily/evap_" +date+".img",/remove_all)
of2 = strcompress("/gibber/lis_data/"+name+"/output/"+expdir+"/NOAH32/daily/sm01_" +date+".img",/remove_all)
of3 = strcompress("/gibber/lis_data/"+name+"/output/"+expdir+"/NOAH32/daily/sm02_" +date+".img",/remove_all)
of4 = strcompress("/gibber/lis_data/"+name+"/output/"+expdir+"/NOAH32/daily/sm03_" +date+".img",/remove_all)
of5 = strcompress("/gibber/lis_data/"+name+"/output/"+expdir+"/NOAH32/daily/sm04_" +date+".img",/remove_all)
of6 = strcompress("/gibber/lis_data/"+name+"/output/"+expdir+"/NOAH32/daily/PoET_" +date+".img",/remove_all)
of7 = strcompress("/gibber/lis_data/"+name+"/output/"+expdir+"/NOAH32/daily/root_" +date+".img",/remove_all)
of8 = strcompress("/gibber/lis_data/"+name+"/output/"+expdir+"/NOAH32/daily/rain_" +date+".img",/remove_all)
of9 = strcompress("/gibber/lis_data/"+name+"/output/"+expdir+"/NOAH32/daily/tair_" +date+".img",/remove_all)

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
;openw,1,of1

;initalize arrays
rain   = fltarr(nx,ny)
evap   = fltarr(nx,ny)
root   = fltarr(nx,ny)
sm01   = fltarr(nx,ny)
sm02   = fltarr(nx,ny)
sm03   = fltarr(nx,ny)
sm04   = fltarr(nx,ny)
tair   = fltarr(nx,ny)
PoET   = fltarr(nx,ny)

for x=0,nx-1 do for y=0,ny-1 do begin
;pull out the band that corrosponds with a spp variable from each 3hrly file
;
   evap[x,y] = mean(data_in[x,y,0,*],/NAN) ;average rate of the day...  
   sm01[x,y] = mean(data_in[x,y,1,*],/NAN) 
   sm02[x,y] = mean(data_in[x,y,2,*],/NAN) 
   sm03[x,y] = mean(data_in[x,y,3,*],/NAN) 
   sm04[x,y] = mean(data_in[x,y,4,*],/NAN) 
   PoET[x,y] = mean(data_in[x,y,5,*],/NAN); now we are dealing with daily, rather than 3hrly data.
   root[x,y] = mean(data_in[x,y,6,*],/NAN) 
   rain[x,y] = mean(data_in[x,y,7,*],/NAN) ;check variable index in NOAHstats.d01.stats
   tair[x,y] = mean(data_in[x,y,8,*],/NAN) 
    

end

writeu,1,evap
writeu,2,sm01
writeu,3,sm02
writeu,4,sm03
writeu,5,sm04
writeu,6,PoET
writeu,7,root
writeu,8,rain
writeu,9,tair

print,"wrote " + of1
print,"wrote " + of2
print,"wrote " + of3
print,"wrote " + of4
print,"wrote " + of5
print,"wrote " + of6
print,"wrote " + of7
print,"wrote " + of8
print,"wrote " + of9

; end program
end

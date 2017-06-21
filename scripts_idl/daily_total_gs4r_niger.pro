pro daily_total_gs4r_niger,year,date,expdir,nx,ny,nbands

;this program calls 'flip..' which removes the header and rotates the image. Instead of a loop
;it calls the file run_daily_total which has a list of the year and date arguments that are needed
; as input both here and 'flip_'. That list is created with /source/mcnally/scripts_bash/run_daily_list.sh (4/9/11?)
;modified on 9/6/11 for the west africa amma runs.

;12/1/2011: updated to include almost all of the outputs - it turns out that I did need thoes rad terms, thanks laura!

flip_AF_gs4r_niger,date,year,expdir,nx,ny,nbands

;expdir = 'EXPA02'

close,/ALL

wdir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/"+year+"/"+date+"/deyuk/",/remove_all)
FILE_MKDIR,wdir

cd,wdir 

files = file_search('*gs4r')
; flip direction
direction = 2

nfiles = n_elements(files)

;nx     = 720.
;ny     = 350.
;nbands = 37.  9 soilx4, Qsub, Qsurf, Qait, airtemp,rain, eavp

buffer   = fltarr(nx,ny,nbands)
data_in  = fltarr(nx,ny,nbands,nfiles)

for i=0,n_elements(files)-1 do begin
  ; read all of the data (all days all bands) into data_in
  openr,lun,files[i],/get_lun
  readu,lun,buffer
  byteorder,buffer,/XDRTOF
  data_in[*,*,*,i] = buffer
end

day_file=strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/daily/", /remove_all)
FILE_MKDIR,day_file
;cd, day_file

data_in[where(data_in lt -9998)] = !VALUES.F_NAN

of1 = strcompress(day_file+"evap_" +date+".img",/remove_all)
of2 = strcompress(day_file+"sm01_" +date+".img",/remove_all)
of3 = strcompress(day_file+"sm02_" +date+".img",/remove_all)
of4 = strcompress(day_file+"sm03_" +date+".img",/remove_all)
of5 = strcompress(day_file+"sm04_" +date+".img",/remove_all)
of6 = strcompress(day_file+"Qsub_" +date+".img",/remove_all)
of7 = strcompress(day_file+"Qsuf_" +date+".img",/remove_all)
of8 = strcompress(day_file+"rain_" +date+".img",/remove_all)
of9 = strcompress(day_file+"tair_" +date+".img",/remove_all)
of10 = strcompress(day_file+"Qair_" +date+".img",/remove_all)
of11 = strcompress(day_file+"Qlhf_" +date+".img",/remove_all)
of12 = strcompress(day_file+"Swet_" +date+".img",/remove_all)
of13 = strcompress(day_file+"PoET_" +date+".img",/remove_all)
of14 = strcompress(day_file+"TVeg_" +date+".img",/remove_all)
of15 = strcompress(day_file+"ESol_" +date+".img",/remove_all)
of16 = strcompress(day_file+"Rsmc_" +date+".img",/remove_all)
of17 = strcompress(day_file+"Evfr_" +date+".img",/remove_all)
of18 = strcompress(day_file+"Bown_" +date+".img",/remove_all)
of19 = strcompress(day_file+"Qshf_" +date+".img",/remove_all)
of20 = strcompress(day_file+"SWnt_" +date+".img",/remove_all)
of21 = strcompress(day_file+"LWnt_" +date+".img",/remove_all)
of22 = strcompress(day_file+"Ghfl_" +date+".img",/remove_all)
of23 = strcompress(day_file+"surT_" +date+".img",/remove_all)
of24 = strcompress(day_file+"albd_" +date+".img",/remove_all)
of25 = strcompress(day_file+"st01_" +date+".img",/remove_all)
of26 = strcompress(day_file+"st02_" +date+".img",/remove_all)
of27 = strcompress(day_file+"st03_" +date+".img",/remove_all)
of28 = strcompress(day_file+"st04_" +date+".img",/remove_all)
of29 = strcompress(day_file+"pres_" +date+".img",/remove_all)
of30 = strcompress(day_file+"SWin_" +date+".img",/remove_all)
of31 = strcompress(day_file+"LWin_" +date+".img",/remove_all)

;old version
;of9 = strcompress("/gibber/lis_data/"+name+"/output/"+expdir+"/NOAH32/daily/tair_" +date+".img",/remove_all)
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
openw,10,of10
openw,11,of11
openw,12,of12
openw,13,of13
openw,14,of14
openw,15,of15
openw,16,of16
openw,17,of17
openw,18,of18
openw,19,of19
openw,20,of20
openw,21,of21
openw,22,of22
openw,23,of23
openw,24,of24
openw,25,of25
openw,26,of26
openw,27,of27
openw,28,of28
openw,29,of29
openw,30,of30
openw,31,of31
;initalize arrays
rain   = fltarr(nx,ny)
evap   = fltarr(nx,ny)
Qsub   = fltarr(nx,ny)
sm01   = fltarr(nx,ny)
sm02   = fltarr(nx,ny)
sm03   = fltarr(nx,ny)
sm04   = fltarr(nx,ny)
tair   = fltarr(nx,ny)
Qsuf   = fltarr(nx,ny)
Qair   = fltarr(nx,ny)
Qlhf   = fltarr(nx,ny)
Swet   = fltarr(nx,ny)
PoET   = fltarr(nx,ny)
TVeg   = fltarr(nx,ny)
ESol   = fltarr(nx,ny)
Rsmc   = fltarr(nx,ny)
Evfr   = fltarr(nx,ny)
Bown   = fltarr(nx,ny)
Qshf   = fltarr(nx,ny)
SWnt= fltarr(nx,ny)
LWnt= fltarr(nx,ny)
Ghfl= fltarr(nx,ny)
surT= fltarr(nx,ny)
albd= fltarr(nx,ny)
st01= fltarr(nx,ny)
st02= fltarr(nx,ny)
st03= fltarr(nx,ny)
st04= fltarr(nx,ny)
pres= fltarr(nx,ny)
Swin= fltarr(nx,ny)
Lwin= fltarr(nx,ny)


for x=0,nx-1 do for y=0,ny-1 do begin
;pull out the band that corrosponds with a spp variable from each 3hrly file
;check variable index in NOAHstats.d01.stats and find average rate of the day...
   evap[x,y] = mean(data_in[x,y,6,*],/NAN)   
   sm01[x,y] = mean(data_in[x,y,11,*],/NAN) 
   sm02[x,y] = mean(data_in[x,y,12,*],/NAN) 
   sm03[x,y] = mean(data_in[x,y,13,*],/NAN) 
   sm04[x,y] = mean(data_in[x,y,14,*],/NAN) 
   Qsuf[x,y] = mean(data_in[x,y,7,*],/NAN)
   Qsub[x,y] = mean(data_in[x,y,8,*],/NAN) 
   rain[x,y] = mean(data_in[x,y,5,*],/NAN)
   tair[x,y] = mean(data_in[x,y,27,*],/NAN) 
   Qair[x,y] = mean(data_in[x,y,28,*],/NAN) 
   Qlhf[x,y] = mean(data_in[x,y,2,*],/NAN)   
   Swet[x,y] = mean(data_in[x,y,19,*],/NAN)    
   PoET[x,y] = mean(data_in[x,y,20,*],/NAN)   
   TVeg[x,y] = mean(data_in[x,y,22,*],/NAN)    
   ESol[x,y] = mean(data_in[x,y,23,*],/NAN)   
   Rsmc[x,y] = mean(data_in[x,y,32,*],/NAN)   
   Evfr[x,y] = mean(data_in[x,y,36,*],/NAN)    
   Bown[x,y] = mean(data_in[x,y,35,*],/NAN)   
   Qshf[x,y] = mean(data_in[x,y,3,*],/NAN)    
SWnt[x,y] = mean(data_in[x,y,0,*],/NAN) 
LWnt[x,y] = mean(data_in[x,y,1,*],/NAN) 
Ghfl[x,y] = mean(data_in[x,y,4,*],/NAN) 
surT[x,y] = mean(data_in[x,y,9,*],/NAN) 
albd[x,y] = mean(data_in[x,y,10,*],/NAN) 
st01[x,y] = mean(data_in[x,y,15,*],/NAN) 
st02[x,y] = mean(data_in[x,y,16,*],/NAN) 
st03[x,y] = mean(data_in[x,y,17,*],/NAN) 
st04[x,y] = mean(data_in[x,y,18,*],/NAN) 
pres[x,y] = mean(data_in[x,y,29,*],/NAN) 
Swin[x,y] = mean(data_in[x,y,30,*],/NAN) 
Lwin[x,y] = mean(data_in[x,y,31,*],/NAN) 

end

writeu,1,evap
writeu,2,sm01
writeu,3,sm02
writeu,4,sm03
writeu,5,sm04
writeu,6,Qsuf
writeu,7,Qsub
writeu,8,rain
writeu,9,tair
writeu,10,Qair
writeu,11,Qlhf   
writeu,12,Swet   
writeu,13,PoET   
writeu,14,TVeg   
writeu,15,ESol   
writeu,16,Rsmc   
writeu,17,Evfr   
writeu,18,Bown   
writeu,19,Qshf 
writeu,20,SWnt
writeu,21,LWnt
writeu,22,Ghfl
writeu,23,surT
writeu,24,albd
writeu,25,st01
writeu,26,st02
writeu,27,st03
writeu,28,st04
writeu,29,pres
writeu,30,Swin
writeu,31,Lwin
  
print,"wrote " + of20
print,"wrote " + of21
print,"wrote " + of22
print,"wrote " + of23
print,"wrote " + of24
print,"wrote " + of25
print,"wrote " + of26
print,"wrote " + of27
print,"wrote " + of28
print,"wrote " + of29
print,"wrote " + of30
print,"wrote " + of31
; end program
end

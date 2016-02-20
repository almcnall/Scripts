pro daily_total_gs4r_theo2,year,date,expdir,nx,ny,nbands

;this program calls 'flip..' which removes the header and rotates the image. Instead of a loop
;it calls the file run_daily_total which has a list of the year and date arguments that are needed
; as input both here and 'flip_'. That list is created with /source/mcnally/scripts_bash/run_daily_list.sh (4/9/11?)
;modified on 3/7/12 for runs in over theo's rainfall domain. (13:14N, 1.5:3E)
;12/1/2011: updated to include almost all of the outputs - it turns out that I did need thoes rad terms, thanks laura!

flip_AF_gs4r_theo2,date,year,expdir,nx,ny,nbands

close,/ALL

;I put the deyuck files in a different place so that it is easy to delete the original yuk files
wdir = strcompress("/jabber/LIS/OUTPUT/"+expdir+"/postprocess/"+year+"/"+date+"/",/remove_all)

;FILE_MKDIR,wdir

cd,wdir 

files = file_search('*gs4r')
; flip direction
direction = 2

nfiles = n_elements(files)

buffer   = fltarr(nx,ny,nbands)
data_in  = fltarr(nx,ny,nbands,nfiles)

for i=0,n_elements(files)-1 do begin
  ; read all of the data (all days all bands) into data_in
  openr,lun,files[i],/get_lun
  readu,lun,buffer
  byteorder,buffer,/XDRTOF
  data_in[*,*,*,i] = buffer
end

day_file=strcompress("/jabber/LIS/OUTPUT/"+expdir+"/postprocess/daily/", /remove_all)

FILE_MKDIR,day_file

;vars=['SWnt',  'LWnt' , 'Qlhf' , 'Qshf',  'Ghfl' , 'evap' , 'Qsuf' , 'Qsub' , 'albd' , 'sm01',  'sm02',  'sm03', $ 
;      'sm04',  'PoET',  'Ecan',  'Tveg',  'Esol',  'rain',  'SWIx',  'WRTS',  'wAET',  'WRSI',  'xtSM']

;nz=n_elements(vars)
data_in[where(data_in lt -9998)] = !VALUES.F_NAN

of1 = strcompress(day_file+"SWnt_" +date+".img",/remove_all)
of2 = strcompress(day_file+"LWnt_" +date+".img",/remove_all)
of3 = strcompress(day_file+"Qlhf_" +date+".img",/remove_all)
of4 = strcompress(day_file+"Qshf_" +date+".img",/remove_all)
of5 = strcompress(day_file+"Ghfl_" +date+".img",/remove_all)
of6 = strcompress(day_file+"evap_" +date+".img",/remove_all)
of7 = strcompress(day_file+"Qsuf_" +date+".img",/remove_all)
of8 = strcompress(day_file+"Qsub_" +date+".img",/remove_all)
of9 = strcompress(day_file+"albd_" +date+".img",/remove_all)
of10 = strcompress(day_file+"sm01_" +date+".img",/remove_all)
of11 = strcompress(day_file+"sm02_" +date+".img",/remove_all)
of12 = strcompress(day_file+"sm03_" +date+".img",/remove_all)
of13 = strcompress(day_file+"sm04_" +date+".img",/remove_all)
of14 = strcompress(day_file+"PoET_" +date+".img",/remove_all)
of15 = strcompress(day_file+"ECan_" +date+".img",/remove_all)
of16 = strcompress(day_file+"TVeg_" +date+".img",/remove_all)
of17 = strcompress(day_file+"ESol_" +date+".img",/remove_all)
of18 = strcompress(day_file+"rain_" +date+".img",/remove_all)
of19= strcompress(day_file+"SWIx_" +date+".img",/remove_all)
of20 = strcompress(day_file+"WRTS_" +date+".img",/remove_all)
of21 = strcompress(day_file+"wAET_" +date+".img",/remove_all)
of22= strcompress(day_file+"WRSI_" +date+".img",/remove_all)
of23= strcompress(day_file+"xtSM_" +date+".img",/remove_all)

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

;initialize arrays
SWnt= fltarr(nx,ny)
LWnt= fltarr(nx,ny)
Qlhf= fltarr(nx,ny)
Qshf= fltarr(nx,ny)
Ghfl= fltarr(nx,ny)
evap= fltarr(nx,ny)
Qsuf= fltarr(nx,ny)
Qsub= fltarr(nx,ny)
albd= fltarr(nx,ny)
sm01= fltarr(nx,ny)
sm02= fltarr(nx,ny)
sm03= fltarr(nx,ny)
sm04= fltarr(nx,ny)
PoET= fltarr(nx,ny)
Ecan= fltarr(nx,ny)
Tveg= fltarr(nx,ny)
Esol= fltarr(nx,ny)
rain= fltarr(nx,ny)
SWIx= fltarr(nx,ny)
WRTS= fltarr(nx,ny)
wAET= fltarr(nx,ny)
WRSI= fltarr(nx,ny)
xtSM= fltarr(nx,ny)

SWnt= mean(data_in[*,*,0,*],/NAN, dimension=4) 
LWnt= mean(data_in[*,*,1,*],/NAN, dimension=4) 
Qlhf= mean(data_in[*,*,2,*],/NAN, dimension=4) 
Qshf= mean(data_in[*,*,3,*],/NAN, dimension=4) 
Ghfl= mean(data_in[*,*,4,*],/NAN, dimension=4) 
evap= mean(data_in[*,*,5,*],/NAN, dimension=4) 
Qsuf= mean(data_in[*,*,6,*],/NAN, dimension=4) 
Qsub= mean(data_in[*,*,7,*],/NAN, dimension=4) 
albd= mean(data_in[*,*,8,*],/NAN, dimension=4) 
sm01= mean(data_in[*,*,9,*],/NAN, dimension=4) 
sm02= mean(data_in[*,*,10,*],/NAN, dimension=4) 
sm03= mean(data_in[*,*,11,*],/NAN, dimension=4) 
sm04= mean(data_in[*,*,12,*],/NAN, dimension=4) 
PoET= mean(data_in[*,*,13,*],/NAN, dimension=4) 
Ecan= mean(data_in[*,*,14,*],/NAN, dimension=4) 
Tveg= mean(data_in[*,*,15,*],/NAN, dimension=4) 
Esol= mean(data_in[*,*,16,*],/NAN, dimension=4) 
rain= mean(data_in[*,*,17,*],/NAN, dimension=4) 
SWIx= mean(data_in[*,*,18,*],/NAN, dimension=4) 
WRTS= mean(data_in[*,*,19,*],/NAN, dimension=4) 
wAET= mean(data_in[*,*,20,*],/NAN, dimension=4) 
WRSI= mean(data_in[*,*,21,*],/NAN, dimension=4) 
xtSM= mean(data_in[*,*,22,*],/NAN, dimension=4) 

writeu,1,  SWnt
writeu,2,  LWnt
writeu,3,  Qlhf
writeu,4,  Qshf
writeu,5,  Ghfl
writeu,6,  evap
writeu,7,  Qsuf
writeu,8,  Qsub
writeu,9,  albd
writeu,10, sm01
writeu,11, sm02
writeu,12, sm03
writeu,13, sm04
writeu,14, PoET
writeu,15, Ecan
writeu,16, Tveg
writeu,17, Esol
writeu,18, rain
writeu,19, SWIx
writeu,20, WRTS
writeu,21, wAET
writeu,22, WRSI
writeu,23, xtSM
  
print,"wrote " + of20
print,"wrote " + of21
print,"wrote " + of22
print,"wrote " + of23

; end program
end

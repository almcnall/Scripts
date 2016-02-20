;take a quick look at the different datasets to identify 
;issues w/ domain, resolution, nulls etc
;(e.g. ftip and irp) to see where pete likes his globe split.

iifile=file_search('/raid/Products/binary_cubes/IRP_0.25Deg/monthly.from0.05pents/*img')  
cifile=file_search('/home/LIS/z-jabber/Data/CMORPH/moncubie/*.img')  
pifile=file_search('/home/LIS/z-jabber/Data/PERSIANN/moncubie/*img')
eifile=file_search('/home/binary_cubes/ECMWF/monthly/*.img')
prfile=file_search('/home/LIS/z-jabber/Data/PRINCETON/moncubie/*.img')
tipRTfile=file_search('/home/binary_cubes/FTIP-RT/monthly/*.img')
tipV6file=file_search('/home/binary_cubes/FTIP-V6/monthly/*.img')

ecmwf_grid=fltarr(1440,400,22) ;50N-50S
cmor_ingrid=fltarr(1440,480,6) ;60N-60S?
irp_ingrid=fltarr(1440,400,11);50N-50S
pers_ingrid=fltarr(1440,480,6) ;60N-60S?
prin_ingrid=fltarr(360,180,61);90N:90S
tipRT_ingrid=fltarr(1440,400,7);50N-50S  -- not working, no data?
tipV6_ingrid=fltarr(1440,400,10);50N-50S  -- not working, no data?

;*********FTIP-V6*******
openr,1,tipV6file[0]
readu,1,tipV6_ingrid
close,1

mve, tipV6_ingrid
stack=total(tipV6_ingrid,3)
p1=image(stack)



;*********FTIP-RT*******
openr,1,tipRTfile[0]
readu,1,tipRT_ingrid
close,1

big=where(tipRT_ingrid gt 1000)
tipRT_ingrid(big)=1000

stack=mean(tipRT_ingrid,dimension=3, /nan)
p1=image(stack)


;*********princeton*******
openr,1,prfile[0]
readu,1,prin_ingrid
close,1

stack=total(prin_ingrid,3)
p1=image(stack)

;*******ECMWF*************
openr,1,eifile[0]
readu,1,ecmwf_grid
close,1

stack=total(ecmwf_grid,3)
p1=image(stack)
;***IRP**********
openr,1,iifile[0]
readu,1,irp_ingrid
close,1

stack=total(irp_ingrid,3)
p1=image(stack)
mve, cmor_ingrid





;***cmorph**********
openr,1,cifile[0]
readu,1,cmor_ingrid
close,1
byteorder,cmor_ingrid,/XDRTOF

stack=total(cmor_ingrid,3)
p1=image(stack)
mve, cmor_ingrid
;*****persiann**********
openr,1,pifile[0]
readu,1,pers_ingrid
close,1
byteorder,pers_ingrid,/XDRTOF

small=where(pers_ingrid lt 0, complement=good, count)
huge=where(pers_ingrid gt 2000, complement=norm, count)
pers_ingrid(small)=0
pers_ingrid(huge)=mean(pers_ingrid(norm))
stack=total(pers_ingrid,3)
p1=image(stack)
mve, pers_ingrid

;look at some of my new monthly cubes to make sure they are ok..looks fine except the values
ifile=file_search('/home/LIS/z-jabber/Data/PRINCETON/moncubie/princeton_03.img')
buffer=fltarr(360,180,61)

openr,1,ifile
readu,1,buffer
close,1

p1=image(total(buffer,3))

;******checkout the chirp data- does it match the RFE2-gdas?
cfile = file_search('/raid/CHIRPS/6-hrly/africa/rfe_gdas.bin.2011033500')
rfile = file_search('/home/jabber/LIS/Data/RFE2_GDAS/Unbiased/201108/rfe_gdas.bin.2011083100')

nx = 751
ny = 801

ingrid = fltarr(nx,ny)

openr,1,rfile
readu,1,ingrid
close,1

openr,1,cfile
readu,1,ingrid
close,1

chrips = ingrid

openr,1,rfile
readu,1,ingrid
close,1

rfe = ingrid
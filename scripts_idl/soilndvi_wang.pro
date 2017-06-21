pro soilNDVI_wang

;they checked the NDVI in the surrounding 1,5,9 pixels of the soil measurements.
;they averaged 8 days of soil moisture (day+floowing 7) since my NDVI is in 10 day composits I can average the next 9 days.
;they defined the seasonality with a 23 pnts moving average for soil and a 3 pnt moving average for NDVI
;then subtracted the seasonality from the time series before correlating with the deseasonalized NDVI....
; they also only looked at the growing season.
;how should I define the start of season? maybe the WRSI will give me an estimate.

;***dates of soil moisture measurements, w. the occational missing day*********************
;dfile=file_search('/jabber/Data/mcnally/AMMASOIL/wankama_millet_110dates.dat') ;millet site
dfile=file_search('/jabber/Data/mcnally/AMMASOIL/wankama_fallow_110dates.dat')
sdate=intarr(4,493);(fallow)yr.m.day,doy
;sdate=intarr(4,469); (millet)yr.m.day,doy 
openr,1,dfile
readu,1,sdate ;ops looks like i am missing 2005-12-31...2005 is 0:165
close,1

;*****daily soil moisture....rows=days, cols=depths********
nx=6 ; I think that there are 6 for both millet110 and fallow110
ny=493; (469 millet)n depths when SM was recorded, uh what about fallow?
sbuffer=fltarr(nx,ny)

ifile=file_search('/jabber/Data/mcnally/AMMASOIL/wankama_fallow_cube110.dat')
;ifile=file_search('/jabber/Data/mcnally/AMMASOIL/wankama_millet_cube110.dat')
openr,1,ifile
readu,1,sbuffer
close,1

;for each year and each month sum up the days that are lt10, between 10 and 21, gt21
;mdepths=[-10,-50,-100,-150,-200,-250]
sdeks=fltarr(6,57) ;6 depths w/ 20 dekads in 2005 and 36 in 2006
cnt=0
emptydek=fltarr(6)
emptydek[*]=!VALUES.F_NAN

;find dekadal averages of soil moisture.
for y=2005,2006 do begin
  for m=1,12 do begin
    buffer=where(sdate[0,*] eq y AND sdate[1,*] eq m, count) 
    if count eq 0 then continue 
    print, sbuffer[*,buffer]
    ;this pulls out all the indices for the month/yr of interest
    ;this subsets indices them into their respective dekads
    
    d1=where(sdate[2,buffer] lt 11, count) & print, count
    if count gt 0 then sdek1=mean(sbuffer[*,buffer[d1]],dimension=2) else sdek1=emptydek
    sdeks[*,cnt]=sdek1 & cnt++
    ;bad coding practice -- i added in an exception for one particular instance...but it works :p
    d2=where(sdate[2,buffer] ge 11 AND sdate[2,buffer] le 20, count) & print, count
    if count eq 1 then sdek2=sbuffer[*,buffer[d2]] else $ 
    if count gt 0 then sdek2=mean(sbuffer[*,buffer[d2]],dimension=2) else sdek2=emptydek
    sdeks[*,cnt]=sdek2 & cnt++
    
    d3=where(sdate[2,buffer] ge 21, count) & print, count
    if count gt 0 then sdek3=mean(sbuffer[*,buffer[d3]],dimension=2) else sdek3=emptydek
    sdeks[*,cnt]=sdek3 
    if cnt eq n_elements(sdeks[0,*]) then continue else cnt++
   endfor;m
endfor;y

;***************now look at the NDVI data************************************    
ndvi=fltarr(3,2,144)

  ;read in the ndvi data of interest
nfile='/jabber/Data/mcnally/AMMAVeg/NDVI_at_MF110.dat'
openu,1,nfile
readu,1,ndvi
close,1

;work with the average of ndvi over the small box
xmean=mean(ndvi, dimension=1)
avgndvi=mean(xmean,dimension=1)

;add a bunch of nan's to make the arrays the same length
pad=fltarr(6,15)
pad[*,*]=!VALUES.F_NAN
sdeks=[[pad],[sdeks]]

;something like this to plot two y-axis...greg has an example of this somewhere...
p2=plot(sdeks[0,*], axis_style=0, /current, color='red')
p1=plot(avgndvi[16:73,*], axis_style=1, /current)
;plot ndvi from dek1 of june 2005 to last dek of dec 2006...

;work on de-seasonalizing: subtract the raw data from the smoothed version, i like 5 better than 3pnt.
;I wonder if it matters if I smooth the subdaily or the 10 day....or maybe make daily and smooth it?
;this creates a smooth soil moisture series that I can subtract out as the seasonal signal.
ssmooth=smooth(sdeks[0,*],5, /edge_truncate, /nan)
;for the NDVI I can use the short term mean (I have more years than this I think...)
nstm=[transpose(avgndvi[0:35]), transpose(avgndvi[36:71]),transpose(avgndvi[72:107]),transpose(avgndvi[108:143])]
nstm=mean(nstm, dimension=1)
;this is the seasonal time series that can be subtracted.
nstm=[nstm,nstm,nstm,nstm] 
ndiff=avgndvi-nstm
sdiff=sdeks[0,*]-ssmooth
end

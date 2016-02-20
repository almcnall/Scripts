pro soilNDVI_wangv2

;they checked the NDVI in the surrounding 1,5,9 pixels of the soil measurements.
;they averaged 8 days of soil moisture (day+following 7) since my NDVI is in 10 day composits I can average the next 9 days.
;they defined the seasonality with a 23 pnts moving average for soil and a 3 pnt moving average for NDVI
;then subtracted the seasonality from the time series before correlating with the deseasonalized NDVI....
; they also only looked at the growing season.
;how should I define the start of season? maybe the WRSI will give me an estimate.
;7/2/12 v2 modifies the first version so that i can compare the millet/fallow sites with the filed/gully sites
; looking that the timeseries and FIR function.
; i need to convert to VWC using the calibration formula from the manual and i need to fill in missing dates/data
; ;i need these to be in waterpotential too...
; 
;***dates of soil moisture measurements, w. the occational missing day*********************
dfile=file_search('/jabber/Data/mcnally/AMMASOIL/wankama_millet_110datesv2.dat') ;millet site
;dfile=file_search('/jabber/Data/mcnally/AMMASOIL/wankama_fallow_110datesv2.dat'); 502 unq dates.
;sdate=intarr(4,502);(fallow)yr.m.day,doy
sdate=intarr(4,479); (millet)yr.m.day,doy 
openr,1,dfile
readu,1,sdate ;ops looks like i am missing 2005-12-31...2005 is 0:165, uh, where did it go? was it ever there?
close,1

;*****daily soil moisture....rows=days, cols=depths********
nx=6 ; I think that there are 6 for both millet110 and fallow110
ny=n_elements(sdate[0,*]);479 millet)n depths when SM was recorded, uh what about fallow (502)?
sbuffer=fltarr(nx,ny)

;ifile=file_search('/jabber/Data/mcnally/AMMASOIL/wankama_fallow_cube110v2.dat') ;last missing value is a problem.
ifile=file_search('/jabber/Data/mcnally/AMMASOIL/wankama_millet_cube110v2.dat')
openr,1,ifile
readu,1,sbuffer
close,1

;for each year and each month sum up the days that are lt10, between 10 and 21, gt21
;mdepths=[-10,-50,-100,-150,-200,-250]
sdeks=fltarr(6,72) ;6 depths w/ 36 dekads in 2005 and 36 in 2006 ;was 20 in 2005 but i want to fill in the missing 16.
cnt=0
emptydek=fltarr(6)
emptydek[*]=!VALUES.F_NAN

;find dekadal averages of soil moisture. ugh, this isn't working
for y=2005,2006 do begin
  for m=1,12 do begin
    buffer=where(sdate[0,*] eq y AND sdate[1,*] eq m, count) & print, count
    
    ;this pads out the missing 16 dekads at the begining of 2005 so it is easier to align with other datasets.
    if count eq 0 then begin
      print, 'a whole month missing wtf?!'
      sdek1=emptydek
      sdeks[*,cnt]=sdek1 & cnt++
      sdek2=emptydek
      sdeks[*,cnt]=sdek2 & cnt++
      sdek3=emptydek
      sdeks[*,cnt]=sdek3 & cnt++ ;was the first dimension missing?
    continue 
    endif
    ;this pulls out all the indices for the month/yr of interest
    ;this subsets indices them into their respective dekads
    
    d1=where(sdate[2,buffer] lt 11, count) & print, cnt
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
   print,'hold'
endfor;y

;convert from CS616 period to VWC %
VWC=sdeks
VWC[*,*]=!VALUES.F_NAN
for i=0,n_elements(sdeks[*,0])-1 do begin &$
 for j=0,n_elements(sdeks[0,*])-1 do begin &$
  VWC[i,j]=-0.0663-0.0063*sdeks[i,j]+0.0007*sdeks[i,j]^2 &$
  print, sdeks[i,j] &$
 endfor &$
endfor;i

;for the 50cm TS set the negative numbers to nan
;gaps are longer for the millet so i'll have to fill them in differently. 
;WKfallow10=VWC[0,*];
;WKfallow50=VWC[1,*]; but now this is millet not fallow. i need to clean this stuff up. 
;WKfallow100=VWC[2,*];
;;neg=where(WKfallow50 lt 0,count)
;;WKfallow50(neg)=!VALUES.F_NAN
;;and fill in missing values with the mean of the surrounding points.
;good=where(finite(WKfallow100), complement=missing)
;;ugh, does this last one have to be missing?
;for i=0,n_elements(missing)-1 do begin &$
;   fill=mean([WKfallow100(missing[i]-1), WKfallow100(missing[i]+1)]) &$
;   Wkfallow100(missing[i])= fill &$
;endfor

;after missing data is filled write out the file. what other depths should i do this for?
;ofile='/jabber/Data/mcnally/AMMASOIL/WK110_fallow_VWC_100cm.dat'
;openw,1,ofile
;writeu,1,Wkfallow100
;close,1
;***********similar for the millet site************************
;for the 50cm TS set the negative numbers to nan
;gaps are longer for the millet so i'll have to fill them in differently. 
WKmillet50=VWC[1,*]; but now this is millet not fallow. i need to clean this stuff up. 
Wkmillet10=VWC[0,*]
Wkmillet100=VWC[2,*]

;and fill in missing values with the mean of the surrounding points.
;
good=where(finite(WKmillet10), complement=missing)
;good=where(finite(WKmillet100), complement=missing)
;ugh, does this last one have to be missing?
for i=0,n_elements(missing)-1 do begin &$
   fill=mean([WKmillet10(missing[i]-1), WKmillet10(missing[i]+1)]) &$ ;eak was this error in there?
   Wkmillet50(missing[i])= fill &$
   if missing[i] gt 15 then begin &$
   fill=mean([WKmillet50[46], WKmillet50[52]], /nan) &$
   Wkmillet50(missing[i])= fill &$
   endif &$  
endfor

;after missing data is filled write out the file. what other depths should i do this for?
ofile='/jabber/Data/mcnally/AMMASOIL/WK110_millet_VWC_100cm.dat'
;openw,1,ofile
;writeu,1,Wkmillet100
;close,1

;afterthought...read the files back in,include water potenital and writeback out to the same file with 
;an additional column. I didn;t include a date column but i think that it is pretty obvious that it is 
;72 dekads from 2005-2006.

ifile=file_search('/jabber/Data/mcnally/AMMASOIL/WK110/*VWC*.dat')
VWC=fltarr(72)

for i=0,n_elements(ifile)-1 do begin &$
  ;read in the volumetric water content
  openr,1,ifile[i] &$
  readu,1,VWC &$
  close,1 &$
  ;look at the file name to determine the depth and which Campbel coeff to use. 
  if strmid(ifile[i],53,3) eq '100' then begin &$
  ;psie=0.9, b=2.83, thetaS=0.4 >60cm
  WP=0.9*(VWC/0.4)^(-2.83) &$
  endif
  if strmid(ifile[i],53,3) eq '50c' then begin  &$
  ;30-60cm: ψe=0.78, b=2.71, Өs=0.42 
  WP=0.78*(VWC/0.42)^(-2.71)
  endif
  if strmid(ifile[i],53,3) eq '10c' then begin  &$
  ;0-30cm: ψe=0.69, b=2.17, Өs=0.42 
  WP=0.69*(VWC/0.42)^(-2.17)  &$
  endif   &$
  
  ofile=strcompress(strmid(ifile[i],0,58)+'WP.dat', /remove_all)  &$
  openw,1,ofile   &$
  writeu,1,[transpose(VWC),transpose(WP)]   &$
  close,1   &$
endfor
print, 'the end is near'
end

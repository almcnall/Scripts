pro AMMAsoil_mill_fallow110

;the purpose of this script is to read and mess with the data from the wankama and millet sites but from the 110
;site rather than the 210 site. These measurements are different becasue they only cover 2005-2006, at different incremented
;depths and are much more frequent in time. They may be useful together. I think that I already did this with AMMAsoilv3
;Do any of these sites match the nutron probe sites so that I can calibrate them?
;7/2/12 looking back at this code since there seems to be a day missing either at the end of 2005 or 2006.

;# LAND SURFACE > Soils > Soil Moisture/CS616 Period at depth 5 cm(?s)
;# LAND SURFACE > Soils > Soil Moisture/CS616 Period at depth 10 cm(?s)
;# LAND SURFACE > Soils > Soil Moisture/CS616 Period at depth 50 cm(?s)
;# LAND SURFACE > Soils > Soil Moisture/CS616 Period at depth 1 m(?s)
;# LAND SURFACE > Soils > Soil Moisture/CS616 Period at depth 5 cm (2)(?s)
;# LAND SURFACE > Soils > Soil Moisture/CS616 Period at depth 1.5 m(?s)
;# LAND SURFACE > Soils > Soil Moisture/CS616 Period at depth 2 m(?s)
;# LAND SURFACE > Soils > Soil Moisture/CS616 Period at depth 2.5 m(?s)
;# LAND SURFACE > Soils > Soil Moisture/Neutron Count Ratio(no unit)
;# LAND SURFACE > Soils > Soil Moisture/CS616 Period(?s)
;# LAND SURFACE > Soils > Soil Moisture/CS615 Period(ms)


indir= '/jabber/Data/mcnally/AMMASOIL/subsets/'
cd, indir
fname = file_search('*110.csv');
i=0;1=millet, 0=fallow
;lets start with the millet sites to make the foodies happy
  myTemplate = ASCII_TEMPLATE(fname[i]); go to line 41
  buffer = read_ascii(fname[i], delimiter=';' ,template=myTemplate);

;for these data I have to be much more attentive to the hrs.
;did I accumulate these to day anywhere?
datetime = buffer.FIELD01[*]

yr = fix(strmid(datetime,0,4))
mo = fix(strmid(datetime,5,2))
dy = fix(strmid(datetime,8,2))
hr = fix(strmid(datetime,10,2))

doy = YMD2DN(yr, mo,dy)

lat = buffer.FIELD02[*] 
lon = buffer.FIELD03[*]
;these are hourly measurements...they need to be aggregated!
SM010 = buffer.FIELD08[*];
SM150 = buffer.FIELD09[*];
SM100 = buffer.FIELD10[*];
SM250 = buffer.FIELD11[*];
SM200 = buffer.FIELD12[*];
SM050 = buffer.FIELD13[*];

deptharray=[-10,-50,-100,-150,-200,-250]
table=[transpose(SM010),transpose(SM050),transpose(SM100), transpose(SM150),transpose(SM200), transpose(SM250)]
;oh boy, super amazing....
;parse out just the yr-month-day and then remove duplicates, turns out there are 502 not 493?!
test=rem_dup(strmid(datetime[*],0,10))
unqdate=strmid(datetime[test],0,10)

dtable=fltarr(n_elements(table[*,0]),n_elements(unqdate))
sum=fltarr(n_elements(table[*,0]))
;this might change between millet(469) and fallow (502)?
datearray=strarr(n_elements(unqdate))

;initialize index/counters
count=0
j=0

;is there another way that I could aggregate these days?
for i=0,n_elements(table[0,*])-1 do begin
   ;wtf does this line do? must deal with the last value?
   if dy[i] eq dy[n_elements(table[0,*])-1] then begin
   dtable[*,j]=sum/count-1
      count=0
      datearray[j]=datetime[i]
      continue
   endif
;if the day is the same as the next day then 
   if dy[i] eq dy[i+1] then begin
      ;this is a 1x6 vector that totals the values for the day
      sum=sum+table[*,i] 
      ;this keeps tracks of measurements per day so that i can take the mean.
      count++
      ;if it is a new day take the average and record it in dtable
      endif else begin
      dtable[*,j]=sum/count-1
      ;reset the counter
      count=0
      ;record the date...
      datearray[j]=datetime[i]
      ;reset 'sum'
      sum[*]=0
      ;advance j counter: which is the unqday...should get up to 501 i guess
      j++
    endelse
endfor;i 

print, 'hold here'
;ofile='/jabber/Data/mcnally/AMMASOIL/wankama_fallow_cube110.dat'
;openw,1,ofile
;writeu,1,dtable
;close,1
;
;;parse the datearray so that I can match it with the rainfall data that is in bin time.
;ascii time DOW MON DD HH:MM:SS YYYY amma time: 2005-03-18 00:00:00.0

yr = fix(strmid(datearray,0,4))
mo = fix(strmid(datearray,5,2))
dy = fix(strmid(datearray,8,2))
;hr = fix(strmid(datearray[0,*],10,2))
doy = ymd2dn(yr, mo,dy)

smdates=[transpose(yr),transpose(mo),transpose(dy),transpose(doy)]

;
;ofile='/jabber/Data/mcnally/AMMASOIL/wankama_fallow_110dates.dat'
;openw,1,ofile
;writeu,1,smdates
;close,1

print, 'hold'

;i need to re-arrange the data so that I can look at soil profiles, not just time series.
;i should do this with the cube_dat data, not here...
depths=[-10, -50]
profile=[transpose(sm010),transpose(sm050)]
slope=(sm010-sm050)/(50-10)
;uh, where did I make the soil into daily averages?

p1=plot(SM010,'r')
p1=plot(SM050,'orange', /overplot)
p1=plot(SM100,'y', /overplot)
p1=plot(SM150,'g', /overplot)
p1=plot(SM200,'b', /overplot)
p1=plot(SM250,'black', /overplot, title=fname[i])

end

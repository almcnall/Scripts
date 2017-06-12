pro AMMAsoil_mill_fallow110v2

;version 2 of this script revamps how the days are aggregated using the rem_dupicates and where rather than looping thru datestring.
;this code is much more concise and cleaner so that days are not missed.
;the purpose of this script is to read and mess with the data from the wankama and millet sites but from the 110
;site rather than the 210 site. These measurements are different becasue they only cover 2005-2006, at different incremented
;depths and are much more frequent in time. They may be useful together. I think that I already did this with AMMAsoilv3
; Do any of these sites match the nutron probe sites so that I can calibrate them? (yes, the millet sites at wankama...)

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
i=1;1=millet, 0=fallow
;lets start with the millet sites to make the foodies happy
  myTemplate = ASCII_TEMPLATE(fname[i]); go to line 41
  buffer = read_ascii(fname[i], delimiter=';' ,template=myTemplate);

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
;make a nice new table of observations
table=[transpose(SM010),transpose(SM050),transpose(SM100), transpose(SM150),transpose(SM200), transpose(SM250)]
;oh boy, super amazing....
test=rem_dup(strmid(datetime[*],0,10))
unqdate=strmid(datetime[test],0,10)

uyr = fix(strmid(unqdate,0,4))
umo = fix(strmid(unqdate,5,2))
udy = fix(strmid(unqdate,8,2))

dtable=fltarr(n_elements(table[*,0]),n_elements(unqdate))
datearray=strarr(n_elements(unqdate))

;initialize counter
j=0

for i=0,n_elements(unqdate)-1 do begin &$
   index=where(unqdate[i] eq strmid(datetime,0,10), count) &$
   ;take the mean of the 6 depths for the hrs of observations
   if count eq 1 then dmean=table[*,index] &$
   if count gt 1 then dmean=mean(table[*,index],dimension=2, /NAN) &$
   ;put the means in the table
   dtable[*,j]=dmean &$
   ;record the date to make sure it matches up..seems to
   datearray[j]=datetime[index[0]] &$
   j++ &$
endfor;  

print, 'hold here'
;write out new versions of the data....
;ofile='/jabber/Data/mcnally/AMMASOIL/wankama_fallow_cube110v2.dat'
;ofile='/jabber/Data/mcnally/AMMASOIL/wankama_millet_cube110v2.dat'
;openw,1,ofile
;writeu,1,dtable
;close,1
;
;;parse the datearray so that I can match it with the rainfall data that is in bin time.
;ascii time DOW MON DD HH:MM:SS YYYY amma time: 2005-03-18 00:00:00.0
;
yr = fix(strmid(datearray,0,4))
mo = fix(strmid(datearray,5,2))
dy = fix(strmid(datearray,8,2))
;hr = fix(strmid(datearray[0,*],10,2))
doy = ymd2dn(yr, mo,dy)

smdates=[transpose(yr),transpose(mo),transpose(dy),transpose(doy)]

;ofile='/jabber/Data/mcnally/AMMASOIL/wankama_fallow_110datesv2.dat'
ofile='/jabber/Data/mcnally/AMMASOIL/wankama_millet_110datesv2.dat'
openw,1,ofile
writeu,1,smdates
close,1

print, 'hold'
end

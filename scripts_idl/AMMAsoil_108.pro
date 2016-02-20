pro AMMAsoil_108

;this script reads the soil data from file108 that has been parsed out by location and depth.
;and then fills in a calendar to make a complete_TS ...or complete timeseries. this output file is later
;read by other files...spp daily2dekad_soil.pro

;fname=strcompress('/jabber/Data/mcnally/AMMASOIL/WK1_field108_40cm.csv', /remove_all)
;fname=strcompress('/jabber/Data/mcnally/AMMASOIL/WK1_gully108_68cm.csv', /remove_all)
;fname=strcompress('/jabber/Data/mcnally/AMMASOIL/WK1_field108_97cm.csv', /remove_all)
;fname=strcompress('/jabber/Data/mcnally/AMMASOIL/WK1_field108_135cm.csv', /remove_all)
;fname=file_search('/jabber/Data/mcnally/AMMASOIL/WK2_field108_100cm.csv')
;fname=file_search('/jabber/Data/mcnally/AMMASOIL/WK2_field108_160cm.csv')
;fname=file_search('/jabber/Data/mcnally/AMMASOIL/WK2_gully108_100cm.csv')
;fname=file_search('/jabber/Data/mcnally/AMMASOIL/WK2_gully108_135cm.csv')
;fname=file_search('/jabber/Data/mcnally/AMMASOIL/TK_gully108_70cm.csv')
fname=file_search('/jabber/chg-mcnally/AMMASOIL/Sofia/SofiaFallow30cm.csv')




myTemplate = ASCII_TEMPLATE(fname)
ifile = read_ascii(fname, delimiter=',' ,template=myTemplate)

;make a nice new array that I can deal with.
yr = fix(strmid(ifile.field1,0,4)) 
mo = strmid(ifile.field1,5,2)
dy = fix(strmid(ifile.field1,8,2))
hr = fix(strmid(ifile.field1,11,2)) 
minute = fix(strmid(ifile.field1,14,2)) 
lat = ifile.field2
lon = ifile.field3
depth = ifile.field4
soil = ifile.field5
doy = YMD2DN(yr, mo,dy)

;check it out. this part looks fine for TK_field
array=[ transpose(yr), transpose(mo), transpose(doy),transpose(dy), transpose(hr),transpose(minute), $
       transpose(lat), transpose(lon), transpose(soil)]


;make a calendar vector with year,day,hour,min
cal=fltarr(7,70080);for wank1_field40 or does 70080 come from elsewhere...
;cal=fltarr(7,n_elements(array[0,*]));
cal[*,*]=!VALUES.F_NAN
count=0
for y=2005,2008 do begin &$
  for d=1,365 do begin  &$
    for h=0,23 do begin  &$
      for m=0,1 do begin  &$
        ;this fills in the calendar vector with a NAN placeholder for the rainfall values, this could be 
        ;concatenated on later....but this works for now
        if m eq 0 then min=0 else min=30   &$
        cal[*,long(count)]=[y,!VALUES.F_NAN,d,!VALUES.F_NAN,h,min,!VALUES.F_NAN]   &$
        count=long(count)+1    &$
      endfor  &$
    endfor  &$
  endfor   &$  
endfor

;fill in the soil moisture array with values
;cal = year, month, doy, day, hr, min, soil
;array = year, mon, doy, day, hr, min, lat, lon, soil
for i=0,n_elements(array[0,*])-1 do begin &$ 
   index=where(cal[0,*] eq array[0,i] AND cal[2,*] eq array[2,i] AND cal[4,*] eq array[4,i] AND cal[5,*] eq array[5,i], count)  &$     
   ;when year, day, hour match then fill in the soil moisture value
   cal[6,index]=array[8,i] &$ 
   cal[3,index]=array[3,i] &$ 
   cal[1,index]=array[1,i] &$ 
   ;print, cal(*,index) &$
endfor
print, 'hold here'
;
close, 1
;might want to double check and make sure that this strmid config works for different filenames
ofile=(strmid(fname,0,48)+'_completeTS.csv') ;46 for the two digits, 47 for the three digits.
write_csv, ofile, cal

;openw,1,ofile
;writeu,1,cal
;close,1

print, 'hold here'
end
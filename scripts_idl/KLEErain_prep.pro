pro AMMAsoil_108

; It reads in the data and then fills in a calendar to make a complete_TS.

indir = strcompress('/jabber/chg-mcnally/', /remove_all)
;fname = file_search(indir+'/KLEE_Sept2011_Nov2012.csv')
fname = file_search(indir+'/KLEE_Jan2011_Nov2012.csv')


myTemplate = ASCII_TEMPLATE(fname)
ifile = read_ascii(fname, delimiter=',' ,template=myTemplate)
;N: Oo 17.46' N, 36o 51.96' E
;C: Oo 17.13' N, 36o 52.12' E
;S: Oo 16.85' N, 36o 51.12' E

;make a nice new array that I can deal with.
yr = fix('20'+strmid(ifile.field1,6,2)) 
mo = strmid(ifile.field1,0,2) & print, mo[0]
dy = fix(strmid(ifile.field1,3,2)) & print, dy[0]
 
north = float(ifile.field2) 
central = float(ifile.field3) 
south = float(ifile.field4) 

doy = YMD2DN(yr, mo,dy)

;what years are in the wankama dataset? 2006-2011 wankama 1 appears to be complete - except hr 0 day1
array=[ transpose(yr), transpose(mo), transpose(doy),transpose(dy), $
       transpose(north), transpose(central), transpose(south)]
;add in an hr zero...
;looks like Nalohou needs more padding....missing the last hr and last day of 2009
;what should the length be?


;make a calendar vector with year,day,hour,min
cal = fltarr(7,731);2yrs*365day*+an extra day (2011&2012)
;cal=fltarr(7,n_elements(array[0,*]));
cal[*,*]=!VALUES.F_NAN
count=0
for y=2011,2012 do begin &$
  if y eq 2012 then n=366 else n=365 &$
  for d=1,n do begin  &$
        ;this fills in the calendar vector with a NAN placeholder for the rainfall values, this could be 
        ;concatenated on later....but this works for now
        cal[*,long(count)]=[y,!VALUES.F_NAN, d,!VALUES.F_NAN,!VALUES.F_NAN,!VALUES.F_NAN,!VALUES.F_NAN]   &$
        count=long(count)+1    &$
  endfor  &$ 
print, y &$
endfor 

;fill in the soil moisture array with values
;this is prolly a stupid step .... i should just write out the array to match the format & add in hr 0
;cal = year, month, doy, day, soil, soil, soil
;array = year, mon, doy, day, soil, soil, soil
for i = 0,n_elements(array[0,*])-1 do begin &$ 
   index = where(cal[0,*] eq array[0,i] AND cal[2,*] eq array[2,i], count)  &$     
   ;when year, day, match then fill in the month, day and soil moisture values
   cal[1,index]=array[1,i] &$
   cal[3,index]=array[3,i] &$ 
   cal[4,index]=array[4,i] &$ 
   cal[5,index]=array[5,i] &$ 
   cal[6,index]=array[6,i] &$
   
   ;print, cal(*,index) &$
endfor
print, 'hold here'
;
;close, 1
;;might want to double check and make sure that this strmid config works for different filenames
ofile = strcompress(indir+'KLEE_precip.2011.2012_completeTS.csv', /remove_all) ;46 for the two digits, 47 for the three digits.
write_csv, ofile, cal
;
;;openw,1,ofile
;;writeu,1,cal
;;close,1
;
;print, 'hold here'
end
pro AMMAsoil_108

;this script is similar to AMMAsoil_108 but is dealing with the new AMMA 2013. It reads in the data
;and then fills in a calendar to make a complete_TS. there is a good chance this step is not necessary 
;with the new data.
;...or complete timeseries. this output file is later
;read by other files...spp daily2dekad_soil.pro

;indir = strcompress('/jabber/chg-mcnally/AMMASOIL/AMMA2013/AMMA/Wankama/')
;indir = strcompress('/jabber/chg-mcnally/AMMASOIL/AMMA2013/AMMA/Tondikiboro/')
;indir = strcompress('/jabber/chg-mcnally/AMMASOIL/AMMA2013/AMMA/Nalohou-Top/', /remove_all)
indir = strcompress('/jabber/chg-mcnally/AMMASOIL/AMMA2013/AMMA/Nalohou-Mid/', /remove_all)
;indir = strcompress('/jabber/chg-mcnally/AMMASOIL/AMMA2013/AMMA/Belefoungou-Top/', /remove_all)
;indir = strcompress('/jabber/chg-mcnally/AMMASOIL/AMMA2013/AMMA/Agoufou/', /remove_all)

outdir = strcompress('/jabber/chg-mcnally/AMMASOIL/AMMA2013/complete_TS/', /remove_all)

;fname = file_search(indir+'/AMMA_AMMA_Wankama_sm_0.050000_0.050000_CS616_1_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Wankama_sm_0.050000_0.050000_CS616_2_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Wankama_sm_0.100000_0.400000_CS616_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Wankama_sm_0.400000_0.700000_CS616_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Wankama_sm_0.700000_1.000000_CS616_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Wankama_sm_1.000000_1.300000_CS616_20000101_20130314.stm')

;fname = file_search(indir+'/AMMA_AMMA_Tondikiboro_sm_0.050000_0.050000_CS616_1_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Tondikiboro_sm_0.050000_0.050000_CS616_2_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Tondikiboro_sm_0.100000_0.400000_CS616_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Tondikiboro_sm_0.400000_0.700000_CS616_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Tondikiboro_sm_0.700000_1.000000_CS616_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Tondikiboro_sm_1.050000_1.350000_CS616_20000101_20130314.stm')

;what are the dates for this Benin site? 2006-09, deal with these tomorrow....
;fname = file_search(indir+'/AMMA_AMMA_Nalohou-Top_sm_0.050000_0.050000_CS616_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Nalohou-Top_sm_0.100000_0.100000_CS616_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Nalohou-Top_sm_0.200000_0.200000_CS616_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Nalohou-Top_sm_0.400000_0.400000_CS616_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Nalohou-Top_sm_0.600000_0.600000_CS616_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Nalohou-Top_sm_1.000000_1.000000_CS616_20000101_20130314.stm')

;fname = file_search(indir+'/AMMA_AMMA_Nalohou-Mid_sm_0.050000_0.050000_CS616_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Nalohou-Mid_sm_0.100000_0.100000_CS616_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Nalohou-Mid_sm_0.200000_0.200000_CS616_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Nalohou-Mid_sm_0.400000_0.400000_CS616_20000101_20130314.stm')
fname = file_search(indir+'/AMMA_AMMA_Nalohou-Mid_sm_1.200000_1.200000_CS616_20000101_20130314.stm')

;fname = file_search(indir+'/AMMA_AMMA_Belefoungou-Top_sm_0.050000_0.050000_CS616_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Belefoungou-Top_sm_0.100000_0.100000_CS616_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Belefoungou-Top_sm_0.200000_0.200000_CS616_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Belefoungou-Top_sm_0.400000_0.400000_CS616_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Belefoungou-Top_sm_0.600000_0.600000_CS616_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Belefoungou-Top_sm_1.000000_1.000000_CS616_20000101_20130314.stm')

;fname = file_search(indir+'/AMMA_AMMA_Agoufou_sm_0.050000_0.050000_CS616_1_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Agoufou_sm_0.300000_0.300000_CS616_1_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Agoufou_sm_0.600000_0.600000_CS616_1_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Agoufou_sm_1.200000_1.200000_CS616_1_20000101_20130314.stm')

;fname = file_search(indir+'/AMMA_AMMA_Agoufou_sm_0.050000_0.050000_CS616_2_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Agoufou_sm_0.300000_0.300000_CS616_2_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Agoufou_sm_0.600000_0.600000_CS616_2_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Agoufou_sm_1.200000_1.200000_CS616_2_20000101_20130314.stm')

;fname = file_search(indir+'/AMMA_AMMA_Agoufou_sm_0.050000_0.050000_CS616_3_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Agoufou_sm_0.100000_0.100000_CS616_3_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Agoufou_sm_0.400000_0.400000_CS616_3_20000101_20130314.stm')
;fname = file_search(indir+'/AMMA_AMMA_Agoufou_sm_1.200000_1.200000_CS616_3_20000101_20130314.stm')

myTemplate = ASCII_TEMPLATE(fname)
ifile = read_ascii(fname, delimiter=' ' ,template=myTemplate)

;make a nice new array that I can deal with.
yr = fix(strmid(ifile.field1,0,4)) 
mo = strmid(ifile.field1,5,2)
dy = fix(strmid(ifile.field1,8,2))
hr = fix(strmid(ifile.field2,0,2)) 
minute = fix(strmid(ifile.field2,3,2)) 
soil = float(ifile.field3) 
flag = string(ifile.field4)

doy = YMD2DN(yr, mo,dy)

;what years are in the wankama dataset? 2006-2011 wankama 1 appears to be complete - except hr 0 day1
array=[ transpose(yr), transpose(mo), transpose(doy),transpose(dy), transpose(hr),transpose(minute), $
       transpose(soil)]
;add in an hr zero...
;looks like Nalohou needs more padding....missing the last hr and last day of 2009
;what should the length be?
nhrs = long(24)
nyrs = long(4)
ndays = long(365)
leap = long(24) ;extra hrs
nevents = nhrs*nyrs*ndays+leap
padsize = nevents - n_elements(array[0,*])

;pad = [ yr[0],mo[0],doy[0],dy[0], 0,minute[0],soil[0]]
;array2 = [[pad],[array]]

;no missing values for agoufou_1
pad = fltarr(7,padsize) & help, pad
pad[*,*] = !values.f_nan
array2 = [[array],[pad]]

p1 = plot(array[6,*])
print, array[*,n_elements(array[0,*])-1]

;just for A_1
;array2 = array
;Wankama & Agoufou
;ofile=(outdir+strmid(fname,61)+'_completeTS.csv') & print, ofile 
;TondiKiboro
ofile = (outdir+strmid(fname,65)+'_completeTS.csv') & print, ofile 
;Belefoungou
;ofile = (outdir+strmid(fname,69)+'_completeTS.csv') & print, ofile 

write_csv, ofile, array2


;
;;make a calendar vector with year,day,hour,min
;cal = fltarr(7,52584);6yrs*365day*24hrs+an extra day (24hrs)
;;cal=fltarr(7,n_elements(array[0,*]));
;cal[*,*]=!VALUES.F_NAN
;count=0
;for y=2006,2011 do begin &$
;  if y eq 2008 then n=366 else n=365 &$
;  for d=1,n do begin  &$
;    for h=0,23 do begin  &$
;      for m=0,0 do begin  &$
;        ;this fills in the calendar vector with a NAN placeholder for the rainfall values, this could be 
;        ;concatenated on later....but this works for now
;        if m eq 0 then min=0 else min=30   &$
;        cal[*,long(count)]=[y,!VALUES.F_NAN,d,!VALUES.F_NAN,h,min,!VALUES.F_NAN]   &$
;        count=long(count)+1    &$
;      endfor  &$
;    endfor  &$
;  endfor   &$  
;print, y &$
;endfor 
;
;;fill in the soil moisture array with values
;;this is prolly a stupid step .... i should just write out the array to match the format & add in hr 0
;;cal = year, month, doy, day, hr, min, soil
;;array = year, mon, doy, day, hr, min, lat, lon, soil
;for i=0,n_elements(array[0,*])-1 do begin &$ 
;   index=where(cal[0,*] eq array[0,i] AND cal[2,*] eq array[2,i] AND cal[4,*] eq array[4,i] AND cal[5,*] eq array[5,i], count)  &$     
;   ;when year, day, hour match then fill in the soil moisture value
;   cal[6,index]=array[6,i] &$ 
;   cal[3,index]=array[3,i] &$ 
;   cal[1,index]=array[1,i] &$ 
;   ;print, cal(*,index) &$
;endfor
;print, 'hold here'
;;
;close, 1
;;might want to double check and make sure that this strmid config works for different filenames
;ofile=(strmid(fname,0,48)+'_completeTS.csv') ;46 for the two digits, 47 for the three digits.
;write_csv, ofile, cal
;
;;openw,1,ofile
;;writeu,1,cal
;;close,1
;
;print, 'hold here'
end
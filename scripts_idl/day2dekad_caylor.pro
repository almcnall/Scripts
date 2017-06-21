pro day2dekad_caylor
;
;the purpose of this script it to agregate the caylor data to dekads.
;SOILM DEP SM12H D12 ...COSMOS_55=KLEE 10/5/2011 - 11/14/2012 COSMOS_50=MPALA 9/6/2011 (Sept dek1) - 10/27/2012 (Oct dek3)
;ifile = file_search('/jabber/Data/mcnally/AMMASOIL/COS*50.csv')

ifile = file_search('/jabber/chg-mcnally/AMMASOIL/COSMOS_055_KLEE_Apr_18.csv')
;YYYY-MM-DD HH:MM SOILM DEP SM12H D12  
result = read_csv(ifile)
date = result.field1
  mm = fix(strmid(date,0,2))
  dd = fix(strmid(date,3,2))
  yr = fix('20'+strmid(date,6,2))
hhmm = result.field2
sm = result.field5
dp = result.field6
sm12 = result.field5
dp12 = result.field6

dind = [transpose(yr), transpose(mm), transpose(dd)]
sdeks = fltarr(108) ;do I want other stuff in this array? how many dekads will there be in 4 years? 36*4
cnt = 0
emptydek = !VALUES.F_NAN

;find dekadal averages of soil moisture.
for y = 2011,2013 do begin &$
  ;y = 2011
  for m = 1,12 do begin  &$
  ;m = 10
    ;where year=year and month=month
    index = where(dind[0,*] eq y AND dind[1,*] eq m, count)   &$
    if count eq 0 then begin  &$
      print, 'a whole month missing wtf?!'  &$
      sdek1 = emptydek  &$
      sdeks[cnt] = sdek1 & cnt++  &$
      sdek2 = emptydek  &$
      sdeks[cnt] = sdek2 & cnt++  &$
      sdek3 = emptydek &$
      sdeks[cnt] = sdek3 & cnt++  &$
    continue   &$
    endif  &$
    ;dekad1 are the days/hrs/mon where day (sbuffer(3)) is less than 11   
    d1 = where(dind[2,index] lt 11, count) & print, count  &$
    
    ;take the average of the SM col (sbuffer6), ignoring nan's
    if count gt 0 then sdek1=mean(sm[index[d1]], /nan) else sdek1=emptydek  &$
    ;record this average for the dekad.
    sdeks[cnt] = sdek1 & cnt++  &$
    
    ;bad coding practice -- i added in an exception for one particular instance...but it works :p
    d2 = where(dind[2,index] ge 11 AND dd le 20, count) & print, count  &$
    ;if count eq 1 then sdek2=sbuffer[*,index[d2]] else $ 
    if count gt 0 then sdek2 = mean(sm[index[d2]],/nan) else sdek2 = emptydek  &$
    sdeks[cnt] = sdek2 & cnt++  &$
  
    d3 = where(dind[2,index] ge 21, count) & print, count  &$
    if count gt 0 then sdek3 = mean(sm[index[d3]],/nan) else sdek3=emptydek  &$
    sdeks[cnt] = sdek3  &$
    ;if cnt eq 141 then continue else cnt++
    ;if cnt eq 141 then continue else 
    cnt++
    print, 'm ='+string(m)  &$
    print, 'cnt ='+string(cnt)  &$
    
   endfor  &$
   print, 'y ='+string(y)  &$
   print, 'cnt ='+string(cnt)  &$
endfor  &$
print, 'hold'

ofile = '/jabber/chg-mcnally/AMMASOIL/KLEE_dekad_2011_2013.csv'
write_csv,ofile,sdeks

try = ts_smooth(sm,30)
end 
pro wankama_rainstation

;taking another look at the wankama station data to better force LIS_Noah
;It calls the function FUNreadAMMA to read rainfall data from
;the two different files and this script concatinates them in inarr.

ifile1=file_search('/jabber/Data/mcnally/AMMARain/132-CE.Rain_wankama1h_WKE.csv') ;just awk'd yesterday
ifile2=file_search('/jabber/Data/mcnally/AMMARain/132-CE.Rain_wankama24hr_WKE.csv')

ifile3=file_search('/jabber/Data/mcnally/AMMARain/wankamaEast_1hrly_2005_2008.dat');original data to check
ifile4=file_search('/jabber/Data/mcnally/AMMARain/wankamaEast_3hrly_2005_2008.dat');all these data look fine

;check out the hourly and daily totals, they look fine (1920.12, 1920.18 mm over 4 yrs)
r = read_ascii(ifile1, delimiter=',')
rain=r.field1[3,*]

idat=fltarr(3,11680) ;year,doy,rain (mm/3hr)
idat1=fltarr(4,35040)
cal=fltarr(4,35040)


openr,1,ifile3
readu,1,cal
close,1

;make a nice new array that I can deal with.
yr = fix(strmid(rain.field1,0,4)) 
mo = strmid(rain.field1,5,2)
dy = strmid(rain.field1,8,2)
hr = strmid(rain.field1,11,10) 
lat = rain.field2
lon = rain.field3
precip = rain.field4
doy = YMD2DN(yr, mo,dy)

;site 1 East is 13.6496N 2.64920E
;site 2 West is 13.6455N 2.6211E
;add in the site number to the array....
site1=where(rain.field2 eq 13.6496, count, complement=site2) & print, count
site = intarr(n_elements(hr))
site(site1)=1
site(site2)=2

;check it out
array=[transpose(doy), transpose(yr), transpose(mo), transpose(dy), transpose(hr), transpose(lat), transpose(lon), transpose(site), transpose(precip)]

;make a calendar vector with year,day,hour
cal=fltarr(4,35040)
cal[*,*]=!VALUES.F_NAN
count=0
for y=2005,2008 do begin &$
  for d=1,365 do begin &$
    for h=0,23 do begin &$
      ;this fills in the calendar vector with a NAN placeholder for the rainfall values, this could be 
      ;concatenated on later....but this works for now
      cal[*,long(count)]=[y,d,h,!VALUES.F_NAN]  &$
      count=long(count)+1   &$
    endfor &$
  endfor  &$  
endfor

;oops did I do this correct?
for i=0,n_elements(array[0,*])-1 do begin &$ 
   index=where(cal[1,*] eq array[0,i] AND cal[0,*] eq array[1,i] AND cal[2,*] eq array[4,i] AND array[7,i] eq 1, count) &$      
   cal[3,index]=array[8,i] &$ 
   ;print, cal(*,index) &$
endfor

;write out the complete array of hourly data for site 1
;ofile=strcompress('/jabber/Data/mcnally/AMMARain/wankamaEast_complete_array2005_2008.dat', /remove_all)
;openw,1,ofile
;writeu,1,cal

;read in the wankamaEast_complete_array2005_2008.dat so that I can skip the first cal step, maybe 1hr.dat is the complete?
ifile=file_search('/jabber/Data/mcnally/AMMARain/wankamaEast_1hrly_2005_2008.dat')


;now make it three-hourly data....
count=0
three=fltarr(3,n_elements(cal[0,*])/3)
for i=0,n_elements(cal[0,*])-1 do begin &$
  tot=total(cal[3,count:count+2], /nan) &$
  three[*,i]=[cal[0,count], cal[1,count],tot] &$
  count=long(count)+3 &$
  print,count
endfor 

;now make it six-hourly data....
;this seems like an odd way of doing things but I guess it worked the first time.
count=0
six=fltarr(3,n_elements(cal[0,*])/6)
for i=0,n_elements(cal[0,*])-1 do begin &$
  tot=total(cal[3,count:count+5], /nan) &$
  six[*,i]=[cal[0,count], cal[1,count],tot] &$
  count=long(count)+6 &$
  print,count &$
endfor 

;write out the 6- hourly data for site 1
ofile=strcompress('/jabber/Data/mcnally/AMMARain/wankamaEast_6hrly_2005_2008.dat', /remove_all)
openw,1,ofile
writeu,1,six
close,1

;write out the 3- hourly data for site 1
ofile=strcompress('/jabber/Data/mcnally/AMMARain/wankamaEast_3hrly_2005_2008.dat', /remove_all)
openw,1,ofile
writeu,1,three
close,1

;checking out the year accumulations.....
;how do i plot these values with the date on the x-axis?
r1=rain.field4(site1)
d1=rain.field1(site1)

;accumulate rainfall for each year 
;2005: 5578 values  ;2006: 4473 values ;2007: 4467 values ;2008: 5230
year=['2005', '2006', '2007', '2008']
  ;vector of the season
  v05=r1(where(yr(site1) eq year[0])) 
  v06=r1(where(yr(site1) eq year[1]))
  v07=r1(where(yr(site1) eq year[2]))
  v08=r1(where(yr(site1) eq year[3]))
  
cum05=fltarr(n_elements(v05))
for i=1,n_elements(v05)-1 do begin &$
  cum05[0]=v05[0] &$
  cum05[i]=cum05[i-1]+v05[i] &$
endfor

cum06=fltarr(n_elements(v06))
for i=1,n_elements(v06)-1 do begin &$
  cum06[0]=v06[0] &$
  cum06[i]=cum06[i-1]+v06[i] &$
endfor

cum07=fltarr(n_elements(v07))
for i=1,n_elements(v07)-1 do begin &$
  cum07[0]=v07[0] &$
  cum07[i]=cum07[i-1]+v07[i] &$
endfor

cum08=fltarr(n_elements(v08))
for i=1,n_elements(v08)-1 do begin &$
  cum08[0]=v08[0] &$
  cum08[i]=cum08[i-1]+v08[i] &$
endfor
  
  
  tot05=total(r1(where(yr(site1) eq year[0]))) & print, tot05
  tot06=total(r1(where(yr(site1) eq year[1]))) & print, tot06
  tot07=total(r1(where(yr(site1) eq year[2]))) & print, tot07
  tot08=total(r1(where(yr(site1) eq year[3]))) & print, tot08



;r1=rain.field4(site2)
;d1=rain.field1(site2)

;p1=plot(r1)
;make a histogram of rainfall events...
h1=r1(where(r1 ne 0)) ;get rid of the zeros...there are a lot of them
raindays=rain.field1(where(r1 ne 0))
omin=min(h1)
omax=max(h1)

indata=h1
tmphist = histogram(indata,NBINS=10,OMAX=omax,OMIN=omin)
bplot = barplot(tmphist,FILL_COLOR='yellow')
nticks = 10
xticks = STRARR(nticks)
for i=0,nticks-1 do xticks(i) = STRING(FORMAT='(I-)',FLOOR(omin + (i * (omax - omin) / (nticks -1))))
bplot.xtickname = xticks
bplot.title = 'Histogram of Station1-East Rainfall Data'
bplot.xtitle='mm in 1 hr'
bplot.ytitle='frequency'

end


 
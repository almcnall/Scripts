pro wankama_rainstation

;taking another look at the wankama station data to better force LIS_Noah
;It calls the function FUNreadAMMA to read rainfall data from
;the two different files and this script concatinates them in inarr.

;4/14/2013 - looking at the Agoufou sta
;5/22/2013 - looking at the benin stations (belefoungou & nalohou)
;if I am going to use this with the daily2dekad_ script then i need to have days included....maybe i should be using
;a different one??

indir = '/jabber/chg-mcnally/AMMARain/'
;odir = '/jabber/chg-mcnally/AMMARain/132West/'

;fname = file_search(indir+'132-CE.Rain_wankama1hr.csv')
;fname = file_search(indir+'Agoufou_86-AL.Met_Gh.csv')
fname = file_search(indir+'Belefoungou_131_daily.csv')


valid= query_ascii(fname,info) ;checks compatability with read_ascii
myTemplate = ASCII_TEMPLATE(fname); go to line 100.
rain = read_ascii(fname, delimiter=' ' ,template=myTemplate)

;make a nice new array that I can deal with.
yr = fix(strmid(rain.field1,0,4)) 
mo = strmid(rain.field1,5,2)
dy = strmid(rain.field1,8,2)
hr = strmid(rain.field2,0,2) 
;hr = strmid(rain.field1,11,2) 
;mn = strmid(rain.field1,14,2) 
lat = rain.field3
lon = rain.field4
elev = rain.field5
prcp = rain.field6

doy = YMD2DN(yr, mo,dy)

;site 1 East is 13.6496N 2.64920E
;site 2 West is 13.6455N 2.6211E
;Agoufou is 15.3445, -1.47910
;
;add in the site number to the array....
;site1=where(rain.field2 eq 13.6496, count, complement=site2) & print, count
;site = intarr(n_elements(hr))
;site(site1)=1
;site(site2)=2

;check it out -- lets make cal and array match
;array=[transpose(doy), transpose(yr), transpose(mo), transpose(dy), transpose(hr), transpose(mn), $
;       transpose(lat), transpose(lon), transpose(prcp)]
;array=[transpose(yr), transpose(doy), transpose(mo), transpose(hr), transpose(mn),transpose(prcp)]
array=[transpose(yr), transpose(doy), transpose(mo), transpose(hr),transpose(prcp)]


;make a calendar vector with year,day,hour (no hr for Benin)
;cal = fltarr(6,140160+96)
cal = fltarr(4,1096)
cal[*,*]=!VALUES.F_NAN
count = 0
for y = 2006,2008 do begin &$
  if y eq 2008 then ndays = 366 else ndays = 365 &$
    for d = 1,ndays do begin &$
      ;for h = 0,23 do begin &$
;        for m = 0,3 do begin &$
;        if m eq 0 then min = STRING(FORMAT='(I2.2)',0) &$
;        if m eq 1 then min = 15 &$
;        if m eq 2 then min = 30 &$
;        if m eq 3 then min = 45 &$
      ;this fills in the calendar vector with a NAN placeholder for the rainfall values and months
        ;cal[*,long(count)] = [y,d,!VALUES.F_NAN,h,min,!VALUES.F_NAN]  &$
        cal[*,long(count)] = [y,d,!VALUES.F_NAN,!VALUES.F_NAN]  &$
        
        count = long(count)+1 & print, count &$
      ;endfor &$
  endfor  &$  
endfor

for i = 0,n_elements(array[0,*])-1 do begin &$ 
   ;cal:yr, doy, month, rain  & array:yr, doy, month, rain
   ;index = where(cal[0,*] eq array[0,i] AND cal[1,*] eq array[1,i] AND cal[3,*] eq array[3,i], count) &$   
   index = where(cal[0,*] eq array[0,i] AND cal[1,*] eq array[1,i] AND array[4,i] ne -9999.90, count) &$      
      
   cal[2,index] = array[2,i] &$ 
   cal[3,index] = array[4,i] &$ 
   
   ;print, cal(*,index) &$ ;[year,DOY,precip]
endfor

;write out the complete array of hourly data for site 1
ofile = strcompress('/jabber/chg-mcnally/AMMARain/Belefoungou_complete_array2006_2008.csv', /remove_all)
write_csv, ofile, cal

;now make it three-hourly data....but i nees the month in here too for making dekads
count = 0
three = fltarr(3,n_elements(cal[0,*])/12)
for i = 0,n_elements(cal[0,*])-1 do begin &$
  tot = total(cal[4,count:count+11], /nan) &$
  three[*,i] = [cal[0,count], cal[1,count],tot] &$
  count = long(count)+12 &$
  if count eq n_elements(cal[0,*]) then break  &$
 ; print,count &$
endfor 

;write out the 3- hourly data for site 1
;ofile = strcompress('/jabber/chg-mcnally/AMMARain/Agoufou_3hrly_2005_2008.csv', /remove_all)
;write_csv, ofile, three

;; READ IN STATION DATA
startyr = 2005
endyr   = 2008 

infile = file_search('/jabber/chg-mcnally/AMMARain/Agoufou_3hrly_2005_2008.csv')
;infile = file_search('/jabber/chg-mcnally/AMMARain/wankamaEast_3hrly_2005_2008.dat')
;infile = file_search('/jabber/chg-mcnally/AMMARain/wankamaWest_3hrly_2005_2008.dat')
;stndat = fltarr(3,11680) ;year,doy,rain (mm/3hr)

indat = read_csv(infile)
stndat = [transpose(indat.field1), transpose(indat.field2), transpose(indat.field3)]

;; LOOK AT DAILY TOTALS daytots=yr,dy,rfe,station
daytots = FLTARR(4)
tmpvals = FLTARR(4)
for y=startyr,endyr do begin &$
   for d=1,365 do begin &$
      tmpvals[0] = y &$
      tmpvals[1] = d &$
      ;tmpind = WHERE(rfedat[0,*] eq FLOAT(y) AND rfedat[1,*] eq FLOAT(d)) &$
      ; calculate total daily rainfall (mm) from 6 hourly rates (mm/sec)
      ;tmpvals[2] = TOTAL(rfedat[2,tmpind] * 60.0 * 60.0 * 6.0) &$
      tmpind = WHERE(stndat[0,*] eq FLOAT(y) AND stndat[1,*] eq FLOAT(d)) &$
      ; calculate total daily rainfall (mm) from 3 hourly rates (mm/sec)
      ;tmpvals[3] = TOTAL(stndat[2,tmpind] * 60.0 * 60.0 * 3.0)
      tmpvals[3] = TOTAL(stndat[2,tmpind]) &$
      
      daytots = [[daytots],[tmpvals]] &$
   endfor &$
endfor
;get rid of the first day of zeros...what's up with that?
daytots = daytots[*,1:N_ELEMENTS(daytots[0,*])-1]

;write out daytots to file
ofile = strcompress('/jabber/chg-mcnally/AMMARain/Agoufou_daily_2005_2008.csv', /remove_all)
write_csv,ofile,daytots


;checking out the year accumulations.....
;how do i plot these values with the date on the x-axis?
r1=rain.field4(site2)
d1=rain.field1(site2)

;accumulate rainfall for each year 
;2005: 5578 values  ;2006: 4473 values ;2007: 4467 values ;2008: 5230
year=['2005', '2006', '2007', '2008']
  ;vector of the season
  v05=r1(where(yr(site2) eq year[0])) 
  v06=r1(where(yr(site2) eq year[1]))
  v07=r1(where(yr(site2) eq year[2]))
  v08=r1(where(yr(site2) eq year[3]))
  
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
  
  
  tot05=total(r1(where(yr(site2) eq year[0]))) & print, tot05
  tot06=total(r1(where(yr(site2) eq year[1]))) & print, tot06
  tot07=total(r1(where(yr(site2) eq year[2]))) & print, tot07
  tot08=total(r1(where(yr(site2) eq year[3]))) & print, tot08



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
bplot.title = 'Histogram of Station1-West Rainfall Data'
bplot.xtitle='mm in 1 hr'
bplot.ytitle='frequency'

;where are the rainfall events?
;2005-05



;pramnt  = rain.FIELD11 ;make sure that this matches!
;data2 = FUNread_AMMA(fname)

;inarr=[[data],[data2]]
inarr = data2
position=intarr(1,n_elements(inarr[0,*]))
position[*,*]=!values.f_nan
inarr=[inarr,position]
;now I need to group the data according to location then by day
;group by location: add a pixel id to the list of station data.
;data = yr, mo, day, lat, lon, rain, x, y
;yr = inarr[0,*]
;mo = inarr[1,*]
;dy = inarr[2,*]
;lat = inarr[3,*]
;lon = inarr[4,*]
;rain = inarr[5,*]


;
;assigns a position to each of the values in the big array
uplft = where(lon ge 2.55 AND lon le 2.65 AND lat gt 13.55) & inarr(8,uplft)=0
upcnt = where(lon gt 2.65 AND lon le 2.75 AND lat gt 13.55) & inarr(8,upcnt)=1

dnlft = where(lon ge 2.55 AND lon le 2.65 AND lat le 13.55) & inarr(8,dnlft)=2
dncnt = where(lon gt 2.65 AND lon le 2.75 AND lat le 13.55) & inarr(8,dncnt)=3
dnrgt = where(lon gt 2.75 AND lon le 2.85 AND lat le 13.55) & inarr(8,dnrgt)=4

years = yr(rem_dup(yr))
  years = years[1:4]
months = mo(rem_dup(mo))
  month = months[1:7]
days = dy(rem_dup(dy))
  days = days[1:31]

outarr=fltarr(5,1540)
i=0 & j=0 & k=0 & l=0 & q=0 & counter=0
for l=0,3 do begin
  for i=0,n_elements(years)-1 do begin
    for j=0,n_elements(months)-1 do begin
      for k=0,n_elements(days)-1 do begin     
        q=where(inarr[8,*] eq l AND yr eq years[i] AND mo eq months[j] AND dy eq days[k] AND rain gt -1, count)
        if count eq 0 AND total(inarr[5,q]) lt -1 then continue
         rmean = mean(inarr[5,q])
         outarr[*,counter] = [years[i], months[j], days[k], mean(inarr[5,q]), l]
         counter++
       endfor;k
     endfor;j
   endfor;i
 endfor;l
 print, 'hold here'
 end

;ok, so now the data has been averaged by day by pixel. 
;;*************replace the values in the rfe files *******************
; print, 'stop here please'
;cd, '/jabber/LIS/Data/ubRFE2/'
;ingrid=fltarr(751,801)
;;replace all of the grids of interest from 2005 to 2008. That mean ll (all zeros 2205&6) and lr (all zeros 2005)
;; this might be a problem....
;fname=file_search('*{2005,2006,2007,2008}*') ;ug, I think that this is a problem for lower left and lower right....
;
;for m=0, n_elements(fname)-1 do begin
;  openr,1,fname[m]
;  readu,1,ingrid
;  byteorder,ingrid, /XDRTOF
;  close,1
;  
;  ;zero out the unqpix....
;  ingrid(unqpix[0,0], unqpix[1,0]) = 0.
;  ingrid(unqpix[0,1], unqpix[1,1]) = 0.
;  ingrid(unqpix[0,2], unqpix[1,2]) = 0.
;  ingrid(unqpix[0,3], unqpix[1,3]) = 0.
;  ingrid(unqpix[0,4], unqpix[1,4]) = 0.
;  
; ofile = strcompress('/jabber/LIS/Data/AMMArfe_grid/'+fname[m], /remove_all)
; openw,1,ofile
; byteorder,ingrid,/XDRTOF
; writeu,1,ingrid
; close,1
;  
;endfor; m
;
;cd, '/jabber/LIS/Data/AMMArfe_grid/'
;
;for l=0, n_elements(uqyr)-1 do begin
;  ;l=0
;  rfile = file_search('all_products.bin.'+uqyr[l]+uqmo[l]+uqdy[l]); this is only for days when vals were recorded
;  openr,1,rfile
;  readu,1,ingrid
;  byteorder,ingrid,/XDRTOF
;  close, 1
;  
;  ;as long as the value is a number then replace it...starting 20050827
;  if finite(ul(3,l)) eq 1 then ingrid(unqpix[0,0], unqpix[1,0]) = ul(3,l) ; the first entry of the dates there are 125 of these...make sure these are in correct order
;  if finite(lc(3,l)) eq 1 then ingrid(unqpix[0,1], unqpix[1,1]) = lc(3,l)
;  if finite(uc(3,l)) eq 1 then ingrid(unqpix[0,2], unqpix[1,2]) = uc(3,l)
;  if finite(lr(3,l)) eq 1 then ingrid(unqpix[0,3], unqpix[1,3]) = lr(3,l);these start later.
;  if finite(ll(3,l)) eq 1 then ingrid(unqpix[0,4], unqpix[1,4]) = ll(3,l);these start later. 
; 
; ofile = strcompress('/jabber/LIS/Data/AMMArfe_grid/'+rfile, /remove_all)
; openw,1,ofile
; byteorder,ingrid,/XDRTOF
; writeu,1,ingrid
; close,1
;endfor ;l
; 
;print, 'hello'  
 
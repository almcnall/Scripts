pro tendayAMMArain 
;the purpose of this program is to sum of ten day rainfall so that 
;I can compare it to 10 day NDVI. Use this script. it works :)
;modified on 8/15/12 to make dekads from the daily station data. 
;modified on 4/28/13 to make dekads from the Agoufou station data
;modified on 5/22/13 to make dekads from the Belefougou station data.
;
;make the pixel of interest in the Theo into deks, looks like i did this once..what was the ROI?
;for some reason this didn't work with the &$ loops, i had to compile with a breakpoint.
;
;rfile='/jabber/Data/mcnally/AMMARain/rain4soil/ROI_theo.rain.2005_2008.dat' 
;rain=fltarr(365,4);I eliminated the last day of december 2008 b/c i did not want 366 days.

;rfile=file_search('/jabber/chg-mcnally/AMMARain/RFE_and_station_daily.csv')
;rfile = file_search('/jabber/chg-mcnally/AMMARain/wankamaWest_daily_2005_2008.csv')
;rfile = file_search('/jabber/chg-mcnally/AMMARain/Agoufou_daily_2005_2008.csv')
;rfile = file_search('/jabber/chg-mcnally/AMMARain/Theo_WK_2005_2008_025deg_daily.csv')
rfile = file_search('/jabber/chg-mcnally/AMMARain/Belefoungou_complete_array2006_2008.csv')
allrain = read_csv(rfile,count=count)
station = float(allrain.field4) ;hard to say if station data is missing or not...
station(where(station lt 0)) = 0.
;rfe = allrain.field3
;theo = allrain.field1
;station = theo 
;openu,1,rfile
;readu,1,rain
;close,1

;tot=fltarr(82)

cnt = 0
yrs = [2006,2007,2008]
mo = [1,2,3,4,5,6,7,8,9,10,11,12]
;length of dekad (LOD) and length of month (LOM)
LOD = [10,10,11,    10,10,8,    10,10,11,    10,10,10,    10,10,11,     10,10,10,$
       10,10,11,    10,10,11,   10,10,10,    10,10,11,    10,10,10,     10,10,11]
;leap lenght of dekads  I actually forgot to use this...but i don't want to fix it (8/16/12)     
LLOD = [10,10,11,    10,10,9,    10,10,11,    10,10,10,    10,10,11,     10,10,10,$
       10,10,11,    10,10,11,   10,10,10,    10,10,11,    10,10,10,     10,10,11]
       
;rain=[[[transpose(reform(rfe,365,4))]],[[transpose(reform(station,365,4))]]]
;rain = transpose(reform(station[0:1459],365,4))
rain = transpose(reform(station[0:1094],365,3))


;dek = fltarr(n_elements(yrs),n_elements(lod),2)
dek = fltarr(n_elements(yrs),n_elements(lod))

dektot = 0
t=0
;for f = 0, n_elements(rain[0,0,*])-1 do begin ;add a loop for the two kinds of rainfall
 ;there are 4 years
 for y = 0,n_elements(yrs)-1 do begin &$
  for d = 0,n_elements(rain[0,*])-1 do begin &$
      cnt++ &$;start on one
      dektot = dektot+rain[y,d] &$
      print, dektot &$
      print, cnt & print, t &$
      if cnt eq LOD[t] then begin &$
        dek[y,t] = dektot  &$ ;save the total in the dekad array
        ;reset the counters
        t++ &$
        cnt = 0 &$
        dektot = 0 &$
      endif &$
   endfor &$;
  t=0 &$
 endfor
 dektot = 0
 t=0
;endfor

;ofile='/jabber/chg-mcnally/AMMARain/WK_theo.rain.2005_2008_dekads.csv' 
ofile='/jabber/chg-mcnally/AMMARain/Belefoungou.rain.2006_2008_dekads.csv' 
out = reform(transpose(dek),108)
;write_csv,ofile,out
;openw,1,ofile
;writeu,1,dek
;close,1
;and make a smoother version...not sure if this is necessary. come back if it is. 
good = where(finite(out), complement=missing) & print, missing
;too many gaps this doesn't work great...can i do a smoother and fill with that?
smbenin = smooth(out,4, /nan) & p1=where(finite(smbenin), complement=null) & help, null
out(missing) = smbenin(missing)

ofile='/jabber/chg-mcnally/AMMARain/Belefoungou.rain.2006_2008_dekads_filled.csv' 
write_csv,ofile,out

;
;ofile = '/jabber/chg-mcnally/AMMARain/wankamaWest_station_dekads.csv' 
ofile = '/jabber/chg-mcnally/AMMARain/Agoufou_station_dekads.csv' 

ts = reform(transpose(dek),144)
write_csv,ofile,ts
;print, 'hold here'
;stationdek=reform(transpose(dek[*,*,1]),144)
;rfedek=reform(transpose(dek[*,*,0]),144)
;
;cday=correlate(station,rfe) & print, cday
;cdek=correlate(stationdek,rfedek)& print, cdek


;; EXTRACT VALUES FOR UBRFE DATA 
; the station lon/lat is 13.6496N 2.64920E
ifile=file_search('/jabber/LIS/Data/ubRFE2/dekads/sahel/{2011,2012}*.img')
;Mpala Kenya:
xind = FLOOR((36.8701 + 20.) / 0.10)
yind = FLOOR((0.4856 + 5) / 0.10)
;
;KLEE Kenya
xind = FLOOR((36.8669 + 20.) / 0.10)
yind = FLOOR((0.2825 + 5) / 0.10)

;Wankama Niger
xind = FLOOR((2.6496 + 20.) / 0.10)
yind = FLOOR((13.6496 + 5) / 0.10)

;stn_lat = 13.6496
;stn_lon = 2.6492
;xind = FLOOR((stn_lon + 20.05) * 10.0)
;yind = FLOOR((stn_lat + 40.05) * 10.0) 

tmpgrid = fltarr(720,350)
stack = fltarr(720,350,n_elements(ifile))
for i=0,n_elements(ifile)-1 do begin &$
  
  openr,1,ifile[i] &$
  readu,1,tmpgrid &$
  close,1 &$
  
  ;tmpgrid=reverse(tmpgrid,2) &$
  stack[*,*,i]=tmpgrid &$
endfor
print, 'hold'

temp = image(total(stack,3, /nan))
poi1 = stack(xind,yind,*) & temp=plot(poi1);
poi2 = stack(xind,yind,*) & temp=plot(poi2, /overplot);

kenya = [transpose(poi1), transpose(poi2)]

ofile='/jabber/Data/mcnally/AMMARain/Mpala_KLEE_ubRFE2011_2012.csv'
write_csv,ofile,kenya
;**************************************************************
ifile1='/jabber/Data/mcnally/AMMARain/RFE_and_station_dekads.csv'
ifile2='/jabber/Data/mcnally/AMMARain/RFEunbiased_2001_2001.csv'

rain1=read_csv(ifile1)
rain2=read_csv(ifile2)

sta=rain1.field1
rfe=rain1.field2
ubrfe=rain2.field1

ub0508=ubrfe(144:288-1)

temp=plot(ub0508)
temp=plot(rfe,'b', /overplot)
temp=plot(sta,'g', /overplot)

out=[transpose(rfe), transpose(ub0508), transpose(sta)]

;ofile='/jabber/Data/mcnally/AMMARain/RFE_UBRFE_and_station_dekads.csv'
;write_csv,ofile,out


end
  
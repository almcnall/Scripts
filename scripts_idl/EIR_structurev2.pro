pro EIR_structurev2

; the purpose of this program is to compile a data set for each study site in the 
; EIR database that contains the Average Temperature, min Temp, maxTemp and rainfall 
; for the transmission season during the study and the climatology of the transmission season 
; 8/18/11 this is version 2 where I try to include the year round transmission....
; The MARA map is used to determine the middle month of the transmission season since this (start/end month) is the key
; information that is missing from the EIR file. I assume that the length of season from the EIR file is 'truth'. In many
; cases the length of season calculated from the map is close to that recorded in the EIR file, but sometimes they are very
; different.
;try to fix it again 1/17/2012! for real this time!

months = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec']

;read in the new csv file w/  c_name,lon,lat,seasonality (LOS),siteSOS,siteEOS,EI
eirfile = '/home/mcnally/luce_sites/location_SOS_EOS_LOS2_EIR.csv'
;location_SOS_EOS_LOS2_EIR.csv',c_name,lon,lat,seasonality,siteSOS,siteEOS,mapLOS,EIR 

buffer  = read_csv(eirfile, count = count, missing_value = -999 )

c_name=buffer.field1
lon=buffer.field2
lat=buffer.field3
seasonality=buffer.field4 ;this field is important
siteSOS=buffer.field5
siteEOS=buffer.field6
mapLOS=buffer.field7
EIR=buffer.field8

;***************************************************************
;match up 193 timeseries with 193 sites

sitedir = '/home/mcnally/luce_sites/'
cd, sitedir


Tavg  = fltarr(n_elements(infile),228)
Tmin  = fltarr(n_elements(infile),228)
Tmax  = fltarr(n_elements(infile),228)
rain  = fltarr(n_elements(infile),228)

;read in the data and put it in a vector number of sites(193) x number of months(12*19=228)
for k = 0,n_elements(infile)-1 do begin
  valid = query_csv(infile[k], info)
  ts = read_csv(infile[k])  
  ;this will store the ts in "order" according to the EIR file 
  Tavg[k,*]=ts.field2[*]
  Tmin[k,*]=ts.field3[*]
  Tmax[k,*]=ts.field4[*]
  rain[k,*]=ts.field5[*]
endfor ;k

;make a vector of months to add to temperature file (infile)
mocol = intarr(n_elements(ts.field2)) ;228, 19x12
mo = indgen(12)+1 & print, mo
  
;replicate the mo vector for each year so I can add this column to the array and pull out transmission months
  j=0 & i=0
  for i=0,n_elements(mocol)-1 do begin
     mocol[i]=mo[j] & j++ &  if (j eq 12) then j=0 
  endfor ;i
  
;make an array with the month indice
  for z=0,n_elements(months)-1 do begin ; where months[0]=jan and month_index[0,*] are all Jans
    mm = where(mocol eq z+1)
    month_index[z,*] = mm
  endfor ;z

;mtemp is the monthcube> each file,12 months, 19 years (193x12x19)   
;use mclim for the climatology use these in the year round transmission cases....
  for f=0,n_elements(lon100)-1 do begin; all 193 sites....
    for g=0,n_elements(months)-1 do begin ;make a month cube for each month     
      mtemp[f,g,*] = Tavg(f,month_index[g,*]) ;f=0,g=0 will give all benin januaries
      mclim[f,g] = mean(mtemp[f,g,*]);  f=0,g=0 will give the short term mean of benin januaries 
   endfor;g
 endfor;f


;*******************************************
;length of season, start of season issues: 7/6/11
;this section combineds the info on length of season (end-start) from the AMMA maps
;with information on the length of the season from the site specific studies
;I needed derive a start month so that I could extract
;relevant temperature data. The result is the adjusted start of season (AdjSOS)

studymid = fltarr(193) 
AdjSOS   = fltarr(193)

;a vector with the midpoint of tranmission season according to the MAP...ignore year round and no transmission season
mapmid= (float(LOS/2))+startmo ;LOS is calculated from the map

index = where(mapmid gt 12);find places where dec-jan crosses
mapmid(index) = mapmid(index)-12 ;fix it..this makes the yr rounds = 7 becasue 19-12

studyLOS = buffer2.field1[*] ;from the EIR excel file...this is 'truth' so I can use the yr round transmission.

;this first pass excludes point where the EIR database has no legnth of season recorded (i.e. no truth)
nolos   = where((studyLOS eq -999) or (studyLOS eq 0),count) ;this seems pretty redundant...
studylos(nolos) = -999
startmo(nolos) = -999; where there is no studylos black out the map info, just in case

;this second pass excludes points where there is no startmonth given so we don't have the info we need -except for yr round transmission (1 site)
nostart = where(startmo eq 0 OR startmo eq 13 AND studylos ne 12)
studylos(nostart) = -999.
startmo(nostart) = -999.

;this finds all locations that have been excluded and rolls them into one....
nodata = where((studyLOS eq -999), count, complement=good);so here 


studymid(good) = (studyLOS(good))/2
studymid(nodata) = -999;finds the halfway point of the season
;studylos(nodata) = -999;had to add this one in...why didn't I? Why did I do the sudymid correctly?

AdjSOS(good) = mapmid(good)-studymid(good) 
AdjSOS(nodata) = -999 

neg = where((adjSOS le 0) and (adjSOS gt -20)) 
adjSOS(neg) = adjSOS(neg)+12
AdjSOS = round(AdjSOS) 

;***********************************************************************************
yr = indgen(19)+1978
allmo = intarr(19)
index = intarr(n_elements(startmo), n_elements(yr)*12)
index=index-999

;this loops through each site to define the start month
for g=0,n_elements(AdjSOS)-1 do begin 

  ;g=?? benin, 43=no data 44=burundi, 56=sneaky bastard -- there are zeros at the begining...
  start = where((mocol eq AdjSOS[g]) , count) ;mocol=1:12, 5 means May
  if (count eq 0) then start = allmo ;
  i=0  &  k=0 ;this adds a month to the vector of indices that need to be captured....
  for h=0,n_elements(yr)-1 do begin ;one start month (e.g. April) for ea. year
    for j=0,studyLOS[g]-1 do begin ;for g studylos=6 , will this work where studylos = 12?
      
      index[g,k] = start[h]+j  & k++ ;
      
      if j eq studyLOS[g] then continue ;advance h...
    endfor ;j
  endfor;h

endfor;g


;ok, so now that I have the indices I need to go back the ts vectors and pull out the relevant data!

TavgEIR = fltarr(n_elements(startmo), n_elements(yr)*12)
TminEIR = fltarr(n_elements(startmo), n_elements(yr)*12)
TmaxEIR = fltarr(n_elements(startmo), n_elements(yr)*12)
rainEIR = fltarr(n_elements(startmo), n_elements(yr)*12)

flag=!VALUES.F_NAN

nodat=where(index eq -999, count, complement=dat); this does not seem to catch them.

TavgEIR(dat)=Tavg(dat) & TavgEIR(nodat)=!VALUES.F_NAN
TminEIR(dat)=Tmin(dat) & TminEIR(nodat)=!VALUES.F_NAN
TmaxEIR(dat)=Tmax(dat) & TmaxEIR(nodat)=!VALUES.F_NAN
rainEIR(dat)=rain(dat) & rainEIR(nodat)=!VALUES.F_NAN

;**********************************************************************

GrandTavg=fltarr(193)
GrandTmin=fltarr(193)
GrandTmax=fltarr(193)
Grandrain=fltarr(193)


for i=0,192 do begin
  GrandTavg[i]=mean(TavgEIR[i,*],/NAN)
  GrandTmin[i]=mean(TminEIR[i,*],/NAN)
  GrandTmax[i]=mean(TmaxEIR[i,*],/NAN)
  GrandRain[i]=mean(rainEIR[i,*],/NAN)
endfor

 ;add the these 4 new fields to the structure
bufferNew = create_struct(buffer, 'mapStart',startmo, 'studyLOS', studyLOS, 'mapLOS', LOS, 'adjstart',AdjSoS, 'trans_Tavg',GrandTavg,'trans_Tmin', $
                       GrandTmin, 'trans_Tmax', GrandTmax, 'trans_rain', GrandRain)
;help, /struct, bufferNew ;now there are 32 cols, 193 rows
write_csv,'/home/mcnally/luce_sites/EIR_withEnv2.csv', bufferNew

u=where(finite(TavgEIR(0,*)), count) & print, count
  
  ;this separates the 8 months (LOS) into 19 years and plots them! just for the first site
  ;but we are interested in just the years in the study...
  eiryr1 = buffer.field10[*]
  eiryr2 = buffer.field12[*]
  
  sporzinx = buffer.field13[*]
  biterate = buffer.field16[*]
  EIR      = buffer.field19[*]
 
 ;so the best thing to do would probably to put the fields of interest back into the 
 ;original structure that they came out of. 
   
  ;index=where(biterate gt 0)
  ;posbite = biterate(index)
  
  ;testplot
  index=where(EIR ge 0)
  posStudyLOS=studylos(index)
  p1 = plot(posstudyLOS, posEIR, symbol='+', linestyle=6, xrange=[-1,13],xtitle='length of season', ytitle='EIR')
  
  
  ;****************these are prolly the useful ones******************  
   
    ;p1 = plot(grandTavg,EIR,symbol='+',view_title='EIR vs average Temperature', ytitle='EIR', xtitle='temp(C)', $
     ;         linestyle=6, YRANGE=[0,800], XRANGE=[10,35])
              
;   TITLE = 'average transmission season temperature vs annual EIR', XTITLE = 'Avg temp (C)', $  
;   YTITLE = 'Annual EIR' 
   

;    window,2,XSIZE=700
;    DEVICE, SET_FONT='Courier Bold Italic', /TT_FONT,SET_CHARACTER_SIZE=[9,11] 
;    plot, grandTavg,biterate,psym=2,YRANGE=[0,35000], XRANGE=[10,35], $  
;   TITLE = 'average transmission season temperature vs bite rate', XTITLE = 'Avg temp (C)', $  
;   YTITLE = 'bite rate' 
    
;**************************************************************************

end

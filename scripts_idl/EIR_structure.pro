pro EIR_structure

;the purpose of this program is to compile a data set for each study site in the 
; EIR database that contains the Average Temperature, min Temp, maxTemp and rainfall 
; for the transmission season during the study and the climatology of the transmission season 
fixSeason=mara_colormap()
xx = fixSeason[0,*]
yy = fixSeason[1,*]
startmo = fixSeason[2,*]
endmo = fixSeason[3,*]
months = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec']

;read in the original csv file
eirfile = '/home/mcnally/luce_sites/EIR_georeferencedv7_2IDL.csv'
valid = query_csv(eirfile, info) & print, valid, info ;info is also a structure with name, type, lines, nfields
losfile = '/home/mcnally/luce_sites/LOS.csv' ; this is lenght of season from studies 
valid = query_ascii(losfile,info) & print, valid, info

;header=['country','Place','Long_Lat_Source','Long','Lat','LL_source','Land_Use','Study_Date','Start_Month','Start_Year', $
;        'End_Month','End_Year','Sporozoite_Index','SI_method','SI_calc','Biting_Rate','BR_method','BR_calc','EIR', $
;        'EIR_convert','EIR_calc','Seasonality','Seas_meaning','Rel_EIR_AnGam','Rel_EIR_AnFun','Rel_EIR_Other',$
;        'Rel_EIRcalc','Citation']

buffer = read_csv(eirfile, count = count, missing_value = -999 )
buffer2 = read_ascii(losfile, missing_value=-999)

;from mara_colormap.pro., SOS and EOS for each site(x,y)
;startmo = fixedSOS(x[*], y[*]) ;the start of season read off the bmp map some of these are 13 for all yr long./.
;endmo = fixedEOS(x[*], y[*]) 

twelvs = intarr(n_elements(startmo)) & twelvs[*] = 12
LOS = intarr(n_elements(startmo))

;calculate the length of the season (LOS)
ez = where(startmo lt endmo) &  LOS(ez) = endmo(ez) - startmo(ez)
hd = where(startmo ge endmo) &  LOS(hd) = (twelvs(hd) - startmo(hd)) + endmo(hd)

;***************************************************************
;this section will match up the time series lat lons with the EIR file***

;create the col that matches the filename of interest...
lon100 = round(buffer.field04);the field indices changes when I added 'header' to the structure
lat100 = round(buffer.field05)

;move to the directory where the time series are located.
sitedir = '/gibber/Data/ecmwf/100KM/sites/'
cd, sitedir

;this loop makes a list (vector) of the filenames in EIR order so that the indexing matches up.
infile = strarr(n_elements(lon100))
for j = 0,n_elements(lon100)-1 do begin
  fname = strcompress('EIR_TP_lat'+string(lat100[j])+'lon'+string(lon100[j])+'.csv', /remove_all)
  infile[j] = file_search(fname)
endfor

;initialize the arrays for temp and precip
Tavg = fltarr(n_elements(infile),228);12months*19yrs=228
Tmin = fltarr(n_elements(infile),228)
Tmax = fltarr(n_elements(infile),228)
rain = fltarr(n_elements(infile),228)

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

;test plots*********
;0=Benin, 44=Burundi
;p1=plot(Tavg[44,*])
;p2=plot(Tmin[44,*],color='cyan', /overplot)
;p3=plot(Tmax[44,*],color='red',  /overplot)
;*******************************************************

 ;make a vector of months to add to temperature file (infile)
  mocol = intarr(n_elements(ts.field2)) ;228, 19x12
  mo = indgen(12)+1 & print, mo
  
  MTemp = fltarr(193,12,19);all files, 12 months, 19 years
  Mclim = fltarr(193,12) ;all files monthly short term mean 
  month_index=intarr(12,19)
  
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
;use mclim for the climatology for each transmission season later
  for f=0,n_elements(lon100)-1 do begin; all 193 sites....
    for g=0,n_elements(months)-1 do begin ;make a month cube for each month
      mtemp[f,g,*]=Tavg(f,month_index[g,*]) ;f=0,g=0 will give all benin januaries
      mclim[f,g]=mean(mtemp[f,g,*]);  f=0,g= will give the short term mean of benin januaries 
  endfor;g
 endfor;f
  
  ;*******************************testplots*********************************************************************
  ;Benin season = May-Oct
  ;ok for now, now I need to look at the start of season business
;  tt=0 ;benin=0
;  clr=['red','orange','yellow','green','blue']
;  yy=indgen(19)+1978
;  p1=plot(yy,intarr(19)+tavg(tt,4),yrange=[23,28],view_title = string(buffer.field01[tt]))
;  count=0
;  for pp=5,9 do begin 
;    p1=plot(yy,intarr(19)+Tavg[tt,pp], color=clr[count], /overplot)
;    count++ 
;  endfor  
  
  ;Burundi season=Nov-April
;*********************************************************** 
; tt=44 ;burundi
; transseason = [11,12,1,2,3,4]
;  clr=['red','orange','yellow','green','blue']
;  yy=indgen(19)+1978
;  p1=plot(yy,intarr(19)+tavg(tt,transseason[0]),yrange=[15,25],view_title = string(buffer.field01[tt]))
;  count=0
;  for pp=1,5 do begin 
;    p1=plot(yy,intarr(19)+Tavg[tt,transseason[pp]], color=clr[count], /overplot)
;    count++ 
;  endfor 

;*******************************************
;length of season, start of season issues: 7/6/11
;this section combineds the info on start of season from the AMMA maps
;with information on the length of the season from the site specific studies
;I needed to associate a start month with the studies so that I could extract
;relevant temperature data. The result is the adjusted start of season (AdjSOS)

;studymid = fltarr(147) ;what was I thinking here?!
;AdjSOS   = fltarr(147)

studymid = fltarr(193) 
AdjSOS   = fltarr(193)

;an vector with the midpoint of tranmission season according to the MAP
mapmid= (float(LOS/2))+startmo ;yes, LOS is from the map

index = where(mapmid gt 12);find places where dec-jan crosses
mapmid(index) = mapmid(index)-12 ;fix it..

studyLOS = buffer2.field1[*] ;from the excel file

;data points that need to be excluded this part seem fine...all the -999s made it to the right place
nostart = where((startmo eq  0), count, complement=start) 
allstart= where((startmo eq 13),count,complement=start); I should modify this 8/18
;startmo(nostart)= 888

;nolos   = where((studyLOS eq -999) or (studyLOS eq 0) or (studyLOS eq 12),countL,complement=yesLOS)
studylos(nolos) = -999
nodata = where((startmo eq -999) or (studyLOS eq -999), countno, complement=good);somehow studylos is not being omitted

studymid(good) = (studyLOS(good))/2
studymid(nodata) = -999;finds the halfway point of the season
studylos(nodata)=-999;had to add this one in...why didn't I? Why did I do the sudymid correctly?

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

;does this handle -999 yes, count=0 when there are -999s, is my indexing ok?
for g=0,n_elements(AdjSOS)-1 do begin ;this loops through each site to define the start month

  ;g=?? benin, 43=no data 44=burundi, 56=sneaky bastard -- there are zeros at the begining...
  start = where((mocol eq AdjSOS[g]) , count) ;mocol=1:12, 5 means May
  if (count eq 0) then start = allmo ;
  i=0  &  k=0 ;this adds a month to the vector of indices that need to be captured....
  for h=0,n_elements(yr)-1 do begin ;one start month (e.g. April) for ea. year
    for j=0,studyLOS[g]-1 do begin ;for g studylos=6
      
      index[g,k] = start[h]+j  & k++ ;this will save the indices we need to extract correct months...for each site
      
      if j eq studyLOS[g] then continue ;advance h...is there a way to fill these in with something else?SOU
    endfor ;j
  endfor;h

endfor;g


;ok, so now that I have the indices I need to go back the ts vectors and pull out the relevant data!

TavgEIR = fltarr(n_elements(startmo), n_elements(yr)*12)
TminEIR = fltarr(n_elements(startmo), n_elements(yr)*12)
TmaxEIR = fltarr(n_elements(startmo), n_elements(yr)*12)
rainEIR = fltarr(n_elements(startmo), n_elements(yr)*12)

;sooo...how are values sneaking in there when adjSOS and map SOS (startmo) are 999/-999?
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
bufferNew = create_struct(buffer, 'mapStart',startmo, 'adjstart',AdjSoS, 'trans_Tavg',GrandTavg,'trans_Tmin', $
                       GrandTmin, 'trans_Tmax', GrandTmax, 'trans_rain', GrandRain)
;help, /struct, bufferNew ;now there are 32 cols, 193 rows
write_csv,'/home/mcnally/luce_sites/EIR_withEnv.csv', bufferNew

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
    ;junk
    ;
;nostart = where(startmo eq 13 OR studyLOS eq 0, count);these are yr round (map) or 0's in the EIR sheet
;startmo(nostart) = -999. ;fill in these values with a -999
;nostudy = where(studyLOS eq -999.,count); i guess some studyLOS were -999 (there are 0s and Na's in the original data)
;startmo(nostudy) = -999.
;offmap=where(startmo eq 0., count); when the point falls in white space...
;startmo(offmap) = -999.
;nodata = where(startmo eq -999, count, complement=good);compile that so it is all no data for startmo
end

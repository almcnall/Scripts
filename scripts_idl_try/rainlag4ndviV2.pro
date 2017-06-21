pro rainlag4ndvi

;the purpose of this program is to make a matrix of lagged dekadal rainfall data so that 
;I can play with correlations with NDVI. This should be more straight forward than the soil 
;lags since the data is continuous and in dekads.
; gosh, what was i thinking this is weird.

rfile = file_search('/jabber/Data/mcnally/AMMARain/RFE_UBRFE_and_station_dekads.csv')
rain = read_csv(rfile)
rfe = transpose(reform(rain.field1, 36,4))
ubrfe = transpose(reform(rain.field2, 36,4))
station = transpose(reform(rain.field3,36,4))

nfile = file_search('/jabber/Data/mcnally/AMMAVeg/avergeNDVI_WK12MF_TK.csv')
ndvi = read_csv(nfile)

ndvi1 = transpose(reform(ndvi.field1,36,4))
lag=indgen(36)

;check out the first difference of NDVI....why?
shift = shift(ndvi1[0,*],1)
diff = ndvi1[0,*] - shift

;what would the cross corr between rainfall and ndvi change tell you?
;result=c_correlate(reform(rain[yr,*],36), fpoi[*,yr]-0.14,lag) &$
;seems like I want that cummulative rainfall table - generated from station and rfe2 if available...
;try some moving thirty day totals....

;concatinate the two rainfall timeseries together so that I can calc the previous 30 days (3 dekads) or 20 or 50

tsrain = rain.field1
tsrain2 = rain.field2
tsrain3 = rain.field3

table = fltarr(144)
table2 = fltarr(144)
table3 = fltarr(144)

;try with 1,2,3 dekad totals -- the 40 day accumulation seems best.
for i=1,n_elements(table)-1 do begin &$
   buffer1 = [tsrain[i-3],tsrain[i-2],tsrain[i-1],tsrain[i]] &$
   buffer2 =  [tsrain2[i-3],tsrain2[i-2],tsrain2[i-1],tsrain2[i]] &$
   buffer3 =  [tsrain3[i-3],tsrain3[i-2],tsrain3[i-1],tsrain3[i]] &$
   
   table[i] = total(buffer1) &$
   table2[i] = total(buffer2) &$
   table3[i] = total(buffer3) &$
endfor

;now correlate the 40 day total (table) values with the NDVI
;table=reform(table,36,4)
 lag = [0,1,2,3,4,5,6]
 result = c_correlate(table,ndvi.field1,lag) & temp = plot(result,'r', layout = [3,1,1])& print, max(result)
 result = c_correlate(table,ndvi.field3,lag) & temp = plot(result,'orange', /overplot)& print, max(result)
 result = c_correlate(table,ndvi.field5,lag) & temp = plot(result, 'green',/overplot)& print, max(result)
temp.title = 'rfe-ndvi max xcorr = 0.81'

;correlation is better for the other one :) 
  lag = [0,1,2,3,4,5,6]
 result = c_correlate(table2,ndvi.field1,lag) & temp = plot(result,'r', layout = [3,1,2], /current) & print, max(result)
 result = c_correlate(table2,ndvi.field3,lag) & temp = plot(result,'orange', /overplot)& print, max(result)
 result = c_correlate(table2,ndvi.field5,lag) & temp = plot(result, 'green',/overplot)& print, max(result)
 temp.title = 'ubrfe-ndvi max xcorr = 0.83'
 
  lag = [0,1,2,3,4,5,6]
 result = c_correlate(table3,ndvi.field1,lag) & temp = plot(result,'r',layout = [3,1,3], /current)& print, max(result)
 result = c_correlate(table3,ndvi.field3,lag) & temp = plot(result,'orange', /overplot)& print, max(result)
 result = c_correlate(table3,ndvi.field5,lag) & temp = plot(result, 'green',/overplot)& print, max(result)
 temp.title = 'station-ndvi max xcorr = 0.76' 
 
 ;**these are the scatter plots for the max correlation at lag 3 for RFE/ubRFE, station is different.
 wklag3 = shift(ndvi.field1,-3)
 tklag3 = shift(ndvi.field5,-3)
 p1 = plot(table,wklag3,'+', title='ndvi lag3 vs 30 day rainfall accum. RSQ=0.81, 0.80')
 p2 = plot(table,tklag3,'r+',/overplot)

;now look at the anomalies...
;generate the average curve...
cube = transpose(reform(table,36,4)); RFE
cube2 = transpose(reform(table2,36,4))
cube3 = transpose(reform(table3,36,4))

;just for the RFE2
temp = mean(cube,dimension = 1)
curve = [temp, temp, temp, temp]
anom = table - curve

temp = mean(cube2,dimension = 1)
curve2 = [temp, temp, temp, temp]
anom2 = table2 - curve2

temp = mean(cube3,dimension = 1)
curve3 = [temp, temp, temp, temp]
anom3 = table3 - curve3


temp = mean(ndvi1, dimension = 1)
ncurve = [temp, temp, temp, temp]
nanom = ndvi.field1 - ncurve

lag = [-3,-2,-1,0,1,2,3]
result=c_correlate(anom,nanom, lag)
p1=plot(result)
p1.title = 'xcorr of ndvi and rainfall anomalies'
p1.name = 'RFE'

result = c_correlate(anom2,nanom, lag)
p2=plot(result, /overplot, 'g')
p2.name = 'UBFRE'

result = c_correlate(anom3,nanom, lag)
p3=plot(result, /overplot, 'b')
p3.name = 'station'

!null = legend(target=[p1,p2,p3], position=[0.2,0.3]) 

;******************************************************************************************************************
;*******************************************************************************************************************

;here i create an array the same size as rain but shifted by -1 year so that
;when i am e.g. looking for the previous 90 days from march i end up in december.
;it won't work for 2005 since i have no data for 2004.
lhs=fltarr(4,36)
lhs[*,*]=!values.f_nan

;too lazy to loop
lhs[*,1]=rain[*,0]
lhs[*,2]=rain[*,1]
lhs[*,3]=rain[*,2]

;the new double sized array 365*2 (sorry leap year!)
dblrain=[lhs, rain]

openu,1,sfile
readu,1,sdate
close,1

lagtable=fltarr(90,n_elements(sdate[0,*]))
cumtable=fltarr(90,n_elements(sdate[0,*]))

;for each day
for i=0,n_elements(sdate[0,*])-1 do begin
  row=sdate[0,i]-2005
  is = 365-(90-sdate[3,i])
  ie = 365+sdate[3,i]
  lagtable[*,i]=dblrain(is:ie-1, row);index start to index end, row
endfor

;ofile='/jabber/Data/mcnally/AMMARain/rain4soil/rainlag4soil_fallow110.dat'
;openw,1,ofile
;writeu,1,lagtable
;close,1

print, 'hold'
;now create a 71(68)x90 table that is the accumulations for 0-90 days, not just the raw values...uh, is this diff from before?
for i=0,n_elements(lagtable[0,*])-1 do begin &$;for each day (71) [row]
  for j=0,n_elements(lagtable[*,0])-1 do begin &$;for each time slot 0:90 [col]
;   @j=0 lagtable[0:89,i] in position 0
;   @j=1 lagtable[1:89,i] in position 1
   ;add up all 90 days and store that in position 89
    cumtable[j,i]=total(lagtable[j:90-1,i],/nan)   
  endfor
endfor

print, 'hold here'
;check and make sure the values in the lag table match thoes in the cum. table
ofile='/jabber/Data/mcnally/AMMARain/rain4soil/raincum4soil_millet110.dat'
openw,1,ofile
writeu,1,cumtable
close, 1

;****************************************************************
;this sections gets me set up for the generalized linear model. 17 cols of SM values @ 1 depth and one col of rainfall
;not sure if this belongs in this script or not. 
ifile=file_search('/jabber/Data/mcnally/AMMASOIL/*_cube110.dat')
i=0 ; i=0 for fallow and i=1 for millet

nx=11 ;sites (11 for millet, 10 for fallow
;ny=17 ;n dates when SM was recorded
;nz=71 ;n depths where SM was recorded
ny=29 ;n dates when SM was recorded
nz=68 ;n depths where SM was recorded
sbuffer=fltarr(nx,ny,nz)

;for i=0,n_elements(ifile)-1 do begin
  openr,1,ifile[i]
  readu,1,sbuffer
  close,1

;this loop stacks up the 11 sites and replicates the appropriate rainfall vector
LOI=45; Lag-of-interest: which rainfall accumulation am i interested in?

rainvec=cumtable[LOI,*]
catsoil=reform(sbuffer[0,*,*],17,71)
catrain=rainvec
for i=1,nx-1 do begin &$
  temp=reform(sbuffer[i,*,*],17,71) &$
  catsoil=[[catsoil], [temp]] &$
  catrain=[[catrain],[rainvec]] &$
endfor

GLM=[catrain,catsoil]

;check and make sure the values in the lag table match thoes in the cum. table
ofile='/jabber/Data/mcnally/AMMARain/rain4soil/GLM_soil_rain45_fallow.dat'
openw,1,ofile
writeu,1,glm
close, 1

;*********************************************************************

print, 'hold'


end




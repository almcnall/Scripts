pro rainlag4ndvi

;the purpose of this program is to make a matrix of lagged dekadal rainfall data so that 
;I can play with correlations with NDVI. This should be more straight forward than the soil 
;lags since the data is continuous and in dekads.

;this is just the time series for the pixel where the sites are located. 365 colsx 4 rows
rfile = '/jabber/Data/mcnally/AMMARain/rain4soil/ROI_theo.rain.2005_2008_dekads.dat' ;
nfile = '/jabber/Data/mcnally/AMMAVeg/NDVI_at_MF110.dat'

rain=fltarr(4,36)
ndvi=fltarr(3,2,144)


openu,1,rfile
readu,1,rain
close,1

openu,1,nfile
readu,1,ndvi
close,1

ndvi=reform(ndvi,3,2,36,4);breaks it up into two years (x,y,dek,yr)
mpoi=ndvi[0,0,*,*]
fpoi=reform(ndvi[3-1,2-1,*,*],36,4)
lag=indgen(36)

;check out the first difference of NDVI
dfpoi=shift(fpoi,1)
diff=dfpoi-fpoi


yrarray=[2005,2006,2007,2008] ;0=2005, 1=2006

for yr=0,3 do begin &$
 ;result=c_correlate(reform(rain[yr,*],36), fpoi[*,yr]-0.14,lag) &$
 result=c_correlate(reform(rain[yr,*],36), diff[*,yr],lag) &$
 print, 'year = '+string(yrarray[yr]) &$
 print, 'lag =' +string(where(result eq max(result))) &$
 print, 'max corr =' +string(max(result)) & print, 'max NDVI ='+string(max(fpoi[*,yr])) &$
 print, 'total rainfall'+string(total(rain[yr,*])) &$
endfor

test=plot(result)

test=plot(rain[yr,*])
test=plot((fpoi[*,yr]-0.14)*100, /overplot, 'g',title='2008 10-day NDVI and rainfall', ytitle='rainfall (mm/dekad), NDVI*100')

;try some moving thirty day totals....

;concatinate the two rainfall timeseries together so that I can calc the previous 30 days (30 dekads) or 20 or 50
zeros=fltarr(4)
tsrain=[[rain[0,*]], [rain[1,*]], [rain[2,*]],[rain[3,*]]]
tsrain=[zeros,transpose(tsrain)]
table=fltarr(144)

;try with 1,2,3 dekad totals
for i=1,n_elements(table)-1 do begin &$
   buffer=[tsrain[i-3],tsrain[i-2],tsrain[i-1],tsrain[i]] &$
   table[i]=total(buffer) &$
endfor

;now correlate the 30 day total (table) values with the NDVI
table=reform(table,36,4)
for yr=0,3 do begin &$
 ;result=c_correlate(table[*,yr], diff[*,yr],lag) &$
 result=c_correlate(table[*,yr],fpoi[*,yr]-0.14,lag) &$
 print, 'year = '+string(yrarray[yr]) &$
 print, 'lag =' +string(where(result eq max(result))) &$
 print, 'max corr =' +string(max(result)) &$
endfor

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
;now create a 71(68)x90 table that is the accumulations for 0-90 days, not just the raw values
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




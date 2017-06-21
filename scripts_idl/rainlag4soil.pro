pro rainlag4soil

;the purpose of this program is to make a matrix of lagged rainfall data so that 
;I can play with correlations with soil moisture (at a given time and depth...). SO the
;most important part with be the soil moisture time vector and using that to pull
;the rainfall at different lags.

;this is just the time series for the pixel where the sites are located. 365 colsx 4 rows
rfile='/jabber/Data/mcnally/AMMARain/rain4soil/ROI_theo.rain.2005_2008.dat' ;where did i make this file?!
sfile='/jabber/Data/mcnally/AMMASOIL/smdates4rainlag_fallow.dat' ;this is different for fallow and millet!

;sdate=intarr(5,71); (millet)yr.m.day.hr,doy
sdate=intarr(5,68);(fallow)yr.m.day.hr,doy

rain=fltarr(365,4);I eliminated the last day of december 2008 b/c i did not want 366 days.

openu,1,rfile
readu,1,rain
close,1

;here I create an array the same size as rain but shifted by -1 year so that
;when I am e.g. looking for the previous 90 days from March I end up in december.
;it won't work for 2005 since i have no data for 2004.
LHS=fltarr(365,4)
LHS[*,*]=!values.f_nan

;too lazy to loop
LHS[*,1]=rain[*,0]
LHS[*,2]=rain[*,1]
LHS[*,3]=rain[*,2]

;the new double sized array 365*2 (sorry leap year!)
dblrain=[LHS, rain]

openu,1,sfile
readu,1,sdate
close,1

lagtable=fltarr(90,n_elements(sdate[0,*]))
cumtable=fltarr(90,n_elements(sdate[0,*]))

;for each day
for i=0,n_elements(sdate[0,*])-1 do begin
  row=sdate[0,i]-2005
  is = 365-(90-sdate[4,i])
  ie = 365+sdate[4,i]
  lagtable[*,i]=dblrain(is:ie-1, row);index start to index end, row
endfor

;ofile='/jabber/Data/mcnally/AMMARain/rain4soil/rainlag4soil_fallow.dat'
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
ofile='/jabber/Data/mcnally/AMMARain/rain4soil/raincum4soil_fallow.dat'
openw,1,ofile
writeu,1,cumtable
close, 1

;****************************************************************
;this sections gets me set up for the generalized linear model. 17 cols of SM values @ 1 depth and one col of rainfall
;not sure if this belongs in this script or not. 
ifile=file_search('/jabber/Data/mcnally/AMMASOIL/*_cube.dat')
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




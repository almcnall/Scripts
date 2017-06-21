pro rainlag4soilv3

;modified this file on 8/24 to make matrix with station rainfall values. the purpose of this program is to make a matrix 
;of lagged rainfall data so that chose a moving average/API window size.
;V1 is for the soil neutron probe measurements associated
;with file 210-CE.Swsan_Nc.csv, where the dates are arbitrary. This Version 2.0 is for the volumetric 
;soil mosture measurments at one millet (13.644;2.6299) and one fallow (13.6476;2.6337)site.

;10/29/12 - can i get this to work for NDVI as well?

;2x144 staion and RFE dekadal rainfall 2005-2008
;rfile=file_search('/jabber/Data/mcnally/AMMARain/RFE_and_station_dekads.csv') 
rfile = file_search('/jabber/Data/mcnally/AMMARain/RFE_UBRFE_and_station_dekads.csv')

rain = read_csv(rfile)
rfe = rain.field1
ubrfe = rain.field2
sta = rain.field3
sumtable=fltarr(9,144);each day (row) will have a col for the previous n days of rainfall total. 
;for each year (col)
for i=0,n_elements(sumtable[*,0])-1 do begin &$
  for j=8, n_elements(sumtable[0,*])-1 do begin &$
  sumtable[i,j]=total(sta[j-i:j]) &$
  endfor &$
endfor

rfetable=fltarr(9,144);each day (row) will have a col for the previous n days of rainfall total. 
;for each year (col)
for i=0,n_elements(rfetable[*,0])-1 do begin &$
  for j=8, n_elements(rfetable[0,*])-1 do begin &$
  rfetable[i,j]=total(rfe[j-i:j]) &$
  endfor &$
endfor

ofile1='/jabber/Data/mcnally/AMMARain/lagtable_station_dekads.csv'
ofile2='/jabber/Data/mcnally/AMMARain/lagtable_rfe_dekads.csv'

write_csv,ofile1,sumtable
write_csv,ofile2,rfetable

;will these rainfall accumulations be useful for pan et al. (2003)?
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




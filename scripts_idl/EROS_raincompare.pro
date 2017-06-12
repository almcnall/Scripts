pro EROS_raincompare

;this script will compare the seasonal totals for the different rainfall products
;FTIP, RFE_gdas, Theo, ha, maybe I should compare gdas too since that is what i justed used :(

fdir = '/jower/LIS/data/AF_FTIP/'     ;daily ftip 
;rdir = '/jower/LIS/data/Biased_Orig/' ;three hourly rfe2_gdas
rdir='/jabber/LIS/Data/CPCOriginalRFE2/' ;daily rfe

;gdir = '/jabber/LIS/Data/GDAS/'       ;three hourly gdas
;udir = '/jabber/LIS/Data/ubRFE2.02.19.2012/'  ;daily unbiased RFE2
;tdir = '

yr=['2005','2006','2007','2008']

;read in ftip and find the seasonal totals for 2005-2008
nx=1501
ny=1601

buffer=fltarr(nx,ny)
stack=fltarr(nx,ny)
ftiptot=fltarr(nx,ny,n_elements(yr))

for i=0,n_elements(yr)-1 do begin
  ifile=file_search(fdir+'*'+yr[i]+'.{06,07,08,09}*.tif') 
  for j=0,n_elements(ifile)-1 do begin 
    close,/all
    openr,1,ifile[j]
    readu,1,buffer
    close,1
    stack=buffer+stack
  endfor;j

;an array with seasonal totals for each year (4 maps..)  
  ftiptot[*,*,i]=stack
;region of interest (13:14N, 1.5:3E)
ax = (20+1.5)/0.05
bx = (20+1.5)/0.05

ay = (40+13)/0.05

;write the seasonal totals out to a file for each year  
  ofile=strcompress('/jabber/LIS/OUTPUT/Rain_compare/'+strmid(ifile[0],15,22)+'JJAS.img', /remove_all)
  openw,1,ofile
  writeu,1,stack
  close,1
endfor;i


;0.25 degree from theo... 
tfile='/jabber/Data/mcnally/AMMARain/rain4soil/theo_daily2005_2008.dat'
tx = 6
ty = 4
tz = 1461 ;(365*4)+1

train=fltarr(tx,ty,tz)

openr,1,tfile
readu,1,train

print, 'hold'

end
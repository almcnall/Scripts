pro LIS_dek2month
; 7/31 this script will agreegate the LIS dekad output to month so that i can use the trend scripts.
; first I need to grab the soil moisiture (x4), rainfall, SWI, ET with cdo over on discover
; this script is expecting all of the dekads to be in separate files...but they are not, do that in IDL or CDO?
; i think that i have done this in CDO with cdo monmean SWI_Noah_2001_2014.nc SWI_Noah_MO_2000_2014.nc

idir = '/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/'
odir = '/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/monthly/'

nx = 751
ny = 801

NDVI = bytarr(nx,ny)
avgNDVI = bytarr(nx,ny)
for y = 2001,2011 do begin 
  for m = 1,12 do begin 
      mm = STRING(FORMAT='(I2.2)',m)
      ;this way gets all values from all months-- add a year loop for greg/narcissa
      ifile = file_search(strcompress(idir+'data.'+string(y)+'.'+mm+'*.img',/remove_all))
      NDVItot = bytarr(nx,ny,n_elements(ifile))
    for f = 0,n_elements(ifile)-1 do begin
      openr,1,ifile[f]
      readu,1,NDVI
      close,1
    
      NDVItot[*,*,f] = NDVI
    endfor 
      avgNDVI = mean(NDVItot,dimension=3)
      avgNDVI=(avgNDVI-100)/100
      avgNDVI(where(avgNDVI lt 0.))= !values.f_nan
    
    ;fix the out name for the monthly files...
      ofile = odir+strmid(ifile[0],54,9)+mm+'.img'
      openw,1,ofile
      writeu,1,avgNDVI
      close,1
      print, ofile 
  ;    temp=image(reverse(avgndvi,2), rgb_table=4,title=strmid(ofile,56,7))
    endfor
endfor
 print, 'hold here'
end
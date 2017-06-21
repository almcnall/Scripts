pro pet_clim

;the purpose of this program is to generate average daily PET for input into the LIS-WRSI
;I downloaded the daily data from the NASA server, but it could have come from EROS 
;I think i just need to stack um and average in the 3rd dimension.
;NROWS         181
;NCOLS         360
yy = ['02','03','04','05','06','07','08','09','10','11','12']
mm = ['01','02','03','04','05','06','07','08','09','10','11','12']

nx = 360
ny = 181
ingrid = uintarr(nx,ny)
cube = uintarr(nx,ny,n_elements(yy),366)
cube[*,*,*,*] = !values.f_nan
 
for y = 0,n_elements(yy)-1 do begin &$
  yr = yy[y] &$
  ifile = file_search('/raid/chg-mcnally/PET_USGS_daily/et'+yr+'*.bil') &$
  for i = 0, n_elements(ifile)-1 do begin &$
    openr,1,ifile[i] &$
    readu,1,ingrid &$
    close,1 &$
    byteorder,ingrid,/XDRTOF &$
  
    cube[*,*,y,i] = ingrid &$
  endfor &$
endfor

;select a leap year to help with naming the clim files with month, date....some years will need feb 29, althouhg it might be a funny avg..
namelist = file_search('/raid/chg-mcnally/PET_USGS_daily/et04*.bil')
;still upside down, need to swap byte order and write out. get the day from ifile
avgout = mean(cube,dimension=3, /nan) & help, avgout
  
  for i = 0,n_elements(namelist)-1 do begin &$
   ofile = strcompress('/raid/chg-mcnally/PET_USGS_daily/CLIM/etXX'+strmid(namelist[i],37,4)+'.bil', /remove_all) & print, ofile &$
   
   ogrid = avgout[*,*,i] &$
   ogrid = uint(ogrid) &$
   byteorder,ogrid,/XDRTOF &$
   
   openw,1,ofile &$
   writeu,1,ogrid &$
   close,1 &$
  endfor
   
   
   

  

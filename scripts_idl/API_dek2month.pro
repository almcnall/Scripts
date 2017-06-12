pro API_dek2month
;the purpose of this script is to get the average API for each month...
;also use this script for the avg estimated soil moisture from NDVI

idir = '/jabber/LIS/Data/API_sahel/'
odir = '/jabber/LIS/Data/API_sahel/monthly/'

;ifile = file_search('/jabber/chg-mcnally/filterNDVI_soilmoisture_2001Jan_2012Oct_lag2.img')
ifile = file_search('/jabber/chg-mcnally/API_2001_2012_sahel_v2.img')
;odir = '/jabber/chg-mcnally/filterNDVI_sahel/monthly/'

nx = 720
ny = 350
nz = 428 ; filtered=425, API=428
filtered = fltarr(nx,ny,nz)
apigrid = fltarr(nx,ny,nz)

openr,1,ifile
readu,1,apigrid ;filtered
close,1
;*******************************************************************************
;change the stack into individual dekads
;fnames = strmid(file_search('/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/data.*img'),54,18)
;for i = 0,n_elements(filtered[0,0,*])-1 do begin &$
;  ogrid = filtered[*,*,i] &$
;  
;  ofile = strcompress('/jabber/chg-mcnally/filterNDVI_sahel/SMest_'+fnames[i],/remove_all) &$
;  ofile = strcompress('/jabber/chg-mcnally/
;  print, ofile &$
;  openw,1,ofile &$
;  writeu,1,ogrid &$
;  close,1 &$
;endfor

;change the stack into individual dekads
;yyyy=[2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012]
;y=0
;cnt=0
;for i=0,n_elements(apigrid[0,0,*])-1 do begin &$
; for y=0,36-1 do begin &$
;  for m=1,12 do begin &$
;    for d=1,3 do begin &$
;      ofile=strcompress('/jabber/LIS/Data/API_sahel/APIsahel_'+string(yyyy[y])+string(format='(I2.2)',m) $
;                         +string(d)+'.img',/remove_all) &$
;;      openw,1,ofile &$
;;      writeu,1,apigrid[*,*,cnt] &$
;;      close,1 &$
;      
;      print, ofile &$
;      cnt++ &$
;      print, cnt &$
;    endfor &$;d &$
;  endfor &$;m &$
; endfor &$; y &$
; y++ &$
;endfor;i
;***************************************************************************************************



;uh, what is this loop doing??
API = fltarr(nx,ny)
avgAPI = fltarr(nx,ny)

for y = 2001,2012 do begin
  for m = 1,12 do begin 
      mm = STRING(FORMAT='(I2.2)',m)
      ifile = file_search(strcompress(idir+'APIsahel_'+string(y)+mm+'*.img',/remove_all))
      ;ifile = file_search(strcompress('/jabber/chg-mcnally/filterNDVI_sahel/SMest_data.'+string(y)+'.'+mm+'*.img',/remove_all))
      APItot = fltarr(nx,ny,n_elements(ifile))
    for f = 0,n_elements(ifile)-1 do begin
      if n_elements(ifile) eq 1 then break
      openr,1,ifile[f]
      readu,1,API
      close,1    
      APItot[*,*,f] = API
    endfor 
      avgAPI = mean(APItot,dimension=3, /nan)
      ;avgNDVI=(avgNDVI-100)/100
      ;avgNDVI(where(avgNDVI lt 0.))= !values.f_nan
    
    ;fix the out name for the monthly files...
      ofile = strcompress(odir+strmid(ifile[0],27,9)+string(y)+mm+'.img', /remove_all)
      ;ofile = strcompress(odir+strmid(ifile[0],37,10)+string(y)+mm+'.img', /remove_all) 
      
      openw,1,ofile
      writeu,1,avgAPI
      close,1
      print, ofile 
  ;    temp=image(reverse(avgndvi,2), rgb_table=4,title=strmid(ofile,56,7))
    endfor
endfor
 print, 'hold here'
end
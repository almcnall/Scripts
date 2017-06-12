;the purpose of this program is to calculate the short term
;means of the noah output. 


;*****************calculate the short-term mean for the sm03/evap so i can calc anomalies******************
;e.g. get the first dekad for all years (10) and put them into a monthly cube, take the average of the cube and write it out
;******this code is not working properly!!! not sure why. see day2dek for something that does work.
nx = 720
ny = 350
stmmap = fltarr(nx,ny,36)
ingrid = fltarr(nx,ny)
cnt = 1 ;start at one since it is dek1 not dek0
for m = 1,12 do begin &$
  for d = 1,3 do begin &$
  mm = string(format='(i2.2)',m) &$
  dk = string(format='(i2.2)',d) &$
  ifile = file_search(strcompress('/jabber/sandbox/mcnally/EXPA02_dekads/evap/{2005,2006,2007,2008,2009,2010}'+mm+dk+'*img', /remove_all))  &$
       ;print, ifile &$
       cube = fltarr(nx,ny,n_elements(ifile)) &$   
    for f = 0,n_elements(ifile)-1 do begin &$
      openr,1,ifile[f]  &$
      readu,1,ingrid &$
      close,1 &$
    
      ingrid=reverse(ingrid,2) &$
      ;why do i have a crazy small value?
      ;ingrid(where(ingrid lt 0))=!values.f_nan
      cube[*,*,f]=ingrid &$
    endfor &$
    sm03avg = mean(cube, dimension=3, /nan) &$
    ofile = strcompress(strmid(ifile[0],0,43)+'evap.stm_dek'+$
            string(format='(i2.2)',cnt),/remove_all) &$
;    print, ofile &$
;    openw,1,ofile  &$
;    writeu,1,sm03avg &$
;    close,1 &$
    stmmap[*,*,cnt-1]=ingrid &$
    cnt++ &$
  endfor  &$ ;d
  
endfor  ;m 
print, 'hold'

;make sure things look ok -- they do look better than they did earlier!!
ingrid=fltarr(nx,ny)
cube=fltarr(nx,ny,36)
test=file_search('/jabber/sandbox/mcnally/EXPA02_dekads/evap/evap.stm*')
for i=0,n_elements(test)-1 do begin &$
  openr,1,test[i] &$
  readu,1,ingrid &$
  close,1 &$

  cube[*,*,i]=ingrid &$
endfor

;grab some timeseries of interest
lon = 3
lat = 14
xx = floor((lon+19.95)*10) 
yy = floor((29.95-lat)*10)
temp = plot(cube[xx,yy,*], 'm',/overplot)
end
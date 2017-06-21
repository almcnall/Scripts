pro PAW_NSM_corr 

;the purpose of this program is to find which PAW (q25/50/75) has the highest correlation with NSM (during the same dekads...)
;try it for one year and see how it goes -- I hope that this doesn't bomb!

;always handy for checking
;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5) / 0.10)

;so read in the PAW files
ifile = file_search('/jabber/chg-mcnally/sahelPAW_q*_dynSOS.img') & help, ifile
nfile = file_search('/jabber/chg-mcnally/filterNDVI_soilmoisture_2001Jan_2012Oct_lag2.img')
sfile = file_search('/jabber/chg-mcnally/SOSsahel_*.img')
lfile = file_search('/home/mcnally/regionmasks/LGPsahel.img')


nx = 720
ny = 350
nz = 12
nlgp = 22
nzz = 425 ;yes

sgrid = fltarr(nx,ny,nz)
ngrid = fltarr(nx,ny,nzz)
pgrid = fltarr(nx,ny,nlgp,nz)
lgpgrid = bytarr(nx,ny)

openr,1,nfile
readu,1,ngrid
close,1
pad = fltarr(nx,ny,7)
pad[*,*,*] = !values.f_nan
full = [ [[ngrid]], [[pad]] ]
ncube = reform(full,nx,ny,36,12)

;for f = 0,2 do begin &$
f = 1
openr,1,ifile[f] &$
readu,1,pgrid &$
close,1 &$

openr,1,sfile[f] &$
readu,1,sgrid &$
close,1 &$

openr,1,lfile &$
readu,1,lgpgrid &$
close,1  &$

;get the correct chuck of nsm according to the PAW SOS (I can also try this with static SOS, just swap in the clim-map.
  x = wxind  &$
  y = wyind &$
  lgp = lgpgrid[x, y] &$
dyn_ngrid = fltarr(lgp,11)
for yr = 0,10 do begin &$  
  sos = sgrid[x,y,yr] &$
  print, SOS &$
  if SOS gt 25 then print, 'ah!' &$
  dyn_ngrid[*,yr] = ncube[x,y,sos-1:sos-1+lgp-1,yr] &$
endfor

climpaw = fltarr(lgp)
climnsm = fltarr(lgp)
;look at the 2001-2011 average of PAW and NSM
for i = 0,lgp-1 do begin &$
  buffer = pgrid[wxind,wyind,i,*] &$
  buffer2 = dyn_ngrid[i,*] &$
  climpaw[i] = mean(buffer,dimension = 4, /nan)  &$
  climnsm[i] = mean(buffer2,dimension = 2, /nan)  &$
endfor;

;this will get me started for tomorrow....so, find the NSM segment, correlate it and then compare it to other SOS/PAWs
;for yr = 0,12-1 do begin
  yr = 11  &$;0=2001 &$
  ;for x = 0,nx-1 do begin
    x = axind  &$
    ;for y = 0,ny-1 do begin  
      y = ayind &$
      lgp = lgpgrid[x, y] &$
      sos = sgrid[x,y,yr] &$
      print, SOS &$
      if SOS gt 25 then continue &$
      p1 = plot(pgrid[x,y,*,yr])  &$; so where in the season did this start?
      p2 = plot(ncube[x,y,sos-1:sos-1+lgp-1,yr]*1000, 'c', /overplot) &$
      ;Q25=0.56,Q50=0.42,Q75=0.51...interesting....
      print, correlate(pgrid[x,y,*,yr],ncube[x,y,sos-1:sos-1+lgp-1,yr]) &$
endfor ;f

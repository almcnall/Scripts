;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
; This program was based on Charles' pentads.pro and computes 10-day
; accumulations of precipitation and potential evapotranspiration, and
; also climatological averages. 
; Contains a routine to convert data into image files (.bil)
;.............................................................................
; From Verdin and Klaver (2002):
; The dekad is the basic 10 day time step of agrometeorological
; monitoring in Africa. Each month of the year is divided into 3
; dekads: the 1st through the 10th, the 11th through the 20th, and a
; final dekad of 8, 9, 10 or 11 days. 'Dekad' is a technical term of
; the World Meteorological Organization. The dekad represents a
; compromise between a monthly time step, which is inadequate to
; resolve important crop growth stages, and a daily time step, which
; imposes a significant data-processing burden without a commensurate
; gain in agrometeorological information.
;
;=============================================================================
restore,'/home/candida/DATA/NARR/MEX.PREC.1979.2008.IDL' 
;=============================================================================
;   define dekadal calendar
.run
      yr1 = 1979
      yr2 = 2008
     nyrs = yr2 - yr1 + 1
     nmth = 12
     ndkd = 3
     stot = ndkd * nmth * nyrs
    caldk = intarr(stot)
    calmn = intarr(stot)
    calyr = intarr(stot)
     year = yr1
      mon = 1 
      dkd = 1
for m = 0, stot - 1 do begin
   caldk(m) = dkd 
   calmn(m) = mon
   calyr(m) = year
   dkd = dkd + 1
  if(dkd gt 3) then begin
   dkd = 1 & mon = mon + 1
  endif
  if(mon gt 12) then begin
   mon = 1 & year = year + 1
  endif
   print,m,caldk(m),calmn(m),calyr(m)
endfor
end
;
;=============================================================================
;   compute dekads PRECIP
.run
  year = yr1  &  totm = nyrs * nmth
  prec_dekad = fltarr(mlon,mlat,stot)
  dk1s = where(cal_day eq 1) & dk1e = where(cal_day eq 10)
  dk2s = where(cal_day eq 11) & dk2e = where(cal_day eq 20)
  dk3s = where(cal_day eq 21) & dk3e = dk1s - 1 ;ignore 1st element
for i = 0, mlat - 1 do begin
 for j = 0, mlon - 1 do begin
    s = 0
  for k = 0, totm - 1 do begin
    ts1 = prec(j,i,dk1s(k):dk1e(k))
   prec_dekad(j,i,s) = total(ts1,3)
    ts2 = prec(j,i,dk2s(k):dk2e(k))
   prec_dekad(j,i,s+1) = total(ts2,3)
   if (k eq totm-1) then ts3 = prec(j,i,dk3s(k):mtot-1) else $
    ts3 = prec(j,i,dk3s(k):dk3e(k+1))
   prec_dekad(j,i,s+2) = total(ts3,3)
    s = s + 3
  endfor
 endfor
endfor
end
;
loadct,13
window,0,xsize=700,ysize=500
plot,prec_dekad(50,30,*)
erase
.run
for  m = 36,72 do begin
   tvim,prec_dekad(*,*,m),/scale
   wait,0.5
endfor
end
;
moyenvert,prec_dekad,mean,sdv
erase
tvim,mean,/scale
plot,prec_dekad(35,35,*)
;
;=============================================================================
;   save data
;
save,file='/home/candida/DATA/NARR/MEX.PREC.DEKAD.1979.2008.IDL', $
     CALDK,CALMN,CALYR,MLAT,MLON,PREC_DEKAD,STOT
;
;=============================================================================
;   compute dekads PEVAP
;
restore,'/home/candida/DATA/NARR/MEX.PET.1979.2008.IDL' 
;
.run
  year = yr1  &  totm = nyrs * nmth
  pet_dekad = fltarr(mlon,mlat,stot)
  dk1s = where(cal_day eq 1) & dk1e = where(cal_day eq 10)
  dk2s = where(cal_day eq 11) & dk2e = where(cal_day eq 20)
  dk3s = where(cal_day eq 21) & dk3e = dk1s - 1 ;ignore 1st element
for i = 0, mlat - 1 do begin
 for j = 0, mlon - 1 do begin
    s = 0
  for k = 0, totm - 1 do begin
    ts1 = pet(j,i,dk1s(k):dk1e(k))
   pet_dekad(j,i,s) = total(ts1,3)
    ts2 = pet(j,i,dk2s(k):dk2e(k))
   pet_dekad(j,i,s+1) = total(ts2,3)
   if (k eq totm-1) then ts3 = pet(j,i,dk3s(k):mtot-1) else $
    ts3 = pet(j,i,dk3s(k):dk3e(k+1))
   pet_dekad(j,i,s+2) = total(ts3,3)
    s = s + 3
  endfor
 endfor
endfor
end
;
loadct,13
window,0,xsize=700,ysize=500
plot,pet_dekad(50,30,*)
erase
.run
for  m = 36,72 do begin
   tvim,pet_dekad(*,*,m),/scale
   wait,0.5
endfor
end
;
moyenvert,pet_dekad,mean,sdv
erase
tvim,mean,/scale
plot,pet_dekad(35,35,*)
;=============================================================================
;   save data
;
save,file='/home/candida/DATA/NARR/MEX.PET.DEKAD.1979.2008.IDL', $
     CALDK,CALMN,CALYR,MLAT,MLON,PET_DEKAD,STOT
;=============================================================================
;   dekadal climatology
;
restore,'/home/candida/DATA/NARR/MEX.PREC.DEKAD.1979.2008.IDL'
restore,'/home/candida/DATA/NARR/MEX.PET.DEKAD.1979.2008.IDL'
;
; create calendar vector
.run
  yr1 = 1979
  yr2 = 2008
 nyrs = yr2 - yr1 + 1
 ndkd = 36
caldkyr = intarr(stot)
  dkd = 1 
for n = 0, stot - 1 do begin
  caldkyr(n) = dkd
  dkd = dkd + 1
  if(dkd gt 36) then dkd = 1 
  print,n,caldkyr(n),calyr(n)
endfor
end
;
.run
   ppt_clim = fltarr(mlon,mlat,ndkd)
   pet_clim = fltarr(mlon,mlat,ndkd)
for m = 0, ndkd - 1 do begin
   idx = where(caldkyr eq m + 1)
   tmp = prec_dekad(*,*,idx)
   moyenvert,tmp,mean,sdv
   ppt_clim(*,*,m) = mean
   tmp = pet_dekad(*,*,idx)
   moyenvert,tmp,mean,sdv
   pet_clim(*,*,m) = mean
endfor
end
;
; loop for plotting
loadct,5
window,0,xsize=700,ysize=500
.run
for  n = 0, ndkd - 1 do begin
   tit = caldkyr(n)
   tvim,ppt_clim(*,*,n),/scale,title=tit
   wait,1
endfor
end
;
;=============================================================================
;   Convert data to (binary) image files
;
restore,'/home/candida/DATA/NARR/MEX.DOMAIN.INFO.IDL'
nonmex = where(MX_MASK eq 0)
;
; black out pixels outside of Mexico (both dekad and clim variables)
.run
 PPT = fltarr(mlon,mlat,stot)
 PET = fltarr(mlon,mlat,stot)
 for i = 0, stot - 1 do begin
   tmp = reform(PREC_DEKAD(*,*,i))
   tmp(nonmex) = -1.
   PPT(*,*,i) = tmp
   tmp = reform(PET_DEKAD(*,*,i))
   tmp(nonmex) = -1.
   PET(*,*,i) = tmp
 endfor
end
;
.run
 for n = 0, ndkd - 1 do begin
   tmp = reform(PPT_CLIM(*,*,n))
   tmp(nonmex) = -1.
   PPT_CLIM(*,*,n) = tmp 
   tmp = reform(PET_CLIM(*,*,n))
   tmp(nonmex) = -1.
   PET_CLIM(*,*,n) = tmp
 endfor
end
;
.run
  dir = '/home/candida/DATA/NARR/data.to.ENVI/'
    p = 'PPT/ppt'
    e = 'PET/pet'
    d = 0
for i = 0, stot - 1 do begin
  if (d lt 9) then s = '0' else s = ' '
  ff = strcompress(string(dir,p,calyr(i),s,caldkyr(d),'.bil'),/remove_all)
  print,ff
  out = reform(reverse(PPT(*,*,i),2))
  openw,lun,ff,/get_lun
  writeu,lun,out
  close,lun
  free_lun,lun
  ff = strcompress(string(dir,e,calyr(i),s,caldkyr(d),'.bil'),/remove_all)
  print,ff
  out = reform(reverse(PET(*,*,i),2))
  openw,lun,ff,/get_lun
  writeu,lun,out
  close,lun
  free_lun,lun
  d = d + 1
  if (d eq 36) then d = 0
endfor
end
;
.run
  dir = '/home/candida/DATA/NARR/data.to.ENVI/'
    p = 'PPT/ppt'
    e = 'PET/pet'
for d = 0, ndkd - 1 do begin
  if (d lt 9) then s = '0' else s = ' '
  ff = strcompress(string(dir,p,s,caldkyr(d),'.bil'),/remove_all)
  print,ff
  out = reform(reverse(PPT_clim(*,*,d),2))
  openw,lun,ff,/get_lun
  writeu,lun,out
  close,lun
  free_lun,lun
  ff = strcompress(string(dir,e,s,caldkyr(d),'.bil'),/remove_all)
  print,ff
  out = reform(reverse(PET_clim(*,*,d),2))
  openw,lun,ff,/get_lun
  writeu,lun,out
  close,lun
  free_lun,lun
endfor
end

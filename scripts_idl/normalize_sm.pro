pro normalize_SM

ifile1 = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/monthly/Sm01*.img')
ifile2 = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/monthly/Sm02*.img')
ifile3 = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/monthly/Sm03*.img')
ifile4 = file_search('/jower/sandbox/mcnally/ECV_soil_moisture/monthly/sahel/*.img')

ifile5 = file_search('/jabber/chg-mcnally/npaw_monthly.img')
ifile6 = file_search('/jabber/chg-mcnally/rpaw_monthly.img')

nx=720
ny=350

npawcube = fltarr(nx,ny,12,12)*!values.f_nan
rpawcube = fltarr(nx,ny,12,12)*!values.f_nan

openr,1,ifile5
readu,1,npawcube
close,1

openr,1,ifile6
readu,1,rpawcube
close,1

ingrid1 = fltarr(720,250)
buffer1 = fltarr(nx,250,n_elements(ifile1))
ingrid2 = fltarr(720,250)
buffer2 = fltarr(nx,250,n_elements(ifile1))
ingrid3 = fltarr(720,250)
buffer3 = fltarr(nx,250,n_elements(ifile1))

ingrid4 = fltarr(nx,ny)
buffer4 = fltarr(nx,ny,n_elements(ifile4))

for i = 0,n_elements(ifile4)-1 do begin &$
  openr,1,ifile4[i] &$
  readu,1,ingrid4 &$
  close,1 &$
  
  buffer4[*,*,i] = ingrid4 &$
endfor

for i=0,n_elements(ifile1)-1 do begin &$
  openr,1,ifile1[i] &$
  readu,1,ingrid1 &$
  close,1 &$
  buffer1[*,*,i]=ingrid1 &$
  
  openr,1,ifile2[i] &$
  readu,1,ingrid2 &$
  close,1 &$
  buffer2[*,*,i]=ingrid2 &$
  
  openr,1,ifile3[i] &$
  readu,1,ingrid3 &$
  close,1 &$
  buffer3[*,*,i]=ingrid3 &$
endfor

sm01cube = reform(buffer1,720,250,12,11)
sm02cube = reform(buffer2,720,250,12,11)
sm03cube = reform(buffer3,720,250,12,11)
smMWcube = reform(buffer4,nx,ny,12,10)

;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

m=8
w01 = sm01cube[wxind,wyind,m,*]
w02 = sm02cube[wxind,wyind,m,*]
w0N = npawcube[wxind,wyind,m,*]
w0R = rpawcube[wxind,wyind,m,*]
wmw = smMWcube[wxind,wyind,m,*]

p1=plot(  (w01-mean(w01,/nan))/stdev(w01(where(finite(w01))))  )
p1=plot(  (w02-mean(w02,/nan))/stdev(w02(where(finite(w02)))), /overplot,'grey'  )
p1=plot(  (w0N-mean(w0N,/nan))/stdev(w0N(where(finite(w0N)))), /overplot,'green'  )
p1=plot(  (w0R-mean(w0R,/nan))/stdev(w0R(where(finite(w0R)))), /overplot,'blue'  )
p1=plot(  (wMW-mean(wMW,/nan))/stdev(wMW(where(finite(wMW)))), /overplot,'cyan'  )

;get the anomalies for the whole sahel for a map comparison for each month:
Lstdanom=fltarr(nx,250,12,11);x,y,month,year
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    for m=0,11 do begin &$
      w02 = sm02cube[x,y,m,*] &$
      test = where(finite(w02), count) &$
      if count le 1 then continue &$
      Lstdanom[x,y,m,*] = (w02-mean(w02,/nan))/stdev(w02(where(finite(w02)))) &$
    endfor &$
  endfor &$
endfor

Lstdanom01 = lstdanom
Lstdanom02 = lstdanom

Rstdanom=fltarr(nx,250,12,12);x,y,month,year
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    for m=0,11 do begin &$
      w0R = rpawcube[x,y,m,*] &$
      test = where(finite(w0R), count) &$
      if count le 1 then continue &$
      Rstdanom[x,y,m,*] = (w0R-mean(w0R,/nan))/stdev(w0R(where(finite(w0R)))) &$
    endfor &$
  endfor &$
endfor

Nstdanom=fltarr(nx,250,12,12);x,y,month,year
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    for m=0,11 do begin &$
      w0N = npawcube[x,y,m,*] &$
      test = where(finite(w0N), count) &$
      if count le 1 then continue &$
      Nstdanom[x,y,m,*] = (w0N-mean(w0N,/nan))/stdev(w0N(where(finite(w0N)))) &$
    endfor &$
  endfor &$
endfor


Mstdanom=fltarr(nx,250,12,10);x,y,month,year
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    for m=0,11 do begin &$
      wMW = smMWcube[x,y,m,*] &$
      test = where(finite(wMW), count) &$
      if count le 1 then continue &$
      Mstdanom[x,y,m,*] = (wMW-mean(wMW,/nan))/stdev(wMW(where(finite(wMW)))) &$
    endfor &$
  endfor &$
endfor

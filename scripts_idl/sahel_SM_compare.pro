pro sahel_SM_compare

;the purpose of this script is to compare the soil moisture products over the sahel window, similar to rain_compare and ET_compare

;******************read in monthly SM data (RPAW, MW, LIS)********************************
nfile = file_search('/jower/chg-mcnally/fromKnot/EXP01/monthly/Sm01*.img');132
mfile = file_search('/jower/chg-mcnally/ECV_soil_moisture/monthly/sahel/*.img');120
wfile = file_search('/jabber/chg-mcnally/rpaw_monthly.img')
ifile7 = file_search('/jabber/chg-mcnally/sahel_NSM_microwave_monthly_12yrs.img');this is NWET?

nx = 720
ny = 350

buffern = fltarr(nx,250)
bufferm = fltarr(nx,350)

sm01grid = fltarr(nx,250,n_elements(mfile))
mwgrid = fltarr(nx,350,n_elements(mfile))
rpawcube = fltarr(nx,350,12,12)*!values.f_nan
nwetcube = fltarr(nx,ny,12,12)*!values.f_nan

openr,1, wfile
readu,1,rpawcube
close,1

openr,1,ifile7
readu,1,nwetcube
close,1

for i = 0,n_elements(mfile)-1 do begin &$
  openr,1,nfile[i] &$
  openr,2,mfile[i] &$
  
  readu,1,buffern &$
  readu,2,bufferm &$
  
  close,1 &$
  close,2 &$
 
  sm01grid[*,*,i] = buffern &$
  mwgrid[*,*,i] = bufferm &$
endfor 

mw_cube = reform(mwgrid,nx,350,12,10)
sm01_cube = reform(sm01grid,nx,250,12,10)

mo = [1,2,3,4,5,6,7,8,9,10,11,12]
corgrid = fltarr(nx,ny,n_elements(mo))
corgrid[*,*,*]=!values.f_nan

;***correlation map for nwet and mw
for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,250-1 do begin &$
     test = where(finite(rpawcube[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     corgrid[x,y,m]=correlate(mw_cube[x,y,mo[m]-1,*],nwetcube[x,y,mo[m]-1,0:9]) &$
    endfor  &$
  endfor  &$
  print,x,y &$
endfor 

p1 = image(corgrid[*,*,6], image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=4, max_value=1,title = 'NWET-MW Correlation: July')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) 

;***************************calculate statitiscs of interest & save them**********************
;monthly comparisions....
;**************************************************
Mstdanom=fltarr(nx,250,12,10);x,y,month,year
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    for m=0,11 do begin &$
      wMW = MW_cube[x,y,m,*] &$
      test = where(finite(wMW), count) &$
      if count le 1 then continue &$
      Mstdanom[x,y,m,*] = (wMW-mean(wMW,/nan))/stdev(wMW(where(finite(wMW)))) &$
    endfor &$
  endfor &$
endfor
;*******************************************************

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
;****************************************************
Lstdanom01=fltarr(nx,250,12,10);x,y,month,year
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    for m=0,11 do begin &$
      w01 = sm01_cube[x,y,m,*] &$
      test = where(finite(w01), count) &$
      if count le 1 then continue &$
      Lstdanom01[x,y,m,*] = (w01-mean(w01,/nan))/stdev(w01(where(finite(w01)))) &$
    endfor &$
  endfor &$
endfor
;*************************************************
Nstdanom01=fltarr(nx,250,12,12);x,y,month,year
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    for m=0,11 do begin &$
      w01 = nwetcube[x,y,m,*] &$
      test = where(finite(w01), count) &$
      if count le 1 then continue &$
      Nstdanom01[x,y,m,*] = (w01-mean(w01,/nan))/stdev(w01(where(finite(w01)))) &$
    endfor &$
  endfor &$
endfor
;I should look at rank correlation, mean error and mean absolute error.
;maps of mean absolute error abs(model-observed)/12

mo = [1,2,3,4,5,6,7,8,9,10,11,12]
maegrid = fltarr(nx,ny,n_elements(mo))
maegrid[*,*,*]=!values.f_nan
corgrid = fltarr(nx,ny,n_elements(mo))
corgrid[*,*,*]=!values.f_nan

;*****and WRSI mask?********
rmask=mean(rpawcube[*,*,*,0], dimension=3,/nan)
good = where(finite(rmask), complement=other)
rmask(other)=!values.f_nan 
rmask(good)=1

for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,250-1 do begin &$
     test = where(finite(rpawcube[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     maegrid[x,y,m]=(mean(abs(rstdanom[x,y,mo[m]-1,*]-mstdanom[x,y,mo[m]-1,*]),/nan)) &$
    endfor  &$
  endfor  &$
  print,x,y &$
endfor 
rpawmae=maegrid
p1 = image(rpawmae[*,*,7]*rmask, rgb_table=4, max_value=1.5, title = 'RPAW std anom MAE wrt MW Aug')
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20)
             
p1 = image(rpawmae[*,0:249,7]*rmask, image_dimensions=[72.0,25.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=4, max_value=1.5,title = 'RPAW std anom MAE wrt MW Aug')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) 

;not sure this is still the mean abs error when not dividing by mean.             
for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,250-1 do begin &$
     test = where(finite(rpawcube[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     maegrid[x,y,m]=(mean(abs(lstdanom01[x,y,mo[m]-1,*]-mstdanom[x,y,mo[m]-1,*]),/nan)) &$
    endfor  &$
  endfor  &$
  print,x,y &$
endfor 
sm01mae=maegrid

p1 = image(sm01mae[*,0:249,7]*rmask, image_dimensions=[72.0,25.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=4, max_value=1.5,title = 'SM01 std anom MAE wrt MW Aug')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) 
maegrid(where(maegrid gt 1))=1
;ofile = '/jabber/chg-mcnally/mae_cmp_stav2.img'
;openw,1,ofile
;writeu,1,maegrid
;close,1
;************************ NOAH correlation w/ Microwave******************
for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,250-1 do begin &$
     test = where(finite(rpawcube[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     corgrid[x,y,m]=correlate(lstdanom01[x,y,mo[m]-1,*],mstdanom[x,y,mo[m]-1,*]) &$
    endfor  &$
  endfor  &$
  print,x,y &$
endfor 
sm01cor=corgrid
p1 = image(sm01cor[*,0:249,7]*rmask, image_dimensions=[72.0,25.0],$
           image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=4, min_value = 0, max_value=1,title = 'SM01 std anom CORRELATION wrt MW Aug')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) 
  ;************************ RPAW correlation w/ Microwave******************
for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,250-1 do begin &$
     test = where(finite(rpawcube[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     corgrid[x,y,m]=correlate(rstdanom[x,y,mo[m]-1,*],mstdanom[x,y,mo[m]-1,*]) &$
    endfor  &$
  endfor  &$
  print,x,y &$
endfor 
RPAWcor=corgrid
p1 = image(RPAWcor[*,0:249,6]*rmask, image_dimensions=[72.0,25.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=4, min_value = 0, max_value=1,title = 'RPAW std anom CORRELATION wrt MW July')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) 
;*************************************************
megrid = fltarr(nx,250,n_elements(mo))
megrid[*,*,*]=!values.f_nan

;uh, i probably have to do this with the anomalies?? or the stdized anoms?
;dinku et all calls this mean error (ME)
for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,250-1 do begin &$
     test = where(finite(rpawcube[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     megrid[x,y,m]=mean(rpawcube[x,y,mo[m]-1,*]-mw_cube[x,y,mo[m]-1,*],/nan) &$
    endfor  &$
  endfor  &$
 print,x,y &$
endfor

rpaw_megrid = megrid
temp = image(rpaw_megrid[*,*,7], rgb_table=4, min_value=-3000, max_value=-300)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20)
 
 megrid = fltarr(nx,250,n_elements(mo))
megrid[*,*,*]=!values.f_nan
            
for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,250-1 do begin &$
     test = where(finite(rpawcube[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     megrid[x,y,m]=mean(sm01_cube[x,y,mo[m]-1,*]-mw_cube[x,y,mo[m]-1,*],/nan) &$
    endfor  &$
  endfor  &$
 print,x,y &$
endfor

sm01_megrid = megrid
temp = image(sm01_megrid[*,*,7], rgb_table=4, min_value=-3000, max_value=-300)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20)

;ofile = '/jabber/chg-mcnally/mbe_chrps_sta.img'
;openw,1,ofile
;writeu,1,mbegrid
;close,1

;sta_cube, rfe_cube,urf_cube,cmp_cube,chp_cube

biasgrid = fltarr(nx,ny,n_elements(mo))
biasgrid[*,*,*]=!values.f_nan

for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,ny-1 do begin &$
     test = where(finite(urf_cube[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     biasgrid[x,y,m]=cmp_cube[x,y,mo[m]-1,*]/sta_cube[x,y,mo[m]-1,*] &$
    endfor  &$
  endfor  &$
 print,x,y &$
endfor
;biasgrid(where(biasgrid gt 2))=2
;ofile = '/jabber/chg-mcnally/bias_cmp_sta.img'
;openw,1,ofile
;writeu,1,biasgrid
;close,1

;****************by country***************************
meefile = file_search('/jabber/chg-mcnally/mbe_*sta.img')
maefile = file_search('/jabber/chg-mcnally/mae*v2.img')
biafile = file_search('/jabber/chg-mcnally/bias*.img')

  ;***compare standardized soil mositure by crop zones***********************
cfile = file_search('/jabber/chg-mcnally/cz_mask_sahel.img')

nx = 720
ny = 350
nz = 12

cgrid = fltarr(nx,ny)

openr,1,cfile
readu,1,cgrid
close,1

cgrid = cgrid[*,0:249]

burkina = where(cgrid eq 1, count) & print, count
chad = where(cgrid eq 2, count) & print, count
mali = where(cgrid eq 3, count) & print, count
niger = where(cgrid eq 4, count) & print, count
senegal = where(cgrid eq 5, count) & print, count


ingrid = fltarr(nx,ny,nz)
allgrid = fltarr(nx,ny,nz,n_elements(meefile))
for i = 0,n_elements(meefile)-1 do begin &$
  openr,1,maefile[i] &$
  readu,1,ingrid &$
  close,1 &$
  
  allgrid[*,*,*,i] = ingrid &$
endfor
 meegrid = allgrid
 maegrid = allgrid
 biagrid = allgrid
;get the RPAW, NWET, SM01, SMMW for each country (averged over? J,A,S?)
;rain  then NDVI
;******************************************** 
NigerSM = fltarr(4,12,12)*!values.f_nan
SenegalSM = fltarr(4,12,12)*!values.f_nan
MaliSM = fltarr(4,12,12)*!values.f_nan
BurkinaSM = fltarr(4,12,12)*!values.f_nan
ChadSM = fltarr(4,12,12)*!values.f_nan

for m = 0,n_elements(nwetcube[0,0,*,0])-1 do begin &$
  for y = 0,n_elements(nwetcube[0,0,0,0:9])-1 do begin &$
    rpaw = rstdanom[*,*,m,y] &$
    smMW = mstdanom[*,*,m,y] &$ 
    sm01 = Lstdanom01[*,*,m,y] &$
    nwet = nstdanom01[*,*,m,y] &$
    
    NigerSM[*,m,y] = [mean(rpaw(niger),/nan),mean(smMW(niger), /nan),mean(sm01(niger), /nan),mean(nwet(niger), /nan)] &$
    SenegalSM[*,m,y] =  [mean(rpaw(senegal), /nan),mean(smMW(senegal), /nan),mean(sm01(senegal), /nan),mean(nwet(senegal), /nan)] &$
    MaliSM[*,m,y] =  [mean(rpaw(mali), /nan),mean(smMW(mali), /nan),mean(sm01(mali), /nan),mean(nwet(mali), /nan)] &$
    BurkinaSM[*,m,y] =  [mean(rpaw(burkina), /nan),mean(smMW(burkina), /nan),mean(sm01(burkina), /nan),mean(nwet(burkina), /nan)] &$
    ChadSM[*,m,y] =  [mean(rpaw(chad), /nan),mean(smMW(chad), /nan),mean(sm01(chad), /nan),mean(nwet(chad), /nan)] &$
  endfor &$    
endfor;i 

;CALCULATE THE ENSEMBLE AVERAGE FOR EACH COUNTRY; let say -0.3/-0.4 std dev. in Niger?i can play with this number...
enburkina = mean(burkinaSM, dimension=1,/nan)
enchad = mean(chadSM, dimension=1, /nan)
enmali = mean(maliSM, dimension=1, /nan)
ensniger = mean(nigerSM, dimension=1,/nan)
enSenegal = mean(senegalSM, dimension=1,/nan)

;for 'gauge' vs threshold - use the ensemble as 'truth' compare to e.g. NigerSM[*,6:7,*]
;I might have to do this in excel to see what is going on...
JAENBK = mean(enburkina[6:7, *], dimension=1, /nan)
JAENCH = mean(enchad[6:7, *], dimension=1, /nan)
JAENMA = mean(enmali[6:7, *], dimension=1, /nan)
JAENNG = mean(ensniger[6:7, *], dimension=1, /nan)
JAENSG = mean(ensenegal[6:7, *], dimension=1, /nan)

;put all in one array so that i can loop through the countries...
ens_array = [transpose(jaenbk), transpose(jaench), transpose(jaenma), transpose(jaenng), transpose(jaensg)]

;************FOR THE RPAW (0) DATA*****************************
JARBK = mean(burkinaSM[0,6:7,*], dimension=2, /nan)
JARCH = mean(chadSM[0,6:7,*], dimension=2, /nan)
JARMA = mean(maliSM[0,6:7,*], dimension=2, /nan)
JARNG = mean(nigerSM[0,6:7,*], dimension=2, /nan)
JARSG = mean(senegalSM[0,6:7,*], dimension=2, /nan)

prod_array = [jarbk, jarch, jarma, jarng, jarsg]

a = intarr(5,n_elements(jaenbk)-2)
b = intarr(5,n_elements(jaenbk)-2)
c = intarr(5,n_elements(jaenbk)-2)
d = intarr(5,n_elements(jaenbk)-2)

for x = 0, n_elements(ens_array[*,0])-1 do begin  &$
  for y = 0, n_elements(jaenbk)-3 do begin &$
    ;truth positive product neg = B false alarm
    if ens_array[x,y] ge 0 AND prod_array[x,y] gt 0 then A[x,y] = 1 else A[x,y] = 0 &$
    if ens_array[x,y] le 0 AND prod_array[x,y] gt 0 then B[x,y] = 1 else B[x,y] = 0 &$
    if ens_array[x,y] ge 0 AND prod_array[x,y] lt 0 then C[x,y] = 1 else C[x,y] = 0 &$
    if ens_array[x,y] le 0 AND prod_array[x,y] lt 0 then D[x,y] = 1 else D[x,y] = 0 &$
    print, A &$
  endfor &$; y
endfor;c

A_rpaw = total(A) 
B_rpaw = total(B)
C_rpaw = total(C)
D_rpaw = total(D)

;*******************************************************
;*************** microwave (1)******************************
JARBK = reform(mean(burkinaSM[1,6:7,*], dimension=2, /nan))
JARCH = mean(chadSM[1,6:7,*], dimension=2, /nan)
JARMA = mean(maliSM[1,6:7,*], dimension=2, /nan)
JARNG = mean(nigerSM[1,6:7,*], dimension=2, /nan)
JARSG = mean(senegalSM[1,6:7,*], dimension=2, /nan)

prod_array = [jarbk, jarch, jarma, jarng, jarsg]

a = intarr(5,n_elements(jaenbk)-2)
b = intarr(5,n_elements(jaenbk)-2)
c = intarr(5,n_elements(jaenbk)-2)
d = intarr(5,n_elements(jaenbk)-2)

for x = 0, n_elements(ens_array[*,0])-1 do begin  &$
  for y = 0, n_elements(jaenbk)-3 do begin &$
    ;truth positive product neg = B false alarm
    if ens_array[x,y] ge 0 AND prod_array[x,y] gt 0 then A[x,y] = 1 else A[x,y] = 0 &$
    if ens_array[x,y] le 0 AND prod_array[x,y] gt 0 then B[x,y] = 1 else B[x,y] = 0 &$
    if ens_array[x,y] ge 0 AND prod_array[x,y] lt 0 then C[x,y] = 1 else C[x,y] = 0 &$
    if ens_array[x,y] le 0 AND prod_array[x,y] lt 0 then D[x,y] = 1 else D[x,y] = 0 &$
    print, A &$
  endfor &$; y
endfor;c
A_mwsm = total(A) 
B_mwsm = total(B)
C_mwsm = total(C)
D_mwsm = total(D)

;****************LIS-NOAH SM01*************************

JARBK = reform(mean(burkinaSM[2,6:7,*], dimension=2, /nan))
JARCH = mean(chadSM[2,6:7,*], dimension=2, /nan)
JARMA = mean(maliSM[2,6:7,*], dimension=2, /nan)
JARNG = mean(nigerSM[2,6:7,*], dimension=2, /nan)
JARSG = mean(senegalSM[2,6:7,*], dimension=2, /nan)

prod_array = [jarbk, jarch, jarma, jarng, jarsg]

a = intarr(5,n_elements(jaenbk)-2)
b = intarr(5,n_elements(jaenbk)-2)
c = intarr(5,n_elements(jaenbk)-2)
d = intarr(5,n_elements(jaenbk)-2)

for x = 0, n_elements(ens_array[*,0])-1 do begin  &$
  for y = 0, n_elements(jaenbk)-3 do begin &$
    ;truth positive product neg = B false alarm
    if ens_array[x,y] ge 0 AND prod_array[x,y] gt 0 then A[x,y] = 1 else A[x,y] = 0 &$
    if ens_array[x,y] le 0 AND prod_array[x,y] gt 0 then B[x,y] = 1 else B[x,y] = 0 &$
    if ens_array[x,y] ge 0 AND prod_array[x,y] lt 0 then C[x,y] = 1 else C[x,y] = 0 &$
    if ens_array[x,y] le 0 AND prod_array[x,y] lt 0 then D[x,y] = 1 else D[x,y] = 0 &$
    print, A &$
  endfor &$; y
endfor;c

A_sm01 = total(A) 
B_sm01 = total(B)
C_sm01 = total(C)
D_sm01 = total(D)

;**************NDVI-MICROWAVE composite (3)******************************
;NWET 

JARBK = reform(mean(burkinaSM[3,6:7,*], dimension=2, /nan))
JARCH = mean(chadSM[3,6:7,*], dimension=2, /nan)
JARMA = mean(maliSM[3,6:7,*], dimension=2, /nan)
JARNG = mean(nigerSM[3,6:7,*], dimension=2, /nan)
JARSG = mean(senegalSM[3,6:7,*], dimension=2, /nan)

prod_array = [jarbk, jarch, jarma, jarng, jarsg]

a = intarr(5,n_elements(jaenbk)-2)
b = intarr(5,n_elements(jaenbk)-2)
c = intarr(5,n_elements(jaenbk)-2)
d = intarr(5,n_elements(jaenbk)-2)

for x = 0, n_elements(ens_array[*,0])-1 do begin  &$
  for y = 0, n_elements(jaenbk)-3 do begin &$
    ;truth positive product neg = B false alarm
    if ens_array[x,y] ge 0 AND prod_array[x,y] gt 0 then A[x,y] = 1 else A[x,y] = 0 &$
    if ens_array[x,y] le 0 AND prod_array[x,y] gt 0 then B[x,y] = 1 else B[x,y] = 0 &$
    if ens_array[x,y] ge 0 AND prod_array[x,y] lt 0 then C[x,y] = 1 else C[x,y] = 0 &$
    if ens_array[x,y] le 0 AND prod_array[x,y] lt 0 then D[x,y] = 1 else D[x,y] = 0 &$
    print, A &$
  endfor &$; y
endfor;c
A_nwet = total(A) 
B_nwet = total(B)
C_nwet = total(C)
D_nwet = total(D)

;**********now what are the classification metrics?**********
;POD (A/A+C) [wet]
;POD(D/D+C) [dry]
;FAR (B/B+A)
;CSI (A/A+B+C) [wet]
;CSI (D/D+B+C) [dry]
;AR (A+C)*(A+B)/N
;ETS (A-AR)/(A+B+C-AR)
;HK (A/A+C)-(B/B+C)
;HSS_num 2**(AD)-(BC))
;HSS_den = (A+C)*(C+D) + (A+B)*(B+D)
;HSS = num/den

POD_w = [A_rpaw/(A_rpaw+C_rpaw), A_mwsm/(A_mwsm+C_mwsm),A_sm01/(A_sm01+C_sm01),A_nwet/(A_nwet+C_nwet)]
POD_d = [D_rpaw/(D_rpaw+C_rpaw), D_mwsm/(D_mwsm+C_mwsm),D_sm01/(D_sm01+C_sm01),D_nwet/(D_nwet+C_nwet)]
FAR = [B_rpaw/(B_rpaw+A_RPAW), B_mwsm/(B_mwsm+A_mwsm), B_sm01/(B_sm01+A_sm01), B_nwet/(B_nwet+A_nwet)] 
CSI_w = [A_rpaw/(A_rpaw+B_rpaw+C_rpaw),A_mwsm/(A_mwsm+B_mwsm+C_mwsm),A_sm01/(A_sm01+B_sm01+C_sm01),$
       A_nwet/(A_nwet+B_nwet+C_nwet)]
;critical sucess index
CSI_d = [D_rpaw/(D_rpaw+B_rpaw+C_rpaw),D_mwsm/(D_mwsm+B_mwsm+C_mwsm),D_sm01/(D_sm01+B_sm01+C_sm01),$
       D_nwet/(D_nwet+B_nwet+C_nwet)]
;hits that could occur by chance
AR = [(A_rpaw+C_rpaw)*(A_rpaw+B_rpaw)/50, (A_mwsm+C_mwsm)*(A_mwsm+B_mwsm)/50, (A_sm01+C_sm01)*(A_sm01+B_sm01)/50,$
     (A_nwet+C_nwet)*(A_nwet+B_nwet)/50]
;how well the products correspond to the mean
ETS = [ (A_rpaw-AR[0])/(A_rpaw+B_rpaw+C_rpaw-AR[0]),(A_mwsm-AR[1])/(A_mwsm+B_mwsm+C_mwsm-AR[1]), $
       (A_sm01-AR[2])/(A_sm01+B_sm01+C_sm01-AR[2]), (A_nwet-AR[3])/(A_nwet+B_nwet+C_nwet-AR[3]) ]
;how well products discrimate between wet and dry events (not super well...)
HK = [ (A_rpaw/(A_rpaw+C_rpaw)) - (B_rpaw/(B_rpaw+C_rpaw)) , (A_mwsm/(A_mwsm+C_mwsm)) - (B_mwsm/(B_mwsm+C_mwsm)), $
       (A_sm01/(A_sm01+C_sm01)) - (B_sm01/(B_sm01+C_sm01)), (A_nwet/(A_nwet+C_nwet)) - (B_nwet/(B_nwet+C_nwet))   ]   
  HSS_num = [ 2*(A_rpaw*D_rpaw-B_rpaw*C_rpaw) , 2*(A_mwsm*D_mwsm-B_mwsm*C_mwsm) , 2*(A_sm01*D_sm01-B_sm01*C_sm01) , $
             2*(A_nwet*D_nwet-B_nwet*C_nwet) ]
  HSS_den = [ (A_rpaw+C_rpaw)*(C_rpaw+D_rpaw)+(A_rpaw+B_rpaw)*(B_rpaw+D_rpaw),$
            (A_mwsm+C_mwsm)*(C_mwsm+D_mwsm)+(A_mwsm+B_mwsm)*(B_mwsm+D_mwsm),$
            (A_sm01+C_sm01)*(C_sm01+D_sm01)+(A_sm01+B_sm01)*(B_sm01+D_sm01), $
            (A_nwet+C_nwet)*(C_nwet+D_nwet)+(A_nwet+B_nwet)*(B_nwet+D_nwet)  ]
HSS = HSS_num/HSS_den          

;now I guess i need to classify how the 3 different ET products do?
;my 'truth will be ens. SM lt 0...


p1=plot(mean(ensenegal[6:7, *], dimension=1, /nan), thick=3, 'orange',/overplot)
;MEarray = fltarr(4,5,12)
;MAEarray= fltarr(4,5,12)
;BIAarray = fltarr(4,5,12)

for m = 0,n_elements(meegrid[0,0,*,0])-1 do begin &$
  for p = 0,n_elements(meegrid[0,0,0,*])-1 do begin &$
    
    mee = meegrid[*,*,m,p] &$
    mae = maegrid[*,*,m,p] &$
    bia = biagrid[*,*,m,p] &$
    
    MEarray[p,*,m] =  [mean(mee(burkina),/nan),mean(mee(chad),/nan),mean(mee(mali), /nan),mean(mee(niger), /nan),mean(mee(senegal), /nan)] &$
    MAEarray[p,*,m] =  [mean(mae(burkina),/nan),mean(mae(chad),/nan),mean(mae(mali), /nan),mean(mae(niger), /nan),mean(mae(senegal), /nan)] &$
    BIAarray[p,*,m] =  [mean(bia(burkina),/nan),mean(bia(chad),/nan),mean(bia(mali), /nan),mean(bia(niger), /nan),mean(bia(senegal), /nan)] &$

  endfor &$    
endfor;i           
             
             
             
             
             

;****************correlation map******************************
;Wankama 2006 - 2011 (13.6456,2.632 )
;wxind = FLOOR((2.632 + 20.) / 0.10)
;wyind = FLOOR((13.6456 + 5) / 0.10)
;
x = wxind
y = wyind

corgrid = fltarr(nx,ny,n_elements(mo))
corgrid[*,*,*]=!values.f_nan

;I guess this is where i should be doing the scatter quads...
for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,ny-1 do begin &$
     test = where(finite(urf_cube[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     corgrid[x,y,m]=correlate(cmp_cube[x,y,mo[m]-1,0:10],sta_cube[x,y,mo[m]-1,0:10]) &$
    endfor  &$
  endfor  &$
 print,x,y &$
endfor

p1=image(corgrid[*,*,6], rgb_table=20)

;ofile = '/jabber/chg-mcnally/cor_cmp_sta.img'
;openw,1,ofile
;writeu,1,corgrid
;close,1

;****************************************************
;*****************at sites**************************

;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5) / 0.10)


;Belefoungou-Top 9.79506     1.71450  
bxind = FLOOR((1.7145 + 20.) / 0.10)
byind = FLOOR((9.79506 + 5) / 0.10)

;the full time series
p1=plot(ingridb[wxind,wyind,*], thick=2)
p1=plot(ingridr[wxind,wyind,*], /overplot,'b')
p1=plot(ingridu[wxind,wyind,*], /overplot,'c')
p1=plot(ingridc[wxind,wyind,*], /overplot,'g')
p1=plot(ingridp[wxind,wyind,*], /overplot,'m')
;june time plot

m=9
x = wxind
y = wyind
p1=plot(sta_cube[x,y,m-1,*], thick = 2, name = 'CSCDP station')
p2=plot(rfe_cube[x,y,m-1,*], /overplot,'b', name = 'rfe')
p3=plot(urf_cube[x,y,m-1,*], /overplot,'c', name = 'ub rfe')
p4=plot(cmp_cube[x,y,m-1,*], /overplot,'g', name = 'cmap')
!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3]) 
p1.title=' Belefoungou, Benin 2001-2012 month '+string(m)

;june scatter plot
;p1=plot(sta_cube[wxind,wyind,6-1,*])
p2=plot(rfe_cube[x,y,m-1,*],sta_cube[x,y,m-1,*], '*b', name = 'rfe')
p3=plot(urf_cube[x,y,m-1,*],sta_cube[x,y,m-1,*], '*c',/overplot, name = 'ub rfe')
p4=plot(cmp_cube[x,y,m-1,*],sta_cube[x,y,m-1,*], '*g', /overplot, name = 'cmap')
p2.title=' Belefougou 2001-2012 month '+string(m)
p2.xminor=0
p2.yminor=0
!null = legend(target=[p2,p3,p4], position=[0.2,0.3]) 

p2.xrange=[120,325]
p2.yrange=[120,325]
p5=plot([120,325], [120,325], /overplot)


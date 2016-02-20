pro sahel_ET_compare

;the purpose of this script is to compare the soil moisture products over the sahel window, similar to rain_compare and ET_compare

;******************read in monthly ET data (RPAW, MW, LIS)********************************
lfile = file_search('/jower/chg-mcnally/fromKnot/EXP01/monthly/Evap*.img');132
mfile = file_search('/jower/sandbox/mcnally/MOD16/Africa/sahel/*{2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012}*.tif');156 2000-2012
rfile = file_search('/jower/chg-mcnally/rAET_monthly.img')
;efile = file_search('/jabber/chg-mcnally/ETA/sahel/*.img');144

nx = 720
ny = 350
nyy = 250

;for the ETA data...
;ingride = fltarr(nx,ny,n_elements(efile))
;buffere = bytarr(nx,ny)

ingridm = intarr(nx,ny,n_elements(mfile))
bufferm = intarr(nx,ny)

;and the LIS Evap
ingridl = fltarr(720,250,n_elements(lfile))
bufferl = fltarr(720,250)

;read in the rpawcube
raetcube = fltarr(nx,ny,12,12)*!values.f_nan
openr,1,rfile
readu,1,raetcube
close,1

for i=0,n_elements(lfile)-1 do begin &$
   openr,1,lfile[i] &$
   readu,1,bufferl &$
   close,1 &$
   ingridl[*,*,i] = bufferl &$
endfor 
   
mfile = file_search('/jower/sandbox/mcnally/MOD16/Africa/sahel/*{2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012}*.tif');156 2000-2012  
for i = 0, n_elements(mfile)-1 do begin &$   
   bufferm = read_tiff(mfile[i]) &$
   bufferm = reverse(bufferm,2) &$
   ingridm[*,*,i] = bufferm &$
   
;   openr,1,efile[i] &$
;   readu,1,buffere &$
;   close,1 &$
;   ingride[*,*,i] = buffere &$

endfor
ingridm = float(ingridm)
ingridm(where(ingridm eq 32767, count)) = !values.f_nan & print, count

;month cubies....
raetcube = raetcube
modcube  = reform(ingridm,nx,ny,12,12)/100.
;etancube = reform(ingride,nx,ny,12,12) ;oh right, how do i deal with this being 0-255?
liscube  = reform(ingridl,nx,250,12,11)*86400

;etancube(where(etancube eq 0))=!values.f_nan
;etancube(where(etancube eq 255))=!values.f_nan


;these should be standardized anomalies...should i do this with cube

ranom = fltarr(720,250,12,12)*!values.f_nan
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    for m=0,n_elements(raetcube[0,0,*,0])-1 do begin &$
      ret = raetcube[x,y,m,*] &$
      test = where(finite(ret),count) &$
      if count le 1 then continue &$
      rsigma = stdev(ret(where(finite(ret)))) &$
      ranom[x,y,m,*] = (ret-mean(ret,/nan))/rsigma &$
    endfor &$
  endfor &$
endfor

lanom = fltarr(720,250,12,11)*!values.f_nan
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    for m=0,n_elements(liscube[0,0,*,0])-1 do begin &$
      let = liscube[x,y,m,*] &$
      test = where(finite(let),count) &$
      if count le 1 then continue &$
      lsigma = stdev(let(where(finite(let)))) &$
      lanom[x,y,m,*] = (let-mean(let,/nan))/lsigma &$
    endfor &$
  endfor &$
endfor

;ganom = fltarr(720,250,12,12)*!values.f_nan
;for x = 0,nx-1 do begin &$
;  for y = 0,250-1 do begin &$
;    for m=0,n_elements(etancube[0,0,*,0])-1 do begin &$
;      get = etancube[x,y,m,*] &$
;      test = where(finite(get),count) &$
;      if count le 1 then continue &$
;      gsigma = stdev(get(where(finite(get)))) &$
;      ;ganom[x,y,m,*] = (100-get)/gsigma &$
;      ganom[x,y,m,*] = (100-get)&$
;    endfor &$
;  endfor &$
;endfor

manom = fltarr(720,250,12,12)*!values.f_nan
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    for m=0,n_elements(modcube[0,0,*,0])-1 do begin &$
      met = modcube[x,y,m,*] &$
      test = where(finite(met),count) &$
      if count le 1 then continue &$
      msigma = stdev(met(where(finite(met)))) &$
      manom[x,y,m,*] = (met-mean(met,/nan))/msigma &$
    endfor &$
  endfor &$
endfor
;****crop zone mask*****
cfile = file_search('/jower/chg-mcnally/cz_mask_sahel.img')

nx = 720
ny = 350
nz = 12

cgrid = fltarr(nx,ny)

openr,1,cfile
readu,1,cgrid
close,1


burkina = where(cgrid eq 1, count) & print, count
chad = where(cgrid eq 2, count) & print, count
mali = where(cgrid eq 3, count) & print, count
niger = where(cgrid eq 4, count) & print, count
senegal = where(cgrid eq 5, count) & print, count
;*************************
NigerET = fltarr(3,12,11)
SenegalET = fltarr(3,12,11)
MaliET = fltarr(3,12,11)
BurkinaET = fltarr(3,12,11)
ChadET = fltarr(3,12,11)

for m = 0,n_elements(lanom[0,0,*,0])-1 do begin &$
  for y = 0,n_elements(lanom[0,0,0,*])-1 do begin &$
    ret = ranom[*,*,m,y] &$
    let = lanom[*,*,m,y] &$
    met = manom[*,*,m,y] &$
    
    NigerET[*,m,y] =  [mean(ret(niger),/nan),mean(let(niger), /nan), mean(met(niger), /nan) ] &$
    SenegalET[*,m,y] =  [mean(ret(senegal), /nan),mean(let(senegal),/nan), mean(met(senegal), /nan) ] &$
    MaliET[*,m,y] =  [mean(ret(mali), /nan),mean(let(mali), /nan), mean(met(mali), /nan) ] &$
    BurkinaET[*,m,y] =  [mean(ret(burkina), /nan),mean(let(burkina), /nan), mean(met(burkina), /nan) ] &$
    ChadET[*,m,y] =  [mean(ret(chad), /nan),mean(let(chad), /nan), mean(met(chad), /nan) ] &$
  endfor &$    
endfor;i

;T= soil moisture threshold
t=-0.3

;this is really aug/set but now i don't want to change it.
;not quite wroking try in the morning.
JARBK = mean(burkinaET[0,7:8,*], dimension=2, /nan)
JARCH = mean(chadET[0,7:8,*], dimension=2, /nan)
JARMA = mean(maliET[0,7:8,*], dimension=2, /nan)
JARNG = mean(nigerET[0,7:8,*], dimension=2, /nan)
JARSG = mean(senegalET[0,7:8,*], dimension=2, /nan)

prod_array = [jarbk, jarch, jarma, jarng, jarsg] & help, array

a = intarr(5,n_elements(jaenbk)-2)
b = intarr(5,n_elements(jaenbk)-2)
c = intarr(5,n_elements(jaenbk)-2)
d = intarr(5,n_elements(jaenbk)-2)


;the ens_array comes from the soil moisture script....
for x = 0, n_elements(ens_array[*,0])-1 do begin  &$
  for y = 0, n_elements(jaenbk)-3 do begin &$
    ;truth positive product neg = B false alarm
    if ens_array[x,y] ge 0 AND prod_array[x,y] gt t then A[x,y] = 1 else A[x,y] = 0 &$
    if ens_array[x,y] le 0 AND prod_array[x,y] gt t then B[x,y] = 1 else B[x,y] = 0 &$
    if ens_array[x,y] ge 0 AND prod_array[x,y] lt t then C[x,y] = 1 else C[x,y] = 0 &$
    if ens_array[x,y] le 0 AND prod_array[x,y] lt t then D[x,y] = 1 else D[x,y] = 0 &$
    print, A &$
  endfor &$; y
endfor;c

A_raet = total(A) 
B_raet = total(B)
C_raet = total(C)
D_raet = total(D)

;******************NOAH ET******************************
JARBK = mean(burkinaET[1,7:8,*], dimension=2, /nan)
JARCH = mean(chadET[1,7:8,*], dimension=2, /nan)
JARMA = mean(maliET[1,7:8,*], dimension=2, /nan)
JARNG = mean(nigerET[1,7:8,*], dimension=2, /nan)
JARSG = mean(senegalET[1,7:8,*], dimension=2, /nan)

prod_array = [jarbk, jarch, jarma, jarng, jarsg] & help, array

a = intarr(5,n_elements(jaenbk)-2)
b = intarr(5,n_elements(jaenbk)-2)
c = intarr(5,n_elements(jaenbk)-2)
d = intarr(5,n_elements(jaenbk)-2)

;the ens_array comes from the soil moisture script....
for x = 0, n_elements(ens_array[*,0])-1 do begin  &$
  for y = 0, n_elements(jaenbk)-3 do begin &$
    ;truth positive product neg = B false alarm
    if ens_array[x,y] ge 0 AND prod_array[x,y] gt t then A[x,y] = 1 else A[x,y] = 0 &$
    if ens_array[x,y] le 0 AND prod_array[x,y] gt t then B[x,y] = 1 else B[x,y] = 0 &$
    if ens_array[x,y] ge 0 AND prod_array[x,y] lt t then C[x,y] = 1 else C[x,y] = 0 &$
    if ens_array[x,y] le 0 AND prod_array[x,y] lt t then D[x,y] = 1 else D[x,y] = 0 &$
    print, A &$
  endfor &$; y
endfor;c

A_evap = total(A) 
B_evap = total(B)
C_evap = total(C)
D_evap = total(D)

;****************************MOD16***************************
JARBK = mean(burkinaET[2,7:8,*], dimension=2, /nan)
JARCH = mean(chadET[2,7:8,*], dimension=2, /nan)
JARMA = mean(maliET[2,7:8,*], dimension=2, /nan)
JARNG = mean(nigerET[2,7:8,*], dimension=2, /nan)
JARSG = mean(senegalET[2,7:8,*], dimension=2, /nan)

prod_array = [jarbk, jarch, jarma, jarng, jarsg] & help, array

a = intarr(5,n_elements(jaenbk)-2)
b = intarr(5,n_elements(jaenbk)-2)
c = intarr(5,n_elements(jaenbk)-2)
d = intarr(5,n_elements(jaenbk)-2)

;the ens_array comes from the soil moisture script....
for x = 0, n_elements(ens_array[*,0])-1 do begin  &$
  for y = 0, n_elements(jaenbk)-3 do begin &$
    ;truth positive product neg = B false alarm
    if ens_array[x,y] gt 0 AND prod_array[x,y] ge t then D[x,y] = 1 else D[x,y] = 0 &$ ;dinku A
    if ens_array[x,y] lt 0 AND prod_array[x,y] ge t then C[x,y] = 1 else C[x,y] = 0 &$ ;dinku B
    if ens_array[x,y] gt 0 AND prod_array[x,y] le t then B[x,y] = 1 else B[x,y] = 0 &$ ;dinku C
    if ens_array[x,y] lt 0 AND prod_array[x,y] le t then A[x,y] = 1 else A[x,y] = 0 &$ ;dinku D
    print, A &$
  endfor &$; y
endfor;c

A_mod = total(A) 
B_mod = total(B)
C_mod = total(C)
D_mod = total(D)

;*********************now compute the catagorical statistics********************

POD_w = [A_raet/(A_raet+C_raet), A_evap/(A_evap+C_evap),A_mod/(A_mod+C_mod)]
POD_d = [D_raet/(D_raet+C_raet), D_evap/(D_evap+C_evap),D_mod/(D_mod+C_mod)]
FAR = [B_raet/(B_raet+A_Raet), B_evap/(B_evap+A_evap), B_mod/(B_mod+A_mod)] 
CSI_w = [A_raet/(A_raet+B_raet+C_raet),A_evap/(A_evap+B_evap+C_evap),A_mod/(A_mod+B_mod+C_mod)]
;critical sucess index
CSI_d = [D_raet/(D_raet+B_raet+C_raet),D_evap/(D_evap+B_evap+C_evap),D_mod/(D_mod+B_mod+C_mod)]
;hits that could occur by chance
AR = [(A_raet+C_raet)*(A_raet+B_raet)/50, (A_evap+C_evap)*(A_evap+B_evap)/50, (A_mod+C_mod)*(A_mod+B_mod)/50 ]
;how well the products correspond to the mean
ETS = [ (A_raet-AR[0])/(A_raet+B_raet+C_raet-AR[0]),(A_evap-AR[1])/(A_evap+B_evap+C_evap-AR[1]), $
       (A_mod-AR[2])/(A_mod+B_mod+C_mod-AR[2])]
;how well products discrimate between wet and dry events (not super well...)
HK = [ (A_raet/(A_raet+C_raet)) - (B_raet/(B_raet+C_raet)) , (A_evap/(A_evap+C_evap)) - (B_evap/(B_evap+C_evap)), $
       (A_mod/(A_mod+C_mod)) - (B_mod/(B_mod+C_mod)) ]   
  HSS_num = [ 2*(A_raet*D_raet-B_raet*C_raet) , 2*(A_evap*D_evap-B_evap*C_evap) , 2*(A_mod*D_mod-B_mod*C_mod) ]
  HSS_den = [ (A_raet+C_raet)*(C_raet+D_raet)+(A_raet+B_raet)*(B_raet+D_raet),$
            (A_evap+C_evap)*(C_evap+D_evap)+(A_evap+B_evap)*(B_evap+D_evap),$
            (A_mod+C_mod)*(C_mod+D_mod)+(A_mod+B_mod)*(B_mod+D_mod) ]
HSS = HSS_num/HSS_den          

print, pod_w, pod_d, far, csi_w, csi_d, ets, hk, hss

mo = [1,2,3,4,5,6,7,8,9,10,11,12]
corgrid = fltarr(nx,ny,n_elements(mo))
corgrid[*,*,*]=!values.f_nan

;***correlation map for gabriel-ET and MOD16
for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,250-1 do begin &$
     test = where(finite(ranom[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     corgrid[x,y,m]=correlate(lanom[x,y,mo[m]-1,*],ganom[x,y,mo[m]-1,*]) &$
    endfor  &$
  endfor  &$
  print,x,y &$
endfor 

mod_eta_cor = corgrid
mod_lis_cor = corgrid
mod_aet_cor = corgrid

rmask=mean(raetcube[*,*,*,0], dimension=3,/nan)
good = where(finite(rmask), complement=other)
rmask(other)=!values.f_nan
rmask(good)=1

;strange that my grid is off by 0.75...yeah, for some reason the MOD16 grid is a bit off...i guess i needed that xtra pixel
p1 = image(mean(ranom[*,*,6:7,3], dimension=3, /nan)*rmask, image_dimensions=[72.0,25.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=6, min_value=-2, max_value=2,title = 'AETc avg Jul-Aug anom 2004')
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
;get the RPAW, NPAW, SM01, SM02, and SMMW for each country (averged over? J,A,S?)
;rain  then NDVI
;******************************************** 

;NigerSM = fltarr(3,12,4)
;SenegalSM = fltarr(3,12,4)
;MaliSM = fltarr(3,12,4)
;BurkinaSM = fltarr(3,12,4)
;ChadSM = fltarr(3,12,4)

MEarray = fltarr(4,5,12)
MAEarray= fltarr(4,5,12)
BIAarray = fltarr(4,5,12)

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



;*****Noah AET compare************************************
;lfile = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/monthly/Evap*.img')
;efile = file_search('/jabber/chg-mcnally/ETA/sahel/*.img')
;
;ingridl = fltarr(720,250,n_elements(lfile))
;bufferl = fltarr(720,250)
;
;ingride = fltarr(720,350,n_elements(efile))
;buffere = bytarr(720,350)
;
;for i=0,n_elements(ifile1)-1 do begin &$
;   openr,1,lfile[i] &$
;   readu,1,bufferl &$
;   close,1 &$
;   
;   openr,1,efile[i] &$
;   readu,1,buffere &$
;   close,1 &$
;   
;   ingridl[*,*,i] = bufferl &$
;   ingride[*,*,i] = buffere &$
;endfor
;
;
;etancube = reform(ingrid2,720,350,12,12)
;
;evapcube = reform(ingrid1,720,250,12,11)
;avgevap = mean(evapcube,dimension=4);average for each month.
;anom = fltarr(720,250,12,11)
;
;for m=0,n_elements(evapcube[0,0,*,0])-1 do begin &$
;  for y = 0,n_elements(evapcube[0,0,0,*])-1 do begin &$
;  anom[*,*,m,y] = evapcube[*,*,m,y]-avgevap[*,*,m] & help, anom &$
;endfor
;ofile = '/jabber/chg-mcnally/MonthlyEvapAnom2001_2011cube_Noah32.img'
;openw,1,ofile
;writeu,1,anom
;close,1



;compare monthly NOAH anomalies and geoWRSI
;setancube=etancube[*,0:249,*,0:10]
;sranom=ranom[*,0:249,*,0:10]
;snanom=nanom[*,0:249,*,0:10]
;cormap = fltarr(nx,250,12,2)
;for x = 0,nx-1 do begin &$
;  for y = 0,250-1 do begin &$
;    for m = 0,11 do begin &$
;      ;good = where(finite(etancube[x,y,m,0:10]), count) &$
;      good = where(finite(snanom[x,y,m,0:10]), count) &$
;      if count le 1 then continue &$
;      ;print, x,y,m &$
;      ;cormap[x,y,m,*] = r_correlate(etancube[x,y,m,good], anom[x,y,m,good]) &$
;      ;cormap[x,y,m,*] = r_correlate(sranom[x,y,m,good], anom[x,y,m,good]) &$
;      cormap[x,y,m,*] = r_correlate(snanom[x,y,m,good], anom[x,y,m,good]) &$
;    endfor &$
;  endfor   &$
;endfor
;
;Raet_noah_cormap = cormap ;I get reasonable correspondance with the R-AET but not the ETa
;Naet_noah_cormap = cormap
;p1=image(naet_noah_cormap[*,*,7,0], rgb_table=20, max_value=0.8, min_value=-0.8)
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
; 
;  p1 = image(naet_noah_cormap[*,*,7,0],image_dimensions=[72.0,25.0], image_location=[-20,-5], $ 
;             dimensions=[nx/100,ny/100],title = 'N-AET vs Noah Evap Anom', rgb_table=20, min_value=0,max_value=0.7) &$ 
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
;  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
;  p1.mapgrid.linestyle = 'dotted' &$
;  p1.mapgrid.color = [150, 150, 150] &$
;  p1.mapgrid.label_position = 0 &$
;  p1.mapgrid.label_color = 'black' &$
;  p1.mapgrid.FONT_SIZE = 12 &$
;  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
;             
;
;;Wankama 2006 - 2011 (13.6456,2.632 )
;wxind = FLOOR((2.632 + 20.) / 0.10)
;wyind = FLOOR((13.6456 + 5) / 0.10)
;
;p1=plot(ingrid2[wxind,wyind,*])

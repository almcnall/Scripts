pro paper3_plotsv3

;09/29/14 revisit this code for Yemen applications and update to Rain paths. commented out things that
;don't exsisit or might be zipped

;*****mask*****
;rfile = file_search('/home/chg-mcnally/rAET_monthly.img')
;raetcube = fltarr(720,350,12,12)*!values.f_nan
;openr,1,rfile
;readu,1,raetcube
;close,1
;
;rmask=mean(raetcube[*,*,*,0], dimension=3,/nan)
;good = where(finite(rmask), complement=other)
;rmask(other)=!values.f_nan
;rmask(good)=1
;rmask = rmask[*,0:249]

;Table 4: Mean and variance/std dev of each of the different monthly SM datasets:
;****************************************************
;******soil moisture compare*************************
ifile1 = file_search('/home/chg-mcnally/fromKnot/EXP01/monthly/Sm01*.img')
;ifile2 = file_search('/home/chg-mcnally/fromKnot/EXP01/monthly/Sm02*.img')
ifile4 = file_search('/home/chg-mcnally/ECV_soil_moisture/monthly/sahel/*.img')
;ifile6 = file_search('/home/chg-mcnally/rpaw_monthly.img')
;ifile7 = file_search('/home/chg-mcnally/sahel_NSM_microwave_monthly_12yrs.img');this is NWET?


;What was my old sahel window?
map_ulx = -20.  & map_lrx = 52.
map_uly = 20.  & map_lry = -5

ulx = (180.+map_ulx)*10.  & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10.   & lry = (50.-map_lry)*10.-1
NX = lrx - ulx + 1
NY = lry - uly + 1

;nx = 720
;ny = 250
;
;rpawcube = fltarr(nx,350,12,12)*!values.f_nan
;nwetcube = fltarr(nx,350,12,12)*!values.f_nan
;
;openr,1,ifile6
;readu,1,rpawcube
;close,1
;
;openr,1,ifile7
;readu,1,nwetcube
;close,1
;nwetcube(where(nwetcube lt 0))=0
;;mask out nwetcube like the other data....
;temp = reform(nwetcube,nx,350,144)
;masked = fltarr(nx,ny,144)
;for i = 0, n_elements(temp[0,0,*])-1 do begin &$
;  masked[*,*,i] = temp[*,*,i]*rmask &$
;endfor 
;nwetcube = reform(masked,nx,ny,12,12)

ingrid1 = fltarr(nx,ny)
buffer1 = fltarr(nx,ny,n_elements(ifile1))
;ingrid2 = fltarr(nx,ny)
;buffer2 = fltarr(nx,ny,n_elements(ifile1))

ingrid4 = fltarr(nx,350)
buffer4 = fltarr(nx,350,n_elements(ifile4))

for i = 0,n_elements(ifile4)-1 do begin &$
  openr,1,ifile4[i] &$
  readu,1,ingrid4 &$
  close,1 &$
  
  ;buffer4[*,*,i] = ingrid4*rmask &$
  buffer4[*,*,i] = ingrid4 &$

endfor
buffer4 = buffer4[*,0:249,*]
for i=0,n_elements(ifile1)-1 do begin &$
  openr,1,ifile1[i] &$
  readu,1,ingrid1 &$
  close,1 &$
  ;buffer1[*,*,i]=ingrid1*rmask &$
  buffer1[*,*,i]=ingrid1 &$

  
;  openr,1,ifile2[i] &$
;  readu,1,ingrid2 &$
;  close,1 &$
;  buffer2[*,*,i]=ingrid2*rmask &$
  
endfor
buffer1 = buffer1[*,*,0:119]
;;;;correlate the RFE2-GDAS soil moisture with ECV;;;;;
cormap = fltarr(nx,ny)
for x = 0,NX-1 do begin &$
  for y = 0, NY-1 do begin &$
  cormap[x,y] = correlate(buffer1[x,y,*], buffer4[x,y,*]) &$
endfor  &$
endfor

;ofile = '/home/mcnally/arc_chirps_corr.img'
;openw,1,ofile
;writeu,1, cormap
;close,1


sm01cube = reform(buffer1,nx,ny,12,11)
;sm02cube = reform(buffer2,nx,ny,12,11)
smMWcube = reform(buffer4,nx,ny,12,10)

;plot the march to september mean annual totals for sm01 and EVC
growSM01 = mean(mean(sm01cube[*,*,2:8,*], dimension=3, /nan),dimension=3,/nan)
growECV = mean(mean(smMWcube[*,*,2:8,*], dimension=3, /nan), dimension=3,/nan)

;Yemen Highland window
hmap_ulx = 42.5 & hmap_lrx = 48.
hmap_uly = 17.5 & hmap_lry = 12.5

hulx = (hmap_ulx-22)*10.  & hlrx = (hmap_lrx-22)*10.-1
huly = (11.75+hmap_uly)*10.   & hlry = (11.75+hmap_lry)*10.-1

hNX = hlrx - hulx + 1.5
hNY = hlry - huly + 2

;Africa mean annual SM figure
monthtot = total(smMWcube,4,nan)
tot = total(buffer4,3,/nan)
ncolors=12
p1 = image(congrid(tot, NX*3, NY*3), image_dimensions=[nx/10,ny/10],image_location=[map_ulx,map_lry], $
  RGB_TABLE=64)  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
 ; p1.title = 'gdas+rfe 2001-2013 mar-sept sm01' &$
  p1.max_value=0.30 
  p1.min_value=0
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,font_size=18) &$
  ;m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot) &$
 m1 = MAP('Geographic',LIMIT = [hmap_lry,hmap_ulx,hmap_uly ,hmap_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  m1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0, 0, 0], THICK = 2)

;i want a time series of where there are gaps in the MW data over yemen.

;Table 4 - Mean and standard deviation for monthly SM products!
nve, smMWcube[*,*,6:7,0:9]/100
nve, rpawcube[*,*,6:7,0:9]
nve, sm01cube[*,*,6:7,0:9]
nve, sm02cube[*,*,6:7,0:9]/3
nve, nwetcube[*,*,6:7,*]/100

;*****figures in google by country, by year standardized anomalies of MW, RPAW and SM01 [[AND NWET]]*******
; (1)get monthly standardized anomalies for the whole sahel for each product
; (2) agregate by crop zone and country

;LIS-NOAH soil layers 1 & 2 -- these need to be for the same time span or things get weird i think...also make sure nve/0's are comprable.
Lstdanom01=fltarr(nx,ny,12,10);x,y,month,year
Lstdanom02=fltarr(nx,ny,12,10);x,y,month,year
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    for m=0,11 do begin &$
      w01 = sm01cube[x,y,m,0:9] &$
      w02 = sm02cube[x,y,m,0:9] &$
      test = where(finite(w01), count) &$
      test2 = where(finite(w02), count2) &$      
      if count le 1 then continue &$
      if count2 le 1 then continue &$
      Lstdanom01[x,y,m,*] = (w01-mean(w01,/nan))/stdev(w01(where(finite(w01)))) &$
      Lstdanom02[x,y,m,*] = (w02-mean(w02,/nan))/stdev(w02(where(finite(w02)))) &$
    endfor &$
  endfor &$
endfor


Rstdanom=fltarr(nx,250,12,10);x,y,month,year
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    for m=0,11 do begin &$
      w0R = rpawcube[x,y,m,0:9] &$
      test = where(finite(w0R), count) &$
      if count le 1 then continue &$
      Rstdanom[x,y,m,*] = (w0R-mean(w0R,/nan))/stdev(w0R(where(finite(w0R)))) &$
    endfor &$
  endfor &$
endfor

Mstdanom=fltarr(nx,ny,12,10);x,y,month,year
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    for m=0,11 do begin &$
      wMW = smMWcube[x,y,m,*] &$
      test = where(finite(wMW), count) &$
      if count le 1 then continue &$
      Mstdanom[x,y,m,*] = (wMW-mean(wMW,/nan))/stdev(wMW(where(finite(wMW)))) &$
    endfor &$
  endfor &$
endfor

NWstdanom=fltarr(nx,250,12,10);x,y,month,year
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    for m=0,11 do begin &$
      Nwet = nwetcube[x,y,m,0:9] &$
      test = where(finite(nwet), count) &$
      if count le 1 then continue &$
      NWstdanom[x,y,m,*] = (nwet-mean(nwet,/nan))/stdev(nwet(where(finite(nwet)))) &$
    endfor &$
  endfor &$
endfor

;**********************************FIGURES 4 & 5 ***************************
;**************************RPAW corrlation with MW map!*********************
nfile = file_search('/jower/chg-mcnally/fromKnot/EXP01/monthly/Sm01*.img');132
mfile = file_search('/jower/chg-mcnally/ECV_soil_moisture/monthly/sahel/*.img');120
wfile = file_search('/jower/chg-mcnally/rpaw_monthly.img')
ifile7 = file_search('/jower/chg-mcnally/sahel_NSM_microwave_monthly_12yrs.img');this is NWET?

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


 
;*** (2) compare soil mositure by crop zones ***********************
cfile = file_search('/jower/chg-mcnally/cz_mask_sahel.img')

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

;***********these need to be z-scores, std anoms**********
NigerSM = fltarr(5,12,12)*!values.f_nan
SenegalSM = fltarr(5,12,12)*!values.f_nan
MaliSM = fltarr(5,12,12)*!values.f_nan
BurkinaSM = fltarr(5,12,12)*!values.f_nan
ChadSM = fltarr(5,12,12)*!values.f_nan

for m = 0,n_elements(sm01cube[0,0,*,0])-1 do begin &$
  for y = 0,n_elements(sm01cube[0,0,0,0:9])-1 do begin &$
    rpaw = rstdanom[*,*,m,y] &$
    smMW = mstdanom[*,*,m,y] &$ 
    sm01 = Lstdanom01[*,*,m,y] &$
    sm02 = Lstdanom02[*,*,m,y] &$
    nwet = nwstdanom[*,*,m,y] &$
    
    NigerSM[*,m,y] = [mean(rpaw(niger),/nan),mean(smMW(niger), /nan),mean(sm01(niger), /nan),mean(sm02(niger), /nan),mean(nwet(niger), /nan)] &$
    SenegalSM[*,m,y] =  [mean(rpaw(senegal), /nan),mean(smMW(senegal), /nan),mean(sm01(senegal), /nan),mean(sm02(senegal), /nan),mean(nwet(senegal), /nan)] &$
    MaliSM[*,m,y] =  [mean(rpaw(mali), /nan),mean(smMW(mali), /nan),mean(sm01(mali), /nan),mean(sm02(mali), /nan),mean(nwet(mali), /nan)] &$
    BurkinaSM[*,m,y] =  [mean(rpaw(burkina), /nan),mean(smMW(burkina), /nan),mean(sm01(burkina), /nan),mean(sm02(burkina), /nan),mean(nwet(burkina), /nan)] &$
    ChadSM[*,m,y] =  [mean(rpaw(chad), /nan),mean(smMW(chad), /nan),mean(sm01(chad), /nan),mean(sm02(chad), /nan),mean(nwet(chad), /nan)] &$
  endfor &$    
endfor;i
;print out vectors of standardized anomalies by country for google spreadsheet -- not easy for country by-country

p = 0
rpawvector = transpose([ reform(mean(burkinaSM[p,6:7,*], dimension=2,/nan)),reform(mean(chadSM[p,6:7,*], dimension=2, /nan)),$
                   reform(mean(maliSM[p,6:7,*], dimension=2,/nan)),reform(mean(nigerSM[p,6:7,*], dimension=2, /nan)), $
                   reform(mean(senegalSM[p,6:7,*], dimension=2, /nan)) ] )
                   
p = 1 
mwvector = transpose([ reform(mean(burkinaSM[p,6:7,*], dimension=2,/nan)),reform(mean(chadSM[p,6:7,*], dimension=2, /nan)),$
                   reform(mean(maliSM[p,6:7,*], dimension=2,/nan)),reform(mean(nigerSM[p,6:7,*], dimension=2, /nan)), $
                   reform(mean(senegalSM[p,6:7,*], dimension=2, /nan)) ] )
p = 2
sm01vector = transpose([ reform(mean(burkinaSM[p,6:7,*], dimension=2,/nan)),reform(mean(chadSM[p,6:7,*], dimension=2, /nan)),$
                   reform(mean(maliSM[p,6:7,*], dimension=2,/nan)),reform(mean(nigerSM[p,6:7,*], dimension=2, /nan)), $
                   reform(mean(senegalSM[p,6:7,*], dimension=2, /nan)) ] )
p = 4
nwvector = transpose([ reform(mean(burkinaSM[p,6:7,*], dimension=2,/nan)),reform(mean(chadSM[p,6:7,*], dimension=2, /nan)),$
                   reform(mean(maliSM[p,6:7,*], dimension=2,/nan)),reform(mean(nigerSM[p,6:7,*], dimension=2, /nan)), $
                   reform(mean(senegalSM[p,6:7,*], dimension=2, /nan)) ] )
                   
ensvector = mean([rpawvector, mwvector, sm01vector, nwvector],dimension=1, /nan) & help, ensvector

;does the yield data agree with these drougt years at all?
;***********yields***********
;read in yields data: maybe i need to go back and just get the 2001-2010 anomalies for this to work.

;average_2001_2010 
;Burkina 8201.10,Chad  5554.00 ,Mali  7569.80, Niger 4597.10, Senegal 6615.00 
;Burkina = [-574, -1043,  219,  -423, 933,1402,   -33,-243, -465, 228]
;Chad    = [-870, -498,  1617,  -836, 335, 296,  -599,  72,  -54, 537]
;Mali    = [-632, -2465, -897,  -848, 231, -24,  -162,1400, 1575,1820]
;Niger   = [18,   -107,   159,  -961, -97, 232,   -88, 629, -486, 702]
;Senegal = [ 334, -1554,  714, -1902, 985,  -9, -1973,1060, 1088,1257]

;these plots are in the excel Niger_2005_2008file and in gooddocs. 

;*********ET analysis**************************

;******************read in monthly ET data (RPAW, MW, LIS)********************************
;****************restrict the analysis to 2010 to match the soil moisture and yields******
;***************also make sure to apply the wrsi mask
lfile = file_search('/jower/chg-mcnally/fromKnot/EXP01/monthly/Evap*.img');132
rfile = file_search('/jower/chg-mcnally/rAET_monthly.img')

nx = 720
ny = 350
nyy = 250

;MOD16 ET data
ingridm = intarr(nx,nyy,n_elements(mfile))
bufferm = intarr(nx,ny)

;and the LIS Evap
ingridl = fltarr(720,250,n_elements(lfile))
bufferl = fltarr(720,250)

;read in the rpawcube
raetcube = fltarr(nx,ny,12,12)*!values.f_nan
openr,1,rfile
readu,1,raetcube
close,1

;get everyone to be the same size plz, thx
raetcube = raetcube(*,0:249,*,0:9)

for i=0,n_elements(lfile)-1 do begin &$
   openr,1,lfile[i] &$
   readu,1,bufferl &$
   close,1 &$
   ingridl[*,*,i] = bufferl*rmask &$
endfor 
   
mfile = file_search('/jower/sandbox/mcnally/MOD16/Africa/sahel/*{2001,2002,2003,2004,2005,2006,2007,2008,2009,2010}*.tif');156 2000-2012  
for i = 0, n_elements(mfile)-1 do begin &$   
   bufferm = read_tiff(mfile[i]) &$
   bufferm = reverse(bufferm,2) &$
   ingridm[*,*,i] = bufferm*rmask &$

endfor
ingridm = float(ingridm)
ingridm(where(ingridm eq 32767, count)) = !values.f_nan & print, count

;month cubies....720x250x10
raetcube = raetcube
modcube  = reform(ingridm,nx,250,12,10)/100.
liscube  = reform(ingridl,nx,250,12,11)*86400
liscube = liscube[*,*,*,0:9]
help, raetcube,modcube, liscube

;these should be standardized anomalies...should i do this with cube

ranom = fltarr(720,250,12,10)*!values.f_nan
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

lanom = fltarr(720,250,12,10)*!values.f_nan
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

manom = fltarr(720,250,12,10)*!values.f_nan
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    for m=0,n_elements(liscube[0,0,*,0])-1 do begin &$
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
NigerET = fltarr(3,12,12)
SenegalET = fltarr(3,12,12)
MaliET = fltarr(3,12,12)
BurkinaET = fltarr(3,12,12)
ChadET = fltarr(3,12,12)

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

;print out the anomalies to look at in goog?

p = 0
retvector = transpose([ reform(mean(burkinaET[p,7:8,*], dimension=2,/nan)),reform(mean(chadET[p,7:8,*], dimension=2, /nan)),$
                   reform(mean(maliET[p,7:8,*], dimension=2,/nan)),reform(mean(nigerET[p,7:8,*], dimension=2, /nan)), $
                   reform(mean(senegalET[p,7:8,*], dimension=2, /nan)) ] )
                   
p = 1 
letvector = transpose([ reform(mean(burkinaET[p,7:8,*], dimension=2,/nan)),reform(mean(chadET[p,7:8,*], dimension=2, /nan)),$
                   reform(mean(maliET[p,7:8,*], dimension=2,/nan)),reform(mean(nigerET[p,7:8,*], dimension=2, /nan)), $
                   reform(mean(senegalET[p,7:8,*], dimension=2, /nan)) ] )
p = 2
metvector = transpose([ reform(mean(burkinaET[p,7:8,*], dimension=2,/nan)),reform(mean(chadET[p,7:8,*], dimension=2, /nan)),$
                   reform(mean(maliET[p,7:8,*], dimension=2,/nan)),reform(mean(nigerET[p,7:8,*], dimension=2, /nan)), $
                   reform(mean(senegalET[p,7:8,*], dimension=2, /nan)) ] )

;T= soil moisture threshold
t=-0.3

;is this the best way to code this up??
;this is really aug/set but now i don't want to change it.
;not quite wroking try in the morning.
JARBK = mean(burkinaET[0,7:8,*], dimension=2, /nan)
JARCH = mean(chadET[0,7:8,*], dimension=2, /nan)
JARMA = mean(maliET[0,7:8,*], dimension=2, /nan)
JARNG = mean(nigerET[0,7:8,*], dimension=2, /nan)
JARSG = mean(senegalET[0,7:8,*], dimension=2, /nan)

prod_array = [jarbk, jarch, jarma, jarng, jarsg] & help, prod_array

a = intarr(5,10)
b = intarr(5,10)
c = intarr(5,10)
d = intarr(5,10)


;the ens_array comes from the soil moisture script....
ens_array=transpose(reform(ensvector,12,5)) ;ugh, why does this have two dimesnions? becasue it is by country? 5*12?
for x = 0, n_elements(ens_array[*,0])-1 do begin  &$
  for y = 0, 9 do begin &$
    ;truth positive product neg = B false alarm
    if ens_array[x,y] gt 0 AND prod_array[x,y] ge t then D[x,y] = 1 else D[x,y] = 0 &$ ;dinku A
    if ens_array[x,y] lt 0 AND prod_array[x,y] ge t then C[x,y] = 1 else C[x,y] = 0 &$ ;dinku B
    if ens_array[x,y] gt 0 AND prod_array[x,y] le t then B[x,y] = 1 else B[x,y] = 0 &$ ;dinku C
    if ens_array[x,y] lt 0 AND prod_array[x,y] le t then A[x,y] = 1 else A[x,y] = 0 &$ ;dinku D
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

prod_array = [jarbk, jarch, jarma, jarng, jarsg] & help, prod_array

a = intarr(5,10)
b = intarr(5,10)
c = intarr(5,10)
d = intarr(5,10)

;the ens_array comes from the soil moisture script....
for x = 0, n_elements(ens_array[*,0])-1 do begin  &$
  for y = 0,9 do begin &$
    ;truth positive product neg = B false alarm
    if ens_array[x,y] gt 0 AND prod_array[x,y] ge t then D[x,y] = 1 else D[x,y] = 0 &$ ;dinku A
    if ens_array[x,y] lt 0 AND prod_array[x,y] ge t then C[x,y] = 1 else C[x,y] = 0 &$ ;dinku B
    if ens_array[x,y] gt 0 AND prod_array[x,y] le t then B[x,y] = 1 else B[x,y] = 0 &$ ;dinku C
    if ens_array[x,y] lt 0 AND prod_array[x,y] le t then A[x,y] = 1 else A[x,y] = 0 &$ ;dinku D
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

prod_array = [jarbk, jarch, jarma, jarng, jarsg] & help, prod_array

a = intarr(5,10)
b = intarr(5,10)
c = intarr(5,10)
d = intarr(5,10)

;the ens_array comes from the soil moisture script....
for x = 0, n_elements(ens_array[*,0])-1 do begin  &$
  for y = 0, 9 do begin &$
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




;********FIGURE 6 -- WRSI ANOMALIES**********************
;*********Where is all the WRSI data and plots?? they are google figures, but still....maybe over in paper 2...
;start back here after run. here i am at 2:40. should be mellow enought to sit here for a bit.

;***plot the N-WRSI, R-WRSI for Wankama and Agoufou****
rfile = file_search('/jabber/chg-mcnally/EOS_WRSI_ubRFE2001_2012vPETv2.img') ;EOS_WRSI_NDVI2001_2012vPETv2.img
lfile = file_search('/jabber/chg-mcnally/EOS_WRSI_SM01_2001_2012.img')
cfile = file_search('/jabber/chg-mcnally/cz_mask_sahel.img')
nfile = file_search('/jabber/chg-mcnally/EOS_WRSI_NWET_2001_2012.img')

nx = 720
ny = 350
nz = 12

cgrid = fltarr(nx,ny)
mgrid = fltarr(nx,ny)
lgrid = fltarr(nx,ny,nz)
rgrid = fltarr(nx,ny,nz)
ngrid = fltarr(nx,ny,nz)

openr,1,cfile
readu,1,cgrid
close,1

openr,1,rfile
readu,1,rgrid
close,1
 
openr,1,nfile
readu,1,ngrid
close,1

openr,1,lfile
readu,1,lgrid
close,1

;calculate anomalies
RWanom = fltarr(nx,250,10);R-WRSI 2001-2012
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    RW = rgrid[x,y,0:9] &$
    test = where(finite(RW), count) &$
    if count le 1 then continue &$
    RWanom[x,y,*] = (RW-mean(RW,/nan)) &$
  endfor &$
endfor

NWanom = fltarr(nx,250,10);NWET-WRSI 2001-2012
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    Nwet = ngrid[x,y,0:9] &$
    test = where(finite(nwet), count) &$
    if count le 1 then continue &$
    NWanom[x,y,*] = (nwet-mean(nwet,/nan)) &$
  endfor &$
endfor

LWanom = fltarr(nx,250,10) ; 2001-2011 -- only go to 2010 to match SM analysis.
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    LW = lgrid[x,y,0:9] &$
    test = where(finite(LW), count) &$
    if count le 1 then continue &$
    LWanom[x,y,*] = (LW-mean(LW,/nan)) &$
  endfor &$
endfor

;*** (2) compare WRSI anomalies by crop zones ***********************
; these look different than the other way i calculated WRSI anoms...
cgrid = cgrid[*,0:249]

burkina = where(cgrid eq 1, count) & print, count
chad = where(cgrid eq 2, count) & print, count
mali = where(cgrid eq 3, count) & print, count
niger = where(cgrid eq 4, count) & print, count
senegal = where(cgrid eq 5, count) & print, count

NigerW = fltarr(3,12)*!values.f_nan
SenegalW = fltarr(3,12)*!values.f_nan
MaliW = fltarr(3,12)*!values.f_nan
BurkinaW = fltarr(3,12)*!values.f_nan
ChadW = fltarr(3,12)*!values.f_nan

  for y = 0,9 do begin &$
    RWRSI = RWanom[*,*,y] &$
    LWRSI = LWanom[*,*,y] &$
    NWRSI = NWanom[*,*,y] &$
    
    NigerW[*,y] =  [mean(RWRSI(niger),/nan),mean(LWRSI(niger), /nan),mean(NWRSI(niger), /nan)] &$
    SenegalW[*,y] =  [mean(RWRSI(senegal), /nan),mean(LWRSI(senegal), /nan),mean(NWRSI(senegal), /NAN)] &$
    MaliW[*,y] =  [mean(RWRSI(mali), /nan),mean(LWRSI(mali), /nan),mean(NWRSI(mali), /nan)] &$
    BurkinaW[*,y] =  [mean(RWRSI(burkina), /nan),mean(LWRSI(burkina), /nan),mean(NWRSI(burkina), /nan)] &$
    ChadW[*,y] =  [mean(RWRSI(chad), /nan),mean(LWRSI(chad), /nan),mean(NWRSI(chad), /nan)] &$
  endfor    

;ok, how did i do this for the soil moisture?
p = 0
rwrsivec = [ burkinaW[p,*],chadW[p,*],maliW[p,*], NigerW[p,*], senegalW[p,*] ] 

p = 1
lwrsivec = [ burkinaW[p,*],chadW[p,*],maliW[p,*], NigerW[p,*], senegalW[p,*] ] 

p = 2
nwrsivec = [ burkinaW[p,*],chadW[p,*],maliW[p,*], NigerW[p,*], senegalW[p,*] ] 

print, transpose(reform(transpose(rwrsivec), 5*12))

;*********************************************************
;compare Noah transpiration and geoWRSI AETc
;*******N-AET and R-AET***********************************
rfile = file_search('/jabber/chg-mcnally/rAET_monthly.img')
nfile = file_search('/jabber/chg-mcnally/nAET_monthly.img');...what is this? from NPAW or NWET
efile = file_search('/jabber/chg-mcnally/ETA/sahel/*.img')
lfile = file_search('/jower/chg-mcnally/fromKnot/EXP01/monthly/Evap*.img');is this avg or total? I think avg...
pfile = file_search('/jower/chg-mcnally/fromKnot/EXP01/monthly/Rain*.img')
vfile = file_search('/jower/chg-mcnally/fromKnot/EXP01/monthly/PoET*.img')
tfile = file_search('/jower/chg-mcnally/fromKnot/EXP02/monthly/TVeg*.img')
rofile = file_search('/jower/chg-mcnally/fromKnot/EXP01/monthly/Qsuf*.img')

nx = 720
ny = 350
nyy = 250

;for the ETA data...
ingride = fltarr(nx,ny,n_elements(efile))
buffere = bytarr(nx,ny)

;and the LIS Evap
ingridl = fltarr(720,250,n_elements(lfile))
bufferl = fltarr(720,250)

;and the LIS rainfall
ingridp = fltarr(720,250,n_elements(pfile))
bufferp = fltarr(720,250)

;and the LIS PoET
ingridv = fltarr(720,250,n_elements(vfile))
bufferv = fltarr(720,250)

;for the TVeg data...
ingridt = fltarr(nx,250,n_elements(tfile))
buffert = fltarr(nx,250)

;for the runoff data...
ingridro = fltarr(nx,250,n_elements(rofile))
bufferro = fltarr(nx,250)

;only compare from 2001-2010, why?
for i=0,n_elements(lfile)-1 do begin &$
   openr,1,efile[i] &$
   readu,1,buffere &$
   close,1 &$
   ingride[*,*,i] = buffere &$
   
   openr,1,lfile[i] &$
   readu,1,bufferl &$
   close,1 &$
   ingridl[*,*,i] = bufferl &$
   
   openr,1,pfile[i] &$
   readu,1,bufferp &$
   close,1 &$
   ingridp[*,*,i] = bufferp &$
      
   openr,1,vfile[i] &$
   readu,1,bufferv &$
   close,1 &$
   ingridv[*,*,i] = bufferv &$
   
   openr,1,tfile[i] &$
   readu,1,buffert &$
   close,1 &$
   ingridt[*,*,i] = buffert &$
   
   openr,1,rofile[i] &$
   readu,1,bufferro &$
   close,1 &$
   ingridro[*,*,i] = bufferro &$
endfor
etancube = reform(ingride,nx,ny,12,12)
liscube = reform(ingridl,nx,250,12,11)
raincube = reform(ingridp,nx,250,12,11)
PoETcube = reform(ingridv,nx,250,12,11)
TVegcube = reform(ingridt,nx,250,12,11)
Qsufcube = reform(ingridro,nx,250,12,11)

naetcube = fltarr(nx,ny,12,12)*!values.f_nan
raetcube = fltarr(nx,ny,12,12)*!values.f_nan

openr,1,nfile
readu,1,naetcube
close,1

openr,1,rfile
readu,1,raetcube
close,1

;Wankama 2006 - 2011
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5.) / 0.10)

;Belefoungou-Top 9.79506N     1.71450E  
bxind = FLOOR((1.7145 + 20.) / 0.10)
byind = FLOOR((9.79506 + 5) / 0.10)

;burkina Faso – (12◦16_N, 2◦9_W, > 12.26667N, 2.15
bfxind = FLOOR((-2.15 + 20.) / 0.10)
bfyind = FLOOR((12.26667 + 5) / 0.10)

;Nigeria 11.9N, 13.083E
ngxind = FLOOR((13.083 + 20.) / 0.10)
ngyind = FLOOR((11.9 + 5) / 0.10)

;Bambey Senegal 14°43′N 16°37′W (14.72, -16.62) 
sxind = FLOOR((-16.62 + 20.) / 0.10)
syind = FLOOR((14.43 + 5) / 0.10)

;********************************
;*****Figure 6,7 & 8*************
;********************************

xind = bxind
yind = byind
;agoufou=may-oct
;plot the average water balance for each site:
;somehow i need to stretch the month values to line up with the ticks....
p1 = plot(mean(raincube[xind,yind,*,*], dimension=4,/nan)*86400, 'b', thick=3, name= 'Precip')
p2 = plot(mean(liscube[xind,yind,*,*], dimension=4,/nan)*86400, 'g', /overplot, thick=3, name = 'Noah ET')
p3 = plot(mean(tvegcube[xind,yind,*,*], dimension=4,/nan)*86400, 'c', /overplot, thick=3, name = 'Noah Transpiration')
p4 = plot(mean(raetcube[xind,yind,*,*], dimension=4,/nan), linestyle=2, /overplot, thick=3, name = 'geoWRSI AETc')
p1.xrange=[0,11]
xticks = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec' ]
p1.xtickname = xticks
!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3]) ;
p1.title='Belefougou, Benin Water Balance'
p1.xminor=0
p1.yminor=0

a = total(mean(raincube[xind,yind,2:9,*], dimension=4,/nan)*86400) & print, a
b = total(mean(liscube[xind,yind,2:9,*], dimension=4,/nan)*86400) & print, b, b/a
c = total(mean(tvegcube[xind,yind,2:9,*], dimension=4,/nan)*86400) & print, c/a
d = total(mean(raetcube[xind,yind,2:9,*], dimension=4,/nan), /nan) & print, d/a
e = mean(mean(raetcube[xind,yind,2:9,*], dimension=3,/nan), dimension=3, /nan)& print,e
;

;this finds the evap/transpration:rainfall ratios for summer
;in the steps above I did it using the length of season specified by geoWRSI
GW = fltarr(nx,ny); geoWRSI AET
NH = fltarr(nx,ny);Noah transpiration
ER = fltarr(nx,ny);evap ratio (Noah)
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    GW[x,y]=mean(total(raetcube[x,y,*,*],3, /nan)/total(raincube[x,y,*,*]*86400,3, /nan)) &$
    NH[x,y]=mean(total(tvegcube[x,y,5:9,*],3, /nan)/total(raincube[x,y,5:9,*],3, /nan)) &$
    ER[x,y]=mean(total(liscube[x,y,5:9,*],3, /nan)/total(raincube[x,y,5:9,*],3, /nan)) &$
  endfor &$
endfor

;*****average PET, AET and anomalies over each country******
ranom = fltarr(720,350,12,12)*!values.f_nan
lavg = mean(liscube,dimension=4, /nan)
lanom = fltarr(720,250,12,11)*!values.f_nan

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

;***Figures 8-12 re: AET anomalies -- how to get the WRSI no-start to highlight?
;ET anomalies average over country.....map the 2002 ad 2009 anomalies.
rmask=mean(raetcube[*,*,*,0], dimension=3,/nan)
good = where(finite(rmask), complement=other)
rmask(other)=!values.f_nan
rmask(good)=1

p1 = image(mean(lanom[*,*,6:7,1], dimension=3, /nan)*rmask, rgb_table=6)
p1 = image(mean(ranom[*,*,6:7,1], dimension=3, /nan), rgb_table=6)

p1 = image(mean(lanom[*,*,6:7,8], dimension=3, /nan)*rmask, image_dimensions=[72.0,25.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=6,title = 'July/Aug Noah ET anomaly')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) 
  
  
p1 = image(mean(ranom[*,*,6:7,8], dimension=3, /nan), image_dimensions=[72.0,25.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=6,title = '2009 July/Aug geoWRSI AETc anomaly', min_value=-2, max_value=2)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) 

;*************************
NigerET = fltarr(2,12,11)
SenegalET = fltarr(2,12,11)
MaliET = fltarr(2,12,11)
BurkinaET = fltarr(2,12,11)
ChadET = fltarr(2,12,11)

for m = 0,n_elements(lanom[0,0,*,0])-1 do begin &$
  for y = 0,n_elements(lanom[0,0,0,*])-1 do begin &$
    ret = ranom[*,*,m,y] &$
    let = lanom[*,*,m,y] &$
    NigerET[*,m,y] =  [mean(ret(niger),/nan),mean(let(niger), /nan)] &$
    SenegalET[*,m,y] =  [mean(ret(senegal), /nan),mean(let(senegal),/nan)] &$
    MaliET[*,m,y] =  [mean(ret(mali), /nan),mean(let(mali), /nan)] &$
    BurkinaET[*,m,y] =  [mean(ret(burkina), /nan),mean(let(burkina), /nan)] &$
    ChadET[*,m,y] =  [mean(ret(chad), /nan),mean(let(chad), /nan)] &$
  endfor &$    
endfor;i

Bret = reform(BurkinaET[0,*,*],132)
Blet = reform(BurkinaET[1,*,*],132)
good = where(finite(Bret))

Cret = reform(ChadET[0,*,*],132)
Clet = reform(ChadET[1,*,*],132)
good = where(finite(Cret))

Mret = reform(MaliET[0,*,*],132)
Mlet = reform(MaliET[1,*,*],132)
good = where(finite(Mret))

Nret = reform(NigerET[0,*,*],132)
Nlet = reform(NigerET[1,*,*],132)
good = where(finite(Nret))

Sret = reform(SenegalET[0,*,*],132)
Slet = reform(SenegalET[1,*,*],132)
good = where(finite(Sret))

Xret = Sret
Xlet = Slet
 
p1 = plot(Xret,Xlet,'o',sym_size=1, /SYM_FILLED, name = 'N-ET')
print, correlate(Xret(good),Xlet(good))
print, r_correlate(Xret(good),Xlet(good))

;correlation between Noah ET and geoWRSI AET anomalies, not awful.
;  corr   rcorr
;B  0.52  0.51
;C  0.48  0.49
;M  0.63  0.67
;N  0.53  0.49
;S  0.62  0.58
 
p1 = plot(Nret,Nlet,'o',sym_size=1, /SYM_FILLED, name = 'N-ET')
print, correlate(Nret(good),Nlet(good));0.52
print, r_correlate(Nret(good),Nlet(good));0.49


;figure 12 green veg fraction
ifile = file_search('/home/chg-mcnally/gvf_12mo_10KMsahel.1gd4r')
nx = 720
ny = 350

grnsahl = fltarr(nx,ny,12)
openr,1,ifile
readu,1, grnsahl
close,1

grnsahl(where(grnsahl lt 0)) = !values.f_nan
p1 = image(mean(grnsahl[*,*,5:9],dimension=3, /nan), image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=20, min_value=-0.2, max_value=1)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
p1.title = 'Average NCEP GVF Jun-October ' 
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])  
  
  
 ;Agoufou 15.35400    -1.47900 
 star = TEXT(-1.5, 15.3, /DATA, '*', $
       FONT_SIZE=42, FONT_STYLE='Bold', $
       FONT_COLOR='blue')
 ;Wankama 
  star = TEXT(2.7, 13.5, /DATA, '*', $
       FONT_SIZE=42, FONT_STYLE='Bold', $
       FONT_COLOR='blue')
 ;Mpala
  star = TEXT(37, 0.5, /DATA, '*', $
       FONT_SIZE=42, FONT_STYLE='Bold', $
       FONT_COLOR='blue')
  ;Belefoungou-Top 9.79506     1.71450  
  star = TEXT(1.7,9.8, /DATA, '*', $
       FONT_SIZE=42, FONT_STYLE='Bold', $
       FONT_COLOR='blue')


;APPENDIX A
;*****rainfall compare***************
;I think that this might just end up as a table. Possible that a time series would 
;be useful somewheres but not needed just yet. 
ifile = file_search('/jabber/chg-mcnally/mae_*_sta.img')

nx = 720
ny = 350
nz = 12
maegrid = fltarr(nx,ny,nz)
allgrid = fltarr(nx,ny,nz,n_elements(ifile))
for i = 0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[i] &$
  readu,1,maegrid &$
  close,1 &$
  
  allgrid[*,*,*,i] = maegrid &$
endfor

;cmap, rfe, ubrfe
;month of interest
m = 6
m = m-1
;rainfall product of interest
p = 0 ; cmap=0, rfe=1, ubrf=2
p1 = image(allgrid[*,*,m,0], RGB_TABLE=20,image_dimensions=[72.0,35.0], image_location=[-20,-5], $ 
 min_value=0, max_value=60, dimensions=[nx/100,ny/100])
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20)
  p1.title = 'mean abs error CMAP Sept (vs CSCDP krigged stations)'
  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 52], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])  
  
 ;maybe take the average of the whole map & individual values for AG, WK, BB

;MAE for each month at the three sites
agmae = fltarr(12,3)
wkmae = fltarr(12,3)
bbmae = fltarr(12,3)
for i = 0,11 do begin &$
  for j = 0,n_elements(ifile)-1 do begin &$
    agmae[i,j] = allgrid[axind,ayind,i,j] &$
    wkmae[i,j] = allgrid[wxind,wyind,i,j] &$
    bbmae[i,j] = allgrid[bxind,byind,i,j] &$
  endfor &$
endfor   

p1=plot(agmae[*,0], name = 'ag-mae cmap')
p2=plot(agmae[*,1], name = 'ag-mae rfe', 'b', /overplot)
p3=plot(agmae[*,2], name = 'ag-mae ubrfe', 'g', /overplot)
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) ;

p1=plot(wkmae[*,0], name = 'wk-mae cmap')
p2=plot(wkmae[*,1], name = 'wk-mae rfe', 'b', /overplot)
p3=plot(wkmae[*,2], name = 'wk-mae ubrfe', 'g', /overplot)
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) ;


p1=plot(bbmae[*,0], name = 'bb-mae cmap')
p2=plot(bbmae[*,1], name = 'bb-mae rfe', 'b', /overplot)
p3=plot(bbmae[*,2], name = 'bb-mae ubrfe', 'g', /overplot)
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) ;

;**************correlations between station data and the different products**********
;***Appendix****compare with monthly in-situ**
;use files assocatied with table 1 (NWET, SM01, RPAW monthly
bfile = file_search('/jabber/chg-mcnally/belefoungou.20.40.60.SM_monthly2006_2009.csv')
wfile = file_search('/jabber/chg-mcnally/wanakma.14.47.71.SM_monthly2006_2011.csv')
afile = file_search('/jabber/chg-mcnally/agoufou.103.203.304.106.206.SM_monthly2005_2008.csv')

bb = read_csv(bfile) & help, bb
wk = read_csv(wfile) & help, wk
ag = read_csv(afile)

;look at the time series...
;Belefoungou-Top 9.79506     1.71450  
bxind = FLOOR((1.7145 + 20.) / 0.10)
byind = FLOOR((9.79506 + 5) / 0.10)

b20cube = reform(float(bb.field1),12,4);2006-2009
b40cube = reform(float(bb.field2),12,4)
b60cube = reform(float(bb.field3),12,4)

;june to september correlations
print, correlate(nwetcube[bxind,byind,5:8,5],b20cube[5:8,0]);0.86 - check out sos....
print, correlate(nwetcube[bxind,byind,5:8,6],b20cube[5:8,1]);0.97
print, correlate(nwetcube[bxind,byind,5:8,7],b20cube[5:8,2]);0.99
print, correlate(nwetcube[bxind,byind,5:8,8],b20cube[5:8,3]);0.87
print, correlate(nwetcube[bxind,byind,5:8,7],b20cube[5:8,2]);-0.37

;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

wk14cube = reform(wk.field1,12,6)
wk47cube = reform(wk.field2,12,6)
wk71cube = reform(wk.field3,12,6)

print, correlate(nwetcube[wxind,wyind,5:8,5],wk14cube[5:8,0])
print, correlate(nwetcube[wxind,wyind,5:8,6],wk14cube[5:8,1])
print, correlate(nwetcube[wxind,wyind,5:8,7],wk14cube[5:8,2])
print, correlate(nwetcube[wxind,wyind,5:8,8],wk14cube[5:8,3])
print, correlate(nwetcube[wxind,wyind,5:8,9],wk14cube[5:8,4])
print, correlate(nwetcube[wxind,wyind,5:8,10],wk14cube[5:8,5])

;Agoufou_1 15.35400    -1.47900  agoufou.103.203.304.106.206 - skip 206, 203 since they are missing 2005, 103 might as well be...
axind = FLOOR((-1.4807 + 20.) / 0.10)
ayind = FLOOR((15.3432 + 5) / 0.10)

a103cube=reform(float(ag.field1),12,4);2005-2008
a203cube=reform(float(ag.field2),12,4)
a304cube=reform(float(ag.field3),12,4)
a106cube=reform(float(ag.field4),12,4)
a206cube=reform(float(ag.field5),12,4)

print, correlate(nwetcube[axind,ayind,5:8,4],a304cube[5:8,0]);0.99!
print, correlate(nwetcube[axind,ayind,5:8,5],a304cube[5:8,1])
print, correlate(nwetcube[axind,ayind,5:8,6],a304cube[5:8,2])
print, correlate(nwetcube[axind,ayind,5:8,7],a304cube[5:8,3])

;20, 40, 60...
bbmean = mean(reform(transpose([[float(bb.field1)],[float(bb.field2)],[float(bb.field3)]]),3,12,4), dimension=3,/nan)
wkmean = mean(reform(transpose([[float(wk.field1)],[float(wk.field2)],[float(wk.field3)]]),3,12,6), dimension=3,/nan)
agmean = mean(reform(transpose([[float(ag.field1)],[float(ag.field2)],[float(ag.field3)],[float(ag.field4)],$
              [float(ag.field5)]]),5,12,4), dimension=3,/nan)
              
;********when is SOS, does that explain misfits in SM01&SM02*******
;doesn't actually mean the sos was correct I supposed - I could check the station data...
ifile = file_search('/jabber/chg-mcnally/SOSsahel_ubRFE_2001_2001.img')
sosgrid = fltarr(nx,ny,12)
;ifile = file_search('/home/mcnally/regionmasks/SOSsahel.img')
;sosgrid = bytarr(nx,ny)

openr,1,ifile
readu,1,sosgrid
close,1
;benin SOS 2006-2009
print, sosgrid[bxind,byind,5:8]
;*******************************************************************

;************************************
;correlations with the in-situ soil moisture means:
;I would say that Noah definately produces better soil moisture estimates than the WRSI bucket model, 
;especially in dry places like Mali, but also niger. 
;;******************BENIN************************************
;at 20/40/60cm depth - SM02&60cm have highest corr, but 40cm argreed best will all of the products.
d = 0
print, correlate(bbmean[d,*],mean(sm01cube[bxind,byind,*,*],dimension=4,/nan));0.95/0.92/0.88
print, correlate(bbmean[d,*],mean(sm02cube[bxind,byind,*,*],dimension=4,/nan));0.93/0.96/0.97
print, correlate(bbmean[d,*],mean(npawcube[bxind,byind,*,*],dimension=4,/nan));0.77/0.79/0.75

good = where(finite(mean(rpawcube[bxind,byind,*,*],dimension=4,/nan)))
avg = mean(rpawcube[bxind,byind,*,*],dimension=4,/nan)
print, correlate(bbmean[d,good],avg(good));0.94/0.90/0.86

print, correlate(bbmean[d,*],mean(smMWcube[bxind,byind,*,*],dimension=4,/nan));0.94/0.91/0.86

;;******************Agoufou************************************
;In mali SM01 does the best  by far.
d = 4
print, correlate(agmean[d,*],mean(sm01cube[axind,ayind,*,*],dimension=4,/nan));0.96/0.97/0.95/0.95/0.86
print, correlate(agmean[d,*],mean(sm02cube[axind,ayind,*,*],dimension=4,/nan));0.67/0.75/0.77/072/0.68
print, correlate(agmean[d,*],mean(npawcube[axind,ayind,*,*],dimension=4,/nan));0.17/0.05/0.12/0.23/0.12

good = where(finite(mean(rpawcube[axind,ayind,*,*],dimension=4,/nan)))
avg = mean(rpawcube[axind,ayind,*,*],dimension=4,/nan)
print, correlate(agmean[d,good],avg(good));0.089/-0.25/-0.09/0.15/-0.15

good = where(finite(mean(smMWcube[axind,ayind,*,*],dimension=4,/nan)))
avg = mean(smMWcube[axind,ayind,*,*],dimension=4,/nan)
print, correlate(agmean[4,good],avg(good));0.73/0.72/0.68/0.68/0.66
;;******************NIGER************************************
;SM02 def does the best here.
d = 2
print, correlate(wkmean[d,*],mean(sm01cube[wxind,wyind,*,*],dimension=4,/nan));0.91/0.84/0.82
print, correlate(wkmean[d,*],mean(sm02cube[wxind,wyind,*,*],dimension=4,/nan));0.95/0.92/0.91
print, correlate(wkmean[d,*],mean(npawcube[wxind,wyind,*,*],dimension=4,/nan));0.88/0.81/0.7

good = where(finite(mean(rpawcube[wxind,wyind,*,*],dimension=4,/nan)))
avg = mean(rpawcube[wxind,wyind,*,*],dimension=4,/nan)
print, correlate(wkmean[d,good],avg(good));0.80/0.75/0.62

good = where(finite(mean(smMWcube[wxind,wyind,*,*],dimension=4,/nan)))
avg = mean(smMWcube[wxind,wyind,*,*],dimension=4,/nan)
print, correlate(wkmean[d,good],avg(good));0.85/0.85/0.84
;************************************************************************
              
;Find the average SOS for the crop zone...
;ifile = file_search('/jabber/chg-mcnally/SOSsahel_ubRFE_2001_2001.img')
;sosgrid = fltarr(nx,ny,12)
ifile = file_search('/home/mcnally/regionmasks/SOSsahel.img')
sosgrid = bytarr(nx,ny)

openr,1,ifile
readu,1,sosgrid
close,1   

burkinasos = fltarr(12)
chadsos = fltarr(12)
malisos = fltarr(12)
nigersos = fltarr(12)
senegalsos = fltarr(12)


  for y = 0,n_elements(sosgrid[0,0,*])-1 do begin &$
    sos = sosgrid[*,*] &$
    
    BurkinaSOS = mean(sos(burkina), /nan)&$
    ChadSOS = mean(sos(chad), /nan) &$
    MaliSOS = mean(sos(mali), /nan) &$    
    NigerSOS = mean(sos(niger),/nan) &$
    SenegalSOS = mean(sos(senegal), /nan) &$
  
  endfor
 print, transpose([ reform(burkinaSos),reform(chadSOS),reform(maliSOS),$
                   reform(nigerSOS),reform(senegalSOS) ])


;;fix these up for christa/kristi
;xtickvalues=indgen(12)*12+5
;xticknames = ['01' , '02', '03', '04','05', '06',  '07', '08', '09', '10', '11','12']
;p1 = plot(reform(raetcube[xind,yind,*,*],144), name='geoWRSI AETc', thick=2)
;p2 = plot(reform(raincube[xind,yind,*,*],132)*86400, /overplot,'b', name='ubREF2 rainfall', thick=2)
;p3 = plot(reform(liscube[xind,yind,*,*],132)*86400, /overplot,'g', name='Noah32 ET', thick=1)
;p4 = plot(reform(tvegcube[xind,yind,*,*],132)*86400, /overplot,'c', name='Noah32 transpiration', thick=2)
;;p1=plot(reform(poetcube[xind,yind,*,*],132)*86400, /overplot,'orange', 'Noah Penman-PET')
;p1.xtickvalues = xtickvalues
;p1.xtickname = xticknames
;p1.font_size = 14
;p1.yminor = 0
;p1.ytitle='(mm)'
;p1.title ='Wankama, Niger water balance: ubRFE2, Noah32 ET & transpiration, geoWRSI AETc'
;!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=14) ;

;;well, WRSI predicts about 30% of rainfall. which sounds transpiration-y....but is a little high. I think shuttleworth suggested that the KC overestiamtes?
;;happy i am finally getting somewhere with this. It does look like the timing is a problem...although adding over these months is reasonable...
;print, mean(total(raetcube[xind,yind,*,*],3, /nan)/total(raincube[xind,yind,*,*]*86400,3, /nan));mean=20% transp.
;print, mean(total(tvegcube[xind,yind,5:9,*],3, /nan)/total(raincube[xind,yind,5:9,*],3, /nan));mean=10% transp - ok maybe this is a buit low?
;print, mean(total(liscube[xind,yind,5:9,*],3, /nan)/total(raincube[xind,yind,5:9,*],3, /nan)); mean=80% for the growing season
;print, mean(total(Qsufcube[xind,yind,5:9,*],3, /nan)/total(raincube[xind,yind,5:9,*],3, /nan)); mean=80% for the growing season
;print, mean(total(liscube[xind,yind,5:9,*],3, /nan)/total(poetcube[xind,yind,5:9,*],3, /nan));mean=30%
;
;print, mean(total(raincube[sxind,syind,*,*],3),dimension=3)*86400 ;373
;print, mean(total(poETcube[sxind,syind,*,*],3),dimension=3)*86400 ;373


;***map dekad peak of season*****

nx=720
ny=250

x = wxind
y = wyind
mdw =fltarr(12)
wmaxdek = fltarr(nx,ny)
mdn =fltarr(12)
nmaxdek = fltarr(nx,ny)
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    mdw[*] = mean(raetcube[x,y,*,*], dimension=4, /nan) &$
    mdn[*] = mean(tvegcube[x,y,*,*], dimension=4, /nan) &$
    wmaxdek[x,y] = where(mdw eq max(mdw,/nan)) &$
    good = where(mdn eq max(mdn,/nan)) &$
    nmaxdek[x,y] = good[0] &$
  endfor &$
endfor
   
p1 = image(wmaxdek+1, rgb_table=22, max_value=11)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20) &$
             
p1 = image(wmaxdek+1, image_dimensions=[72.0,25.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=4, min_value=5)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
p1.title = 'geoWRSI month of peak transpiration' ;change the season if you want to look at kenya
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])                  
             
             
p1 = image(nmaxdek*rmask, rgb_table=22, max_value=10)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20) &$

p1 = image((nmaxdek+1)*rmask, image_dimensions=[72.0,25.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=4, min_value=5, max_value=11)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
p1.title = 'Noah month of peak transpiration' ;change the season if you want to look at kenya
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])  


;****************crop mask***************
ifile = file_search('/jabber/chg-mcnally/cropmask_01deg_sahel.img'); 1=8 bit byte
cropmask = fltarr(nx,ny)
openr,1,ifile
readu,1,cropmask
close,1
;*****and WRSI mask?********
rmask=mean(raetcube[*,*,*,0], dimension=3,/nan)
good = where(finite(rmask), complement=other)
rmask(other)=!values.f_nan 
rmask(good)=1
;**************************************
ncolors=256           
p1 = image((GW-NH)*cropmask*rmask, image_dimensions=[72.0,25.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), min_value=-0.5, max_value=0.5)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
p1.title = 'geoWRSI and Noah transpiration ratio (T:rainfall) June-October w/ crop mask' ;change the season if you want to look at kenya
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])     
  ;******************overlay rainfall totals******************************
  ;read in FCLIM data to make annual rainfall total mask 
fx = 1501
fy = 1601
fz = 12
climgrid = LONARR(fx,fy,fz)

climfile = file_search('/jabber/LIS/Data/FCLIM_Afr/*.img')
openr,1, climfile
readu,1, climgrid
close,1

climgrid = float(climgrid[*,*,*])
null = where(climgrid lt 0, count) & print, count
climgrid(null) = !values.f_nan
totclim = reverse(total(climgrid,3, /nan),2)
temp = image(totclim, rgb_table=20)

;matches up correctly
totclimCoarse = congrid(totclim, 751,801)
xrt = (751-1)-3/0.1  ;RFE goes to 55, sahel goes to 52 plus an extra pixel
ybot = (35/0.1)+1    ;sahel starts at -5S
ytop = (801-1)-10/0.1  ; &$sahel stops at 30N
xlt = 1.              ;and I guess sahel starts at 19W, rather than 20....
sahel = totclimcoarse[xlt:xrt,ybot:ytop]

nx = 720
ny = 350
longitude = findgen(720)-200
latitude = findgen(350)-50  
;*cropmask*rmask
ncontour = 8
index = findgen(ncontour)/10. +0.1


p1 = image((GW-NH)*rmask, image_dimensions=[72.0,25.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), min_value=-0.5, max_value=0.5)

p1 = MAP('Geographic',LIMIT = [-5, -20, 18, 52], /overplot)
p2 = contour(mean(grnsahl[*,*,5:9], dimension=3,/nan),longitude/10,latitude/10,rgb_table=4, C_VALUE=index, RGB_INDICES=[FINDGEN(ncontour)*255./FLOAT(ncontour)],$
             mapgrid=p1,/overplot)
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) 
c = COLORBAR(target=p2,ORIENTATION=0,/BORDER_ON, $
 POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100], taper=1)
   
;;;GREG SAMPLE TEXT
ncontour = 8
index = findgen(ncontour)/10. +0.1
tmptr = CONTOUR(mean(grnsahl[*,*,5:9],DIMENSION=3,/NAN),FINDGEN(720)/10. -20.0,FINDGEN(350)/10. -5., $
RGB_TABLE=4, ASPECT_RATIO=1, C_VALUE=index, RGB_INDICES=[FINDGEN(ncontour)*255./FLOAT(ncontour)], $
   MAP_PROJECTION='Geographic',/CURRENT, mapgrid=p1)
   
tmptr.mapgrid.linestyle = 6 & tmptr.mapgrid.label_position = 0
tmptr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=p2,ORIENTATION=1,TAPER=1,/BORDER)
;;;END GREG SAMPLE

m = mean(total(liscube[wxind,wyind,5:9,*],3, /nan)/total(poetcube[wxind,wyind,5:9,*],3, /nan),/nan)
b1=barplot((total(liscube[wxind,wyind,5:9,*],3, /nan)/total(poetcube[wxind,wyind,5:9,*],3, /nan))-m)


;compare with station data
afile = '/jabber/chg-mcnally/LHFLX_Agoufou_monthly_2007_2008.csv'
kfile = '/jabber/chg-mcnally/LHFLX_Kelma_monthly_2007_2008.csv'
wfile = '/jabber/chg-mcnally/LHFLX_WankFal_monthly_2006.csv'

a0708 = read_csv(afile)
k0708 = read_csv(kfile)
wf06  = read_csv(wfile)

;lat lons of the sites...
 ;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.4807 + 20.) / 0.10)
ayind = FLOOR((15.3432 + 5) / 0.10)

;Kelma (-15.2237;-1.5002)
kxind = FLOOR((-1.5002 + 20.) / 0.10)
kyind = FLOOR((15.2237 + 5) / 0.10)

p1 = plot(wf06.field1,/overplot,'b', thick=3)
p1 = plot((liscube[wxind,wyind,*,5]*86400-86400)*100,/overplot)
p1 = plot(naetcube[wxind,wyind,*,5]+200, /overplot, 'g')

lis0708 = [[[liscube[axind,ayind,*,6]*86400-86400]],[[liscube[axind,ayind,*,7]*86400-86400]]] & help, lis0708
p1 = plot(float(a0708.field1),/overplot,'b', thick=3)
p1 = plot(lis0708*40,/overplot)
p1 = plot(raetcube[axind,ayind,*,5]+100, /overplot, 'g')

;what kind of veg in at kalma? the phase is totally off...
lis0708 = [[[liscube[kxind,kyind,*,6]*86400-86400]],[[liscube[kxind,kyind,*,7]*86400-86400]]] & help, lis0708
p1 = plot(float(k0708.field1),/overplot,'b', thick=3)
p1 = plot(lis0708*40,/overplot)
p1 = plot(naetcube[kxind,kyind,*,5]+100, /overplot, 'g')

;
;p3 = plot(NigerET[3,m,*],NigerET[0,m,*],'bo',/overplot, sym_size=2,/SYM_FILLED, name='ETa')
;p2 = plot(NigerET[2,m,*],NigerET[0,m,*],'go',/overplot, sym_size=2,/SYM_FILLED,$
;          yminor=0, xminor=0,font_name='times', ytitle='R-ET',$ 
;          xtitle = 'other estimates', name='Noah-ET')
;!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14)
;
;p2.xrange=[-1.5,1.5]
;p2.yrange=[-1.5,1.5]
;p1.title = 'July standardized anomalies ET'
;p1.font_size = 20
;p3=plot([0,0],[-1.5,1.5],/overplot)
;p3=plot([-1.5,1.5],[0,0],/overplot)
;;***************************************************************************************
;m=7
;p1 = plot(SenegalET[1,m,*],SenegalET[0,m,*],'o',sym_size=2, name = 'N-ET')
;p3 = plot(SenegalET[3,m,*],SenegalET[0,m,*],'bo',/overplot, sym_size=2,/SYM_FILLED, name='ETa')
;p2 = plot(SenegalET[2,m,*],SenegalET[0,m,*],'go',/overplot, sym_size=2,/SYM_FILLED,$
;          yminor=0, xminor=0,font_name='times', ytitle='R-ET',$ 
;          xtitle = 'other estimates', name='Noah-ET')
;!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14)
;
;p2.xrange=[-2,2]
;p2.yrange=[-2,2]
;p1.title = 'Sept standardized anomalies ET Senegal'
;p1.font_size = 20
;p3=plot([0,0],[-2,2],/overplot)
;p3=plot([-2,2],[0,0],/overplot)
;;***************************************************************************************
;;***************************************************************************************
;m=5
;p1 = plot(MaliET[1,m,*],MaliET[0,m,*],'o',sym_size=2, name = 'N-ET')
;p3 = plot(MaliET[3,m,*],MaliET[0,m,*],'bo',/overplot, sym_size=2,/SYM_FILLED, name='ETa')
;p2 = plot(MaliET[2,m,*],MaliET[0,m,*],'go',/overplot, sym_size=2,/SYM_FILLED,$
;          yminor=0, xminor=0,font_name='times', ytitle='R-ET',$ 
;          xtitle = 'other estimates', name='Noah-ET')
;!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14)
;
;mn = -1.5
;mx = 1.5
;p2.xrange=[mn,mx]
;p2.yrange=[mn,mx]
;p1.title = 'June standardized anomalies ET Mali'
;p1.font_size = 20
;p3=plot([0,0],[mn,mx],/overplot)
;p3=plot([mn,mx],[0,0],/overplot)
;;***************************************************************************************
;;***************************************************************************************
;m=8
;p1 = plot(BurkinaET[1,m,*],BurkinaET[0,m,*],'o',sym_size=2, name = 'N-ET')
;p3 = plot(BurkinaET[3,m,*],BurkinaET[0,m,*],'bo',/overplot, sym_size=2,/SYM_FILLED, name='ETa')
;p2 = plot(BurkinaET[2,m,*],BurkinaET[0,m,*],'go',/overplot, sym_size=2,/SYM_FILLED,$
;          yminor=0, xminor=0,font_name='times', ytitle='R-ET',$ 
;          xtitle = 'other estimates', name='Noah-ET')
;!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14)
;
;mn = -1.5
;mx = 1.5
;p2.xrange=[mn,mx]
;p2.yrange=[mn,mx]
;p1.title = 'Sept standardized anomalies ET Burkina'
;p1.font_size = 20
;p3=plot([0,0],[mn,mx],/overplot)
;p3=plot([mn,mx],[0,0],/overplot)
;;***************************************************************************************
;;***************************************************************************************
;m=8
;p1 = plot(ChadET[1,m,*],chadET[0,m,*],'o',sym_size=2, name = 'N-ET')
;p3 = plot(chadET[3,m,*],chadET[0,m,*],'bo',/overplot, sym_size=2,/SYM_FILLED, name='ETa')
;p2 = plot(chadET[2,m,*],chadET[0,m,*],'go',/overplot, sym_size=2,/SYM_FILLED,$
;          yminor=0, xminor=0,font_name='times', ytitle='R-ET',$ 
;          xtitle = 'other estimates', name='Noah-ET')
;!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14)
;
;mn = -1.5
;mx = 1.5
;p2.xrange=[mn,mx]
;p2.yrange=[mn,mx]
;p1.title = 'Sept standardized anomalies ET Chad'
;p1.font_size = 20
;p3=plot([0,0],[mn,mx],/overplot)
;p3=plot([mn,mx],[0,0],/overplot)
;;***************************************************************************************
;nbars = 5
;colors = ['blue', 'green', 'cyan', 'grey', 'maroon']
;name = ['R-ET', 'N-ET', 'LIS-ET','EROS-ETA']
;
;  index = 0
;  xticks = ['July', 'Aug', 'Sept']
;  xtickvalues = [0,1,2]
;
;for y =1,4 do begin &$
;  for p=0,n_elements(NigerET[*,0,0])-1 do begin &$
;   ;y=1 &$
;    b2 = barplot(ChadET[p,6:8,y], nbars=nbars, fill_color=colors[p],index=p, name = name[p], /overplot) &$
;   
;   b2.yrange=[-2,2] &$
;   b2.xminor = 0 &$
;   b2.yminor = 0 &$
;   b2.xtickvalues = xtickvalues &$
;   b2.xtickname = xticks &$
;   b2.font_name='times' &$
;   b2.font_size=16 &$
;   b2.title = 'Chad ET standardized anomalies '+strcompress('200'+string(y+1), /remove_all) &$
;   ax = b2.axes &$
;   ax[2].HIDE = 1  &$
;   ax[3].HIDE = 1  &$
;   if p lt 3 then continue &$
;   !null = legend(target=[b1], position=[0.2,0.3], font_size=14) &$
;  endfor &$
;  w=window() &$
;endfor
;;*******************************
;ncolors=256
;p1 = image(ganom[*,*,7,4]*mask, image_dimensions=[72.0,25.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
;           RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), min_value=-2, max_value=2)
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
;p1.title='ETa 2005 Aug'
;compare monthly nAET, rAET anomalies and ETa
;cormap = fltarr(nx,ny,12,2)
;for x = 0,nx-1 do begin &$
;  for y = 0,ny-1 do begin &$
;    for m = 0,11 do begin &$
;      good = where(finite(etancube[x,y,m,*]), count) &$
;      if count le 1 then continue &$
;      ;print, x,y,m &$
;      cormap[x,y,m,*] = r_correlate(etancube[x,y,m,good], ranom[x,y,m,good]) &$
;    endfor &$
;  endfor   &$
;endfor
;good = where(finite(ranom[*,*,*,0]), complement=null)
;test = cormap
;test(null)=!values.f_nan
;p1=image(test[*,*,8,0], rgb_table=20, min_value=0, max_value=0.6)
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
;why did i pick g? 
;ganom = fltarr(720,250,12,12)*!values.f_nan
;for x = 0,nx-1 do begin &$
;  for y = 0,250-1 do begin &$
;    for m=0,n_elements(etancube[0,0,*,0])-1 do begin &$
;      get = etancube[x,y,m,*] &$
;      test = where(finite(get),count) &$
;      if count le 1 then continue &$
;      gsigma = stdev(get(where(finite(get)))) &$
;      ganom[x,y,m,*] = (100-get)/gsigma &$
;    endfor &$
;  endfor &$
;endfor


;cmask = cgrid
;cmask(where(cgrid ge 1, complement = other))=1
;cmask(other)= !values.f_nan
;get the RPAW, NPAW, SM01, SM02, and SMMW for each country (averged over? J,A,S?)
;rain  then NDVI
;******************************************** 
;;**************original/raw/rescaled data for each country********

rile = ;where is rpaw in all this? already loaded? yes, because it doesn't need to be scaled.
lfile = file_search('/jabber/chg-mcnally/SM01_scaled4WRSI.img');
mfile = file_search('/jabber/chg-mcnally/NWET_scaled4WRSI.img');
; no, just plain microwave....

nx = 720
ny = 350
nz = 432

nwet = fltarr(nx,ny,36,12); 2001-2011 (do they all look like this? 
openr,1,mfile
readu,1,nwet
close,1

sm01S = fltarr(nx,ny,36,11); 2001-2011 (do they all look like this? 
openr,1,lfile
readu,1,sm01S
close,1


;******

;why was i looking at raw/scaled values??
;NigerSM = fltarr(4,12,12)*!values.f_nan
;SenegalSM = fltarr(4,12,12)*!values.f_nan
;MaliSM = fltarr(4,12,12)*!values.f_nan
;BurkinaSM = fltarr(4,12,12)*!values.f_nan
;ChadSM = fltarr(4,12,12)*!values.f_nan
;
;for m = 0,n_elements(sm01cube[0,0,*,0])-1 do begin &$
;  for y = 0,n_elements(sm01cube[0,0,0,0:10])-1 do begin &$
;     ;country original data - not anomalies....no, use the geoWRSI re-scaled data. what are thoes files??
;    rpaw = rpawcube[*,*,m,y] &$
;    smMW = nwet[*,*,m,y] &$
;    sm01 = sm01S[*,*,m,y] &$
;    
;    NigerSM[*,m,y] =  [mean(rpaw(niger),/nan),mean(smMW(niger), /nan),mean(sm01(niger), /nan)] &$
;    SenegalSM[*,m,y] =  [mean(rpaw(senegal), /nan),mean(smMW(senegal), /nan),mean(sm01(senegal), /nan)] &$
;    MaliSM[*,m,y] =  [mean(rpaw(mali), /nan),mean(smMW(mali), /nan),mean(sm01(mali), /nan)] &$
;    BurkinaSM[*,m,y] =  [mean(rpaw(burkina), /nan),mean(smMW(burkina), /nan),mean(sm01(burkina), /nan)] &$
;    ChadSM[*,m,y] =  [mean(rpaw(chad), /nan),mean(smMW(chad), /nan),mean(sm01(chad), /nan)] &$
;  endfor &$    
;endfor;i


;scatter plots vs SM01 -- is that what I want? For google I used microwave....
month = ['Jun','Jul','Aug','Spt']
for m=5,8 do begin &$;i could look june-sept...
  p1 = plot(MaliSM[0,m,*],MaliSM[1,m,*],'bo',sym_size=2, name = 'R-SM',/SYM_FILLED) &$
  p3 = plot(MaliSM[1,m,*],MaliSM[1,m,*],'o',/overplot, sym_size=2, name='N-SM') &$
  p4 = plot(MaliSM[5,m,*],MaliSM[1,m,*],'go',/overplot, sym_size=2, name='N-MW',/SYM_FILLED) &$
  p2 = plot(MaliSM[3,m,*],MaliSM[1,m,*],'mo',/overplot, sym_size=2,/SYM_FILLED,$
          yminor=0, xminor=0,font_name='times', ytitle='SM_01',$ 
          xtitle = 'other estimates', name='ECV_SM') &$
  !null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=14) &$

  mn = -2 &$
  mx = 2 &$
  p2.xrange=[mn,mx] &$
  p2.yrange=[mn,mx] &$
  p1.title = month[m-5]+' standardized anomalies SM Mali' &$
  p1.font_size = 20 &$
  p3=plot([0,0],[mn,mx],/overplot) &$
  p3=plot([mn,mx],[0,0],/overplot) &$
endfor 
;***************************************************************************************
;***************************************************************************************
for m=5,8 do begin &$
p1 = plot(NigerSM[0,m,*],NigerSM[1,m,*],'bo',sym_size=2, name = 'R-SM',/SYM_FILLED) &$
p3 = plot(NigerSM[1,m,*],NigerSM[1,m,*],'o',/overplot, sym_size=2, name='N-SM') &$
p4 = plot(NigerSM[5,m,*],NigerSM[1,m,*],'go',/overplot, sym_size=2, name='N-MW', /SYM_FILLED) &$
p2 = plot(NigerSM[2,m,*],NigerSM[1,m,*],'mo',/overplot, sym_size=2,/SYM_FILLED,$
          yminor=0, xminor=0,font_name='times', ytitle='Noah SM01',$ 
          xtitle = 'other estimates', name='ECV_SM') &$
!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=14) &$

mn = -2 &$
mx = 2 &$
p2.xrange=[mn,mx] &$
p2.yrange=[mn,mx] &$
p1.title = month[m-5]+' standardized anomalies SM Niger' &$
p1.font_size = 20 &$
p3=plot([0,0],[mn,mx],/overplot) &$
p3=plot([mn,mx],[0,0],/overplot) &$
endfor
;***************************************************************************************
;***************************************************************************************
for m=5,8 do begin &$
p1 = plot(SenegalSM[0,m,*],SenegalSM[3,m,*],'bo',sym_size=2, name = 'R-SM',/SYM_FILLED) &$
p3 = plot(SenegalSM[1,m,*],SenegalSM[3,m,*],'o',/overplot, sym_size=2, name='N-SM') &$
p4 = plot(SenegalSM[5,m,*],SenegalSM[3,m,*],'go',/overplot, sym_size=2, name='N-MW', /SYM_FILLED) &$
p2 = plot(SenegalSM[2,m,*],SenegalSM[3,m,*],'mo',/overplot, sym_size=2,/SYM_FILLED,$
          yminor=0, xminor=0,font_name='times', ytitle='Noah SM01',$ 
          xtitle = 'other estimates', name='ECV_SM') &$
!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=14) &$

mn = -2 &$
mx = 2 &$
p2.xrange=[mn,mx] &$
p2.yrange=[mn,mx] &$
p1.title = month[m-5]+' standardized anomalies SM Senegal' &$
p1.font_size = 20 &$
p3=plot([0,0],[mn,mx],/overplot) &$
p3=plot([mn,mx],[0,0],/overplot) &$
endfor
;***************************************************************************************
;***************************************************************************************
for m=5,8 do begin &$
  p1 = plot(BurkinaSM[0,m,*],BurkinaSM[3,m,*],'bo',sym_size=2, name = 'R-SM',/SYM_FILLED) &$
  p3 = plot(BurkinaSM[1,m,*],BurkinaSM[3,m,*],'o',/overplot, sym_size=2, name='N-SM') &$
  p4 = plot(BurkinaSM[5,m,*],BurkinaSM[3,m,*],'go',/overplot, sym_size=2, name='N-MW',/SYM_FILLED) &$
  p2 = plot(BurkinaSM[2,m,*],BurkinaSM[3,m,*],'mo',/overplot, sym_size=2,/SYM_FILLED,$
          yminor=0, xminor=0,font_name='times', ytitle='Noah SM01',$ 
          xtitle = 'other estimates', name='ECV_SM') &$
  !null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=14) &$

  mn = -2 &$
  mx = 2 &$
  p2.xrange=[mn,mx] &$
  p2.yrange=[mn,mx] &$
  p1.title = month[m-5]+' standardized anomalies SM Burkina' &$
  p1.font_size = 20 &$
  p3=plot([0,0],[mn,mx],/overplot) &$
  p3=plot([mn,mx],[0,0],/overplot) &$
endfor
;***************************************************************************************
;***************************************************************************************
for m=5,8 do begin &$
  p1 = plot(ChadSM[0,m,*],ChadSM[3,m,*],'bo',sym_size=2, name = 'R-SM',/SYM_FILLED) &$
  p3 = plot(ChadSM[1,m,*],ChadSM[3,m,*],'o',/overplot, sym_size=2, name='N-SM') &$
  p3 = plot(ChadSM[5,m,*],ChadSM[3,m,*],'go',/overplot, sym_size=2, name='N-MW', /SYM_FILLED) &$
  p2 = plot(ChadSM[2,m,*],ChadSM[3,m,*],'mo',/overplot, sym_size=2,/SYM_FILLED,$
          yminor=0, xminor=0,font_name='times', ytitle='Noah_SM01',$ 
          xtitle = 'other estimates', name='ECV_SM') &$
  !null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=14) &$

  mn = -2 &$
  mx = 2 &$
  p2.xrange=[mn,mx] &$
  p2.yrange=[mn,mx] &$
  p1.title = month[m-5]+' standardized anomalies SM Chad' &$
  p1.font_size = 20 &$
  p3=plot([0,0],[mn,mx],/overplot) &$
  p3=plot([mn,mx],[0,0],/overplot) &$
endfor

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



pro paper3_plotsv1

;*****rainfall compare***************
ifile = file_search('/jabber/chg-mcnally/mae_*_sta.img')

nx = 720
ny = 350
nz = 12
meagrid = fltarr(nx,ny,nz)
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
 ;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5) / 0.10)


;Belefoungou-Top 9.79506     1.71450  
bxind = FLOOR((1.7145 + 20.) / 0.10)
byind = FLOOR((9.79506 + 5) / 0.10)

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
;****************************************************
;******soil moisture compare*************************
ifile1 = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/monthly/Sm01*.img')
ifile2 = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/monthly/Sm02*.img')
ifile3 = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/monthly/Sm03*.img')
ifile4 = file_search('/jower/sandbox/mcnally/ECV_soil_moisture/monthly/sahel/*.img')

ifile5 = file_search('/jabber/chg-mcnally/npaw_monthly.img')
ifile6 = file_search('/jabber/chg-mcnally/rpaw_monthly.img')

wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

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
;***compare with monthly in-situ**
bfile = file_search('/jabber/chg-mcnally/belefoungou.20.40.60.SM_monthly2006_2009.csv')
wfile = file_search('/jabber/chg-mcnally/wanakma.14.47.71.SM_monthly2006_2011.csv')
afile = file_search('/jabber/chg-mcnally/agoufou.103.203.304.106.206.SM_monthly2005_2008.csv')

bb = read_csv(bfile) & help, bb
wk = read_csv(wfile)
ag = read_csv(afile)

;20, 40, 60...
bbmean = mean(reform(transpose([[float(bb.field1)],[float(bb.field2)],[float(bb.field3)]]),3,12,4), dimension=3,/nan)
wkmean = mean(reform(transpose([[float(wk.field1)],[float(wk.field2)],[float(wk.field3)]]),3,12,6), dimension=3,/nan)
agmean = mean(reform(transpose([[float(ag.field1)],[float(ag.field2)],[float(ag.field3)],[float(ag.field4)],$
              [float(ag.field5)]]),5,12,4), dimension=3,/nan)

;************************************
sm01cube = reform(buffer1,720,250,12,11)
sm02cube = reform(buffer2,720,250,12,11)
sm03cube = reform(buffer3,720,250,12,11)
smMWcube = reform(buffer4,nx,ny,12,10)

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

;get the anomalies for the whole sahel for a map comparison for each month:
Lstdanom01=fltarr(nx,250,12,11);x,y,month,year
Lstdanom02=fltarr(nx,250,12,11);x,y,month,year
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    for m=0,11 do begin &$
      w01 = sm01cube[x,y,m,*] &$
      w02 = sm02cube[x,y,m,*] &$
      test = where(finite(w01), count) &$
      test2 = where(finite(w02), count2) &$      
      if count le 1 then continue &$
      if count2 le 1 then continue &$
      Lstdanom01[x,y,m,*] = (w01-mean(w01,/nan))/stdev(w01(where(finite(w01)))) &$
      Lstdanom02[x,y,m,*] = (w02-mean(w02,/nan))/stdev(w02(where(finite(w02)))) &$
    endfor &$
  endfor &$
endfor


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

;get the RPAW, NPAW, SM01, SM02, and SMMW for each country (averged over? J,A,S?)
;rain  then NDVI
;******************************************** 
;these need to be standardized

NigerSM = fltarr(5,12,10)
SenegalSM = fltarr(5,12,10)
MaliSM = fltarr(5,12,10)
BurkinaSM = fltarr(5,12,10)
ChadSM = fltarr(5,12,10)

for m = 0,n_elements(smMWcube[0,0,*,0])-1 do begin &$
  for y = 0,n_elements(smMWcube[0,0,0,*])-1 do begin &$
    rpaw = rstdanom[*,*,m,y] &$
    npaw = nstdanom[*,*,m,y] &$
    smMW = mstdanom[*,*,m,y] &$
    sm01 = Lstdanom01[*,*,m,y] &$
    sm02 = Lstdanom02[*,*,m,y] &$
    
    NigerSM[*,m,y] =  [mean(rpaw(niger),/nan),mean(npaw(niger),/nan),mean(smMW(niger), /nan),mean(sm01(niger), /nan),mean(sm02(niger), /nan)] &$
    SenegalSM[*,m,y] =  [mean(rpaw(senegal), /nan),mean(npaw(senegal), /nan),mean(smMW(senegal), /nan),mean(sm01(senegal), /nan),mean(sm02(senegal), /nan)] &$
    MaliSM[*,m,y] =  [mean(rpaw(mali), /nan),mean(npaw(mali), /nan),mean(smMW(mali), /nan),mean(sm01(mali), /nan),mean(sm02(mali), /nan)] &$
    BurkinaSM[*,m,y] =  [mean(rpaw(burkina), /nan),mean(npaw(burkina), /nan),mean(smMW(burkina), /nan),mean(sm01(burkina), /nan),mean(sm02(burkina), /nan)] &$
    ChadSM[*,m,y] =  [mean(rpaw(chad), /nan),mean(npaw(chad), /nan),mean(smMW(chad), /nan),mean(sm01(chad), /nan),mean(sm02(chad), /nan)] &$
  endfor &$    
endfor;i

;***************************************************************************************
month = ['Jun','Jul','Aug','Spt']
for m=5,8 do begin &$;i could look june-sept...
  p1 = plot(MaliSM[0,m,*],MaliSM[3,m,*],'bo',sym_size=2, name = 'R-SM',/SYM_FILLED) &$
  p3 = plot(MaliSM[1,m,*],MaliSM[3,m,*],'o',/overplot, sym_size=2, name='N-SM') &$
  p2 = plot(MaliSM[2,m,*],MaliSM[3,m,*],'mo',/overplot, sym_size=2,/SYM_FILLED,$
          yminor=0, xminor=0,font_name='times', ytitle='SM_01',$ 
          xtitle = 'other estimates', name='ECV_SM') &$
  !null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) &$

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
p1 = plot(NigerSM[0,m,*],NigerSM[3,m,*],'bo',sym_size=2, name = 'R-SM',/SYM_FILLED) &$
p3 = plot(NigerSM[1,m,*],NigerSM[3,m,*],'o',/overplot, sym_size=2, name='N-SM') &$
p2 = plot(NigerSM[2,m,*],NigerSM[3,m,*],'mo',/overplot, sym_size=2,/SYM_FILLED,$
          yminor=0, xminor=0,font_name='times', ytitle='Noah SM01',$ 
          xtitle = 'other estimates', name='ECV_SM') &$
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) &$

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
p2 = plot(SenegalSM[2,m,*],SenegalSM[3,m,*],'mo',/overplot, sym_size=2,/SYM_FILLED,$
          yminor=0, xminor=0,font_name='times', ytitle='Noah SM01',$ 
          xtitle = 'other estimates', name='ECV_SM') &$
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) &$

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
  p2 = plot(BurkinaSM[2,m,*],BurkinaSM[3,m,*],'mo',/overplot, sym_size=2,/SYM_FILLED,$
          yminor=0, xminor=0,font_name='times', ytitle='Noah SM01',$ 
          xtitle = 'other estimates', name='ECV_SM') &$
  !null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) &$

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
  p2 = plot(ChadSM[2,m,*],ChadSM[3,m,*],'mo',/overplot, sym_size=2,/SYM_FILLED,$
          yminor=0, xminor=0,font_name='times', ytitle='Noah_SM01',$ 
          xtitle = 'other estimates', name='ECV_SM') &$
  !null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) &$

  mn = -2 &$
  mx = 2 &$
  p2.xrange=[mn,mx] &$
  p2.yrange=[mn,mx] &$
  p1.title = month[m-5]+' standardized anomalies SM Chad' &$
  p1.font_size = 20 &$
  p3=plot([0,0],[mn,mx],/overplot) &$
  p3=plot([mn,mx],[0,0],/overplot) &$
endfor
;***************************************************************************************

nbars = 5
colors = ['blue', 'green', 'cyan', 'grey', 'maroon']
name = ['RPAW', 'NPAW', 'MW', 'Noah01', 'Noah02']

  index = 0
  xticks = ['July', 'Aug', 'Sept']
  xtickvalues = [0,1,2]
for p=0,n_elements(NigerSM[*,0,0])-1 do begin &$
  ;for y =1,4 do begin &$
   y=4 &$
    b2 = barplot(NigerSM[p,6:8,y], nbars=nbars, fill_color=colors[p],index=p, name = name[p], /overplot) &$
   
   b2.yrange=[-2,2] &$
   b2.xminor = 0 &$
   b2.yminor = 0 &$
   b2.xtickvalues = xtickvalues &$
   b2.xtickname = xticks &$
   b2.font_name='times' &$
   b2.font_size=16 &$
   b2.title = 'Niger soil moisture standardized anomalies '+strcompress('200'+string(y+1), /remove_all) &$
   ax = b2.axes &$
   ax[2].HIDE = 1  &$
   ax[3].HIDE = 1  &$
   !null = legend(target=[b1], position=[0.2,0.3], font_size=14) &$
   
  ;endfor &$
endfor

;make correlation map for SM02 and RPAW -- these should be anomalies....
cormap = fltarr(nx,250,12,2)
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    for m = 0,11 do begin &$
      good = where(finite(rpawcube[x,y,m,0:10]), count) &$
      if count le 1 then continue &$
      cormap[x,y,m,*] = r_correlate(rpawcube[x,y,m,good], sm02cube[x,y,m,good]) &$
    endfor &$
  endfor   &$
endfor  

ofile = '/jabber/chg-mcnally/cormap_sm02_rpawcube.img'
;openw,1,ofile
;writeu,1,cormap
;close,1  
;make a difference maps of the Noah and R-PAW
keep = where(nstdanom[*,*,8,y] ne 0,complement=chuk)
mask = nstdanom[*,*,8,y]
mask(keep)=1
mask(chuk)=!values.f_nan
y=1
diff = (lstdanom01[*,*,8,y]-mstdanom[*,*,8,y])*mask & nve, diff
diff = (lstdanom02[*,*,8,y]-mstdanom[*,*,8,y])*mask & nve, diff
diff = (rstdanom[*,*,8,y]-mstdanom[*,*,8,y])*mask & nve, diff
diff = (nstdanom[*,*,8,y]-mstdanom[*,*,8,y])*mask & nve, diff

p1 = image(diff, image_dimensions=[72.0,25.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), title = 'RPAW - MW anomalies Aug'+strcompress('200'+string(y+1),/remove_all), min_value=-4,max_value=4)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, -20, 18, 52], /overplot)
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])    

;*********************************************************
;*******N-AET and R-AET***********************************
rfile = file_search('/jabber/chg-mcnally/rAET_monthly.img')
nfile = file_search('/jabber/chg-mcnally/nAET_monthly.img')
efile = file_search('/jabber/chg-mcnally/ETA/sahel/*.img')
lfile = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/monthly/Evap*.img')

nx = 720
ny = 350
nyy = 250

;for the ETA data...
ingride = fltarr(nx,ny,n_elements(efile))
buffere = bytarr(nx,ny)

;and the LIS Evap
ingridl = fltarr(720,250,n_elements(lfile))
bufferl = fltarr(720,250)

;only compare from 2001-2010
for i=0,n_elements(lfile)-1 do begin &$
   openr,1,efile[i] &$
   readu,1,buffere &$
   close,1 &$
   ingride[*,*,i] = buffere &$
   
   openr,1,lfile[i] &$
   readu,1,bufferl &$
   close,1 &$
   ingridl[*,*,i] = bufferl &$
endfor
etancube = reform(ingride,nx,ny,12,12)
liscube = reform(ingridl,nx,250,12,11)

naetcube = fltarr(nx,ny,12,12)*!values.f_nan
raetcube = fltarr(nx,ny,12,12)*!values.f_nan

openr,1,nfile
readu,1,naetcube
close,1

openr,1,rfile
readu,1,raetcube
close,1

ranom = fltarr(720,350,12,12)*!values.f_nan

lavg = mean(liscube,dimension=4, /nan)
lanom = fltarr(720,250,12,11)*!values.f_nan

;these should be standardized anomalies...should i do this with cube
nanom = fltarr(720,250,12,12)*!values.f_nan
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    for m=0,n_elements(naetcube[0,0,*,0])-1 do begin &$
      net = naetcube[x,y,m,*] &$
      test = where(finite(net),count) &$
      if count le 1 then continue &$
      nsigma = stdev(net(where(finite(net)))) &$
      nanom[x,y,m,*] = (net-mean(net,/nan))/nsigma &$
    endfor &$
  endfor &$
endfor

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

ganom = fltarr(720,250,12,12)*!values.f_nan
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    for m=0,n_elements(etancube[0,0,*,0])-1 do begin &$
      get = etancube[x,y,m,*] &$
      test = where(finite(get),count) &$
      if count le 1 then continue &$
      gsigma = stdev(get(where(finite(get)))) &$
      ganom[x,y,m,*] = (100-get)/gsigma &$
    endfor &$
  endfor &$
endfor

;oookkay...average over country.....

NigerET = fltarr(4,12,11)
SenegalET = fltarr(4,12,11)
MaliET = fltarr(4,12,11)
BurkinaET = fltarr(4,12,11)
ChadET = fltarr(4,12,11)
;was this the right thing to do?
etancube(where(etancube eq 0))=!values.f_nan
etancube(where(etancube eq 255))=!values.f_nan


for m = 0,n_elements(lanom[0,0,*,0])-1 do begin &$
  for y = 0,n_elements(lanom[0,0,0,*])-1 do begin &$
    ret = ranom[*,*,m,y] &$
    net = nanom[*,*,m,y] &$
    let = lanom[*,*,m,y] &$
    get = ganom[*,*,m,y] &$
    NigerET[*,m,y] =  [mean(ret(niger),/nan),mean(net(niger),/nan),mean(let(niger), /nan), mean(get(niger),/nan)] &$
    SenegalET[*,m,y] =  [mean(ret(senegal), /nan),mean(net(senegal), /nan),mean(let(senegal),/nan),mean(get(senegal),/nan)] &$
    MaliET[*,m,y] =  [mean(ret(mali), /nan),mean(net(mali), /nan),mean(let(mali), /nan),mean(get(mali), /nan)] &$
    BurkinaET[*,m,y] =  [mean(ret(burkina), /nan),mean(net(burkina), /nan),mean(let(burkina), /nan),mean(get(burkina), /nan)] &$
    ChadET[*,m,y] =  [mean(ret(chad), /nan),mean(net(chad), /nan),mean(let(chad), /nan),mean(get(chad), /nan)] &$
  endfor &$    
endfor;i

mask = fltarr(720,250)
good = where(finite(ranom[*,*,7,2]), complement=null)
mask(good)=1
mask(null)=!values.f_nan

;***********make the 4 quadrant scatter plot for each country******************
m=6
p1 = plot(NigerET[1,m,*],NigerET[0,m,*],'o',sym_size=2, name = 'N-ET')
p3 = plot(NigerET[3,m,*],NigerET[0,m,*],'bo',/overplot, sym_size=2,/SYM_FILLED, name='ETa')
p2 = plot(NigerET[2,m,*],NigerET[0,m,*],'go',/overplot, sym_size=2,/SYM_FILLED,$
          yminor=0, xminor=0,font_name='times', ytitle='R-ET',$ 
          xtitle = 'other estimates', name='Noah-ET')
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14)

p2.xrange=[-1.5,1.5]
p2.yrange=[-1.5,1.5]
p1.title = 'July standardized anomalies ET'
p1.font_size = 20
p3=plot([0,0],[-1.5,1.5],/overplot)
p3=plot([-1.5,1.5],[0,0],/overplot)
;***************************************************************************************
m=7
p1 = plot(SenegalET[1,m,*],SenegalET[0,m,*],'o',sym_size=2, name = 'N-ET')
p3 = plot(SenegalET[3,m,*],SenegalET[0,m,*],'bo',/overplot, sym_size=2,/SYM_FILLED, name='ETa')
p2 = plot(SenegalET[2,m,*],SenegalET[0,m,*],'go',/overplot, sym_size=2,/SYM_FILLED,$
          yminor=0, xminor=0,font_name='times', ytitle='R-ET',$ 
          xtitle = 'other estimates', name='Noah-ET')
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14)

p2.xrange=[-2,2]
p2.yrange=[-2,2]
p1.title = 'Sept standardized anomalies ET Senegal'
p1.font_size = 20
p3=plot([0,0],[-2,2],/overplot)
p3=plot([-2,2],[0,0],/overplot)
;***************************************************************************************
;***************************************************************************************
m=5
p1 = plot(MaliET[1,m,*],MaliET[0,m,*],'o',sym_size=2, name = 'N-ET')
p3 = plot(MaliET[3,m,*],MaliET[0,m,*],'bo',/overplot, sym_size=2,/SYM_FILLED, name='ETa')
p2 = plot(MaliET[2,m,*],MaliET[0,m,*],'go',/overplot, sym_size=2,/SYM_FILLED,$
          yminor=0, xminor=0,font_name='times', ytitle='R-ET',$ 
          xtitle = 'other estimates', name='Noah-ET')
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14)

mn = -1.5
mx = 1.5
p2.xrange=[mn,mx]
p2.yrange=[mn,mx]
p1.title = 'June standardized anomalies ET Mali'
p1.font_size = 20
p3=plot([0,0],[mn,mx],/overplot)
p3=plot([mn,mx],[0,0],/overplot)
;***************************************************************************************
;***************************************************************************************
m=8
p1 = plot(BurkinaET[1,m,*],BurkinaET[0,m,*],'o',sym_size=2, name = 'N-ET')
p3 = plot(BurkinaET[3,m,*],BurkinaET[0,m,*],'bo',/overplot, sym_size=2,/SYM_FILLED, name='ETa')
p2 = plot(BurkinaET[2,m,*],BurkinaET[0,m,*],'go',/overplot, sym_size=2,/SYM_FILLED,$
          yminor=0, xminor=0,font_name='times', ytitle='R-ET',$ 
          xtitle = 'other estimates', name='Noah-ET')
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14)

mn = -1.5
mx = 1.5
p2.xrange=[mn,mx]
p2.yrange=[mn,mx]
p1.title = 'Sept standardized anomalies ET Burkina'
p1.font_size = 20
p3=plot([0,0],[mn,mx],/overplot)
p3=plot([mn,mx],[0,0],/overplot)
;***************************************************************************************
;***************************************************************************************
m=8
p1 = plot(ChadET[1,m,*],chadET[0,m,*],'o',sym_size=2, name = 'N-ET')
p3 = plot(chadET[3,m,*],chadET[0,m,*],'bo',/overplot, sym_size=2,/SYM_FILLED, name='ETa')
p2 = plot(chadET[2,m,*],chadET[0,m,*],'go',/overplot, sym_size=2,/SYM_FILLED,$
          yminor=0, xminor=0,font_name='times', ytitle='R-ET',$ 
          xtitle = 'other estimates', name='Noah-ET')
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14)

mn = -1.5
mx = 1.5
p2.xrange=[mn,mx]
p2.yrange=[mn,mx]
p1.title = 'Sept standardized anomalies ET Chad'
p1.font_size = 20
p3=plot([0,0],[mn,mx],/overplot)
p3=plot([mn,mx],[0,0],/overplot)
;***************************************************************************************
nbars = 5
colors = ['blue', 'green', 'cyan', 'grey', 'maroon']
name = ['R-ET', 'N-ET', 'LIS-ET','EROS-ETA']

  index = 0
  xticks = ['July', 'Aug', 'Sept']
  xtickvalues = [0,1,2]

for y =1,4 do begin &$
  for p=0,n_elements(NigerET[*,0,0])-1 do begin &$
   ;y=1 &$
    b2 = barplot(ChadET[p,6:8,y], nbars=nbars, fill_color=colors[p],index=p, name = name[p], /overplot) &$
   
   b2.yrange=[-2,2] &$
   b2.xminor = 0 &$
   b2.yminor = 0 &$
   b2.xtickvalues = xtickvalues &$
   b2.xtickname = xticks &$
   b2.font_name='times' &$
   b2.font_size=16 &$
   b2.title = 'Chad ET standardized anomalies '+strcompress('200'+string(y+1), /remove_all) &$
   ax = b2.axes &$
   ax[2].HIDE = 1  &$
   ax[3].HIDE = 1  &$
   if p lt 3 then continue &$
   !null = legend(target=[b1], position=[0.2,0.3], font_size=14) &$
  endfor &$
  w=window() &$
endfor
;*******************************
ncolors=256
p1 = image(ganom[*,*,7,4]*mask, image_dimensions=[72.0,25.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), min_value=-2, max_value=2)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
p1.title='ETa 2005 Aug'
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



;compare monthly NOAH anomalies and ETa
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

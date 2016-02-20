pro waterbal4paper3

;calculate ET as the residual between P and S...for the whole season. this doens't tell me if the anomalies are happening
;at the right time but at least it is an initial assessment of seasonal quality, and should indicate if the whole season 
;was a drought. Do for whole sahel and then compute ET anomalies and compare with Noah, Modis and RFE, how should the models balance themselves?
;
;*****mask*****
rfile = file_search('/jabber/chg-mcnally/rAET_monthly.img')
raetcube = fltarr(720,350,12,12)*!values.f_nan
openr,1,rfile
readu,1,raetcube
close,1

rmask=mean(raetcube[*,*,*,0], dimension=3,/nan)
good = where(finite(rmask), complement=other)
rmask(other)=!values.f_nan
rmask(good)=1
rmask = rmask[*,0:249]
;***********************
;*******************station 'truth'*****************************     
;;*******try these Niamey airport station dekads (2002-2012?), how do they compare to ubREF estimates?***************
sfile = file_search('/jabber/chg-mcnally/NiameyAPPAW36_2002_2012_SOS.15.16.08etc_LGP10_WHC125_PET.csv')
efile = file_search('/jabber/chg-mcnally/NiameyAP_AETc36_2002_2012_SOS.15.16.08etc_LGP10_WHC125_PET.csv')    
rfile = file_search('/jabber/chg-mcnally/AMMARain/GTS.Niamey_Rainstation_dekad.csv')

rain = read_csv(rfile)
NArain = reform(float(rain.field1),36,11)
paw = read_csv(sfile)
NApaw = reform(float(paw.field1),36,11) 
aet = read_csv(efile)
NAaet = reform(float(aet.field1),36,11)

;this makes it look like the WRSI is not amenable to water balancing :)
NAetR02 = total(narain,1,/nan)-total(NAaet,1,/nan)
;NAet = total(naAET,1,/nan) & print, naET

;******Noah's water balance (there should be a little error due to runoff...5-10%?
rfile = file_search('/jabber/LIS/Data/ubRFE04.19.2013/monthly/sahel/all_products.bin.*.img')
sfile = file_search('/jower/chg-mcnally/fromKnot/EXP01/monthly/Sm01*.img');132
efile = file_search('/jower/chg-mcnally/fromKnot/EXP01/monthly/Evap*.img');132

nx = 720
ny = 250

ringrid = fltarr(nx,350)
singrid = fltarr(nx,ny)
eingrid = fltarr(nx,ny)

rain = fltarr(nx,350,n_elements(sfile))*!values.f_nan
soil = fltarr(nx,ny,n_elements(sfile))*!values.f_nan
evap = fltarr(nx,ny,n_elements(sfile))*!values.f_nan


for i = 0,n_elements(sfile)-1 do begin &$
  openr,1,rfile[i] &$
  readu,1,ringrid &$
  close,1 &$
  rain[*,*,i] = ringrid &$
  
  openr,1,sfile[i] &$
  readu,1,singrid &$
  close,1 &$
  soil[*,*,i] = singrid &$
  
  openr,1,efile[i] &$
  readu,1,eingrid &$
  close,1 &$
  evap[*,*,i] = eingrid &$
endfor

rain2 = rain[*,0:249,*]

rcube = reform(rain2,nx,ny,12,11)  
scube = reform(soil,nx,ny,12,11)  
ecube = reform(evap,nx,ny,12,11)*86400 

;total up may-october why is this so hard? I hate units. 
;Did I take monthly totals or averages for Noah postprocessing?
rsummer = total(rcube[*,*,4:9,1:10],3, /nan)
ssummer = total(scube[*,*,4:9,1:10],3, /nan)
esummer = total(ecube[*,*,4:9,1:10],3, /nan)

NoahETR02 = rsummer-ssummer
;************check WRSI PAW and ET*******************
 ;****can this balance given time period? And that is cacculating trasnpiration?
s2file = file_search('/jabber/chg-mcnally/rpaw_monthly.img')
e2file = file_search('/jabber/chg-mcnally/rAET_monthly.img')

rpawcube = fltarr(nx,350,12,12)*!values.f_nan
openr,1,s2file
readu,1,rpawcube
close,1

raetcube = fltarr(nx,350,12,12)*!values.f_nan
openr,1,e2file
readu,1,raetcube
close,1

r2summer = total(rcube[*,*,6:9,1:10],3, /nan)
s2summer = total(rpawcube[*,*,6:9,1:10],3, /nan)
e2summer = total(raetcube[*,*,6:9,1:10],3, /nan)

WrsiETR02 = r2summer-s2summer

;***************caculate ET residual with MW***************
mfile = file_search('/jower/chg-mcnally/ECV_soil_moisture/monthly/sahel/*.img');120
mwgrid = fltarr(nx,350,n_elements(mfile))
buffer = fltarr(nx,350)
for i = 0,n_elements(mfile)-1 do begin &$
  openr,1,mfile[i] &$
  readu,1,buffer &$
  close,1  &$
  mwgrid[*,*,i] = buffer &$
endfor

mcube = reform(mwgrid,nx,350,12,10)   
mcube = mcube[*,0:249,*,*]/100
s3summer = total(mcube[*,*,4:9,1:9],3, /nan)

rain3 = rain[*,0:249,0:119]
rcube3 = reform(rain3,nx,250,12,10)  
r3summer = total(rcube3[*,*,4:9,1:9],3, /nan)

mwETR02 = r3summer-s3summer

;**************NWET***************************************
ifile = file_search('/jabber/chg-mcnally/sahel_NSM_microwave_monthly_12yrs.img');this is NWET?
nwetcube = fltarr(nx,ny,12,12)*!values.f_nan

openr,1,ifile
readu,1,nwetcube
close,1

s5summer = total(nwetcube[*,*,4:9,1:11],3, /nan)/100
NWETetR02 = rsummer-s5summer

;**********************************************************
;***************how does MODIS ET compare to Noah and the residuals************************************
ifile = file_search('/jower/sandbox/mcnally/MOD16/Africa/sahel/*{2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012}*.tif');156 2000-2012  
ingridm = intarr(720,350, n_elements(ifile))
for i = 0, n_elements(ifile)-1 do begin &$   
   bufferm = read_tiff(ifile[i]) &$
   bufferm = reverse(bufferm,2) &$
   ingridm[*,*,i] = bufferm &$
   endfor
ingridm = float(ingridm)
ingridm(where(ingridm eq 32767, count)) = !values.f_nan & print, count
ingridm = ingridm[*,0:249,0:131]
e4cube = reform(ingridm,nx,ny,12,11)/10
modisETsummer = total(e4cube[*,*,4:9,1:10],3, /nan)

modisSOILR02 = rsummer-modisETsummer
modisETR02 = rsummer-modisSOILR02     
;*********how do correlations change over wetness gradient*********************
;Niamey,Airport 13.483334,2.1666667
nxind = FLOOR((2.16667 + 20.) / 0.10)
nyind = FLOOR((13.4833 + 5) / 0.10)

xind=nxind
yind=nyind
;************
;maybe the best thing to compare is the station and RFE WRSI residuals
print, r_correlate(WRSIetR02[xind, yind, *],NWETetR02[xind, yind, 0:9])
print, r_correlate(WRSIetR02[xind, yind, 0:8],MWetR02[xind, yind, *])
print, r_correlate(WRSIetR02[xind, yind, *],NOAHetR02[xind, yind, *])
print, r_correlate(WRSIetR02[xind, yind, *],NAetR02[0:9])
print, r_correlate(WRSIetR02[xind, yind, *],modisETsummer[xind,yind,0:9])

;*******
print, r_correlate(NAetR02[0:9],NWETetR02[xind, yind, *]) 
print, r_correlate(NAetR02 [0:8],MWetR02[xind, yind, *])
print, r_correlate(NAetR02[0:9],NOAHetR02[xind, yind, *])
print, r_correlate(NAetR02[0:9],modisETsummer[xind, yind, *])

;******************************************
; anomalies, these might unfairly penalize products with larger std deviation? modis shows low error despite poor correlation
; maybe standardize too...
;make them all 2002-2010!!!!
NAetR02 = NAetR02[0:8] 
nWRSIetR02 = WRSIetR02[xind,yind,0:8]
nNWETetR02 = NWETetR02[xind,yind,0:8]
nMWetR02 = MWetR02[xind,yind,*] ; shortest time series...
nNOAHetR02 = NOAHetR02[xind,yind,0:8]
nmodisETsummer = modisETsummer[xind,yind,0:8]


;MODEL EXPERIMENTS
aNAetR02 = (NAetR02-mean(NAetR02,/nan))/stdev(NAetR02) & nve, aNAetR02 ;11 yrs from 2002
aWRSIetR02 = (nWRSIetR02 - mean(nWRSIetR02,/nan))/stdev(nwrsietr02) & nve, aWRSIetR02 ;10 years from 2002
;PRODUCTS
aNWETetR02 = (nNWETetR02-mean(nNWETetR02,/nan)) /stdev(nNWETetR02) & nve, aNWETetR02 ; 10 years from 2002
aMWetR02 = (nMWetR02-mean(nMWetR02,/nan))       /stdev(nmwetr02) & nve, aMWetR02 ;9 years from 2002
aNOAHetR02 = (nNOAHetR02-mean(nNOAHetR02,/nan)) /stdev(nnoahetr02) & nve, aNOAHetR02;10 years from 2002
amodisETsummer = (nmodisETsummer-mean(nmodisETsummer,/nan)) /stdev(nmodisETsummer) & nve, amodisETsummer; 10 yrs from 2002

;calculate root mean sq errors on the anomalies? .
Enwet = mean(sqrt((aNAetR02-aNWETetR02)^2))      & print, Enwet
Emw   = mean(sqrt((aNAetR02-  aMWetR02)^2))          & print, Emw
Enoah = mean(sqrt((aNAetR02-aNoahetR02)^2))      & print, Enoah
Emodis = mean(sqrt((aNAetR02-aMODISetsummer)^2)) & print, Emodis

;find the total 'error'
S = (enwet + emw + enoah + emodis) & print, S

Wnwet = enwet/s & print, Wnwet
Wmw = emw/s & print, Wmw
Wnoah = Enoah/s & print, Wnoah
Wmodis = Emodis/s & print, Wmodis

print, Wmodis+wnoah+wmw+wnwet

;why do i get the same answers with the mean and the total?
wa=  [ Wnwet*aNWETetR02+Wmw*aMWetR02+Wnoah*aNoahETR02+Wmodis*amodisETsummer ]

p1=plot(aNWETetR02, 'r', name = 'NWET',/overplot)
p2=plot(aMWetR02, 'orange', name = 'MW', /overplot)
p3=plot(aNoahetR02, 'g', name = 'Noah',/overplot)
p4=plot(amodisetsummer, 'c', name = 'modis', /overplot)
p5=plot(wa,thick=3, linestyle=2,name = 'linear combo', /overplot)
p6=plot(aNAetR02,thick=3,/overplot,name='true')
!null = legend(target=[p1,p2,p3,p4,p5,p6], position=[0.2,0.3], font_size=14) ;

;MW (e3) vs Noah Resid (er)
print, correlate(e3resid[xind, yind, *],eresid[xind, yind, *]);
;MW vs NoahET
print, correlate(e3resid[xind, yind, *],esummer[xind, yind, *]);

;MW (e3) vs AETc-Station
print, correlate(e3resid[xind, yind, *],NAet);0.38
;MW vs MODIS
print, correlate(e3resid[xind, yind, *],e4summer[xind, yind, *]);
;MW vs NWET
print, correlate(e3resid[xind, yind, *],e5resid[xind, yind, *])

;
;AET-station vs Noah
print, correlate(NAet,esummer[xind, yind, *]);
;AET-station vs MODIS
print, correlate(NAet,e4summer[xind, yind, *]);
;resid AET-station vs Noah
print, correlate(NAetresid,esummer[xind, yind, *]);
;AET-station vs MODIS
print, correlate(NAetresid,e4summer[xind, yind, *]);
;AETstation vs NWET(p-s)
print, correlate(NAet,e5resid[xind, yind, *]);
;NoahET vs MODIS
print, correlate(esummer[xind, yind, *],e4summer[xind, yind, *]);
;NoahET vs NWET
print, correlate(esummer[xind, yind, *],e5resid[xind, yind, *]);
;NoahET vs Noah Resid
print, correlate(esummer[xind, yind, *],eresid[xind, yind, *]);
;MODIS vs NWET
print, correlate(e4summer[xind, yind, *],e5resid[xind, yind, *]);

;plot P-S for AG 2005-2008
p1=plot(e3resid[axind, ayind, 4:7], '-*', /overplot, name = 'P-S(MW)')
p1=plot(aETresid, /overplot, name = 'Station - Obs', 'b-*')
p1=plot(eresid[axind, ayind, 4:7], '-*r', /overplot, name = 'P-S(Noah)')

p1=plot(e3resid[wxind, wyind, 5:7], '-*', name = 'P-S(MW)')
p1=plot(wETresid, /overplot, name = 'Station - Obs', 'b-*')
p1=plot(eresid[wxind, wyind, 5:7], '-*r', /overplot, name = 'P-S(Noah)')

p1=plot(e3resid[bxind, byind, 5:7], '-*', name = 'P-S(MW)')
p1=plot(bETresid, /overplot, name = 'Station - Obs', 'b-*')
p1=plot(eresid[bxind, byind, 5:7], '-*r', /overplot, name = 'P-S(Noah)')

;*******************junk******************************

;*****************WRSI with station data, not so useful*****************************
afile = file_search('/jabber/chg-mcnally/AGPAW36_2005_2008_SOS.20.18.19.20_LGP7_WHC125_PET.csv')
wfile = file_search('/jabber/chg-mcnally/WKPAW36_2005_2008_SOS.16.18.18.14_LGP10_WHC140_PET.csv')
bfile = file_search('/jabber/chg-mcnally/BBPAW36_2005_2008_SOS.12.10.09_LGP18_WHC119_PET.csv');2006-2008

apaw = read_csv(afile)
apaw = reform(float(apaw.field1),36,4)
wpaw = read_csv(wfile)
wpaw = reform(float(wpaw.field1),36,4)
bpaw = read_csv(bfile)
bpaw = reform(float(bpaw.field1),36,3)

;calculate ET residuals...by dekads and then sum, stupid months...
;how can these be greater than rainfall? here maybe SWC would be better. 
aETresid = total(arain,1, /nan) - total(apaw,1,/nan)
wETresid = wrain - wpaw
bETresid = brain - bpaw
;************************************************************************************

;************how much does P-S explain AETc? Time series is tooo short******************** 
afile = file_search('/jabber/chg-mcnally/AMMARain/Agoufou_station_dekads.csv')
wfile = file_search('/jabber/chg-mcnally/AMMARain/wankamaWest_station_filled_dekads.csv')
bfile = file_search('/jabber/chg-mcnally/AMMARain/Belefoungou.rain.2006_2008_dekads_filled.csv')

arain = read_csv(afile) & help, arain
arain = reform(float(arain.field1),36,4)
wrain = read_csv(wfile) & help, wrain
wrain = reform(float(wrain.field1),36,4)
brain = read_csv(bfile) & help,  brain
brain = reform(float(brain.field1),36,3)

afile = file_search('/jabber/chg-mcnally/AMMASOIL/AMMA2013/dekads/Agoufou*{0.3,0.4,0.6}*csv')
wfile = file_search('/jabber/chg-mcnally/AMMASOIL/AMMA2013/dekads/Wankama_sm_0.{1,4,7}*.csv')
bfile = file_search('/jabber/chg-mcnally/AMMASOIL/AMMA2013/dekads/Belefoungou-Top_sm_{0.2,0.4,0.6}*.csv')

A103 = read_csv(afile[0])
A203 = read_csv(afile[1])
A304 = read_csv(afile[2])
A106 = read_csv(afile[3])
A206 = read_csv(afile[4])

A103 = float(A103.field1); go with this one!
A106 = float(A106.field1); go with this one!
A304 = float(A304.field1); go with this one!
A203 = float(A203.field1)
A206 = float(A206.field1)

agavg = reform(mean([transpose(a103),transpose(a106),transpose(a304),transpose(a203),transpose(a206)], dimension=1, /nan),36,4)
aETresid = total(arain[12:30,*],1) - total(agavg[12:30,*],1) & print, aETresid

WK14 = read_csv(wfile[0])
WK47 = read_csv(wfile[1])
WK71 = read_csv(wfile[2])


sarray = transpose([[float(wk14.field1)],[float(wk47.field1)],[float(wk71.field1)]]) & help, sarray
wkavg = reform(mean(sarray[*,0:107], dimension=1, /nan)*100,36,3)
wETresid = total(wrain[12:30,1:3],1) - total(wkavg[12:30,*],1) & print, wETresid

BB20 = read_csv(bfile[0])
BB40 = read_csv(bfile[1])
BB60 = read_csv(bfile[2])

sarray = transpose([[float(bb20.field1)],[float(bb40.field1)],[float(bb60.field1)]]) & help, sarray
bbavg = reform(mean(sarray[*,0:107], dimension=1, /nan)*100,36,3)

bETresid = total(brain[12:30,*],1) - total(bbavg[12:30,*],1)

;look at may-october....
;how does Noah Runoff look?
qfile = file_search('/jower/chg-mcnally/fromKnot/EXP01/monthly/Q*.img');132
nx = 720
ny = 250
nz = n_elements(qfile)
buffer = fltarr(nx,ny)
Qgrid = fltarr(nx,ny,nz)

for i=0,n_elements(qfile)-1 do begin &$
  openr,1,qfile[i] &$
  readu,1,buffer &$
  close,1 &$
  qgrid[*,*,i] = buffer &$
endfor
qcube = reform(qgrid, nx,ny,12,11)
qsummer = total(qcube[*,*,4:9,*],3, /nan)

p1 = image(mean(qsummer,dimension=3,/nan)*86400*rmask, rgb_table=4, max_value=100)
 c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
 ;runoff is a very small amount, what is quesitonale is the amout of ET that is supported by Noah layer 2...


print, r_correlate(e2summer[xind, yind, 0:9],wrsiresid[xind,yind,*]);AETc, WRSI (P-S)
print, r_correlate(e2summer[xind, yind, 0:9],e5resid[xind, yind, *]);AETc vs NWET
print, r_correlate(e2summer[xind, yind, 0:8],e3resid[xind, yind, *]);MW vs AETc-RFE
print, r_correlate(e2summer[xind, yind, 0:9],esummer[xind, yind, *]);AETc vs Noah ET
print, r_correlate(e2summer[xind, yind, 0:9],eresid[xind, yind, *]);;AETc (e3) vs Noah Resid (er)
print, r_correlate(e2summer[xind, yind, 0:9],e4summer[xind, yind, *]);AETc vs MODIS
print, r_correlate(e2summer[xind, yind, *],naetresid);AETc vs AETC-station (P-S)

print, r_correlate(naet,wrsiresid[xind,yind,*]);AETc, WRSI (P-S)
print, r_correlate(naet,e5resid[xind, yind, *]);AETc vs NWET
print, r_correlate(naet[0:8],e3resid[xind, yind, *]);MW vs AETc-RFE
print, r_correlate(naet,esummer[xind, yind, *]);AETc vs Noah ET
print, r_correlate(naet,eresid[xind, yind, *]);;AETc (e3) vs Noah Resid (er)
print, r_correlate(naet,e4summer[xind, yind, *]);AETc vs MODIS
print, r_correlate(naet,e2summer[xind, yind, *]);AETc vs MODIS
print, r_correlate(naet,naetresid);AETc vs MODIS



p1 = image(eresid[*,*,0]*rmask, rgb_table=4, title = 'Noah residual ET', max_value=800)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])

p1 = image(esummer[*,*,0]*rmask, rgb_table=4, title = 'Noah ET',max_value=800)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100]) 

p1 = image((esummer[*,*,0]*rmask*86400)/(eresid[*,*,0]*rmask), rgb_table=4, title = 'Ratio between ET and P-S', max_value=1.5, min_value=0.5)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100]) 
             



print, correlate(e2summer[xind, yind, *],wrsiresid[xind,yind,*]);AETc, WRSI (P-S)
print, correlate(e2summer[xind, yind, *],e5resid[xind, yind, *]);AETc vs NWET
print, correlate(e2summer[xind, yind, *],e3resid[xind, yind, *]);MW vs AETc-RFE
print, correlate(e2summer[xind, yind, *],esummer[xind, yind, *]);AETc vs Noah ET
print, correlate(e2summer[xind, yind, *],eresid[xind, yind, *]);;AETc (e3) vs Noah Resid (er)
print, correlate(e2summer[xind, yind, *],e4summer[xind, yind, *]);AETc vs MODIS
print, correlate(e2summer[xind, yind, *],naetresid);AETc vs MODIS

print, correlate(naet,wrsiresid[xind,yind,*]);AETc, WRSI (P-S)
print, correlate(naet,e5resid[xind, yind, *]);AETc vs NWET
print, correlate(naet,e3resid[xind, yind, *]);MW vs AETc-RFE
print, correlate(naet,esummer[xind, yind, *]);AETc vs Noah ET
print, correlate(naet,eresid[xind, yind, *]);;AETc (e3) vs Noah Resid (er)
print, correlate(naet,e4summer[xind, yind, *]);AETc vs MODIS
print, correlate(naet,e2summer[xind, yind, *]);AETc vs MODIS
print, correlate(naet,naetresid);AETc vs MODIS

;*************

;*********************
;print, correlate(WRSIetR02[xind, yind, 0:9],naetresid[0:9]);AETc, WRSI (P-S)
print, correlate(WRSIetR02[xind, yind, 0:9],e5resid[xind, yind, *]);AETc vs NWET
print, correlate(WRSIetR02[xind, yind, 0:8],e3resid[xind, yind, *]);MW vs AETc-RFE
print, correlate(WRSIetR02[xind, yind, 0:9],esummer[xind, yind, *]);AETc vs Noah ET
print, correlate(wrsiresid[xind, yind, 0:9],eresid[xind, yind, *]);;AETc (e3) vs Noah Resid (er)
print, correlate(wrsiresid[xind, yind, 0:9],e4summer[xind, yind, *]);AETc vs MODIS
;maybe the best thing to compare is the station and RFE WRSI residuals
print, r_correlate(naetresid[0:9],naetresid[0:9]);AETc, WRSI (P-S)
print, r_correlate(naetresid[0:9],e5resid[xind, yind, *]);AETc vs NWET
print, r_correlate(naetresid[0:8],e3resid[xind, yind, *]);MW vs AETc-RFE
print, r_correlate(naetresid[0:9],esummer[xind, yind, *]);AETc vs Noah ET
print, r_correlate(naetresid[0:9],eresid[xind, yind, *]);;AETc (e3) vs Noah Resid (er)
print, r_correlate(naetresid[0:9],e4summer[xind, yind, *]);AETc vs MODIS

print, correlate(naetresid[0:9],naetresid[0:9]);AETc, WRSI (P-S)
print, correlate(naetresid[ 0:9],e5resid[xind, yind, *]);AETc vs NWET
print, correlate(naetresid[0:8],e3resid[xind, yind, *]);MW vs AETc-RFE
print, correlate(naetresid[0:9],esummer[xind, yind, *]);AETc vs Noah ET
print, correlate(naetresid[0:9],eresid[xind, yind, *]);;AETc (e3) vs Noah Resid (er)
print, correlate(naetresid[0:9],e4summer[xind, yind, *]);AETc vs MODIS

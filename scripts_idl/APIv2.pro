pro APIv2
;the purpose of this script is to calculate the antecedent precipitation index (API)
;And then to compare the anomalies from the sAPI, rAPI, TF and obs

PETfile = file_search('/jabber/Data/mcnally/EROSPET/wankama_dekadPET_2005_2008.csv')
Rfile   = file_search('/jabber/Data/mcnally/AMMARain/RFE_and_station_dekads.csv')
obsfile = file_search('/jabber/Data/mcnally/AMMASOIL/observed_TKWK1WK2.csv')
TFfile  = file_search('/jabber/Data/mcnally/AMMASOIL/tftk70*')

data = read_csv(Rfile)
sdata = read_csv(obsfile)
petdata= read_csv(PETfile)

;wk140  wk170 wk240 wk270 tk40  tk70

;correlation is 0.76
sta = data.field1
rfe = data.field2 
pet = float(petdata.field1)

wk140 = float(sdata.field1)
wk170 = float(sdata.field2)
wk240 = float(sdata.field3)
wk270 = float(sdata.field4)
tk40 = float(sdata.field5)
tk70 = float(sdata.field6)

;put the soil moisture back into a matrix so i can loop thru or put the names of the vars in a vector...
SM=[transpose(wk140),transpose(wk170),transpose(wk240),transpose(wk270),transpose(tk40),transpose(tk70)]

tftk40=read_csv(TFfile[0])
tftk70=read_csv(TFfile[1])
tfwk140=read_csv(TFfile[2])
tfwk170=read_csv(TFfile[3])
tfwk240=read_csv(TFfile[4])
tfwk270=read_csv(TFfile[5])

tkpad=fltarr(19) & tkpad[*]=!values.f_nan
tftk40=[tkpad,tftk40.field1] ;starts at 20
tftk70=[tkpad,tftk70.field1] ;starts at 20
tfwk140=tfwk140.field1 ;starts at 1
tfwk170=tfwk170.field1 ;starts at 1
wk2pad=fltarr(15) & wk2pad[*]=!values.f_nan
tfwk240=[wk2pad,tfwk240.field1] ;starts at 16
tfwk270=[wk2pad,tfwk270.field1] ;starts at 16

tfSM=transpose([[tfwk140],[tfwk170],[tfwk240],[tfwk270],[tftk40],[tftk70]])

;**********NDVI:*******;WK1,W2,TK108,F110 and M110
nfile=file_search('/jabber/Data/mcnally/AMMAVeg/avergeNDVI_WK12MF_TK.dat')

ndvi=fltarr(5,144,3)

openr,1,nfile
readu,1,ndvi
close,1
;just take the dimension of interest
ndvi=ndvi[0:2,*,1]
ndvi=[ndvi[0,*],ndvi[0,*],ndvi[1,*],ndvi[1,*],ndvi[2,*],ndvi[2,*]]
;
;ofile='/jabber/Data/mcnally/AMMAVeg/avergeNDVI_WK12MF_TK.csv'
;write_csv,ofile,ndvi

;***simple API equation from Choudhury and Blanchard*******
;APIj=K(APIj-1 + R j-1) Saxton and Lenz (1967)
;for time varying K that is a function of fc,wp,PET,Z
;K=exp(-E/Z(fc-Wp) where fc is 0.2, wp=0.03,Z=?,kbar=0.72, E=EROS PET

;API calculated with station rainfall
APIs=fltarr(n_elements(sta))
;API calculated with RFE2 rainfall
APIr=fltarr(n_elements(sta))
;
;corr=fltarr(n_elements(SM[*,0]), n_elements(z))
;rsq=fltarr(n_elements(SM[*,0]),n_elements(z))
;SMapi=fltarr(n_elements(SM[*,0]),n_elements(sta))
;SMapi[*,*]=!values.f_nan
 
;to see how I solved for z=40 see API.pro (version 1)
fc= 0.2
wp= 0.03
z = 40
denom = (fc-wp)*z
;calculate the API where k is a function of PET, fc, wp, z
for r = 1,n_elements(sta)-1 do begin &$ 
  k = exp(-PET[r-1]/denom) &$
  APIs[r]=k*(APIs[r-1]+sta[r-1]) &$
  APIr[r]=k*(APIr[r-1]+rfe[r-1]) &$
endfor
     
staname=['wk140', 'wk170','wk240','wk270','tk40','tk70']
aSM=fltarr(n_elements(SM[*,0]),144)
aAPI=fltarr(n_elements(SM[*,0]),144)
apifit=fltarr(n_elements(SM[*,0]))
tffit=fltarr(n_elements(SM[*,0]))

;also check out the addative mean irf and tf
for i=0,n_elements(SM[*,0])-1 do begin &$
  ;move into anomaly space!
  ;S'
  i=2
  nSM=mean(reform(SM[i,*],36,4),dimension=2,/nan) &$
  nSM=[nSM,nSM,nSM,nSM] &$
  aSM=reform((SM[i,*]+0.08)/(nSM+0.08),144) &$
  ;API'
  nAPI=mean(reform(APIr[*],36,4),dimension=2,/nan) &$
  nAPI=[nAPI,nAPI,nAPI,nAPI] &$
  aAPI=reform((APIr[*]+10)/(nAPI+10),144)  &$ 
  ;TF' -- transfer function is an anomaly 
  TF=tfSM[i,*] &$
  ;get the NDVI anomaly too while we are here...
  nNDVI=mean(reform(ndvi[i,*],36,4),dimension=2,/nan) &$
  nNDVI=[nNDVI,nNDVI,nNDVI,nNDVI] &$
  aNDVI=(ndvi[i,*]+0.15)/(nNDVI+0.15) &$
  
  aSM=smooth(aSm,3,/nan) &$
  aNDVI=smooth(aNDVI,3,/nan) &$
  aAPI=smooth(aAPI,3,/nan) &$
  aTF=smooth(TF,3,/nan) &$
  
  ;p1=plot(aSM,'r') & p1=plot(aAPI, /overplot, 'orange') & p1=plot(TF,'g',/overplot) & p1=plot(aNDVI,'b',/overplot) &$
  ;p1=plot(aSM,'r') & p1=plot(TF,'g',/overplot) &$
  ;p1.title='anomolies @ '+staname[i] &$
  
  
;this should be caluclating the same fit as matlab but isn't...
  apifit[i] = 100*(1-norm(aSM-aAPI)/norm(aSM-mean(aSM, /nan))) &$
  tffit[i] = 100*(1-norm(aSM-aTF)/norm(aSM-mean(aSM, /nan))) &$
  p1=plot(aTF,aSM, title=staname[i],'*')
  ;apirsq[i] = correlate(aSM,aAPI)
  ;rsq[i]=correlate(aSM[0:143-2],aNDVI[2:143]) ;just use the good values....
  ;try the impulse reponse function...
  impfile=file_search('/jabber/Data/mcnally/AMMASOIL/imp*')
  imptab=read_csv(impfile)
  imp240=[wk2pad,imptab.field1]+1
  
  me=imp240*nsm
  dat=SM[i,*]
  avg=nSM
  
  good=where(finite(dat))
  ;this is what the norm function does...
  ;fit=sqrt(total((nSM(good)-dat(good))^2,/nan)) & print, fit
  fit=norm(me(good)-dat(good)) & print, fit
  fit=norm(nSM(good)-dat(good)) & print, fit
endfor  

;for each freq use a sin and cos wave...on regression coeff. 
;this is a kind of harmonic analysis...
;when fitting a dis fft on finite sample set nyquis freq to pi and largest to 2pi/144
;sin and cos at 36 freq/2
;x matrix of predictors
xmat=fltarr(36,144)
ymat=reform(ndvi[2,*],144)

;ian's means
;make a predictor matrix of  sin and cos values at intervals 1-18
pi=3.14159
;time
for t=1, n_elements(xmat[0,*]) do begin  &$
  ;period
  for p=1,18 do begin  &$
    xmat[p-1,t-1]=cos(2*pi*p*t/36)  &$
  endfor  &$
  for p=1,18 do begin  &$
    xmat[18+p-1,t-1]=sin(2*pi*p*t/36)  &$
  endfor  &$
endfor

result=regress(xmat,ymat, yfit=yfit)

2pi*i/m f
for i=0,(m/2)-1


;************best fit criteria*****************************
;FIT = 100 * (1-norm(Y-YHAT)/norm(Y-mean(Y))) (in %) - from matlab
staname=['wk140', 'wk170','wk240','wk270','tk40','tk70']
for i=0,n_elements(SM[*,0])-1 do begin &$
  sim=[i,*] &$
  obs=SM[i,*]  &$;wk140
  fit=100*(1-norm(obs-sim)/norm(obs-mean(obs, /nan))) &$
  print, fit  &$
  temp=plot(sim, linestyle=2)  &$
  temp=plot(obs,/overplot,'b',title='observ (blue) vs rfe API estimated (black) at '+staname[i],font_size=20)  &$
endfor
       

n=fltarr(10)
p=fltarr(10) 
ns=fltarr(10)
ps=fltarr(10)     
     ;experiment in lags
     for i=0,9 do begin &$
       n[i]=correlate(ma2n[0:143-i],aAPI[i:143]) & print, n  &$
       p[i]=correlate(matn[i:143],aAPI[0:143-i]) & print, p  &$
     
       ns[i]=correlate(ma2n[0:143-i],aSM[i:143]) & print, ns  &$
       ps[i]=correlate(matn[i:143],aSM[0:143-i]) & print, ps  &$
     endfor;i
     
     temp=plot(ps)
     temp=plot(ns)
   ;endfor;j
   


end
;***********************************************************
;write out the soil moisture estimates from the API.
;ofile='/jabber/Data/mcnally/AMMASOIL/APIsta_WK1WK2TK.csv'
;write_csv,ofile,SMapi
;
;ofile='/jabber/Data/mcnally/AMMASOIL/API_rfe_sta.csv'
;write_csv,ofile,APIsta,APIrfe




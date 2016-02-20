;the purpose of this script is to calculate the antecedent precipitation index (API)
;using the the equation in Yamaguchi and Shinoda 2002. It seems to fit pretty well. 
;they suggesting using sum 60days of rainfall, and i added an additional 3 dekad offset when I didn't fit any of the parameters in excel (lucky)

ifile = file_search('/jabber/Data/mcnally/AMMARain/RFE_and_station_dekads.csv')
;obsfile = file_search('/jabber/Data/mcnally/AMMASOIL/WK1_2/WK2_field108_40cm_10dayWP.csv')
obsfile = file_search('/jabber/Data/mcnally/AMMASOIL/observed_TKWK1WK2.csv');wk140  wk170 wk240 wk270 tk40  tk70
PETfile = file_search('/jabber/Data/mcnally/EROSPET/wankama_dekadPET_2005_2008.csv')

data = read_csv(ifile)
sdata = read_csv(obsfile)
petdata= read_csv(PETfile)

sta = data.field1;correlation is 0.76
rfe = data.field2 
wk140 = float(sdata.field1)
wk240 = float(sdata.field2)
wk170 = float(sdata.field3)
wk270 = float(sdata.field4)
tk40 = float(sdata.field5)
tk70 = float(sdata.field6)
pet = float(petdata.field1)

;put the soil moisture back into a matrix so i can loop thru or put the names of the vars in a vector...
SM=[transpose(wk140),transpose(wk240),transpose(wk170),transpose(wk270),transpose(tk40),transpose(tk70)]

;***simple API equation from Choudhury and Blanchard*******
;APIj=K(APIj-1 + R j-1) Saxton and Lenz (1967)
;for time varying K that is a function of fc,wp,PET,Z
;K=exp(-E/Z(fc-Wp) where fc is 0.2, wp=0.03,Z=?,kbar=0.72, E=EROS PET

;calculate a whole season using one value for z....test the correlation, k will vary with z.
fc= 0.2
wp= 0.03
z=indgen(20)*10+10
APIs=fltarr(n_elements(sta),n_elements(z))
APIr=fltarr(n_elements(sta),n_elements(z))
corr=fltarr(n_elements(SM[*,0]), n_elements(z))
rsq=fltarr(n_elements(SM[*,0]),n_elements(z))
SMapi=fltarr(n_elements(SM[*,0]),n_elements(sta))
SMapi[*,*]=!values.f_nan
;calc API and find the soil depth which maximizes the correlation between 
;API and observed soil moisture. 
  
  ;for j=0,n_elements(z)-1 do begin &$ ;19 depths
      j=3 ;z[3]=40cm works best here with the given PET, fc, wp
      for r=1,n_elements(sta)-1 do begin &$ 
        denom=(fc-wp)*z[j] &$
        k=exp(-PET[r-1]/denom) &$
        ;k=0.45  &$
        APIs[r,j]=k*(APIs[r-1,j]+sta[r-1]) &$
        APIr[r,j]=k*(APIr[r-1,j]+rfe[r-1]) &$
        print,k &$
      endfor &$
    ;correlates with each of the observed datasets and fits the line to the observations.
    staname=['wk140', 'wk170','wk240','wk270','tk40','tk70']
     for i=0,n_elements(SM[*,0])-1 do begin &$
       i=0
       j=3 &$
       ;remove the mean of the SM: first find the mean for a specific site, then standardize by it
       nSM=mean(reform(SM[i,*],36,4),dimension=2,/nan) &$
       nSM=[nSM,nSM,nSM,nSM] &$
       aSM=(SM[i,*]+0.02)/(nSM+0.02) &$
       ;remove the mean of the API-SM (multipicative): first find the mean API for the specific site, then stdz
       ;i might change APIs to APIr here but it will not carry thru -- just be careful
       nAPI=mean(reform(APIr[*,j],36,4),dimension=2) &$
       nAPI=[nAPI,nAPI,nAPI,nAPI] &$
       aAPI=(API[*,j]+10)/(nAPI+10) &$    
       
       ;i think that this makes them comparable by scaling the observed SM to the same API - then i can 
       ;check the fit statistics...
       scaleSM=aSM*nAPI
       temp=plot(scaleSM,'b')
       temp=plot(APIr[*,3],/overplot)
       temp=plot(APIs[*,3],'g',/overplot)
       
       good=where(finite(SM[i,*])) &$ 
       result=regress(aAPI[good],reform(aSM[good],n_elements(good)),correlation=correlation,yfit=yfit) &$
       rsq[i,j]=correlation &$
       
       ;API estiamted soil moisture wk140  wk170 wk240 wk270 tk40  tk70
       ;too much fitting-- I should just adjust the means.
       ;SMapi[i,144-n_elements(good):n_elements(good)+144-n_elements(good)-1]=yfit &$
     temp=plot(aSM) &$
     temp=plot(aAPI, /overplot,'b', title=" SM' and staAPI' at "+staname[i] , font_size=20) &$
     temp=plot(ma1n,/overplot,'g'); these come from the other script, have way less magnitude...
     
     temp=plot(aSM,aAPI,'*', title=" SM' and rfeAPI' at "+staname[i] , font_size=20) &$
     temp=plot(ma1n[2:143],aAPI[0:143-2],'*', title=" lag (2) N' and rfeAPI' at "+staname[i] , font_size=20)
     c=correlate(ma1n[1:143],aAPI[0:143-1]) & print, c

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
   
;***see how the transfer function compares********
ifile=file_search('/jabber/Data/mcnally/AMMASOIL/tftk40*')

tftk40=read_csv(ifile[0])
tftk70=read_csv(ifile[1])
tfwk140=read_csv(ifile[2])
tfwk170=read_csv(ifile[3])
tfwk240=read_csv(ifile[4])
tfwk270=read_csv(ifile[5])

tkpad=fltarr(19) & tkpad[*]=!values.f_nan
tftk40=[tkpad,tftk40.field1] ;starts at 20
tftk70=[tkpad,tftk70.field1] ;starts at 20
tfwk140=tfwk140.field1 ;starts at 1
tfwk170=tfwk170.field1 ;starts at 1
wk2pad=fltarr(15) & wk2pad[*]=!values.f_nan
tfwk240=[wk2pad,tfwk240.field1] ;starts at 16
tfwk270=[wk2pad,tfwk270.field1] ;starts at 16

;eak, why are the same sites not identicle? they should have had the same NDVI
;input but are a tad different.Somthing about the anomalies I guess?
;I could look at the site with the mean closest to zero, or go back and get the zero mean timeseries...

tfSM=transpose([[tfwk140],[tfwk170],[tfwk240],[tfwk270],[tftk40],[tftk70]])
;************best fit criteria*****************************
;;these would prolly be better if i removed the dry season...
;FIT = 100 * (1-norm(Y-YHAT)/norm(Y-mean(Y))) (in %) - from matlab
staname=['wk140', 'wk170','wk240','wk270','tk40','tk70']
for i=0,n_elements(SM[*,0])-1 do begin &$
  sim=SMapi[i,*] &$
  obs=SM[i,*]  &$;wk140
  fit=100*(1-norm(obs-sim)/norm(obs-mean(obs, /nan))) &$
  print, fit  &$
  temp=plot(sim, linestyle=2)  &$
  temp=plot(obs,/overplot,'b',title='observ (blue) vs rfe API estimated (black) at '+staname[i],font_size=20)  &$
endfor

;***********************************************************
;write out the soil moisture estimates from the API.
;ofile='/jabber/Data/mcnally/AMMASOIL/APIsta_WK1WK2TK.csv'
;write_csv,ofile,SMapi
;
;ofile='/jabber/Data/mcnally/AMMASOIL/API_rfe_sta.csv'
;write_csv,ofile,APIsta,APIrfe




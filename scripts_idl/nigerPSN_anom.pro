;the purpose of this script is to calculate the additive and multiplicative anoms
;for precip, ndvi and soil moisture at the different sites in Niger.

;**********rainfall***************************************
;2x144 staion and RFE dekadal rainfall 2005-2008
rfile=file_search('/jabber/Data/mcnally/AMMARain/RFE_and_station_dekads.csv') 
rain=read_csv(rfile)
sta=rain.field1
rfe=rain.field2

;********soil moisture**************************************
;***wait on these***read in 2005-2006 dekadal SM files*************************
ifilef10=file_search('/jabber/Data/mcnally/AMMASOIL/WK110/WK110_fallow_VWC_10cm.WP.csv')
ifilef50=file_search('/jabber/Data/mcnally/AMMASOIL/WK110/WK110_fallow_VWC_50cm.WP.csv')
ifilem10=file_search('/jabber/Data/mcnally/AMMASOIL/WK110/WK110_millet_VWC_10cm.WP.csv')
ifilem50=file_search('/jabber/Data/mcnally/AMMASOIL/WK110/WK110_millet_VWC_50cm.WP.csv')

f10=read_csv(ifilef10)
f10vwc=float(f10.field1)

f50=read_csv(ifilef50)
f50vwc=float(f50.field1)

m10=read_csv(ifilem10)
m10vwc=float(m10.field1)

m50=read_csv(ifilem50)
m50vwc=float(m50.field1)
;*************RFE and station API -- redo these ....***********************
;ifileAPI = file_search('/jabber/Data/mcnally/AMMASOIL/API_rfe_sta.csv')

temp = read_csv(ifileAPI)
APIs=temp.field1
APIr=temp.field2

;*****************************************************************
ifile140=file_search('/jabber/Data/mcnally/AMMASOIL/WK1_2/WK1_field108_40cm_10dayWP.csv')
ifile170=file_search('/jabber/Data/mcnally/AMMASOIL/WK1_2/WK1_field108_7Xcm_10dayWP.csv')
ifile240=file_search('/jabber/Data/mcnally/AMMASOIL/WK1_2/WK2_field108_40cm_10dayWP.csv')
ifile270=file_search('/jabber/Data/mcnally/AMMASOIL/WK1_2/WK2_field108_7Xcm_10dayWP.csv')

ifilet40=file_search('/jabber/Data/mcnally/AMMASOIL/TK110/TK_field108_40cm_10dayavg_VWC.csv')
ifilet70=file_search('/jabber/Data/mcnally/AMMASOIL/TK110/TK_field108_70cm_10dayavg_VWC.csv')

f140=read_csv(ifile140)
f140vwc=float(f140.field3)

f170=read_csv(ifile170)
f170vwc=float(f170.field3)

f240=read_csv(ifile240)
f240vwc=float(f240.field3)

f270=read_csv(ifile270)
f270vwc=float(f270.field3)

t40=read_csv(ifilet40)
t40vwc=float(t40.field3)

t70=read_csv(ifilet70)
t70vwc=float(t70.field3)

;*****************************NDVI***************************************************************
;5sitesx144 dekadsx3 different pixel aggregations, use pixel #2 (which is really 1 w/ zero indexing)
;WK1,W2,TK108,F110 and M110
nfile=file_search('/jabber/Data/mcnally/AMMAVeg/avergeNDVI_WK12MF_TK.dat')

ndvi=fltarr(5,144,3)

openr,1,nfile
readu,1,ndvi
close,1
;just take the dimension of interest
ndvi=ndvi[*,*,1]

nwk1 = reform(ndvi(0,*),36,4)
nwk2 = reform(ndvi(1,*),36,4)
ntk  = reform(ndvi(2,*),36,4)
nfal = reform(ndvi(3,*),36,4)
nmil = reform(ndvi(4,*),36,4)

mwk1n=mean(nwk1,dimension=2,/nan)
wk1n=[mwk1n,mwk1n,mwk1n,mwk1n]
mwk2n=mean(nwk2,dimension=2,/nan)
wk2n=[mwk2n,mwk2n,mwk2n,mwk2n]
mtkn=mean(ntk,dimension=2,/nan)
tkn=[mtkn,mtkn,mtkn,mtkn]

;********************find the average seasonal curve*************************
;find the means accross years
msta  = mean(transpose(reform(sta,36,4)),dimension=1, /nan)
mrfe = mean(transpose(reform(rfe,36,4)), dimension=1, /nan)

;ndviarray = mean(transpose(mean(ndvi, dimension=1)),dimension=1, /nan)
;mndvi=mean(reform(ndviarray,36,4),dimension=2, /nan)

soilarray = reform([[f140vwc],[f240vwc], [f170vwc],[f270vwc],[t40vwc],[t70vwc]],36,4,6)
msoil = transpose(mean(soilarray, dimension=2, /nan))

mAPIs=mean(reform(APIs,36,4),dimension=2, /nan)
mAPIr=mean(reform(APIr,36,4),dimension=2, /nan)

;put it back into a vector for easy subtraction
vmsta = [msta,msta,msta,msta]
vmrfe  = [mrfe,mrfe,mrfe,mrfe]
;vmndvi = [mndvi,mndvi,mndvi,mndvi]
mAPIs = [mAPIs,mAPIs,mAPIs,mAPIs]
mAPIr = [mAPIr,mAPIr,mAPIr,mAPIr]

vmsoilf140 = reform(transpose([msoil[0,*],msoil[0,*],msoil[0,*],msoil[0,*]]),144)
vmsoilf240 = reform(transpose([msoil[1,*],msoil[1,*],msoil[1,*],msoil[1,*]]),144)
vmsoilf170 = reform(transpose([msoil[2,*],msoil[2,*],msoil[2,*],msoil[2,*]]),144)
vmsoilf270 = reform(transpose([msoil[3,*],msoil[3,*],msoil[3,*],msoil[3,*]]),144)
vmsoilt40 = reform(transpose([msoil[4,*],msoil[4,*],msoil[4,*],msoil[4,*]]),144)
vmsoilt70 = reform(transpose([msoil[5,*],msoil[5,*],msoil[5,*],msoil[5,*]]),144)

;additive and multiplicative anomalies
;magic epsilon
e=0.08 ;min soil mositure is around 0.04, and i want climatology for each site, don't use global mean.

maf140=(f140vwc+e)/(vmsoilf140+e)
maf240=(f240vwc+e)/(vmsoilf240+e)
maf170=(f170vwc+e)/(vmsoilf170+e)
maf270=(f270vwc+e)/(vmsoilf270+e)
mat40=(t40vwc+e)/(vmsoilt40+e)
mat70=(t70vwc+e)/(vmsoilt70+e)

anomarray=transpose([[maf140],[maf240],[maf170],[maf270],[mat40],[mat70]])
avganom=mean(anomarray, dimension=1,/nan)

temp=plot(maf140)
temp=plot(maf240,/overplot,'b')
temp=plot(maf170,/overplot,'g')
temp=plot(maf270,/overplot,'c')
temp=plot(mat40,/overplot,'m')
temp=plot(mat70,/overplot,'r')

;additive SM anomalies
aaf140 = f140vwc-vmsoilf140
aaf240 = f240vwc-vmsoilf240
aaf170 = f170vwc-vmsoilf170
aaf270 = f270vwc-vmsoilf270
aatk40 = t40vwc-vmsoilt40
aatk70 = t70vwc-vmsoilt70

temp=plot(aaf140)
temp=plot(aaf240,/overplot,'b')
temp=plot(aaf170,/overplot,'g')
temp=plot(aaf270,/overplot,'c')
temp=plot(aatk40,/overplot,'m')
temp=plot(aatk70,/overplot,'r')


;additive and multiplicative ndvi anomalies
e=0.2 ;min ndvi~0.12
;i should not have done thes by the global mean...
ma1n=reform((nwk1+e)/(vmndvi+e),144)
ma2n=reform((nwk2+e)/(vmndvi+e),144)
matn=reform((ntk+e)/(vmndvi+e),144)

;average NDVI anomalies******************************
nanomarray=[[ma1n],[ma2n],[matn]]
navganom=mean(nanomarray,dimension=2, /nan)

temp=plot(ma1n)
temp=plot(ma2n,/overplot,'b')
temp=plot(matn,/overplot,'g')

aa1n=reform(nwk1-vmndvi,144)
aa2n=reform(nwk2-vmndvi,144)
aatn=reform(ntk-vmndvi,144)

;additive and multiplicative rainfall anomalies and API...
e=10
maSTA=(sta+e)/(vmsta+e)
maRFE=(rfe+e)/(vmrfe+e)

e=10
maAPIs=(APIs+e)/(mAPIs+e)
maAPIr=(APIr+e)/(mAPIr+e)

temp=plot(maSTA)
temp=plot(maRFE,/overplot,'b')

aaSTA=(sta-vmsta)
aaRFE=(rfe-vmrfe)

temp=plot(aaSTA)
temp=plot(aaRFE,/overplot,'b')
temp.title='additive rainfall anomalies'
temp.title.font_size=20

ofile1='/jabber/Data/mcnally/AMMASOIL/add_anomsWK12TK.csv'
ofile2='/jabber/Data/mcnally/AMMASOIL/mult_anomsWK12TK.csv'
ofile3='/jabber/Data/mcnally/NDVIadd_anomsWK12TK.csv'
ofile4='/jabber/Data/mcnally/NDVImult_anomsWK12TK.csv'
ofile5='/jabber/Data/mcnally/AMMARain/add_anomsRFEsta.csv'
ofile6='/jabber/Data/mcnally/AMMARain/mult_anomsRFEsta.csv'


write_csv,ofile1,aaf140,aaf240,aaf170,aaf270,aatk40,aatk70
write_csv,ofile2,maf140,maf240,maf170,maf270,mat40,mat70
write_csv,ofile3,aa1n,aa2n,aatn
write_csv,ofile4,ma1n,ma2n,matn
write_csv,ofile5,aaSTA,aaRFE
write_csv,ofile6,maSTA,maRFE

;then re-import the models from matlab and add back in the seasonal means
;
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


;addback in the seasonal means (look good!)
stk40=tftk40*vmsoilt40 ;plot with t40vwc)
stk70=tftk70*vmsoilt70
swk140=tfwk140*vmsoilf140
swk170=tfwk170*vmsoilf170
swk240=tfwk240*vmsoilf240
swk270=tfwk270*vmsoilf270

;***scale the API data too ****
result=regress(APIs,f140vwc,correlation=rsq,yfit=api140)
result=regress(APIs,f170vwc,correlation=rsq,yfit=api170)
good=where(finite(f240vwc))
result=regress(APIs(good),f240vwc(good),correlation=rsq,yfit=api240)
good=where(finite(f270vwc))
result=regress(APIs(good),f270vwc(good),correlation=rsq,yfit=api270)
good=where(finite(t40vwc))
result=regress(APIs(good),t40vwc(good),correlation=rsq,yfit=apit40)
good=where(finite(t70vwc))
result=regress(APIs(good),t70vwc(good),correlation=rsq,yfit=apit70)

tkpad=fltarr(19) & tkpad[*]=!values.f_nan
wk2pad=fltarr(15) & wk2pad[*]=!values.f_nan

api240=[wk2pad,reform(api240,129)]
api270=[wk2pad,reform(api270,129)]
apit40=[tkpad,apit40]
apit70=[tkpad,apit70]

temp=plot(api140)
temp=plot(api170, /overplot,'r')
temp=plot(api240, /overplot,'orange')
temp=plot(api270, /overplot,'g')
temp=plot(apit40, /overplot,'b')
temp=plot(api170, /overplot,'m')

;************best fit criteria*****************************
;FIT = 100 * (1-norm(Y-YHAT)/norm(Y-mean(Y))) (in %) - from matlab
sim=apit70
obs=t70vwc
fit=100*(1-norm(obs-sim)/norm(obs-mean(obs, /nan))) & print, fit

;something wrong...i need to do individual scaling
temp=plot(sim)
temp=plot(obs,'b')
temp=plot(f270vwc,/overplot,'g')
temp=plot(f140vwc,/overplot,'c')
;***********************************************************
;
;;export these to excel!
;ofile='/jabber/Data/mcnally/AMMASOIL/tf_anom_TKWK1WK2.csv'
;write_csv,ofile,swk140,swk170,swk240,swk270,stk40,stk70
;
;ofile='/jabber/Data/mcnally/AMMASOIL/observed_TKWK1WK2.csv'
;write_csv,ofile,f140vwc,f170vwc,f240vwc,f270vwc,t40vwc,t70vwc

temp=plot(stk70, title='TK70 modeled [ndvi-soil moisture anom] (black) vs observed (blue)', font_size=20)
temp=plot(t70vwc,'b',/overplot)

temp=plot(swk270, title='wk270 modeled [ndvi-soil moisture anom] (black) vs observed (blue)', linestyle=2,font_size=20)
temp=plot(f270vwc,'b',/overplot)

;***************correlate ndvi and soil moisture with truncating vectors per chris***********************
lag=fltarr(n_elements(avganom))
nlag=fltarr(n_elements(avganom))
apilag=fltarr(n_elements(avganom))
rapilag=fltarr(n_elements(avganom))
for i=0,n_elements(avganom)-1 do begin &$
  ;highest correlation is SMt-NDVIt+2 0.44
  nlag[i]=correlate(avganom[0:(n_elements(navganom)-1)-i], navganom[i:n_elements(avganom)-1]) &$
  lag[i]=correlate(avganom[i:n_elements(avganom)-1],navganom[0:(n_elements(navganom)-1)-i]) &$
  apilag[i]=correlate(maAPIs[i:n_elements(avganom)-1],navganom[0:(n_elements(navganom)-1)-i]) &$
  rapilag[i]=correlate(maAPIr[i:n_elements(avganom)-1],navganom[0:(n_elements(navganom)-1)-i]) &$
endfor

i=2
X=avganom[i:n_elements(avganom)-1]
Y=navganom[0:(n_elements(navganom)-1)-i]
temp=plot(avganom[i:n_elements(avganom)-1],navganom[0:(n_elements(navganom)-1)-i],'*')
temp=regress(avganom[i:n_elements(avganom)-1],navganom[0:(n_elements(navganom)-1)-i],correlation=rsq,const=const)
result = LINFIT(X, Y, MEASURE_ERRORS=measure_errors)
line=result[0]+avganom*result[1]
temp=plot(avganom,line,/overplot)


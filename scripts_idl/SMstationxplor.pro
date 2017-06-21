pro SMstationxplor

;the purpose of this program to to check out the correlations and crosscorr
;of the seasonalized and deseasonalized ndvi and soil moisture time series.

;field comparisons
sf40=file_search('/jabber/Data/mcnally/AMMASOIL/WK?_field*40cm_10dayavg_VWC.dat')  ;buffer=fltarr(3,144) columns are: year, dekad, soil moisture
sf7X=file_search('/jabber/Data/mcnally/AMMASOIL/WK?_field*7?cm_10dayavg_VWC.dat')
;sfdeep=file_search('/jabber/Data/mcnally/AMMASOIL/WK?_field*{97,100}cm_10dayavg_VWC.dat'); doesn't work 97f is negative

;gully comparisons
sg6X=file_search('/jabber/Data/mcnally/AMMASOIL/WK?_gully108_{68,70}cm_10dayavg_VWC.dat') 
;sgdeep=file_search('/jabber/Data/mcnally/AMMASOIL/WK?_gully108_{97,100}cm_10dayavg_VWC.dat') ;doesn't work, 97g is negative

;rain and NDVI files
nrawfile=file_search('/jabber/Data/mcnally/AMMAVeg/avergeNDVI_Wnk1_Wnk2_file108.dat') ;buffer=fltarr(2,144,3)
rtheofile=file_search('/jabber/Data/mcnally/AMMARain/rain4soil/ROI_theo.rain.2005_2008_dekads.dat')

nbuffer=fltarr(2,144,3)
openr,1,nrawfile
readu,1,nbuffer
close,1

rraw=fltarr(4,36) ;wankama1 field40
openr,1,rtheofile
readu,1,rraw
close,1

sbuffer=fltarr(3,144) ;wankama1 field40

;openr,1,sf40[1]
openr,1,sgdeep[1]
readu,1,sbuffer
close,1

;doing this by hand, read in wk1 first...
wk1f40=sbuffer
wk2f40=sbuffer

wk1f7X=sbuffer
wk2f7X=sbuffer

wk1g6x=sbuffer
wk2g6x=sbuffer

wk1gdeep=sbuffer; 97g bad
wk1deep
temp=plot(wk1deep[2,*])
temp=plot(wk1gdeep[2,*], /overplot, color="blue", title='wk1 97field (black), wk197 gully (blue)')
wk2gdeep=sbuffer
;*****************************************************
temp=plot(wk1f40[2,*])
temp=plot(wk2f40[2,*],color='green', /overplot, title='@40cm wk1(black), wk2(blue) R2=0.82')
good=where(finite(wk2f40[2,*]), complement=bad)
lag = [0,1,2,3,4,5]
scorr = c_correlate(wk2f40[2,good], wk1f40[2,good],lag) & print, scorr
;******************************************************
temp=plot(wk1f7X[2,*])
temp=plot(wk2f7X[2,*],color='blue', /overplot, title='@~70cm wk1(black), wk2(blue) R2=0.5') 
good=where(finite(wk2f7X[2,*]), complement=bad)
lag = [0,1,2,3,4,5]
scorr = c_correlate(wk2f7X[2,good], wk1f7X[2,good],lag) & print, scorr

;***************************************************************************
temp=plot(wk1g6x[2,*])
temp=plot(wk2g6x[2,*],color='blue', /overplot, title='@~70cm gully wk1(black), wk2(blue) R2=0.85') 
good=where(finite(wk2g6x[2,*]), complement=bad)
lag = [0,1,2,3,4,5]
scorr = c_correlate(wk2g6X[2,good], wk1g6X[2,good],lag) & print, scorr
;***************************************************************************
;this exampe doesn't really work...
temp=plot(wk1gdeep[2,*])
temp=plot(wk2gdeep[2,*],color='blue', /overplot);, title='@~70cm gully wk1(black), wk2(blue) R2=0.85') 

;convert to water potential 
;what are the differences between the banzoumba and bagoua sites where 
;these parameters come from. Should I be using one over another?
;Bagoua has a higher sand content. Campbell van Gnucten perform differently under dry/wet regime.
;I could try a range of the parameters but will probably continue on for now. 
 ;30-60cm: ψe=0.78, b=2.71, Өs=0.42 
 ;ψm = ψe (Ө/Өs)-b
wpwk1f40=0.78*(wk1f40[2,*]/0.42)^(-2.71)
wpwk2f40=0.78*(wk2f40[2,*]/0.42)^(-2.71)

;psie=0.9, b=2.83, thetaS=0.4 >60cm
wpwk1f7X =0.9*(wk1f7X[2,*]/0.4)^(-2.83)
wpwk2f7X =0.9*(wk2f7X[2,*]/0.4)^(-2.83)

wpwk1g6X =0.9*(wk1g6X[2,*]/0.4)^(-2.83)
wpwk2g6X =0.9*(wk2g6X[2,*]/0.4)^(-2.83)

;and then export as yr, doy, vwc, potential
ofile1=strcompress('/jabber/Data/mcnally/AMMASOIL/WK1_field108_40cm_10dayWP.csv')
odat1=[wk1f40,transpose(wpwk1f40)]

ofile2=strcompress('/jabber/Data/mcnally/AMMASOIL/WK2_field108_40cm_10dayWP.csv')
odat2=[wk2f40,wpwk2f40]

ofile3=strcompress('/jabber/Data/mcnally/AMMASOIL/WK1_field108_7Xcm_10dayWP.csv')
odat3=[wk1f7X,transpose(wpwk1f7X)]

ofile4=strcompress('/jabber/Data/mcnally/AMMASOIL/WK2_field108_7Xcm_10dayWP.csv')
odat4=[wk2f7X,transpose(wpwk2f7X)]

ofile5=strcompress('/jabber/Data/mcnally/AMMASOIL/WK1_gully108_6Xcm_10dayWP.csv')
odat5=[wk1g6X, transpose(wpwk1g6X)]

ofile6=strcompress('/jabber/Data/mcnally/AMMASOIL/WK2_gully108_6Xcm_10dayWP.csv')
odat6=[wk2g6X,transpose(wpwk2g6X),nbuffer(1,*,2)]

write_csv,ofile1,odat1
write_csv,ofile2,odat2
write_csv,ofile3,odat3
write_csv,ofile4,odat4
write_csv,ofile5,odat5
write_csv,ofile6,odat6

;reform into cubes so that i can compare seasons and years.
ncube=reform(nraw,2,36,3,4)
scube=reform(sraw,3,36,4)
scube2=reform(sraw2,3,36,4)
scube3=reform(sraw3,3,36,4)
scube4=reform(sraw4,3,36,4)


;example plot command - not great to look at these all at the same time but at least they are all loaded. 
;wk2 is wetter, no consistant pattern between field and gully in 2005
p1=plot(scube[2,*,2],'m') ;wk1 field40
;p1=plot(scube2[2,*,3],'g-.',/overplot); wk2_field
p1=plot(scube3[2,*,2],'m--',/overplot);wk1_gully68
p1=plot(scube4[2,*,3],'g*-',/overplot);wk2 gully
p1=plot(ncube[0,*,1,2],'m',/overplot) ;wk1
p1=plot(ncube[1,*,1,3],'g*-',/overplot) ;stary=wk2


;**********************deseasobnalized TS*******************************
;reshape into 144 length arrays...(macarronis)
sdesmac=[[sdes[0,*]], [sdes[1,*]],[sdes[2,*]],[sdes[3,*]]]
ndesmac=[[ndes[0,*]], [ndes[1,*]],[ndes[2,*]],[ndes[3,*]]]
rsq = correlate(sdesmac, ndesmac) & print, rsq
p1=plot(ndesmac, sdesmac,'+', linestyle=6)

;look at just summer
rsq = correlate(sdesmac(summer), ndesmac(summer)) & print, rsq
p1=plot(ndesmac(summer), sdesmac(summer),'+', linestyle=6)

lag = [0,1,2,3,4,5]
scorr = c_correlate(ndesmac, sdesmac,lag) & print, scorr
scorr = c_correlate(ndesmac(summer), sdesmac(summer),lag) & print, scorr


pro ndvi_soil_corr

;the purpose of this program to to check out the correlations and crosscorr
;of the seasonalized and deseasonalized ndvi and soil moisture time series.

;raw and deseasonalized files.
srawfile=file_search('/jabber/Data/mcnally/AMMASOIL/WK1_field108_40cm_10dayavg_VWC.dat')  ;buffer=fltarr(3,144) columns are: year, dekad, soil moisture
srawfile2=file_search('/jabber/Data/mcnally/AMMASOIL/WK2_field108_40cm_10dayavg.dat')  ;buffer=fltarr(3,144) columns are: year, dekad, soil moisture

srawfile3=file_search('/jabber/Data/mcnally/AMMASOIL/WK1_gully108_68cm_10dayavg_VWC.dat')  ;not sure if this one in VWC
srawfile4=file_search('/jabber/Data/mcnally/AMMASOIL/WK2_gully108_70cm_10dayavg_VWC.dat')  ;buffer=fltarr(3,144) columns are: year, dekad, soil moisture

srawfile5=file_search('/jabber/Data/mcnally/AMMASOIL/WK1_field108_77cm_10dayavg_VWC.dat')  ;buffer=fltarr(3,144) columns are: year, dekad, soil moisture
srawfile6=file_search('/jabber/Data/mcnally/AMMASOIL/WK2_gully108_100cm_10dayavg_VWC.dat') ;I don't think that I can use this one.

srawfile7=file_search('/jabber/Data/mcnally/AMMASOIL/WK2_field108_100cm_10dayavg_VWC.dat') ;I don't think that I can use this one.
srawfile8=file_search('/jabber/Data/mcnally/AMMASOIL/WK2_gully108_70cm_10dayavg_VWC.dat') ;I don't think that I can use this one.

srawfile9=file_search('/jabber/Data/mcnally/AMMASOIL/WK1_field108_97cm_10dayavg_VWC.dat') ;I don't think that I can use this one.

nrawfile=file_search('/jabber/Data/mcnally/AMMAVeg/avergeNDVI_Wnk1_Wnk2_file108.dat') ;buffer=fltarr(2,144,3)

rtheofile=file_search('/jabber/Data/mcnally/AMMARain/rain4soil/ROI_theo.rain.2005_2008_dekads.dat')
;ndesfile='/jabber/Data/mcnally/AMMAVeg/Wank1_filteredNDVI2005_08.dat'    ;buffer=fltarr(4,36)
;sdesfile='/jabber/Data/mcnally/AMMASOIL/WK1_gully108_68cm_anomalyTS.dat' ;buffer=fltarr(4,36)
;sdesfile='/jabber/Data/mcnally/AMMASOIL/WK1_field108_40cm_anomalyTS.dat' ;buffer=fltarr(4,36)


rraw=fltarr(4,36) ;wankama1 field40
openr,1,rtheofile
readu,1,rraw
close,1

sraw=fltarr(3,144) ;wankama1 field40
openr,1,srawfile
readu,1,sraw
close,1

sraw2=fltarr(3,144) ;wankama2 field
openr,1,srawfile2
readu,1,sraw2
close,1

sraw3=fltarr(3,144) ;wankama1 gully
openr,1,srawfile3
readu,1,sraw3
close,1

sraw4=fltarr(3,144) ;wankama2 gully
openr,1,srawfile4
readu,1,sraw4
close,1


sraw5=fltarr(3,144) ;wankama1 field77
openr,1,srawfile5
readu,1,sraw5
close,1

sraw6=fltarr(3,144) ;wankama1 gully97
openr,1,srawfile6
readu,1,sraw6
close,1

sraw7=fltarr(3,144) ;wankama2 field 100
openr,1,srawfile7
readu,1,sraw7
close,1

sraw8=fltarr(3,144) ;wankama2 field 70
openr,1,srawfile8
readu,1,sraw8
close,1

nraw=fltarr(2,144,3); 2 must be the 750m avg
openr,1,nrawfile
readu,1,nraw
close,1

lag = [0,1,2,3,4,5]

;remove the long series of nans (as in wankama2)
;sraw=wk1=0
good=where(finite(sraw[2,*]), complement=bad)
s=0
suck = sraw
suck[2,*]=0.78*(suck[2,*]/0.35)^(-2.71)
scorr = c_correlate(suck[2,good], nraw[s,good,1],lag) & print, scorr
scorr = c_correlate(sraw[2,good], nraw[s,good,1],lag) & print, scorr
scorr = c_correlate(rraw[good],sraw[2,good],lag) & print, scorr

firstdiff=nraw[s,1:143,1]-nraw[s,0:142,1]
firstdiff=[firstdiff,mean(firstdiff)]
summer=where(firstdiff gt 0)

scorr = c_correlate(suck[2,summer], nraw[s,summer,1],lag) & print, scorr
scorr = c_correlate(sraw[2,summer], nraw[s,summer,1],lag) & print, scorr


;sraw2=wk2=1
good=where(finite(sraw2[2,*]), complement=bad)
s=1
rsq = c_correlate(sraw2[2,good], nraw[s,good,1],lag) & print, rsq

;sraw3=wk1gully=0
good=where(finite(sraw3[2,*]), complement=bad)
s=0
rsq = c_correlate(sraw3[2,good], nraw[s,good,1],lag) & print, rsq

;sraw4=wk2gully=1
good=where(finite(sraw4[2,*]), complement=bad)
s=1
rsq = c_correlate(sraw2[2,good], nraw[s,good,1],lag) & print, rsq

good=where(finite(sraw5[2,*]), complement=bad)
s=0
scorr = c_correlate(sraw5[2,good], nraw[s,good,1],lag) & print, scorr

good=where(finite(sraw6[2,*]), complement=bad)
s=1
scorr = c_correlate(sraw6[2,good], nraw[s,good,1],lag) & print, scorr

good=where(finite(sraw7[2,*]), complement=bad)
s=1
scorr = c_correlate(sraw7[2,good], nraw[s,good,1],lag) & print, scorr

good=where(finite(sraw8[2,*]), complement=bad)
s=1
scorr = c_correlate(sraw8[2,good], nraw[s,good,1],lag) & print, scorr

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


pro findsoillagv3

;this script was originaly used on the neutron probe data (v1), then the millet and fallow-110 (v2)
;this time (v3) i'll look at the fallow sites wk1,wk2,tk (do I want gully sites)
;Use the 90 day table for each of the different days (someday i need to look at the other station...)
;maybe this needs to be redone for 10 day increments?

;read in 2005-2006 dekadal SM files*************************
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
;*****************************************************************
wkfile=file_search('/jabber/Data/mcnally/AMMASOIL/WK1_2/WK*_field108_??cm_10dayWP.csv')
tkfile=file_search('/jabber/Data/mcnally/AMMASOIL/TK110/TK_field108_??cm_10dayavg_VWC.dat')


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
;*********************************************************************
ifile=file_search('/jabber/Data/mcnally/AMMARain/lagtable_station_dekads.csv')
rain=read_csv(ifile) 
rainmat=transpose([[rain.field1],[rain.field2],[rain.field3],[rain.field4],[rain.field5],[rain.field6],[rain.field7], $
                    [rain.field8],[rain.field8]])

Rf140=fltarr(n_elements(rainmat[*,0]))
Rf240=fltarr(n_elements(rainmat[*,0]))
Rf170=fltarr(n_elements(rainmat[*,0]))
Rf270=fltarr(n_elements(rainmat[*,0]))
Rt40=fltarr(n_elements(rainmat[*,0]))
Rt70=fltarr(n_elements(rainmat[*,0]))

for i=0,n_elements(rainmat[*,0])-1 do begin &$
  
  Rf140[i]=correlate(f140vwc,rainmat[i,*]) &$
  good=where(finite(f240vwc)) &$
  Rf240[i]=correlate(f240vwc[good],rainmat[i,good]) &$
  
  good=where(finite(f170vwc)) &$
  Rf170[i]=correlate(f170vwc[good],rainmat[i,good]) &$
  
  good = where(finite(f270vwc)) &$
  Rf270[i]=correlate(f270vwc[good],rainmat[i,good]) &$
  
  good=where(finite(t40vwc)) &$
  Rt40[i]=correlate(t40vwc[good],rainmat[i,good]) &$
  
  good=where(finite(t70vwc)) &$
  Rt70[i]=correlate(t70vwc[good],rainmat[i,good]) &$
endfor

p1=plot(rf140,'red') 
p2=plot(rf240,'orange', /overplot)
p3=plot(rf170,'green', /overplot)
p4=plot(rf270,'blue', /overplot)
p5=plot(rt40,'cyan', /overplot)
p6=plot(rt70,'m', /overplot)

p1.name='wk1 40cm'
p2.name='wk2 40cm'
p3.name='wk1 70cm'
p4.name='wk2 70cm'
p5.name='tk 40cm'
p6.name='tk 70cm'

!null = legend(target=[p1,p2,p3,p4,p5,p6], position=[0.2,0.3]) 

print, max(rf140) & print, where(rf140 eq max(rf140))
print, max(rf240) & print, where(rf240 eq max(rf240))

print, max(rf170) & print, where(rf170 eq max(rf170))
print, max(rf270) & print, where(rf270 eq max(rf270))

print, max(rt40) & print, where(rt40 eq max(rt40))
print, max(rt70) & print, where(rt70 eq max(rt70))

;do the same this for the shorter period millet an fallow sites:
Rf10=fltarr(n_elements(rainmat[*,0]))
Rf50=fltarr(n_elements(rainmat[*,0]))
Rm10=fltarr(n_elements(rainmat[*,0]))
Rm50=fltarr(n_elements(rainmat[*,0]))

for i=0,n_elements(rainmat[*,0])-1 do begin &$
  good=where(finite(f10vwc)) &$
  Rf10[i]=correlate(f10vwc[good],rainmat[i,good]) &$ 
  
  good=where(finite(f50vwc)) &$
  Rf50[i]=correlate(f50vwc[good],rainmat[i,good]) &$  
  
  good=where(finite(m10vwc)) &$
  Rm10[i]=correlate(m10vwc[good],rainmat[i,good]) &$ 
  
  good=where(finite(m50vwc)) &$
  Rm50[i]=correlate(m50vwc[good],rainmat[i,good]) &$ 

endfor

p1=plot(rf10,'red') 
p2=plot(rf50,'orange', /overplot)
p3=plot(rm10,'green', /overplot)
p4=plot(rm50,'blue', /overplot,yrange=[0.6,0.9])

p1.name='fallow 10cm'
p2.name='fallow 50cm'
p3.name='millet 10cm'
p4.name='millet 50cm'
p4.ytickfont_size=20
p4.xtickfont_size=20
p4.title='correlation with n-previous dekads accumulated precip'
p4.title.font_size=20
!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=18) 

;************what do these curves look like for NDVI and rainfall?*********************************
;the correlation is monotonically increasing. i guess just becasue it is increasingly smooth. 
;5sitesx144 dekadsx3 different pixel aggregations, use pixel #2 (which is really 1 w/ zero indexing)
;WK1,W2,TK108,F110 and M110
nfile=file_search('/jabber/Data/mcnally/AMMAVeg/avergeNDVI_WK12MF_TK.dat')

ndvi=fltarr(5,144,3)

openr,1,nfile
readu,1,ndvi
close,1

;correlate NDVI at different sites with different accumulations of rainfall...
Rwk1=fltarr(n_elements(rainmat[*,0]))
for i=0,n_elements(rainmat[*,0])-1 do begin &$
  good=where(finite(ndvi[0,*,2])) &$
  Rwk1[i]=correlate(ndvi[0,good,2],rainmat[i,good]) &$ 
end

;and what is the correlation between NDVI and soil moisture again? right, pretty high. this is dumb.
;but this is the issue of spurious correlation when there is seasonal autocorrelation. I should prolly be comparing anomalies
;in all of these cases? or the rank or fit statistic used in matlab....
  good=where(finite(f270vwc))
print, correlate(ndvi[1,good,2],f270vwc[good])
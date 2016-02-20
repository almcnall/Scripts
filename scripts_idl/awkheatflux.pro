;this script plots (and smooths) the heat flux values that I pulled from the noah stats file (not post-processed).
; and i updated it on 9/12/2012 to look at the water balance...things look pretty good. See Slides_4_sciMeetingv2.

;station rainfall runs are the WK3 and satellite rainfall are RF4
lfile=file_search('/jabber/LIS/OUTPUT/spinupcheck/WK3_Qle.txt')
sfile=file_search('/jabber/LIS/OUTPUT/spinupcheck/WK3_Qh.txt')

Qle=read_csv(lfile) ;need to pad with 19 nans
Qh=read_csv(sfile)

smQle=smooth(Qle.field1,360)
smQh=smooth(Qh.field1,360)

;p1=plot(Qle.field1)
p1=plot(smQle, 'g', thick=3)
p2=plot(smQh, 'orange', thick=3, /overplot)
p1.title='LIS-Noah modeled heat fluxes forced with station and satellite rainfall'
xticks=['2005', '2006','2007','2008']
p2.xtickname=xticks
p2.xtickfont_size=26
p2.ytickfont_size=20
p2.ytitle='Heat flux millet (Wm2)'
p1.title.font_size=24
p1.name='latent heat flux'
p2.name='sensible heat flux'
 !null = legend(target=[p1,p2], position=[0.2,0.3], font_size=17) 
p2.xrange=[360,11000]
p2.yrange=[0,200]

;*************plot the heat flux from the RFE2 runs********************************
lfile=file_search('/jabber/LIS/OUTPUT/spinupcheck/RF4_Qle.txt')
sfile=file_search('/jabber/LIS/OUTPUT/spinupcheck/RF4_Qh.txt')

RQle=read_csv(lfile) ;need to pad with 19 nans
RQh=read_csv(sfile)

RsmQle=smooth(RQle.field1,360)
RsmQh=smooth(RQh.field1,360)

;p1=plot(Qle.field1)
p3=plot(RsmQle, 'c', thick=3,/overplot)
p4=plot(RsmQh, 'm', thick=3, /overplot)
p1.title='LIS-Noah modeled heat fluxes forced with satellite and station rainfall'
xticks=['2005', '2006','2007','2008']
p2.xtickfont_size=26
p2.ytickfont_size=20
p2.ytitle='Heat flux millet (Wm2)'
p1.title.font_size=24
p3.name='RFE latent heat flux'
p4.name='RFE sensible heat flux'
p1.name='station latent heat flux'
p2.name='station sensible heat flux'
 !null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=17) 
p2.xrange=[360,11000]
p2.yrange=[0,200]
p2.xtickname=xticks

;water balance plot from the RFE2 runs
;ok, now I have to recreate the water balance figure...cummulative rainfall
;for 2006, cummulative evap, non-cum. soil storage, P-E-S

rfile=file_search('/jabber/LIS/OUTPUT/spinupcheck/RF4_rain.txt')
sfile=file_search('/jabber/LIS/OUTPUT/spinupcheck/WK3_rain.txt')
erfile=file_search('/jabber/LIS/OUTPUT/spinupcheck/RF4_evap.txt')
esfile=file_search('/jabber/LIS/OUTPUT/spinupcheck/WK3_evap.txt')

rfe=read_csv(rfile)
sta=read_csv(sfile)
revap=read_csv(erfile)
sevap=read_csv(esfile)

rfe=float(rfe.field1);1/1/2005-1/1/2009
sta=float(sta.field1);1/1/2005-12/30/2008
revap=float(revap.field1)
sevap=float(sevap.field1)

;this is a stupid way to denote years....plus i'll wanto to extend into 2007 to match Raimer plot
yr05=rfe(0:365*8-1)
yr06=rfe(365*8:365*8+365*8-1)
yr07=rfe(365*2*8:365*3*8-1)
yr08=rfe(365*3*8:365*4*8)

ys06=sta(365*8:365*8+365*8-1)
yes06=sevap(365*8:365*8+365*8-1)
yer06=revap(365*8:365*8+365*8-1)

rraintot=fltarr(n_elements(yr06))
sraintot=fltarr(n_elements(ys06))
revaptot=fltarr(n_elements(yr06))
sevaptot=fltarr(n_elements(ys06))

rraintot[0]=yr06[0]
sraintot[0]=ys06[0]

;how do i fix the units? mm/s to mm how many seconds in 
for i=1,n_elements(ys06)-1 do begin &$
  rraintot[i]=yr06[i]+rraintot[i-1] &$
  sraintot[i]=ys06[i]+sraintot[i-1] &$
  revaptot[i]=yer06[i]+revaptot[i-1] &$
  sevaptot[i]=yes06[i]+sevaptot[i-1] &$
endfor
;adjust the units....
rraintot=rraintot*10800
sraintot=sraintot*10800
revaptot=revaptot*10800
sevaptot=sevaptot*10800
;60sec*60min*3hrs
p1=plot(rraintot,'b',thick=3)
p2=plot(sraintot,'g',/overplot,thick=3,title="RFE and Station Rainfall 2006", font_size=20, ytitle="mm")
p3=plot(sevaptot,'orange',/overplot,thick=3)
p4=plot(revaptot,'m',/overplot,thick=3)

p2.yrange=[0,700]
 
 ;**********soil storage**********************************
ifile=file_search('/jabber/LIS/OUTPUT/spinupcheck/WK3soil.txt')
sm=read_ascii(ifile,delimiter=' ')
layers4=reform(sm.field1[1,*],n_elements(sm.field1[1,*])) ;all four layers before splitting

sm1=fltarr((n_elements(layers4)/4)+1)
sm2=fltarr((n_elements(layers4)/4)+1)
sm3=fltarr((n_elements(layers4)/4)+1)
sm4=fltarr((n_elements(layers4)/4)+1)

count=0
j=0 & k=0 & l=0 &m=0
for i=0,n_elements(layers4)-1 do begin &$
  if count eq 0 then begin &$
    sm1[j]=layers4[i] & count++ & j++ & continue &$
  endif &$
  if count eq 1 then begin &$
    sm2[k]=layers4[i] & count++ & k++ & continue &$
  endif &$
  if count eq 2 then begin &$
    sm3[l]=layers4[i] & count++ & l++ & continue &$
  endif &$
  if count eq 3 then begin &$
    sm4[m]=layers4[i] & count = 0 & m++ & continue &$\
  endif &$
endfor 

totsoil=sm1+sm2+sm3+sm4
ssoil06=totsoil(365*8:365*8+365*8-1)
ssoil06=ssoil06-min(ssoil06)

rsoil06=totsoil(365*8:365*8+365*8-1)
rsoil06=rsoil06-min(rsoil06)
p5=plot(rsoil06, /overplot)
p6=plot(ssoil06, /overplot, 'b')

p1.name='RFE2 rainfall'
p2.name='station rainfall'
p3.name='station evap'
p4.name='RFE2 evap'
p5.name='RFE2 soil'
p6.name='station soil'
 !null = legend(target=[p1,p2,p3,p4,p5,p6], position=[0.2,0.3], font_size=17) 

;***water balance***********
diff=rcum06-ecum06-scube06
p4=plot(diff, /overplot, thick=2,font_size=20,font_name='times',title='water cycle dynamics crop exp007', ytitle='mm', $
        yrange=[0,700],XTICKV=[30,90,150,210,270,330],XTICKNAME=['Apr06','Jun06','Aug06','Oct06','Dec06','Feb07'])
p4.name = 'Pc-Ec-S'

!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=20, font_name='times') ; not sure how this line works...

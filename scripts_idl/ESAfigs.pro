pro ESAfigs
;the purpose of this program is to make nice figures for ESA...i might end up exporting them to R
;but i'll try here for now.

;4x144 [yr, dek, vwc, waterpotential]
wkfile=file_search('/jabber/Data/mcnally/AMMASOIL/WK1_2/WK*_field108_??cm_10dayWP.csv')
fmfile=file_search('/jabber/Data/mcnally/AMMASOIL/WK110/WK110_*_VWC_?0cm.WP.csv')
tkfile=file_search('/jabber/Data/mcnally/AMMASOIL/TK110/TK_field108_??cm_10dayavg_VWC.dat')
simfile=file_search('/jabber/Data/mcnally/AMMASOIL/VWCnoWK1_avgNDVI.csv')
simfileWK2=file_search('/jabber/Data/mcnally/AMMASOIL/VWCWK2_wk2NDVI.csv')
simWK2Tk=file_search('/jabber/Data/mcnally/AMMASOIL/VWCWK2_TKNDVI.csv')
simWK2M=file_search('/jabber/Data/mcnally/AMMASOIL/VWCwk2_millNDVI.csv')
simWK2F=file_search('/jabber/Data/mcnally/AMMASOIL/VWCwk2_fallNDVI.csv')

tfmilfile=file_search('/jabber/Data/mcnally/AMMASOIL/tf43_milNDVI.csv')
tftkfile=file_search('/jabber/Data/mcnally/AMMASOIL/tf43_tkNDVI.csv')
tfwk2file=file_search('/jabber/Data/mcnally/AMMASOIL/tf43_wk2NDVI.csv')

;these will be structures with 4, 144 row field
simVWC=read_csv(simfile) ;need to pad with 19 nans
simVWCwk2=read_csv(simfileWK2)
simVWCwk2m=read_csv(simWK2M)
simVWCwk2f=read_csv(simWK2F)
simVWCwk2tk=read_csv(simWK2tk)

;transfer function files. then need to pad them out appropriately....
miltf=read_csv(tfmilfile)
tktf=read_csv(tftkfile)
wk2tf=read_csv(tfwk2file)

miltf=miltf.field1
;*************Wankama2 filler
pad=dblarr(15)
pad[*]=!values.f_nan

psimVWC=[pad,simVWC.field1]
psimVWCwk2=[pad,simVWCwk2.field1]
ptfwk2=[pad,wk2tf.field1]

;*********tondi kiboro filler
pad=dblarr(19)
pad[*]=!values.f_nan
psimVWCwk2tk=[pad,simVWCwk2tk.field1]
pktf=[pad,tktf.field1]

wk1f40=read_csv(wkfile[0])
wk1f70=read_csv(wkfile[1])
wk2f40=read_csv(wkfile[2])
wk2f70=read_csv(wkfile[3])

fal10=read_csv(fmfile[0])
fal50=read_csv(fmfile[1])
mil10=read_csv(fmfile[2])
mil50=read_csv(fmfile[3])

fal10=double(fal10.field1)
fal50=double(fal50.field1)
mil10=double(mil10.field1)
mil50=double(mil50.field1)

;************millet filler*********************
fpad=dblarr(16)
pad=dblarr(72)
pad[*]=!values.f_nan
fpad[*]=!values.f_nan

ptfmil50=[fpad,miltf.field1,pad];they need pad on the front end too...

pfal10=[fal10,pad]
pfal50=[fal50,pad]
pmil10=[mil10,pad]
pmil50=[mil50,pad]

;now read in the tondi kiboro sites yr dek vwc wp
tk05=fltarr(4,144)
tk40=fltarr(4,144)
tk70=fltarr(4,144)

openr,1,tkfile[0]
readu,1,tk05
close,1

openr,1,tkfile[1]
readu,1,tk40
close,1

openr,1,tkfile[2]
readu,1,tk70
close,1

;inserted this bit so that the tk file would be the same format as the other wankama files (8/24)
;ofile1='/jabber/Data/mcnally/AMMASOIL/TK110/TK_field108_05cm_10dayavg_VWC.csv
;ofile2='/jabber/Data/mcnally/AMMASOIL/TK110/TK_field108_40cm_10dayavg_VWC.csv'
;ofile3='/jabber/Data/mcnally/AMMASOIL/TK110/TK_field108_70cm_10dayavg_VWC.csv'
;
;write_csv,ofile1,tk05
;write_csv,ofile2,tk40
;write_csv,ofile3,tk70

avgsmNOwk1=mean([[double(wk2f40.field3)],[double(wk2f70.field3)],[pfal10],[pfal50],[pmil10],[pmil50],[reform(tk70[2,*],144)],[reform(tk40[2,*],144)]],/nan,dimension=2)
                    
;avgsm=mean([[wk1f40.field3],[wk1f70.field3],[double(wk2f40.field3)],[double(wk2f70.field3)],[pfal10],[pfal50],[pmil10],[pmil50]],/nan,dimension=2)
;avgwk=mean([[wk1f40.field3],[wk1f70.field3],[double(wk2f40.field3)],[double(wk2f70.field3)]],/nan,dimension=2)
;avgfm=mean([[pfal10],[pfal50],[pmil10],[pmil50]],/nan,dimension=2)
;avgfm50=mean([[pfal50],[pmil50]],/nan,dimension=2)
;avg70=mean([[wk1f70.field3],[double(wk2f70.field3)],[reform(tk70[2,*],144)]],/nan,dimension=2)

;*************FIGURE 3 WK2 FIR vs WK40-70********************************
p1=plot(double(wk2f40.field3),'b',thick=2)
p2=plot(double(wk2f70.field3), /overplot, 'c',thick=2)
p3=plot(psimVWCwk2, /overplot, thick=3, linestyle=2)
p4=plot(ptfwk2,/overplot,thick=3,linestyle=2,'orange')
p1.xrange=[0,144]
p1.name='wk2 40cm, NP fit=52.5, P fit=45.89'
p2.name='wk2 70cm, NP fit=49.4, P fit=42.68'
p3.name='non-parametric SM (avg 40-70)'
p4.name='parametric SM (avg 40-70)'
!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=18) 

xticks=['2005','','2006','','2007','','2008']
p2.xtickname=xticks
p2.title='Estimated and Observed soil moisture at Wankama 2 2005-2008'
p2.title.font_size=22
p2.xtickfont_size=22
p2.ytickfont_size=22
p2.ytitle='volumetric soil moisture (m3/m3)'

;***********FIGURE 4 WK2 FIR vs Tondi Kiboro******************
p1=plot(tk40[2,*],'b',thick=2)
p2=plot(tk70[2,*],/overplot,'c',thick=2)
p3=plot(psimVWCwk2tk, thick=3,linestyle=2,/overplot)
p4=plot(pktf,thick=3,linestyle=2,/overplot,'orange')

p1.title='Estimated and Observed soil moisture at Tondi Kiboro 2005-2008'
p1.name='tk 40cm, NP fit=24.74, P fit=30.56' 
p2.name='tk 70cm, NP fit=14.46, P fit=26.91'
p3.name='non-parametric SM (avg 40-70)'
p4.name='parametric SM (avg 40-70)'
!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=18) 

xticks=['2005','','2006','','2007','','2008']
p2.xtickname=xticks
p2.title.font_size=22
p2.xtickfont_size=22
p2.ytickfont_size=22
p2.ytitle='volumetric soil moisture (m3/m3)'


;*********FIGURE 5 WK2 FIR vs millet and fallow AND NOAH modeled at 10-100cm***************.
ifile=file_search('/jabber/LIS/OUTPUT/spinupcheck/RF*soil*.txt')
sm=read_ascii(ifile[4],delimiter=' ')
layers4=sm.field1[1,*] ;all four layers before splitting
sm1=fltarr((n_elements(layers4)/4)+1)
sm2=fltarr((n_elements(layers4)/4)+1)
sm3=fltarr((n_elements(layers4)/4)+1)
sm4=fltarr((n_elements(layers4)/4)+1)

count=0
j=0 & k=0 & l=0 &m=0
for i=0,n_elements(layers4[0,*]) do begin &$
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

ssm2=congrid(sm2/300,144)
ssm3=congrid(sm3/600,144);40 - 100 mm

p1=plot((simVWCwk2m.field1-mean(simVWCwk2m.field1))+mean(pmil50,/nan),thick=3, linestyle=2)
p2=plot(pmil50,'b',thick=2, /overplot)
p3=plot((ssm3-mean(ssm3)+mean(pmil50,/nan)), /overplot, thick=2,color='green')
p4=plot((miltf-mean(miltf)+mean(pmil50,/nan)), /overplot, thick=2, linestyle=2,'orange')

p1.title='Estimated and Observed soil moisture 2005-2006: Wankama Millet'
p1.title.font_size=22
p1.xtickfont_size=22
p1.ytickfont_size=22
p1.ytitle='volumetric soil moisture (m3/m3)'
p1.name='non-parametrc SM 40-70 cm'
p2.name='millet 50cm, NP fit=60.3, P fit=55.2'
p3.name='Noah SM 40-100cm (mean adjusted)'
p4.name='parametric SM 40-70 cm'
!null = legend(target=[p1,p4,p2,p3], position=[0.2,0.3], font_size=18)
p1.XRANGE=[10, 140]
p1.YRANGE=[0, 0.17]
xticks=['2005','','2006','','2007','','2008']
p1.xtickname=xticks


;*****FIGURE 1 NDVI plots***************************************
;make a map of the avg AUG ndvi
nfile=file_search('/jabber/Data/mcnally/AMMAVeg/avergeNDVI_WK12MF_TK.dat') ;buffer=fltarr(2,144,3)
;5sitesx144 dekadsx3 different pixel aggregations, use pixel #2 (which is really 1 w/ zero indexing)
;WK1,W2,TK108,F110 and M110
ndvi=fltarr(5,144,3)

openr,1,nfile
readu,1,ndvi
close,1

p1=plot(ndvi[0,*,1],'r', thick=3, linestyle=2);wk1
p2=plot(ndvi[1,*,1],'b', /overplot, thick=3);wk2
p3=plot(ndvi[2,*,1],'orange', /overplot, thick=1);tk
p4=plot(ndvi[3,*,1],'g', /overplot, thick=1);fallow
p5=plot(ndvi[4,*,1],'c', linestyle=2,/overplot,thick=1);millet

p1.name='Wankama 1'
p2.name='Wankama 2'
p3.name='Tondi Kiboro'
p4.name='fallow'
p5.name='millet'
;!null = legend(target=[p1,p2,p3,p4,p5], position=[0.2,0.3], font_size=16) 
!null = legend(target=[p1,p2,p3,p4,p5], position=[0.2,0.3], font_size=18) 

xticks=['2005', '','2006','','2007','','2008','']
p1.xtickname=xticks
p1.title='NDVI at soil moisture sites'
p1.title.font_size=24
p1.xtickfont_size=24
p1.ytickfont_size=24
p1.ytitle='NDVI'

;pull map for august 2007 
mfile=file_search('/jabber/sandbox/mcnally/west_africa_emodis/WAdata.2007.081.img')
nx= 19271
ny= 7874

ingrid=fltarr(nx,ny)
openr,1,mfile
readu,1,ingrid
close,1
;ll=2.002 map info saved in 'envi_example'
;resolution = 2.4130000000e-03 =   0.00241300

;this is a good example for the standard west africa window...
p1 = image(ingrid, image_dimensions=[46.5,19], image_location=[-19,2], dimensions=[nx/100,ny/100], $
           rgb_table=20)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
p1 = MAP('Geographic',LIMIT = [2, -19, 21, 27.5], /overplot)
p1 = MAPCONTINENTS(/COUNTRIES)

;so I think that I want to clip out...12N to 16N, and 0-7E
wlon = 0. ;deg east
elon = 7. ;east
slat = 12.
nlat = 16.

wxind = FLOOR((wlon + 19.) / 0.002413)
exind = FLOOR((elon + 19.) / 0.002413)
syind = FLOOR((slat - 21) / 0.002413)
nyind = FLOOR((nlat - 21) / 0.002413)

;highlight area of interest on the map....good check
;ingrid(wxind:exind,syind:nyind)=8

ngr=ingrid(wxind:exind,syind:nyind)
x=2901
y=1658
p1 = image(ngr, image_dimensions=[7,4], image_location=[0,12], dimensions=[x/10,y/10], $
           rgb_table=20)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
p1 = MAP('Geographic',LIMIT = [12, 0, 16, 7], /overplot)
p1 = MAPCONTINENTS(/COUNTRIES)
;lat lons for WK1,W2,TK108,F110 and M110
lat = [13.6456, 13.6448, 13.5483, 13.6476, 13.644] 
lon = [  2.632,    2.63,  2.6966,  2.6337,  2.6299] 

p1 = plot(lon,lat,linestyle=6,'*', /overplot)

;******soil water potential at different depths*******
;Bagoua has a higher sand content. Campbell van Gnucten perform differently under dry/wet regime.
 ;ψm = ψe (Ө/Өs)-b Oh! I just need to plot water potential vs water content...
 ;do I have the TK data readin already? yup tk05,tk40,tk70
 
 p1=plot(tk05[2,*], tk05[3,*], linestyle=6, '*', /ylog)
 p2=plot(tk40[2,*], tk40[3,*], linestyle=6,color='blue', '*', /overplot)
 p3=plot(tk70[2,*], tk70[3,*], linestyle=6,color='green', '*', /overplot)
 p1.title='Soil characteric curve at the Tondi Kiboro site using Campbell equation'
 p1.title.font_size=18
 p1.ytitle='tension (kPa)'
 p1.xtitle='volumetric water content (fraction)'
 ;how do I change the fontsize on the x and y axis?
 
 p1.name='05cm'
 p2.name='40cm'
 p3.name='70cm'
 !null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=15) 
 
;****plot up the impulse response function(not pretty)...don't show this- show freq amp/gain instead.
;ifile='/jabber/Data/mcnally/AMMASOIL/FIR_noWK1.txt';this is not the same as just WK2
;ifile='/jabber/Data/mcnally/AMMASOIL/FIR_WK2_66.txt'
;FIR=read_csv(ifile)
;;for some reason this goes from -7 to 22 
;xticks=indgen(14)-6
;b1=barplot(xticks,FIR.field1)
;b1.title='Impulse response function Input= WK2 NDVI !C Output= WK2 Volumetric water content'
;b1.title.font_size=28
;b1.xtickfont_size=28
;b1.ytickfont_size=28
;b1.YRANGE=[-0.4, 0.6]
;x_title = TEXT(0.45,0.04,'lag (dekads)',FONT_SIZE=28, /current)
;b1.ytitle='impulse response weight'
;******************plot the heat flux from the station runs********************

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

;****bode plots, can i make them nice?*****************************
tffile=file_search('/jabber/Data/mcnally/AMMASOIL/tf43_bode.csv')
FRfile=file_search('/jabber/Data/mcnally/AMMASOIL/FR_bode.csv')
tfbode=read_csv(tffile)
FRbode=read_csv(FRfile) 

tmag=tfbode.field1
tphse=tfbode.field2
twout=tfbode.field3
tp=1/(twout/(2*3.14159))

mag=frbode.field1
phse=frbode.field2
wout=frbode.field3
p=1/(wout/(2*3.14159))

;plot the amplitude/gain
p1=plot(tp,tmag,/ylog,/xlog,title='Frequency Response',thick=4,'orange',xrange=[30,1])
p2=plot(p,mag,/overplot,/xlog, /ylog, thick=3)
p1.xtickfont_size=26
p1.ytickfont_size=26
p1.ytitle='amplitude'
p1.title.font_size=26
p1.xtitle='period (dekads)'
p1.name='parametric transfer function'
p2.name='frequency response function'
 !null = legend(target=[p1,p2], position=[0.2,0.3], font_size=26) 
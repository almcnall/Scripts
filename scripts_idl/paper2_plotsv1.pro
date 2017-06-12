pro paper2_plotsv1

;***figures of station-PAW vs observed SM****
;;*******FIGURE 1**********
;******same figure for Agoufou*********
;read in the Agoufou data
ifile = file_search('/jabber/chg-mcnally/AMMASOIL/AMMA2013/dekads/Agoufou*{0.3,0.4,0.6}*csv')

A103 = read_csv(ifile[0])
A203 = read_csv(ifile[1])
A304 = read_csv(ifile[2])
A106 = read_csv(ifile[3])
A206 = read_csv(ifile[4])

;read in the stationPAW
ifile = file_search('/jabber/chg-mcnally/AGPAW_2005_2008_SOS.20.18.19.20_LGP16_WHC125_PET.csv')
paw = read_csv(ifile) ; 7fields (dekads) x 12 years
pcube = [[paw.field1],[paw.field2], [paw.field3],[paw.field4]]

;****make a time series of the paw filling in the correct spaces 36*3 = 108 2006-2008
PAWTS = fltarr(36,4)
;PAWTS = fltarr(36,3)
LGP=7
SOS = [20,18,19,20] 
for yr = 0,n_elements(SOS)-1 do begin &$
  start = 0  &$
  ph1 = SOS[yr]-2 & print, ph1  &$
  ph2 = SOS[yr]-1 & print, ph2 &$
  ph3 = SOS[yr]-1+LGP-1 & print, ph3 &$
  ph4 = SOS[yr]+LGP-1 & print, ph4 &$
  fin = 35  &$
  PAWTS[start:ph1,yr] = !values.f_nan  &$
  PAWTS[ph2:ph3,yr] = pcube[*,yr]  &$
  PAWTS[ph4:fin,yr] = !values.f_nan  &$
endfor

pvect = reform(pawts,144)
;ofile = strcompress('/jabber/chg-mcnally/AGPAW_complete_TS.csv', /remove_all)

A103 = float(A103.field1); go with this one!
A106 = float(A106.field1); go with this one!
A304 = float(A304.field1); go with this one!
A203 = float(A203.field1)
A206 = float(A206.field1)

pawv = reform(PAWts,1,144)

;*****************the figure*******************************
xticks = ['Jun-05','Jun-06','Jun-07','Jun-08']
xtickvalues = [ 18, 54, 90, 126 ]
p2 = plot(PAWv, thick = 3, 'black', name = 'station-PAW', /overplot, $)
         xtickvalues = xtickvalues, $
         xtickname = xticks,$
         MARGIN = [0.15,0.2,0.15,0.1], $
         AXIS_STYLE=0, yminor = 0, xrange=[0,143])
yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='station-PAW (mm)', $
       TEXTPOS=1,tickfont_size=20, minor = 0, tickfont_name='times')
p1 = plot(A304*100, thick = 2, 'light grey', name = '60cm SM', xminor = 0, yminor = 0, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = xtickvalues, font_name='times',$
         xtickname = xticks,$
         YTITLE='SM (VWC%)',AXIS_STYLE=1,/CURRENT, xrange=[0,143],font_size=20)
!null = legend(target=[p1,p2], position=[0.2,0.3], font_size=14) ;
;***********************************************************
wet = where(finite(PAWv))
ok = where(finite(a206), complement=null)
a206(null) = 0.0173731

ok = where(finite(a203), complement=null)
a203(null) = 0.0391368

;not normalized
p1=plot(PAWv(wet),A103(wet)*100, '*', sym_size=3, xtitle = 'PAW (mm)', $
        ytitle = 'AG obs, wet season (%VWC)' , font_size=20)
p2=plot([-2.5,2.5],[-2.5,2.5], /overplot,xrange=[-2.5,2.5], yrange=[-2.5,2.5])
print, correlate(PAWv(wet),A203(wet));1_60cm=0.53,1_30cm=0.47, 3_40cm=0.18;2_60=0.31,2_30=0.39

;normally normalized...how do i gamma normalize this??
normpaw = (PAWv(wet)-mean(PAWv(wet), /nan))/stdev(PAWv(wet)) 
NORMA103 = (A103(WET)-MEAN(A103(WET), /NAN))/stdev(A103(wet[0:60]))
NORMA106 = (A106(WET)-MEAN(A106(WET), /NAN))/stdev(A106(wet))

print, correlate(normpaw,normA106);0.53
p1=plot(norma106,normpaw, '*', sym_size=3, xtitle = 'normalized AG-obs, wet season', $
        ytitle = 'normalized PAW' , font_size=20, xrange=[-2.5,2.5], yrange=[-2.5,2.5])
p2=plot([-2.5,2.5],[-2.5,2.5], /overplot,xrange=[-2.5,2.5], yrange=[-2.5,2.5])
;;;calculate the root mean sq error
err = mean((normpaw-norma106)^2)^0.5 & print, err
stderr = err/mean(norma106,/nan) & print, stderr ;very very small...

;*************************Wankama****************************
ifile = file_search('/jabber/chg-mcnally/AMMASOIL/AMMA2013/dekads/Wankama_sm_0.{1,4,7}*.csv')
pfile = file_search('/jabber/chg-mcnally/WKPAW_wfill_2006_2008_SOS.16.18.18.14_LGP10_WHC_PET.csv')

WK14 = read_csv(ifile[0])
WK47 = read_csv(ifile[1])
WK71 = read_csv(ifile[2])

sarray = transpose([[wk14.field1],[wk47.field1],[wk71.field1]]) & help, sarray
scube = reform(sarray*100,3,36,6)

paw = read_csv(pfile) 
pcube = transpose([[paw.field2], [paw.field3],[paw.field4]])
PAWTS = fltarr(36,3)
LGP=10
SOS = [18,18,14] 

for yr = 0,n_elements(SOS)-1 do begin &$
  start = 0  &$
  ph1 = SOS[yr]-2 & print, ph1  &$
  ph2 = SOS[yr]-1 & print, ph2 &$
  ph3 = SOS[yr]-1+LGP-1 & print, ph3 &$
  ph4 = SOS[yr]+LGP-1 & print, ph4 &$
  fin = 35  &$
  PAWTS[start:ph1,yr] = !values.f_nan  &$
  PAWTS[ph2:ph3,yr] = pcube[yr,*]  &$
  PAWTS[ph4:fin,yr] = !values.f_nan  &$
endfor

;pout = reform(pawts,108)
;ofile = strcompress('/jabber/chg-mcnally/WKPAW_complete_TS.csv', /remove_all)
;write_csv, ofile, pout

 xtickname = ['Jun-06', 'Jun-07','Jun-08']
 xtickvals = [0,36,72]+18
p2 = plot(reform(pawts,108), thick = 3, 'black', name = 'station PAW', /overplot, $)
         xtickvalues = xtickvals, $
         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct'],$
         MARGIN = [0.15,0.2,0.15,0.1], $
         AXIS_STYLE=0, yminor = 0, xrange=[0,107])
yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='station PAW (mm)', $
       TEXTPOS=1,tickfont_size=20, minor = 0)
p1 = plot(wk14.field1[0:108]*100, thick = 3, 'light grey', name = 'observed SM', xminor = 0, yminor = 0, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = xtickvals, font_name='times',$
         xtickname = xtickname,$
         YTITLE='SM',AXIS_STYLE=1,/CURRENT, xrange=[0,107])
lgr2 = LEGEND(TARGET=[p1, p2], font_size=16, font_name='times')
p1.xtickfont_size = 20
p1.ytickfont_size = 20
p1.ytitle='soil moisture (%VWC)'
p1.font_name='times'

;;;calculate the root mean sq error, but i'd have to normalize first.
PAWv = reform(PAWts,1,108)
wet = where(finite(PAWv))

normpaw = (PAWv(wet)-mean(PAWv(wet), /nan))/stdev(PAWv(wet)) 
normwk = (wk14.field1(wet)-mean(wk14.field1(wet), /nan))/stdev(wk14.field1(wet)) & print, normwk
;not normalized:
p1=plot(pawv(wet),wk14.field1(wet)*100, '*', sym_size=3, xtitle = 'PAW (mm)', $
        ytitle = 'WK obs wet season (%VWC)' , font_size=20)
p2=plot([0,250],[0,16], /overplot,xrange=[0,250], yrange=[0,16])
x = pawv(wet)
y = wk71.field1(wet)
print, correlate(x,y);wk14=0.849,wk47=0.854,wk71=0.66

;normally normalized:
;p1=plot(normwk[1:29],normpaw, '*', sym_size=3, xtitle = 'normalized wk-obs, wet season', $
;        ytitle = 'normalized PAW' , font_size=20, xrange=[-2.5,2.5], yrange=[-2.5,2.5])
;p2=plot([-2.5,2.5],[-2.5,2.5], /overplot,xrange=[-2.5,2.5], yrange=[-2.5,2.5])
;print, correlate(normpaw,normwk)
;;;calculate the root mean sq error
err = mean((normpaw-normwk)^2)^0.5 & print, err
stderr = err/mean(normwk,/nan) & print, stderr ;very very small...


;**********Belefougou, Benin******************
ifile = file_search('/jabber/chg-mcnally/AMMASOIL/AMMA2013/dekads/Belefoungou-Top_sm_{0.2,0.4,0.6}*.csv')
pfile = file_search('/jabber/chg-mcnally/BBPAW_2006_2008_SOS.12.10.9_LGP18_WHC119_PET.csv')

BB20 = read_csv(ifile[0])
BB40 = read_csv(ifile[1])
BB60 = read_csv(ifile[2])

sarray = transpose([[float(bb20.field1)],[float(bb40.field1)],[float(bb60.field1)]]) & help, sarray
scube = reform(sarray*100,3,36,4)

paw = read_csv(pfile) 
pcube = transpose([[paw.field1],[paw.field2], [paw.field3]])
PAWTS = fltarr(36,3)
LGP=18
SOS = [12,10,9] 

for yr = 0,n_elements(SOS)-1 do begin &$
  start = 0  &$
  ph1 = SOS[yr]-2 & print, ph1  &$
  ph2 = SOS[yr]-1 & print, ph2 &$
  ph3 = SOS[yr]-1+LGP-1 & print, ph3 &$
  ph4 = SOS[yr]+LGP-1 & print, ph4 &$
  fin = 35  &$
  PAWTS[start:ph1,yr] = !values.f_nan  &$
  PAWTS[ph2:ph3,yr] = pcube[yr,*]  &$
  PAWTS[ph4:fin,yr] = !values.f_nan  &$
endfor

;pout = reform(pawts,108)
;ofile = strcompress('/jabber/chg-mcnally/bbpaw_complete_ts.csv', /remove_all)
;write_csv, ofile, pout

 xtickname = ['Jun-06', 'Jun-07','Jun-08']
 xtickvals = [0,36,72]+18
p2 = plot(reform(pawts,108), thick = 3, 'black', name = 'station PAW', /overplot, $)
         xtickvalues = xtickvals, $
         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct'],$
         MARGIN = [0.15,0.2,0.15,0.1], $
         AXIS_STYLE=0, yminor = 0, xrange=[0,107])
yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='station PAW (mm)', $
       TEXTPOS=1,tickfont_size=20, minor = 0)
p1 = plot(sarray[2,0:107]*100, thick = 3, 'light grey', name = 'observed SM @60cm', xminor = 0, yminor = 0, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = xtickvals, font_name='times',$
         xtickname = xtickname,$
         YTITLE='SM',AXIS_STYLE=1,/CURRENT, xrange=[0,107])

lgr2 = LEGEND(TARGET=[p1, p2], font_size=16, font_name='times')
p1.xtickfont_size = 20
p1.ytickfont_size = 20
p1.ytitle='soil moisture (%VWC)'
p1.font_name='times'

;;;calculate the root mean sq error, but i'd have to normalize first.
PAWv = reform(PAWts,1,108)
wet = where(finite(PAWv))
Y = sarray[0,2:107]*100
;not normalized
p1=plot(PAWv(wet),Y(wet),  '*', sym_size=3, xtitle = 'PAW (mm)', $
        ytitle = 'BB obs, wet season (%VWC)' , font_size=20)
p2=plot([-2.5,2.5],[-2.5,2.5], /overplot,xrange=[-2.5,2.5], yrange=[-2.5,2.5])
print, correlate(PAWv(wet),Y(wet));60cm=0.7619(sarray2),40cm=0.787(sarray1),20cm=0.7666(sarray0)

normpaw = (PAWv(wet)-mean(PAWv(wet), /nan))/stdev(PAWv(wet)) 
normwk = (wk14.field1(wet)-mean(wk14.field1(wet), /nan))/stdev(wk14.field1(wet)) & print, normwk
p1=plot(normwk[1:29],normpaw, '*', sym_size=3, xtitle = 'normalized wk-obs, wet season', $
        ytitle = 'normalized PAW' , font_size=20, xrange=[-2.5,2.5], yrange=[-2.5,2.5])
p2=plot([-2.5,2.5],[-2.5,2.5], /overplot,xrange=[-2.5,2.5], yrange=[-2.5,2.5])
print, correlate(normpaw,normwk)
;;;calculate the root mean sq error
err = mean((normpaw-normwk)^2)^0.5 & print, err
stderr = err/mean(normwk,/nan) & print, stderr ;very very small...

;************FIGURE 5 --- COMPARE MEAN/STD etc for NPAW/RPAWA-- similar/same code below...*
;;*****************use this to make a mask for WRSI comparisons later**********************
;******FIGURE RE: RPAW AND NPAW WHOLE TS AND SCATTER********************
;7/5 replace NPAW with re-scaled NWET_dekads
rfile = file_search('/jabber/chg-mcnally/sahel_ubRFE_PAW36_2001-2012_LGP_WHC_PET.img')
;nfile = file_search('/jabber/chg-mcnally/sahel_NPAW_2001_2012_PET_DYNSOS.img');these two files match...
mfile = file_search('/jabber/chg-mcnally/cz_mask_sahel.img')
nfile = file_search('/jabber/chg-mcnally/NWET_scaled4WRSI.img');i guess in the rescaling proecess i lost all non-rpaw values?

test = file_search('/jabber/chg-mcnally/SM01_scaled4WRSI.img')
sm01 = fltarr(nx,250,36,11); 2001-2011
openr,1,test
readu,1,sm01
close,1
sm01=reform(sm01,nx,250,396)


nx = 720
ny = 350
nz = 431

maskgrid = fltarr(nx,ny)
npawgrid = fltarr(nx,ny,36,12)
rpawgrid = fltarr(nx,ny,36,12)

openr,1,mfile
readu,1,maskgrid
close,1

openr,1,rfile
readu,1,rpawgrid
close,1
rpawgrid = reform(rpawgrid,nx,ny,432)
rpawgrid(where(rpawgrid eq 0))=!values.f_nan

openr,1,nfile
readu,1,npawgrid
close,1
npawgrid = reform(npawgrid,nx,ny,432)
npawgrid(where(npawgrid eq 0))=!values.f_nan
;fill in the last value so i have full 12 yrs.
;pad = fltarr(nx,ny,1)
;pad[*,*,*]=!values.f_nan
;npawgrid = [[[npawgrid]],[[pad]]]

;why do i need to mask out npaw values?
;good = where(finite(rpawgrid), complement = null)
;npawgrid2 = npawgrid
;npawgrid2(null) = !values.f_nan
;rpawcube = reform(rpawgrid,nx,ny,36,12)
;npawcube = reform(npawgrid2,nx,ny,36,12)

;******correlate seasonal totals per Funk suggestion******
;ntot = total(npawcube,3,/nan)
;rtot = total(rpawcube,3,/nan)
;
;seasoncorr = fltarr(nx,ny,2)
;for x = 0,nx-1 do begin &$
;  for y = 0,ny-1 do begin &$
;    seasoncorr[x,y,*] = r_correlate(ntot[x,y,*],rtot[x,y,*]) &$
;  endfor &$
;endfor
;
;p1 = image(seasoncorr[*,*,0], RGB_TABLE=5,image_dimensions=[72.0,35.0], image_location=[-20,-5], $ 
; min_value=-1, max_value=0.5, dimensions=[nx/100,ny/100])
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07], font_size=20)
;  p1.title = 'Significant rank correlation between seasonal total NPAW and seasonal total RPAW'
;  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 52], /overplot) &$
;  p1.mapgrid.linestyle = 'dotted' &$
;  p1.mapgrid.color = [150, 150, 150] &$
;  p1.mapgrid.label_position = 0 &$
;  p1.mapgrid.label_color = 'black' &$
;  p1.mapgrid.FONT_SIZE = 12 &$
;  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])   
;
;v = reform(seasoncorr[*,*,1],long(nx)*long(ny))
;sig = where(v lt 0.05)
;v2 = reform(seasoncorr[*,*,0],long(nx)*long(ny))
;sig2=v2(sig)
;********************************************************
;compare R-PAW with N-PAW by looking at the difference between the means
good = where(finite(rpawgrid), complement = null)
NPAWgrid(null) = !values.f_nan
diff = mean(npawgrid, dimension=3, /nan)-mean(rpawgrid, dimension=3, /nan)

;***to check the correlation also null out the NPAWgrid values in RPAWgrid
good = where(finite(npawgrid), complement = null)
RPAWgrid(null) = !values.f_nan
ncolors=256   

  p1 = image(diff, RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),image_dimensions=[72.0,35.0], image_location=[-20,-5], $ 
             dimensions=[nx/100,ny/100],title = 'mean diff') &$ 
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20) &$
  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 52], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

;****make a mask for the WRSI comparisons*****
mask = diff
null = where(diff gt 15 OR diff lt -15)
mask(null) = -999.0
good = where(mask gt 0)
mask(good) = 1
;ofile = '/jabber/chg-mcnally/WRSI_compare_mask.img'
;openw,1,ofile
;writeu,1,mask
;close,1
;********************FIGURE 6 for Agoufou*************************
;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5.) / 0.10)

xticks = ['2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011','2012']
xtickinterval = 36
xtickvalues = [ 36,      72 ,    108  ,   144  ,   180 ,    216   ,  252   ,  288  ,   324  ,   360  ,   396  ,   432 ]-18
p1=plot(rpawgrid[axind,ayind,*], thick = 3)
p2=plot(npawgrid[axind,ayind,*], /overplot,'g', xrange = [0,431], font_name='times', font_size=14, $
        xtickinterval=xtickinterval)
p2.ytitle = 'plant avail. water (mm)'
p2.xminor = 0
p2.yminor = 0
p2.xtickname = xticks
p2.xtickvalues = xtickvalues
p2.ytickfont_size=20

;******Agoufou inset scatterplot*************************
good = where(finite(rpawgrid[axind,ayind,*]) AND rpawgrid[axind,ayind,*] gt 0)

;these are all very close to the mean, is that why i was standardizing before? try after coffee....
p3 = plot(rpawgrid[axind,ayind,good],npawgrid[axind,ayind,good],'*',sym_size=2, xrange=[0,140], yrange=[0,140],$
          xtitle = 'R-PAW (mm)', ytitle='N-PAW (mm)')
p4 = plot([0,150],[0,150], /overplot, xminor=0, yminor=0)
p3.ytickfont_size=20
p3.xtickfont_size=20
print, correlate(rpawgrid[axind,ayind,good],npawgrid[axind,ayind,good]);0.34

;normrpaw = (rpawgrid[axind,ayind,good]-mean(rpawgrid[axind,ayind,good], /nan))/stdev(rpawgrid[axind,ayind,good]) 
;normnpaw = (npawgrid[axind,ayind,good]-mean(npawgrid[axind,ayind,good], /nan))/stdev(npawgrid[axind,ayind,good]) 
;print, correlate(normrpaw,normnpaw);0.33
;p3=plot(normrpaw,normnpaw,'*',sym_size=2,xrange = [-3,3], yrange=[-3,3],$
;        xminor=0,yminor=0)
;p4=plot([-3,3],[-3,3], /overplot)
;p4.xtitle = 'normalized AG-obs, wet season'
;p4.ytitle = 'normalized PAW' 
;***********************FIGURE X WANKAMA RPAW-NPAW time series*****************
good = where(finite(rpawgrid[wxind,wyind,*]))

wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;xticks = ['Jun-05','Jun-06','Jun-07','Jun-08']
xticks = ['2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011','2012']
xtickinterval = 36
xtickvalues = [ 36,      72 ,    108  ,   144  ,   180 ,    216   ,  252   ,  288  ,   324  ,   360  ,   396  ,   432 ]-18
p1=plot(rpawgrid[wxind,wyind,*], thick = 3)
p2=plot(npawgrid[wxind,wyind,*], /overplot,'g', xrange = [0,431], font_name='times', font_size=14, $
        xtickinterval=xtickinterval)
p2.ytitle = 'plant avail. water (mm)'
p2.xminor = 0
p2.yminor = 0
p2.xtickname = xticks
p2.xtickvalues = xtickvalues
p2.ytickfont_size=20

;******Wankama inset scatterplot*************************
good = where(finite(rpawgrid[wxind,wyind,*]))

;these are all very close to the mean, is that why i was standardizing before? try after coffee....
p3 = plot(rpawgrid[wxind,wyind,good],npawgrid[wxind,wyind,good],'*',sym_size=2,xrange=[0,200], yrange=[0,200])
p4 = plot([0,250],[0,250], /overplot, xminor=0, yminor=0)
p4.ytitle = 'N-PAW (mm)'
p4.xtitle = 'R-PAW (mm)'
p4.font_size=20
;normrpaw = (rpawgrid[wxind,wyind,good]-mean(rpawgrid[wxind,wyind,good], /nan))/stdev(rpawgrid[wxind,wyind,good]) 
;normnpaw = (npawgrid[wxind,wyind,good]-mean(npawgrid[wxind,wyind,good], /nan))/stdev(npawgrid[wxind,wyind,good]) 
;
;print, correlate(normrpaw,normnpaw);0.46
;print, correlate(rpawgrid[wxind,wyind,good],npawgrid[wxind,wyind,good]);0.45
;
;p3=plot(normrpaw,normnpaw,'*',sym_size=2,xrange = [-3,3], yrange=[-3,3],$
;        xminor=0,yminor=0)
;p4=plot([-3,3],[-3,3], /overplot)
;p4.xtitle = 'normalized WK-obs, wet season'
;p4.ytitle = 'normalized PAW' 

;****************FIGURE 7 for Belefoungou****************
;Belefoungou-Top 9.79506     1.71450  
bxind = FLOOR((1.7145 + 20.) / 0.10)
byind = FLOOR((9.79506 + 5) / 0.10)
xticks = ['2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011','2012']
xtickinterval = 36
xtickvalues = [ 36,      72 ,    108  ,   144  ,   180 ,    216   ,  252   ,  288  ,   324  ,   360  ,   396  ,   432 ]-18
p1=plot(rpawgrid[bxind,byind,*], thick = 3)
p2=plot(npawgrid[bxind,byind,*], /overplot,'g', xrange = [0,431], font_name='times', font_size=14, $
        xtickinterval=xtickinterval)
p2.ytitle = 'plant avail. water (mm)'
p2.xminor = 0
p2.yminor = 0
p2.xtickname = xticks
p2.xtickvalues = xtickvalues
p2.font_size=20

wet=where(finite(rpawgrid[bxind,byind,*]))
p1=plot(rpawgrid[bxind,byind,wet],npawgrid[bxind,byind,wet],'*',sym_size=2, xrange=[0,300], yrange=[0,300])
p2=plot([0,300],[0,300], /overplot)
p2.xminor = 0
p2.yminor = 0
p2.ytitle = 'N-PAW (mm)'
p2.xtitle = 'R-PAW (mm)'


print, correlate(rpawgrid[bxind,byind,wet],npawgrid[bxind,byind,wet]);0.386


;*****************NEW figure 6,7,8**********************************
;*********keep the scatter plots above******************************
ifile = file_search('/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/sahel/data.{2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012}*img')

nx = 720
ny = 350
nz = n_elements(ifile)
;nz = 36

ingrid = fltarr(nx,ny)
ndvi = fltarr(nx,ny,nz)

for f = 0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[f] &$
  readu,1,ingrid &$
  close,1 &$
  ndvi[*,*,f] = ingrid &$
endfor 

;replace rpaw with ECV_microwave....
;rfile = file_search('/jabber/chg-mcnally/sahel_ubRFE_PAW36_2001-2012_LGP_WHC_PET.img')
rfile =  '/jabber/chg-mcnally/ECV_microwaveSM_dekadal.2001.2010.img'
;nfile = file_search('/jabber/chg-mcnally/sahel_NPAW_2001_2012_PET_DYNSOS.img');these two files match..
nfile = '/jabber/chg-mcnally/sahel_NSM_microwave.img'
nx = 720
ny = 350
nz = 431

npawgrid = fltarr(nx,ny,nz)
;rpawgrid = fltarr(nx,ny,36,12)
rpawgrid = fltarr(nx,ny,36,10)

openr,1,rfile
readu,1,rpawgrid
close,1
;rpawgrid = reform(rpawgrid,nx,ny,432)
rpawgrid = reform(rpawgrid,nx,ny,360)
rpawgrid(where(rpawgrid eq 0))=!values.f_nan

openr,1,nfile
readu,1,npawgrid
close,1

pad = fltarr(nx,ny,1)
pad[*,*,*]=!values.f_nan
npawgrid = [[[npawgrid]],[[pad]]]


;a = mean(ndvi,dimension=3,/nan)
;Wankama 2006 - 2011
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5.) / 0.10)

;Belefoungou-Top 9.79506     1.71450  
bxind = FLOOR((1.7145 + 20.) / 0.10)
byind = FLOOR((9.79506 + 5) / 0.10)

;********remake the NWET vs ECV_SM scatter********************
p1=plot(npawgrid[bxind,byind,*]*0.0001,rpawgrid[bxind,byind,*]*0.0001, '*')
p1.xrange=[0.05,0.25]
p1.yrange=[0.05,0.25]
p1.ytitle = 'microwave sm (m3/m3)'
p1.xtitle = 'ndvi derived sm (m3/m3)'
p1.title = 'Belefougou, Benin Soil moisture 2001-2010'
;*************************************************************
ndvi36 = reform(ndvi,nx,ny,36,12)
npaw36 = reform(npawgrid,nx,ny,36,12)
rpaw36 = reform(rpawgrid,nx,ny,36,10)

aveg = mean(ndvi36[axind,ayind,*,*], dimension=4,/nan)
wveg = mean(ndvi36[wxind,wyind,*,*], dimension=4,/nan)
bveg = mean(ndvi36[bxind,byind,*,*], dimension=4,/nan)

arpaw = mean(rpaw36[axind,ayind,*,*], dimension=4,/nan)
wrpaw = mean(rpaw36[wxind,wyind,*,*], dimension=4,/nan)
brpaw = mean(rpaw36[bxind,byind,*,*], dimension=4,/nan)

anpaw = mean(npaw36[axind,ayind,*,*], dimension=4,/nan)
wnpaw = mean(npaw36[wxind,wyind,*,*], dimension=4,/nan)
bnpaw = mean(npaw36[bxind,byind,*,*], dimension=4,/nan)

;does this look ok?
p1 = image(total(nswb,3, /nan), rgb_table=20)
 c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])

;********************AG,MALI***************************************
xtickvalues=[0, 5, 10, 15, 20, 25, 30, 35]+2
xtickname = ['11-Jan' , '1-Mar', '21-Apr', '11-Jun','1-Aug', '21-Sep',  '11-Nov', '1-Jan']
p2 = plot(aveg, thick = 3, 'black', name = 'AG NDVI', /overplot, $
         xtickvalues = xtickvalues, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         AXIS_STYLE=0, yminor = 0)
yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='NDVI', $
       TEXTPOS=1,tickfont_size=20, minor = 0, tickfont_name='times')
p1 = plot(anpaw*0.0001, thick = 3, 'light grey', name = 'N-WET', xminor = 0, yminor = 0, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = xtickvalues, font_name='times',$
         YTITLE='soil wetness m3/m3',AXIS_STYLE=1,/CURRENT, xrange=[0,MAX(p2.xrange)],font_size=20)
p3 = plot(arpaw*0.0001, thick = 2, 'orange', name = 'ECV_SM', /overplot)
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) ;
p3.xtickname=xtickname
;*******************WK, NIGER*************************************************
xtickvalues=[0, 5, 10, 15, 20, 25, 30, 35]+2
xtickname = ['11-Jan' , '1-Mar', '21-Apr', '11-Jun','1-Aug', '21-Sep',  '11-Nov', '1-Jan']
p2 = plot(wveg, thick = 3, 'black', name = 'WK NDVI', /overplot, $
         xtickvalues = xtickvalues, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         AXIS_STYLE=0, yminor = 0)
yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='NDVI', $
       TEXTPOS=1,tickfont_size=20, minor = 0, tickfont_name='times')
p1 = plot(wnpaw*0.0001, thick = 3, 'light grey', name = 'N-WET', xminor = 0, yminor = 0, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = xtickvalues, font_name='times',$
         YTITLE='soil wetness m3/m3',AXIS_STYLE=1,/CURRENT, xrange=[0,MAX(p2.xrange)],font_size=20)
p3 = plot(wrpaw*0.0001, thick = 2, 'orange', name = 'ECV_SM', /overplot)
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) ;
p3.xtickname=xtickname
;*******************BT, BENIN*************************************************
xtickvalues=[0, 5, 10, 15, 20, 25, 30, 35]+2
xtickname = ['11-Jan' , '1-Mar', '21-Apr', '11-Jun','1-Aug', '21-Sep',  '11-Nov', '1-Jan']
p2 = plot(bveg, thick = 3, 'black', name = 'BB NDVI', /overplot, $
         xtickvalues = xtickvalues, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         AXIS_STYLE=0, yminor = 0)
yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='NDVI', $
       TEXTPOS=1,tickfont_size=20, minor = 0, tickfont_name='times')
p1 = plot(bnpaw*0.0001, thick = 3, 'light grey', name = 'N-WET', xminor = 0, yminor = 0, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = xtickvalues, font_name='times',$
         YTITLE='soil wetness m3/m3',AXIS_STYLE=1,/CURRENT, xrange=[0,MAX(p2.xrange)],font_size=20)
p3 = plot(brpaw*0.0001, thick = 2, 'orange', name = 'ECV_SM', /overplot)
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) ;
p3.xtickname=xtickname

;*********************WRSI FIGURES*********************
;***plot the N-WRSI, R-WRSI for Wankama and Agoufou****
;this will require some investigation....not sure why everything at Agoufou is 100...
;rfile = file_search('/jabber/chg-mcnally/EOS_WRSI_ubRFE2001_2012v2.img'); some seasons didn't evenstart WTF?
rfile = file_search('/jabber/chg-mcnally/EOS_WRSI_ubRFE2001_2012vPETv2.img') ;EOS_WRSI_NDVI2001_2012vPETv2.img
nfile = file_search('/jabber/chg-mcnally/EOS_WRSI_NDVI2001_2012vPETv2.img')
lfile = file_search('/jabber/chg-mcnally/EOS_WRSI_SM01_2001_2012.img')
mfile = file_search('/jabber/chg-mcnally/WRSI_compare_mask.img')
cfile = file_search('/jabber/chg-mcnally/cz_mask_sahel.img')

nx = 720
ny = 350
nz = 12

cgrid = fltarr(nx,ny)
mgrid = fltarr(nx,ny)
lgrid = fltarr(nx,ny,nz)
rgrid = fltarr(nx,ny,nz)
ngrid = fltarr(nx,ny,nz)

mrgrid = fltarr(nx,ny,nz);masked version
mngrid = fltarr(nx,ny,nz);masked versions
mlgrid = fltarr(nx,ny,nz)

openr,1,cfile
readu,1,cgrid
close,1

openr,1,mfile
readu,1,mgrid
close,1

openr,1,rfile
readu,1,rgrid
close,1
 
openr,1,nfile
readu,1,ngrid
close,1

openr,1,lfile
readu,1,lgrid
close,1
;show the cropped areas by country
  p1 = image(cgrid,image_dimensions=[72.0,35.0], image_location=[-20,-5], $ 
             dimensions=[nx/100,ny/100],title = 'crop zones', rgb_table=27) &$ 
  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

;mask out areas where rpaw and npaw are toooo different and use these for the annual comparisons.
for i = 0, nz-1 do begin &$
  mrgrid[*,*,i] = mgrid*rgrid[*,*,i] &$
  mngrid[*,*,i] = mgrid*ngrid[*,*,i] &$
  mlgrid[*,*,i] = mgrid*lgrid[*,*,i] &$
endfor

mngrid(where(mngrid lt 0)) = !values.f_nan
mrgrid(where(mrgrid lt 0)) = !values.f_nan
mlgrid(where(mlgrid lt 0)) = !values.f_nan

;********looking at points...*********************
;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5.) / 0.10)

wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)
;xticks = ['2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011']
p1 = plot(rgrid[wxind,wyind,0:10],'b', thick=2, name = 'WK R-WRSI')
p2 = plot(ngrid[wxind,wyind,0:10],'g', /overplot, thick=2, name = 'WK N-WRSI')
;p3 = plot(rgrid[axind,ayind,0:10],'red', thick=3,/overplot, name = 'AG R-WRSI')
;p4 = plot(ngrid[axind,ayind,0:10],'orange', /overplot, yrange=[85,105], thick=2,name = 'AG N-WRSI',$
;          xtickname=xticks, xminor=0,yminor=0, font_name='times',$
;          font_size=18)
;!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=14) ;
;****************************************************
;****************looking at countries**6/11/2013**************************
NigerWRSI = fltarr(3,n_elements(mngrid[0,0,*]))
SenegalWRSI = fltarr(3,n_elements(mngrid[0,0,*]))
MaliWRSI = fltarr(3,n_elements(mngrid[0,0,*]))
BurkinaWRSI = fltarr(3,n_elements(mngrid[0,0,*]))
ChadWRSI = fltarr(3,n_elements(mngrid[0,0,*]))

; ['Niger (1000)', 'Senegal(1001)', 'Mali'(1002), 'Burkina_Faso', 'Chad', 'Sudan', 'South_Sudan'] (over on Rain....)
; I should put them in alphabetical order...they are for yields[Burkina Faso  Chad  Mali  Niger Senegal]

;read in yields data:
yfile = file_search('/jabber/chg-mcnally/millet_yields_6_11_2013.csv')
buffer = read_csv(yfile) ; 2000-2011
bfyield = buffer.field1
cyield = buffer.field2
myield = buffer.field3
nyield = buffer.field4
syield = buffer.field5

;remove trend from yield data...from Greg's code:
yield_mat = transpose([[bfyield],[cyield], [myield],[nyield],[syield]]) & help, yield_mat
trend = fltarr(n_elements(yield_mat[*,0]))
yld2 = FLTARR(SIZE(yield_mat,/DIMENSIONS)) * !VALUES.F_NAN

;use the detrended yields instead....
for i=0,n_elements(trend)-1 do begin &$
  yrind = WHERE(FINITE(yield_mat[i,*]),count) &$
  trend[i] = REGRESS(yrind,REFORM(yield_mat[i,yrind],count),yfit = tmp_est) &$
  yld2[i,yrind] = yield_mat[i,yrind] - tmp_est &$
endfor

burkina = where(cgrid eq 1, count) & print, count
chad = where(cgrid eq 2, count) & print, count
mali = where(cgrid eq 3, count) & print, count
niger = where(cgrid eq 4, count) & print, count
senegal = where(cgrid eq 5, count) & print, count

;sudan = where(cgrid eq 1005, count) & print, count
;southsudan = where(cgrid eq 1006, count) & print, count ;oops did i not rerun this? ignore sudan for now.

;rain  then NDVI
for i = 0,n_elements(mngrid[0,0,*])-1 do begin &$
    nyrgrid = mngrid[*,*,i] &$
    ryrgrid = mrgrid[*,*,i] &$
    lyrgrid = mlgrid[*,*,i] &$
    NigerWRSI[*,i] =  [mean(ryrgrid(niger), /nan),mean(nyrgrid(niger), /nan),mean(lyrgrid(niger), /nan)] &$
    SenegalWRSI[*,i] =  [mean(ryrgrid(senegal), /nan),mean(nyrgrid(senegal), /nan),mean(lyrgrid(senegal), /nan)] &$
    MaliWRSI[*,i] =  [mean(ryrgrid(mali), /nan),mean(nyrgrid(mali), /nan),mean(lyrgrid(mali), /nan)] &$
    BurkinaWRSI[*,i] =  [mean(ryrgrid(burkina), /nan),mean(nyrgrid(burkina), /nan),mean(lyrgrid(burkina), /nan)] &$
    ChadWRSI[*,i] =  [mean(ryrgrid(chad), /nan),mean(nyrgrid(chad), /nan),mean(lyrgrid(chad), /nan)] &$   
endfor;i
  xticks = ['2001', '2002', '2003', '2004', '2005', '2006', '2007', '2008', '2009', '2010', '2011']
  xtickvalues = [0,1,2,3,4,5,6,7,8,9,10]

;**************burkina faso*************************************
;byanom = bfyield[1:11]-mean(bfyield[1:11])
brwanom = BurkinaWRSI[0,0:10]-mean(BurkinaWRSI[0,0:10])
bnwanom = BurkinaWRSI[1,0:10]-mean(BurkinaWRSI[1,0:10])
blwanom = BurkinaWRSI[2,0:10]-mean(BurkinaWRSI[2,0:10])

print, r_correlate(yld2[0,1:11],brwanom);0.52*
print, r_correlate(yld2[0,1:11],bnwanom);0.73**
print, r_correlate(yld2[0,1:11],blwanom);0.59*

p1 = plot(brwanom/stdev(brwanom),yld2[0,1:11]/stdev(yld2[0,1:11]),'o',sym_size=2)
p2 = plot(bnwanom/stdev(bnwanom),yld2[0,1:11]/stdev(yld2[0,1:11]),'go',/overplot, sym_size=2,/SYM_FILLED,$
          yminor=0, xminor=0,font_name='times', ytitle='yield anomaly',$ 
          xtitle = 'WRSI anomaly')
p2.xrange=[-3,3]
p2.yrange=[-3,3]
p1.title = 'Burkina Faso: R-WRSI (0.52*), N-WRSI (0.73**)'
p1.font_size = 20
p3=plot([0,0],[-3,3],/overplot)
p3=plot([-3,3],[0,0],/overplot)


;p2 = plot(byanom, thick = 3, 'black', name = 'Yield anom', /overplot, $
;         xtickvalues = xtickvalues, $
;         MARGIN = [0.15,0.2,0.15,0.1], $
;         AXIS_STYLE=0, yminor = 0, yrange = [-1500,1500])
;yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='Yield anomaly (Hg/Ha)', $
;       TEXTPOS=1,tickfont_size=20, minor = 0, tickfont_name='times')
;p1 = plot(brwanom, thick = 3, 'light grey', name = 'R-WRSI anom, r=0.51', xminor = 0, yminor = 0, $
;         MARGIN = [0.15,0.2,0.15,0.1], $
;         xtickvalues = xtickvalues, font_name='times',$
;         YTITLE='WRSI anomaly',AXIS_STYLE=1,/CURRENT, xrange=[0,MAX(p2.xrange)],font_size=20)
;p3 = plot(bnwanom, thick = 2, 'green', name = 'N-WRSI anom, r=0.45', /overplot,yrange=[-10,10])
;!null = legend(target=[p1,p3,p2], position=[0.2,0.3], font_size=14) ;
;p3.xtickname=xticks

;****CHAD**WOWY**************
;cyanom = cyield[1:11]-mean(cyield[1:11])
crwanom = ChadWRSI[0,0:10]-mean(ChadWRSI[0,0:10])
cnwanom = ChadWRSI[1,0:10]-mean(ChadWRSI[1,0:10])
clwanom = ChadWRSI[2,0:10]-mean(ChadWRSI[2,0:10])

print, r_correlate(yld2[1,1:11],crwanom);45
print, r_correlate(yld2[1,1:11],cnwanom);18
print, r_correlate(yld2[2,1:11],clwanom);55*


p1 = plot(crwanom/stdev(crwanom),yld2[1,1:11]/stdev(yld2[1,1:11]),'o',sym_size=2)
p2 = plot(cnwanom/stdev(cnwanom),yld2[1,1:11]/stdev(yld2[1,1:11]),'go',/overplot, sym_size=2,/SYM_FILLED, $
          yminor=0, xminor=0,font_name='times', ytitle='yield anomaly',$ 
          xtitle = 'WRSI anomaly')
p2.xrange=[-3,3]
p2.yrange=[-3,3]
p1.title = 'Chad: R-WRSI (0.45), N-WRSI (0.18)'
p1.font_size = 20
p3=plot([0,0],[-3,3],/overplot)
p3=plot([-3,3],[0,0],/overplot)


;p2 = plot(cyanom, thick = 3, 'black', name = 'Yield anom', /overplot, $
;         xtickvalues = xtickvalues, $
;         MARGIN = [0.15,0.2,0.15,0.1], $
;         AXIS_STYLE=0, yminor = 0)
;yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='Yield anomaly (Hg/Ha)', $
;       TEXTPOS=1,tickfont_size=20, minor = 0, tickfont_name='times')
;p1 = plot(crwanom, thick = 3, 'light grey', name = 'R-WRSI anom, r=0.45', xminor = 0, yminor = 0, $
;         MARGIN = [0.15,0.2,0.15,0.1], $
;         xtickvalues = xtickvalues, font_name='times',$
;         YTITLE='WRSI anomaly',AXIS_STYLE=1,/CURRENT, xrange=[0,MAX(p2.xrange)],font_size=20)
;p3 = plot(cnwanom, thick = 2, 'green', name = 'N-WRSI anom, r=0.85', /overplot, yrange=[-15,15])
;!null = legend(target=[p1,p3,p2], position=[0.2,0.3], font_size=14) ;
;p3.xtickname=xticks



;*******WHOOT -- Mali************
;myanom = myield[1:11]-mean(myield[1:11])
mrwanom = MaliWRSI[0,0:10]-mean(MaliWRSI[0,0:10])
mnwanom = MaliWRSI[1,0:10]-mean(MaliWRSI[1,0:10])
mlwanom = MaliWRSI[2,0:10]-mean(MaliWRSI[2,0:10])

print, r_correlate(yld2[2,1:11],mrwanom);0.65**
print, r_correlate(yld2[2,1:11],mnwanom);0.73**
print, r_correlate(yld2[2,1:11],mlwanom);0.80**

p1 = plot(mrwanom/stdev(mrwanom),yld2[2,1:11]/stdev(yld2[2,1:11]),'o',sym_size=2)
p2 = plot(mnwanom/stdev(mnwanom),yld2[2,1:11]/stdev(yld2[2,1:11]),'go',/overplot, sym_size=2,/SYM_FILLED, $
          yminor=0, xminor=0,font_name='times', ytitle='yield anomaly',$ 
          xtitle = 'WRSI anomaly')
p2.xrange=[-3,3]
p2.yrange=[-3,3]
p1.title = 'Mali: R-WRSI (0.65**), N-WRSI (0.73**)'
p1.font_size = 20
p3=plot([0,0],[-3,3],/overplot)
p3=plot([-3,3],[0,0],/overplot)

;p2 = plot(myanom/1000, thick = 3, 'black', name = 'Yield anom', /overplot, $
;         xtickvalues = xtickvalues, $
;         MARGIN = [0.15,0.2,0.15,0.1], $
;         AXIS_STYLE=0, yminor = 0, yrange =[-3,3])
;yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='Yield anomaly/1000 (Hg/Ha)', $
;       TEXTPOS=1,tickfont_size=20, minor = 0, tickfont_name='times')
;p1 = plot(mrwanom, thick = 3, 'light grey', name = 'R-WRSI anom, r=0.45', xminor = 0, yminor = 0, $
;         MARGIN = [0.15,0.2,0.15,0.1], $
;         xtickvalues = xtickvalues, font_name='times',$
;         YTITLE='WRSI anomaly',AXIS_STYLE=1,/CURRENT, xrange=[0,MAX(p2.xrange)],font_size=20)
;p3 = plot(mnwanom, thick = 2, 'green', name = 'N-WRSI anom, r=0.56', /overplot,yrange=[-10,10])
;!null = legend(target=[p1,p3,p2], position=[0.2,0.3], font_size=14) ;
;p3.xtickname=xticks
  
  ;*******************NIGER************************** 
;b=0,c=1,m=2,n=3,s=4
;nyanom = nyield[1:11]-mean(nyield[1:11])
nrwanom = NigerWRSI[0,0:10]-mean(NigerWRSI[0,0:10])
nnwanom = NigerWRSI[1,0:10]-mean(NigerWRSI[1,0:10])
nlwanom = NigerWRSI[2,0:10]-mean(NigerWRSI[2,0:10])

print, r_correlate(yld2[3,1:11],nrwanom);0.47
print, r_correlate(yld2[3,1:11],nnwanom);0.62
print, r_correlate(yld2[3,1:11],nlwanom);0.57


;p2 = plot(yld2[3,1:11], thick = 3, 'black', name = 'Yield anom', /overplot, $
;         xtickvalues = xtickvalues, $
;         MARGIN = [0.15,0.2,0.15,0.1], $
;         AXIS_STYLE=0, yminor = 0)
;yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='Yield anomaly (Hg/Ha)', $
;       TEXTPOS=1,tickfont_size=20, minor = 0, tickfont_name='times')
;p1 = plot(nrwanom, thick = 3, 'light grey', name = 'R-WRSI anom, r=0.52*', xminor = 0, yminor = 0, $
;         MARGIN = [0.15,0.2,0.15,0.1], $
;         xtickvalues = xtickvalues, font_name='times',$
;         YTITLE='WRSI anomaly',AXIS_STYLE=1,/CURRENT, xrange=[0,MAX(p2.xrange)],font_size=20)
;p3 = plot(nnwanom, thick = 2, 'g', name = 'N-WRSI anom, r=0.58*', /overplot, yrange=[-15,15])
;!null = legend(target=[p1,p3,p2], position=[0.2,0.3], font_size=14) ;
;p3.xtickname=xticks

;and chris's scatterplot
p1 = plot(nrwanom/stdev(nrwanom),yld2[3,1:11]/stdev(yld2[3,1:11]),'o',sym_size=2)
p2 = plot(nnwanom/stdev(nnwanom),yld2[3,1:11]/stdev(yld2[3,1:11]),'go', /overplot, sym_size=2,/SYM_FILLED, $
          yminor=0, xminor=0, font_size=20, font_name='times', ytitle='yield anomaly',$ 
          xtitle = 'WRSI anomaly')
p2.xrange=[-3,3]
p2.yrange=[-3,3]
p1.title = 'Niger: R-WRSI (0.47), N-WRSI (0.63**)'
p1.font_size = 20
p3=plot([0,0],[-3,3],/overplot)
p3=plot([-3,3],[0,0],/overplot)
;***********************************************
;WHOOT --Senegal
;syanom = syield[1:11]-mean(syield[1:11])
srwanom = SenegalWRSI[0,0:10]-mean(SenegalWRSI[0,0:10])
snwanom = SenegalWRSI[1,0:10]-mean(SenegalWRSI[1,0:10])
slwanom = SenegalWRSI[2,0:10]-mean(SenegalWRSI[2,0:10])

print, r_correlate(yld2[4,1:11],srwanom);0.73 (0.011)
print, r_correlate(yld2[4,1:11],snwanom);0.9  (0.00)
print, r_correlate(yld2[4,1:11],slwanom);0.79  (0.003)


;p2 = plot(syanom, thick = 3, 'black', name = 'Yield anom', /overplot, $
;         xtickvalues = xtickvalues, $
;         MARGIN = [0.15,0.2,0.15,0.1], $
;         AXIS_STYLE=0, yminor = 0)
;yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='Yield anomaly (Hg/Ha)', $
;       TEXTPOS=1,tickfont_size=20, minor = 0, tickfont_name='times')
;p1 = plot(srwanom, thick = 3, 'light grey', name = 'R-WRSI anom, r=0.73', xminor = 0, yminor = 0, $
;         MARGIN = [0.15,0.2,0.15,0.1], $
;         xtickvalues = xtickvalues, font_name='times',$
;         YTITLE='WRSI anomaly',AXIS_STYLE=1,/CURRENT, xrange=[0,MAX(p2.xrange)],font_size=20)
;p3 = plot(snwanom, thick = 2, 'green', name = 'N-WRSI anom, r=0.86', /overplot, yrange=[-40,40])
;!null = legend(target=[p1,p3,p2], position=[0.2,0.3], font_size=14) ;
;p3.xtickname=xticks

;and chris's scatterplot
p1 = plot(srwanom/stdev(srwanom),yld2[4,1:11]/stdev(yld2[4,1:11]),'o',sym_size=2, name='__R-WRSI std anom')
p2 = plot(snwanom/stdev(snwanom),yld2[4,1:11]/stdev(yld2[4,1:11]),'go', /overplot, sym_size=2,/SYM_FILLED, $
          yminor=0, xminor=0, font_size=20, font_name='times', ytitle='yield anomaly',$ 
          xtitle = 'WRSI anomaly', name='__N-WRSI std anom')
p2.xrange=[-3,3]
p2.yrange=[-3,3]
p1.title = 'Senegal: R-WRSI (0.73**), N-WRSI (0.9**)'
p1.font_size = 20
p3=plot([0,0],[-3,3],/overplot)
p3=plot([-3,3],[0,0],/overplot)
!null = legend(target=[p1,p2], position=[0.2,0.3], font_size=12) ;





;checkum out, still not toatally sure why i lose a whole yr of NDVI. 
mmngrid = mean(mngrid[*,*,0:10],dimension=3,/nan)
mmngrid(where(mmngrid lt 50))=!values.f_nan

mmrgrid = mean(mrgrid[*,*,0:10],dimension=3,/nan)
mmrgrid(where(mmrgrid lt 50))=!values.f_nan

mdiff = mmngrid-mmrgrid
mdiff(where(mdiff gt 20 OR mdiff lt -20))=!values.f_nan
;****for the nice WRSI looking map*******************
p1 = image(byte(mmngrid), image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
            RGB_TABLE=make_wrsi_cmap(), title = 'mean (2001-2011) N-WRSI')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

;***************for the difference map, use the cmap color table*****************
ncolors=256   

  p1 = image(mdiff, RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),image_dimensions=[72.0,35.0], image_location=[-20,-5], $ 
             dimensions=[nx/100,ny/100],title = 'mean diff', min_value = -20, max_value=20) &$ 
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20) &$
  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 52], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

;**********************************************************************************
;***********************start checking out the anomalies year by year**************
;**********************************************************************************
rfile = file_search('/jabber/chg-mcnally/EOS_WRSI_ubRFE2001_2012vPETv2.img') 
nfile = file_search('/jabber/chg-mcnally/EOS_WRSI_NDVI2001_2012vPETv2.img')

nx = 720
ny = 350
nz = 12

rgrid = fltarr(nx,ny,nz)
ngrid = fltarr(nx,ny,nz)

openr,1,rfile
readu,1,rgrid
close,1

openr,1,nfile
readu,1,ngrid
close,1

nanom = fltarr(nx,ny,11)
nm=fltarr(11)
rm=fltarr(11)
for i = 0,10 do begin &$
  nanom[*,*,i] = mngrid[*,*,i]-mean(mngrid[*,*,0:10], dimension=3,/nan) &$
  nm[i] = mean(nanom[*,*,i],/nan) &$
endfor  

ranom = fltarr(nx,ny,11)
for i = 0,10 do begin &$
  ranom[*,*,i] = mrgrid[*,*,i]-mean(mrgrid[*,*,0:10], dimension=3,/nan) &$
   rm[i] = mean(ranom[*,*,i],/nan) &$
endfor  
;***make a nice barplot, not in excel :) ********
nbars = 2
colors = ['blue', 'green']
data = [[rm],[nm]]

  index = 0
  xticks = ['2001', '2002', '2003', '2004', '2005', '2006', '2007', '2008', '2009', '2010', '2011']
  xtickvalues = [0,1,2,3,4,5,6,7,8,9,10]
   b1 = barplot(rm/stdev(rm), nbars=nbars, index=0,fill_color=colors[0], name = 'R-WRSI');blue = rain
   b2 = barplot(nm/stdev(nm), nbars=nbars, index=1,fill_color=colors[1],/overplot, yrange = [-2,2], name = 'N-WRSI')
   b2.xminor = 0
   b2.yminor = 0
   b2.xtickvalues = xtickvalues
   b2.xtickname = xticks
   b2.font_name='times'
   b2.font_size=16
   ax = b2.axes
   ax[2].HIDE = 1 
   ax[3].HIDE = 1 
  !null = legend(target=[b1,b2], position=[0.2,0.3], font_size=14) ;
   
;*********************************************************************  
NCOLORS=256
;wet=2003,2005 dry = 2004,2002
i=6
good = where(finite(nanom), complement=null)
nanom(null) = 0

good = where(finite(ranom), complement=null)
ranom(null) = 0

  p1 = image(nanom[*,*,i], RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),image_dimensions=[72.0,35.0], image_location=[-20,-5], $ 
             min_value=-20, max_value=20, $ 
             dimensions=[nx/100,ny/100], title = strcompress('N-WRSI_ANOMALY_200'+string(i+1),/remove_all )) &$ 
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20) &$
  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 52], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) &$
  p1.Save, strcompress("/home/mcnally/N_anom_data"+string(i)+".png", /remove_all), BORDER=10, RESOLUTION=300, /TRANSPARENT   &$ 


;check out the wet/dry years
meangrid = fltarr(11)
for i =0,10 do begin &$
 meangrid[i] = mean(ranom[*,*,i], /nan) &$
endfor

;************PLOT THE NPAW fitting process***************
;***********************for Niger, Mali and Benin********* 
;read in the whole maps and then check WK,AG and other places.

;make or read in the average NDVI for each pixel
ifile = file_search('/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/sahel/data.{2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012}*img')
;ifile = file_search('/jabber/chg-mcnally/sahel_avg_dekadal_NDVI.img'); don't both with this one, i need the full TS anyway

nx = 720
ny = 350
;nz = 36
nz = n_elements(ifile)

ingrid = fltarr(nx,ny)
ndvi = fltarr(nx,ny,nz)

for f = 0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[f] &$
  readu,1,ingrid &$
  close,1 &$
  ndvi[*,*,f] = ingrid &$
endfor 
ndvi36 = reform(ndvi,nx,ny,36,12)
rfile = file_search('/jabber/chg-mcnally/sahel_ubRFE_PAW36_2001-2012_LGP_WHC_PET.img')
nfile = file_search('/jabber/chg-mcnally/sahel_NPAW_2001_2012_PET_DYNSOS.img');these two files match...

nx = 720
ny = 350
nz = 431

npawgrid = fltarr(nx,ny,nz)
rpawgrid = fltarr(nx,ny,36,12)

openr,1,rfile
readu,1,rpawgrid
close,1
rpawgrid = reform(rpawgrid,nx,ny,432)
rpawgrid(where(rpawgrid eq 0))=!values.f_nan

openr,1,nfile
readu,1,npawgrid
close,1

pad = fltarr(nx,ny,1)
pad[*,*,*]=!values.f_nan
npawgrid = [[[npawgrid]],[[pad]]]

good = where(finite(rpawgrid), complement=null)
npawgrid(null)  = !values.f_nan

neg = where(npawgrid lt 0)
npawgrid(neg) = !values.f_nan
rpawgrid(neg) = !values.f_nan

diffRN = mean(npawgrid, dimension=3, /nan)-mean(rpawgrid, dimension=3, /nan)
cormap = fltarr(nx,ny)
for x = 0,nx -1 do begin &$
  for y = 0,ny-1 do begin &$
    ngood = where(finite(npawgrid[x,y,*]),complement=null) &$
    rgood = where(finite(rpawgrid[x,y,*]), complement=null) &$
    
    cormap[x,y] = correlate(npawgrid[x,y,ngood], rpawgrid[x,y,rgood]) &$
  endfor  &$; x
endfor ; y

poscorr = cormap

p1 = image(cormap, RGB_TABLE=20,image_dimensions=[72.0,35.0], image_location=[-20,-5], $  
             dimensions=[nx/100,ny/100],MIN_VALUE=-0.20, MAX_VALUE=1,title = strcompress('cor map NPAW/RPAW', /remove_all)) &$ 
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100]) &$
  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 52], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) &$



;*******************************************************************************

;****The Wankama observations*******
xticks = ['Jun-06','Jun-07','Jun-08','Jun-09','Jun-10','Jun-11']
xtickvalues = [ 18, 54, 90, 126, 162, 198  ]
xtickinterval = 36
p1 = plot(sarray[0,*], name = 'WK (10-40cm)', 'r', thick = 3, xminor=0, yminor=0, $
          xrange=[0,216], xtickinterval = xtickinterval, xtickvalues = xtickvalues)
p2 = plot(sarray[1,*], name = 'WK (40-70cm)', 'orange', thick = 3, /overplot)
p3 = plot(sarray[2,*], name = 'WK (70-100cm)', 'g', thick = 3, /overplot)
p1.xtickname = xticks
p1.xtickfont_size = 20
p1.ytickfont_size = 20
null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=16, font_name='times') ;
p1.ytitle = 'soil moisture (%VWC)'

;***Agoufou Extras*******
;A203 = float(A203.field1); too many nans
A304 = float(A304.field1)
A106 = float(A106.field1)
;A206 = float(A206.field1); too many nans
NORMA304 = (A304(WET)-MEAN(A304(WET), /NAN))/STDEV(A304(WET))
NORMA106 = (A106(WET[0:60])-MEAN(A106(WET[0:60]), /NAN))/STDEV(A106(WET[0:60]))
NORMA206 = (A206(WET)-MEAN(A206(WET), /NAN))/STDEV(A206(WET))
;p3 = plot(float(A203.field1)*2000, /overplot, 'b')
p3 = plot(float(A304.field1)*2000, /overplot, 'g')
p4 = plot(float(A106.field1)*2000, /overplot, 'r')
p5 = plot(float(A206.field1)*2000, /overplot, 'm')

;**********************theo PAW*************************
;p1=plot(tcube[*,0])
;p1=plot(tcube[*,1], 'r')
;p1=plot(total(tcube[*,0], /cumulative), 'r')
;p1=plot(total(tcube[*,0], /cumulative), 'r')
;p1=plot(total(tcube[*,1], /cumulative), 'orange', /overplot)
;p1=plot(total(tcube[*,2], /cumulative), 'g', /overplot)
;p1=plot(total(tcube[*,3], /cumulative), 'b', /overplot)
;p1.title = 'theo gridded station rainfall totals 2005-2008'
;
;
;p1=plot(total(raingrd[wxind,wyind,*,0], /cumulative), linestyle=3,'r', /overplot)
;p1=plot(total(raingrd[wxind,wyind,*,1], /cumulative), linestyle=3,'orange', /overplot)
;p1=plot(total(raingrd[wxind,wyind,*,2], /cumulative), linestyle=3,'green', /overplot)
;p1=plot(total(raingrd[wxind,wyind,*,3], /cumulative), linestyle=3,'b', /overplot)
;
;
;
;;read in the TheoPAW
;ifile = file_search('/jabber/chg-mcnally/WKPAW_Theo_2005_2008_18.19.18.15.csv')
;paw = read_csv(ifile) ; 7fields (dekads) x 12 years
;array = [[paw.field1],[paw.field2], [paw.field3],[paw.field4]]
;
;;****make a time series of the paw filling in the correct spaces 36*3 = 108 2006-2008
;PAWTS = fltarr(36,4)
;;****2005******
;PAWTS[0:16,0] = !values.f_nan
;PAWTS[17:26,0] = paw.field1 & help, pawts
;PAWTS[27:35,0] = !values.f_nan
;;***2006*******
;PAWTS[0:17,1] = !values.f_nan
;PAWTS[18:27,1] = paw.field2
;PAWTS[28:35,1] = !values.f_nan
;;***2007*****
;PAWTS[0:16,2] = !values.f_nan
;PAWTS[17:26,2] = paw.field3
;PAWTS[27:35,2] = !values.f_nan
;;****2008******
;PAWTS[0:13,3] = !values.f_nan
;PAWTS[14:23,3] = paw.field4 & help, pawts
;PAWTS[24:35,3] = !values.f_nan

;*******FIGURE 3******
;averge PAW/SWB compared to average NDVI, then show NPAW/NSWB
;ifile = file_search('/jabber/chg-mcnally/sahel_NPAW_2001_2012_PET.img') ; from ndvi2paw
;sfile = file_search('/jabber/chg-mcnally/sahel_ubRFE_PAW36_2001-2012_LGP_WHC_PET.img');from WRSI_rain_gridv2
;read in the whole maps and then check WK,AG and other places.

;make or read in the average NDVI for each pixel


;*****************************************************

;show where the sites are on the avg NDVI map

;p1 = image(mean(ndvi,dimension=3,/nan), RGB_TABLE=20,image_dimensions=[72.0,35.0], image_location=[-20,-5], $  
;             dimensions=[nx/100,ny/100],min_value=0,title = strcompress('avg NDVI', /remove_all)) &$ 
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100]) &$
;  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 52], /overplot) &$
;  p1.mapgrid.linestyle = 'dotted' &$
;  p1.mapgrid.color = [150, 150, 150] &$
;  p1.mapgrid.label_position = 0 &$
;  p1.mapgrid.label_color = 'black' &$
;  p1.mapgrid.FONT_SIZE = 12 &$
;  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) &$
;  
;  ;why do i need this correction factor to get the star in the correct place? Somthin about the window...
;  star = TEXT(2.632-1.5,13.6456-3,/DATA,'*', $
;       FONT_SIZE=32, FONT_STYLE='Bold', $
;       FONT_COLOR='green')
;       
;  star = TEXT(-1.479-1.5,15.3540-3,/DATA,'*', $
;       FONT_SIZE=32, FONT_STYLE='Bold', $
;       FONT_COLOR='green')
;  star = TEXT(1.7145-1.5,9.795-3,/DATA,'*', $
;       FONT_SIZE=32, FONT_STYLE='Bold', $
;       FONT_COLOR='green')


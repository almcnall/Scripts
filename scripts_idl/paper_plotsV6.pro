;the purpose of this script is to make the plots for the paper.
;KLEE 10/5/2011 - 11/14/2012 (Octdek1-Nov dek2) or one?
;COSMOS_50=MPALA 9/6/2011 (Sept dek1) - 10/27/2012 (Oct dek3)
;revisit on 9/1/2013
;move from zippy to rain 9/30/2013


;********FIGURE 1********************************************************
ifile = file_search('/raid/chg-mcnally/NDVI_UBRFcorr_current_plus6deks.img')
nx = 720
ny = 350

sahel = fltarr(nx,ny)

openr,1,ifile
readu,1,sahel
close,1

longitude = findgen(720)-200
latitude = findgen(350)-50

p1 = image(sahel, RGB_TABLE=20,image_dimensions=[72.0,35.0], image_location=[-20,-5], $ 
 min_value=0.2,max_value=1, dimensions=[nx/100,ny/100],/overplot)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], title = 'NDVI-rainfall(current+2month) correaltion',font_size=20)
p1 = MAP('Geographic',LIMIT = [-5, -20, 18, 52], /overplot)
p2 = contour(sahel,RGB_TABLE=0, longitude/10,latitude/10,mapgrid=p1,n_levels=10,/overplot)
p2.rgb_table=0
p2.n_levels=8
p2.c_label_show=[0,0,0,0,0,0,0,0]
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) 
  
 ;Agoufou 15.35400    -1.47900 
 star = TEXT(-1.5, 15.3, /DATA, '*', $
       FONT_SIZE=42, FONT_STYLE='Bold', $
       FONT_COLOR='white')
 ;Wankama 
  star = TEXT(2.7, 13.5, /DATA, '*', $
       FONT_SIZE=42, FONT_STYLE='Bold', $
       FONT_COLOR='white')
 ;Mpala
  star = TEXT(37, 0.5, /DATA, '*', $
       FONT_SIZE=42, FONT_STYLE='Bold', $
       FONT_COLOR='white')
;  ;Belefoungou-Top 9.79506     1.71450  
;  star = TEXT(1.7,9.8, /DATA, '*', $
;       FONT_SIZE=42, FONT_STYLE='Bold', $
;       FONT_COLOR='yellow')
;;************FIGURE 2 ******************************************************
ifile1 = file_search('/raid/chg-mcnally/AMMA2013/dekads/Wankama_sm_0.400000_0.700000_CS616_2_10dayavg_VWC.csv')
ifile2 = file_search('/raid/chg-mcnally/AMMA2013/dekads/Wankama_sm_0.700000_1.000000_CS616_2_10dayavg_VWC.csv')
ifile3 = file_search('/raid/chg-mcnally/AMMA2013/dekads/Tondikiboro_sm_0.400000_0.700000_CS616_2_10dayavg_VWC.csv')
ifile4 = file_search('/raid/chg-mcnally/AMMA2013/dekads/Tondikiboro_sm_0.700000_1.000000_CS616_2_10dayavg_VWC.csv')

wk47 = read_csv(ifile1)
wk71 = read_csv(ifile2)
tk47 = read_csv(ifile3)
tk71 = read_csv(ifile4)

avgwk47 = mean(reform(wk47.field1,36,6), dimension = 2,/nan)
avgwk71 = mean(reform(wk71.field1,36,6), dimension = 2,/nan)
avgtk47 = mean(reform(tk47.field1,36,6), dimension = 2,/nan)
avgtk71 = mean(reform(tk71.field1,36,6), dimension = 2,/nan)

p1 = plot(avgwk47*100, thick = 3, 'black', font_size = 20, name = 'WK 40-70cm')
p2 = plot(avgwk71*100, thick = 3, /overplot, 'black', linestyle = 2, name = 'WK 70-100cm')
p3 = plot(avgtk47*100, thick = 3, /overplot,'grey', name = 'TK 40-70cm')
p4 = plot(avgtk71*100, thick = 3, /overplot,'grey', linestyle = 2, name = 'TK 70-100cm')

;p4.title = 'Average dekadal soil mositure 2005-2008 '
p4.ytitle = 'soil moisture (% VWC)'
p4.xminor = 0
p4.yminor = 0
p4.xrange = [10, 35]
p4.xtickvalues = [10+2, 15+2, 20+2, 25+2, 30+2]
xticks = ['21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov']
p4.xtickname = xticks
p4.font_name='times'
null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3],font_size=16, font_name='times', color='w', shadow=0) 
;p1.Save, strcompress("/home/mcnally/McNally_Figure2.png", /remove_all), BORDER=10, RESOLUTION=300, /TRANSPARENT   &$ 
ax = p4.AXES
;ax[0].TITLE = 'X axis'
;ax[1].TITLE = 'Y axis'
ax[2].HIDE = 1 ; hide top X axis
ax[3].HIDE = 1 ; hide right Y axis


;******************FIGURE 3********************************************************
;this doesn't look so impressive with the new data, the lag 3 looks better but then doens't
;really make a difference when looking at the longer time series (but it averages out better...) 
;is it worth adding an extra lag??

nfile = file_search('/raid/chg-mcnally/NDVI_WKTK06.11.csv');how is this different than above?
sfile = file_search('/raid/chg-mcnally/observed_avgTKWK06.11.csv')
ffile = file_search('/raid/chg-mcnally/filterNDVI_soilmoisture_2001Jan_2012Oct_lag2.img')
;ffile3 = file_search('/jabber/chg-mcnally/filterNDVI_soilmoisture_2001Jan_2012Oct_lag3.img')

soil = read_csv(sfile)
  wktk = float(soil.field1)
ndvi = read_csv(nfile)
  wkn = ndvi.field1
  tkn = ndvi.field2

nx = 720
ny = 350
nz = 424

ingrid = fltarr(nx,ny,nz)
ingrid3 = fltarr(nx,ny,nz)

openr,1,ffile
readu,1,ingrid
close,1

;openr,1,ffile3
;readu,1,ingrid3
;close,1

;pull out locations of interest WK and TK (I guess use the lat/lons that ISMN uses...)
;Wankama 2006 - 2011
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Tondikiboro 2006-2011
txind = FLOOR((2.6956 + 20.) / 0.10)
tyind = FLOOR((13.548 + 5) / 0.10)

;so this does predict higher soil moisture with higher NDVI 
;the RANGE of the TK site is greater, maybe meaning more PAW, but maxSM is higher at WK.
nsmWK = ingrid(wxind, wyind, *)
nsmTK = ingrid(txind, tyind, *)
nsm = mean([[transpose(nsmWK)], [transpose(nsmTK)]], dimension = 2, /nan)
pad = fltarr(8)
pad[*] = !values.f_nan
nsm = [nsm, pad]
avgnsm = mean(reform(nsm, 36,12), dimension = 2, /nan)

nsmWK3 = ingrid3(wxind, wyind, *)
nsmTK3 = ingrid3(txind, tyind, *)
nsm3 = mean([[transpose(nsmWK3)], [transpose(nsmTK3)]], dimension = 2, /nan)
pad = fltarr(8)
pad[*] = !values.f_nan
nsm3 = [nsm3, pad]
avgnsm3 = mean(reform(nsm3, 36,12), dimension = 2, /nan)

navg216 = mean([transpose(WKn), transpose(TKn)], /nan, dimension = 1)
navg = mean(reform(navg216, 36,6), dimension = 2, /nan)

savg = mean(reform(soil.field1,36,6), dimension = 2, /nan) 
xtickvals=[0, 5, 10, 15, 20, 25, 30]+2
p2 = plot(navg, thick = 3, 'black', name = 'NDVI', /overplot, $)
         xtickvalues = xtickvals, $
         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct'],$
         MARGIN = [0.15,0.2,0.15,0.1], $
         AXIS_STYLE=0, yminor = 0, xrange=[0,36])
yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='NDVI', $
       TEXTPOS=1,tickfont_size=20, minor = 0)
p1 = plot(savg*100, thick = 3, 'light grey', name = 'SM', xminor = 0, yminor = 0, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = xtickvals, font_name='times',$
         xtickname = ['11-Jan', '01-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct'],$
         YTITLE='SM',AXIS_STYLE=1,/CURRENT, xrange=[0,36])
;I shouldn't use yfit because it is not long enough -- maybe the avg of est will look better too!
p3 = plot(avgnsm*100, thick = 3, linestyle = 2, 'grey',name ='NSM', /overplot)
;p4 = plot(avgnsm3*100, thick = 3, linestyle = 1, 'grey',name ='SM estimate3', /overplot)

lgr2 = LEGEND(TARGET=[p1, p2, p3], font_size=16, font_name='times',color='w', shadow=0)
p1.xtickfont_size = 20
p1.ytickfont_size = 20
p1.ytitle='soil moisture (%VWC)'
p1.font_name='times'
ax = p3.AXES
;ax[0].TITLE = 'X axis'
;ax[1].TITLE = 'Y axis'
ax[2].HIDE = 1 ; hide top X axis

;p1.Save, strcompress("/home/mcnally/McNally_Figure2.png", /remove_all), BORDER=10, RESOLUTION=300, /TRANSPARENT   &$ 


temp = regress(avgnsm, savg, correlation=corr, sigma=sigma) & print, corr, sigma; 0.934 p=0.06
rmse = sqrt(mean((savg-avgnsm)^2, /nan)) & print, rmse; 0.005
;p1.Save, strcompress("/home/mcnally/McNally_Figure3.png", /remove_all), BORDER=10, RESOLUTION=300, /TRANSPARENT 
;******************FIGURE 4***********************************
;**********fit the longer time series************************
ifile = file_search('/raid/chg-mcnally/observed_avgTKWK06.11.csv')
ffile = file_search('/raid/chg-mcnally/filterNDVI_soilmoisture_2001Jan_2012Oct_lag2.img');two nans that is not nice.
afile = file_search('/raid/chg-mcnally/API_WKrain_WKTKsoil.csv');

soil = read_csv(ifile)
savg216 = soil.field1*100

api = read_csv(afile)
api = api.field2*100

nx = 720
ny = 350
nz = 424
ingrid = fltarr(nx,ny,nz)

openr,1,ffile
readu,1,ingrid
close,1

;pull out locations of interest WK and TK (I guess use the lat/lons that ISMN uses...)
;Wankama 2006 - 2011
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Tondikiboro 2006-2011
txind = FLOOR((2.6956 + 20.) / 0.10)
tyind = FLOOR((13.548 + 5) / 0.10)

;so this does predict higher soil moisture with higher NDVI 
;the RANGE of the TK site is greater, maybe meaning more PAW, but maxSM is higher at WK.
nsmWK = ingrid(wxind, wyind, *)
nsmTK = ingrid(txind, tyind, *)
nsm = mean([[transpose(nsmWK)], [transpose(nsmTK)]], dimension = 2, /nan)

;ugh, what are thie indices that i need?
nsm0611 = nsm[179:179+215]*100
nsmcube = reform(nsm0611,36,6)
mxnsm = max(nsmcube, dimension=1)
smcube = reform(savg216,36,6)
mxsm = max(smcube,dimension=1)

apicube = reform(api,36,6)
smcube = reform(soil.field1,36,6)
mapi = max(apicube,dimension=1)

xticks = ['Jun-06','Jun-07','Jun-08','Jun-09','Jun-10','Jun-11']
p1 = plot(nsm0611, thick = 3, 'g',linestyle=2, name = 'NSM', xminor = 0, yminor = 0,xrange = [0,216], $
 xtickvalues = [ 18, 54, 90, 126, 162, 198  ], xtickinterval = 36 ,font_size = 14)

p1.xtickname= xticks
p1.xtickfont_size = 20
p1.ytickfont_size = 20
p2 = plot(savg216, thick = 1, name = 'observed SM', /overplot, font_name='times')
p3 = plot(api, thick = 3, name = 'API','b',linestyle = 1, /overplot)
;for B&W figure
;p1.color='black'
;p3.color='grey'

null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=16, font_name='times', color='w', shadow=0) ;
p1.ytitle = 'soil moisture (%VWC)'
ax = p3.AXES
;ax[0].TITLE = 'X axis'
;ax[1].TITLE = 'Y axis'
ax[2].HIDE = 1 ; hide top X axis
ax[3].HIDE = 1 ; hide right Y axis

;p1.Save, strcompress("/home/mcnally/McNally_Figure4.png", /remove_all), BORDER=10, RESOLUTION=300, /TRANSPARENT 

;calculate root mean sq error for the two series total and summer
rms_nsm = sqrt(mean((savg216-nsm0611)^2, /nan)) & print, rms_nsm; 1.23
rms_api = sqrt(mean((savg216-API)^2, /nan)) & print, rms_api;1.21

;rank correlation for the lag2 vs lag3 peaks..good reason to stick with 2.
print, r_correlate(mxnsm,mxsm);LAG2: rho=0.6, p=0.2
print, r_correlate(mapi,mxsm);LAG2: rho=0.1, p=0.9
print, r_correlate(mapi,mxnsm);LAG2: rho=0.257, p=0.622


;*******figure 5********Mali data********************
ifile = file_search('/raid/chg-mcnally/AMMA2013/dekads/Agoufou*{0.7,0.6}*csv')
ffile = file_search('/raid/chg-mcnally/filterNDVI_soilmoisture_2001Jan_2012Oct_lag2.img')
afile = file_search('/raid/chg-mcnally/API_2001_2012_sahel_v2.img')

A106 = read_csv(ifile[0])
A206 = read_csv(ifile[1])

A06 = mean([transpose(float(A106.field1)), transpose(float(A206.field1))], dimension=1, /nan)*100
;ofile = strcompress('/jabber/chg-mcnally/AMMASOIL/Agoufou_avg0102SM.csv')
;write_csv,ofile, A06

nx = 720
ny = 350
nz = 428
apigrid = fltarr(nx,ny,nz)
nsmgrid = fltarr(nx,ny,nz-3)

openr,1,afile
readu,1,apigrid
close,1

openr,1,ffile
readu,1,nsmgrid
close,1

;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5.) / 0.10)

AAPI = (apigrid[axind,ayind,144:144+143]*100)-3.5; change these to 2005
nsm0611 = (nsmgrid[axind,ayind,144:144+143]*100)-3.5; change these to 2005
;I wish that there was a reason that these are shifted by two dekads...
xticks = ['Jun-05','Jun-06','Jun-07','Jun-08']
p1 = plot((nsm0611), thick = 2, 'g',linestyle=2, name = 'NSM + WP diff', xminor = 0, yminor = 0,xrange = [0,143], $
 xtickvalues = [ 18, 54, 90, 126], xtickinterval = 36 ,font_size = 14)
p1.xtickname= xticks
p1.xtickfont_size = 20
p1.ytickfont_size = 20
p2 = plot((A06), thick = 1, name = 'observed SM', /overplot, font_name='times')
p3 = plot((aapi), thick = 3, name = 'API + WP diff','b',linestyle = 1, /overplot)
;for B&W figure
p1.color='black'
p3.color='grey'
null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=16, font_name='times', color='w', shadow=0) ;
p1.ytitle = 'soil moisture (%VWC)'
ax = p3.AXES
;ax[0].TITLE = 'X axis'
;ax[1].TITLE = 'Y axis'
ax[2].HIDE = 1 ; hide top X axis
ax[3].HIDE = 1 ; hide right Y axis
;p1.Save, strcompress("/home/mcnally/McNally_Figure6.png", /remove_all), BORDER=10, RESOLUTION=300, /TRANSPARENT 

;check out the rank correlations
;cube um'
a06cube = reform(A06,36,4)
nsmcube = reform(nsm0611, 36,4)
apicube = reform(aapi,36,4)

tmp = regress(a06[10:143], nsm0611[10:143], correlation = corr, sigma=sigma) & print, corr, sigma ;0.65, 0.07
tmp = regress(a06[10:143], aapi[10:143], correlation = corr, sigma=sigma) & print, corr, sigma ;0.68, 0.03
tmp = regress(nsm0611[10:143], aapi[10:143], correlation = corr, sigma=sigma) & print, corr, sigma ;0.9 0.02

print, r_correlate(max(a06cube,dimension=1, /nan), max(nsmcube, /nan, dimension=1));-0.8, 0.2 - almost inverse.
print, r_correlate(max(a06cube,dimension=1, /nan), max(apicube, /nan, dimension=1));-1, 0
print, r_correlate(max(nsmcube,dimension=1, /nan), max(apicube, /nan, dimension=1));0.8, 0.2 - hard to be significant here

rms_nsm = sqrt(mean((nsm0611[10:143]-A06[10:143])^2, /nan)) & print, rms_nsm;1.55
rms_api = sqrt(mean((aapi[10:143]-A06[10:143])^2, /nan)) & print, rms_api ;1.33


;********FIGURE 7a&b pull the klee and mpala sites from the ndvi filter and API maps******
;KLEE 10/5/2011 - 11/14/2012 (Octdek1-Nov dek2) or one?
;COSMOS_50=MPALA 9/6/2011 (Sept dek1) - 10/27/2012 (Oct dek3)
afile = file_search('/raid/chg-mcnally/API_2001_2012_sahel_v2.img'); 
;check and see if it matches /raid/chg-mcnally/API_2001_2012_sahel_WKTKparams_930.img
ffile = file_search('/raid/chg-mcnally/filterNDVI_soilmoisture_2001Jan_2012Oct_lag2.img')
kfile = file_search('/raid/chg-mcnally/KLEE_dekad.csv');do i want to use the newer versions?
mfile = file_search('/raid/chg-mcnally/Mpala_dekad.csv')

nx = 720
ny = 350
nz = 428
nnz = 425

apigrid = fltarr(nx,ny,nz)
filter  = fltarr(nx,ny,nnz);this should be 426 no? or 425...why is it 424?
cormap = fltarr(nx,ny)

openr,1,afile
readu,1,apigrid
close,1

openr,1,ffile
readu,1,filter
close,1

apipad = fltarr(nx,ny,4)
apipad[*,*,*] = !values.f_nan
apifull = [[[apigrid]],[[apipad]]]

filterpad = fltarr(nx,ny,7)
filterpad[*,*,*] = !values.f_nan
filterfull = [[[filter]],[[filterpad]]]

result = read_csv(mfile)
mpala = float(result.field1)

result = read_csv(kfile)
KLEE = float(result.field1)

;Mpala Kenya:
mxind = FLOOR((36.8701 + 20.) / 0.10)
myind = FLOOR((0.4856 + 5) / 0.10)

;;KLEE Kenya
kxind = FLOOR((36.8669 + 20.) / 0.10)
kyind = FLOOR((0.2825 + 5) / 0.10)


;*******************FIGURE 7A: the Mpala DATA*************************************
;I had to add in xrange, and adjusted the estimates rather than observations (e.g. +4 to API, not -4 from Mpala) 2/28/13
;looks like I should fix the y-ticks too so that figures 7&8 are identicle
;xticks = ['sept-11','nov-11','jan-12','mar-12', 'may-12','jul-12','sept-12']
xticks = ['Oct-11','Dec-11','Feb-12','Apr-12', 'Jun-12','Aug-12','Oct-12']
xvals = [0,  6,  12,  18,  24,  30,  36]+3

nsm = filterfull[mxind,myind,360+24:431-6]*100
api = apifull[mxind,myind,360+24:431-6]*100 
obs = Mpala[24:71-6]

p1 = plot(api, thick = 3,  name = 'API', $
         xminor = 0, yminor = 0, linestyle = 1, 'b', $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = xvals, font_name='times',$
         xtickname = xticks,$
         YTITLE='soil moisture (%VWC)',AXIS_STYLE = 1, $
         XRANGE = [0,n_elements(apifull[mxind,myind,360+24:431-6])-1], $
         YRANGE = [2,22])
p2 = plot(nsm, thick = 3, linestyle = 2, $
          'g', name='NSM', /overplot)
p3 = plot(obs,thick = 3,name = 'observed SM',/overplot)  
;Mapla Kenya fig6
p1.color='grey'
p2.color='black'

p1.xtickfont_size = 20
p1.ytickfont_size = 20
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=16, font_name='times', color='w', shadow=0) 
ax = p3.AXES
;ax[0].TITLE = 'X axis'
;ax[1].TITLE = 'Y axis'
ax[2].HIDE = 1 ; hide top X axis
ax[3].HIDE = 1 ; hide right Y axis
;p1.Save, strcompress("/home/mcnally/McNally_Figure7.png", /remove_all), BORDER=10, RESOLUTION=300, /TRANSPARENT 

;check correlations with the niger parameters

tmp = regress(obs[0:40], nsm[0:40], correlation = corr, sigma=sigma) & print, corr, sigma ;0.76, p=0.063
tmp = regress(obs, reform(api), correlation = corr, sigma=sigma) & print, corr, sigma ;0.72, 0.04
tmp = regress(reform(nsm[0:40]), reform(api[0:40]), correlation = corr, sigma=sigma) & print, corr, sigma ;0.91, p=0.03


rms_nsm = sqrt(mean((nsm-obs)^2, /nan)) & print, rms_nsm;2.78
rms_api = sqrt(mean((api-obs)^2, /nan)) & print, rms_api ;5.8

;*****FIGURE 7 API-NDVI-ECV correlation map***********
;;***is this actually figures 7,8,9?********
;i correlate the api and nsm incorr_api_ndvi_ubrf
NMfile = file_search('/raid/chg-mcnally/NSM_MWcorr_2001_2010.img')
MAfile = file_search('/raid/chg-mcnally/MW_APIcorr_2001_2010.img')
NAfile = file_search('/raid/chg-mcnally/NSM_APIcorr_2001_2010.img')
nx = 720
ny = 350

NMcorr = fltarr(nx,ny)
MAcorr = fltarr(nx,ny)
NAcorr = fltarr(nx,ny)

;read in NSM-MW-API correlations
openr,1,NMfile
readu,1,NMcorr
close,1

openr,1,MAfile
readu,1,MAcorr
close,1

openr,1,NAfile
readu,1,NAcorr
close,1

;reduce the window down to 18N for the figures...
NMsahel = NMcorr[*, 0:230]
MAsahel = MAcorr[*, 0:230]
NAsahel = NAcorr[*, 0:230]
;reverse the black and white color bar for b/w figures
;cgloadct, 0, /reverse, rgb_table = table

;mask out the ECV regions to highlight agree-disagreement
good = where(finite(NMsahel), complement=bad)
NAsahel_mask = NAsahel
NAsahel_mask(bad)=!values.f_nan

;39 works ok for the difference plots.
p1 = image(NAsahel, image_dimensions=[72.0,23.1], image_location=[-20,-5], dimensions=[nx/100,231/100], $
           rgb_table =0, title = 'NSM-API correlation May-October 2001-2010', font_size=18, min_value=0.5,max_value=1)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20)
p1 = MAP('Geographic',LIMIT = [-5, -20, 18, 52], /overplot)
p1.mapgrid.linestyle = 'dotted'
p1.mapgrid.color = [150, 150, 150]
p1.mapgrid.label_position = 0
p1.mapgrid.label_color = 'black'
p1.mapgrid.FONT_SIZE = 12
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

;m1 = MAPCONTINENTS(/COUNTRIES, $
;  COLOR = [120, 120, 120], $
;  FILL_BACKGROUND = 0)
;p1.Save, strcompress("/home/mcnally/McNally_Figure5.png", /remove_all), BORDER=10, RESOLUTION=300, /TRANSPARENT 



 


;**********************FIG 7B: the KLEE DATA************************************
xticks = ['oct-11','dec-11','feb-12','apr-12', 'jun-12','aug-12','oct-12']
p1 = plot(apifull[kxind,kyind,360+27:431-4]*100+26, thick = 3,  name = 'API+WPdiff',$
         xminor = 0, yminor = 0, linestyle = 2, 'light grey', $
         MARGIN = [0.15,0.2,0.15,0.1], $
          xtickvalues = [0,  6,  12,  18,  24,  30,  36], $
         xtickname = xticks,$
         YTITLE='% volumetric SM',AXIS_STYLE=1)
         ;YTITLE='API & SM est',AXIS_STYLE=1,/CURRENT,/NOERASE)
p2 = plot(filterfull[kxind,kyind,360+27:431-4]*100+26, thick = 3, linestyle = 2,$
          'grey', name='SM est from NDVI+WPdiff', /overplot)
p3 = plot(KLEE[27:67], thick = 3,name = 'observ',/overplot)
;uh, i guess this shouldn't be 11...
p1.xtickfont_size = 16
p1.ytickfont_size = 16
;p1.title = 'Observed and estimated soil moisture at KLEE'
;p1.title.font_size = 24 
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) ;

;clay = 14 (FAO);  
;WPdiff = 14-3

;API fit ...as the wilting point increases (i.e. shift the mean up!) so does the fit...maxes out at 30. 
;Haider's equation calculates it at 37% for ethipia black cotton clay. I should be able to justify this somehow.
;literature suggests that the wilting point of these clay soils is much higher, so we use the statsgo 28?         
for i = 22,37 do begin &$
  vKLEE = (KLEE[27:67]-(i-3))/100 &$
  vkAPI = (apifull[kxind,kyind,360+27:431-4])&$
  print, 'i= ', i, 1-total((vKLEE-vkAPI)^2)/total((vKLEE-mean(vKLEE))^2) &$ ;-0.037&$
endfor

;Filter Fit..so why don't I have the full time series avaialble??
vKLEE = (KLEE[27:64]-26)/100
vkFilter = (filterfull[kxind,kyind,360+27:431-7])
vkAPI = (apifull[kxind,kyind,360+27:431-4])
print, 1-total((vKLEE-vkfilter)^2)/total((vKLEE-mean(vKLEE))^2);0.38
print, 1-total((vKLEE-vkAPI)^2)/total((vKLEE-mean(vKLEE))^2);0.16


;******FIGURE 8--plot of refit Mpala*************************** 
;I should just do this with the individual point since this is so time consuming
;afile = file_search('/jabber/LIS/Data/ubRFE2/dekads/horn_API_2001_2012MP.img');looks like this one is gone, what were the Mpala coefficents?
ffile = file_search('/raid/chg-mcnally/filterNDVI_soilmoisture_2001_2012_Mpala.img')
kfile = file_search('/raid/chg-mcnally/KLEE_dekad.csv')
mfile = file_search('/raid/chg-mcnally/Mpala_dekad.csv')

nx = 250
ny = 350
anz = 428
nnz = 425

apigrid = fltarr(nx,ny,anz)
filter  = fltarr(nx,ny,nnz);this should be 426 no? or 425...why is it 424? I guess I fixed this...
cormap = fltarr(nx,ny)

;openr,1,afile
;readu,1,apigrid
;close,1

openr,1,ffile
readu,1,filter
close,1

apipad = fltarr(nx,ny,4)
apipad[*,*,*] = !values.f_nan
apifull = [[[apigrid]],[[apipad]]]

filterpad = fltarr(nx,ny,7)
filterpad[*,*,*] = !values.f_nan
filterfull = [[[filter]],[[filterpad]]]

result = read_csv(mfile)
mpala = float(result.field1)

result = read_csv(kfile)
KLEE = float(result.field1)

mxind = FLOOR((36.8701 - 27.) / 0.10)
myind = FLOOR((0.4856 + 5) / 0.10)

;KLEE
kxind = FLOOR((36.8669 - 27.) / 0.10)
kyind = FLOOR((0.2825 + 5) / 0.10)


;*******************FIGURE 8A the Mpala DATA*************************************
xticks = ['oct-11','dec-11','feb-12','apr-12', 'jun-12','aug-12','oct-12']
xvals = [0+3,  6+3,  12+3,  18+3,  24+3,  30+3,  36+3]

p1 = plot(apifull[mxind,myind,360+24:431-6], thick = 3,  name = 'API', $
         xminor = 0, yminor = 0, linestyle = 2, 'light grey', $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = xvals, $
         xtickname = xticks,$
         YTITLE='% volumetric SM',AXIS_STYLE = 1,$
         XRANGE = [0,n_elements(apifull[mxind,myind,360+24:431-6])], $
         YRANGE = [2,24])
p2 = plot(filterfull[mxind,myind,360+24:431-6], thick = 3, linestyle = 2, $
          'grey', name='SM est from NDVI', /overplot)
p3 = plot(Mpala[24:65],thick = 3,name = 'observ',/overplot)  
p1.xtickfont_size = 14
p1.ytickfont_size = 14
;p1.title = 'Observed and estimated soil moisture at Mpala (Mpala refit)'
;p1.title.font_size = 24 
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) ;

;API fit             
vMPALA = (mpala[24:64])
vAPI = (apifull[mxind,myind,360+24:431-7])
print, 1-total((vMpala-vAPI)^2)/total((vmpala-mean(vmpala))^2);0.43

;Filter Fit
vFilter = (filterfull[mxind,myind,360+24:431-7])
print, 1-total((vMpala-vfilter)^2)/total((vmpala-mean(vmpala))^2);0.49

;*********FIGURE 8B********************************************************

xticks = ['oct-11','dec-11','feb-12','apr-12', 'jun-12','aug-12','oct-12']
p1 = plot(apifull[kxind,kyind,360+27:431-4]+22, thick = 3,  name = 'API+WPdiff',$
         xminor = 0, yminor = 0, linestyle = 2, 'light grey', $
         MARGIN = [0.15,0.2,0.15,0.1], $
          xtickvalues = [0,  6,  12,  18,  24,  30,  36], $
         xtickname = xticks,$
         YTITLE='% volumetric SM',AXIS_STYLE=1)
p2 = plot(filterfull[kxind,kyind,360+27:431-4]+22, thick = 3, linestyle = 2,$
          'grey', name='SM est from NDVI+WPdiff', /overplot)
p3 = plot(KLEE[27:67], thick = 3,name = 'observ',/overplot)

p1.xtickfont_size = 14
p1.ytickfont_size = 14
;p1.title = 'Observed and estimated soil moisture at KLEE (Mpala refit)'
;p1.title.font_size = 24 
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) ;


;API fit             
vKLEE = (KLEE[27:67])
vkAPI = (apifull[kxind,kyind,360+27:431-4])
print, 1-total((vKLEE-vkAPI)^2)/total((vKLEE-mean(vKLEE))^2);0.48 -- really?

;Filter Fit..so why don't I have the full time series avaialble?? I hope that I have these correct....
vKLEE = (KLEE[27:64])
vkFilter = (filterfull[kxind,kyind,360+27:431-7])
print, 1-total((vKLEE-vkfilter)^2)/total((vKLEE-mean(vKLEE))^2);0.43


; go to Niger_yields.pro for the final figure with the yield data....and its the second plot of anomalies

;*************EXTRAS***************
;suplemental figures for the discussion - why can't i capture the range of SM in kenya w/ Niger data?

nfile = file_search('/jabber/chg-mcnally/AMMAVeg/NDVI_mpala_klee_2011_2012.csv')
ndvi = read_csv(nfile)

mpala = float(ndvi.field1)
KLEE = float(ndvi.field2)

xticks = ['jan-11','may-11','aug-11','jan-12', 'apr-12','sept-12','jan-13']
p1 = plot(mpala, thick = 3,  name = 'Mpala',$
         xminor = 0, yminor = 0, linestyle = 2, 'light grey', $
         MARGIN = [0.15,0.2,0.15,0.1], $
          xtickvalues = [0,  6,  12,  18,  24,  30,  36]*2, $
         xtickname = xticks,font_name='times', $
         YTITLE='NDVI',AXIS_STYLE=1)
p2 = plot(KLEE, thick = 3, linestyle = 2,$
          'grey', name='KLEE', /overplot)
;uh, i guess this shouldn't be 11...
p1.xtickfont_size = 16
p1.ytickfont_size = 16
;p1.title = 'Observed and estimated soil moisture at KLEE'
;p1.title.font_size = 24 
!null = legend(target=[p1,p2], position=[0.2,0.3], font_size=14, font_name='times') ;

;****start here on 9/2********
;*******FIGURE 5/MAP 1 average soil moisture est from NDVI*************
;might want to update this to the one that goes to 2012>filterNDVI_soilmoisture_200101_2012.10.3.img
;nfile = file_search('/jabber/chg-mcnally/filterNDVI_soilmoisture_2001_2011.img');cube of filtered NDVI
nfile = file_search('/jower/chg-mcnally/filterNDVI_soilmoisture_200101_2012.10.2.img');cube of filtered NDVI

nx = 720
ny = 350
nz = 425 ;396 ;this will be bigger with new file...425

filtered = fltarr(nx,ny,nz-6)
openr,1,nfile
readu,1,filtered
close,1

cap = where(filtered gt 0.15, count) & print, count
filtered(cap) = !values.f_nan
p1 = image(mean(filtered, dimension = 3, /nan), image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 1)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

;****FIGURE 6 average API map************************************
;might want to update this to the one that goes to 2012> sahel_API_200101_201232.img
;ifile = file_search('/jabber/chg-mcnally/API_soilmoisture_2001_2011.img')
ifile = file_search('/jower/chg-mcnally/sahel_API_200101_201232.img');not there

nx = 720
ny = 350
nz = 428 ;396;this will be bigger with new file...428

apigrid = fltarr(nx,ny,nz)
openr,1,ifile
readu,1,apigrid
close,1
cap = where(apigrid gt 0.15, count) & print, count
apigrid(cap) = !values.f_nan
p1 = image(mean(apigrid,dimension = 3, /nan), image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 20)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  p1.title = 'Avg API'

;***************figure 8 precip-NDVI correlation Nicholson*******
 ;pretty sure this has not been re-done with 2012 data (12/14/12)
nichol = file_search('/jabber/chg-mcnally/NDVI_UBRFcorr.img') ;correlation between 8dek rain and NDVI
nx = 720
ny = 350
PNcorr = fltarr(nx,ny)
;read in Precip-NDVI correlation
openr,1,nichol
readu,1,PNcorr
close,1
p1 = image(PNcorr, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 20)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  
  ;******try making a box plot WK and TK 2006-2011 as a way to show SM heterogenity******
;*****we won't have this luxery for other point observations*******
xtickname = ['2006', '2007', '2008', '2009', '2010', '2011'] 
Sarry = fltarr(5,n_elements(xtickname))
whisdat = fltarr(2,n_elements(xtickname))

;4x216 array of all of the soil data -- is there a significant difference bettween depth and means?
WKTK4771 = reform([transpose(wk47.field1), transpose(wk71.field1),transpose(wk47.field1),transpose(wk71.field1)],4,36,6)
SM06 = reform(WKTK4771[*,*,0],144)
;SM07 = WKTK4771[*,*,1]
;SM08 = WKTK4771[*,*,2]
;SM09 = WKTK4771[*,*,3]
;SM10 = WKTK4771[*,*,4]
;SM11 = WKTK4771[*,*,5]

for i = 0,n_elements(xtickname)-1 do begin  &$
  SM06 = reform(WKTK4771[*,17:26,i],n_elements(wktk4771[*,17:26,0])) &$
  ;the lower quartile
  Sort06 = SM06(sort(SM06)) &$
  index = fix(n_elements(SM06)/2) &$
  
  Sarry[0,i] = min(sort06) &$
  Sarry[1,i] = Sort06(fix(index*0.25)) &$
  Sarry[2,i] = median(Sort06) &$
  Sarry[3,i] = Sort06(fix(index*0.75)) &$
  Sarry[4,i] = max(sort06) &$
  whisdat[0,i] = (median(sort06) / 2.0) - sort06[0] &$     ; negative error bar
  whisdat[1,i] = sort06[N_elements(sort06)-1] - (median(sort06) / 2.0) &$        ; positive error bar
endfor 

b = BARPLOT(REFORM(Sarry(3,*)),BOTTOM_VALUES=REFORM(Sarry(1,*)), $
      COLOR='green',NAME='Shape Value', FILL_COLOR='white', $
      XTITLE='year',xtickname = xtickname, $
      YTITLE='Parameter Value')
;eak, how does this work?
e = ERRORPLOT(INDGEN(N_ELEMENTS(xtickname)),REFORM(Sarry(2,*)),(whisdat[*,*]), $
      LINESTYLE=6, ERRORBAR_COLOR='green',ERRORBAR_CAPSIZE=0.25, $
      /OVERPLOT)
b.order,/SEND_TO_FRONT

;****************************************************************
;;making a cute map of niger and the sites see:
;;file:///usr/local/itt/idl/idl80/help/online_help/IDL/Content/GuideMe/text_annotations.html#Map
;;add in elevation, rainfall isopleths, soil type/veg type
;
;small_pos = [0.14,0.65,0.36,0.95]
;othermap = map('Geographic',LIMIT=[-45,-25,55,65],POSITION=small_pos,/CURRENT)
;grid2 = othermap.mapgrid
;grid2.hide = 1
;m3 = MAPCONTINENTS(/COUNTRIES)
;m3['Niger'].FILL_COLOR = 'dark gray'
;m3['Kenya'].FILL_COLOR = 'dark gray'
;m_outline = POLYGON([small_pos[0],small_pos[0],small_pos[2],small_pos[2]], $
;[small_pos[3],small_pos[1],small_pos[1],small_pos[3]],/NORMAL,LINESTYLE=0, $
;   FILL_BACKGROUND=0)
;
;; i think you need to click on the graphic window at this point, deactivating all graphics
;m = map('Geographic',LIMIT=[11.,0.,24.,17.], /CURRENT); bottom,left,top,right 
;;m = map('Geographic',LIMIT=[10.,0.,25.,20.])
;grid = m.mapgrid
;grid.linestyle = 6
;grid.label_position = 0
;grid.FONT_SIZE = 14
;m2 = MAPCONTINENTS(/COUNTRIES,/HIDE)
;m2['Niger'].HIDE = 0
;m2['Niger'].FILL_COLOR = 'light gray'
;
;; Label the state of Texas.==how am i supposed to know the positioning?
;
;texas = TEXT(6, 16, /DATA, 'Niger', FONT_SIZE = 50,/CURRENT) ;then this is x,y
;star = TEXT(2.6, 13.6, /DATA, '*', $
;       FONT_SIZE=32, FONT_STYLE='Bold', $
;       FONT_COLOR='yellow')
;label = TEXT(2.6, 14.7, /DATA, $
;       'Wankama', FONT_STYLE='Italic')
;
;star = TEXT(2.7, 13.5, /DATA, '*', $
;       FONT_SIZE=32, FONT_STYLE='Bold', $
;       FONT_COLOR='yellow')
;label = TEXT(2.7, 13.3, /DATA, $
;       'Tondi Kiboro', FONT_STYLE='Italic')
;      
;      
;; And now for Kenya
;m = map('Geographic',LIMIT=[-5.,33.,5.,43.]); bottom,left,top,right 
;grid = m.mapgrid
;grid.linestyle = 6
;grid.label_position = 0
;grid.FONT_SIZE = 14
;m2 = MAPCONTINENTS(/COUNTRIES,/HIDE)
;m2['Kenya'].HIDE = 0
;m2['Kenya'].FILL_COLOR = 'light gray'
;
;; Label the state of Texas.==how am i supposed to know the positioning?
;
;texas = TEXT(36, 2.5, /DATA, 'Kenya', FONT_SIZE = 50,/CURRENT) ;then this is x,y in data corrds
;star = TEXT(37, 0.5, /DATA, '*', $
;       FONT_SIZE=32, FONT_STYLE='Bold', $
;       FONT_COLOR='yellow')
;label = TEXT(37.5, 1, /DATA, $
;       'Mpala', FONT_STYLE='Italic')
;
;star = TEXT(37, 0.28, /DATA, '*', $
;       FONT_SIZE=32, FONT_STYLE='Bold', $
;       FONT_COLOR='yellow')
;label = TEXT(37, 0, /DATA, $
;       'KLEE', FONT_STYLE='Italic')
       
;p1.Save, strcompress("/home/mcnally/McNally_Figure1.png", /remove_all), BORDER=10, RESOLUTION=300, /TRANSPARENT   &$ 

;too bad this doesn't work anymore...
;  
;;****************************FULL time series- supplemetal************************************
;p1 = plot(wk47.field1, thick = 3, font_size = 20, name = 'Wk 40-70cm',xminor = 0, yminor = 0,xrange = [0,216], $
;          xtickvalues = [ 18, 54, 90, 126, 162, 198  ], xtickinterval = 36 )
;p2 = plot(wk71.field1, thick = 3, /overplot, 'black', linestyle = 2, name = 'Wk 70-100cm')
;p3 = plot(tk47.field1, thick = 3, /overplot,'grey', name = 'Tk 40-70cm')
;p4 = plot(tk71.field1, thick = 3, /overplot,'grey', linestyle = 2, name = 'Tk 70-100cm')
;
;xticks = ['Jun-06','Jun-07','Jun-08','Jun-09','Jun-10','Jun-11']
;p4.xtickname= xticks
;p4.xtickfont_size = 20
;p4.ytickfont_size = 20
;null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=18, font_name='times') ;
;p1.ytitle = 'soil moisture (%VWC)'
;
;;*******FULL NDVI Timeseries (supplemental)*********************************************
;ifile = file_search('/raid/chg-mcnally/NDVI_WK_TK_AVG_2006_2011.csv')
;ndvi = read_csv(ifile)
;wk=ndvi.field1
;tk=ndvi.field2
;avg=ndvi.field3
;
;p1 = plot(wk, thick = 3, font_size = 20, name = 'Wankama',xminor = 0, yminor = 0,xrange = [0,216], $
;          xtickvalues = [ 18, 54, 90, 126, 162, 198  ], xtickinterval = 36 )
;p2 = plot(tk, thick = 3, /overplot, 'black', linestyle = 2, name = 'Tondi_Kiboro')
;
;xticks = ['Jun-06','Jun-07','Jun-08','Jun-09','Jun-10','Jun-11']
;p2.xtickname= xticks
;p2.xtickfont_size = 20
;p2.ytickfont_size = 20
;null = legend(target=[p1,p2], position=[0.2,0.3], font_size=16, font_name='times') ;
;p1.ytitle = 'soil moisture (%VWC)'
;
;;*****************************************************************************************


  
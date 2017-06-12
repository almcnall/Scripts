;the purpose of this script is to make the plots for the paper.

;****************************************************************
;read in the observed soil moisture data
ifile = file_search('/jabber/Data/mcnally/AMMASOIL/observed_TKWK1WK2.csv')
soil = read_csv(ifile)
wk140 = float(soil.field1)
wk170 = float(soil.field2) ;the weird one
wk240 = float(soil.field3) 
wk270 = float(soil.field4) 
tk40 = float(soil.field5) 
tk70 = float(soil.field6)
avg144 = mean([transpose(wk140),transpose(wk170),transpose(wk240), transpose(wk270), transpose(tk40), transpose(tk70)],$
              /nan, dimension = 1)
              
;p1 = plot(avg144,wk140,'c+', name = 'wankama 140')
;p2 = plot(avg144,wk170,'b+', /overplot,  name = 'wankama 170')
;p3 = plot(avg144,wk240,'*', /overplot, name = 'wankama 240')
;p4 = plot(avg144,wk270,'+', /overplot, name = 'wankama 270')
;p5 = plot(avg144,tk40,'m+', /overplot, name = 'tondi kiboro 40')
;p6 = plot(avg144,tk70,'r+', /overplot, name = 'tondi kiboro 70')
;p7 = plot(avg144,avg144,'.',sym_size = 28,sym_filled = 1,title = 'correlation between sites and the mean', /overplot, $
;          xminor = xminor, yminor = 0, font_size = 18)
;null = legend(target=[p1,p2,p3,p4,p5,p6,p7], position=[0.2,0.3]) ;

titlefont_size = 24
xtickinterval = 36
xminor = 0
xtickvalues = [ 18, 54, 90, 126  ]
xticks = ['05','06',  '07','08']
fontsize = 14
xrange = [0,144]
yrange = [0.015, 0.125]

;********read in the UB RFE-API and filtered NDVI data *************
;ifile = file_search('/jabber/LIS/Data/API_sahel/APIsahel_*') ;individual ubrfe API files (not pre-stacked)
ifile = file_search('/jabber/Data/mcnally/API_soilmoisture_2001_2011.img')
vfile = file_search('/jabber/Data/mcnally/AMMAVeg/mask_bare75_sahel.img') ;bare soil mask
nfile = file_search('/jabber/Data/mcnally/filterNDVI_soilmoisture_2001_2011.img');cube of filtered NDVI
cfile = file_search('/jabber/Data/mcnally/filterNDVI_APIcorr.img') ;correlation between API and filtered NDVI
nichol = file_search('/jabber/Data/mcnally/NDVI_UBRFcorr.img') ;correlation between 8dek rain and NDVI
rfile = file_search('/jabber/Data/mcnally/FCLIMshael_rainmask4NDVI.img') ;masks 150-1200m of rainfall

nx = 720
ny = 350
nz = 396

apigrid = fltarr(nx,ny,nz-2)
filtered = fltarr(nx,ny,nz-6)
vegmask = fltarr(nx,ny)
ANcorr = fltarr(nx,ny)
PNcorr = fltarr(nx,ny)
rmask = intarr(nx,ny)

;read in veg mask and filteredNDVI outside o' loop
openr,1,vfile
readu,1,vegmask
close,1
vegmask(where(vegmask eq 0.))=!values.f_nan

;readin rain mask
openr,1,rfile
readu,1,rmask
close,1
rmask= float(rmask)
out = where(rmask eq 0)
rmask(out)=!values.f_nan
;read in API-NDVI correlation
openr,1,cfile
readu,1,ANcorr
close,1

;read in Precip-NDVI correlation
openr,1,nichol
readu,1,PNcorr
close,1

openr,1,nfile
readu,1,filtered
close,1

openr,1,ifile
readu,1,apigrid
close,1

;************figure 1 ******************************************************
;**************************************************************************
avgwk140 = mean(reform(wk140,36,4), dimension = 2,/nan)
avgwk170 = mean(reform(wk170,36,4), dimension = 2,/nan)
avgwk240 = mean(reform(wk240,36,4), dimension = 2,/nan)
avgwk270 = mean(reform(wk270,36,4), dimension = 2,/nan)
avgtk40 = mean(reform(tk40,36,4), dimension = 2,/nan)
avgtk70 = mean(reform(tk70,36,4), dimension = 2,/nan)

;p1 = plot(avgwk140, thick = 3, 'r', font_size = 16, name = 'Wk1 40cm')
;p2 = plot(avgwk170, thick = 3, /overplot, 'r', linestyle = 2, name = 'Wk1 70cm')
;p3 = plot(avgwk240, thick = 3, /overplot,'b', name = 'Wk2 40cm')
;p4 = plot(avgwk270, thick = 3, /overplot,'b', linestyle = 2, name = 'Wk1 70cm')
;p5 = plot(avgtk40, thick = 3, /overplot,'g', name = 'TK 40cm')
;p6 = plot(avgtk70, thick = 3, /overplot,'g', linestyle = 2, name = 'TK 70cm')
;p4.title = '2005-2008 average soil mositure at 3 sites'
;p4.xminor = 0
;p4.yminor = 0
;p4.xrange = [10, 35]
;p4.xtickvalues = [10+2, 15+2, 20+2, 25+2, 30+2]
;xticks = ['21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov']
;p4.xtickname = xticks
;p4.title.font_size = 18
;null = legend(target=[p1,p2,p3,p4,p5,p6], position=[0.2,0.3]) ;

;**********include a figure on fitting the API************
; use avg144
afile = file_search('/jabber/Data/mcnally/AMMASOIL/API_ubrf_niger')
api = read_csv(afile)
api = api.field1

xticks = ['Jun-05','Jun-06','Jun-07','Jun-08']
p1 = plot(api, thick = 3, name = 'ubrfe API', xminor = 0, yminor = 0,xrange = [0,144], $
 xtickvalues = [ 18, 54, 90, 126  ], xtickinterval = 36 ,font_size = 14, linestyle = 2)
 p1.xtickname= xticks
p1.xtickfont_size = 18
p1.ytickfont_size = 18
p2 = plot(avg144, thick = 2, name = 'observed SM', 'b', /overplot)
null = legend(target=[p1,p2], position=[0.2,0.3], font_size=18) ;

print, correlate(api, avg144)
p3 = plot(avg144, api,'*')
 print, 100*(1-norm(avg144-API)/norm(avg144-mean(avg144, /nan))) 
;********************************************************************************
;;*******************************************************************************
;KLEE 10/5/2011 - 11/14/2012 COSMOS_50=MPALA 9/6/2011 (Sept dek1) - 10/27/2012 (Oct dek3)

mapi = read_csv('/jabber/Data/mcnally/AMMASOIL/API_ubrf_mpala.csv')
soil = mapi.field1
api = mapi.field2
xticks = ['sept-11','nov-11','jan-12','mar-12', 'may-12','jul-12','sept-12']
p1 = plot(api, thick=3, linestyle = 2, name = 'ubrfe API',xtickinterval = 6)
 p1.xtickname= xticks
p2 = plot(soil, thick=3, 'b', /overplot, name = 'observed SM')
p1.xtickfont_size = 18
p1.ytickfont_size = 18
null = legend(target=[p1,p2], position=[0.2,0.3], font_size=18) ;
print, 100*(1-norm(soil-API)/norm(soil-mean(soil, /nan))) 

kapi = read_csv('/jabber/Data/mcnally/AMMASOIL/API_ubrf_KLEE.csv')
soil = kapi.field1
api = kapi.field2
xticks = ['oct-11','dec-11','feb-12','apr-12', 'jun-12','aug-12','oct-12']
p1 = plot(api, thick=3, linestyle = 2, name = 'ubrfe API',xtickinterval = 6)
 p1.xtickname= xticks
p2 = plot(soil, thick=3, 'b', /overplot, name = 'observed SM')
p1.xtickfont_size = 18
p1.ytickfont_size = 18
null = legend(target=[p1,p2], position=[0.2,0.3], font_size=18) ;
print, 100*(1-norm(soil-API)/norm(soil-mean(soil, /nan))) 
;plot the average NDVI and rainfall (stations and 250m too! just so i know how they vary)
; these axis are going to be unpleasent, no?
;rfile = file_search('/jabber/Data/mcnally/AMMARain/RFE_UBRFE_and_station_dekads.csv')
;rain = read_csv(rfile)
;ubrf = rain.field2
;ubrf = mean(reform(ubrf,36,4),dimension=2, /nan)
kfile = file_search('/jabber/Data/mcnally/AMMASOIL/KLEE_dekad.csv')
mfile = file_search('/jabber/Data/mcnally/AMMASOIL/Mpala_dekad.csv')


nfile = file_search('/jabber/Data/mcnally/AMMAVeg/avergeNDVI_WK12MF_TK.csv')
ndvi = read_csv(nfile)

wk1 = ndvi.field1
wk2 = ndvi.field3
tk = ndvi.field5
navg144 = mean([transpose(wk1), transpose(wk2), transpose(tk)], /nan, dimension = 1)
navg = mean(reform(navg144, 36,4), dimension = 2, /nan)
;from figure 1.....
savg144 = mean([transpose(wk140), transpose(wk170), transpose(wk240), transpose(wk270),$
             transpose(tk40), transpose(tk70)], dimension = 1, /nan)
savg = reform(mean([transpose(wk140), transpose(wk170), transpose(wk240), transpose(wk270),$
             transpose(tk40), transpose(tk70)], dimension = 1, /nan),36,4)
savg = mean(savg,dimension = 2, /nan)   

;p2 = plot(savg, thick = 3, 'orange', name = 'soil moisture', /overplot, $)
;         MARGIN = [0.15,0.2,0.15,0.1], $
;         xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
;         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'],$
;         AXIS_STYLE=0, yminor = 0)
;yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='Average SM (mm)', $
;       TEXTDIR=0, TEXTPOS=1,YCHARSIZE=14)
;p1 = plot(navg, thick = 3, 'g', name = 'ndvi', xminor = 0, yminor = 0, $
;         MARGIN = [0.15,0.2,0.15,0.1], $
;         xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
;         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'],$
;         YTITLE='NDVI',AXIS_STYLE=1,/CURRENT,/NOERASE)
;lgr2 = LEGEND(TARGET=[p1, p2])
;p2.yminor = 0
;p1.xtickfont_size=14
;p1.ytickfont_size=16

;now regress them...
Y = savg[0:34]
X = [ transpose(navg[0:34]),transpose(navg[1:35]) ]
reg = regress(X,Y,const=const,correlation=corr,yfit=yfit) & print, const, corr

;p1 = plot(savg,thick = 3, 'orange', name = 'soil moisture', /overplot,$
;          xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
;         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'], yminor = 0)
;p2 = plot(yfit,/overplot, linestyle=2,thick = 3,'g',xminor=0, name = 'filtered NDVI')
;lgr2 = LEGEND(TARGET=[p1, p2], font_size=16)
;p1.xtickfont_size=16
;p1.ytickfont_size=16
;p1.ytitle='soil moisture (mm)'
print, 100*(1-norm(savg-yfit)/norm(savg-mean(savg, /nan))) ;72

;*****combine the previous to plots with SM on the left axis and NDVI on the new right one.
p2 = plot(navg, thick = 3, 'g', name = 'NDVI', /overplot, $)
         xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'],$
         MARGIN = [0.15,0.2,0.15,0.1], $
         AXIS_STYLE=0, yminor = 0)
yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='NDVI', $
       TEXTDIR=0, TEXTPOS=1,YCHARSIZE=14)
p1 = plot(savg, thick = 3, 'orange', name = 'SM', xminor = 0, yminor = 0, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'],$
         YTITLE='SM',AXIS_STYLE=1,/CURRENT,/NOERASE)
p3 = plot(yfit, thick = 3, linestyle = 2, 'g',name ='filtered NDVI', /overplot)
lgr2 = LEGEND(TARGET=[p1, p2, p3], font_size=16)
p1.xtickfont_size=16
p1.ytickfont_size=16
p1.ytitle='soil moisture (mm)'
print, 100*(1-norm(savg-yfit)/norm(savg-mean(savg, /nan))) ;72

;**********fit the longer time series?************************
est = const+reg[0]*navg144[0:142]+reg[1]*navg144[1:143]
print, 100*(1-norm(savg144-est)/norm(savg144-mean(savg144, /nan))) ;40

xticks = ['Jun-05','Jun-06','Jun-07','Jun-08']
p1 = plot(est, thick = 3, name = 'filtered NDVI', xminor = 0, yminor = 0,xrange = [0,144], $
 xtickvalues = [ 18, 54, 90, 126  ], xtickinterval = 36 ,font_size = 14, linestyle = 2)
 p1.xtickname= xticks
p1.xtickfont_size = 18
p1.ytickfont_size = 18
p2 = plot(savg144, thick = 2, name = 'observed SM', 'b', /overplot)
null = legend(target=[p1,p2], position=[0.2,0.3], font_size=18) ;
p1.ytitle = 'soil moisture (mm)'
;************************************************************************************************************
;       
;************make cummulative precip at a point*****************************
;;orginal file made in 
rfile = file_search('/jabber/Data/mcnally/AMMARain/RFE_UBRFE_and_station_dekads.csv')
rain = read_csv(rfile)

;first cube into years
RFE = transpose(reform(rain.field1,36,4))
UBRFE = transpose(reform(rain.field2,36,4))
station = transpose(reform(rain.field3,36,4))

cum = fltarr(4,36)
for y = 0,n_elements(RFE[*,0])-1 do begin &$
  for i = 0,n_elements(RFE[0,*])-1 do begin &$
    cum[y,0] = RFE[y,0] &$
    cum[y,i] = cum[y,i-1] + RFE[y,i] &$
  endfor &$
endfor  

temp1 = plot(cum[0,*],'r', layout = [3,1,1] )
temp2 = plot(cum[1,*],'orange', /overplot)
temp3 = plot(cum[2,*],'green', /overplot)
temp4 = plot(cum[3,*],'blue', /overplot)


;***make map of filtered NDVI -- 9 yrs of data 2001-2011?***********
;*******check and see if my filter still works moving from matlab to IDL
  ndvi = file_search('/jabber/Data/mcnally/AMMAVeg/avergeNDVI_WK12MF_TK.csv')
  ndvi = read_csv(ndvi)
  b =   [0.0005, -0.3615, 0.5924]
  temp = ndvi.field1
  filtered = b[0]+ b[1]*temp[0:144-1] + b[2]*temp[1:144-2] 
  p1 = plot(ndvi.field1)
  p1 = plot(filtered,/overplot,'g')



 p1 = image((PNcorr-ANcorr)*rmask, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table=4)
;Mpala Kenya:
xind = FLOOR((36.8701 + 20.) / 0.10)
yind = FLOOR((0.4856 + 5) / 0.10)
print, PNcorr[xind,yind] ;Mpala - 0.65
print, ANcorr[xind,yind]; Mpala - 0.66
print, rmask[xind,yind]

;;KLEE Kenya
xind = FLOOR((36.8669 + 20.) / 0.10)
yind = FLOOR((0.2825 + 5) / 0.10)
print, PNcorr[xind,yind]; KLEE 0.73
print, ANcorr[xind,yind]; KLEE 0.74
print, rmask[xind,yind]

;Wankama Niger
xind = FLOOR((2.633 + 20.) / 0.10)
yind = FLOOR((13.6454 + 5) / 0.10)
print, PNcorr[xind,yind]; WK 0.87
print, ANcorr[xind,yind]; WK 0.85
print, rmask[xind,yind]

;;Joel's locations in Ethiopia: Interesting that these are the least predictable....
;joel's location is not within the 150-1200m threshold.
W = 36.25
N = -2
xind = FLOOR((W + 20.) / 0.10)
yind = FLOOR((N + 5) / 0.10)
print, PNcorr[xind,yind]; Joel 0.03
print, ANcorr[xind,yind]; Joel 0.12 
print, rmask[xind,yind]
;****check out regions in ethiopia and kenya where correspodance is low should be bimodal
;;read in Caylor's Mpala data

mfile = file_search('/jabber/Data/mcnally/AMMASOIL/Mpala_dekad.csv') ;length 72 array change to 36 and compare with avg API and filtered
kfile = file_search('/jabber/Data/mcnally/AMMASOIL/KLEE_dekad.csv')
ifile = file_search('/jabber/LIS/Data/API_sahel/APIsahel_*') ;individual ubrfe API files (not pre-stacked)
nfile = file_search('/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/sahel/data.{2011,2012}*.img')

nx = 720
ny = 350
nz = n_elements(ifile)
nnz = n_elements(nfile)

apigrid = fltarr(nx,ny,nz-2)
;make a stack of NDVI to pull out the sites of interest...
veggrid = fltarr(nx,ny,72)
veggrid[*,*,*] = !values.f_nan
buffer = fltarr(nx,ny)
for i = 0,n_elements(nfile)-1 do begin &$
  openr,1,nfile[i] &$
  readu,1,buffer &$
  close,1 &$
  ;I should pad out rest of veg grid...I can just make the array bigger
  veggrid[*,*,i] = buffer &$
endfor

result = read_csv(mfile)
mpala = float(result.field1)

result = read_csv(kfile)
KLEE = float(result.field1)

mpala = mean(reform(mpala,36,2), dimension =2, /nan);scale is totally off!
KLEE = mean(reform(KLEE,36,2), dimension =2, /nan);scale is totally off!

;Mpala Kenya:
mxind = FLOOR((36.8701 + 20.) / 0.10)
myind = FLOOR((0.4856 + 5) / 0.10)

;;KLEE Kenya
kxind = FLOOR((36.8669 + 20.) / 0.10)
kyind = FLOOR((0.2825 + 5) / 0.10)

p1 = plot(veggrid[mxind,myind,*])
p2 = plot(veggrid[kxind,kyind,*], /overplot, 'g')

mveg = veggrid[mxind,myind,*]
kveg = veggrid[kxind,kyind,*]
nout = reform([mveg,kveg],2,72)

ofile = '/jabber/Data/mcnally/AMMAVeg/NDVI_mpala_klee_2011_2012.csv'
write_csv,ofile,nout/

;not ideal to have to run the API grid every time.
season = reform([[[apigrid[xind,yind,*]]],[[fltarr(1,1,2)]]],36,11)
season(where(season eq 0)) = !values.f_nan
seasonmean = mean(season,dimension = 2, /nan)

nfseason = reform([[[filtered[xind,yind,*]]],[[fltarr(1,1,6)]]],36,11)
nfseason(where(nfseason eq 0)) = !values.f_nan
nfseasonmean = mean(nfseason,dimension = 2, /nan)

nseason = reform([[[cube[xind,yind,*]]],[[fltarr(1,1,4)]]],36,11)
nseason(where(nseason eq 0)) = !values.f_nan
nseasonmean = mean(nseason,dimension = 2, /nan)


p3 = plot(KLEE,thick = 3,name = 'observ',/overplot,  $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'],$
         AXIS_STYLE=0, yminor = 0,/CURRENT,/NOERASE)
yax2 = AXIS('Y',LOCATION=[MAX(p3.xrange),0],TITLE='obs (VWC %)', $
       TEXTDIR=0, TEXTPOS=1,YCHARSIZE=14)
p1 = plot(seasonmean, thick = 3,  name = 'API', xminor = 0, yminor = 0, linestyle = 2, 'orange', $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'],$
         YTITLE='API & filtered NDVI',AXIS_STYLE=1,/CURRENT,/NOERASE)
p2 = plot(nfseasonmean, thick = 3, linestyle = 2, 'g', name='filtered NDVI', /overplot)
p1.xtickfont_size = 16
p1.ytickfont_size = 18
p1.title = 'API & filtered NDVI vs Observed @ KLEE'
p4 = plot(nseasonmean, title='NDVI seasonal mean at Mpala, Kenya 2001-2011')
p1.title.font_size = 24


;*************************************************************************
;find out where ndvi-precip doen't agree with ndvi-api
; temp=fltarr(nx,ny)
;;this is truncated a little becasue the NDVI is only goes to 390 (Nov 2011)
;for i = 0, n_elements(ifile)-7 do begin &$
;  openr,1,ifile[i] &$
;  readu,1,temp &$
;  close,1 &$
;  ;these were made in matlab (I think?) so need to be flipped.
;  temp = reverse(temp,2) &$
;  ;temp = temp*vegmask &$
;  ;test = image(temp, rgb_table = 4)
;  apigrid[*,*,i] = temp &$
;endfor
;
;;write out the apigrid so that i never have to run this section of code again
;ofile = '/jabber/Data/mcnally/API_soilmoisture_2001_2011.img'
;openw,1,ofile
;writeu,1,apigrid
;close,1


p1 = plot(apigrid[xind,yind,*])
p1 = plot(filtered[xind,yind,*])

cormap = fltarr(nx,ny) 
print, cormap[xind,yind]
;

;read in the big cube of rainfall data so i can check out the correponding timeseries.
ifile=file_search('/jabber/LIS/Data/ubRFE2/dekads/sahel_2001_2011.img')
z = 396
sahelarray = fltarr(nx,ny,z)
openr,1,ifile
readu,1,sahelarray
close,1

;might want to average this so i can see the typical seasonal cycle
p1 = plot(cube[xind,yind,*]*10, /overplot)
p2 = plot(sahelarray[xind,yind,*], /overplot,'b')

;add some spacers so i can cube the yr
pad = fltarr(1,1,4)
ethNDVI = mean(reform([[[cube[xind,yind,*]]], [[pad]]],36,11),dimension=2,/nan)
ethRFE = mean(reform(sahelarray[xind,yind,*],36,11),dimension=2,/nan)
p1.title = 'rainfall and NDVI climatology at 7N, 37E'
p1.title.font_size =24
ethNVI = transpose(reform(ethNDVI,36,11))



;**********************pull and total JAS dekads 16-24 for each year*******************************
;;**********************************************WRSI comparison***********************************
;reshape to nx,ny,36 * 11
pad = fltarr(nx,ny,2)
pad[*,*,*] = !values.f_nan
apipad = [[[apigrid]], [[pad]]]
pad = fltarr(nx,ny,6)
filterpad = [[[filtered]], [[pad]]]

apistack = reform(apipad,nx,ny,36,11)
filterstack = reform(filterpad,nx,ny,36,11)
;p1 = plot(apistack[xind,yind,19:27,0],'r', name = '2001') ;2001
;p2 = plot(apistack[xind,yind,19:27,1],'orange', /overplot,name = '2002');2002
;p3 = plot(apistack[xind,yind,19:27,2],'yellow',/overplot,name = '2003');2003 sort of wet...
;p4 = plot(apistack[xind,yind,19:27,3],'g', /overplot,name = '2004');2004
;p5 = plot(apistack[xind,yind,19:27,4],'b', /overplot,name = '2005');2005
;p6 = plot(apistack[xind,yind,19:27,5],'c', /overplot,name = '2006');2006
;p7 = plot(apistack[xind,yind,19:27,6],'m', /overplot,name = '2007');2007-- wet, yay!
;p8 = plot(apistack[xind,yind,19:27,7],'black', /overplot,name = '2008');2008
;p9 = plot(apistack[xind,yind,19:27,8],'r', linestyle = 2 ,/overplot,name = '2009');2009 supposed to be dry
;p10 = plot(apistack[xind,yind,19:27,9],'orange',linestyle = 2 , /overplot,name = '2010');2010
;p11 = plot(apistack[xind,yind,19:27,10],'g',linestyle = 2 , /overplot,name = '2011');2011 supposed to be dry?
;p12 = plot(mean(apistack[xind,yind,19:27,*], dimension = 4, /nan), thick = 3, /overplot,name = 'mean')
;p12.thick= 12
;p1.title = 'API 2001-2011 and mean'
;!null = legend(target=[p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12], position=[0.2,0.3]) ;
;xticks = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec' ]
;xticks = ['19','20','21','22','23','24','25','26','27']
;p1.xtickname = xticks

;get the totals for S
t1 = fltarr(nx,ny,11);API
t2 = fltarr(nx,ny,11);filtered NDVI
st1 = fltarr(nx,ny,11);API
st2 = fltarr(nx,ny,11);filtered NDVI
for y = 0,11-1 do begin &$
  t1[*,*,y] = mean(apistack[*,*,22:24,y],dimension=3,/nan) &$ ;API
  t2[*,*,y] = mean(filterstack[*,*,22:24,y],dimension=3,/nan) &$ ;filtered NDVI
  st1[*,*,y] = stddev(apistack[*,*,22:24,y],dimension=3,/nan) &$ ;API
  st2[*,*,y] = stddev(filterstack[*,*,22:24,y],dimension=3,/nan) &$ ;filtered NDVI
endfor 

temp = image(st2[*,*,9], rgb_table=10)

temp.title = 'stddev NDVI filter 2009'
x = indgen(11)
y = mean(total(apistack[xind,yind,19:27,*],3, /nan), dimension=3) & print, y
yy = fltarr(11)
yy[*] = y

p1 = plot(t1)
p1 = barplot(x,t1-yy)
p1.title = 'JAS API anomalies SW Niger 2001-2011'
p1.xtickinterval = 1
;p1.xminor = 0
xticks = ['','01','02','03','04','05','06','07','08','09','10','11','']
p1.xtickname = xticks

;map the years that chris suggested...2003,2009, hari's analysis is 2007
 diff1 = (t1[*,*,2])-(t1[*,*,8]);API
 diff2 = (t2[*,*,2])-(t2[*,*,8]);NDVI
 
 max1 = max(diff1(where(finite(diff1)))) & print, max1
 max2 = max(diff2(where(finite(diff2)))) & print, max2
 
 min1 = min(diff1(where(finite(diff1)))) & print, min1
 min2 = min(diff2(where(finite(diff2)))) & print, min2
 
 maxx = min([max1,max2]) & print, maxx
 ;minx = max([min1,min2]) & print, minx
 minx = -0.2
 ;messing with the data....
 diff1(where(diff1 ge maxx))= maxx
 diff2(where(diff2 ge maxx))= maxx
 
 diff1(where(diff1 le minx))= minx
 diff2(where(diff2 le minx))= minx
 
 ;color table 5 is pretty good. 
 p1 = image(diff1*wmask, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 10)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  p1.title = 'Aug API 2003(wet) - 2009(dry)'
  p1.title.font_size=14
;Joel's locations in Ethiopia:
xind = FLOOR((37 + 20.) / 0.10)
yind = FLOOR((7 + 5) / 0.10)

;*******************************************************************



;ndvi should pick up bimodal where as the 60day lag for API does't work.
p1 = plot(apigrid[xind,yind,*])
p2 = plot(filtered[xind,yind,*],/overplot,'g') 

p1.title = 'filtered-NDVI and API at Wankama'; Mpala,0.48N, 36.8E'
p1.title.font_size = 24
p1.xtickinterval = 36
p1.xminor = 0
p1.xtickvalues = [18, 54, 90,   126, 162, 198,   234, 270, 306,   342, 378]
xticks = ['01-Jun','02-Jun','03-Jun','04-Jun','05-Jun','06-Jun','07-Jun','08-Jun','09-Jun','10-Jun','11-Jun']
p1.xtickname = xticks
p1.ytitle = 'soil moisture (mm)'
p1.name = 'ubRFE2 API'
p2.name = 'filtered NDVI'
!null = legend(target=[p1,p2], position=[0.2,0.3]) ;


;p1 = plot(apigrid[xind,yind,*],filtered[xind,yind,*],'+')
print, correlate(apigrid[xind,yind,*],filtered[xind,yind,*])

;what are the indexes for october 2011-november 2012? Ah! I don't have data here! could pull from elsewhere.
;look at average seasonal cycle for now?


;;well correlate apigrid and filtered grid and see what we get....
;for x = 0,nx-1 do begin &$
;  for y = 0,ny-1 do begin &$
;    rsq = correlate(apigrid[x,y,0:389], filtered[x,y,*]) &$
;    ;rsq = correlate(apigrid[xind,yind,*], filtered[xind,yind,*]) &$
;    cormap[x,y] = rsq &$
;  endfor &$
;endfor

;ofile = '/jabber/Data/mcnally/filterNDVI_APIcorr.img'
;openw,1,ofile
;writeu,1,cormap
;close,1

;scatter plot to show deviation from the mean is not much
p1 = plot(navg, wk1,'r+', name = 'wankama 1')
p2 = plot(navg, wk2,'b*', /overplot, name = 'wankama 2')
p3 = plot(navg, tk, '+',/overplot, name = 'tondi kiboro')
p4 = plot(navg, navg, '.', xminor = 0, yminor = 0,sym_size = 18,/overplot, $
          sym_filled = 1,title = 'correlation between sites and the mean ndvi', font_size = 18 )
p4.title.font_size = 20
p2.xtickfont_size = 16
null = legend(target=[p1,p2,p3], position=[0.2,0.3]) ;


p1 = plot(wk140, thick = 3, linestyle = 3, 'c', name = '40cm', $
          layout = [3,1,1], title = 'Wankama 1', font_size = fontsize, xminor = xminor, $
          xtickinterval = xtickinterval, xtickvalues = xtickvalues) & p1.xtickname = xticks
p2 = plot(wk170, thick = 3, linestyle = 5, 'b', name = '70cm', /overplot, $
          xrange = xrange, yrange = yrange, /PALATINO)

p3 = plot(wk240, thick = 3, linestyle = 3, 'c', name = 'Wankama 2 @ 40cm', $
           layout = [3,1,2], title = 'Wankama 2', font_size = fontsize, xminor = xminor, /current, $
           xtickinterval = xtickinterval, xtickvalues = xtickvalues) & p3.xtickname = xticks
p4 = plot(wk270, thick = 3, linestyle = 5, 'b', name = 'Wankama 2 @ 70cm', /overplot, $
          xrange = xrange, yrange = yrange) 

p5 = plot(tk40, thick = 3, linestyle = 3, 'c', name = 'Tondi Kiboro @ 40cm', $
           layout = [3,1,3], title = 'Tondi Kiboro', font_size = fontsize, xminor = xminor, /current, $
            xtickinterval = xtickinterval, xtickvalues = xtickvalues) & p5.xtickname = xticks
p6 = plot(tk70, thick = 3, linestyle = 5, 'b', name = 'Tondi Kibroro @ 70cm', /overplot, $
          xrange = xrange, yrange = yrange)
p1.SET_FONT='Palatino-Roman'

soilavg = mean([[soil.field1],[soil.field2], [soil.field3],[soil.field4], [soil.field5],[soil.field6]], dimension =2, /nan)
soilstm = mean(reform(soilavg,36,4),dimension = 2, /nan)

;*********make short term mean maps for calculating anomalies**********************************
;******and comparing wet vs dry maps for filtered NDVI, API, WRSI******************************


pad = fltarr(nx,ny,2)
pad[*,*,*] = !values.f_nan
apipad = [[[apigrid]], [[pad]]]

apistm = mean(reform(apipad,nx,ny,36,11),dimension=4,/nan)
apicube = reform(apipad,nx,ny,36,11)

pad = fltarr(nx,ny,6)
filterpad = [[[filtered]], [[pad]]]
filterstm = mean(reform(filterpad,nx,ny,36,11),dimension=4,/nan)
filtercube = reform(filterpad,nx,ny,36,11)
;calculate the Sept 2003 and Sept 2009 anomalies (25-27)
api2003 = (apicube[*,*,26,2]-apistm[*,*,26])*wmask 
filter2003 = (filtercube[*,*,26,2]-filterstm[*,*,26])*wmask 
api2009 = (apicube[*,*,26,8]-apistm[*,*,26])*wmask 
filter2009 = (filtercube[*,*,26,8]-filterstm[*,*,26])*wmask 

 minx = min([api2003,api2009,filter2003,filter2009],/nan) & print, minx
 ;maxx = max([api2003,api2009,filter2003,filter2009],/nan) & print, maxx
 maxx = 0.05
 api2003[0,0] = minx 
 api2009[0,0] = minx
 filter2003[0,0] = minx
 filter2009[0,0] = minx
  api2003[1,0] = maxx 
 api2009(where(api2009 gt maxx))=maxx
 ;filter2003[1,0] = maxx
 filter2009(where(filter2009 gt maxx)) = maxx
 filter2003(where(filter2003 gt maxx)) = maxx
 
p1 = image(filter2003, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 10)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])             
p1.title = 'Filtered NDVI 2003 Anomaly'
p1.title.font_size = 16
p1.save,strcompress('/jabber/sandbox/mcnally/'+p1.title.string+'.jpg', /remove_all),RESOLUTION=200

;read in the wrsi anomaly (and soil water index anomaly?)

;check out the time series at wankama
p1 = plot(apistm[xind,yind,*])
p2 = plot(filterstm[xind,yind,*], 'g', /overplot)
p3 = plot(soilstm,'b',/overplot);plot the observed mean while i am at it.
p1.xtickinterval = 12
p1.xminor = 0
p1.xtickvalues = [0, 4-1, 7-1, 10-1, 13-1, 16-1, 19-1, 22-1, 25-1, 28-1,31-1, 34-1 ]
xticks = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec' ]
p1.xtickname = xticks
p1.title = 'averge seasonal API, filtered NDVI and observed soil moisture: SW Niger'
p1.name = 'API'
p2.name = 'filtered NDVI'
p3.name = 'observed SM'
!null = legend(target=[p1,p2,p3], position=[0.2,0.3]) ;
p1.title.font_size = 18


;************rainfall v rainfall plots****************************
temp = plot(rain.field1);RFE
temp2 = plot(rain.field2, /overplot, 'b');UBRFE
temp3 = plot(rain.field3, /overplot, 'g');station
temp.title = 'RFE, UBRFE and station rainfall SW Niger 2005-2008'
temp.ytitle = 'rainfall (mm/dekad)' 
temp.name = 'RFE'
temp2.name = 'UBRFE'
temp3.name = 'station'
!null = legend(target=[temp, temp2, temp3], position=[0.2,0.3]) 

temp = plot(rain.field1, rain.field2, '+', layout=[1,3,1], title='RFE v UBRF, RSQ=0.91')
temp1 = plot(rain.field1, rain.field3, '+', layout=[1,3,2], title='RFE v station, RSQ=0.76', /current)
temp2 = plot(rain.field2, rain.field3, '+', layout=[1,3,3], title='UBRFE v station, RSQ=0.76', /current)

temp.title = 'RFE vs UBRFE, RSQ = 0.91'
temp.xtitle = 'RFE'
temp.ytitle = 'UBRFE'
result=regress(rain.field1, rain.field2,correlation=rsq,yfit=yfit)
result=regress(rain.field2, rain.field3,correlation=rsq,yfit=yfit) & print, rsq

p1 = plot(data1, layout=[2,3,1])
p2 = plot(data2, layout=[2,3,2], /current)

;Wankama Niger
;xind = FLOOR((2.633 + 20.) / 0.10)
;yind = FLOOR((13.6454 + 5) / 0.10)

;;Joel's locations in Ethiopia:
;xind = FLOOR((37 + 20.) / 0.10)
;yind = FLOOR((7 + 5) / 0.10)


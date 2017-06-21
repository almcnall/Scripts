pro amma2013_datacompare

;just load in the whole dataset and pull out the latlons of interest, no?

;check on the new ubRFE data

;get a new rainfall time series for the API...
;rfile = file_search('/jabber/LIS/Data/ubRFE04.19.2013/dekads/sahel/{2006,2007,2008,2009,2010,2011,2012}*.img') & print, rfile
;rfile = file_search('/jabber/LIS/Data/CPCOriginalRFE2/dekads/sahel/{2006,2007,2008,2009,2010,2011,2012}*.img') & print, rfile
ifile = file_search('/home/sandbox/people/mcnally/RFE2_sahel/dekads/data.20{01,02,03,04,05,06,07,08,09,10,11,12,13}*.tiff')

nx = 720
ny = 350
nz = n_elements(rfile)
temp = fltarr(nx,ny)
ingrid = fltarr(nx,ny,nz)

for i = 0, n_elements(rfile)-1 do begin &$
  openr,1,rfile[i] &$
  readu,1,temp &$
  close,1 &$
  
  ingrid[*,*,i] = temp &$
endfor

ubrfegrid = ingrid; save as new var so i can read in other RFE
rfe2grid = ingrid

;Wankama 2006 - 2011
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Tondikiboro 2006-2011
txind = FLOOR((2.6956 + 20.) / 0.10)
tyind = FLOOR((13.548 + 5) / 0.10)

;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5) / 0.10)

agubrf = ubrfegrid[axind, ayind, *]

;ofile = strcompress('/jabber/chg-mcnally/AMMARain/Agoufou_UBRFE_amma2013.csv')
;write_csv, ofile, agubrf

wkubrf = ubrfegrid[wxind, wyind, *]
tkubrf = ubrfegrid[txind, tyind, *]

wkrf = rfe2grid[wxind, wyind, *]
tkrf = rfe2grid[txind, tyind, *]

out = [transpose(wkrf), transpose(tkrf), transpose(wkubrf), transpose(tkubrf)]
;ofile = strcompress('/jabber/chg-mcnally/AMMARain/WKRFE_TKRFE_WKUBRF_TKUBRF_amma2013.csv')
;write_csv, ofile, out

p1 = plot(wkubrf, 'red', /overplot)
p2 = plot(tkubrf, 'orange', /overplot)



;this is a good place to pull out the NDVI timeseries too.
;ffile = file_search('/jabber/chg-mcnally/filterNDVI_sahel/filterNDVI_soilmoisture_200101_2012.10.2.img')
;f3file = file_search('/jabber/chg-mcnally/filterNDVI_soilmoisture_2001Jan_2012Oct_lag3.img')
;f2file = file_search('/jabber/chg-mcnally/filterNDVI_soilmoisture_2001Jan_2012Oct_lag2.img')
nfile = file_search('/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/sahel/data*.img')
;afile = file_search('/jabber/chg-mcnally/sahel_API_200101_201232.img')

nx = 720
ny = 350
nz = 12*36
nnz = 425
nnnz = 424

filter2  = fltarr(nx,ny,nnnz)
filter3  = fltarr(nx,ny,nnnz)
apigrid = fltarr(nx,ny,428)

openr,1,afile
readu,1,apigrid
close,1

ingrid = fltarr(nx,ny)
ndvi = fltarr(nx,ny,nz)
ndvi[*,*,*] = !values.f_nan

for i = 0, n_elements(nfile)-1 do begin &$
  openr,1,nfile[i] &$
  readu,1,ingrid &$
  close,1 &$
  
  ndvi[*,*,i] = ingrid &$
endfor
openr,1,f2file
readu,1,filter2
close,1

openr,1,f3file
readu,1,filter3
close,1

;pad = fltarr(nx,ny,7)
;pad[*,*,*] = !values.f_nan
;filter2 =[ [[filter]], [[pad]] ]

;figure out what the time frames are, plot and fit
;print, 1-total((savg144-est)^2)/total((savg144-mean(savg144))^2);0.65

  
  ;lat/lons of the sites of interest
;Wankama 2006 - 2011
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Tondikiboro 2006-2011
txind = FLOOR((2.6956 + 20.) / 0.10)
tyind = FLOOR((13.548 + 5) / 0.10)

;****Nalohou-Top, Benin  9.74407     1.60580  
ntxind = FLOOR((1.6058 + 20.) / 0.10);says it is 144...2006-2007 (2009)
ntyind = FLOOR((9.74407 + 5) / 0.10)

;******Nalohou-Mid 9.74530     1.60530  
nmxind = FLOOR((1.6053 + 20.) / 0.10)
nmyind = FLOOR((9.74530 + 5) / 0.10)

;Belefoungou-Top 9.79506     1.71450  
bxind = FLOOR((1.7145 + 20.) / 0.10)
byind = FLOOR((9.79506 + 5) / 0.10)

;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5) / 0.10)

;*****extract the point of interest so that i can KStest in matlab
rfile = file_search('/jabber/chg-mcnally/sahel_ubRFE_PAW36_2001-2012_LGP_WHC_PET.img')
nfile = file_search('/jabber/chg-mcnally/sahel_NPAW_2001_2012_PET_DYNSOS.img');

nx = 720
ny = 350
nz = 431

npawgrid = fltarr(nx,ny,nz)
rpawgrid = fltarr(nx,ny,36,12)

openr,1,rfile
readu,1,rpawgrid
close,1
rpawgrid = reform(rpawgrid,nx,ny,432)
;rpawgrid(where(rpawgrid eq 0))=!values.f_nan

openr,1,nfile
readu,1,npawgrid
close,1

;checking...
pad = fltarr(nx,ny,1)
pad[*,*,*]=!values.f_nan
npawgrid = [[[npawgrid]],[[pad]]]

outpaw = fltarr(6,432)
outpaw[0,*] = npawgrid[axind,ayind,*]
outpaw[1,*] = npawgrid[wxind,wyind,*]
outpaw[2,*] = npawgrid[bxind,byind,*]
outpaw[3,*] = rpawgrid[axind,ayind,*]
outpaw[4,*] = rpawgrid[wxind,wyind,*]
outpaw[5,*] = rpawgrid[bxind,byind,*]

ofile = strcompress('/jabber/chg-mcnally/NPAW_RPAW_AG_WK_BT.csv', /remove_all)
write_csv,ofile, outpaw

;***8what does FAO think that the soil types are at each of these locations?
ifile = file_search('/jabber/chg-mcnally/AMMASOIL/soiltexture_STATSGO-FAO_10KMSahel.1gd4r')
nx = 720
ny = 350

ingrid = fltarr(nx,ny)
openr,1,ifile
readu,1,ingrid
close,1

print, ingrid[txind,tyind]; WK/TK=3, AG=1, B/N=7, where is this silly list? check FC_WP
sandloam = 3, sand=1, sandyclayloam = 7 


;**********************NDVI STUFF *****************
;get the NDVI timeseries for the appropriate length
;was there much difference between the wankama sites? Did I originally pull these values for the 750m data? eak?
;tk is a greener site that wk. differences could be due to soil background, rather than hgiher
;SM content. Which has higher SM content? TK soil moisture is actually less. 
ifile = file_search('/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/sahel/data.{2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012}*img')

nx = 720
ny = 350
nz = n_elements(ifile)

ingrid = fltarr(nx,ny)
ndvi = fltarr(nx,ny,nz)

for f = 0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[f] &$
  readu,1,ingrid &$
  close,1 &$
  ndvi[*,*,f] = ingrid &$
endfor 

;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5) / 0.10)

;Wankama 2006 - 2011
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Tondikiboro 2006-2011
txind = FLOOR((2.6956 + 20.) / 0.10)
tyind = FLOOR((13.548 + 5) / 0.10)

AG = ndvi[axind,ayind,*]

wk = ndvi[wxind,wyind,*]
tk = ndvi[txind,tyind,*]
wktk = [[transpose(wk)],[transpose(tk)]] 
avgwktk = mean(wktk,dimension=2, /nan)

ndviout = transpose([[transpose(wk)],[transpose(tk)], [avgwktk]] )
;ofile = strcompress('/jabber/chg-mcnally/AMMAVeg/NDVI_WK_TK_AVG_2006_2011.csv')
ofile = strcompress('/jabber/chg-mcnally/AMMAVeg/NDVI_WK_2001_2012.csv')
write_csv,ofile, wk

;******************soil observations******************************
ifile = file_search('/raid/chg-mcnally/AMMA2013/dekads/*{0.7,0.6}*csv')

  A106 = read_csv(ifile[0])
  A206 = read_csv(ifile[1])
  BT06 = read_csv(ifile[2])
  NT06 = read_csv(ifile[3])
 
  TK47 = read_csv(ifile[4])
  TK71 = read_csv(ifile[5])
  WK47 = read_csv(ifile[6])
  WK71 = read_csv(ifile[7])
  

avg216 = mean([transpose(wk47.field1),transpose(wk71.field1),transpose(tk47.field1),transpose(tk71.field1)], /nan, dimension=1)
std216 = stdev([transpose(wk47.field1),transpose(wk71.field1),transpose(tk47.field1),transpose(tk71.field1)], /nan, dimension=1)

p1 = plot(wk47.field1-mean(wk47.field1, /nan), name = 'wk47','r', thick = 1)
p2 = plot(tk47.field1-mean(tk47.field1, /nan),  /overplot, 'orange', name = 'tk47', thick = 1)
p3 = plot(wk71.field1-mean(wk71.field1,/nan), /overplot, 'g',name = 'wk71', thick = 1)
p4 = plot(tk71.field1-mean(tk71.field1, /nan),  /overplot, 'b', name = 'tk71', thick = 1)
p5 = plot(avg216,  /overplot, name = 'avg', thick = 3)
null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=18) 
p1.xtickfont_size = 18
p1.ytickfont_size = 18

;ofile = strcompress('/jabber/chg-mcnally/AMMASOIL/observed_avgTKWK06.11.csv', /remove_all)
;write_csv, ofile, avg216

;ofile = strcompress('/jabber/chg-mcnally/AMMAVeg/NDVI_WKTK06.11.csv', /remove_all)
;write_csv, ofile, ndviout

;Agofou sites*****************************
  A106 = float(A106.field1);2005-2008, oh good i had the yrs right here..
  A206 = float(A206.field1);2006-2008
  ;2005-2008 = 
  A2 = filter2[axind,ayind,144:287] & help, A2
  AAPI = apigrid[axind,ayind,144:287]
  
  xticks = ['Jun-05','Jun-06','Jun-07','Jun-08']
p1 = plot(AG, thick = 3, 'grey',name = 'N-SM estimate', xminor = 0, yminor = 0,xrange = [0,144], $
 xtickvalues = [ 18, 54, 90, 126  ], xtickinterval = 36 ,font_size = 14, linestyle = 2)
 p1.xtickname= xticks
p1.xtickfont_size = 24
p1.ytickfont_size = 18
p2 = plot(A106, thick = 2, name = 'observed SM A1', 'black', /overplot)
p3 = plot(A206, thick = 1, name = 'observed SM A2', 'm', /overplot)
p4 = plot(AApi-0.03, thick = 2, name = 'API', 'b',linestyle=2, /overplot)
null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=18) ;
p1.ytitle = 'soil moisture (%VWC)'
print, 1-total((A106[10:139]-A[10:139])^2)/total((A[10:139]-mean(A[10:139]))^2);-1.99 pretty awful without mean adj
print, correlate(aapi, A2);0.92 they covary similarly but NDVI may better capture diff. between yrs?

;what if we ask, how well does it capture growing season total?
;******************************************  
  BT06 = float(BT06.field1);2006-2009
  B = filter2[bxind, byind,180:323] & help, B
  BAPI = apigrid[bxind,byind,180:323]
  xticks = ['Jun-06','Jun-07','Jun-08','Jun-09']
p1 = plot(B-mean(B), thick = 3, 'grey',name = 'SM estimate', xminor = 0, yminor = 0,xrange = [0,144], $
 xtickvalues = [ 18, 54, 90, 126  ], xtickinterval = 36 ,font_size = 14, linestyle = 2)
 p1.xtickname= xticks
p1.xtickfont_size = 24
p1.ytickfont_size = 18
p2 = plot(BT06-mean(BT06, /nan), thick = 1, name = 'observed SM Belef', 'black', /overplot)
p3 = plot(BAPI-mean(BAPI, /nan), thick = 2, name = 'API Belef', 'c',linestyle=2, /overplot)

null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=18) ;
p1.ytitle = 'soil moisture (%VWC)'
p1.title = 'NSM-Est, API and observed SM at Blefoungou-Top'
;******************************************************
  
  NT06 = float(NT06.field1);2006-2007
  NT = filter2[ntxind, ntyind,216:359] & help, NT
  NAPI = apigrid[ntxind, ntyind,216:359]
  xticks = ['Jun-06','Jun-07','Jun-08','Jun-09']
p1 = plot(NT-mean(nt,/nan), thick = 3, 'grey',name = 'SM estimate', xminor = 0, yminor = 0,xrange = [0,144], /overplot, $
 xtickvalues = [ 18, 54, 90, 126  ], xtickinterval = 36 ,font_size = 14, linestyle = 2)
p1.xtickname= xticks
p1.xtickfont_size = 24
p1.ytickfont_size = 18
p2 = plot(NT06-mean(nt06,/nan), thick = 2, name = 'observed SM Nalohou-Top', 'black', /overplot)
p3 = plot(NAPI-mean(napi,/nan), thick = 2, name = 'API Nalohou-Top', 'c',linestyle=2, /overplot)

null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=18) ;
p1.ytitle = 'soil moisture (%VWC)'
p1.title = 'NSM, API and observed SM at Nalohou-Top'
;******************************************** 
  TK47 = float(TK47.field1);2006-2011
  TK71 = float(TK71.field1)
  TK = filter[txind, tyind,216:423] & help, TK
  
  xticks = ['Jun-06','Jun-07','Jun-08','Jun-09']
p1 = plot(TK, thick = 3, 'grey',name = 'SM estimate', xminor = 0, yminor = 0,xrange = [0,144], $
 xtickvalues = [ 18, 54, 90, 126  ], xtickinterval = 36 ,font_size = 14, linestyle = 2)
 p1.xtickname= xticks
p1.xtickfont_size = 24
p1.ytickfont_size = 18
p2 = plot(TK47, thick = 2, name = 'observed SM TK0.4-0.7', 'black', /overplot)
p3 = plot(TK71, thick = 2, name = 'observed SM TK0.7-1.0', 'b', /overplot)

null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=18) ;
p1.ytitle = 'soil moisture (%VWC)'
;*************************************************  
  WK47 = float(WK47.field1)
  WK71 = float(WK71.field1)
  
  WK = filter[wxind, wyind,216:423] & help, wK
  
  xticks = ['Jun-06','Jun-07','Jun-08','Jun-09']
p1 = plot(WK, thick = 3, 'grey',name = 'SM estimate', xminor = 0, yminor = 0,xrange = [0,144], $
 xtickvalues = [ 18, 54, 90, 126  ], xtickinterval = 36 ,font_size = 14, linestyle = 2)
 p1.xtickname= xticks
p1.xtickfont_size = 24
p1.ytickfont_size = 18
p2 = plot(WK47, thick = 2, name = 'observed SM WK0.4-0.7', 'black', /overplot)
p3 = plot(WK71, thick = 2, name = 'observed SM WK0.7-1.0', 'b', /overplot)

null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=18) ;
p1.ytitle = 'soil moisture (%VWC)'

  



  
 
;this script is to calculates the aquestat DS index and
;compares it to WRSI, I can say that my historical context can include
;how we have evaluated drought in the past :)
;so what would I compare EOS WRSI drought severity
;DS time series with EOS WRSI values plotted on top. combine with getEOS_percentiles_EastAfrica?
;this script also has the plots of the drought class for the hyperwall (DON'T F-THESE UP, I MIGHT NEED THEM LATER)
;12/3/14 redo the analysis at 0.25 degrees, including shrad's VIC outputs. 
;12/6/14 this script has become more 30+ yr oriented and the CHIRPS_NDVI script more 10 yr oriented (for compare w/ RFE and GDAS)
;01/04/15 tried removing single ECV years. no correlation improves, but show that some yrs help the corr.
;like 1984-1985, 1987, 1990-91, 1999-2004, 200 drought severity with monthly SM percentiles (maybe try with ECV as well?);;;;;;;;;;;;;
;3/12/15 working on MW paper, updated EVC, soon updated VIC runs
;3/17/15 this script takes soil moisture from the other script (ALL_EXP_SM_COMPARE.pro) and computes the drought serverity index

startyr = 1981
endyr = 2013
nyrs = endyr - startyr +1

;0.1 degree dims
;nx = 294
;ny = 348

;0.25 degree dims
NX = 117
NY = 139

;;for soil moisture vars see ALL_EXP_COMAPRE.pro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;AGU14 figure 1A. see "map_CHG_stations.pro"
;AGU14 figure 1B. skip to ROIs
;AGU14 figure 1C. plot the correlation in Tigray ethiopia:
;preventionWeb: use a kenya box

;East Africa WRSI/Noah window for Tigray
;map_ulx = 22.  & map_lrx = 51.35 &$
;map_uly = 22.95  & map_lry = -11.75 &$
;bot = (12-map_lry)/0.25 & top = (14-map_lry)/0.25  &$
;left = (38.5-map_ulx)/0.25 & right = (40-map_ulx)/0.25  &$

;Ethiopia WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35 &$
map_uly = 22.95  & map_lry = -11.75 &$
bot = (-map_lry-3)/0.25 & top = (1-map_lry)/0.25  &$
left = (35.5-map_ulx)/0.25 & right = (41-map_ulx)/0.25  &$


map_ulx = 22.  & map_lrx = 51.35 &$
map_uly = 22.95  & map_lry = -11.75 &$
bot = (12-map_lry)/0.1 & top = (16-map_lry)/0.1  &$
left = (44-map_ulx)/0.1 & right = (45-map_ulx)/0.1

check = zmwts[*,*,0]/zmwts[*,*,0] &$
check[left:right, bot:top,0]=5 &$

emw = mean(mean(ZMWTS[left:right,bot:top,*], dimension=1,/nan),dimension=1,/nan) &$
ecm = mean(mean(ZCMTS[left:right,bot:top,*], dimension=1,/nan),dimension=1,/nan) &$
;ecs = mean(mean(ZCsTS[left:right,bot:top,*], dimension=1,/nan),dimension=1,/nan) &$
print, 'yr '+string(t) &$
a = r_correlate(emw, ecm) & print, a &$
b = R_correlate(emw, ecs) & print, b &$
c = R_correlate(ecm, ecs) & print, c &$

endfor

w = WINDOW(WINDOW_TITLE=string('LZ_droughtTS'),DIMENSIONS=[1500,500]) &$

p1 = plot(ts_smooth(emw,3), /CURRENT, thick=2)
p2 = plot(ts_smooth(ecm,3), /overplot, thick=2, 'b')
p2 = plot(ts_smooth(ecs,3), /overplot, thick=2, 'g')

  p2.xrange=[1,384] &$
  p2.xmajor=32 &$
  p2.xtickname=string(indgen(32)+1981)
  p2.xminor = 1 & p2.yminor = 0
  p2.title = strcompress('Noah-ECV (R='+string(a[0])+')_VIC-ECV (R='+string(b[0])+')_Noah-VIC (R='+string(c[0])+')', /remove_all)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;WRSI, BLWS, DSI COMPARE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;read in the longrain/short rain mask:
ifile = file_search('/home/sandbox/people/mcnally/lis_input_wrsi.ea_oct2feb.nc') & print, ifile
fileID = ncdf_open(ifile, /nowrite) &$
  maskID = ncdf_varid(fileID,'WRSIMASK')
ncdf_varget,fileID, maskID, shortmask

;FOR WRSI TIME SERIES FOR TO getEOS_percentiles_EastAfrica.pro

;;;;;;;calculate the soil moisture percentiles (used on hyperwall and AGU poster)
;generate a map of the percentile emperical thresholds for each month.
;for both Noah and VIC...where did i read these in?

sm25cube = sm25cube[*,*,*,0:29]
VIC81cube = vic81cube[*,*,*,0:29]

Npermap = fltarr(nx, ny, 12, 4)
Vpermap = fltarr(nx, ny, 12, 4)

for m = 0,11 do begin &$
  for x = 0, nx-1 do begin &$
    for y = 0, ny-1 do begin &$
    ;skip nans
    test = where(finite(SM25cube[x,y,m,*]),count) &$
    if count eq -1 then continue &$
    ;look at one pixel time series at a time
    Npix = SM25cube[x,y,m,*] &$
    Vpix = VIC81cube[x,y,m,*] &$

    ;then find the index of the Xth percentile, how would i fit a distribution?
    Npermap[x,y,m,*] = cgPercentiles(Npix, PERCENTILES=[0.05,0.1,0.2,0.3]) &$
    Vpermap[x,y,m,*] = cgPercentiles(Vpix, PERCENTILES=[0.05,0.1,0.2,0.3]) &$

    endfor  &$;x
  endfor &$ ;y
endfor

;for each month in the time series classify these using the USDM scheme
;from US drought monitor (0-2 = exceptional; 3-5 = extreme [5]); 6-10=severe [4]; 11-20=moderate [3]; 21-30 = abnormal dry [2]; >30 not drought [1]
;set these vars if working with 0.25deg data
sm = sm25cube[*,*,*,0:29]
vsm = VIC81cube

npc = sm*!values.f_nan
sm(where(sm lt -999.))=!values.f_nan


vpc = vsm*!values.f_nan
vsm(where(vsm lt -999.))=!values.f_nan

for m = 0,12-1 do begin &$
  for x = 0, nx-1 do begin &$
    for y = 0, ny-1 do begin &$
    ;skip nans
    test = where(finite(SM[x,y,m,*]),count) &$
    if count eq 0 then continue &$

    smvector = sm[x,y,m,*] &$
    smvector2 = smvector*!values.f_nan &$
    
    vsmvector = vsm[x,y,m,*] &$
    vsmvector2 = vsmvector*!values.f_nan &$
    ;change the values of the vector, how to do this...
    smvector2(where(smvector le npermap[x,y,m,0])) = 5 &$
    smvector2(where(smvector gt npermap[x,y,m,0] AND smvector le npermap[x,y,m,1])) = 4 &$
    smvector2(where(smvector gt npermap[x,y,m,1] AND smvector le npermap[x,y,m,2])) = 3 &$
    smvector2(where(smvector gt npermap[x,y,m,2] AND smvector le npermap[x,y,m,3])) = 2 &$
    smvector2(where(smvector gt npermap[x,y,m,3])) = 1 &$
    
    vsmvector2(where(vsmvector le vpermap[x,y,m,0])) = 5 &$
    vsmvector2(where(vsmvector gt vpermap[x,y,m,0] AND vsmvector le vpermap[x,y,m,1])) = 4 &$
    vsmvector2(where(vsmvector gt vpermap[x,y,m,1] AND vsmvector le vpermap[x,y,m,2])) = 3 &$
    vsmvector2(where(vsmvector gt vpermap[x,y,m,2] AND vsmvector le vpermap[x,y,m,3])) = 2 &$
    vsmvector2(where(vsmvector gt vpermap[x,y,m,3])) = 1 &$
    ;then put them back into the map
    npc[x,y,m,*] = smvector2 &$ 
    vpc[x,y,m,*] = vsmvector2 &$
  
    endfor &$
  endfor &$
endfor

npcvect = reform(npc,nx,ny,12*30);was 34
vpcvect = reform(vpc,nx,ny,12*30);but shorter...

;drought severity is number of months below 20th percentile (class ge 2 = 4,3,2).
;Percentiles=[0.05,0.1,0.2,0.3]....reform to a 12*34 vector then if x and x-1 are ge 2 then count else sum and reset to 0
;calculate length of drought
;to get the severity multiply length x average percentile (or class)
;ndrought = intarr(nx,ny,12*34)
;nseverity = fltarr(nx,ny,12*34)

ndrought = intarr(nx,ny,12*30)
nseverity = fltarr(nx,ny,12*30)

vdrought = intarr(nx,ny,12*30)
vseverity = fltarr(nx,ny,12*30)
cnt=0
vcnt=0

for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
  nts = npcvect[x,y,*] &$
  vts = vpcvect[x,y,*] &$

  for z = 1, n_elements(vts)-1 do begin &$
  if vts[z] gt 2 AND vts[z-1] gt 2 then vcnt++ else vcnt = 0 &$
  vseverity[x,y,z] = vcnt*vts[z] &$
  vdrought[x,y,z] = vcnt &$
  
  if nts[z] gt 2 AND nts[z-1] gt 2 then cnt++ else cnt = 0 &$
  nseverity[x,y,z] = cnt*nts[z] &$
  ndrought[x,y,z] = cnt &$
  if vcnt eq cnt AND vcnt gt 0 then print, [vcnt, cnt] &$
endfor &$
endfor &$
endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;AGU Drought severity figures - timeseries and scatter plot.
years3 = ['81','84','87','90','93','96','99','02','05','08','11','14']
years2 = ['81','83','85','87','89','91','93','95','97','99','01','03','05','07','09','11']
years1 = indgen(31)+1981
shortmask25 = congrid(shortmask,NX,NY)

shortmaskPW=shortmask25
shortmaskPW[*,*] = 0
map_ulx = 22.  & map_lrx = 51.35 &$
  map_uly = 22.95  & map_lry = -11.75 &$
  bot = (-map_lry-3)/0.25 & top = (1-map_lry)/0.25  &$
  left = (34.5-map_ulx)/0.25 & right = (41-map_ulx)/0.25
  
  shortmaskPW[left:right,bot:top] = 1
shortmask25 = shortmaskPW

N = mean(mean(nSEVERITY*rebin(shortmask25,nx,ny,360), dimension=1,/nan), dimension=1, /nan);was 408
V = mean(mean(vSEVERITY*rebin(shortmask25,nx,ny,360), dimension=1,/nan), dimension=1, /nan)

Nd = mean(mean(ndrought*rebin(shortmask25,nx,ny,360), dimension=1,/nan), dimension=1, /nan);was 408
Vd = mean(mean(vdrought*rebin(shortmask25,nx,ny,360), dimension=1,/nan), dimension=1, /nan)
p1 = plot(Nd,vd,'*', xrange=[0,0.15], yrange=[0,0.15], xtitle = 'Noah drought', ytitle='vic drought')

p1 = plot(N,v,'*', xrange=[0,1.5], yrange=[0,1.5])
print, r_correlate(n,v)
p1.title = 'drought severity from Noah and VIC, R=0.6'
p1.xtitle = 'noah DS'
p1.ytitle= 'VIC DS'

w = WINDOW(WINDOW_TITLE=string('LZ_droughtTS'),DIMENSIONS=[1200,500]) &$
p1 = plot(n, /CURRENT)
pl = plot(v,linestyle=2,'g',/overplot)
p1.xrange=[0,360]
p1.xtickinterval=12
p1.xtickname=strmid(string(years1),6,2)
p1.xminor=1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;East Africa WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

ulx = (180.+map_ulx)*10.  & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10.   & lry = (50.-map_lry)*10.-1
NX = lrx - ulx + 1.5
NY = lry - uly + 2
;plot the 2010-2011 soil moisture progression just for example.

mo = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun','Jul','Aug','Sep','Oct','Nov','Dec']
ncolors = 5
CLASS = [' > normal ', 'abnormally dry', 'moderate drought', 'severe drought', 'extreme drought']
;1368X768
;plot for the hyperwall, and multipannel for different comparisons
startyr=1981
for YOI = 2009,2011 do begin &$
  ;for multipanel plot
  ;w = WINDOW(WINDOW_TITLE=string(YOI),DIMENSIONS=[700,700]) &$
 for i = 0,12-1 do begin &$
  ;p1 = image(pc[*,*,i,YOI-startyr]*SHORTMASK, layout=[4,3,i+1],RGB_TABLE=65,FONT_SIZE=14, $
  yoi = 2005
  I = 11
 ; w = WINDOW(WINDOW_TITLE=string(YOI),DIMENSIONS=[1368,768]) &$
  ;w = WINDOW(WINDOW_TITLE=string(YOI),DIMENSIONS=[700,700]) &$
  p1 = image(CONGRID(npc[*,*,i,YOI-startyr]*shortmask25,NX*1.8,NY*18),RGB_TABLE=65,FONT_SIZE=14, $
  ;p1 = image(CONGRID(shortmask,NX*1.8,NY*18),RGB_TABLE=65,FONT_SIZE=14, $
  AXIS_STYLE=0,MAP_PROJECTION='Geographic',LIMIT=[map_lry+7,map_ulx+7,map_uly-10,map_lrx], $
  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry])  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [200,200,200] &$
  p1.rgb_table = rgbdump &$
  p1.title ='NOAH'+string(mo[i]+string(YOI)) &$
  p1.mapgrid.linestyle = 6 &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.FONT_SIZE = 0 &$
  p1.min_value=0 &$
  p1.max_value=5 &$
  m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.], thick=2) &$
  ;vector:[X1, Y1, X2, Y2],
  cb = colorbar(target=p1,ORIENTATION=1,FONT_SIZE=16, POSITION=[0.14,0.3,0.16,0.6]) &$
  ;cb = colorbar(target=p1,ORIENTATION=0,FONT_SIZE=16) &$
  cb.tickvalues = [0,1,2,3,4]+0.5 &$
  cb.tickname = CLASS &$
  cb.minor=0 &$
  p1.save,strcompress('/home/sandbox/people/mcnally/hyperwall/EA_SMpercentile_'+string(YOI)+'_'+STRING(format='(I2.2)', i+1)+'.jpg', /remove_all),RESOLUTION=200 &$
 endfor  &$
   ;for multipannel plot
;   cb = colorbar(target=p1,ORIENTATION=0,FONT_SIZE=12, POSITION=[0.22,0.05,0.29,0.9]) &$
;   cb.tickvalues = [0,1,2,3,4]+0.5 &$
;   cb.tickname = CLASS &$
;   cb.minor=0 &$
endfor

;;;;;;;;plot time series for the different masks (like Bala did). Can also do the livelihood zones. 
;read in the livelihood raster for kenya
ifile = file_search('/home/sandbox/people/mcnally/AQUEDUCT/Kenya_livlihood_raster')
NX01 = 294
NY01 = 348
ingrid = bytarr(nx01,ny01)
openr,1,ifile
readu,1,ingrid
close,1
ingrid = CONGRID(reverse(ingrid,2),NX,NY)

names = ['unclass', 'CentralHighlandsHigh',  'MarsabitMarginalMixed', 'NorthwesternAgropastoralZone',  'SoutheasternMarginalMixed',  $
          'TurkwellRiverineZone', 'WesternHighPotential','TanaRiverineZone'    ,  'SoutheasternMediumPotential',$
           'NorthernPastoralZone' , 'WesternMediumPotential', 'WesternLakeshoreMarginal',$
         'SouthernPastoralZone',  'NortheasternPastoralZone' , 'ManderaRiverineZone' ,'GrasslandsPastoralZone' , 'NortheasternAgropastoralZone',$
         'LakeTurkanaFishing',  'LakeVictoriaFishing', 'WesternAgropastoralZone', 'CoastalMediumPotential',$
         'CoastalMarginalAgricultural', 'SoutheasternPastoralZone', 'NorthwesternPastoralZone', 'SouthernAgropastoralZone']

;PERCENTILES rather than pc (cube)
;pcvect = reform(pc,nx,ny,12*34)
ZMWTS = REFORM(ZMW,NX,NY,12*32)
ZCMTS = REFORM(ZCM,NX,NY,12*32)
ZCSTS = REFORM(ZCS,NX,NY,12*32)

;COR12nm = FLTARR(n_ELEMENTS(NAMES),2)
COR30mn = FLTARR(n_ELEMENTS(NAMES),2)
COR30nv = FLTARR(n_ELEMENTS(NAMES),2)
COR30mv = FLTARR(n_ELEMENTS(NAMES),2)

smCOR30mn = FLTARR(n_ELEMENTS(NAMES),2)
smCOR30nv = FLTARR(n_ELEMENTS(NAMES),2)
smCOR30mv = FLTARR(n_ELEMENTS(NAMES),2)

;COR12sm = FLTARR(n_ELEMENTS(NAMES),2)
;COR30sm = FLTARR(n_ELEMENTS(NAMES),2)

for r = 0, n_elements(names)-1 do begin &$
  ;for r = 0, 5-1 do begin &$
  R = 12 ;southern pastoral
  ROI = r &$
  LZ = ingrid &$
  LZ(where(ingrid eq ROI, complement=no))=1 &$
  LZ(no)=0 &$
  ;LZ = rebin(LZ, nx, ny, 12*34) &$
  LZ = rebin(LZ, nx, ny, 12*32) &$

  ;ROI = where(ingrid[*,*,0] eq 0, complement=no)
  ;TS = mean(mean(pcvect*LZ, dimension=1, /nan),dimension=1,/nan) &$
  TS = mean(mean(ZCMTS*LZ, dimension=1, /nan),dimension=1,/nan) &$
  TS2 = mean(mean(ZMWTS*LZ, dimension=1, /nan),dimension=1,/nan) &$
  TS3 = mean(mean(ZCSTS*LZ, dimension=1, /nan),dimension=1,/nan) &$

  ;WITH SMOOTHING...
  TS_sm = ts_smooth(TS,3) & help, ts_sm &$
  TS_sm2 = ts_smooth(TS2,3) & help, ts_sm2 &$
  TS_sm3 = ts_smooth(TS3,3) & help, ts_sm3 &$

;
;w = WINDOW(WINDOW_TITLE=string('LZ_droughtTS'),DIMENSIONS=[1700,500]) &$
;  ;p1=BARplot(TS, /current, FILL_COLOR='YELLOW') &$
;  p1=plot(TS, /current,thick=2) &$
;  p1=plot(TS2, /OVERPLOT,'b', thick=1) &$
;  p1=plot(TS3, /OVERPLOT,'g', thick=2) &$
;
;  
;  p1.xrange=[1,384] &$
;  p1.xmajor=32 &$
;  p1.xtickname=string(indgen(32)+1981) &$
  ;THIS CORRELATES THE LAST 12 YRS (144mo/12MO=12YR)
  ;COR12[R,*] = R_CORRELATE(TS[384-144:383],TS2[384-144:383]) &$
  COR30mn[R,*] = R_CORRELATE(TS,TS2) &$
  COR30mv[R,*] = R_CORRELATE(TS2,TS3) &$
  COR30nv[R,*] = R_CORRELATE(TS,TS3) &$

;  p1.title = string(names[r])+'_'+STRING(COR30[r,0])+'_'+STRING(COR12[R,0])+'_'+STRING(COR30mv[r,0])+'_'+STRING(COR30nv[r,0]) &$
;    
   w = WINDOW(WINDOW_TITLE=string('LZ_droughtTS'),DIMENSIONS=[1700,500]) &$
  p2 = plot(TS_sm, thick=1, /CURRENT, 'b') &$
  p2 = plot(TS_sm2, /overplot, thick=2) &$
  p2 = plot(TS_sm3, /overplot, thick=1,'g') &$

  p2.xrange=[1,384] &$
  p2.xmajor=32 &$
  p2.xtickname=string(indgen(32)+1981) &$
  ;THIS CORRELATES THE LAST 12 YRS (144mo/12MO=12YR)
;  COR12sm[R,*] = R_CORRELATE(TS_SM[384-144:383],TS_sm2[384-144:383]) &$
;  COR30sm[R,*] = R_CORRELATE(TS_SM,TS2_sm2) &$ that was noah v smoothed mw?
  ;smCOR12[R,*] = R_CORRELATE(TS_sm[384-144:383],TS_sm2[384-144:383]) &$
  smCOR30mn[R,*] = R_CORRELATE(TS_sm,TS_sm2) &$
  smCOR30mv[R,*] = R_CORRELATE(TS_sm2,TS_sm3) &$
  smCOR30nv[R,*] = R_CORRELATE(TS_sm,TS_sm3) &$

 ; p2.title = string(names[r])+'_'+STRING(COR30sm[r,0])+'_'+STRING(COR12sm[R,0]) &$
 p2.title = string(names[r])+'_'+STRING(smCOR30mn[r,0])+'_'+STRING(smCOR30mv[r,0])+'_'+STRING(smCOR30nv[r,0]) &$

endfor 

;drought severity is number of months below 20th percentile (class ge 2 = 4,3,2).
;Percentiles=[0.05,0.1,0.2,0.3]....reform to a 12*34 vector then if x and x-1 are ge 2 then count else sum and reset to 0
;calculate length of drought
;to get the severity multiply length x average percentile (or class) 
drought = intarr(nx,ny,12*34)
severity = fltarr(nx,ny,12*34)
for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
  ts = pcvect[x,y,*] &$
  for z = 1, n_elements(ts)-1 do begin &$
    if ts[z] gt 2 AND ts[z-1] gt 2 then cnt++ else cnt = 0 &$
    severity[x,y,z] = cnt*ts[z] &$
    drought[x,y,z] = cnt &$
  endfor &$
 endfor &$
endfor

;reform the drought and severity index so i can pull MOI
dmo = reform(drought,294,348,12,34)
smo = reform(severity,294,348,12,34)

dmo_short = mean(dmo[*,*,9:11,*], dimension=3,/nan)*rebin(shortmask,294,348,34) & help, dmo_short

;how do i plot this against the OND timeseries?
p1=barplot(-mean(mean(dmo_short, dimension=1,/nan), dimension=1,/nan))
p1.xrange=[0,35]
p1.xtickinterval=3
p1.xtickname=years 
p1.xminor=2  
years = ['81','84','87','90','93','96','99','02','05','08','11','14']
  cnt=0
  ;w = WINDOW(WINDOW_TITLE=string('LZ_droughtTS'),DIMENSIONS=[1000,600]) &$
  w = WINDOW(WINDOW_TITLE=string('LZ_droughtTS'),DIMENSIONS=[700,900]) &$

for r = 1, n_elements(names)-1 do begin &$
  ;R = 4,13,16,22
 ; for r = 1, 3 do begin &$
  ROI = 22 &$
  LZ = ingrid &$
  LZ(where(ingrid eq ROI, complement=no))=1 &$
  LZ(no)=0 &$
  LZ = rebin(LZ, nx, ny, 12*34) &$

;ROI = where(ingrid[*,*,0] eq 0, complement=no)
  TS = mean(mean(severity*LZ, dimension=1, /nan),dimension=1,/nan) &$
  ;TS_sm = ts_smooth(TS,6) & help, ts_sm
  ;p1=barplot(TS*100, layout=[3,8,r], /current) &$
  p1=barplot(TS*100, layout=[1,4,4], /current, FONT_SIZE=12) &$

 ;p2 = plot(TS_sm, /overplot, thick=2)
  p1.xrange=[0,395] &$
  p1.xmajor=12 &$
  p1.xtickname=string(years) &$
  p1.title = string(names[roi]) &$
endfor 
 
;ofile = '/home/sandbox/people/mcnally/EA_SM_droughtlength_294x348x408.bin'
;openw,1,ofile
;writeu,1,drought
;close,1
;
;;;;;;Ethiopia-Yemen window;;;;;;;;
;ymap_ulx = 30.05  & ymap_lrx = 49.95
;ymap_uly = 20.15  & ymap_lry = 5.15

;Yemen window
ymap_ulx = 42. & ymap_lrx = 48.
ymap_uly = 18. & ymap_lry = 12.

;;;;;;;compare ECV and Noah amomalies averaged over the WRSI mask;;;;;;;

;
;;plot the timeseries of average OND soil moisture anomalies for the WRSI mask
;ond = mean(mean(mean(sm[*,*,9:11,*],dimension=3,/nan)*rebin(shortmask,nx, ny, 32),dimension=1,/nan), dimension=1,/nan)
;ondmw = mean(mean(mean(ecvcube[*,*,9:11,*],dimension=3,/nan)*rebin(shortmask,nx, ny, 32),dimension=1,/nan), dimension=1,/nan)
;
;years = ['81','84','87','90','93','96','99','02','05','08','11','14']
;ondmw(where(ondmw lt 0.013))=!values.f_nan
;sma = OND-mean(OND, /NAN)
;smaMW = ONDmw-mean(ONDmw, /NAN)
;
;tmpplt = plot(ONDMW, xrange=[0,35], thick=3, 'b', /overplot)
;xticks = indgen(32)+1981 & print, xticks
;tmpplt.xtickinterval = 3
;tmpplt.xTICKNAME = YEARS
;tmpplt.xminor = 2
;tmpplt.yminor = 0
;tmpplt.TITLE = 'soil moisture anomalies'
;tmpplt.yrange = [-0.005,0.005]

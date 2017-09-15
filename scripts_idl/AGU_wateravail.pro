;ok, so now i need to generate the three, 6, 9, 12, 18, 24 month blocks for water avail.
;if i break the yr up into 3month blocks i will have 4 periods per yr
;this code needs tp be generalized to produce multi month cubes but for now
;05/17/16 update for paper and compare to other kariba data. use with aqueductv4
;06/05/16 lost good file, start over.
;get runoff from NoahRFE and NoahCHIRPS from readin_RFE_NOAH and readin_CHIRPS_noah.pro
;11/02/16 revist for routine SRI calculations - what does the script do? I want to produce SRI-1 and SRI-24 maps
;11/17/16 where was I? read in the runoff, preferably routed I think....what is the difference between surface water storage and flux?
;12/05/16 try out the multi-yr population data. I can use either storage term. I can stick with surface water for now.

;HELP, CMPPcube
HELP, RO_CHIRPS01, RO_ANNUAL, P_AnnUAL, SMM3, rain, Evap
SMM3_annual = mean(SMM3, dimension=3, /nan)

;just a point for the water balance
;-0.820278, 36.850278
mxind = FLOOR( (36.8503 - map_ulx)/ 0.1)
myind = FLOOR( (-0.82 - map_lry) / 0.1)

;look at the average water balance 1990-2000 (reliable data)
c_start = 1990
c_end   = 2000

c_rain = rain[mxind,myind,*,c_start-startyr:endyr-c_end]
c_rain_avg = rain[mxind,myind,*,c_start-startyr:endyr-c_end]

c_ro = mean(ro_chirps01[mxind,myind,*,c_start-startyr:endyr-c_end],dimension=4,/nan)
c_ro_all = ro_chirps01[mxind,myind,*,*]*86400*30
c_ro_clim = mean(c_ro_all, dimension=4, /nan) & help, c_ro_clim


p1 = plot(mean(c_rain, dimension=4,/nan))

;;;;;;;;plot the thick baseline;;;;;;;;;;
c_ro_all = reform(c_ro_all,12*36)*86400*30

p1 = plot(c_ro_all, thick=2)
p1 = plot(smooth(c_ro_all[0:425],48),'m',thick=3,/overplot)

p1 = plot(total(reform(c_ro_all,12*36), /cumulative)*86400*30, thick=2)
p1 = plot(, /overplot, 'c')

ma = smooth(reform(c_ro_all,12*36)*86400*30, 48) & help, ma
;nothing remarkable about the 
p1=plot(ma)


;then plot all of the years

var = c_ro_all
for i = 0,nyrs-1 do begin &$
  p2 = plot(total(reform(var[*,*,*,i],12), /cumulative), /overplot, 'grey') &$
endfor

;yr 32 = the bad one 2014, 34 = 2016 not good, 2017 bad start
for j = 31,35 do begin &$
  p3 = plot(total(reform(var[*,*,*,j],12), /cumulative), /overplot, thick=2, 'r') &$
endfor

p1 = plot(mean(c_ro_all, dimension=4,/nan)*86400*30, thick=2, /overplot)

p1 = plot(reform(c_rain,12*10));1990-2000 
p2 = plot(reform(rain[mxind,myind,*,*],12*36))

;water balance plots;;;;
p1 = plot(total(c_rain_avg*86400*30, /cumulative), name='precip', 'b')
p1 = plot(total(c_rain_avg*86400*30, /cumulative), name='precip', 'b')



nskip=0
;fit a line at each point and keep the slope.
trendmap = fltarr(NX, NY)
Ptrendmap = fltarr(NX, NY)

;there is some weird shift in here...
for x = 0, NX-1 do begin &$
  for y = 0, NY-1 do begin &$
    trendmap[x,y] = REGRESS(INDGEN(nyrs-nskip),REFORM(SMM3_annual[x,y,nskip:nyrs-1]),MCORRELATION=r) &$
    ;trendmap[x,y] = REGRESS(INDGEN(nyrs-nskip),REFORM(RO_ANNUAL[x,y,nskip:nyrs-1]),MCORRELATION=r) &$
   ; Ptrendmap[x,y] = REGRESS(INDGEN(nyrs-nskip),REFORM(P_ANNUAL[x,y,nskip:nyrs-1]),MCORRELATION=r) &$
  endfor &$
endfor



;look at the timeseries for the upper tana basin
;chop everything down to the yemen window
;Yemen Highland window
ymap_ulx = 36.2 & ymap_lrx = 36.9
ymap_uly = -0.70 & ymap_lry = -0.85

res = 0.1

left = (ymap_ulx-map_ulx)/res  & right= (ymap_lrx-map_ulx)/res-1
top= (ymap_uly-map_lry)/res   & bot= (ymap_lry-map_lry)/res-1

;yemen box 20.5 x 48
print, right - left + 1
print, top - bot + 1

;looks like the right place!
test = ro_chirps01[*,*,0,0]
test[left:right, bot:top]=200 

;generate a time series...
;UTTS = mean(mean(ro_chirps01[left:right, bot:top,*,*], dimension=1, /nan), dimension=1, /nan) & help, UTTS
UTTS = total(total(ro_chirps01[left:right, bot:top,*,*],1, /nan),1, /nan) & help, UTTS
UTTS_vect = reform(UTTS, 12*36)
UTTS_annual = total(UTTS, 1,/nan)

ETS = total(total(evap[left:right, bot:top,*,*],1, /nan),1, /nan) & help, ETS
ETS_vect = reform(ETS, 12*36)
ETS_cum = total(ETS_vect, /cumulative)
UTTS_cum = total(UTTS_vect, /cumulative)
p1 = plot(total(ETS,1, /nan))
p1 = plot(total(UTTS,1, /nan), /overplot, 'm')




;generate the date string with TIMEGEN and label_date
dummy = LABEL_DATE(DATE_FORMAT=['%Y-%M'])
time82 = TIMEGEN(START=JULDAY(1,1,1982), FINAL=JULDAY(12,31,2017), units='months')

p1 = plot(time82, total(UTTS_vect[0:431],/cumulative),xrange=[min(time82),max(time82)], xtickformat='label_date')

p1 = plot(time82, UTTS_vect[0:431],xrange=[min(time82),max(time82)], xtickformat='label_date')
p1 = plot(time82, smooth(UTTS_vect[0:431],6),'m',xrange=[min(time82),max(time82)], xtickformat='label_date', /overplot)

p1 = plot(smooth(UTTS_vect[0:431],6),'m',/overplot,xrange=[min(time82),max(time82)], xtickformat='label_date')

;migrate to RAIN
ofile = '/discover/nobackup/almcnall/VIC_ANNUAL_RO_118_141_12_35.bin
openw,1,ofile
writeu,1,RO_CHIRPS25
close,1
;make a mask where if RO is greater than X std then it = x std. That should damp this el nino business.
;how do i plot how many stdev this el nino made go cray? 

;dims = size(RO_RFE01, /dimensions)
dims = size(RO_CHIRPS01, /dimensions)
nx = dims[0]
ny = dims[1]
nmos = dims[2]
nyrs82 = n_elements(RO_CHIRPS01[0,0,0,*])
;nyrs01 = n_elements(RO_RFE01[0,0,0,*])

;CMPPvect = reform(CMPPcube,NX,NY,nmos*nyrs) & help, CMPPvect
;ROvect01 = reform(RO_RFE01,NX,NY,nmos*nyrs01) & help, ROvect01
ROvect82 = reform(RO_CHIRPS01,NX,NY,nmos*nyrs82) & help, ROvect82

;;;;compute ROC here;;;;;;;;
;;;this is the moving averages. where are the PON maps?
;maybe that buffer is essential
tic
TIME = [1];months
;CMPP_24mo = CMPPvect*!values.f_nan ; is this still being used?
;ROR = fltarr(nx, ny, nmos*nyrs01, n_elements(time))*!values.f_nan
buffer = fltarr(nx, ny, n_elements(time))*!values.f_nan

;for t = 0, n_elements(time)-1 do begin &$
;  for i = TIME[t]-1,nmos*nyrs01-1 do begin &$
;    buffer[*,*,t] = mean(ROvect01[*,*,i-(TIME[t]-1):i],dimension=3,/nan) &$
;    ROR[*,*,i,t] = buffer[*,*,t]  &$  
;  endfor &$
;endfor
;toc

;;CHIRPS
;;compute the 24 month moveing average. 
tic
TIME = [24];months
ROC = fltarr(nx, ny, nmos*nyrs82, n_elements(time))*!values.f_nan
buffer = fltarr(nx, ny, n_elements(time))*!values.f_nan

for t = 0, n_elements(time)-1 do begin &$
  for i = TIME[t]-1,nmos*nyrs82-1 do begin &$
  buffer[*,*,t] = mean(ROvect82[*,*,i-(TIME[t]-1):i],dimension=3,/nan) &$
  ROC[*,*,i,t] = buffer[*,*,t]  &$
endfor &$
endfor
toc
delvar,buffer 

;;;FIGURE FOR PAPER - DON"T MESS UP;;;;;;

CM_PONmap = (roc/rebin(mean(roc,dimension=3,/nan),NX,NY,NMOS*NYRS82))*100
CM_anom24cube = reform(CM_PONmap,nx,ny,nmos,nyrs82)

RG_PONmap = (ror/rebin(mean(ror,dimension=3,/nan),NX,NY,NMOS*NYRS01))*100
RG_anom24cube = reform(RG_PONmap,nx,ny,nmos,nyrs01)

;;;;;;;;;this is a CONTOUR plot;;;;;;;;;;;
;;;read in landcover MODE to grab sparse veg mask;;;
;;;;eastern, southern africa;;;;;;
indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/' ;i would rather have hymap...
mfile_E = file_search(indir+'lis_input_ea_elev_hymapv2.nc') ;'lis_input.MODISmode_ea.nc')
;mfile_S = file_search(indir+'lis_input_sa_elev_mode.nc')
;mfile_W = file_search(indir+'lis_input_wa_elev_mode.nc')

VOI = 'LANDCOVER'
LC = get_nc(VOI, mfile_E)
bare = where(LC[*,*,15] eq 1, complement=other)
water = where(LC[*,*,16] eq 1, complement=other)
Emask = fltarr(eNX,eNY)+1.0
Emask(bare)=!values.f_nan
Emask(water)=!values.f_nan

VOI = 'HYMAP_basin'
LC = get_nc(VOI, mfile_E)
water = where(LC eq 8, complement=other)
Vmask = fltarr(eNX,eNY)+1.0
Vmask(water)=1
Vmask(other)=!values.f_nan
;Vmask[*,140:347]=!values.f_nan

;;where is my yemen mask?
;;gotta check the yemen results
ymask = fltarr(nx,ny)
ofile = '/home/almcnall/yemen_mask_294x348V2.bin'
openr,1,ofile
readu,1,ymask
close,1

params = get_domain01('EA')

eNX = params[0]
eNY = params[1]
emap_ulx = params[2]
emap_lrx = params[3]
emap_uly = params[4]
emap_lry = params[5]

map_ulx = emap_ulx & min_lon = map_ulx
map_lry = emap_lry & min_lat = map_lry
map_uly = emap_uly & max_lat = map_uly
map_lrx = emap_lrx & max_lon = map_lrx
mask = emask
NX = eNX
NY = eNY

;;;stress mask;;;;
indir = '/discover/nobackup/almcnall/Africa-POP/'
POP = read_tiff(indir+'EAfrica_POP_10km.tiff')
popcube = rebin(pop,NX, NY, 12, 34) & help, popcube

;;;;population mask;;;;
popcap = pop
popcap(where(popcap gt 100))=100

;;;note places where TWS is close to threshold;;;
help, SMm3,pop
SMM3vect = reform(smm3,nx,ny,34*12)
avgSMM3 = mean(total(smm3,3, /nan), dimension=3,/nan)
CMPP = avgSMM3/pop

LV = mean(mean(smm3vect*rebin(vmask, nx, ny, 34*12), dimension=1, /nan), dimension=1, /nan)
YM = mean(mean(smm3vect*rebin(ymask, nx, ny, 34*12), dimension=1, /nan), dimension=1, /nan)

p1=plot(YM)

shapefile = '/discover/nobackup/almcnall/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'
w = WINDOW(DIMENSIONS=[700,900]);works for EA 700x900
;w = WINDOW(DIMENSIONS=[1200,500]);

mlim = [min_lat,min_lon,max_lat,max_lon]
m1 = MAP('Geographic',LIMIT=mlim,/CURRENT,horizon_thick=1)
xsize=0.10
ysize=0.10
index = [0,50,70,90,110,130,150];

ncolors = n_elements(index) ;is this right or do i add some?
mo = 9
y=34
;tmpgr = CONTOUR(avgsmm3, $
tmpgr = CONTOUR(CM_anom24cube[*,*,mo,y]*mask, $
  FINDGEN(NX)*(xsize) + min_lon, FINDGEN(NY)*(ysize) + min_lat, $
  RGB_TABLE=72, /FILL, ASPECT_RATIO=1, BACKGROUND_COLOR='white', $
  C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./(ncolors-1)), $
  MAP_PROJECTION='Geographic', XSTYLE=1, YSTYLE=1, /OVERPLOT)
  cb = COLORBAR(TARGET=tmpgr, POSITION=[0.05,0.02,0.95,0.04],FONT_SIZE=11,/BORDER)

tmpgr = CONTOUR(popcap, N_LEVELS=2,rgb_table=6, $
    FINDGEN(NX)*(xsize) + min_lon, ASPECT_RATIO=1, FINDGEN(NY)*(ysize) + min_lat,$
    MAP_PROJECTION='Geographic', XSTYLE=1, YSTYLE=1, /OVERPLOT, FILL=0,C_FILL_PATTERN=1)
  
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
;position = x1,y1, x2, y2
;cb = COLORBAR(TARGET=tmpgr, POSITION=[0.05,0.2,0.95,0.25],FONT_SIZE=11,/BORDER)

mc = MAPCONTINENTS(shapefile, /COUNTRIES,COLOR=[105,105,105],FILL_BACKGROUND=0,LIMIT=mlim, thick=2)
;tmpgr.save,'/home/almcnall/figs4SciData/SM_CCI_ACORR_WA_1026.png'
;;tmptr.save,'/home/almcnall/WaterAvail24mo_Apr.png'
close

CM_anom24cube(where(CM_anom24cube gt 250)) = 250
;;;open the tiff to grab the geotag
ifile = file_search('/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/WaterAvail_SA/EA4CHEM.tif')
ingrid = read_tiff(ofile, GEOTIFF=g_tags)
;;then write out the files...where should the files go? what should they be called?
;;percent of normal water stress, month yr.
outdir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/WaterAvail_SA/'
;;for yr = 1982,2016 do begin &$
yr = 2016
for m = 7,10 do begin &$
  ofile = outdir+STRING(FORMAT='(''WaterStressPercentNorm_24mon_EA'',I4.4,I2.2,''.tif'')',yr,m) &$
  print,max(cm_anom24cube[*,*,m-1,yr-startyr],/nan) &$
  write_tiff, ofile, reverse(cm_anom24cube[*,*,m-1,yr-startyr],2), geotiff=g_tags, /FLOAT &$
endfor
;endfor

;;write out SRI-24 for use in other studies.
;; see Akash's python code...or just do it! once a month, so doing it by hand is not so bad,

SRInow = CM_anom24cube[*,*,mo,y]
bad = where(SRInow lt 70)
vbad = where(SRInow lt 50)

npeople_bad = total(pop(bad),/nan)
npeople_vbad = total(pop(vbad),/nan)

help, bad, vbad

;;make data, map in IDL/Pthyon, overlay population map
;;where is my population data?


print, total(pop(bad),/nan)
print, total(pop(vbad),/nan)

;;good now how do i get a time series of this??? and how to i map it nicely? 
;;can i make a contour of where population is high? or an overplot
popmask=pop
popmask(where(popmask lt 50, complement=other))=!values.f_nan
popmask(other)=100




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
params = get_domain01('SA')

sNX = params[0]
sNY = params[1]
smap_ulx = params[2]
smap_lrx = params[3]
smap_uly = params[4]
smap_lry = params[5]
;;;STICK with CONTOUR;;;;;;;
map_ulx = smap_ulx & min_lon = map_ulx
map_lry = smap_lry & min_lat = map_lry
map_uly = smap_uly & max_lat = map_uly
map_lrx = smap_lrx & max_lon = map_lrx
NX = sNX
NY = sNY

;shapefile = '/discover/nobackup/almcnall/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'
;w = WINDOW(DIMENSIONS=[700,900]);works for EA 700x900
;w = WINDOW(DIMENSIONS=[1200,500]);works for EA 700x900
w = WINDOW(DIMENSIONS=[1200,1200], /buffer);works for EA 700x900


mlim = [min_lat,min_lon,max_lat,max_lon]
xsize=0.10
ysize=0.10

index = [0,50,70,90,110,130,150];
ncolors = n_elements(index)
ct=colortable(72)
y=34
tic
for mo = 0,8 do begin &$
  m1 = MAP('Geographic',LIMIT=mlim,/CURRENT,horizon_thick=1, layout=[3,3,mo+1]) &$
  tmpgr = CONTOUR(CM_anom24cube[*,*,mo,y], $
  FINDGEN(NX)*(xsize) + min_lon, FINDGEN(NY)*(ysize) + min_lat, $
  RGB_TABLE=ct, /FILL, ASPECT_RATIO=1, BACKGROUND_COLOR='white', $
  C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./(ncolors-1)), $
  MAP_PROJECTION='Geographic', XSTYLE=1, YSTYLE=1, /OVERPLOT) &$
  ct[108:108+36,*] = 200  &$
  tmpgr.rgb_table=ct &$
  tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0 &$
  ;cb = COLORBAR(TARGET=tmpgr, POSITION=[0.05,0.05,0.95,0.09],FONT_SIZE=11,/BORDER)
  ;cb = COLORBAR(TARGET=tmpgr, POSITION=[0.05,0.2,0.95,0.25],FONT_SIZE=11,/BORDER)
  ;mc = MAPCONTINENTS(shapefile, /COUNTRIES,COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=mlim)
  mc = MAPCONTINENTS( /COUNTRIES,COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=mlim) &$
endfor
toc
tmpgr.save,'/home/almcnall/SRI-24_JFMAMJJAS.png'
close




;;;revisit this July 5, 2017
;;;;next, make time series to compare RFE2 and CHIRPS 
;;;;first average over the watershed then compute anomalies;;;;

;Gabarone Dame
;24.700161°S 25.926381°E
gxind = FLOOR( (25.926 - map_ulx)/ 0.1)
gyind = FLOOR( (-24.5 - map_lry) / 0.1)

;Lesotho 29.5S, 28.5 E
lxind = FLOOR( (28.5 - map_ulx)/ 0.1)
lyind = FLOOR( (-29.5 - map_lry) / 0.1)

;Hwane Dam Swaziland 26.2S, 31E
;-26.234409, 31.091360
hxind = FLOOR( (31.09 - map_ulx)/ 0.1)
hyind = FLOOR( (-26.23 - map_lry) / 0.1)

;Namibia Winkhoek, 22 S, 17E
nxind = FLOOR( (17 - map_ulx)/ 0.1)
nyind = FLOOR( (-22 - map_lry) / 0.1)

;Kariba Dam, Zambia, Zimbabwae 17S, 27.5E
 ;-16.523194, 28.761542
kxind = FLOOR( (28.7615 - map_ulx)/ 0.1)
kyind = FLOOR( (-16.523 - map_lry) / 0.1)

;;Adwa, tigray region (14,39.4) NDVI has higher freq variation that soil moisture here
txind = FLOOR( (39 - map_ulx)/ 0.1)
tyind = FLOOR( (14 - map_lry) / 0.1)

;;test;;
p1=plot(roc[lxind, lyind,419-192:419], 'b', /overplot)
p1=plot(ror[lxind, lyind,*], 'r', /overplot)


;read in the basin map to see if i can average over these areas instead of rando boxes.
ifile = file_search('/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/lis_input_sa_elev_hymap_test.nc')
VOI = 'HYMAP_basin' &$ ;
basin = get_nc(VOI, ifile)
;temp = image(basin, rgb_table = 38)

;18=zambeie, karibe dam
good = where(basin eq 18, complement = other)
zamb_mask = basin
zamb_mask(good) = 1
zamb_mask(other) = !values.f_nan
zamb_mask[kxind:485,*]=!values.f_nan

;limpopo=58
good = where(basin eq 58, complement = other)
limp_mask=basin
limp_mask(good) = 1
limp_mask(other) = !values.f_nan
limp_mask[gxind:485,*]=!values.f_nan

;swaziland/hawane dam=534
good = where(basin eq 534, complement = other)
hwan_mask=basin
hwan_mask(good) = 1
hwan_mask(other) = !values.f_nan
;hwan_mask[gxind:485,*]=!values.f_nan

;xind=gxind
;yind=gyind
;test = ROmm[*,*,0,0]
;test[xind-70:xind+70, yind-10:yind+10]=5
;save in case I want it back
;r1 = mean(mean(ROvect[xind-70:xind+70, yind-10:yind+10, *], /nan, dimension=1), dimension=1, /nan)
zmask82 = rebin(zamb_mask,NX, NY, NYRS82*NMOS)
lmask82 = rebin(limp_mask,NX, NY, NYRS82*NMOS)
hmask82 = rebin(hwan_mask,NX, NY, NYRS82*NMOS)

zmask01 = rebin(zamb_mask,NX, NY, NYRS01*NMOS)
delvar, zamb_mask
lmask01 = rebin(limp_mask,NX, NY, NYRS01*NMOS)
delvar, limp_mask
hmask01 = rebin(hwan_mask,NX, NY, NYRS01*NMOS)
delvar, hwan_mask

help, ROC, zmask82
;zmask=zmask82
;;compute percent of normal per month;;
gbasin82 = mean(mean(zmask82*roc, dimension=1, /nan),dimension=1, /nan)
kbasin82 = mean(mean(lmask82*roc, dimension=1, /nan),dimension=1, /nan)
hbasin82 = mean(mean(hmask82*roc, dimension=1, /nan),dimension=1, /nan)

gbasin01 = mean(mean(zmask01*ror, dimension=1, /nan),dimension=1, /nan)
kbasin01 = mean(mean(lmask01*ror, dimension=1, /nan),dimension=1, /nan)
hbasin01 = mean(mean(hmask01*ror, dimension=1, /nan),dimension=1, /nan)

;;;;just the runoff not the moving average
gbasin82 = mean(mean(zmask82*RO_CHIRPS01, dimension=1, /nan),dimension=1, /nan)
kbasin82 = mean(mean(lmask82*RO_CHIRPS01, dimension=1, /nan),dimension=1, /nan)
hbasin82 = mean(mean(hmask82*RO_CHIRPS01, dimension=1, /nan),dimension=1, /nan)

gbasin01 = mean(mean(zmask01*RO_RFE01, dimension=1, /nan),dimension=1, /nan)
kbasin01 = mean(mean(lmask01*RO_RFE01, dimension=1, /nan),dimension=1, /nan)
hbasin01 = mean(mean(hmask01*RO_RFE01, dimension=1, /nan),dimension=1, /nan)

;write out CSV for Shrad's SRI
header = ['gaborone', 'karibe', 'hwane']
ofile = '/home/almcnall/figs4SciData/NOAH_RG_RO_2001_2016.csv'
write_csv,  ofile, gbasin01,kbasin01,hbasin01, header=header

;generate the date string with TIMEGEN and label_date
dummy = LABEL_DATE(DATE_FORMAT=['%Y-%M'])
time82 = TIMEGEN(START=JULDAY(1,1,1982), FINAL=JULDAY(12,31,2016), units='months')
time01 = TIMEGEN(START=JULDAY(1,1,2001), FINAL=JULDAY(12,31,2016), units='months')


p1 = plot(time82, gbasin82, layout=[1,3,1],'g', xrange=[min(time82),max(time82)], xtickformat='label_date', name = 'Gaborone', /overplot)
p1 = plot(time01, gbasin01, layout=[1,3,1],'g', xrange=[min(time82),max(time01)], xtickformat='label_date', name = 'Gaborone', /overplot)

p2 = plot(time82, kbasin82, layout=[1,3,2], 'r', /current,xrange=[min(time82),max(time82)], xtickformat='label_date', name='Karibe')
p2 = plot(time01, kbasin01, layout=[1,3,2], 'r', /current,xrange=[min(time82),max(time01)], xtickformat='label_date', name='Karibe', /overplot )

p3 = plot(time82, hbasin82, layout=[1,3,3], 'b', /current,xrange=[min(time82),max(time82)], xtickformat='label_date', name='Hwane')
p3 = plot(time01, hbasin01, layout=[1,3,3], 'b', /current,xrange=[min(time82),max(time01)], xtickformat='label_date', name='Hwane', /overplot)

!null = legend(target=[p1,p2,p3], position=[0.2,0.3], orientation=1,shadow=0)

PON24g01 = gbasin01/mean(gbasin01,/nan)
PON24k01 = kbasin01/mean(kbasin01,/nan)
PON24h01 = hbasin01/mean(hbasin01,/nan)

PON24g82 = gbasin82/mean(gbasin82,/nan)
PON24k82 = kbasin82/mean(kbasin82,/nan)
PON24h82 = hbasin82/mean(hbasin82,/nan)

;read in the VIC timeseries:
ifileR = file_search('/home/almcnall/figs4SciData/VIC_GKHbasins_192_3.bin')
ifileC = file_search('/home/almcnall/figs4SciData/VIC_GKHbasins_420_3.bin')

rcube = fltarr(192,3)
ccube = fltarr(420,3)

openr,1,ifileR
readu,1,Rcube
close,1

openr,1,ifileC
readu,1,Ccube
close,1


p1 = plot(time82, PON24g82*100, layout=[1,3,1],'g', name = 'Gaborone, Botswanna',$
     xrange=[min(time82),max(time82)], xtickformat='label_date')
p1 = plot(time82, ccube[*,0]*100, layout=[1,3,1],'g', name = 'Gaborone, Botswanna',$
     xrange=[min(time82),max(time82)], xtickformat='label_date', /overplot)
p1 = plot(time01, PON24g01*100, layout=[1,3,1],'g', linestyle='3',name = 'Gaborone, Botswanna',xrange=[min(time82),max(time01)], xtickformat='label_date', /overplot)
p1 = plot(time01, rcube[*,0]*100, layout=[1,3,1],'g', name = 'Gaborone, Botswanna',xrange=[min(time82),max(time01)], xtickformat='label_date', /overplot)

p2 = plot(time82, PON24k82*100, layout=[1,3,2], 'r', /current, name='Kariba, Zambia', $
     xrange=[min(time82),max(time82)], xtickformat='label_date')
p2 = plot(time82, ccube[*,1]*100, layout=[1,3,2], '-r', /current, name='Kariba, Zambia', $
     xrange=[min(time82),max(time82)], xtickformat='label_date', /overplot)
p2 = plot(time01, PON24k01*100, layout=[1,3,2], 'r', /current, name='Kariba, Zambia', $
     xrange=[min(time82),max(time01)], xtickformat='label_date', /overplot)
p2 = plot(time01, rcube[*,1]*100, layout=[1,3,2],linestyle=3, 'r', /current, name='Kariba, Zambia', $ 
     xrange=[min(time82),max(time01)], xtickformat='label_date', /overplot)

p3 = plot(time82, PON24h82*100, layout=[1,3,3], 'b', /current, name = 'Hwane, Swaziland', $
     xrange=[min(time82),max(time82)], xtickformat='label_date')
p3 = plot(time82, ccube[*,2]*100, layout=[1,3,3], 'b', /current, name = 'Hwane, Swaziland',$
     xrange=[min(time82),max(time82)], xtickformat='label_date', /overplot)
p3 = plot(time01, PON24h01*100, layout=[1,3,3], 'b', /current, name = 'Hwane, Swaziland',$
     xrange=[min(time82),max(time01)], xtickformat='label_date', /overplot)
p3 = plot(time01, rcube[*,2]*100, layout=[1,3,3], 'b', /current, name = 'Hwane, Swaziland',$
     xrange=[min(time82),max(time01)], xtickformat='label_date', /overplot)

!null = legend(target=[p1,p2,p3], position=[0.2,0.3], orientation=1,shadow=0)

;but i still need to compute per pixel percent of normal for the map 
;and writing geoTiffs (and pngs). 






c_value=[25,50,100]
p2 = image(pop,rgb_table=62, FINDGEN(NX)/10.+ map_ulx,FINDGEN(NY)/10.+ map_lry,$
  mapgrid=tmptr, max_value=200, /buffer, /overplot, /current, transparency = 50)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;WRITE OUT GEOTIFFS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;writing geoTiffs (and pngs).
help, Ro24cube, anom24cube
;put a cap on anom24cube
anom24cube(where(anom24cube gt 200)) = 200
;percent of normal 24mo water avail, month yr.
outdir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/WaterAvail_SA/'
outdir2 = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/WaterAvail_SA/PNG/'


ncolors=5
RGB_INDICES=[0,25,50,85,125,200]
index = [0,25,50,85,125,200]
ct=colortable(72, /reverse)

TIC
for yr = 1982,2016 do begin &$
  for m = 1,12 do begin &$
  ofile1 = outdir+STRING(FORMAT='(''WaterAvail24_SA'',I4.4,I2.2,''.tif'')',yr,m) &$
  write_tiff, ofile1, reverse(Ro24cube[*,*,m-1,yr-startyr],2), geotiff=g_tags, /FLOAT &$
  
  ofile2 = outdir+STRING(FORMAT='(''WaterAvail_PON_24_SA'',I4.4,I2.2,''.tif'')',yr,m) &$
  write_tiff, ofile2, reverse(anom24cube[*,*,m-1,yr-startyr],2), geotiff=g_tags, /FLOAT &$
  
  ;write out all of the pngs too
  tmptr = CONTOUR(anom24cube[*,*,m-1,yr-startyr],FINDGEN(NX)/10. + map_ulx, FINDGEN(NY)/10. + map_lry, RGB_TABLE=ct,$
  /FILL, ASPECT_RATIO=1, C_VALUE=index,RGB_INDICES=FIX(FINDGEN(ncolors)*255./ncolors), layout=[1,1,1],$
  TITLE= month(m-1)+' % of norm. water avail', MAP_PROJECTION='geographic',Xstyle=1,Ystyle=1, /buffer)  &$
  tmptr.rgb_table = reverse(tmptr.rgb_table,2) &$
  tmptr.mapgrid.linestyle = 'none'  &$ 
    tmptr.mapgrid.FONT_SIZE = 0 &$
    m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot) &$;
    m2 = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2) &$
    cb = colorbar(target=tmptr,ORIENTATION=0,TAPER=1,/BORDER, TITLE='percent of normal', position=[0.3,0.07,0.7,0.11]) &$
    ofile3 = outdir2+STRING(FORMAT='(''WaterAvail_PON_24_SA'',I4.4,I2.2,''.png'')',yr,m) &$
    tmptr.save,ofile3 &$
endfor &$
endfor
TOC



help, anom24

r1 = mean(mean(ROvect*mask, /nan, dimension=1), dimension=1, /nan)
r3 = mean(mean(RO_3mo*mask, /nan, dimension=1), dimension=1, /nan)
r6 = mean(mean(RO_6mo*mask, /nan, dimension=1), dimension=1, /nan)
r12 = mean(mean(RO_12mo*mask, /nan, dimension=1), dimension=1, /nan)
r18 = mean(mean(RO_18mo*mask, /nan, dimension=1), dimension=1, /nan)
r24 = mean(mean(RO_24mo*mask, /nan, dimension=1), dimension=1, /nan)

r24g = mean(mean(anom24*lmask, /nan, dimension=1), dimension=1, /nan)
r24k = mean(mean(anom24*zmask, /nan, dimension=1), dimension=1, /nan)
r24h = mean(mean(anom24*hmask, /nan, dimension=1), dimension=1, /nan)

r48 = mean(mean(RO_48mo*mask, /nan, dimension=1), dimension=1, /nan)

p6 = plot(r1, name='1mo')
p7 = plot(r3, 'r', /overplot, name='3mo')
p8 = plot(r6, 'orange', /overplot,name='6mo')
p9 = plot(r12, 'g', /overplot, name='12mo')
p10 = plot(r18, 'c', /overplot, name='18mo')
p11 = plot(r24, 'b', /overplot, name='24mo')
p12 = plot(r48, 'm', /overplot, name='48mo')

p11a = plot(r24g, 'b', name='gaborone', layout = [1,3,1])
p11a.xrange = [0,419]
p11a.xtickinterval=12
p11a.xtickname=string(indgen(nyrs)+1982)
p11a.xtickinterval = 48

p11b = plot(r24h, 'g', /current, name='hwane',layout = [1,3,2])
p11b.xrange = [0,419]
p11b.xtickinterval=12
p11b.xtickname=string(indgen(nyrs)+1982)
p11b.xtickinterval = 48

p11c = plot(r24k, 'r', /current, name='kariba', layout= [1,3,3])
p11c.xrange = [0,419]
p11c.xtickinterval=12
p11c.xtickname=string(indgen(nyrs)+1982) 
p11c.xtickinterval = 48
;!null = legend(target=[p6,p7,p8,p9,p10,p11,p12], position=[0.2,0.3])
!null = legend(target=[p11a,p11b,p11c], position=[0.2,0.3], orientation=1, shadow=0)

;ok, so maybe for now this needs to be a two step process...plot the runoff percentiles.
;people like runoff more than soil mositure. never mind having never validated it :)
;if ET is consistently too high then RO will be too low, but it should be a consistent bias.

;so now I think I want the 24 month average as a map...and then I want the anomaly and percentile
;not sure that it needs to be looked at monthly...I think i just look at the mean
help, RO_24MO
avg24 = rebin(mean(ro_24mo, dimension = 3, /nan),nx,ny, nyrs*nmos)

anom24 = (ro_24mo/avg24)*100
anom24cube = reform(anom24,nx,ny,nmos,nyrs)

;temp = image(anom24cube[*,*,1,34], rgb_table=70, min_value=0, max_value=200 )
;temp.title = 'feb percent of normal 24mo-mv-average water availability'

r1 = mean(mean(anom24*mask, /nan, dimension=1), dimension=1, /nan)
p1=plot(r1-100, '*')

p1.xrange = [0,419]
p1.xtickinterval=12
p1.xtickname=string(indgen(nyrs)+1982)
p1.xtickinterval = 24



test = ROmm
;test(where(test gt 10000))=10000
test[xind,yind,0,0]=max(ROmm)

;p1 = plot(CMPPvect[xind, yind, *])
;p2 = plot(CMPP_3mo[xind, yind, *], 'r', /overplot)
p3 = plot(CMPP_6mo[xind, yind, *], 'orange', /overplot)
p4 = plot(CMPP_12mo[xind, yind, *], 'g', /overplot)
p5 = plot(CMPP_18mo[xind, yind, *], 'c', /overplot)
p6 = plot(CMPP_48mo[xind, yind, *], 'm', /overplot)




;I guess smoothing allows the soil mositure to be computed easier. 
RO03cube = reform(RO_3mo, NX, NY, NMOS, NYRS)
RO06cube = reform(RO_6mo, NX, NY, NMOS, NYRS)
RO12cube = reform(RO_12mo, NX, NY, NMOS, NYRS)
RO18cube = reform(RO_18mo, NX, NY, NMOS, NYRS)
RO24cube = reform(RO_24mo, NX, NY, NMOS, NYRS)

;per67 = fltarr(nx, ny, 12)
;per33 = fltarr(nx, ny, 12)
permap03 = fltarr(nx, ny, 12, 5);show 3 month SRI ending in September (JAS)
permap06 = fltarr(nx, ny, 12, 5);AMJJAS
permap12 = fltarr(nx, ny, 12, 5);OND,JFM,AMJ,JAS
permap18 = fltarr(nx, ny, 12, 5);JAS,OND,JFM,AMJ,JAS
permap24 = fltarr(nx, ny, 12, 5);JAS,OND,JFM,AMJ,JAS

for m = 0,11 do begin &$
  for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
  ;skip nans
  test = where(finite(RO06cube[x,y,m,*]),count) &$
  if count eq -1 then continue &$
  ;look at one pixel time series at a time
;  pix = RO03cube[x,y,m,*] &$
;  permap03[x,y,m,*] = cgPercentiles(pix , PERCENTILES=[0.02,0.05,0.1,0.2,0.3]) &$
;  
;  pix = RO06cube[x,y,m,*] &$
;  permap06[x,y,m,*] = cgPercentiles(pix , PERCENTILES=[0.02,0.05,0.1,0.2,0.3]) &$
;  
;  pix = RO12cube[x,y,m,*] &$
;  permap12[x,y,m,*] = cgPercentiles(pix , PERCENTILES=[0.02,0.05,0.1,0.2,0.3]) &$
;
;  pix = RO18cube[x,y,m,*] &$
;  permap18[x,y,m,*] = cgPercentiles(pix , PERCENTILES=[0.02,0.05,0.1,0.2,0.3]) &$
  
  pix = RO24cube[x,y,m,*] &$
  permap24[x,y,m,*] = cgPercentiles(pix , PERCENTILES=[0.02,0.05,0.1,0.2,0.3]) &$

endfor  &$;x
endfor;


;map the percentile classes
;from US drought monitor (0-2 = exceptional; 3-5 = extreme [5]); 6-10=severe [4]; 11-20=moderate [3]; 21-30 = abnormal dry [2]; >30 not drought [1]
cube = RO24cube
permap=permap24

pc = cube*!values.f_nan
permap(where(permap lt -999.))=!values.f_nan

for m = 0,12-1 do begin &$
  for x = 0, nx-1 do begin &$
    for y = 0, ny-1 do begin &$
    ;skip nans
    test = where(finite(ro18cube[x,y,m,*]),count) &$
    if count eq 0 then continue &$
    ;map the percentile bins for each year using the permap values
    ;go over each map 294x348x12x34 and replace values with bin, this can be a where statement....
    smvector = cube[x,y,m,*] &$
    smvector2=smvector*!values.f_nan &$
    ;change the values of the vector, how to do this...
    smvector2(where(smvector le permap[x,y,m,0])) = 5 &$
    smvector2(where(smvector gt permap[x,y,m,0] AND smvector le permap[x,y,m,1])) = 4 &$
    smvector2(where(smvector gt permap[x,y,m,1] AND smvector le permap[x,y,m,2])) = 3 &$
    smvector2(where(smvector gt permap[x,y,m,2] AND smvector le permap[x,y,m,3])) = 2 &$
    smvector2(where(smvector gt permap[x,y,m,3] AND smvector le permap[x,y,m,4])) = 1 &$
    smvector2(where(smvector gt permap[x,y,m,4])) = 0 &$
    ;then put them back into the map
    pc[x,y,m,*] = smvector2 &$   
    endfor &$
  endfor &$
endfor

;pc3=pc
;pc6=pc
pc12=pc
pc18=pc
pc24=pc

;try muliplying population by 1-percentile and THEN classify?
shapefile = '/home/code/idl_user_contrib/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'

mo = ['jan', 'feb', 'mar', 'apr', 'may', 'jun','jul','aug','sep','oct','nov','dec']
ncolors = 6

startyr=1981
for YOI = 2014,2015 do begin &$
  YOI = 2015
  w = WINDOW(WINDOW_TITLE=string(YOI),DIMENSIONS=[300,900]) &$
  ;for i = 0,12-4 do begin &$
  p1 = image(pc24[*,*,8,YOI-startyr]*popmask, layout=[1,4,4],RGB_TABLE=65,FONT_SIZE=14, $
  AXIS_STYLE=0,MAP_PROJECTION='Geographic',LIMIT=[map_lry+10,map_ulx+10,map_uly,map_lrx], $
  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry],/current )  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [200,200,200] &$
  p1.rgb_table = rgbdump &$
 ; p1.title = 'Water Avail 3-mo percentile'+string(mo[i]) &$
  p1.title = '18-mo SRI '&$
  p1.mapgrid.linestyle = 6 &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.FONT_SIZE = 0 &$
  p1.min_value=-0.5 &$
  p1.max_value=5.5 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black') 

endfor  &$
cb = colorbar(target=p1,ORIENTATION=1,FONT_SIZE=12) &$
endfor
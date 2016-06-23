;ok, so now i need to generate the three, 6, 9, 12, 18, 24 month blocks for water avail.
;if i break the yr up into 3month blocks i will have 4 periods per yr
;this code needs tp be generalized to produce multi month cubes but for now
;05/17/16 update for paper and compare to other kariba data. use with aqueductv4
;06/05/16 lost file get runoff from NoahRFE and NoahCHIRPS from readin_RFE_NOAH and readin_CHIRPS_noah.pro
;06/14/16 repeat with VIC
;HELP, CMPPcube
HELP, RO_RFE25, RO_CHIRPS25

;make a mask where if RO is greater than X std then it = x std. That should damp this el nino business.
;how do i plot how many stdev this el nino made go cray? 

dims = size(RO_RFE25, /dimensions)
;dims = size(RO_CHIRPS25, /dimensions)
nx = dims[0]
ny = dims[1]
nmos = dims[2]
nyrs82 = n_elements(RO_CHIRPS25[0,0,0,*])
nyrs01 = n_elements(RO_RFE25[0,0,0,*])

;CMPPvect = reform(CMPPcube,NX,NY,nmos*nyrs) & help, CMPPvect
ROvect01 = reform(RO_RFE25,NX,NY,nmos*nyrs01) & help, ROvect01
;ROvect82 = reform(RO_CHIRPS25,NX,NY,nmos*nyrs82) & help, ROvect82

;
;;;this is the moving averages. where are the PON maps?
;maybe that buffer is essential
tic
TIME = [24];months
;CMPP_24mo = CMPPvect*!values.f_nan
ROR = fltarr(nx, ny, nmos*nyrs01, n_elements(time))*!values.f_nan
buffer = fltarr(nx, ny, n_elements(time))*!values.f_nan

for t = 0, n_elements(time)-1 do begin &$
  for i = TIME[t]-1,nmos*nyrs01-1 do begin &$
    buffer[*,*,t] = mean(ROvect01[*,*,i-(TIME[t]-1):i],dimension=3,/nan) &$
    ROR[*,*,i,t] = buffer[*,*,t]  &$  
  endfor &$
endfor
toc

;;CHIRPS
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

;;map that
res = 4

index = [0,50,70,90,110,130,150];
ncolors = n_elements(index)
ct=colortable(72)
TIC
;;still need to work on SRI rathern than these average anomalies.
y=n_elements(RG_anom24cube[0,0,0,*])-1
m=4 ;zero index 1=feb
;for y = 0,13 do begin &$
tmptr = CONTOUR(RG_anom24cube[*,*,m,y],FINDGEN(NX)/res+map_ulx, FINDGEN(NY)/res+map_lry, $
  RGB_TABLE=ct, ASPECT_RATIO=1, Xstyle=1,Ystyle=1, dimensions=[NX*1.5, NY], $
  /FILL, C_VALUE=index,RGB_INDICES=FIX(FINDGEN(ncolors)*255./ncolors)) &$
  ct[108:108+36,*] = 200  &$
  tmptr.rgb_table=ct  &$
  m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], horizon_thick=1, /overplot)
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=1) &$
  tmptr.mapgrid.linestyle = 'none'  &$ ; could also use 6 here
  tmptr.mapgrid.FONT_SIZE = 0
  tmptr.mapgrid.label_position = 0
TOC
;position = x1,y1, x2, y2
cb = colorbar(target=tmptr,ORIENTATION=1,TAPER=1,/BORDER, POSITION=[0.78,0.25,0.80,0.75])
cb.TEXTPOS=1
cb.font_size=8
tmptr.save,'/home/almcnall/WaterAvail24mo_Apr_VIC.png'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;anom24cube(where(anom24cube gt 250)) = 250
;;;open the tiff to grab the geotag
;ifile = file_search('/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/WaterAvail_SA/SA4CHEM.tif')
;ingrid = read_tiff(ifile, GEOTIFF=g_tags)
;;then write out the files...where should the files go? what should they be called?
;;percent of normal water stress, month yr.
;outdir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/WaterAvail_SA/'
;;for yr = 1982,2016 do begin &$
;yr = 2016
;for m = 1,4 do begin &$
;  ofile = outdir+STRING(FORMAT='(''WaterStressPercentNorm_24mon_SA'',I4.4,I2.2,''.tif'')',yr,m) &$
;  print,max(anom24cube[*,*,m-1,yr-startyr],/nan) &$
;  write_tiff, ofile, reverse(anom24cube[*,*,m-1,yr-startyr],2), geotiff=g_tags, /FLOAT &$
;endfor
;endfor



;;;;next, make time series to compare RFE2 and CHIRPS 
;;;;first average over the watershed then compute anomalies;;;;

;Gabarone Dame
;24.700161°S 25.926381°E
gxind = FLOOR( (25.926 - map_ulx)/ 0.25)
gyind = FLOOR( (-24.5 - map_lry) / 0.25)

;Lesotho 29.5S, 28.5 E
lxind = FLOOR( (28.5 - map_ulx)/ 0.25)
lyind = FLOOR( (-29.5 - map_lry) / 0.25)

;Hwane Dam Swaziland 26.2S, 31E
;-26.234409, 31.091360
hxind = FLOOR( (31.09 - map_ulx)/ 0.25)
hyind = FLOOR( (-26.23 - map_lry) / 0.25)

;Namibia Winkhoek, 22 S, 17E
nxind = FLOOR( (17 - map_ulx)/ 0.25)
nyind = FLOOR( (-22 - map_lry) / 0.25)

;Kariba Dam, Zambia, Zimbabwae 17S, 27.5E
 ;-16.523194, 28.761542
kxind = FLOOR( (28.7615 - map_ulx)/ 0.25)
kyind = FLOOR( (-16.523 - map_lry) / 0.25)

;;Adwa, tigray region (14,39.4) NDVI has higher freq variation that soil moisture here
txind = FLOOR( (39 - map_ulx)/ 0.25)
tyind = FLOOR( (14 - map_lry) / 0.25)

;;test;;
p1=plot(ror[lxind, lyind,419-192:419], 'b')
p1=plot(ror[lxind, lyind,*], 'r')

;;;START HERE WITH vic 025 BASIN MAP!
;read in the basin map to see if i can average over these areas instead of rando boxes.
;ifile = file_search('/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/lis_input_sa_elev_hymap_test.nc')
ifile = file_search('/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/VIC_test/vic_africa/HYMAP/lis_input_lis7.1_SA_HYMAP.d01.nc')
VOI = 'HYMAP_basin' &$ ;
basin = get_nc(VOI, ifile)
;temp = image(basin, rgb_table = 38)

;18=zambeie, karibe dam
good = where(basin eq 18, complement = other)
zamb_mask = basin
zamb_mask(good) = 1
zamb_mask(other) = !values.f_nan
zamb_mask[kxind:NX-1,*]=!values.f_nan

;where did the basins go in the VIC files?
;limpopo=58 (noah) 59 VIC
good = where(basin eq 59, complement = other)
limp_mask=basin
limp_mask(good) = 1
limp_mask(other) = !values.f_nan
limp_mask[gxind:NX-1,*]=!values.f_nan

;swaziland/hawane dam=534 VIC 517?
good = where(basin eq 517, complement = other)
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


;;;write out just the runoff, not the moving averaged 
gbasin82 = mean(mean(zmask82*RO_CHIRPS25, dimension=1, /nan),dimension=1, /nan)
kbasin82 = mean(mean(lmask82*RO_CHIRPS25, dimension=1, /nan),dimension=1, /nan)
hbasin82 = mean(mean(hmask82*RO_CHIRPS25, dimension=1, /nan),dimension=1, /nan)

gbasin01 = mean(mean(zmask01*RO_RFE25, dimension=1, /nan),dimension=1, /nan)
kbasin01 = mean(mean(lmask01*RO_RFE25, dimension=1, /nan),dimension=1, /nan)
hbasin01 = mean(mean(hmask01*RO_RFE25, dimension=1, /nan),dimension=1, /nan)


header = ['gaborone', 'karibe', 'hwane']
ofile = '/home/almcnall/figs4SciData/VIC_CM2_RO_2001_2016.csv'
write_csv,  ofile, gbasin82,kbasin82,hbasin82, header=header


;generate the date string with TIMEGEN and label_date
dummy = LABEL_DATE(DATE_FORMAT=['%Y-%M'])
time82 = TIMEGEN(START=JULDAY(1,1,1982), FINAL=JULDAY(12,31,2016), units='months')
time01 = TIMEGEN(START=JULDAY(1,1,2001), FINAL=JULDAY(12,31,2016), units='months')


p1 = plot(time82, gbasin82, layout=[1,3,1],'g', xrange=[min(time82),max(time82)], xtickformat='label_date', name = 'Gaborone')
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

p1 = plot(time82, PON24g82*100, layout=[1,3,1],'g', name = 'Gaborone, Botswanna',xrange=[min(time82),max(time82)], xtickformat='label_date')
p1 = plot(time01, PON24g01*100, layout=[1,3,1],'g-', name = 'Gaborone, Botswanna',xrange=[min(time82),max(time01)], xtickformat='label_date', /overplot)

p2 = plot(time82, PON24k82*100, layout=[1,3,2], 'r', /current, name='Kariba, Zambia', xrange=[min(time82),max(time82)], xtickformat='label_date')
p2 = plot(time01, PON24k01*100, layout=[1,3,2], 'r', /current, name='Kariba, Zambia', xrange=[min(time82),max(time01)], xtickformat='label_date', /overplot)

p3 = plot(time82, PON24h82*100, layout=[1,3,3], 'b', /current, name = 'Hwane, Swaziland',xrange=[min(time82),max(time82)], xtickformat='label_date')
p3 = plot(time01, PON24h01*100, layout=[1,3,3], 'b', /current, name = 'Hwane, Swaziland',xrange=[min(time82),max(time01)], xtickformat='label_date', /overplot)

!null = legend(target=[p1,p2,p3], position=[0.2,0.3], orientation=1,shadow=0)

;but i still need to compute per pixel percent of normal for the map 
;and writing geoTiffs (and pngs). 

;;;;;;;save for plotting with the NOAH data;;;;;;;;
ocube = [[pon24g01], [pon24k01],[pon24h01]]
ofile = '/home/almcnall/figs4SciData/VIC_GKHbasins_192_3.bin'
openw,1,ofile
writeu,1,ocube
close,1




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
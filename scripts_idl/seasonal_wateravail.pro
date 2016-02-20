;ok, so now i need to generate the three, 6, 9, 12, 18, 24 month blocks for water avail.
;if i break the yr up into 3month blocks i will have 4 periods per yr
;this code needs tp be generalized to produce multi month cubes but for now

HELP, CMPPcube
HELP, ROmm

;make a mask where if RO is greater than X std then it = x std. That should damp this el nino business.
;how do i plot how many stdev this el nino made go cray? 

dims = size(CMPPcube, /dimensions)
nx = dims[0]
ny = dims[1]
nmos = dims[2]
nyrs = dims[3]

CMPPvect = reform(CMPPcube,NX,NY,nmos*nyrs) & help, CMPPvect
ROvect = reform(ROmm,NX,NY,nmos*nyrs) & help, ROvect

;can i turn these into functions?

TIME = 3;months
CMPP_3mo = CMPPvect*!values.f_nan
RO_3mo = ROvect*!values.f_nan
for i = TIME-1,nmos*nyrs-1 do begin &$
  CMPP_3mo[*,*,i] = mean(CMPPvect[*,*,i-(TIME-1):i],dimension=3,/nan) &$
  RO_3mo[*,*,i] = mean(ROvect[*,*,i-(TIME-1):i],dimension=3,/nan) &$
endfor 

TIME = 6;months
CMPP_6mo = CMPPvect*!values.f_nan
RO_6mo = ROvect*!values.f_nan
for i = TIME-1,nmos*nyrs-1 do begin &$
  CMPP_6mo[*,*,i] = mean(CMPPvect[*,*,i-(TIME-1):i],dimension=3,/nan) &$
    RO_6mo[*,*,i] = mean(ROvect[*,*,i-(TIME-1):i],dimension=3,/nan) &$
endfor

TIME = 12;months
CMPP_12mo = CMPPvect*!values.f_nan
RO_12mo = ROvect*!values.f_nan
for i = TIME-1,nmos*nyrs-1 do begin &$
  CMPP_12mo[*,*,i] = mean(CMPPvect[*,*,i-(TIME-1):i],dimension=3,/nan) &$
    RO_12mo[*,*,i] = mean(ROvect[*,*,i-(TIME-1):i],dimension=3,/nan) &$
endfor

TIME = 18;months
CMPP_18mo = CMPPvect*!values.f_nan
  RO_18mo = ROvect*!values.f_nan
for i = TIME-1,nmos*nyrs-1 do begin &$
  CMPP_18mo[*,*,i] = mean(CMPPvect[*,*,i-(TIME-1):i],dimension=3,/nan) &$
  RO_18mo[*,*,i] = mean(ROvect[*,*,i-(TIME-1):i],dimension=3,/nan) &$
endfor


TIME = 24;months
CMPP_24mo = CMPPvect*!values.f_nan
RO_24mo = ROvect*!values.f_nan
for i = TIME-1,nmos*nyrs-1 do begin &$
  CMPP_24mo[*,*,i] = mean(CMPPvect[*,*,i-(TIME-1):i],dimension=3,/nan) &$
  RO_24mo[*,*,i] = mean(ROvect[*,*,i-(TIME-1):i],dimension=3,/nan) &$
endfor

TIME = 48;months
CMPP_48mo = CMPPvect*!values.f_nan
RO_48mo = ROvect*!values.f_nan
for i = TIME-1,nmos*nyrs-1 do begin &$
  CMPP_48mo[*,*,i] = mean(CMPPvect[*,*,i-(TIME-1):i],dimension=3,/nan) &$
  RO_48mo[*,*,i] = mean(ROvect[*,*,i-(TIME-1):i],dimension=3,/nan) &$
endfor

;check a time series
;I would like to remove, or cap the 1997-98 el nino since it makes everthing else look like low percentile
;mxind = FLOOR( (36.8701 - map_ulx)/ 0.1)
;myind = FLOOR( (0.4856 - map_lry) / 0.1)

;Gabarone Dame
gxind = FLOOR( (25.926 - map_ulx)/ 0.1)
gyind = FLOOR( (-24.5 - map_lry) / 0.1)

;Drought Box
bxind = FLOOR( (29. - map_ulx)/ 0.1)
byind = FLOOR( (-22 - map_lry) / 0.1)

;Lesotho 29.5S, 28.5 E
lxind = FLOOR( (28.5 - map_ulx)/ 0.1)
lyind = FLOOR( (-29.5 - map_lry) / 0.1)

;Hwane Dam Swaziland 26.2S, 31E
hxind = FLOOR( (31 - map_ulx)/ 0.1)
hyind = FLOOR( (-26.2 - map_lry) / 0.1)

;Namibia Winkhoek, 22 S, 17E
nxind = FLOOR( (17 - map_ulx)/ 0.1)
nyind = FLOOR( (-22 - map_lry) / 0.1)

;Kariba Dam, Zambia, Zimbabwae 17S, 27.5E
kxind = FLOOR( (27.5 - map_ulx)/ 0.1)
kyind = FLOOR( (-17 - map_lry) / 0.1)

xind=bxind
yind=byind

p1 = plot(CMPPvect[xind, yind, *])
p2 = plot(CMPP_3mo[xind, yind, *], 'r', /overplot)
p3 = plot(CMPP_6mo[xind, yind, *], 'orange', /overplot)
p4 = plot(CMPP_12mo[xind, yind, *], 'g', /overplot)
p5 = plot(CMPP_18mo[xind, yind, *], 'c', /overplot)

;;Adwa, tigray region (14,39.4) NDVI has higher freq variation that soil moisture here
txind = FLOOR( (39 - map_ulx)/ 0.1)
tyind = FLOOR( (14 - map_lry) / 0.1)
mxind=txind
myind=tyind

test = popmask
test[xind-70:xind+70, yind-100:yind+100]=5

r1 = mean(mean(ROvect[xind-70:xind+70, yind-100:yind+100, *], /nan, dimension=1), dimension=1, /nan)
r3 = mean(mean(RO_3mo[xind-70:xind+70, yind-100:yind+100, *], /nan, dimension=1), dimension=1, /nan)
r6 = mean(mean(RO_6mo[xind-70:xind+70, yind-100:yind+100, *], /nan, dimension=1), dimension=1, /nan)
r12 = mean(mean(RO_12mo[xind-70:xind+70, yind-100:yind+100, *], /nan, dimension=1), dimension=1, /nan)
r18 = mean(mean(RO_18mo[xind-70:xind+70, yind-100:yind+100, *], /nan, dimension=1), dimension=1, /nan)
r24 = mean(mean(RO_24mo[xind-70:xind+70, yind-100:yind+100, *], /nan, dimension=1), dimension=1, /nan)
r48 = mean(mean(RO_48mo[xind-70:xind+70, yind-100:yind+100, *], /nan, dimension=1), dimension=1, /nan)

p6 = plot(r1, name='1mo')
p7 = plot(r3, 'r', /overplot, name='3mo')
p8 = plot(r6, 'orange', /overplot,name='6mo')
p9 = plot(r12, 'g', /overplot, name='12mo')
p10 = plot(r18, 'c', /overplot, name='18mo')
p11 = plot(r24, 'b', /overplot, name='24mo')
p12 = plot(r48, 'm', /overplot, name='48mo')

;for individual points
p6 = plot(ROvect[xind, yind, *], /nan), name='1mo')
p7 = plot(RO_3mo[xind, yind, *], 'r', /overplot, name='3mo')
p8 = plot(RO_6mo[xind, yind, *], 'orange', /overplot,name='6mo')
p9 = plot(RO_12mo[xind, yind, *], 'g', /overplot, name='12mo')
p10 = plot(RO_18mo[xind, yind, *], 'c', /overplot, name='18mo', thick =2)
p11 = plot(RO_24mo[xind, yind, *], 'b', /overplot, name='24mo')
p12 = plot(RO_48mo[xind, yind, *], 'm', /overplot, name='48mo')


p6.xrange = [0,407]
p6.xtickinterval=12
p6.xtickname=string(indgen(nyrs)+1982) 
p6.xtickinterval = 24
!null = legend(target=[p6,p7,p8,p9,p10,p11,p12], position=[0.2,0.3])

;ok, so maybe for now this needs to be a two step process...plot the runoff percentiles.
;people like runoff more than soil mositure. never mind having never validated it :)
;if ET is consistently too high then RO will be too low, but it should be a consistent bias.

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
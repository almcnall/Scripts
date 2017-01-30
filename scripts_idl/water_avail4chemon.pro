pro water_avail4CHEMON
;; CHIRPS water storage anomalies for routine Chemonics maps.

  HELP, RO_CHIRPS01
  
  ;.compile /home/almcnall/Scripts/scripts_idl/cgpercentiles.pro


  ;make a mask where if RO is greater than X std then it = x std. That should damp this el nino business.
  ;how do i plot how many stdev this el nino made go cray?

  ;dims = size(RO_RFE01, /dimensions)
  dims = size(RO_CHIRPS01, /dimensions)
  nx = dims[0]
  ny = dims[1]
  nmos = dims[2]
  nyrs82 = n_elements(RO_CHIRPS01[0,0,0,*])

  ROvect82 = reform(RO_CHIRPS01,NX,NY,nmos*nyrs82) & help, ROvect82

  ;;;this is the moving averages. where are the PON maps?
  ;maybe that buffer is essential

  ;;e.g. compute the 24 month moveing average.
  TIME = [1];months
  ROC = fltarr(nx, ny, nmos*nyrs82)*!values.f_nan
  buffer = fltarr(nx, ny)*!values.f_nan

;ugh, i guess this wasn't working how i expected or manyeb it was
 t=0
 for i = TIME[0]-1,nmos*nyrs82-1 do begin &$
  if time[0] eq 1 then begin &$
    buffer = ROvect82[*,*,i-(TIME[t]-1):i] &$
  endif else begin &$
    buffer = mean(ROvect82[*,*,i-(TIME[t]-1):i],dimension=3,/nan) &$
  endelse &$
    ROC[*,*,i] = buffer  &$
  endfor &$
delvar,buffer
ROC_cube = reform(ROC, NX, NY, NMOS, NYRS82) 

;percent of normal...not as good as percentiles...
CM_PONmap = (roc/rebin(mean(roc,dimension=3,/nan),NX,NY,NMOS*NYRS82))*100
CM_anom24cube = reform(CM_PONmap,nx,ny,nmos,nyrs82)

;;;working on percentiles as an alternative to PON, just can't get the map-back right;;;;;;;;
PERCENTILES=[0.02,0.05,0.1,0.2,0.3,0.4, 0.6, 0.7, 0.8, 0.9, 0.95, 0.98]
permap = fltarr(nx, ny, nmos, n_elements(percentiles))
;;try the percentile function with the smoothed timeseries.
for m = 0,11 do begin &$
  for x = 0, nx-1 do begin &$
    for y = 0, ny-1 do begin &$
     ;skip nans
     test = where(finite(ROC_cube[x,y,m,0:33]),count) &$
     if count eq -1 then continue &$
     pix = ROC_cube[x,y,m,0:33] &$
     ;what does this output? the thresholds or the actaual map?
     permap[x,y,m,*] = cgPercentiles(pix , PERCENTILES=percentiles) &$
     ;permap[x,y,m,*] = cgPercentiles(pix , PERCENTILES=[0.02,0.05,0.1,0.2,0.3]) &$

    endfor  &$;x
  endfor &$
endfor
pc = roc_cube*!values.f_nan
;roc_cube(where(roc_cube lt -999.))=!values.f_nan

for m = 0,12-1 do begin &$
  for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
  ;skip nans
  test = where(finite(roc_cube[x,y,m,*]),count) &$
  if count eq 0 then continue &$
  ;map the percentile bins for each year using the permap values
  ;go over each map 294x348x12x34 and replace values with bin, this can be a where statement....
  smvector = roc_cube[x,y,m,*] &$
  smvector2 = smvector*!values.f_nan &$
  ;change the values of the vector, how to do this...
  smvector2(where(smvector le permap[x,y,m,0])) = Percentiles[0] &$
  smvector2(where(smvector gt permap[x,y,m,0] AND smvector le permap[x,y,m,1])) = Percentiles[1] &$
  smvector2(where(smvector gt permap[x,y,m,1] AND smvector le permap[x,y,m,2])) = Percentiles[2] &$
  smvector2(where(smvector gt permap[x,y,m,2] AND smvector le permap[x,y,m,3])) = Percentiles[3] &$
  smvector2(where(smvector gt permap[x,y,m,3] AND smvector le permap[x,y,m,4])) = Percentiles[4] &$
  smvector2(where(smvector gt permap[x,y,m,4] AND smvector le permap[x,y,m,5])) = Percentiles[5] &$
  smvector2(where(smvector gt permap[x,y,m,5] AND smvector le permap[x,y,m,6])) = Percentiles[6] &$
  smvector2(where(smvector gt permap[x,y,m,6] AND smvector le permap[x,y,m,7])) = Percentiles[7] &$
  smvector2(where(smvector gt permap[x,y,m,7] AND smvector le permap[x,y,m,8])) = Percentiles[8] &$
  smvector2(where(smvector gt permap[x,y,m,8] AND smvector le permap[x,y,m,9])) = Percentiles[9] &$
  smvector2(where(smvector gt permap[x,y,m,9] AND smvector le permap[x,y,m,10])) = Percentiles[10] &$
  smvector2(where(smvector gt permap[x,y,m,10] AND smvector le permap[x,y,m,11])) = Percentiles[11] &$
  smvector2(where(smvector gt permap[x,y,m,11])) = 1 &$
  ;then put them back into the map
  pc[x,y,m,*] = smvector2 &$
endfor &$
endfor &$
endfor


;;;;;;;;;this is a CONTOUR plot;;;;;;;;;;;
;;;read in landcover MODE to grab sparse veg mask;;;
;;;;eastern, southern africa;;;;;;
indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/' ;i would rather have hymap...
mfile_E = file_search(indir+'lis_input_ea_elev_hymapv2.nc') ;'lis_input.MODISmode_ea.nc')
;mfile_S = file_search(indir+'lis_input_sa_elev_mode.nc')
;mfile_W = file_search(indir+'lis_input_wa_elev_mode.nc')

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
NX = eNX
NY = eNY

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
mask = emask

;w = WINDOW(DIMENSIONS=[1200,500]);

mlim = [min_lat,min_lon,max_lat,max_lon]
m1 = MAP('Geographic',LIMIT=mlim,/CURRENT,horizon_thick=1)
xsize=0.10
ysize=0.10
index = [0,25,50,70,90,110,130,150,175];
;index = percentiles

ncolors = n_elements(index) ;is this right or do i add some?
mo = 10
y=34
;tmpgr = CONTOUR(avgsmm3, $
tmpgr = contour(CM_anom24cube[*,*,mo,y]*mask, rgb_table=70, $
;  tmpgr = CONTOUR(pc[*,*,mo,y]*mask, rgb_table=66, $
  FINDGEN(NX)*(xsize) + min_lon, FINDGEN(NY)*(ysize) + min_lat, $
  /FILL, ASPECT_RATIO=1, BACKGROUND_COLOR='white', $
  C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./(ncolors-1)), $
  MAP_PROJECTION='Geographic', XSTYLE=1, YSTYLE=1, /OVERPLOT)
cb = COLORBAR(TARGET=tmpgr, POSITION=[0.05,0.02,0.95,0.04],FONT_SIZE=11,/BORDER)

;tmpgr = CONTOUR(popcap, N_LEVELS=2,rgb_table=6, $
;  FINDGEN(NX)*(xsize) + min_lon, ASPECT_RATIO=1, FINDGEN(NY)*(ysize) + min_lat,$
;  MAP_PROJECTION='Geographic', XSTYLE=1, YSTYLE=1, /OVERPLOT, FILL=0,C_FILL_PATTERN=1)

tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
;position = x1,y1, x2, y2
;cb = COLORBAR(TARGET=tmpgr, POSITION=[0.05,0.2,0.95,0.25],FONT_SIZE=11,/BORDER)

mc = MAPCONTINENTS(shapefile, /COUNTRIES,COLOR=[105,105,105],FILL_BACKGROUND=0,LIMIT=mlim, thick=2)
;tmpgr.save,'/home/almcnall/figs4SciData/SM_CCI_ACORR_WA_1026.png'
;;tmptr.save,'/home/almcnall/WaterAvail24mo_Apr.png'
close

;;;;;;write out data of interest for chemonics;;;;;;;
CM_anom24cube(where(CM_anom24cube gt 250)) = 250
;;;open the tiff to grab the geotag
ifile = file_search('/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/WaterAvail_SA/EA4CHEM.tif')
ingrid = read_tiff(ifile, GEOTIFF=g_tags)
;;then write out the files...where should the files go? what should they be called?
;;percent of normal water stress, month yr.
outdir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/WaterAvail_SA/'
;;for yr = 1982,2016 do begin &$
yr = 2016
for m = 9,11 do begin &$
  ofile = outdir+STRING(FORMAT='(''WaterStressPercentNorm_01mon_EA'',I4.4,I2.2,''.tif'')',yr,m) &$
  print,max(cm_anom24cube[*,*,m-1,yr-startyr],/nan) &$
  write_tiff, ofile, reverse(cm_anom24cube[*,*,m-1,yr-startyr],2), geotiff=g_tags, /FLOAT &$
endfor
;endfor
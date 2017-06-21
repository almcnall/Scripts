pro plot_east_africa

;grab any script with proper plot parameters - what have been my best plots so far? AGU?
.compile /home/almcnall/Scripts/scripts_idl/make_cmap.pro
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro

;;input file to plot;;;;
help, sZMAP_CM01,sZMAP_CM02, sZMAP_CM  ;from seasonal_zscore.pro JFM = 0, AMJ = 1, JAS = 2, OND = 3
help, NSM01RC_L2, NSM01RC_L1, NSM01RC_L0, NSM03RC_L0, NSM03RC_L1, NSM03RC_L2
help, QS

;regrid noahSM04 to substract from VIC
noah025_04 = congrid(NSM04RC_L0, 118, 141)
noah025_03 = congrid(NSM03RC_L0, 118, 141)


ingrid01 = reverse(NSM01RC_L0,2)
ingrid02 = sZMAP_CM02
ingrid = sZMAP_CM
ingrid = qs


print, min(ingrid), max(ingrid)

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
;mask = emask
NX = eNX
NY = eNY

shapefile = '/discover/nobackup/almcnall/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'
;w = WINDOW(DIMENSIONS=[700,900]);works for EA 700x900
;;w = WINDOW(DIMENSIONS=[1200,500]);
;
;
;mlim = [min_lat,min_lon,max_lat,max_lon]
;m1 = MAP('Geographic',LIMIT=mlim,/CURRENT,horizon_thick=1)
;xsize=0.10
;ysize=0.10
;get an ocean mask...
maskdir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/' ;i would rather have hymap...
mfile_E = file_search(maskdir+'lis_input.MODISmode_ea.nc')

VOI = 'LANDCOVER'
LC = get_nc(VOI, mfile_E)

bare = where(LC[*,*,15] eq 1, complement=other)
water = where(LC[*,*,16] eq 1, complement=other)
Emask = fltarr(eNX,eNY)+1.0
Emask(bare)=!values.f_nan
Emask(water)=!values.f_nan


;index = [0,50,70,90,110,130,150];
index = [0,2,5,10,20,30,70,80,90,95,98,100]
;index = [-3,-2.5,-2,-1.5,-1,-0.5]
;index = [-1, -0.5, 0, 0.5, 1.0, 1.5]

ncolors = n_elements(index) ;is this right or do i add some?
mo = 4
y=34

;;;;image plots;;;;;;

;figure out a nice discrete plotting scheme...
w = WINDOW(WINDOW_TITLE='Plotting Stuff',DIMENSIONS=[NX+500,NY+500])
mlim = [min_lat,min_lon,max_lat,max_lon]
m1 = MAP('Geographic',LIMIT=mlim,/CURRENT,horizon_thick=1)
xsize=0.10
ysize=0.10

;ncolors = 20 ;IBBP=20, UMD=14
p1 = image(ingrid*100*emask,rgb_table=74,image_dimensions=[nx*xsize,ny*ysize], image_location=[map_ulx,map_lry], $
  MAP_PROJECTION='Geographic', XSTYLE=1, YSTYLE=1, /OVERPLOT)
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  ; just rewrites the discrete colorbar
;rgbdump[*,0] = rebin([190,190,190],3,1)
;rgbdump[*,255-(256/ncolors):255] = rebin([173,216,230],3,(256/ncolors)+1)
p1.min_value = 0
p1.max_value = 100
;p1.max_value = ncolors - 0.5
p1.rgb_table = rgbdump
c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON)
;c.tickvalues = FINDGEN(ncolors)
;c.tickname = class_igbp_ncep
c.minor= 0
m1.mapgrid.linestyle = 6 &$
  m1.mapgrid.label_show = 0
m1.mapgrid.label_position = 0
mc = MAPCONTINENTS(shapefile, /COUNTRIES,COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=mlim, thick=4)
p1.title = 'Noah SM percentile 0-200cm'
;;;;;;;;;;;;;;

;;;contour plot (not working);;;;;;;;;
;RGB_TABLE=CONGRID(make_cmap(ncolors),3,256) ;couldn't figure out greg's colortable
;tmpgr = CONTOUR(avgsmm3, $
tmpgr = CONTOUR(ingrid01, FINDGEN(NX)*(xsize) + min_lon, FINDGEN(NY)*(ysize) + min_lat, $
  /FILL, ASPECT_RATIO=1, BACKGROUND_COLOR='white',RGB_TABLE=62, $
  C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./(ncolors-1)), $
  MAP_PROJECTION='Geographic', XSTYLE=1, YSTYLE=1, /OVERPLOT)
tmpgr.rgb_table = reverse(tmpgr.rgb_table,2)
cb = COLORBAR(TARGET=tmpgr, POSITION=[0.05,0.02,0.95,0.04],FONT_SIZE=11,/BORDER)

;RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), min_value=-0.5, max_value=0.5

;tmpgr = CONTOUR(popcap, N_LEVELS=2,rgb_table=6, $
;  FINDGEN(NX)*(xsize) + min_lon, ASPECT_RATIO=1, FINDGEN(NY)*(ysize) + min_lat,$
;  MAP_PROJECTION='Geographic', XSTYLE=1, YSTYLE=1, /OVERPLOT, FILL=0,C_FILL_PATTERN=1)
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
;position = x1,y1, x2, y2
;cb = COLORBAR(TARGET=tmpgr, POSITION=[0.05,0.2,0.95,0.25],FONT_SIZE=11,/BORDER)
mc = MAPCONTINENTS(shapefile, /COUNTRIES,COLOR=[105,105,105],FILL_BACKGROUND=0,LIMIT=mlim, thick=2)
tmpgr.title = 'OND SM01 zscore: standardized soil moisture anomaly 0-10cm'
;tmpgr.save,'/home/almcnall/figs4SciData/SM_CCI_ACORR_WA_1026.png'
;;tmptr.save,'/home/almcnall/WaterAvail24mo_Apr.png'
close

;read in the file with the geotag
ifile = file_search('/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/WaterAvail_SA/EA4CHEM.tif')
ingrid = read_tiff(ifile, GEOTIFF=g_tags)

;write out tiffs for Chemonmics
outdir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/SoilMoisture_EA/'
ofile = outdir+STRING('SM01_0_10_zscore_OND_2016.tif') 
write_tiff, ofile, reverse(ingrid01[*,*,3,34],2), geotiff=g_tags, /FLOAT 

ofile = outdir+STRING('SM02_10_40_zscore_OND_2016.tif')
write_tiff, ofile, reverse(ingrid02[*,*,3,34],2), geotiff=g_tags, /FLOAT

ofile = outdir+STRING('SMtot_0_200_zscore_OND_2016.tif')
write_tiff, ofile, reverse(sZMAP_CM[*,*,3,34],2), geotiff=g_tags, /FLOAT

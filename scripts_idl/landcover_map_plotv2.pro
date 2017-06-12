pro landcover_map_plotv2
;8-17-14 make simple landcover map for SMAP-WRSI paper
;12-8-14 can i use this for AVHRR and MODIS comparison over east africa?
;08-20-15 i don't love this but someone always wants to know the dominant landcover type...
;03-14-17 new script so that i can plot IGBP and UMD for different regions. May require 2 scripts.
;First start with IGBP modis, which can use the MODE function (UMD MODE doesn't work)

.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro

params = get_domain01('WA')

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

map_ulx = map_ulx & min_lon = map_ulx
map_lry = map_lry & min_lat = map_lry
map_uly = map_uly & max_lat = map_uly
map_lrx = map_lrx & max_lon = map_lrx

;;;read in landcover MODE to grab sparse veg mask;;;
indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/'
;ifile = file_search(indir+'lis_input.MODISmode_ea.nc')
ifile = file_search(indir+'lis_input_wa_elev_mode.nc')
VOI = 'LANDCOVER'
LC = get_nc(VOI, ifile)

;IGBP-MODIS: double check that these match, moved bareground to first postion to fix (not best soln')
CLASS_IGBP_NCEP = ['tundra','EvergreenNeedleleafForest', 'EvergreenBroadleafForest', 'DeciduousNeedleleafForest', $ 
  'DeciduousBroadleafForest',  'MixedForests',  'ClosedShrublands',  'OpenShrublands', ' WoodySavannas', $ 
  'Savannas',  'Grasslands',  'PermanentWetland',  'Croplands', 'UrbanandBuilt-Up',  'Cropland/NaturalVegetationMosaic', $  
  'SnowandIce', 'BarrenorSparsely',  'Ocean', 'WoodedTundra', 'MixedTundra']
;CLASS_IGBP = ['EVERGREEN NEEDLELEAF FOREST',   'EVERGREEN BROADLEAF FOREST' , 'DECIDUOUS NEEDLELEAF FOREST'  , $
;         'DECIDUOUS BROADLEAF FOREST' , 'MIXED FORESTS' ,  'CLOSED SHRUBLANDS' ,  'OPEN SHRUBLANDS'  ,$
;         'WOODY SAVANNAS' , 'SAVANNAS' , 'GRASSLANDS' , 'PERMANENT WETLAND' ,  'CROPLANDS' ,  'URBAN AND BUILT-UP', $
;         'CROPLAND/NATURAL VEGETATION MOSAIC' , 'SNOW AND ICE' , 'BARREN OR SPARSELY VEGETATED' , $
;         'WOODED TUNDRA' ,  'MIXED TUNDRA' , 'BARE GROUND TUNDRA','OCEAN' ]
;UMD AVHRR, swap uban and water from what is listed on UMD website
CLASS_UMD = ['Urban', 'EvergreenNeedleleafForest', 'EvergreenBroadleafForest', 'DeciduousNeedleleafForest', 'DeciduousBroadleafForest', $
             'MixedForest', 'Woodland','WoodedGrassland', 'ClosedShrubland', 'OpenShrubland', 'Grassland', 'Cropland', $
             'BareGround', 'Water']

;assign the value to the layer so that we can sum them to a single mask
IGBP = fltarr(NX,NY)
for i = 0, n_elements(LC[0,0,*])-1 do begin &$
  temp = LC[*,*,i] &$
  temp(where(temp eq 1)) = i+1 &$
  ;try with 2 dims
  IGBP = temp+IGBP &$
endfor

;figure out a nice discrete plotting scheme...
w = WINDOW(WINDOW_TITLE='Plotting Stuff',DIMENSIONS=[NX+700,NY])
mlim = [min_lat,min_lon,max_lat,max_lon]
m1 = MAP('Geographic',LIMIT=mlim,/CURRENT,horizon_thick=1)
xsize=0.10
ysize=0.10

ncolors = 20 ;IBBP=20, UMD=14
p1 = image(IGBP,rgb_table=46,image_dimensions=[nx*xsize,ny*ysize], image_location=[map_ulx,map_lry], $
  MAP_PROJECTION='Geographic', XSTYLE=1, YSTYLE=1, /OVERPLOT)
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))
rgbdump = p1.rgb_table & rgbdump = reverse(CONGRID(rgbdump[*,rgbind],3,256),2)  ; just rewrites the discrete colorbar
;rgbdump[*,0] = rebin([190,190,190],3,1)
;rgbdump[*,255-(256/ncolors):255] = rebin([173,216,230],3,(256/ncolors)+1)
p1.min_value = -0.5
p1.max_value = ncolors - 0.5
p1.rgb_table = rgbdump
c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON)
c.tickvalues = FINDGEN(ncolors)
c.tickname = class_igbp_ncep
c.minor= 0
m1.mapgrid.linestyle = 6 &$
  m1.mapgrid.label_show = 0
m1.mapgrid.label_position = 0
mc = MAPCONTINENTS(shapefile, /COUNTRIES,COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=mlim)
       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UMD AVHRR
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
.compile /home/almcnall/Scripts/scripts_idl/get_domain25.pro
shapefile = '/discover/nobackup/almcnall/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'

params = get_domain25('WA')

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

map_ulx = map_ulx & min_lon = map_ulx
map_lry = map_lry & min_lat = map_lry
map_uly = map_uly & max_lat = map_uly
map_lrx = map_lrx & max_lon = map_lrx

;;;read in landcover, MODE doesn't work for AVHRR
indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/VIC_test/vic_africa/input/'
;ifile = file_search(indir+'lis_input_lis7.1afr.d01_v2.nc')
ifile = file_search(indir+'lis_input_lis7.1_WA.d01.nc')

VOI = 'LANDCOVER'
LC25 = get_nc(VOI, ifile)
dims = size(LC25, /dimensions) & print, dims

;made a mode file
UMDtile = LC25*!values.f_nan
for x = 0, dims[0] - 1 do begin &$
  for y = 0, dims[1] -1 do begin &$
    ;look at each pixel
    pix = LC25[x,y,*] &$
    ;find index max val for that pixel
    maxval = where(pix eq max(pix), complement=other)  &$
    ;print, maxval &$
    pix(maxval) = 1 &$
    pix(other) = 0 &$
    UMDtile[x,y,*] = pix &$
  endfor &$
endfor

;assign the value to the layer so that we can sum them to a single mask
delvar, temp
UMD = fltarr(NX,NY)
for i = 0, n_elements(UMDtile[0,0,*])-1 do begin &$
  temp = UMDtile[*,*,i] &$
  temp(where(temp eq 1)) = i+1 &$
  ;try with 2 dims
  UMD = temp+UMD &$
endfor

temp = image(umd, rgb_table=42, max_value=14)

;update with most recent plotting methods and fix water...
;could make a colormap for landcover w/ rgb's like the WRSI_cmap
w = WINDOW(WINDOW_TITLE='Plotting Stuff',DIMENSIONS=[NX*3+700,NY*3+100])
mlim = [min_lat,min_lon,max_lat,max_lon]
m1 = MAP('Geographic',LIMIT=mlim,/CURRENT,horizon_thick=1)
xsize=0.25
ysize=0.25

ncolors = 14 ;IBBP=20, UMD=14
p1 = image(umd,rgb_table=46,image_dimensions=[nx*xsize,ny*ysize], image_location=[map_ulx,map_lry], $
  MAP_PROJECTION='Geographic', XSTYLE=1, YSTYLE=1, /OVERPLOT)
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1)) 
  rgbdump = p1.rgb_table & rgbdump = reverse(CONGRID(rgbdump[*,rgbind],3,256),2)  ; just rewrites the discrete colorbar
  ;rgbdump[*,0] = rebin([190,190,190],3,1)
  rgbdump[*,255-20:255] = rebin([173,216,230],3,21)
  p1.min_value = -0.5
  p1.max_value = ncolors - 0.5
  p1.rgb_table = rgbdump
  c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON) 
  c.tickvalues = FINDGEN(ncolors)
  c.tickname = class_umd
  c.minor= 0
  m1.mapgrid.linestyle = 6 &$
  m1.mapgrid.label_show = 0 
  m1.mapgrid.label_position = 0 
  mc = MAPCONTINENTS(shapefile, /COUNTRIES,COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=mlim)


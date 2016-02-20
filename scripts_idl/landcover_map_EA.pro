pro landcover_map_EA
;8-17-14 make simple landcover map for SMAP-WRSI paper
;12-8-14 can i use this for AVHRR and MODIS comparison over east africa?
;08-20-15 i don't love this but someone always wants to know the dominant landcover type...
;; 
;from UMD website
;0 Water
;1 Evergreen Needleleaf Forest
;2 Evergreen Broadleaf Forest
;3 Deciduous Needleleaf Forest
;4 Deciduous Broadleaf Forest
;5 Mixed Forest
;6 Woodland
;7 Wooded Grassland
;8 Closed Shrubland
;9 Open Shrubland
;10  Grassland
;11  Cropland
;12  Bare Ground
;13  Urban and Built

;IGBP-MODIS: was there some not how they changed the order of 'ocean?', whatif i move ocean to the end?
CLASS_FULL = ['EVERGREEN NEEDLELEAF FOREST',   'EVERGREEN BROADLEAF FOREST' , 'DECIDUOUS NEEDLELEAF FOREST'  , $
         'DECIDUOUS BROADLEAF FOREST' , 'MIXED FORESTS' ,  'CLOSED SHRUBLANDS' ,  'OPEN SHRUBLANDS'  ,$
         'WOODY SAVANNAS' , 'SAVANNAS' , 'GRASSLANDS' , 'PERMANENT WETLAND' ,  'CROPLANDS' ,  'URBAN AND BUILT-UP', $
         'CROPLAND/NATURAL VEGETATION MOSAIC' , 'SNOW AND ICE' , 'BARREN OR SPARSELY VEGETATED' , $
         'WOODED TUNDRA' ,  'MIXED TUNDRA' , 'BARE GROUND TUNDRA','OCEAN' ]
;class = ['',   'Evergreen Broadleaf Forest' , ''  , $
;         '' , '' ,  'Closed Shrublands' ,  'Open Shrublands'  ,$
;         'Woody Savannas' , 'Savannas' , 'Grasslands' , '' ,  'Croplands' ,  '', $
;         '' , '' , 'Barren or Sparsely Vegetated' , 'Ocean' ,$
;         'Wooded Tundra' ,  'Mixed Tundra' , 'Bare Ground Tundra']
;class_UMD = ['Evergreen Needleleaf Forest',  'Evergreen Broadleaf Forest' , 'Deciduous Needleleaf Forest' ,$
;             'Deciduous Broadleaf Forest' , 'Mixed Cover'  , 'Woodland',  'Wooded Grassland' , 'Closed Shrubland', $
;             'Open Shrubland' , 'Grassland' ,  'Cropland' , 'Bare Ground'  , 'Urban and Built-Up'  , 'other']

;;this has the WRSI related parameters...see below for other Noah related params 
;ifile = file_search('/home/sandbox/people/mcnally/lis_input_wrsi.wa.mode.nc');i guess i want mode.nc
;ifile = file_search('/home/sandbox/people/mcnally/lis_input.noah33_eaoct2nov.nc')
;lis_input_sa_elev.nc
;lis_input_wa_elev.nc
; read in the IGBP-MODIS landcover data
ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input.reorg2_010_noah_hymap_tigris.nc')

fileID = ncdf_open(ifile, /nowrite)
landID = ncdf_varid(fileID,'LANDCOVER') &$
ncdf_varget,fileID, landID, MODIS
dims = size(MODIS, /dimensions) & print, dims

NX = dims[0]
NY = dims[1]
;what is the greatest value?
;I need the max value AND its index...
vmap = modis*!values.f_nan
for x= 0, nx-1 do begin &$
  for y=0, ny-1 do begin &$
   vmap[X,Y,*] = sort(modis[X,Y,*])&$
 endfor &$
endfor

;Southern Africa (37.85 S - 6.35 N; 6.05 E - 54.55 E)
;NX = 486, NY = 443
;map_ulx = 6.05  & map_lrx = 54.55
;map_uly = 6.35  & map_lry = -37.85

;;East Africa WRSI/Noah window
;map_ulx = 22.  & map_lrx = 51.35
;map_uly = 22.95  & map_lry = -11.75
;
;; west africa domain
;map_ulx = -18.65 & map_lrx = 25.85
;map_uly = 17.65 & map_lry = 5.35

;Tigris-Euphrates domainFLDAScd 
map_ulx = 34.05 & map_lrx = 53.95
map_uly = 41.95 & map_lry = 27.05

;w = WINDOW(WINDOW_TITLE='Plotting Stuff',DIMENSIONS=[NX*3+700,NY*3+100])
ncolors = 20 ;IBBP=20, UMD=14
p1 = image(congrid(vmap[*,*,19], 3*NX, 3*NY), rgb_table=46,image_dimensions=[NX/10,NY/10], image_location=[map_ulx,map_lry], /CURRENT)
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of thecolors to be pulled
  rgbdump = p1.rgb_table & rgbdump = reverse(CONGRID(rgbdump[*,rgbind],3,256),2)  &$ ; just rewrites the discrete colorbar
  ;rgbdump[*,0:12] = rebin([190,190,190],3,13)
rgbdump[*,243:255] = rebin([28,107,160],3,13)
p1.min_value = -0.5
p1.max_value = ncolors - 0.5
p1.rgb_table = rgbdump
c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON)
;c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON)
c.tickvalues = FINDGEN(ncolors)
c.tickname = CLASS_FULL
;c.TEXT_ORIENTATION=90
c.minor=0
m = MAP('Geographic',LIMIT = [map_lry, map_ulx, map_uly, map_lrx], /CURRENT) &$ ;18.8 fits better than 18.65
  m.mapgrid.linestyle = 6 &$
  m.mapgrid.label_show = 0
shapefile = '/home/code/idl_user_contrib/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'
mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1)
m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2)
c.font_size=14
;C_VALUE = [300,600,900,1200]






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; read in the IGBP-MODIS landcover data
ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input.MODISmode_ea.nc')
fileID = ncdf_open(ifile, /nowrite)
landID = ncdf_varid(fileID,'LANDCOVER') &$
  ncdf_varget,fileID, landID, MODIS
dims = size(MODIS, /dimensions) & print, dims


;what is this doing? oh this file isn't 1-0s, these are fractions...
IGBP = MODIS*!values.f_nan
for i = 0, dims[2]-1 do begin &$
  temp = MODIS[*,*,i] &$
  temp(where(temp eq 1)) = i+1 &$
  IGBP[*,*,i]=temp &$
endfor
IGBtot = total(IGBP,3,/NAN)
b = intarr(dims[2])
for i = 0,dims[2]-1 do begin &$
  a = where(IGBP eq i, count)  &$
  b[i] = count &$
endfor

;;;;get help with the UMD AVHRR -- doesn't look like much;;;;;
;;;until then correlate VIC, NOAH and ECV for each vegetation type.

Igbtot25 = congrid(igbtot,117,139)

ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input_wrsi.ea_may2nov.nc') & print, ifile ;long mask
fileID = ncdf_open(ifile, /nowrite) &$
maskID = ncdf_varid(fileID,'WRSIMASK')
ncdf_varget,fileID, maskID, longmask
long25 = congrid(longmask,117,139)

;read in the UMD-AVHRR landcover...its possible that this didn't process correctly....
;ifile = file_search('/home/sandbox/people/mcnally/lis_input_VIC_MODE.d01.nc')
;fileID = ncdf_open(ifile, /nowrite)
;landID = ncdf_varid(fileID,'LANDCOVER') &$
;ncdf_varget,fileID, landID, AVHRR
;dims = size(AVHRR, /dimensions) & print, dims
;
;UMD = AVHRR*!values.f_nan
;for i = 0, dims[2]-1 do begin &$
;  temp = AVHRR[*,*,i] &$
;  temp(where(temp eq 1)) = i+1 &$
;  UMD[*,*,i]=temp &$
;endfor
;UMDtot = total(UMD,3,/NAN)
;b = intarr(dims[2])
;for i = 0,dims[2]-1 do begin &$
;  a = where(UMD eq i, count)  &$
;  b[i] = count &$
;endfor

;read in the tile UMD AVHRR since the mode doens't show much!
;So this seems to confirm that UMD-AVHRR assumes a lot of bare ground in this domain while IGBP does not.
ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input_EA_AVHRR_VIC.d01.nc')
fileID = ncdf_open(ifile, /nowrite)
landID = ncdf_varid(fileID,'LANDCOVER') &$
  ncdf_varget,fileID, landID, AVHRRtile
dims = size(AVHRRtile, /dimensions) & print, dims

UMDtile = AVHRRtile*!values.f_nan
for x = 0, dims[0] - 1 do begin &$
  for y = 0, dims[1] -1 do begin &$
    ;look at each pixel
    pix = avhrrtile[x,y,*] &$
    ;find index max val for that pixel
    maxval = where(pix eq max(pix), complement=other)  &$
    print, maxval &$
    pix(maxval) = 1 &$
    pix(other) = !values.f_nan &$
    UMDtile[x,y,*] = pix &$
  endfor &$
endfor
UMDtot = total(UMDtile,3,/NAN)

;
;for i = 0, dims[2]-1 do begin &$
;  temp = AVHRRtile[*,*,i] &$
;  temp(where(temp eq 1)) = i+1 &$
;  UMDtile[*,*,i]=temp &$
;endfor
;UMDtot = total(UMDtile,3,/NAN)
;b = intarr(dims[2])
for i = 0,dims[2]-1 do begin &$
  a = where(UMDtile[*,*,i] eq 1, count)  &$
  b[i] = count-5051 &$
endfor

;East Africa WRSI/Noah window for VIC
;map_ulx = 21.875  & map_lrx = 51.125
;map_uly = 23.125  & map_lry = -11.875

map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

ulx = (180.+map_ulx)*10.  & lrx = (180.+map_lrx)*10.
uly = (50.-map_uly)*10.   & lry = (50.-map_lry)*10.
;NX = lrx - ulx 
;NY = lry - uly 

NX=117
NY=139

NX = 294
NY = 348

w = WINDOW(WINDOW_TITLE='Plotting Stuff',DIMENSIONS=[NX*3+700,NY*3+100])
ncolors = 21 ;IBBP=20, UMD=14
p1 = image(congrid(igbtot25, 3*NX, 3*NY), rgb_table=66,image_dimensions=[NX/10,NY/10], image_location=[map_ulx,map_lry], /CURRENT)
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of thecolors to be pulled
  rgbdump = p1.rgb_table & rgbdump = reverse(CONGRID(rgbdump[*,rgbind],3,256),2)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = rebin([190,190,190],3,1)
  rgbdump[*,215:255] = rebin([28,107,160],3,41)
  p1.min_value=0
  p1.max_value=20 ;UMD=14, IGBP=20
  p1.rgb_table = rgbdump
  c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON) 
 ; POSITION=[0.05,0.13,0.95,0.17],font_size=12); 
  ;c.tickvalues = [500,600,700,800,900,1000,1100,1200]
  c.tickname = class
  ;c.tickname = ['other','woodland', 'wood-grassland','closed shrub', 'open shrub', 'crop','bare', 'water']
  c.minor=0
  m = MAP('Geographic',LIMIT = [map_lry, map_ulx, map_uly, map_lrx], /CURRENT) &$ ;18.8 fits better than 18.65
  m.mapgrid.linestyle = 6 &$
  m.mapgrid.label_show = 0
  shapefile = '/home/code/idl_user_contrib/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1)
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2)
  C_VALUE = [300,600,900,1200]

;;;;;;run the rainfall section below before this next line -- this plots the countours on the veg plot.
;p2 = contour(sahel,color='black', (longitude/10)-18.9,(latitude/10)+5.3,mapgrid=p1,c_value=C_VALUE,/overplot, max_value=1200)
p2 = contour(sahel,color = 'black',(longitude/4)+map_ulx,(latitude/4)+map_lry,mapgrid=p1,c_value=C_VALUE,/overplot, max_value=1200)

  ;******************overlay rainfall totals as isohytes******************************
  ;read in FCLIM data to make annual rainfall total mask
  fx = 1501
  fy = 1601
  fz = 12
  climgrid = LONARR(fx,fy,fz)

  climfile = file_search('/home/chg-mcnally/FCLIM_Afr/*.img')
  openr,1, climfile
  readu,1, climgrid
  close,1

  climgrid = float(climgrid[*,*,*])
  null = where(climgrid lt 0, count) & print, count
  climgrid(null) = !values.f_nan
  totclim = reverse(total(climgrid,3, /nan),2)

  totclimCoarse = congrid(totclim, 751,801)

;FEWS WAfr domain
;  map_ulx = -18.65 & map_lrx = 25.85
;  map_uly =  17.65 & map_lry =  5.35

map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

  culx = (20.+map_ulx)*10. & clrx = (20.+map_lrx)*10.
  culy = (40.+map_uly)*10. & clry = (40.+map_lry)*10.
  sahel = totclimcoarse[culx:clrx, clry:culy]
  sahel = congrid(sahel, 117, 139)
  dims = size(sahel, /dimensions)

  snx = dims[0]
  sny = dims[1]

  longitude = findgen(sNX)
  latitude = findgen(sNY)

  ;example txt
  
  ;why does this not work when i set the window size? this is still mysterious....
  p1 = image(congrid(sahel,nx*4,ny*4), RGB_TABLE=0,image_dimensions=[nx,ny], image_location=[map_ulx,map_lry], $
    min_value=0, max_value=1300, dimensions=[nx*4,ny*4], /current)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
    POSITION=[0.3,0.04,0.7,0.07], title = 'annual rainfall (mm)',font_size=20)
  p1 = MAP('Geographic',LIMIT = [map_lry, map_ulx, map_uly, map_lrx], /CURRENT)
  p2 = contour(sahel,RGB_TABLE=4, (longitude/10)+map_ulx,(latitude/10)+map_lry,mapgrid=p1,n_levels=10,/overplot, c_thick=2)
  m.mapgrid.linestyle = 6 &$
    m.mapgrid.label_show = 0
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ;mask out the wet part of chad
  cgrid[*,0:150]=!values.f_nan

  mask = cgrid[*,0:249]
  mask(where(mask gt 0, complement=other))=1
  mask(other) = !values.f_nan
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;Look at soil moisture by veg type to see if there is a relationship
  NZ = n_elements(ZMWTS[0,0,*])
  mMW = ZMWTS
  mCM = ZCMTS
  mCS = ZCSTS

  ;use IGBtot25 from landcover_map_EA.pro
  IGBtot25cube = rebin(IGBTOT25*long25*sig3,117,139,NZ)
  for i = 1, 20 do begin &$
    good = where(igbtot25cube eq i, count, complement = other) &$
    cnt = where(igbtot25*long25*sig3 eq i) &$
    ;if count gt 0 then print, [i ,  r_correlate(ZMWTS(good), ZCMTS(good)), n_elements(cnt)] &$
    if count gt 0 then print, [i ,  r_correlate(ZMWTS(good), ZCSTS(good)), n_elements(cnt)] &$
  endfor


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;; 10/22/14 does ECV soil moisture detect irrigation? Is SMAP expected to detect irrigation?
; this is pretty tough to see at a coarse scale....
  ;;inspect where irrigation takes place and see if that is influencing our results
  ;;little hard to validate but does point out that we don't try very hard to have 
  ;; good crop maps for a lot of CHG analysis, when that really might help correlations
  ;; with yeilds...look at Monfreda map for millet.
  ifile = file_search('/home/sandbox/people/mcnally/lis_input.WA.modislc_gripc.nc')
  fileID = ncdf_open(ifile, /nowrite) &$

 irrgID = ncdf_varid(fileID,'IRRIGFRAC') &$
 ncdf_varget,fileID, irrgID, IRRG
 dims = size(IRRG, /dimensions)

 cropID = ncdf_varid(fileID,'CROPTYPE') &$
 ncdf_varget,fileID, cropID, CROP
 dims = size(CROP, /dimensions)
crop(where(crop lt 0)) = !values.f_nan

 landID = ncdf_varid(fileID,'LANDCOVER') &$
 ncdf_varget,fileID, landID, LAND
 dims = size(LAND, /dimensions)
 
 
 
 nx = dims[0]
 ny = dims[1]
 nz = dims[2]
 
 
 ;FEWS WAfr domain...there is a shift in the x-direction.
 map_ulx = -18.65 & map_lrx = 25.85
 map_uly =  17.65 & map_lry =  5.35
 ;calculate NX and NY for the crop map
 culx = (20.+map_ulx)*10. & clrx = (20.+map_lrx)*10.
 culy = (5.+map_uly)*10. & clry = (5.+map_lry)*10.
 ;this is off by one in the y-direction...
 cNX = (clrx - culx)+1
 cNY = (culy - clry)+1

;;;read in the ECV soil mositure (mpawcube/mpaw grid) from paper2_plotsv3.pro
;;clip ECV to EROS/irrigation window
ecv2eros = mpawgrid[culx:clrx, clry:culy,*]

 
 w = WINDOW(WINDOW_TITLE='Plotting Stuff',DIMENSIONS=[800,400])
 ncolors = 13
 p1 = image(congrid(mean(ecv2eros, dimension=3,/nan), 4*cNX, 4*cNY), rgb_table=20,image_dimensions=[NX,NY], image_location=[map_ulx,map_lry],dimensions=[nx,ny], /CURRENT)
 p2 = image(congrid(IRRG, 4*cNX, 4*cNY), rgb_table=20,image_dimensions=[NX,NY], image_location=[map_ulx,map_lry],dimensions=[nx,ny], /CURRENT, transparency=50)

 rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
   rgbdump = p1.rgb_table & rgbdump = reverse(CONGRID(rgbdump[*,rgbind],3,256),2)  &$ ; just rewrites the discrete colorbar
   ;rgbdump[*,223:255] = rebin([28,107,160],3,33)
 p2.min_value=0
 p2.max_value=0.1
 p1.rgb_table = rgbdump
 c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
   POSITION=[0.05,0.13,0.95,0.17],font_size=12);
 m1 = MAP('Geographic',LIMIT = [map_lry, -18.8, map_uly, map_lrx], /CURRENT) &$ ;18.8 fits better than 18.65
   m1.mapgrid.linestyle = 6 &$
   m1.mapgrid.label_show = 0
 m1 = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2)
 
 
  



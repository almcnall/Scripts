pro landcover_map
;8-17-14 make simple landcover map for SMAP-WRSI paper
;
; Figure 2 on the SMAP WRSI paper
; 
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

;;this has the WRSI related parameters...see below for other Noah related params
ifile = file_search('/home/sandbox/people/mcnally/lis_input_wrsi.wa.mode.nc')
fileID = ncdf_open(ifile, /nowrite) &$
  
maskID = ncdf_varid(fileID,'WRSIMASK') &$
ncdf_varget,fileID, maskID, MASK
dims = size(MASK, /dimensions)
NX = dims[0]
NY = dims[1]

landID = ncdf_varid(fileID,'LANDCOVER') &$
ncdf_varget,fileID, landID, LAND
dims = size(LAND, /dimensions)
NX = dims[0]
NY = dims[1]
NZ = dims[2]

class = land[*,*,0]*!VALUES.f_nan
;what are these color numbers? pull the major ones and then make an 'other'
t = 0.3
class(where(land[*,*,11] ge t)) = 1100.  ;bare
;class(where(land[*,*,10] ge t)) = 1000. ;crop
class(where(land[*,*,0] ge t)) = 500.    ;e needle
class(where(land[*,*,1] ge t)) = 500.    ;e broad
class(where(land[*,*,2] ge t)) = 500.    ;d needle
class(where(land[*,*,3] ge t)) = 500.    ;d broadleaf
class(where(land[*,*,4] ge t)) = 500.    ;mixed forest
class(where(land[*,*,6] ge t)) = 700.   ;wood grass
class(where(land[*,*,5] ge t)) = 600.   ;woodland
class(where(land[*,*,7] ge t)) = 800.   ;closed shru
class(where(land[*,*,8] ge t)) = 900. ;open shrub
class(where(land[*,*,12] ge t)) = 500. ;urban
class(where(land[*,*,13] ge t)) = 1200. ;this make it look like 14=water
class(where(land[*,*,10] ge 0.1)) = 1000. ;crop

class = class*mask
class(where(land[*,*,13] ge t)) = 1200. ;this make it look like 14=water

;crop mask
;cfile = file_search('/home/chg-mcnally/cz_mask_sahel.img')& cgrid = fltarr(720,350)

;FEWS WAfr domain...there is a shift in the x-direction.
map_ulx = -18.65 & map_lrx = 25.85
map_uly =  17.65 & map_lry =  5.35
;calculate NX and NY for the crop map
culx = (20.+map_ulx)*10. & clrx = (20.+map_lrx)*10.
culy = (5.+map_uly)*10. & clry = (5.+map_lry)*10.
;this is off by one in the y-direction...
cNX = (clrx - culx)+1
cNY = (culy - clry)+1

w = WINDOW(WINDOW_TITLE='Plotting Stuff',DIMENSIONS=[800,400])
ncolors = 8
p1 = image(congrid(class, 4*cNX, 4*cNY), rgb_table=66,image_dimensions=[NX,NY], image_location=[map_ulx,map_lry],dimensions=[nx,ny], /CURRENT)
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = reverse(CONGRID(rgbdump[*,rgbind],3,256),2)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,223:255] = rebin([28,107,160],3,33)
  p1.min_value=450
  p1.max_value=1250
  p1.rgb_table = rgbdump
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
  POSITION=[0.05,0.13,0.95,0.17],font_size=12); 
  c.tickvalues = [500,600,700,800,900,1000,1100,1200]
  c.tickname = ['other','woodland', 'wood-grassland','closed shrub', 'open shrub', 'crop','bare', 'water']
  c.minor=0
  p1 = MAP('Geographic',LIMIT = [map_lry, -18.8, map_uly, map_lrx], /CURRENT) &$ ;18.8 fits better than 18.65
  p1.mapgrid.linestyle = 6 &$
  p1.mapgrid.label_show = 0
  P1 = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2)
  C_VALUE = [250,500,750,1000,1250]
;;;;;;run the rainfall section below before this next line
p2 = contour(sahel,color='black', (longitude/10)-18.9,(latitude/10)+5.3,mapgrid=p1,c_value=C_VALUE,/overplot, max_value=1200)

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

  ;FEWS WAfr domain
  totclimCoarse = congrid(totclim, 751,801)

  map_ulx = -18.65 & map_lrx = 25.85
  map_uly =  17.65 & map_lry =  5.35
  culx = (20.+map_ulx)*10. & clrx = (20.+map_lrx)*10.
  culy = (40.+map_uly)*10. & clry = (40.+map_lry)*10.
  sahel = totclimcoarse[culx:clrx, clry:culy]
  dims = size(sahel, /dimensions)

  snx = dims[0]
  sny = dims[1]

  longitude = findgen(sNX)
  latitude = findgen(sNY)

  ;example txt
  
  ;why does this not work when i set the window size? this is still mysterious....
  p1 = image(congrid(class,nx*4,ny*4), RGB_TABLE=0,image_dimensions=[nx,ny], image_location=[-18,5], $
    min_value=0, max_value=1300, dimensions=[nx*4,ny*4], /current)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
    POSITION=[0.3,0.04,0.7,0.07], title = 'annual rainfall (mm)',font_size=20)

  p1 = MAP('Geographic',LIMIT = [5.35, -18.5, map_uly, map_lrx], /CURRENT) &$

  p2 = contour(sahel,RGB_TABLE=4, (longitude/10)-18.9,(latitude/10)+5.3,mapgrid=p1,n_levels=10,/overplot, c_thick=2)
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ;mask out the wet part of chad
  cgrid[*,0:150]=!values.f_nan

  mask = cgrid[*,0:249]
  mask(where(mask gt 0, complement=other))=1
  mask(other) = !values.f_nan
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
 
 
  



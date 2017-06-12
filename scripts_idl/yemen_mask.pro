pro yemen_mask

;get vars from FLDAS eval Eastern Africa Domain
;I don't expect that the CHIRPS-fix helped much but should prob redo, just to 
;stay consistant. I think that I do have the RCORR, ACORR for the new runs...
;

indir = '/home/sandbox/people/mcnally/FLDAS_EVAL/'
ifile = file_search(indir+'LVT_RCORR_NDVI_NoahSM01fix_1992_2013_EA.nc');LVT_RCORR_NDVI_NoahSM01_1992_2013_EA.nc'); get the new RCORR file!

fileID = ncdf_open(ifile, /nowrite) &$
  wrsiID = ncdf_varid(fileID,'SoilMoist_v_NDVI') &$
  ncdf_varget,fileID, wrsiID, RCORR

ifile = file_search(indir+'LVT_ACORR_FINAL.201401010000.d01_CM_FIX_EA_2001.nc') ;LVT_ACORR_CCISM_NoahSM01_1992_2013_EA.nc
fileID = ncdf_open(ifile, /nowrite) &$
  wrsiID = ncdf_varid(fileID,'SoilMoist_v_SoilMoist') &$
  ncdf_varget,fileID, wrsiID, ACORR

dims = size(ACORR, /dimensions)
NX = dims[0]
NY = dims[1]
; East africa domain
map_ulx = 22.05 & map_lrx = 51.35
map_uly = 22.95 & map_lry = -11.75
;greg's way of nx, ny-ing
ulx = (180.+map_ulx)*10. & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10. & lry = (50.-map_lry)*10.-1
gNX = lrx - ulx + 2 ;not sure why i have to add 2...
gNY = lry - uly + 2

RCORR(where(RCORR lt -100))=!values.f_nan
ACORR(where(ACORR lt -100))=!values.f_nan

;43 to 45 E, 12.5 to 17N
ymap_ulx = 43. & ymap_lrx = 45.
ymap_uly = 17. & ymap_lry = 12.5

left = (ymap_ulx-map_ulx)/0.1  & right= (ymap_lrx-map_ulx)/0.1
top= (ymap_uly-map_lry)/0.1   & bot= (ymap_lry-map_lry)/0.1

;Yemen mask so I can take look at the NDVI, CCI-SM and NOAH time series.
;If I make this a shape file then I can use it in LVT
mask = fltarr(NX, NY)*!values.f_nan
mask(where(rcorr gt 0.3)) = 1
mask(where(acorr gt 0.3)) = 1
mask[0:left,*] = !values.f_nan
mask[right:NX-1,*] = !values.f_nan
mask[*,0:bot] = !values.f_nan
mask[*, top:NY-1] = !values.f_nan

;write out mask for greg:
ofile = '/home/sandbox/people/mcnally/yemen_mask_294x348V2.bin'
openw,1,ofile
writeu,1,mask
close,1

;try opening the tiff file
ifile = file_search('/home/sandbox/people/mcnally/westyemen_mask.tif')
ingrid = read_tiff(ifile, GEOTIFF=g_tags)
temp = reverse(ingrid,2)
print, g_tags

w = window(DIMENSIONS=[1200,800])
ncolors=5
p1 = image(congrid(temp,NX*3,NY*3), image_dimensions=[nx/10,ny/10],image_location=[map_ulx+0.25,map_lry+0.25], $
  RGB_TABLE=64, layout = [1,1,1], /current) &$
  ;p1.title = 'LIS-Noah33 SM01-GIMMS NDVI lag-1 rank correlation'
  p1.title = 'LIS-Noah33 SM01- CCI-SM anomaly correlation'
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  ;rgbdump[*,255] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  ;rgbdump[*,0] = [190,190,190] &$
  ;rgbdump[*,255] = [190,190,190] &$
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  ;p1.MAX_VALUE=0.9 &$
  p1.min_value=0
c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON)
;POSITION=[0.3,0.04,0.7,0.07], font_size=16) &$
tmpclr = p1.rgb_table &$
  ;tmpclr[*,0] = [211,211,211] &$ ;different color oceans
  ;tmpclr[*,0] = [102,178,255] &$
  p1.rgb_table = tmpclr &$
  ;p1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot) &$
  p1 = MAP('Geographic',LIMIT = [12.5,43,17,45], /overplot) &$
  p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2)
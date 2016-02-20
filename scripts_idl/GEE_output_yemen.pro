GEE_output_yemen
;PIXELTYPE      UNSIGNEDINT
;ULXMAP         41.0041666666666
;ULYMAP         19.9958333332974
;XDIM           0.0083333333333
;YDIM           0.0083333333333

;// region = [[43.2, 17.73], [43.2, 12.52], [45.6, 12.52], [45.5, 17.73]]
;// Northern Box
;// 'region' :  [[43.2, 17.73], [43.2, 15.52], [45.6, 15.52], [45.6, 17.73]],
;// Southern Box
;'region': [[43.2, 15.52], [43.2, 13.52], [45.6, 13.52], [45.6, 15.52]],


ifile = file_search('/home/mcnally/Downloads/LinearFit2000_2014_LandsatNDVI_TH_North-0000000000-0000000000.tif')
ingrid = read_tiff(ifile, geotiff=geotagN)
ingrid = float(ingrid)
image1 = reverse(reform(ingrid[0,*,*]),2) & help, image1

ifile = file_search('/home/mcnally/Downloads/LinearFit2000_2014_LandsatNDVI_TH_South-0000000000-0000000000.tif')
ingrid = read_tiff(ifile, geotiff=geo_tagS)
ingrid = float(ingrid)
image2 = reverse(reform(ingrid[0,*,*]),2) & help, image2

pad = fltarr(371, 9092)*!values.f_nan

yem = [[image2],[image1]] & help, yem

w = window(DIMENSIONS=[700,1000])

dims = size(yem, /dimensions)
nx = dims[0]
ny = dims[1]

;Yemen highland window
ulx = geo_tags.(1)[3];43.199982
lrx = 45.6 & uly = 17.73 & lry = 13.52

;larger yemen window [41.13, 18.73], [41.84, 11.52], [53.35, 11.52], [53.09, 19.97]]
yulx = 41.13 & ylrx = 53.35 
yuly = 18.73 & ylry = 11.52

temp = image(yem, rgb_table=66, min_value=-0.02, max_value=0.02, /CURRENT, $
  image_location=[ulx,lry])
c = COLORBAR(target=temp,ORIENTATION=0,/BORDER_ON,font_size=12)
;not working at the moment. rarr. maybe i can write it as a tiff and have it read into ENVI properly.
ofile = '/home/sandbox/people/mcnally/yem_high_ndvi_lin_trend.tif'
yem2 = reverse(yem,2)
write_tiff, ofile, yem2, /float

m1 = MAP('Geographic',limit=[ylry,yulx,yuly,ylrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  m1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0, 0, 0], THICK = 2)

NROWS = 1080
NCOLS = 1680

;this might be a problem for envi --- make it a shape file.


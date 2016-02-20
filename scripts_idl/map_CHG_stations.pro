;map the station density over EAfrica
;12/10/14 map stations for AGU poster
;02/09/15 revisit for Yemen map
;03/16/15 working on it for the ECV paper

;YEMEN
;map_ulx = 44  & map_lrx = 45
;map_uly = 16  & map_lry = 12
;bot = (50+map_lry)/0.25 & top = (50+map_uly)/0.25 & print, bot, top
;left = (180+map_ulx)/0.25 & right = (180+map_lrx)/0.25 & print, left, right
;YM = sum[left:right, bot:top]

;;;;;;;;;;;rainfall station density;;;;;;
idir = '/home/ftp_out/products/CHIRPS-1.8/global_monthly_station_density/tifs/p25/'
;ifile = file_search(idir+'*.tif') & help, ifile
ifile = file_search(idir+'stn_density.{1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013}.??.tif') 
help, ifile
sum = read_tiff(ifile[0])*0
for i = 0, n_elements(ifile)-1 do begin &$
  ingrid = read_tiff(ifile[i],geotiff=geotiff) &$
  sum = ingrid+sum &$
endfor
sum = reverse(sum,2)

pdf = HISTOGRAM(sum(where(sum gt 0)), binsize=1, locations=xbin, max=600)
p1 = barplot(xbin,pdf)
print, max(pdf) ;

;East Africa WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

bot = (50+map_lry)/0.25 & top = (50+map_uly)/0.25 & print, bot, top
left = (180+map_ulx)/0.25 & right = (180+map_lrx)/0.25 & print, left, right

EA = sum[left:right, bot:top]

;read in the longrain/short rain mask:lis_input_wrsi.ea_may2nov.nc
ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input_wrsi.ea_may2nov.nc') & print, ifile ;long mask
fileID = ncdf_open(ifile, /nowrite) &$
  maskID = ncdf_varid(fileID,'LANDMASK')
ncdf_varget,fileID, maskID, land
land25 = congrid(land,118,139)
land25(where(land25 eq 0)) = !values.f_nan

EA = EA*land25

;use EA for correlation in the ECV_eval_paper.pro
ncolors=5
w = window(DIMENSIONS=[700,900])
p1 = image(congrid(EA,nx*4, ny*4), image_dimensions=[nx/25,ny/25], $
  image_location=[map_ulx,map_lry],RGB_TABLE=55, /current, /overplot, transparency=60)  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.title = string(i+1) &$
  p1.max_value=1 &$
  ;p1.min_value=0 &$
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,font_size=18) &$
  m1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly,map_lrx], /current) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  shapefile = '/home/code/idl_user_contrib/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1)
  
  
  ;m1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0, 0, 0], THICK = 2) &$
  P1.TITLE='reporting stations 1992-2013'
  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;rainfall station density box plots;;;;;;
  ;see map_CHG_Stations.pro
  ; Create an array of the corr values in order:
  ; minimum, lower quartile, median, upper quartile, and maximum values
  ea2 = congrid(ea,117,139)
  sta = ea2(where(ea2 gt 0, complement=nosta))
  nmw = cormap1[*,*,0]
  a = nmw(sta)
  b = nmw(nosta)
  boxA =[min(a), cgPercentiles(a , PERCENTILES=[0.25,0.5,0.75]) ,max(a)]
  boxB =[min(b), cgPercentiles(b , PERCENTILES=[0.25,0.5,0.75]) ,max(b)]

  nsamps = [10,20];
  plotdat = FLTARR(3,2)        ; data defining the box values
  whisdat = FLTARR(2,2)        ; data defining the whisker values
  maxy = 2.0
  for i=0,N_ELEMENTS(nsamps)-1 do begin &$

    whisdat[0,0] = boxA[0]     ; negative error bar
  whisdat[1,0] = boxA[4]       ; positive error bar

  plotdat[0,0] = boxA[1]  ; 25th percentile value
  plotdat[1,0] = boxA[2]  ; 50th percentile value
  plotdat[2,0] = boxA[3]  ; 75th percentile value

  whisdat[0,1] = boxB[0]     ; negative error bar
  whisdat[1,1] = boxB[4]       ; positive error bar

  plotdat[0,1] = boxB[1]  ; 25th percentile value
  plotdat[1,1] = boxB[2]  ; 50th percentile value
  plotdat[2,1] = boxB[3]  ; 75th percentile value
endfor

; make boxplot, or not ;p
b = BARPLOT(REFORM(plotdat(2,*)),BOTTOM_VALUES=REFORM(plotdat(0,*)), $
  COLOR='green',NAME='Shape Value', FILL_COLOR='white', $
  XTITLE='Number of Samples', XTICKNAME=STRING(nsamps), $
  YTITLE='Parameter Value',YRANGE=[0,maxy])
X = INDGEN(N_ELEMENTS(nsamps))
Y = REFORM(plotdat(1,*)) ;the mean values?
YERR = whisdat
e = ERRORPLOT(X,Y,YERR, $
  LINESTYLE=6, ERRORBAR_COLOR='green',ERRORBAR_CAPSIZE=0.25, $
  /OVERPLOT)
b.order,/SEND_TO_FRONT

;use EA from map_CHG_stations.pro, Ian pointed out that binning was dumb
;try to make a box plot here.
EA2 = congrid(ea, 117,139)
print, r_correlate(ea2,cormap1[*,*,0])
print, r_correlate(ea2,cormap3[*,*,0])

;does the high station densitiy just get rid of the negative correlations?
cmap1_v = reform(cormap1[*,*,0],117*139)
ea2_v = reform(ea2, 117*139)

print, correlate(cmap1_v(where(ea2 gt 0)), ea2_v(where(ea2 gt 0)) )
p1=plot(sqrt(reform(ea2, 117*139)),reform(cormap1[*,*,0],117*139),'*')


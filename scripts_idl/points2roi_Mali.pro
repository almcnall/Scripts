pro points2roi_Mali

;the purpose of this file to to extract data from a 10km area around kat's
;DHS lat/lon points in Mali for 2006. Look at the NDVi data and any of 
;the LIS outputs from EXPA02 on /gibber

;read in the Mali data
pfile = file_search('/jabber/sandbox/mcnally/ForKatNDVI/Mali_DHS_latlon.csv')
buffer = read_csv(pfile, count=count)
pnames = transpose(buffer.field1)
lat = transpose(buffer.field2)
lon = transpose(buffer.field3)
;there is one zero,zero point in there that is not great
bad=where(lat eq 0 AND lon eq 0, complement=good)
;check out where the points are. 
;p1=plot(lon(good), lat(good), linestyle=6, '*')

;change the lat lons to x-y corrds for the LIS output.see code below.
;********change lon-lat to xy*********************
  ;-19.95 -4.95
 x = (lon(good)+19.95)/0.1; becasue it is -29.95W and (2.5*20 = 50pixels) that is .05 off of 20 which should be the center of the pixel.
 y = (lat(good)+4.95)/0.1 ;becasue it is -5S (more south, not exact...)

;write out the data so maybe I can read it in envi
ofile=strcompress('/jabber/sandbox/mcnally/ForKatNDVI/Mali4envi.csv')
write_csv,ofile,lat,lon
;read in the west africa NDVI data for 2006

;lets get some time series from the LIS first
ifile=file_search('/gibber/lis_data/OUTPUT/EXPA02/NOAH/daily/sm02_2006*.img')

nx=720
ny=350
ingrid=fltarr(nx,ny)
POI=fltarr(n_elements(ifile), n_elements(y))

;read in one map at a time, extract points of interest
for i=0,n_elements(ifile)-1 do begin
  openr,1,ifile[i]
  readu,1,ingrid
  close,1
  
  for j=0,n_elements(y)-1 do begin ;&$
  ;the SM values at the 'exact' locations
    ;j=0
    POI[i,j]=ingrid[x[j],y[j]]  ;&$
  endfor;j
  print, ifile[i] 
endfor;i  
;
;outarray=[transpose(float(lon(good))), transpose(float(lat(good))), POI]
;ofile='/jabber/sandbox/mcnally/ForKatNDVI/SM_Mali2006.csv'
;write_csv,ofile, outarray

;
;;**************************************************************************************
;do the same thing but for the 2006 NDVI

;;********change lon-lat to xy*********************
y=(lat-2)/0.002413 ;this checks out with ENVI, not sure about pixel corners.
x=(lon+19)/0.002413
nfile=file_search('/jabber/sandbox/mcnally/west_africa_emodis/WAdata.2006.*.img')
nx  = 19271
ny  = 7874
ingrid=fltarr(nx,ny)
POI=fltarr(n_elements(nfile), n_elements(y))

for i=0,n_elements(nfile)-1 do begin
  openr,1,nfile[i]
  readu,1,ingrid
  close,1
  
  for j=0,n_elements(y)-1 do begin ;&$
  ;the SM values at the 'exact' locations
    ;j=0
    POI[i,j]=ingrid[x[j],y[j]]  ;&$
  endfor;j
  print, nfile[i] 
endfor;i 
print, 'hold'

;outarray2=[float(lon), float(lat), POI]
;ofile='/jabber/sandbox/mcnally/ForKatNDVI/NDVI_Mali2006.csv'
;write_csv,ofile, outarray2
;
;
;;nice plot.....but not how you'd extract the points.   
;p1 = image(reverse(ingrid,2), image_dimensions=[72.0,35.0], image_location=[-19.95,-4.95], dimensions=[720,350], $
;           rgb_table=20)
;c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07])
;p1 = MAP('Geographic',LIMIT = [-4.95, -19.95, 29.95, 51.95], /overplot)
;p1 = MAPCONTINENTS(/COUNTRIES)
;p1 = plot(lon(good),lat(good),linestyle=6,'*', /overplot)
;
;
END
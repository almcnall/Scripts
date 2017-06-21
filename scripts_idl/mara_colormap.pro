function mara_colormap 

; first wrote the script on 6/27/11  (see notes in spiral red notebook)
; the purpose of this script is to associate the RGB from the bitmap to a month so that 
; I can define the start and end of season for my specific study sites. 
; going back through the code on 1/16/12

Device,DECOMPOSED=0;
;------------------------------------------------------------------------------------
;from pete FTIPP/make_2monthly_from_monthly.pro

gtag_p05_Deg =  {ModelTiepointTag:   [0,0,0, -20.0,40.0,0],  $  ; Long/Lat for center of upper left corner pixel
                 ModelPixelScaleTag:    [0.05, 0.05, 0],  $  ; Long/Lat spatial resolution in degrees
                 GTModelTypeGeoKey:                   2,  $  ; (ModelTypeGeographic)
                 GTRasterTypeGeoKey:                  1,  $  ; (RasterPixelIsArea)
                 GeographicTypeGeoKey:             4326,  $  ; (GCS_WGS_84)
                 GeogAngularUnitsGeoKey:          9102s   $  ; Angular_Degree
                }
;--------------------------------------------------------------------------------------

indir='/home/mcnally/luce_sites/' ;maybe I should replace this with the original eir file....

;lon lats that need to become x y
xycords = indir+'EIR_georeferencedv7_2IDL.csv';'Malaria_season_lat_lon.csv' ;> revert to this if other bombs. 
valid = query_csv(xycords, info) & print, valid, info
ifile = read_csv(xycords) 

;print the column of country names
c_name = ifile.field01         & print, transpose(c_name)
;print a list of the sampled countries (no duplicates): there are 15 countries
c_list=c_name(rem_dup(c_name)) & print, transpose(c_list)

;there are 162 cities/sites from the 15 countries
city_name = ifile.field02
city_list = city_name(rem_dup(city_name)) & print, transpose(city_list)
seasonality= ifile.field22
EIR = ifile.field19
;but only 160 unique lat/lons...what happened to the other 2?
lon=ifile.field04
lat=ifile.field05 ;try with originals not rounded 8 and 9

;;***************dealing with duplicate latlons************************
; Step 1: Map your columns 2 and 3 into a single unique index
  col1ord = ord(lon)
  col2ord = ord(lat)
  index = col1ord + (max(col1ord)+1)*col2ord ;this turns the 2 cols into a single unique index
; Step 2: Use histogram to find which ones have the same unique index 
  h = histogram(index, reverse_indices=ri) ;list of subscripts that contribute to each bin
; Step 3: Get the first one in each bin, and put back in sorted order 
  keep = ri[ri[where(h gt 0)]]
  keep = keep[sort(keep)]
; Step 4: Print/write them out without the nans
  unqlonlat = [transpose(lon(keep)), transpose(lat(keep))]
;*********************************************************************

;bmp maps of start and end of transmission season (color=month) 
;MinLat = -35. ;south &  MinLon = -17.5 &  MaxLat = 37.5  &  MaxLon = 51.5 
inSOS = indir+'AfFirstMonth1.bmp'
inEOS = indir+'AfLastMonth1.bmp'
;what happened when i checked the AfFirstMonth2.bmp??

;start of season and end of season files with funny dimensions
SOSmap = read_bmp(inSOS, r,g,b)
EOSmap = read_bmp(inEOS, r,g,b)

sosmap2 = read_bmp(inSOS)

;pad out the bmp file so that the dimensions are a nicer square/rectangle
;bmp map domian--at 0.05 resolution there are 20 pixels per degree
A = intarr(50,1450) ;add 2.5 degrees, pad to -20E (2.5*20=50pixels) 
B = intarr(70,1450) ; add 3.5 degrees, pad to 55W
C = intarr(1500,50) ; add 2.5 degrees, to pad to 40N

;cat east/west fillers
bottomSOS = [A, SOSmap, B] & bottomEOS = [A, EOSmap, B] 

;the new&improved arrays!
fixedSOS = [[bottomSOS], [C]] ;cat in y-direction with double brackets, silly idl
fixedEOS = [[bottomEOS], [C]]

 ;change the site lat lons into x and y so I can extract relevant EOS and SOS info.
 x = (lon+20)*20 ;becasue it is -20w
 y = (lat+35)*20;becasue it is -35s

;start of season map with study locations
;p1=image(fixedSOS, rgb_table=6, /overplot)
;p1=plot(x,y, 'w*',linestyle=6, /overplot)

;now I want a list of x and y locations and their start and end of season
siteSOS = fixedSOS(x,y)
siteEOS = fixedEOS(x,y)

;concatinate the relevant vars so I can pass them to EIR structure.pro
;fixSeason = [x, y, siteSOS, siteEOS]
fixSeason = [transpose(x), transpose(y), transpose(siteSOS),transpose(siteEOS)]

mapLOS=fltarr(193)
;calculate the length of the season (LOS) from the map. We'll ignore the yr round and no start
ez = where(siteSOS lt siteEOS)
mapLOS(ez) = siteEOS(ez) - siteSOS(ez)
hd = where(siteSOS  ge siteEOS) 
mapLOS(hd) = (12 - siteSOS(hd)) + siteEOS(hd)

;*****************the most useful part of this script*************************************
;********create a file with sites, SOS, EOS***********************************************
write_csv, indir+'location_SOS_EOS_LOS2_EIR.csv',c_name,lon,lat,seasonality,siteSOS,siteEOS,mapLOS,EIR 
;*****************************************************************************************

mapMaraDiff=seasonality-mapLOS

fixSeason = [transpose(x), transpose(y), transpose(siteSOS),transpose(siteEOS), transpose(seasonality), transpose(mapLOS), transpose(mapMaraDiff)]
print, fixSeason
;I am not going to use the points where it says that the transmission season is 0, but will use the ones where it is 13.
lonlats=[transpose(lon), transpose(lat)]
return, lonlats
end




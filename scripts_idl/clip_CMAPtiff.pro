pro clip_CMAPtiff

;this program clips out the global ftip to the 1501x1601 africa window.
;6/3/2013 modified the script to clip CMAP/CSCDP to the 0.05 degree window.(1500x1600)


;thanks for the tag pete but missing some info...not sure how to see what
;gtag_1Deg = { ModelTiepointTag: [0,0,0, -20.05,40.05,0], $
;                ModelPixelScaleTag: [0.1,0.1,0], $
;                GTModelTypeGeoKey:    2,         $  ; (ModelTypeGeographic)
;                GTRasterTypeGeoKey:   1,         $  ; (RasterPixelIsArea)
;                GeographicTypeGeoKey: 4326,      $  ; (GCS_WGS_84)
;                GeogAngularUnitsGeoKey: 9102s    $  ; Angular_Degree
;          }


;ifile = file_search('/jower/sandbox/mcnally/CMAP/*rain1*.tif')
ifile = file_search('/jower/sandbox/mcnally/CSCDP/cscdp.20*.tif')
stack = fltarr(1500,1600)

;first clip to the RFE window....
for j=0,N_elements(ifile)-1 do begin &$
  CMAP = read_tiff(ifile[j],R,G,B,geotiff=geotiff) &$
  CMAP = rebin(CMAP,7200,2000) &$
  CLIP = CMAP[3200:4699,200:1799] &$
  CLIP = reverse(clip,2) &$
  ofile = strcompress('/jower/LIS/data/CSCDP_afr/'+strmid(ifile[j],29,22), /remove_all) &$
  openw,1,ofile &$
  writeu,1,clip &$
  close,1 &$
  stack = mean([ [[CLIP]],[[stack]] ], dimension=3) &$
endfor

;CMAP05 = rebin(stack,7200,2000)
 ;1500,1600 0.05 africa window...
temp = image(reverse(clip,2), rgb_table=4);1500,1600 isn't bad....



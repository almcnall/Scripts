pro hadcm3_clip
;the purpose of this file is to read in the tffs, clip them and write them out as tiffs for Sadie

;thanks for the tag pete but missing some info...not sure how to see what
;gtag_1Deg = { ModelTiepointTag: [0,0,0, -20.05,40.05,0], $
;                ModelPixelScaleTag: [0.1,0.1,0], $
;                GTModelTypeGeoKey:    2,         $  ; (ModelTypeGeographic)
;                GTRasterTypeGeoKey:   1,         $  ; (RasterPixelIsArea)
;                GeographicTypeGeoKey: 4326,      $  ; (GCS_WGS_84)
;                GeogAngularUnitsGeoKey: 9102s    $  ; Angular_Degree
;          }
;just use the header info from greg's files g_tags is the important part...
masktest = file_search('/home/mcnally/mask_ndvi020.tif')
test = read_tiff(masktest,GEOTIFF=g_tags)
;Result = QUERY_TIFF( masktest , Info, GEOTIFF=variable, IMAGE_INDEX=index )

inx = 4320 ;rebin this to 3600
iny = 1800 ;and this to 1500
inz = 12

ox = 3600
oy = 1500

buffer = intarr(inx,iny,inz)
ifile = file_search('/jabber/sandbox/mcnally/HADCM34luce/HADCM3_ESRIgrid/IMG_2020/hadcm3_2020')

openr,1,ifile
readu,1,buffer
close,1
buffer = reverse(buffer,2)

outdir = strcompress('/jabber/sandbox/mcnally/HADCM34luce/HADCM3_tiffs/proj2020/', /remove_all)
month = ['01','02','03','04','05','06','07','08','09','10','11','12']
for z = 0,inz-1 do begin &$
  coarse = CONGRID(buffer[*,*,z],ox,oy) &$
  africa = reverse(coarse[1600:2350,200:1000]/10.,2) &$
  null = where(africa lt -3276) &$
  africa(null) = -999.0 &$
  ;temp = image(africa)
  write_tiff,  outdir+'africa_tmean_'+month[z]+'.tiff', africa, geotiff=g_tags, /FLOAT &$
endfor 



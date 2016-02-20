pro eMODIS_fix2

;this script is to check out the eMODIS data.
;MODIS NDVI data are stretched (mapped) linearly (to byte values) as follows:
;[-1.0, 1.0] -> [0, 200]
;Invalid Values: 201 - 255 
;NDVI = (value – 100) / 100;  example:  [ (150 – 100) / 100 = 0.5 NDVI ]

;indir = strcompress('/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/dekads/', /remove_all)
indir = strcompress('/jabber/sandbox/shared/eMODIS/', /remove_all)

cd, indir

;open the file, save the area of interest (west africa window) and then close the file...
;what is the FEWS west africa window? 
;pixel size:  -0.00241300000000
;lef lon:    -18.99879350000000
;upper lat:   20.99875550000000
;lower lat:    2.004
;year = ['2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011']
year = ['2010','2011'] ; crashed after 2008 so restarting 1/18

nx = 29838
ny = 31299

;double check to make sure that this matches the fews window...dimensions are right but do they line up?
outx = 19271
outy = 7874



;NDVI=fltarr(nx, ny)

;is there a way to do this without a loop? this is horribly slow. 
;for i = 0,n_elements(year)-1 do begin
  ifile = file_search('data.{2010,2011}*.tiff') ;is this going to match the new data? it should...
  for j = 0,n_elements(ifile)-1 do begin
    NDVI = read_tiff(ifile[j],R,G,B,geotiff=geotiff)
    NDVI = reverse((NDVI-100.)/100.,2)
    ;21N,19W - this matches the FEWS TIFF...
    ;according to envi, this matches the fews window identicaly
     AOI = NDVI(414:19684,15551:23424) 
     NDVI=0 ;free the NDVI var from memory  
  
     ofile = strcompress('/jabber/sandbox/mcnally/west_africa_emodis/WA'+ifile[j]+'.img', /remove_all)
     openw,1,ofile
     writeu,1,AOI
     print, 'writing west_africa_emodis/WA'+ifile[j]+'.img'
     close,1
     AOI=0
 endfor ;j
    
end    
;
;lat = 13.5
;lon = 2.6
;
;ROIx = (19.99+lon)/0.0024
;ROIy = (35.5+lat)/0.0024

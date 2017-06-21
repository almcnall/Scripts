pro eMODIS_clip2008123

;this is a copy of eMODIS.pro but modified to clip just 2008.12.3 from the original dataset. I accidently deleted it since
;my naming convention was off... 

indir = strcompress('/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/dekads/', /remove_all)
cd, indir

;open the file, save the area of interest (west africa window) and then close the file...
;what is the FEWS west africa window? 
;pixel size:  -0.00241300000000
;lef lon:    -18.99879350000000 (19)
;upper lat:   20.99875550000000
;lower lat:    2.004
;year = ['2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011']
year = ['2008'] ; crashed after 2008 so restarting 1/18

nx = 29838
ny = 31299

;double check to make sure that this matches the fews window...dimensions are right but do they line up?
outx = 19271
outy = 7874



;NDVI=fltarr(nx, ny)

;is there a way to do this without a loop? this is horribly slow. 
;for i = 0,n_elements(year)-1 do begin
  ifile = file_search('data.2008.123.tiff')
   NDVI = read_tiff(ifile,R,G,B,geotiff=geotiff)
   NDVI = reverse((NDVI-100.)/100.,2)
    ;21N,19W - this matches the FEWS TIFF...
    ;according to envi, this matches the fews window identicaly until Nov 2011.
   AOI = NDVI(414:19684,15551:23424) 
   NDVI=0 ;free the NDVI var from memory  
  
     ofile = strcompress('/jabber/sandbox/mcnally/west_africa_emodis/WAdata.2008.124.tiff.img', /remove_all)
     openw,1,ofile
     writeu,1,AOI
     print, 'writing west_africa_emodis/WA'+ifile+'.img'
     close,1
     AOI=0

    
end    
;
;lat = 13.5
;lon = 2.6
;
;ROIx = (19.99+lon)/0.0024
;ROIy = (35.5+lat)/0.0024
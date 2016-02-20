pro eMODIS_fine2coarse

;this script agregates 250m NDVI for continental africa to 0.1 degree -- in a more careful way than using rebin/congrid.
;The output is still in dekads (9/14/2012)

;read in ndvi file and add it all up.
idir = '/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/dekads/'
odir = '/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/update/'

;data_dir = '/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/dekads/'
;cd,data_dir

;testtif = 'data.2001.071.tiff'

;for m = 1,12 do begin &$
;  m=1
;  mm = STRING(FORMAT='(I2.2)',m) &$
  ifile = file_search(idir+'data.{2012}.*' ) &$ 
  print,systime()
for f=0,n_elements(ifile)-1 do begin
    ;ndvi = read_tiff(idir+testtif,GEOTIFF=g_tags)
    ndvi = read_tiff(ifile[f],GEOTIFF=g_tags)
    sclf = 0.1 / g_tags.modelpixelscaletag[0]               ; scale factor to make larger data

    bignx = 751                     ; output X for 0.1-degree
    bigny = 801                     ; output Y for 0.1-degree grid
    lilnx = bignx * sclf            ; output X for 250m grid
    lilny = bigny * sclf            ; output Y for 250m grid
    indims = SIZE(ndvi,/DIMENSIONS) ; dimensions for input NDVI grid

    fine_grid = BYTARR(lilnx,lilny)
    coarse_grid = BYTARR(bignx,bigny)

    fine_grid[ROUND(sclf/2.)-1:ROUND(sclf/2.)+indims[0]-2,ROUND(sclf/2.)-1:ROUND(sclf/2.)+indims[1]-2] = ndvi
    print,systime()
    ;this regrids the image in an acceptable way
      for x=0,bignx-1 do begin &$
        for y=0,bigny-1 do begin &$
          coarse_grid[x,y] = BYTE(MEAN(fine_grid[FLOOR(x*sclf):FLOOR((x+1)*sclf)-1,FLOOR(y*sclf):FLOOR((y+1)*sclf)-1])) &$
        endfor &$
      endfor &$
     print,systime()

    ;tmpgr = IMAGE(coarse_grid,/ORDER,RGB_TABLE=4)
  
  ofile = odir+strmid(ifile[f],52,13)+'.img' &$
  openw,1,ofile &$
  writeu,1,coarse_grid &$
  close,1 &$

endfor
print, 'hold here'
end
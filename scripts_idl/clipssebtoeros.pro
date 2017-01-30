pro clipSSEBtoEROS

;05/13/16 this script clips the monthly, continental Africa SSEB to the differnet EROS domains.
;moved from noahVsseb to its own script.
;01/15/17 update to include more recent EA, did not do SA or WA.
;
;;try reading in the SSEB data for east africa
;;first read one in to get the domain info for upper left x and y.
indir = '/discover/nobackup/projects/fame/Validation/SSEB/ETA_AFRICA/'
ifile = file_search(strcompress(indir+'/ma0401.modisSSEBopET.tif',/remove_all))
ingrid = read_tiff(ifile, geotiff=gtag)
ingrid = reverse(ingrid,2)

smap_ulx = gtag.MODELTIEPOINTTAG[3]
smap_lrx = 54.75 ;
smap_uly = gtag.MODELTIEPOINTTAG[4]
smap_lry = -37.75

ulx = (180.+smap_ulx)/0.0083  & lrx = (180.+smap_lrx)/0.0083
uly = (50.-smap_uly)/0.0083    & lry = (50.-smap_lry)/0.0083
NX = lrx - ulx -1
NY = lry - uly
print, nx, ny
help, ingrid

;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
params = get_domain01('EA')

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

;;;; VIC East africa domain ;;;;;
;map_ulx = 21.875 & map_lrx = 51.125
;map_uly = 23.125 & map_lry = -11.875

res = 10. ;or 10. if its 0.1 degree, 4 or for 0.25 VIC

ulx = (180.+map_ulx)*res  & lrx = (180.+map_lrx)*res-1
uly = (50.-map_uly)*res   & lry = (50.-map_lry)*res-1
NX = lrx - ulx + 2
NY = lry - uly + 2

;;;;;;;clip continental africa to east/west africa domain;;;;;;
ea_left = (map_ulx-smap_ulx)/0.0083 & print, ea_left
ea_right = (map_lrx-smap_ulx)/0.0083 & print, ea_right
ea_bot = abs(smap_lry-map_lry)/0.0083 & print, ea_bot
ea_top = (map_uly-smap_lry)/0.0083 & print, ea_top

;check the west africa domain - this should be in separate script
temp = image(ingrid[ea_left:ea_right,ea_bot:ea_top])

startyr = 2003
endyr = 2016
NMOS = 12
temp = ingrid[ea_left:ea_right,ea_bot:ea_top]
dim = size(temp,/dimensions) & print, dim
SNX = dim[0]
SNY = dim[1]

ETA = bytarr(NX,NY,NMOS,(endyr-startyr)+1)
;ETA = bytarr(3537,4182,12,(endyr-startyr)+1)
;ETA = bytarr(294,348,12,(endyr-startyr)+1)

indir = '/discover/nobackup/projects/fame/Validation/SSEB/ETA_AFRICA/'
TIC
;;read in the 0.1x0.1 degree file instead
for y = startyr,endyr do begin &$
  for m = 1,12 do begin &$
  yy = strmid(string(y),6,2) &$
  ifile = file_search(strcompress(indir+'/ma'+yy+STRING(format='(I2.2)', m)+'.modisSSEBopET.tif',/remove_all)) &$
  ingrid = read_tiff(ifile, geotiff=gtag) &$
  ingrid = reverse(ingrid,2) &$
  ETA[*,*,m-1,y-startyr] = congrid(ingrid[ea_left:ea_right,ea_bot:ea_top],NX,NY) &$
endfor &$
endfor
TOC

;write out file since it takes 3 min to generate.
ofile = indir+'ETA_EA_294_348_12_14_byte.bin'
openw,1,ofile
writeu,1,ETA
close,1

;write out file since it takes 3 min to generate.
;ofile = indir+'ETA_EA_294_348_12_14_byte.bin'
;openw,1,ofile
;writeu,1,ETA
;close,1

;;read in the file that I just wrote out
;buffer = bytarr(3537,4182,12,(endyr-startyr)+1)
;NX = 294
;NY = 348
ETA = bytarr(NX,NY,12,(endyr-startyr)+1)
openr,1,indir+'ETA_EA_294_348_12_14_byte.bin'
;openr,1,indir+'ETA_WA_446_124_12_14_byte.bin'
;openr,1,indir+'ETA_SA_486_443_12_14_byte.bin'

readu,1,ETA
close,1

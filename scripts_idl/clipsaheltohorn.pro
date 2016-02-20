pro clipSaheltoHorn

;this script subsets the Sahel window to just the Horn.
;all the files are there but no data....so I think that is the same window but 27W
;10/16/2013: modified this script to match Shrad's Horn domain so that i can look at VIC and Noah data.
;I should start with the rainfall, but that might be a waste of time if the chirps are crappy. 
;we'll see...
;
;rfile = file_search('/raid/chg-mcnally/ubRFE04.19.2013/dekads/sahel/*.img')
;nfile = file_search('/raid/MODIS/eMODIS/01degree/sahel/data*.img')
;efile =  file_search('/raid/chg-mcnally/fromKnot/EXP01/dekadal/Evap*.img'); these are only 396
;s1file = file_search('/raid/chg-mcnally/fromKnot/EXP01/dekadal/Sm01*.img'); these are only 396
;s2file = file_search('/raid/chg-mcnally/fromKnot/EXP01/dekadal/Sm02*.img'); these are only 396
;s3file = file_search('/raid/chg-mcnally/fromKnot/EXP01/dekadal/Sm03*.img'); these are only 396
;Q1file = file_search('/raid/chg-mcnally/fromKnot/EXP01/dekadal/Qsuf*.img'); these are only 396
Q2file = file_search('/raid/chg-mcnally/fromKnot/EXP01/dekadal/Qsub*.img'); these are only 396

;and the microwave data....dekadal i suppose.
mwfile = file_search('/

;get the Noah output from the Knot directory....

; use this bit o' code to write out Horn .tifs
nx = long(720)
ny = long(250) ;350 for the NDVI and RFE
nz = long(n_elements(efile)) ;432 for emodis and RFE...396 for lis runs
ingrid = fltarr(nx,ny,nz)
temp = fltarr(nx,ny)

for i = 0,n_elements(efile)-1 do begin &$
  ;change this file....
  openr,1,Q2file[i] &$
  readu,1,temp &$
  close,1 &$
  deg = 28 &$
  
  lft = (deg+20)/0.1 &$
  horn = temp[lft:719, *,*]  &$
  ;ingrid[*,*,i] = temp &$
  ;ofile = strcompress('/raid/chg-mcnally/horn/Evap_horn_'+strmid(efile[i],46,9)+'.tif') & print, ofile &$
  ofile = strcompress('/raid/chg-mcnally/horn/Qsub_horn_'+strmid(s1file[i],46,9)+'.tif') & print, ofile &$
  
  write_tiff, ofile, horn*864000, geotiff=g_tags, /FLOAT &$
endfor 
;**********************************************************************************************************

;I set what I want my left bound to be and my right bound is 52
;and my N/S bounds are -5 to 20  - my window is smaller than both pete's becasue i miss the bottom 7 deg.
deg = 28
lft = (deg+20)/0.1
horn = ingrid[lft:719, *,*] & help, horn
temp = image(total(horn,3, /nan), rgb_table=4)

rainhorn = total(horn,3,/nan)
ndvihorn = horn

;ofile = '/jabber/LIS/Data/ubRFE2/dekads/horn/horn_ubrfe_2001_201232_dek.img'
ofile = '/raid/chg-mcnally/Qsub_horn_2001_2011.img'
openw,1,ofile
writeu,1,horn
close,1

;so the tag information remains correct, you just have to flip the image in envi. not sure what happens in R.


;see how it looks: did i put a cap on the ubrfe earlier? 1000mm/day cap *10 days
NX = 250;
NY = 350;
NZ = 428;

horn = fltarr(nx,ny,nz)
api = fltarr(nx,ny,nz)
api2 = fltarr(nx,ny,nz)
ifile = file_search('/jabber/LIS/Data/ubRFE2/dekads/horn/horn_ubrfe_2001_201232_dek.img')
openr,1,ifile
readu,1,horn
close,1

afile = file_search('/jabber/LIS/Data/ubRFE2/dekads/horn_API_2001_2012.img')
openr,1,afile
readu,1,api
close,1
;uni = where(api gt 60., count)
;api(uni) = !values.f_nan
;temp = image(mean(api,dimension=3, /nan), rgb_table=4)
;c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07])

;see if anything has changed, nope, matlab is consistant, I just need to figure out how to mask these areas of interest. 
;maybe the new corrleation map will tell me that. 
a2file = file_search('/jabber/LIS/Data/ubRFE2/dekads/horn_API_2001_2012v2.img')
openr,1,a2file
readu,1,api2
close,1

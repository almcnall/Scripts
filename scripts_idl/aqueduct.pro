;this script is to calculate the aquestat indices
;baseline water stress = available flow/withdrawals....
;12/12/14 revisit for AGU
;02/10/14 sahel baseline water stress esp 2012
;04/17/2015 try to compute monthly blue water availability
;04/27/2015 compute monthly BLWS for Southern Africa. 
;09/03/2015 revisit for more routine monthly BLWS. Can a population map do better? Have I downloaded an Afripop map?
; this index is good for highlighting where population centers are, so we actually need to overlay with with the drought serverity index for a better index. 
; update the code to work with the new output.
;09/09/15 I don't think I did much on the 3rd. Look into computing the BLWS for southern Africa again to capture the drought event.
;09/21/15 make plots of basline water stress to highlight trouble zones
;(oops....go to aqueduct v2) 9/23/15 working out units with Ian
;
;1. blue water = runoff + [renewable] groundwater (soil)
;2. Compute bluewater footprint
; 2a. rainfed ag = 0
; 2b. rirrigated ag = WR - AET
;   
startyr = 1981 ;start with 1982 since no data in 1981
endyr = 2015
nyrs = endyr-startyr+1

;re-do for all months
startmo = 1
endmo = 12
nmos = endmo - startmo+1

;West Africa (5.35 N - 17.65 N; 18.65 W - 25.85 E)
; west africa domain
;map_ulx = -18.65 & map_lrx = 25.85
;map_uly = 17.65 & map_lry = 5.35

;East Africa WRSI/Noah window
;map_ulx = 22.  & map_lrx = 51.35
;map_uly = 22.95  & map_lry = -11.75

;Southern Africa WRSI/Noah window
;Southern Africa (37.85 S - 6.35 N; 6.05 E - 54.55 E) 
;NX = 486, NY = 443
map_ulx = 6.05  & map_lrx = 54.55
map_uly = 6.35  & map_lry = -37.85

ulx = (180.+map_ulx)*10.  & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10.   & lry = (50.-map_lry)*10.-1
NX = lrx - ulx + 2 
NY = lry - uly + 2


;data_dir2 = '/home/sandbox/people/mcnally/WRSI_May2Nov_GW2_YR/'
data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_CHIRPSv2_MERRA_SA/';FLDAS_NOAH01_B_SA_M.A201507.001.nc
;data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_CHIRPSv2_MERRA_WA/';FLDAS_NOAH01_B_SA_M.A201507.001.nc
;data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_CHIRPSv2_MERRA_EA/';FLDAS_NOAH01_B_SA_M.A201507.001.nc


SM = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
Qsub = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
Qsuf = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
SMper = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan

;WR = FLTARR(NX,NY,nmos,nyrs)
;ETA = FLTARR(NX,NY,nmos,nyrs)
;this loop reads in the selected months only
for yr=startyr,endyr do begin &$
  for i=0,nmos-1 do begin &$
  y = yr &$
  m = startmo + i &$
  if m gt 12 then begin &$
    m = m-12 &$
    y = y+1 &$
  endif &$
  fileID = ncdf_open(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_B_SA_M.A'',I4.4,I2.2,''.001.nc'')',y,m), /nowrite) &$
  SoilID = ncdf_varid(fileID,'SoilMoi00_10cm_tavg') &$
  ncdf_varget,fileID, SoilID, SM01 &$
  SM[*,*,i,yr-startyr] = SM01 &$
  
  qsID = ncdf_varid(fileID,'Qs_tavg') &$
  ncdf_varget,fileID, qsID, Qs &$
  Qsuf[*,*,i,yr-startyr] = Qs &$
 
  qsID = ncdf_varid(fileID,'Qsb_tavg') &$ ;SM01_Percentile
  ncdf_varget,fileID, qsID, Qsb &$
  Qsub[*,*,i,yr-startyr] = Qsb &$
  
  qsID = ncdf_varid(fileID,'Qsb_tavg') &$ ;SM01_Percentile
  ncdf_varget,fileID, qsID, Qsb &$
  Qsub[*,*,i,yr-startyr] = Qsb &$
  
  qsID = ncdf_varid(fileID,'SM01_Percentile') &$ ;
  ncdf_varget,fileID, qsID, SMP &$
  SMper[*,*,i,yr-startyr] = SMP &$
  
;  fileID = ncdf_open(data_dir2+STRING(FORMAT='(''WR_YRMO/WR_gWRSI_'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
;  wrID = ncdf_varid(fileID,'SumWR_inst') &$
;  ncdf_varget,fileID, wrID, SumWr &$
;  WR[*,*,i,yr-startyr] = SumWR &$
  
;  fileID = ncdf_open(data_dir2+STRING(FORMAT='(''ET_YRMO/ET_gWRSI_'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
;  etID = ncdf_varid(fileID,'SumET_inst') &$
;  ncdf_varget,fileID, etID, SumET &$
;  ETA[*,*,i,yr-startyr] = SumET &$

  endfor &$ 
endfor
sm(where(sm lt 0))   = 0 ;CHIRPS MERRA
Qsuf(where(Qsuf lt 0)) = 0
Qsub(where(Qsub lt 0)) = 0
SMper(where(SMper lt 0)) = 0
;WR(where(WR lt 0)) = 0
;ETA(where(ETA lt 0)) = 0

;hazards pay attention to crop zones, we need people zone and all yr.

;;;;;;afri-pop BLWSv2;;;;;;;;;;;
;where population is greatern than X and SM percentile is lt Y then map = 1,0
;open population map
indir = '/home/sandbox/people/mcnally/Africa-POP/'
ingrid = read_tiff(indir+'SAfrica_POP_10km.tiff'); 0-20,757pp/pixel (10km)
temp = image(ingrid, max_value=100)

;example for February 2015
hotspot = qs*!values.f_nan & help, hotspot

dry = where(SMper[*,*,2,34] lt 0.3 AND ingrid gt 50, complement = wet)
hotspot(dry) = 1
hotspot(wet) = 0

ncolors=2
p1 = image(congrid(hotspot, NX*3, NY*3), image_dimensions=[NX/10,NY/10], $
  image_location=[map_ulx,map_lry],RGB_TABLE=55, /current, $
  MARGIN=[0.01, 0.01, 0.01, 0.1])  &$ ;left, botton, right, top
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  ;rgbdump[*,255] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  ;rgbdump[*,0] = [190,190,190] &$
  ;rgbdump[*,255] = [190,190,190]
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  ;p1.title = month[i] &$
  p1.MAX_VALUE=1 &$
  p1.min_value=0 &$
  m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=1)

;ofile = '/home/sandbox/people/mcnally/hotspot.sa.march.2015.bin'
;openw,1,ofile
;writeu,1,reverse(hotspot,2)
;close,1

;get the whc from the WRSI file - doens't cover Yemen - i did make one of these for LIS.
;ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input_wrsi.ea_may2nov.nc') & print, ifile ;long mask
;fileID = ncdf_open(ifile, /nowrite) &$
;whcID = ncdf_varid(fileID,'WHC')
;ncdf_varget,fileID, whcID, WHC
;
;;stupid WHC doesn't include yemen.
;SMmm = rebin(WHC,NX,NY,12,nyrs)*SM

;how much likely goes to irrigation? WR-ETa
;IRR = (WR-ETA)/10

;assume WHC is uniformly 90mm 
;SMmm = SM*90

;;;;;;;AQUEDUCT WITHDRAWLS;;;;;
;TBW = SMmm+(Qsuf+Qsub)*86400 & help, TBW ;no SM because in %VWC



; read in withdrals (m3), subset to africa
; 
indir = '/home/sandbox/people/mcnally/AQUEDUCT/withdrawal/'

ifile = file_search(indir+'*lat_lon2.tif')
ingrid = read_tiff(ifile,R,G,B,geotiff=geotiff);i think that this is 55S-85N

ingrid = reverse(ingrid,2)
;
;dims = size(ingrid, /dimensions)
;
;NX = dims[0]
;NY = dims[1]

;East Africa WRSI/Noah window
;map_ulx = 22.  & map_lrx = 51.35
;map_uly = 22.95  & map_lry = -11.75

;Southern Africa WRSI/Noah window
;Southern Africa (37.85 S - 6.35 N; 6.05 E - 54.55 E)
NX = 486 & NY = 443
map_ulx = 6.05  & map_lrx = 54.55
map_uly = 6.35  & map_lry = -37.85

; west africa domain
;map_ulx = -18.65 & map_lrx = 25.85
;map_uly = 17.65 & map_lry = 5.35

;x direction is ~1degree and y is ~0.5 degree..
ulx = (180.+map_ulx)/1.29  & lrx = (180.+map_lrx)/1.29
uly = (55+map_uly)/0.93   & lry = (55.+map_lry)/0.93

print, ulx, lrx, uly, lry
NX = lrx - ulx 
NY = uly - lry

afr =ingrid[ulx:lrx,lry:uly]
afr(where(afr lt 0)) = !values.f_nan

;first map estimated withdrawls required perperson



;rebinafr = rebin(congrid(afr/12,294,348),294,348,12,nyrs)
rebinafr = rebin(congrid(afr/12,486,443),486,443,12,nyrs)

;rebinafr = congrid(afr,117,139)
;rebinafr = congrid(afr,446,124)

;what does average monthly water availability look like?
help, TBW, IRR, rebinafr
;mask out december 2014 since there was no data
;TBW[*,*,11,33]=!values.f_nan

;compute average TBW for each month.
mTBW = mean(TBW,dimension=4,/nan);*1000000
mTBW_JFM = mean(mean(TBW[*,*,0:2,*],dimension=3,/nan),dimension=3,/nan);*1000000

;mIRR = mean(IRR, dimension=4,/nan)
mWTH = mean(rebinafr,dimension=4,/nan);/10 ;dvide by 10 since the value is a basin avg in km3 and these are 10km2 pixels
; km3 = 1x10^18 mm3, 1*10^-15 = cm3, and multiply TBW*1,000,000 to change mm to km ...this makes everything 10^7
;max withdrawls are still more than available H20, where?;

;compute the TBW anoamlies for each month:
mTBW35 = rebin(mTBW,486,443,12,nyrs)
;mTBW34_JFM = rebin(mTBW_JFM,486,443,nyrs)

TBWanom = TBW - mTBW35

;TBW_JFM = mean(TBW[*,*,0:2,*], dimension=3,/nan)
;TBWanom_JFM = TBW_JFM - mTBW34_JFM



help, mTBW, mIRR, mWTH
;mWTHs = mWTH
;no irrigated ag stress is 0-30
BLWS = mWTH/mTBW
;
;
ncolors=100 ;10 for VIC v NOAH there is a funny hash pattern in VIC v Noah, maybe becasue of re-gridding
;nx = 294
;ny = 348
nx = 486
ny = 443
i=1
month = ['jan', 'feb', 'mar','apr','may','jun','jul','aug','sep','oct','nov','dec']
CLASS = [' low to medium ', 'medium to high', 'high', 'extremely high']

;this was the average monthly stress. how about all 32 yrs?
;for BLWS use rgb_table=55 (now I am really f-ing this up_
w = window(DIMENSIONS=[1400,600])
for i=0,11 do begin &$
  i=0
  p1 = image(congrid(BLWS[*,*,i], NX*3, NY*3), image_dimensions=[NX/10,NY/10], $
  image_location=[map_ulx,map_lry],RGB_TABLE=55, /current, $
   MARGIN=[0.01, 0.01, 0.01, 0.1])  &$ ;left, botton, right, top
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  ;rgbdump[*,255] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  ;rgbdump[*,0] = [190,190,190] &$
  ;rgbdump[*,255] = [190,190,190]
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.title = month[i] &$
  ;p1.MAX_VALUE=1.2 &$
  ;p1.min_value=0.7 &$
;  cb = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,font_size=24) &$
;  cb.tickvalues = [0.1,0.3,0.5,0.7] &$
;  cb.tickname = CLASS &$
;  cb.minor=0 &$
  m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=1) &$
 endfor 
  
;;;;TBW anomalies
ncolors=25
w = window(DIMENSIONS=[1400,600])
for YOI=2008,2014 do begin &$
;for i=0,4 do begin &$
  p1 = image(congrid(TBWanom_JFM[*,*,YOI-startyr], NX*3, NY*3), image_dimensions=[NX/10,NY/10], $
  image_location=[map_ulx,map_lry],RGB_TABLE=70, /current, layout = [4,2,2015-YOI], $
  MARGIN=[0.02, 0.01, 0.02, 0.1])  &$ ;left, botton, right, top
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  ;rgbdump[*,255] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  ;rgbdump[*,0] = [190,190,190] &$
  ;rgbdump[*,255] = [190,190,190]
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.title = string(YOI) &$
  p1.MAX_VALUE=5 &$
  p1.min_value=-5 &$
  cb = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,font_size=24) &$
  ;  cb.tickvalues = [0.1,0.3,0.5,0.7] &$
  ;  cb.tickname = CLASS &$
  ;  cb.minor=0 &$
  ;m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot) &$
  m1 = MAP('Geographic',limit=[-28,18,-21,30], /overplot) &$

  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2) &$
 ;endfor &$
endfor

;show a time series of TBW anomalies for this region November-March 1981-2013
;limit=[-28,21,-21,30]
gmap_lry = -28
gmap_ulx = 21
gmap_uly = -21
gmap_lrx = 30

gulx = (gmap_ulx-map_ulx)/0.1  & glrx = (gmap_lrx-map_ulx)/0.1
guly = (gmap_uly-map_lry)/0.1   & glry = (gmap_lry-map_lry)/0.1

print, gulx, glrx, guly, glry


ROIanom = mean(mean(TBWanom_JFM[gulx:glrx,glry:guly,*],dimension=1,/nan),dimension=1,/nan)
p1 = barplot(roianom)
p1.xrange = [0,nyrs-1]
xticks = indgen(nyrs+1)+startyr & print, xticks
p1.xtickinterval = 1
p1.xTICKNAME = strmid(string(xticks),6,2)
p1.xminor = 0
;p1.yrange=[-2.5,2.5]
afr(where(afr lt 0)) = !values.f_nan


;;;;;;now add in the irrigated ag.
;ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input.EA.modislc_gripc.nc')
;fileID = ncdf_open(ifile, /nowrite)
;
;irrgID = ncdf_varid(fileID,'IRRIGFRAC') &$
;ncdf_varget,fileID, irrgID, IRRG_f
;
;irrgID = ncdf_varid(fileID,'IRRIGTYPE') &$
;  ncdf_varget,fileID, irrgID, IRRG_t
;
;cropID = ncdf_varid(fileID,'CROPTYPE') &$
;  ncdf_varget,fileID, cropID, CROP
;dims = size(CROP, /dimensions)
;crop(where(crop lt 0)) = !values.f_nan
;
;landID = ncdf_varid(fileID,'LANDCOVER') &$
;  ncdf_varget,fileID, landID, LAND
;dims = size(LAND, /dimensions)
;
;nx = dims[0]
;ny = dims[1]
;nz = dims[2]

;mask IRR values where irrigation is present
;IRR and WTH should be in comprable units...

irrmask = irrg_f
irrmask(where(irrmask gt 0, complement=other))=1
irrmask(other)=0

irrmask12=rebin(irrmask,nx,ny,12)
irrmask32=rebin(irrmask,nx,ny,12,nyrs)

ag = irrmask12*mIrr
ag32 = irrmask32*Irr
WTHs = rebinafr;scale this?

help, ag32, TBW, WTHs

BLWS = WTHs/(TBW-ag32) & help, BLWS
;worst rainy seasons March-Sept
M2S = mean(mean(mean(BLWS[*,*,2:8,*],dimension=1,/nan),dimension=1,/nan),dimension=1,/nan)
p1=barplot(m2s-mean(m2s))
p1.xrange = [0,nyrs-1]
xticks = indgen(nyrs+1)+startyr & print, xticks
p1.xtickinterval = 1
p1.xTICKNAME = string(xticks)
p1.xminor=0
p1.yminor=0
p1.title = 'East Africa domain average March-Sept BLWS anom (1982-2013)'
p1.yrange=[-.1,.1]
p1.title.font_size=18



tmpgr = image(congrid(afr,446,124), RGB_TABLE=64, MIN_VALUE=0., $
  TITLE='Aqueduct_withdrawals',FONT_SIZE=14, MAX_VALUE=1000000000, $
   AXIS_STYLE=0,MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], $
  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry])
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
tmpgr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=tmpgr,ORIENTATION=0,FONT_SIZE=0)
tmpgr.save,strcompress('/home/sandbox/people/mcnally/'+tmpgr.title.string+'.jpg', /remove_all),RESOLUTION=200
;get Qsurf and Qsub (k/m2/s = mm/s) 3.16x10^7 sec/yr total annual runoff (per pixel)



;read in Shrad's VIC data mm/day (mm/yr)
;ifile = file_search('/home/sandbox/people/mcnally/VIC_RO/RO_yearsum_1982_2010.nc')
;fileID = ncdf_open(ifile, /nowrite) &$
;  qsID = ncdf_varid(fileID,'RUNOFF') &$
;  ncdf_varget,fileID, qsID, VIC
;VIC(where(VIC lt 0)) = !values.f_nan
;VIC(where(VIC gt 5000))=!values.f_nan
;
;;pad out left side of the figure
;left_pad = rebin(fltarr(24,127)*!values.f_nan,24,127,29) & help, left_pad
;top_pad = rebin(fltarr(117,12)*!values.f_nan,117,12,29) & help, top_pad
;;1981-2010
;eaVIC = [ [ left_pad, vic], [top_pad] ]
;PAD = fltarr(117,139)*!values.f_nan
;;VIC81 = [ [[PAD]],[[eaVIC]] ]
;VIC81 = eavic


 ;looks like i just did surface runoff. what does Qsub look like here...and i did do from 1981.
 ;data from Noah_CHIRPSvS5, what yrs are these?
 ;;;;;;;;;East Africa;;;;;;;
;ifile = file_search('/home/sandbox/people/mcnally/AQUEDUCT/Qs_yearsum_1981_2014.nc')
;fileID = ncdf_open(ifile, /nowrite) &$
;qsID = ncdf_varid(fileID,'Qs_tavg') &$
;ncdf_varget,fileID, qsID, Qsurf
;Qsurf(where(Qsurf lt 0)) = !values.f_nan
;
;ifile = file_search('/home/sandbox/people/mcnally/AQUEDUCT/Qsb_yearsum_1981_2014.nc')
;fileID = ncdf_open(ifile, /nowrite) &$
;qsbID = ncdf_varid(fileID,'Qsb_tavg') &$
;ncdf_varget,fileID, qsbID, Qsub
;Qsub(where(Qsub lt 0)) = !values.f_nan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ifile = file_search('/home/sandbox/people/mcnally/NOAH_CHIRPS_MERRA_WA/Qs_yearsum_1981_2014.nc')
fileID = ncdf_open(ifile, /nowrite) &$
  qsID = ncdf_varid(fileID,'Qs_tavg') &$
  ncdf_varget,fileID, qsID, Qsurf
Qsurf(where(Qsurf lt 0)) = !values.f_nan

ifile = file_search('/home/sandbox/people/mcnally/NOAH_CHIRPS_MERRA_WA/Qsb_yearsum_1981_2014.nc')
fileID = ncdf_open(ifile, /nowrite) &$
  qsbID = ncdf_varid(fileID,'Qsb_tavg') &$
  ncdf_varget,fileID, qsbID, Qsub
Qsub(where(Qsub lt 0)) = !values.f_nan


;read in the longrain/short rain mask:
;ifile = file_search('/home/sandbox/people/mcnally/lis_input_wrsi.ea_oct2feb.nc') & print, ifile
ifile = file_search('/home/sandbox/people/mcnally/lis_input_wrsi.wa.mode.nc') & print, ifile
fileID = ncdf_open(ifile, /nowrite) &$
maskID = ncdf_varid(fileID,'WRSIMASK')
ncdf_varget,fileID, maskID, shortmask
shortmask(where(shortmask eq 0)) = !values.f_nan
RO = Qsurf+Qsub

;0.25 degree for VIC
;qsurf25 = congrid(qsurf,117,139,34)
;qsub25 = congrid(qsub,117,139,34)
;RO25 = congrid(RO,117,139,34)

;average over select regions
;mask for the highwithdrawl regions? Correlation is good R=0.8
;Kenya, Ethipia and Yemen plots would be better
;mask=rebinafr
;mask(where(mask gt 1000000000, complement=other))=1
;mask(other)=!values.f_nan
;mask29=rebin(mask,117,139,29)
;p1=image(mask, max_value=1, min_value=0)

;East Africa WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

;Nile Basin Runoff
bot = (10-map_lry)/0.25 & top = (18-map_lry)/0.25 & print, bot, top
left = (32.5-map_ulx)/0.25 & right = (37-map_ulx)/0.25 & print, left, right

;Southern Kenya Runoff
left = (37.5-map_ulx)/0.25 & right = (40-map_ulx)/0.25 & print, left, right
bot = (abs(map_lry)-4)/0.25 & top = (abs(map_lry)-1)/0.25 & print, bot, top

;any regions of interest in West Africa?
map_ulx = -18.65 & map_lrx = 25.85
map_uly = 17.65 & map_lry = 5.35

;Niger
bot = (10-map_lry)/0.1 & top = (15-map_lry)/0.1 & print, bot, top
left = (0-map_ulx)/0.1 & right = (10-map_ulx)/0.1 & print, left, right

;Senegal
bot = (14-map_lry)/0.1 & top = (15-map_lry)/0.1 & print, bot, top
left = (-15-map_ulx)/0.1 & right = (-10-map_ulx)/0.1 & print, left, right

;Mali
bot = (12-map_lry)/0.1 & top = (15-map_lry)/0.1 & print, bot, top
left = (-6-map_ulx)/0.1 & right = (-2-map_ulx)/0.1 & print, left, right


check = rebinafr
check[left:right, bot:top]=5
p1=image(check, min_value=0, max_value=10)
p2=image(rebinafr,/overplot, rgb_table=4, transparency=60)

;shortmask25 = rebin(congrid(shortmask,117,139),117,139,nyrs)
;Look at the mean across the whole domain, and the shortmask
VTS = mean(mean(Qsurf[left:right,bot:top,*],dimension=1,/nan),dimension=1,/nan)
NTS = mean(mean(Qsub[left:right,bot:top,*],dimension=1,/nan),dimension=1,/nan)
ATS = mean(mean(RO[left:right,bot:top,*],dimension=1,/nan),dimension=1,/nan)
;BTS = mean(mean(vic81[left:right,bot:top,*],dimension=1,/nan),dimension=1,/nan)

;p1=plot(vts/2, thick=2, /overplot)
w = WINDOW(WINDOW_TITLE=string('runoff'),DIMENSIONS=[1500,500])
;p2 = plot(nts/4, 'b', /current)
p4 = plot(ats, /current,'b', thick=2)
;p4 = plot(nts, /overplot,'g', thick=2)
p4.xrange=[0,34] &$
  ;p2.xmajor= 1&$
p4.xtickname=string(indgen(18,increment=2)+1981)
p4.xminor = 1 & p4.yminor = 0
p4.ytitle = 'runoff (kg/m2)'
p4.title='LIS7-Noah33 Runoff, Niger (10N-15N, 0E-10E)'
p4.save,strcompress('/home/sandbox/people/mcnally/Niger_Runoff.jpg', /remove_all),RESOLUTION=200 &$

print, r_correlate(bts,ats)

;;;;;;;;;;baseline water stress;;;;;;;;;;;;;
;what happened here?
;how to convert cubic meters/yr into mm/mo
;wcube = rebin(congrid(afr,294,348),294,348,34) & help, wcube
;wcube = rebin(congrid(afr,117,139),117,139,nyrs) & help, wcube
wcube = rebin(congrid(afr,446,124),446,124,34) & help, wcube

help, wcube, ro
wcube_scale = wcube/10000
ro_scale = ro*(86400*365)
BLWS = Wcube_scale/RO_scale & nve, blws

;ofile = '/home/sandbox/people/mcnally/waterstress_2000_2013.img
;openw,1,ofile
;writeu,1,a[*,*,0:13]
;close,1

nx = 446
ny = 124
ncolors = 20
yr = indgen(34)+1981
y=2012
;yr = [2001,2002]
w = WINDOW(DIMENSIONS=[600,900])
;good to multiply by: *100000000
for y = 20, n_elements(yr)-1 do begin &$
  ncolors=3  &$
  ;p1 = image(mean(blws, dimension=3, /nan)*shortmask, RGB_TABLE=65,layout=[1,3,1],/CURRENT, $
  p1 = image(blws[*,*,2012-1981]*shortmask, RGB_TABLE=65,layout=[1,3,3],/CURRENT, $
  FONT_SIZE=14, AXIS_STYLE=0,MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], $
  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry]) &$
  p1.min_value=-0.5 &$
  p1.max_value=100 &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [200,200,200] &$
  p1.rgb_table = rgbdump &$
  p1.title = 'Water Stress 2012' &$ ;+string(yr[y])
  ;p1.title = 'Baseline Water Stress (1981-2014)' &$ ;+string(yr[y])
  p1.mapgrid.linestyle = 6 &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.FONT_SIZE = 0 &$
  m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.], thick=2) &$
  cb = colorbar(target=p1,ORIENTATION=0,FONT_SIZE=0) &$
  ;p1.save,strcompress('/home/sandbox/people/mcnally/waterstress.jpg', /remove_all),RESOLUTION=200 &$
endfor

BLWS = mean(a[*,*,0:13], dimension=3, /nan)
ncolors = 256
;same thing for the anomaly but and the cmap color scheme
for i = 0, n_elements(yr)-2 do begin &$
  tmpgr = image((a[*,*,i]-BLWS)/10000000,  RGB_TABLE=reverse(CONGRID(make_cmap(ncolors),3,256),2), max_value=0.2,min_value=-0.2,$
  ;tmpgr = image(mean(a, dimension=3, /nan), RGB_TABLE=65, MIN_VALUE=0.,layout=[3,5,i+1], /CURRENT,$
  TITLE=yr[i],FONT_SIZE=14, $
  AXIS_STYLE=0,MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], $
  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry]) &$
  tmpgr.mapgrid.linestyle = 6 &$
  tmpgr.mapgrid.label_position = 0 &$
  tmpgr.mapgrid.FONT_SIZE = 0 &$
  m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.], thick=2) &$
  cb = colorbar(target=tmpgr,ORIENTATION=1,FONT_SIZE=12) &$
  tmpgr.save,strcompress('/home/sandbox/people/mcnally/BLWSa_'+tmpgr.title.string+'.jpg', /remove_all),RESOLUTION=200 &$
endfor

;seasonal variability : stddev/mean monthly avg supply (RO)
data_dir='/home/sandbox/people/mcnally/NOAH_CHIRP_MERRA/'

nx = 294
ny = 348

QsubMO = fltarr(nx,ny,12)
Q = fltarr(294,348,12,34)*!values.f_nan
for m = 1,12 do begin &$
  ifile =  file_search(data_dir+STRING(FORMAT='(''/Qsub_YRMO/Qsb_Noah????_'',I2.2,''.nc'')',m)) &$
  for i = 0,n_elements(ifile)-1 do begin &$
  fileID = ncdf_open(ifile[i]) &$
  qsbID = ncdf_varid(fileID,'Qsb_tavg') &$
  ncdf_varget,fileID, qsID, Qsub &$
  Q[*,*,m-1,i] =  Qsub &$
endfor &$
QsubMO[*,*,m-1] = mean(Q[*,*,m-1,*], dimension=4, /nan) &$
endfor
QsubMO(where(QsubMO lt 0)) = !values.f_nan
;seasonal variability...not sure how useful this one is. except maybe as a tutorial
svar = stddev(QsubMO,dimension=3,/nan)
svag = mean(QsubMO,dimension=3,/nan)


;;;;;;;;drought severity with monthly SM percentiles (maybe try with ECV as well?);;;;;;;;;;;;;
; do i have these runs for the other africa masks? i can do the belg mask

data_dir='/home/sandbox/people/mcnally/NOAH_CHIRP_MERRA/'

;I should probably make sure that the yrs exist. e.g Jan1981?
nx = 294
ny = 348
;SM01_Noah2014_03.nc
smMO = fltarr(nx,ny,12)
SM = fltarr(294,348,12,34)*!values.f_nan
for m = 1,12 do begin &$
  ifile =  file_search(data_dir+STRING(FORMAT='(''/SM01_YRMO/SM01_Noah????_'',I2.2,''.nc'')',m)) &$
  for i = 0,n_elements(ifile)-1 do begin &$
  fileID = ncdf_open(ifile[i]) &$
  smID = ncdf_varid(fileID,'SoilMoist_tavg') &$
  ncdf_varget,fileID, smID, SM01 &$
  SM[*,*,m-1,i] =  SM01 &$
endfor &$
smMO[*,*,m-1] = mean(SM[*,*,m-1,*], dimension=4, /nan) &$
endfor
;;;;;;;calculate the soil moisture percentile
;this needs to be done for each month...
;1. MAM in 2011
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
per67 = fltarr(nx, ny, 12)
per33 = fltarr(nx, ny, 12)
permap = fltarr(nx, ny, 12, 4)
for m = 0,11 do begin &$
  for x = 0, nx-1 do begin &$
    for y = 0, ny-1 do begin &$
  ;skip nans
  test = where(finite(SM[x,y,m,*]),count) &$
  if count eq -1 then continue &$
  ;look at one pixel time series at a time
  pix = SM[x,y,m,*] &$
  ;then find the index of the Xth percentile, how would i fit a distribution?
  permap[x,y,m,*] = cgPercentiles(pix , PERCENTILES=[0.05,0.1,0.2,0.3]) &$
endfor  &$;x
endfor;

;map the percentile classes
;from US drought monitor (0-2 = exceptional; 3-5 = extreme [5]); 6-10=severe [4]; 11-20=moderate [3]; 21-30 = abnormal dry [2]; >30 not drought [1]
pc = sm*!values.f_nan
sm(where(sm lt -999.))=!values.f_nan

for m = 0,12-1 do begin &$
  for x = 0, nx-1 do begin &$
    for y = 0, ny-1 do begin &$
    ;skip nans
    test = where(finite(SM[x,y,m,*]),count) &$
    if count eq 0 then continue &$
    ;map the percentile bins for each year using the permap values
    ;go over each map 294x348x12x34 and replace values with bin, this can be a where statement....
    smvector = sm[x,y,m,*] &$
    smvector2=smvector*!values.f_nan &$
    ;change the values of the vector, how to do this...
    smvector2(where(smvector le permap[x,y,m,0])) = 5 &$
    smvector2(where(smvector gt permap[x,y,m,0] AND smvector le permap[x,y,m,1])) = 4 &$
    smvector2(where(smvector gt permap[x,y,m,1] AND smvector le permap[x,y,m,2])) = 3 &$
    smvector2(where(smvector gt permap[x,y,m,2] AND smvector le permap[x,y,m,3])) = 2 &$
    smvector2(where(smvector gt permap[x,y,m,3])) = 1 &$
    ;then put them back into the map
    pc[x,y,m,*] = smvector2 &$   
    endfor &$
  endfor &$
endfor



;read in the longrain/short rain mask:
ifile = file_search('/home/sandbox/people/mcnally/lis_input_wrsi.ea_oct2feb.nc') & print, ifile
fileID = ncdf_open(ifile, /nowrite) &$
  maskID = ncdf_varid(fileID,'WRSIMASK')
ncdf_varget,fileID, maskID, shortmask

;;;;;;Ethiopia-Yemen window;;;;;;;;
;ymap_ulx = 30.05  & ymap_lrx = 49.95
;ymap_uly = 20.15  & ymap_lry = 5.15

;Yemen window
ymap_ulx = 42. & ymap_lrx = 48.
ymap_uly = 18. & ymap_lry = 12.

mo = ['jan', 'feb', 'mar', 'apr', 'may', 'jun','jul','aug','sep','oct','nov','dec']
ncolors = 5

startyr=1981
for YOI = 1981,2014 do begin &$
w = WINDOW(WINDOW_TITLE=string(YOI),DIMENSIONS=[700,700]) &$
for i = 0,12-1 do begin &$
  p1 = image(pc[*,*,i,YOI-startyr], layout=[4,3,i+1],RGB_TABLE=65,FONT_SIZE=14, $
  AXIS_STYLE=0,MAP_PROJECTION='Geographic',LIMIT=[ymap_lry,ymap_ulx,ymap_uly,ymap_lrx], $
  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry],/current )  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [200,200,200] &$
  p1.rgb_table = rgbdump &$
  p1.title = 'SM percentile'+string(mo[i]) &$
  p1.mapgrid.linestyle = 6 &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.FONT_SIZE = 0 &$
  p1.min_value=0 &$
  p1.max_value=5 &$
 ; m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.]) &$
  m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.]) &$

endfor  &$
cb = colorbar(target=p1,ORIENTATION=0,FONT_SIZE=12) &$
endfor

;;;;;;;;plot time series for the different masks (like Bala did). Can also do the livelihood zones. 
;these GIS tasks are good for ENVI...
;read in the livelihood raster for kenya
ifile = file_search('/home/sandbox/people/mcnally/AQUEDUCT/Kenya_livlihood_raster')
ingrid = bytarr(nx,ny)
openr,1,ifile
readu,1,ingrid
close,1
ingrid = reverse(ingrid,2)
;names = ['central_higlands','Marsabit_Marginal_Mixed_Farming',NW_Agropastoral', 'Southeastern Marginal Mixed Farming Zone &
;          'tinny5, Western High Potential Zone]
names = ['unclass', 'CentralHighlandsHigh',  'MarsabitMarginalMixed', 'NorthwesternAgropastoralZone',  'SoutheasternMarginalMixed',  $
          'TurkwellRiverineZone', 'WesternHighPotential','TanaRiverineZone'    ,  'SoutheasternMediumPotential',$
           'NorthernPastoralZone' , 'WesternMediumPotential', 'WesternLakeshoreMarginal',$
         'SouthernPastoralZone',  'NortheasternPastoralZone' , 'ManderaRiverineZone' ,'GrasslandsPastoralZone' , 'NortheasternAgropastoralZone',$
         'LakeTurkanaFishing',  'LakeVictoriaFishing', 'WesternAgropastoralZone', 'CoastalMediumPotential',$
         'CoastalMarginalAgricultural', 'SoutheasternPastoralZone', 'NorthwesternPastoralZone', 'SouthernAgropastoralZone']

;rather than pc (cube)
pcvect = reform(pc,nx,ny,12*34)

for r = 0, n_elements(names)-1 do begin

  ROI = r+1 &$
  LZ = ingrid &$
  LZ(where(ingrid eq ROI, complement=no))=1 &$
  LZ(no)=0 &$
  LZ = rebin(LZ, nx, ny, 12*34) &$
  w = WINDOW(WINDOW_TITLE=string('LZ_droughtTS'),DIMENSIONS=[1700,500]) &$

  ;w = WINDOW(WINDOW_TITLE=string('LZ_droughtTS'),DIMENSIONS=[1700,500]) &$
  ;ROI = where(ingrid[*,*,0] eq 0, complement=no)
  TS = mean(mean(pcvect*LZ, dimension=1, /nan),dimension=1,/nan) &$
  TS_sm = ts_smooth(TS,6) & help, ts_sm &$
  p1=plot(TS, /current) &$
  p2 = plot(TS_sm, /overplot, thick=2) &$
  p1.xrange=[1,408] &$
  p1.xmajor=34 &$
  p1.xtickname=string(indgen(34)+1981) &$
  p1.title = string(names[r]) &$
endfor 

;drought severity is number of months below 20th percentile (class ge 2 = 4,3,2).
;Percentiles=[0.05,0.1,0.2,0.3]....reform to a 12*34 vector then if x and x-1 are ge 2 then count else sum and reset to 0
;calculate length of drought
;to get the severity multiply length x average percentile (or class) 
drought = intarr(nx,ny,12*34)
severity = fltarr(nx,ny,12*34)
for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
  ts = pcvect[x,y,*] &$
  for z = 1, n_elements(ts)-1 do begin &$
    if ts[z] gt 2 AND ts[z-1] gt 2 then cnt++ else cnt = 0 &$
    severity[x,y,z] = cnt*ts[z] &$
    drought[x,y,z] = cnt &$
  endfor &$
 endfor &$
endfor   
years = ['81','84','87','90','93','96','99','02','05','08','11','14']
  cnt=0
  ;w = WINDOW(WINDOW_TITLE=string('LZ_droughtTS'),DIMENSIONS=[1000,600]) &$
  w = WINDOW(WINDOW_TITLE=string('LZ_droughtTS'),DIMENSIONS=[700,900]) &$

for r = 1, n_elements(names)-1 do begin &$
  ;R = 4,13,16,22
 ; for r = 1, 3 do begin &$
  ROI = 22 &$
  LZ = ingrid &$
  LZ(where(ingrid eq ROI, complement=no))=1 &$
  LZ(no)=0 &$
  LZ = rebin(LZ, nx, ny, 12*34) &$

;ROI = where(ingrid[*,*,0] eq 0, complement=no)
  TS = mean(mean(severity*LZ, dimension=1, /nan),dimension=1,/nan) &$
  ;TS_sm = ts_smooth(TS,6) & help, ts_sm
  ;p1=barplot(TS*100, layout=[3,8,r], /current) &$
  p1=barplot(TS*100, layout=[1,4,4], /current, FONT_SIZE=12) &$

 ;p2 = plot(TS_sm, /overplot, thick=2)
  p1.xrange=[0,395] &$
  p1.xmajor=12 &$
  p1.xtickname=string(years) &$
  p1.title = string(names[roi]) &$
endfor 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;look at the yemen livlihood zones
YE01 = 'Amran rainfed'

;ofile = '/home/sandbox/people/mcnally/EA_SM_droughtlength_294x348x408.bin'
;openw,1,ofile
;writeu,1,drought
;close,1

;**********how to i find a time series for a specific location?******
;East Africa WRSI/Noah window
kmap_ulx = 35.  & kmap_lrx = 41
kmap_uly = 0.  & kmap_lry = -3

;map_ulx = 22.  & map_lrx = 51.35
;map_uly = 22.95  & map_lry = -11.75

;uh, how does this work with the east africa subset
kulx = (kmap_ulx-22.)*10.  & klrx = (kmap_lrx-22.)*10.-1
kuly = (11.-kmap_uly)*10.   & klry = (11.-kmap_lry)*10.-1

;this sort of gets at what i want....
tmpplt=plot(mean(mean(a[kulx:klrx,kuly:klry,*], dimension=1,/nan),dimension=1,/nan), thick=3)
tmpplt.yTICKVALUES = [500000,1000000,1500000,200000,2500000]
tmpplt.yTICKNAME = ['Long Ago','Before','Mid-Century','Semi-Recent','Recent']
tmpplt.yTICKFONT_SIZE = 10
tmpplt.YTICKFONT_SIZE = 10





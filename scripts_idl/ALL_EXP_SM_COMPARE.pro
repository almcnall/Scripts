pro ALL_EXP_SM_COMPARE

;;pulling all the code where I compare different SM experiments. 
;; there might be some useful updates in ECV_evap_paper.pro

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  data_dirR = '/home/chg-mcnally/fromKnot/EXP01/monthly/' ;RFE_GDAS
  data_dirG = '/home/sandbox/people/mcnally/NOAH_CHIRP_GDAS/SM01_YRMO/'
  data_dir = '/home/sandbox/people/mcnally/NOAH_CHIRP_MERRA/SM01_YRMO/'
  data_dirE = '/home/sandbox/people/mcnally/';monthly ECV soil mositure 1982-2012

  SM = FLTARR(NX,NY,nmos,nyrs)
  SMG = FLTARR(NX,NY,nmos,nyrs)
  SM01R = fltarr(720,250)
  SMR = FLTARR(720,250,nmos,nyrs)

  ;ECV = FLTARR(285, 339,12, nyrs)
  ;this loop reads in the selected months only
  for yr=startyr,endyr do begin &$
    for i=0,nmos-1 do begin &$
    y = yr &$
    m = startmo + i &$
    if m gt 12 then begin &$
    m = m-12 &$
    y = y+1 &$
  endif &$
  ;ugh, shouldn't these be cumulative??! like the rainfall?
  fileID = ncdf_open(data_dir+STRING(FORMAT='(''SM01_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
  SoilID = ncdf_varid(fileID,'SoilMoist_tavg') &$
  ncdf_varget,fileID, SoilID, SM01 &$
  SM[*,*,i,yr-startyr] = SM01 &$
  ;generates the seasonal total for months of interest
  ;SM[*,*,yr-startyr] =  SM[*,*,yr-startyr] +SM01 &$

  fileID = ncdf_open(data_dirG+STRING(FORMAT='(''SM01_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
  SoilID = ncdf_varid(fileID,'SoilMoist_tavg') &$
  ncdf_varget,fileID, SoilID, SM01G &$
  SMG[*,*,i, yr-startyr] = SM01G  &$
  ;generates the seasonal total for months of interest it is a percent...
  ;SMG[*,*,yr-startyr] =  SMG[*,*,yr-startyr] +SM01G &$

  ifile = file_search(data_dirR+STRING(FORMAT='(''Sm01_'',I4.4,I2.2,''.img'')',y,m)) &$
  openr,1,ifile &$
  readu,1,SM01R &$
  close,1 &$
  SMR[*,*,i,yr-startyr] = SM01R/100 &$
  ;generates the seasonal total for months of interest it is a percent...
  ;SMR[*,*,yr-startyr] = SMR[*,*,yr-startyr] + SM01R/100 &$

endfor &$
endfor
sm(where(sm lt 0))   = !values.f_nan ;CHIRPS MERRA
smg(where(smg lt 0)) = !values.f_nan ;CHIRPS GDAS
smr(where(smr lt 0)) = !values.f_nan ;RFE GDAS

;ECV SOIL MOISUTURE
fileID = ncdf_open(data_dirE+'EA_LIS_1982-2012_ESACCI-SOILMOISTURE-L3S-SSMV-COMBINED.nc') &$
  ;now in /home/sandbox/people/mcnally/ECV_shrad/Monthly_East_Africa_1979-2013_ESACCI-SOILMOISTURE-L3S-SSMV-COMBINED.nc
  SoilID = ncdf_varid(fileID,'sm') &$
  ncdf_varget,fileID, SoilID, ECV
ECV(WHERE(ECV LT -9998)) = !VALUES.f_NAN
ECV = REVERSE(ECV,2)*0.0001
;ECV = CONGRID(reverse(ECV,2),294,348,372); for 0.1 deg analysis
ECVCUBE = REFORM(ecv,117,139,12,31); for 0.1 deg analysis
ECVCUBE = ECVCUBE[*,*,*,2001-1982:2011-1982]

;SHRAD's VIC SM at 0.25 degrees
;read in shrad's VIC data
sdir = '/home/sandbox/people/mcnally/VIC_SM/'
VIC = fltarr(93,127,12,31)*!values.f_nan
for m = 1,12 do begin &$
  ifile =  file_search(sdir+STRING(FORMAT='(''/SM1_VIC????_'',I2.2,''.nc'')',m)) &$
  for i = 0,n_elements(ifile)-1 do begin &$
  fileID = ncdf_open(ifile[i]) &$
  smID = ncdf_varid(fileID,'SM1') &$
  ncdf_varget,fileID, smID, sm2 &$
  VIC[*,*,m-1,i] =  sm2 &$
endfor &$
endfor
VIC(where(VIC gt 5000))=!values.f_nan
;pad out left side of the figure
left_pad = rebin(fltarr(24,127)*!values.f_nan,24,127,12,31) & help, left_pad
top_pad = rebin(fltarr(117,12)*!values.f_nan,117,12,12,31) & help, top_pad
;1981-2010
eaVIC = [ [ [left_pad], vic], [top_pad] ]
PAD = fltarr(117,139,12)*!values.f_nan
VICv = reform(eavic,117,139,12*31)
VIC81 = [ [[PAD]],[[VICv]] ]
;nan=1981, nan=2012,2011, 2001-2011 20-30
VICCUBE = REFORM(VIC81,117,139,12,32)
VICCUBE = VICCUBE[*,*,*,2001-1981:2011-1981]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;my old sahel window?
map_ulx = -20.  & map_lrx = 52.
map_uly = 20.  & map_lry = -5

;East Africa WRSI/Noah window
ea_ulx = 22.  & ea_lrx = 51.35
ea_uly = 22.95  & ea_lry = -11.75

;;;;;;;;;east africa window;;;;;;;;
ulx = (ea_ulx-map_ulx)*10.  & lrx = (ea_lrx-map_ulx)*10.
bot  = (abs(ea_lry-map_lry)*10)+1 & top = ((ea_uly-map_uly)*10)+1
bot_pad = rebin(fltarr(nx, bot)*!values.f_nan,nx,bot,12,nyrs)
top_pad = rebin(fltarr(nx, top)*!values.f_nan,nx,top,12,nyrs)

eaSMr0 = smr[ulx:lrx, *,*,*]
eaSMr= [ [[bot_pad],[eaSMr0]] , [top_pad]]& help, eaSMR

RFESM = CONGRID(REFORM(EASMR,NX, NY, 12*11),117,139,12*11)
RFECUBE = REFORM(RFESM,117,139,12,11)

;;RESHAPE THE CHIRPS-MERRA AND CHIRPS-GDAS CUBES
HELP, SM, SMG
CM = CONGRID(REFORM(SM,NX,NY,12*11),117,139,12*11)
CMCUBE = REFORM(CM,117,139,12,11)

CG = CONGRID(REFORM(SMG,NX,NY,12*11),117,139,12*11)
CGCUBE = REFORM(CG,117,139,12,11)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;check and see what I got FOR THE 2001-2011 COMPARISON
;rfe-gdas, chips-gdas, ecv, chirps-merra
HELP, VICCUBE, ECVCUBE, RFECUBE, CMCUBE, CGCUBE

NX = 117
NY = 139

;compute standardized anomalies.
;MICROWAVE
AVGMW = FLTARR(NX,NY,12)
STDMW = FLTARR(NX,NY,12)

FOR M = 0, 12 -1 DO AVGMW[*,*,M] = MEAN(ECVCUBE[*,*,M,*], DIMENSION=4, /NAN)
FOR M = 0, 12 -1 DO STDMW[*,*,M] = STDDEV(ECVCUBE[*,*,M,*], DIMENSION=4, /NAN)

;NOAH CHIRPS-MERRA
AVGCM = FLTARR(NX,NY,12)
STDCM = FLTARR(NX,NY,12)

FOR M = 0, 12 -1 DO AVGCM[*,*,M] = MEAN(CMCUBE[*,*,M,*], DIMENSION=4, /NAN)
FOR M = 0, 12 -1 DO STDCM[*,*,M] = STDDEV(CMCUBE[*,*,M,*], DIMENSION=4, /NAN)

;VIC CHIRPS-SHEFIELD
AVGCS = FLTARR(NX,NY,12)
STDCS = FLTARR(NX,NY,12)

FOR M = 0, 12 -1 DO AVGCS[*,*,M] = MEAN(VICCUBE[*,*,M,0:9], DIMENSION=4, /NAN)
FOR M = 0, 12 -1 DO STDCS[*,*,M] = STDDEV(VICCUBE[*,*,M,0:9], DIMENSION=4, /NAN)

;NOAH GDAS-RFE
AVGRG = FLTARR(NX,NY,12)
STDRG = FLTARR(NX,NY,12)

FOR M = 0, 12 -1 DO AVGRG[*,*,M] = MEAN(RFECUBE[*,*,M,*], DIMENSION=4, /NAN)
FOR M = 0, 12 -1 DO STDRG[*,*,M] = STDDEV(RFECUBE[*,*,M,*], DIMENSION=4, /NAN)

;NOAH GDAS-CHIRPS
AVGCG = FLTARR(NX,NY,12)
STDCG = FLTARR(NX,NY,12)

FOR M = 0, 12 -1 DO AVGCG[*,*,M] = MEAN(CGCUBE[*,*,M,*], DIMENSION=4, /NAN)
FOR M = 0, 12 -1 DO STDCG[*,*,M] = STDDEV(CGCUBE[*,*,M,*], DIMENSION=4, /NAN)

;ARE THE BAD VALUES GOING TO CAUSE A PROBLEM?
ZMW = FLTARR(NX,NY,12,NYRS)*!VALUES.F_NAN
ZCM = FLTARR(NX,NY,12,NYRS)*!VALUES.F_NAN
ZCS = FLTARR(NX,NY,12,NYRS)*!VALUES.F_NAN
ZCG = FLTARR(NX,NY,12,NYRS)*!VALUES.F_NAN
ZRG = FLTARR(NX,NY,12,NYRS)*!VALUES.F_NAN

FOR Y = 0, NYRS-1 DO BEGIN &$
  FOR M = 0,12-1 DO BEGIN &$
  ZMW[*,*,M,Y] = (ECVCUBE[*,*,M,Y]-AVGMW[*,*,M])/STDMW[*,*,M] &$
  ZCM[*,*,M,Y] = (CMCUBE[*,*,M,Y]-AVGCM[*,*,M])/STDCM[*,*,M] &$
  ZCS[*,*,M,Y] = (VICCUBE[*,*,M,Y]-AVGCS[*,*,M])/STDCS[*,*,M] &$
  ZCG[*,*,M,Y] = (CGCUBE[*,*,M,Y]-AVGCG[*,*,M])/STDCG[*,*,M] &$
  ZRG[*,*,M,Y] = (RFECUBE[*,*,M,Y]-AVGRG[*,*,M])/STDRG[*,*,M] &$

ENDFOR &$
ENDFOR
;vectorize for plotting?
ZMWTS = REFORM(ZMW,NX,NY,12*NYRS)
ZCMTS = REFORM(ZCM,NX,NY,12*NYRS)
ZCSTS = REFORM(ZCS,NX,NY,12*NYRS)
ZCGTS = REFORM(ZCG,NX,NY,12*NYRS)
ZRGTS = REFORM(ZRG,NX,NY,12*NYRS)

;plot at spp locations
;broader ethiopia stations
emap_ulx = 42.5 & emap_lrx = 48.
emap_uly = 17.5 & emap_lry = 12.5

;;PIXELWISE MONTHLY CORRELATION
;cormap1 = fltarr(nx,ny,12,2)
;cormap2 = fltarr(nx,ny,12,2)
;cormap3 = fltarr(nx,ny,12,2)
;cormap3 = fltarr(nx,ny,12,2)
;cormap4 = fltarr(nx,ny,12,2)

;PIXELWISE Annual CORRELATION
cormap1 = fltarr(nx,ny,2)
cormap2 = fltarr(nx,ny,2)
cormap3 = fltarr(nx,ny,2)
cormap3 = fltarr(nx,ny,2)
cormap4 = fltarr(nx,ny,2)


for x = 0,NX-1 do begin &$
  for y =0, NY-1 do begin &$
  ; for m = 0, 11 do begin &$
  cormap1[x,y,*] = correlate(ZMWTS[x,y,*], ZCMTS[x,y,*]) &$
  cormap2[x,y,*] = correlate(ZCSTS[x,y,0:132-13], ZCMTS[x,y,0:132-13]) &$
  ;cormap3[x,y,*] = correlate(ZMWTS[x,y,0:132-13], ZCSTS[x,y,0:132-13]) &$
  ;cormap4[x,y,*] = correlate(ZMWTS[x,y,*], ZRGTS[x,y,*]) &$

  ;endfor &$
endfor &$
endfor

;;;;;;PLOT TEMPLATE;;;;;;

ncolors=5
w = window(DIMENSIONS=[700,900])
;for i = 0, 11 do begin &$
;p1 = image(congrid(vic[*,*,0,0], NX*3, NY*3), image_dimensions=[nx/10,ny/10], $
p1 = image(congrid(rebinafr, NX*3, NY*3), image_dimensions=[nx/4,ny/4], $
  image_location=[ea_ulx+0.25,ea_lry+0.5],RGB_TABLE=55, /current)  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.title = string(i+1) &$
  p1.MAX_VALUE=1000000000 &$
  p1.min_value=0 &$
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,font_size=0) &$
  ;m1 = MAP('Geographic',limit=[ea_lry+6,ea_ulx+5,ea_uly-15,ea_lrx], /overplot) &$
  m1 = MAP('Geographic',limit=[ea_lry,ea_ulx,ea_uly,ea_lrx], /overplot) &$
  ;m1 = MAP('Geographic',LIMIT = [hmap_lry,hmap_ulx,hmap_uly ,hmap_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  m1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0, 0, 0], THICK = 2) &$
  ;all of thse figures would benefit from the ag boundaries...
  ;endfor
  P1.TITLE='COR 1982-2010 Noah-MERRA AND ECV SM1 Z-SCORE '

;;;;more percentile stuff:
;the following scripts use the cgPercentile function:
;aqueduct.pro
;ds_wrsi.pro
;getEOS_percentiles_EastAfrica.pro
;;;;;;;;calculate the soil moisture percentile. Replace this code with the percentile function
;;1. MAM in 2011
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;per67 = fltarr(nx, ny)
;per33 = fltarr(nx, ny)
;for x = 0, nx-1 do begin &$
;  for y = 0, ny-1 do begin &$
;  ;skip nans
;  test = where(finite(SM[x,y,*]),count) &$
;  if count eq -1 then continue &$
;
;  ;look at one pixel time series at a time
;  pix = SM[x,y,*] &$
;  ;this sorts the historic timeseries from smallest to largest
;  index = sort(pix) &$
;  sorted = pix(index) &$
;
;  ;then find the index of the 67th percentile
;  index50 = (n_elements(sorted)-1)*0.50 &$
;  index67 = (n_elements(sorted)-1)*0.67 &$
;  index33 = (n_elements(sorted)-1)*0.33 &$
;  ;return the value
;  per67[x,y] = sorted(index67) &$
;  per33[x,y] = sorted(index33) &$
;endfor  &$;x
;endfor;y
;
;;;make percentile...this is a more simple version of what is below...
;;using SM the stack of 1981-2013 soil moisture.
;pc = fltarr(nx,ny,nyrs)
;;sm(where(sm lt -999.))=!values.f_nan
;
;;there is something not right about this....
;for x = 0, nx-1 do begin &$
;  for y = 0, ny-1 do begin &$
;  ;skip nans
;  test = where(finite(SM[x,y,*]),count) &$
;  if count eq 0 then continue &$
;  ;map the percentiles for each year
;  for i = 0, nyrs-1 do begin &$
;  if SM[x,y,i] lt per33[x,y] then PC[x,y,i] = 25 &$
;  if SM[x,y,i] lt per67[x,y] AND SM[x,y,i] gt per33[x,y] then PC[x,y,i] = 50 &$
;  if SM[x,y,i] gt per67[x,y] then PC[x,y,i] = 75 &$
;endfor &$
;endfor &$
;endfor
;
;;;;plot it...how do these compare to rainfall percentiles? and other combo of months? how does this compare to GDAS?
;;;; having a suite of different months would be more like what they do for the hazards call, and more like what bala does
;ncolors=3
;for yyyy = 1981,2013 do begin &$
;  yyyy = 1981
;yr = 33-(2013-yyyy)-1 &$
;  p1 = image(pc[*,*,yr], image_dimensions=[nx/10,ny/10],image_location=[map_ulx+0.25,map_lry+0.5], $
;  RGB_TABLE=72,MIN_VALUE=0,max_value=100)  &$
;  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
;  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
;  rgbdump[*,0] = [255,255,255] &$ ; set map values of zero to white, you can change the color
;  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
;  p1.title = string(yyyy)+' MAM SM Percentiles' &$
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;  POSITION=[0.3,0.04,0.7,0.07], font_size=24, tickvalues=[25,50,75]) &$
;  m1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot) &$
;  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
;  m1.mapgrid.color = [150, 150, 150] &$
;  m1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0, 0, 0], THICK = 2) &$
;  p1.save,strcompress('/home/sandbox/people/mcnally/jpg4gary_Aug14/'+p1.title.string+'.jpg', /remove_all),RESOLUTION=200 &$
endfor


;;;;;;;;;;;
;
;repeat info from ds_wrsi.pro
;
;;;read in LIS-Noah SM01 data
;data_dir='/home/sandbox/people/mcnally/NOAH_CHIRPS_MERRA_EA/'
;SMCUBE = fltarr(294,348,12,nyrs)*!values.f_nan
;for yr=startyr,endyr do begin &$
;  for m = 1,12 do begin &$
;  ifile =  file_search(data_dir+STRING(FORMAT='(''/SM01_YRMO/SM01_Noah'',I4.4,''_'',I2.2,''.nc'')',yr,m)) &$
;  fileID = ncdf_open(ifile) &$
;  smID = ncdf_varid(fileID,'SoilMoist_tavg') &$
;  ncdf_varget,fileID, smID, SM01 &$
;  SMCUBE[*,*,m-1,yr-startyr] =  SM01 &$
;  ;generates the seasonal total for months of interest
;  ;SM[*,*,yr-startyr] =  SM[*,*,yr-startyr] +SM01 &$
;endfor &$
;endfor
;NOAH_SM01 = congrid(reform(SMCUBE,294,348,12*nyrs),NX,NY,12*nyrs)
;NOAH_SM01(where(NOAH_SM01 lt 0))=!values.f_nan
;
;;;read in shrad's VIC data for Africa analysis 1982:2010
;sdir = '/home/sandbox/people/mcnally/VIC_SM/'
;VIC = fltarr(93,127,12,nyrs)*!values.f_nan
;;adjust start/end times for the 1982-2010 analysis
;for yr=startyr+1,endyr-3 do begin &$
;  for m = 1,12 do begin &$
;  ifile =  file_search(sdir+STRING(FORMAT='(''/SM1_VIC'',I4.4,''_'',I2.2,''.nc'')',yr,m)) &$
;  fileID = ncdf_open(ifile) &$
;  smID = ncdf_varid(fileID,'SM1') &$
;  ncdf_varget,fileID, smID, sm1 &$
;  VIC[*,*,m-1,yr-startyr] =  sm1 &$
;endfor &$
;endfor
;VIC(where(VIC gt 5000))=!values.f_nan
;
;;pad out left side of the figure
;left_pad = rebin(fltarr(24,127)*!values.f_nan,24,127,12,nyrs) & help, left_pad
;top_pad = rebin(fltarr(117,12)*!values.f_nan,117,12,12,nyrs) & help, top_pad
;;1981-2010
;eaVIC = [ [ [left_pad], vic], [top_pad] ]
;;PAD = fltarr(117,139,12)*!values.f_nan
;VIC81 = reform(eavic,117,139,12*nyrs)
;
;;;for SM percentiles later
;VIC81cube = reform(VIC81,117,139,12,33)
;
;;read in the ECV monthly data
;data_dirE = '/home/sandbox/people/mcnally/ECV_shrad/';monthly ECV soil mositure 1982-2012
;fileID = ncdf_open(data_dirE+'Monthly_East_Africa_1979-2013_ESACCI-SOILMOISTURE-L3S-SSMV-COMBINED.nc') &$
;  SoilID = ncdf_varid(fileID,'sm') &$
;  ncdf_varget,fileID, SoilID, ECV
;ECV(WHERE(ECV LT -9998)) = !VALUES.f_NAN
;ECV = CONGRID(reverse(ECV,2),NX,NY,n_elements(ECV[0,0,*]))
;
;;ECV scale_factor = 0.0001f
;ECV81 = ECV[*,*,((1981-1979)*12):419] *0.0001 ;start ECV at 1981 rather than 1979
;
;;CHECK SM25 IS 2 YRS/24 MONTHS LONGER
;NOAH81 = NOAH_SM01[*,*,0:395] ;make one yr shorter so ends in 2012 (also shortened ECV, Why/?)
;HELP, VIC81, NOAH81, ECV81
;
;;for t = 2009,2012 do begin &$
;;MAKE CUBES OF EVERYTHING
;ECVCUBE = REFORM(ECV81,NX,NY,12,nyrs) &$
;  SMCUBE = REFORM(NOAH81,NX,NY,12,nyrs) &$
;  VICCUBE = REFORM(VIC81,NX,NY,12,nyrs) &$
;
;  ;ECVcube = reform(ecv81, 294,348,12,32)
;  ;GET RID OF 1987-1991
;  ;ECVCUBE[*,*,*,1986-1981:1991-1981] = !VALUES.F_NAN
;  ;ECVCUBE[*,*,*,t-1981] = !VALUES.F_NAN &$
;
;  ;compute standardized anomalies.
;  ;MICROWAVE
;  AVGMW = FLTARR(NX,NY,12) &$
;  STDMW = FLTARR(NX,NY,12) &$
;  ;ECVCUBE[*,*,*,1986-1981:1988-1981]=!values.f_nan
;
;  FOR M = 0, 12 -1 DO AVGMW[*,*,M] = MEAN(ECVCUBE[*,*,M,*], DIMENSION=4, /NAN) &$
;  FOR M = 0, 12 -1 DO STDMW[*,*,M] = STDDEV(ECVCUBE[*,*,M,*], DIMENSION=4, /NAN) &$
;
;  ;NOAH CHIRPS-MERRA
;  AVGCM = FLTARR(NX,NY,12) &$
;  STDCM = FLTARR(NX,NY,12) &$
;
;  FOR M = 0, 12 -1 DO AVGCM[*,*,M] = MEAN(SMCUBE[*,*,M,0:31], DIMENSION=4, /NAN) &$
;  FOR M = 0, 12 -1 DO STDCM[*,*,M] = STDDEV(SMCUBE[*,*,M,0:31], DIMENSION=4, /NAN) &$
;
;  ;VIC CHIRPS-SHEFIELD
;  AVGCS = FLTARR(NX,NY,12) &$
;  STDCS = FLTARR(NX,NY,12) &$
;  ;
;  FOR M = 0, 12 -1 DO AVGCS[*,*,M] = MEAN(VICCUBE[*,*,M,*], DIMENSION=4, /NAN) &$
;  FOR M = 0, 12 -1 DO STDCS[*,*,M] = STDDEV(VICCUBE[*,*,M,*], DIMENSION=4, /NAN) &$
;
;  ;ARE THE BAD VALUES GOING TO CAUSE A PROBLEM?
;  ZMW = FLTARR(NX,NY,12,nyrs) &$
;  ZCM = FLTARR(NX,NY,12,nyrs) &$
;  ZCS = FLTARR(NX,NY,12,nyrs) &$
;
;
;  FOR Y = 0, NYRS-1 DO BEGIN &$
;  FOR M = 0,12-1 DO BEGIN &$
;  ZMW[*,*,M,Y] = (ECVCUBE[*,*,M,Y]-AVGMW[*,*,M])/STDMW[*,*,M] &$
;  ZCM[*,*,M,Y] = (SMCUBE[*,*,M,Y]-AVGCM[*,*,M])/STDCM[*,*,M] &$
;  ZCS[*,*,M,Y] = (VICCUBE[*,*,M,Y]-AVGCS[*,*,M])/STDCS[*,*,M] &$
;ENDFOR &$
;ENDFOR &$
;;vectorize for plotting?
;ZMWTS = REFORM(ZMW,NX,NY,12*nyrs) &$
;ZCMTS = REFORM(ZCM,NX,NY,12*nyrs) &$
;ZCSTS = REFORM(ZCS,NX,NY,12*nyrs) &$
;;
;;PIXELWISE CORRELATION
;
;cormap1 = fltarr(nx,ny,2)*!values.f_nan &$
;cormap2 = fltarr(nx,ny,2)*!values.f_nan &$
;cormap3 = fltarr(nx,ny,2)*!values.f_nan &$
;
;
;for x = 0,NX-1 do begin &$
;for y =0, NY-1 do begin &$
;test = where(finite(zcsts[x,y,*]),count) &$
;if count le 1 then continue &$
;cormap1[x,y,*] = r_correlate(zcmts[x,y,*],zcsts[x,y,*]) &$
;cormap2[x,y,*] = r_correlate(zmwts[x,y,*],zcmts[x,y,*]) &$
;cormap3[x,y,*] = r_correlate(zmwts[x,y,*],zcsts[x,y,*]) &$
;endfor &$
;endfor  &$
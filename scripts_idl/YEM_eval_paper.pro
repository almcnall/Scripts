;; THIS WORKSHEET IS DESIGNED TO DEVELOP DATA AND GRAPHICS for Yemen

;; borrow CHIRPS_NDVI_EAv2.pro for figures w/ ECV manuscript
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FIGURE 2. Rainfall totals & station density
;see map_CHG_Stations.pro

ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input_wrsi.ea_may2nov.nc') & print, ifile ;long mask
fileID = ncdf_open(ifile, /nowrite) &$

maskID = ncdf_varid(fileID,'LANDMASK')
ncdf_varget,fileID, maskID, land
land25 = congrid(land,117,139)
land25(where(land25 eq 0)) = !values.f_nan

startyr = 1982 ;start with 1982 to match NDVI, start with 1998 to match trmm
endyr = 2013
nyrs = endyr-startyr+1

;re-do for all months
startmo = 1
endmo = 12
nmos = endmo - startmo+1

;Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

ulx = (180.+map_ulx)*10.  & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10.   & lry = (50.-map_lry)*10.-1
NX = lrx - ulx + 1.5
NY = lry - uly + 2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
data_dir = '/home/sandbox/people/mcnally/NOAH_CHIRPSv2.0_MERRA_EA/'
data_dirE = '/home/sandbox/people/mcnally/ECV_shrad/';monthly ECV soil mositure 1982-2013 '
data_dirT = '/home/sandbox/people/mcnally/NOAH_TRMM_MERRA/SM_MOYR/' ;SM01_TNoah_1998_01.nc
data_dirT2 = '/home/sandbox/people/mcnally/NOAH_TRMM_GDAS/'

SM = FLTARR(NX,NY,nmos,nyrs)
SM2 = FLTARR(NX,NY,nmos,nyrs)
SMT = FLTARR(NX,NY,nmos,nyrs)
SMTG1 = FLTARR(NX,NY,nmos,nyrs)
SMTG2 = FLTARR(NX,NY,nmos,nyrs)


;this loop reads in the selected months only
for yr=startyr,endyr do begin &$
  for i=0,nmos-1 do begin &$
  y = yr &$
  m = startmo + i &$
  if m gt 12 then begin &$
    m = m-12 &$
    y = y+1 &$
  endif &$
  fileID = ncdf_open(data_dir+STRING(FORMAT='(''/SM01_YRMO/SM01_Noah_'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
  SoilID = ncdf_varid(fileID,'SoilMoist_tavg') &$
  ncdf_varget,fileID, SoilID, SM01 &$
  SM[*,*,i,yr-startyr] = SM01 &$
  
  fileID = ncdf_open(data_dir+STRING(FORMAT='(''/SM02_YRMO/SM02_Noah_'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
  SoilID = ncdf_varid(fileID,'SoilMoist_tavg') &$
  ncdf_varget,fileID, SoilID, SM02 &$
  SM2[*,*,i,yr-startyr] = SM02 &$
  
;  fileID = ncdf_open(data_dirT+STRING(FORMAT='(''SM01_TNoah_'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
;  SoilID = ncdf_varid(fileID,'SoilMoist_tavg') &$
;  ncdf_varget,fileID, SoilID, SM01 &$
;  SMT[*,*,i,yr-startyr] = SM01 &$
;  
;  fileID = ncdf_open(data_dirT2+'elev_correction/'+STRING(FORMAT='(''SM01_TRMM_'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$ ;SM01_TRMM_2014_10.nc
;  SoilID = ncdf_varid(fileID,'SoilMoist_tavg') &$
;  ncdf_varget,fileID, SoilID, SM01 &$
;  SMTG1[*,*,i,yr-startyr] = SM01 &$
;  
;  fileID = ncdf_open(data_dirT2+'no_elev_corr/'+STRING(FORMAT='(''SM01_Noah_'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$ ;SM01_TRMM_2014_10.nc
;  SoilID = ncdf_varid(fileID,'SoilMoist_tavg') &$
;  ncdf_varget,fileID, SoilID, SM01 &$
;  SMTG2[*,*,i,yr-startyr] = SM01 &$
  
  endfor &$
endfor
sm(where(sm lt 0))   = !values.f_nan ;CHIRPS MERRA
sm2(where(sm2 lt 0))   = !values.f_nan ;CHIRPS MERRA

;smt(where(smt lt 0))   = !values.f_nan ;TRMM MERRA
;smtg1(where(smt lt 0))   = !values.f_nan ;TRMM GDAS elev
;smtg2(where(smt lt 0))   = !values.f_nan ;TRMM GDAS no-elev
;
;TG1NOAH_SM25 = congrid(reform(SMTG1,294,348,12*nyrs),117,139,12*nyrs)
;TG1NOAHCUBE = reform(TG1NOAH_SM25,117,139,12,nyrs) 
;
;TG2NOAH_SM25 = congrid(reform(SMTG2,294,348,12*nyrs),117,139,12*nyrs)
;TG2NOAHCUBE = reform(TG2NOAH_SM25,117,139,12,nyrs)
;
;
;TNOAH_SM25 = congrid(reform(SMT,294,348,12*nyrs),117,139,12*nyrs)
;TNOAHCUBE = reform(TNOAH_SM25,117,139,12,nyrs)

NOAH_SM25 = congrid(reform(SM,294,348,12*nyrs),117,139,12*nyrs)
NOAHCUBE = reform(NOAH_SM25,117,139,12,nyrs)

NOAH2_SM25 = congrid(reform(SM2,294,348,12*nyrs),117,139,12*nyrs)
NOAHCUBE2 = reform(NOAH2_SM25,117,139,12,nyrs)

;ECV SOIL MOISUTURE
fileID = ncdf_open(data_dirE+'Monthly_East_Africa_1979-2013_ESACCI-SOILMOISTURE-L3S-SSMV-COMBINED.nc') &$
SoilID = ncdf_varid(fileID,'sm') &$
ncdf_varget,fileID, SoilID, ECV

FLAGID = ncdf_varid(fileID,'flag') &$
  ncdf_varget,fileID, FLAGID, FLAG
flag = reverse(flag,2)

ECV(WHERE(ECV LT -9998)) = !VALUES.f_NAN
ECV = REVERSE(ECV,2)*0.0001

ECVCUBE0 = REFORM(ecv[*,*,(startyr-1979)*12:419-(2013-endyr)*12],117,139,12,nyrs); for 0.1 deg analysis
flagCUBE = float(REFORM(flag[*,*,(startyr-1979)*12:419-(2013-endyr)*12],117,139,12,nyrs)); for 0.1 deg analysis

;what do the flag values mean?
;1no_flag
;2now_coverage_or_temperature_below_zero 
;3dense_vegetation 
;127 others_no_convergence_in_the_model_thus_no_valid_sm_estimates" ;
flagcube(where(flagcube gt 1, complement=ok))=!values.f_nan
flagcube(ok)=1
ECVCUBE = ECVCUBE0*flagcube

NX = 117
NY = 139

;;;;;;;grab ndvicube2 from GIMMS_NDVI_EA.pro;;;;;;;
;re-initialize start yr since GIMMS always starts in 1982
HELP, ECVCUBE, NOAHCUBE, NOAHCUBE2,  NDVICUBE2, TNOAHCUBE, TG1NOAHCUBE, TG2NOAHCUBE
;chop everything down to the yemen window
;Yemen Highland window
ymap_ulx = 43. & ymap_lrx = 45.
ymap_uly = 17. & ymap_lry = 12.5

left = (ymap_ulx-map_ulx)*4.  & right= (ymap_lrx-map_ulx)*4.-1
top= (ymap_uly-map_lry)*4.   & bot= (ymap_lry-map_lry)*4.-1

;yemen box 20.5 x 48
NX = right - left + 1
NY = top - bot + 1

Y_ndvicube = ndvicube2[left:right, bot:top,*,*] & delvar, ndvicube3
Y_ecvcube = ecvcube[left:right, bot:top,*,*]
Y_nohcube = noahcube[left:right, bot:top,*,*]
Y_nohcube2 = noahcube2[left:right, bot:top,*,*]

;Y_tnohcube = tnoahcube[left:right, bot:top,*,*]
;Y_tng1cube = tg1noahcube[left:right, bot:top,*,*]
;Y_tng2cube = tg2noahcube[left:right, bot:top,*,*]

startyr = 1982
endyr = 2013
nyrs = endyr-startyr+1 & print, nyrs
;standardize function:The result is an m-column, n-row array where all columns have a mean of zero and a variance of one
;time series over the whole domain
MY_ECV = mean(mean(Y_ecvcube,dimension=1,/nan),dimension=1,/nan) & help, my_ECV
MY_NOH = mean(mean(Y_NOHcube,dimension=1,/nan),dimension=1,/nan) & help, my_NOH
MY_NOH2 = mean(mean(Y_NOHcube2,dimension=1,/nan),dimension=1,/nan) & help, my_NOH2

;MY_TNH = mean(mean(Y_TNOHcube,dimension=1,/nan),dimension=1,/nan) & help, my_TNH
;MY_TG1 = mean(mean(Y_TNG1cube,dimension=1,/nan),dimension=1,/nan) & help, my_TG1
;MY_TG2 = mean(mean(Y_TNG2cube,dimension=1,/nan),dimension=1,/nan) & help, my_TG2

;;;;;from the max or avg cube GIMMS NDVI script;;;;;
temp = mean(mean(Y_ndvicube,dimension=1,/nan),dimension=1,/nan)
MY_NDV = temp[*,startyr-1982:endyr-1982] & help, my_NDV

;write out .csv for funk
header = ['jan', 'feb', 'mar', 'apr', 'may', 'jun','jul','aug','sep','oct','nov','dec']
ofile = '/home/sandbox/people/mcnally/YEMEN_NDVI/YEM1982_2013_Noah_SM2.csv.csv'
write_csv,  ofile, my_NOH2, header=header

;I want yrs (22/32) to be mean zero 
WET_ECV = MEAN(MY_ECV[5:8,*],DIMENSION=1,/NAN)
WET_NOH = MEAN(MY_NOH[5:8,*],DIMENSION=1,/NAN)
WET_TNH = MEAN(MY_TNH[5:8,*],DIMENSION=1,/NAN)
WET_NDV = MEAN(MY_NDV[5:8,*],DIMENSION=1,/NAN)
WET_TG1 = MEAN(MY_TG1[5:8,*],DIMENSION=1,/NAN)
WET_TG2 = MEAN(MY_TG2[5:8,*],DIMENSION=1,/NAN)

Z_ECV = standardize(reform(WET_ECV,1,nyrs))
Z_NOH = standardize(reform(WET_NOH,1,nyrs))
Z_NDV = standardize(reform(WET_NDV,1,nyrs))
Z_TNH = standardize(reform(WET_TNH,1,nyrs))
Z_TG1 = standardize(reform(WET_TG1,1,nyrs))
Z_TG2 = standardize(reform(WET_TG2,1,nyrs))



;read in Shrad's chirps to include here...ah, can't use these. other make other chirps.
;fileID = ncdf_open('/home/sandbox/people/mcnally/JAGdata4figs/CHIRPSv1.8/Sptially_mean_EA_CHIRPS_March_September_chirps.1982-2013.nc') &$
;rainID = ncdf_varid(fileID,'precip') &$
;ncdf_varget,fileID, rainID, P
;p82 = standardize(reform(P,1,32))
;p92 = standardize(reform(P[1992-1982:31],1,22))

;1982-2013 correlations and 1998-2013 correlations, 2001-2013
print, r_correlate(Z_ECV[0,*],Z_NOH[0,*]);0.37; 0.49, 0.27, 0.25(F=1);0.48 (1991);0.61 (JAS);0.57 (JJAS)

print, r_correlate(Z_NDV[0,*],Z_ECV[0,*]);0.62; 0.48, 0.59, 0.63(F=1);0.43 (1991);0.38 (JAS);0.43 (JJAS)
print, r_correlate(Z_NDV[0,*],Z_NOH[0,*]);0.42; 0.49, 0.60, 0.60(F=1);0.67 (1991);0.50 (JAS);0.52 (JJAS)

print, r_correlate(Z_TNH[0,*],Z_ECV[0,*]);0.34   X, 0.09, 0.14(F=1)  

print, r_correlate(Z_TNH[0,*],Z_NDV[0,*]);0.45   X, 0.51, 0.51(F=1)
print, r_correlate(Z_TNH[0,*],Z_TG1[0,*]);0.90  
print, r_correlate(Z_TNH[0,*],Z_TG2[0,*]);0.91  
print, r_correlate(Z_ECV[0,*],Z_TG1[0,*]);0.29
print, r_correlate(Z_ECV[0,*],Z_TG2[0,*]);0.31

print, r_correlate(Z_NDV[0,*],Z_TG2[0,*]);0.52
print, r_correlate(Z_TG1[0,*],Z_TG2[0,*]);0.999 at this scale elevation correction doesn't change correlation much

;print, r_correlate(P82[0,*],Z_VIC[0,*])

w = window(DIMENSIONS=[1500,600])
p1 = plot(Z_ECV[0,*], /current, thick=2,color='grey', name = 'CCI-SM', linestyle=2)
p2 = plot(Z_TNH[0,*], /overplot, thick=2,color='black', name = 'NOAH_TRMM')
p3 = plot(Z_NOH[0,*], /overplot,thick=2,color='blue', name = 'NOAH_CHIRPS')
p4 = plot(Z_NDV[0,*], /overplot,thick=2,color='green', name = 'NDVI')
p5 = plot(Z_TG1[0,*], /overplot, thick=2,color='black', linestyle=2, name = 'TRMM_GDAS_e')
p6 = plot(Z_TG2[0,*], /overplot, thick=2,color='c', linestyle=3, name = 'TRMM_GDAS')

p1.xrange = [0,nyrs-1]
p1.xtickinterval = 1
xticks = indgen(nyrs+1)+startyr & print, xticks
p1.xTICKNAME = string(xticks)
!null = legend(target=[p1,p2,p3,p4,p5,p6], position=[0.2,0.3], font_size=18)
p1.xminor=0
p1.yminor=0
p1.title = 'Yemen domain average soil moisture and NDVI zscores JJAS (2001-2013)'
p1.yrange=[-3,3]
p1.title.font_size=18

;nx = 117
;ny = 139
;didn't i redo this for 3 monthly values? where is that? seasmean?
ZMAP_MW = fltarr(NX,NY,12,NYRS)*!values.f_nan
ZMAP_CM = fltarr(NX,NY,12,NYRS)*!values.f_nan
ZMAP_VG = fltarr(NX,NY,12,NYRS)*!values.f_nan
;there might be too many missing values for this to work with the CCI_SM.
;my other method might work better since i can /NAN
for X = 0,NX-1 do begin &$
  for Y = 0,NY-1 do begin &$
  ZMAP_CM[x,y,*,*] = standardize(reform(Y_NOHCUBE[X,Y,*,*])) &$
  ZMAP_VG[x,y,*,*] = standardize(reform(Y_NDVICUBE[X,Y,*,startyr-1982:endyr-1982])) &$
  endfor &$
endfor

;;MICROWAVE has to be done 'by hand' since there are missing values.
AVGMW = FLTARR(NX,NY,12)*!values.f_nan
STDMW = FLTARR(NX,NY,12)*!values.f_nan

FOR M = 0, 12 -1 DO AVGMW[*,*,M] = MEAN(Y_ECVCUBE[*,*,M,*], DIMENSION=4, /NAN)
FOR M = 0, 12 -1 DO STDMW[*,*,M] = STDDEV(Y_ECVCUBE[*,*,M,*], DIMENSION=4, /NAN)

ZMAP_MW = fltarr(NX,NY,12,NYRS)*!values.f_nan
;Standardize for each month
FOR Y = 0, NYRS-1 DO BEGIN &$
  FOR M = 0,12-1 DO BEGIN &$
  ZMAP_MW[*,*,M,Y] = (Y_ECVCUBE[*,*,M,Y]-AVGMW[*,*,M])/STDMW[*,*,M] &$
ENDFOR &$
ENDFOR

ZMW = reform(zmap_mw,NX,NY,nyrs*12)
ZCM = reform(zmap_cm,NX,NY,nyrs*12)
ZVG = reform(zmap_vg,NX,NY,nyrs*12)


;PIXELWISE CORRELATION for full time series
cormap1 = fltarr(nx,ny,2)*!values.f_nan
cormap2 = fltarr(nx,ny,2)*!values.f_nan
cormap3 = fltarr(nx,ny,2)*!values.f_nan
cormap4 = fltarr(nx,ny,2)*!values.f_nan
cormap5 = fltarr(nx,ny,2)*!values.f_nan
cormap6 = fltarr(nx,ny,2)*!values.f_nan

for x = 0,NX-1 do begin &$
  for y =0, NY-1 do begin &$
  cormap1[x,y,*] = r_correlate(ZMW[x,y,*], ZCM[x,y,*]) &$
  cormap3[x,y,*] = r_correlate(ZMW[x,y,*], ZVG[x,y,*]) &$  
  cormap4[x,y,*] = r_correlate(ZVG[x,y,*], ZCM[x,y,*]) &$
  
endfor &$
endfor

sig1 = cormap1[*,*,1]
sig1(where(sig1 lt 0.05, complement=other)) = 1
sig1(other)=!values.f_nan

sig3 = cormap3[*,*,1]
sig3(where(sig3 lt 0.05, complement=other)) = 1
sig3(other)=!values.f_nan

sig4 = cormap4[*,*,1]
sig4(where(sig4 lt 0.05, complement=other)) = 1
sig4(other)=!values.f_nan

;make an matrix with the corr and sig values for faster mapping:
c = fltarr(NX, NY, 2, 3)
c[*,*,*,0] = [ [[cormap1[*,*,0]]], [[sig1]]  ]
c[*,*,*,1] = [ [[cormap3[*,*,0]]], [[sig3]]  ]
c[*,*,*,2] = [ [[cormap4[*,*,0]]], [[sig4]]  ]

ymap_ulx = 43. & ymap_lrx = 45.
ymap_uly = 17. & ymap_lry = 12.5
;East Africa WRSI/Noah window
ea_ulx = 22.  & ea_lrx = 51.35
ea_uly = 22.95  & ea_lry = -11.75

ncolors=4 ;10 for VIC v NOAH there is a funny hash pattern in VIC v Noah, maybe becasue of re-gridding

w = window(DIMENSIONS=[1400,900])
i=2
;for i=0,4 do begin &$
p1 = image(congrid(c[*,*,0,i], NX*3, NY*3), image_dimensions=[nx/4,ny/4], $
  image_location=[ymap_ulx,ymap_lry],RGB_TABLE=55, /current, layout = [3,1,i+1])  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,255] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  rgbdump[*,0] = [190,190,190] &$
  ;rgbdump[*,255] = [190,190,190]
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  ;p1.title = string(i+1) &$
  p1.MAX_VALUE=0.8 &$
  p1.min_value=0 &$
  cb = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,font_size=24) &$
  m1 = MAP('Geographic',limit=[ymap_lry,ymap_ulx,ymap_uly,ymap_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2)
;endfor
  P1.TITLE='NDVI v NOAH'
  
;;;;;;;;PANELS for model, RS, NDVI comparions;;;;;;;;;
;;;;;;;;open the NDVI data from GIMMS_NDVI_EA and reshape it;;;;;;;

help, sZVG, sZMW, sZCM;, sZCS

sZVGcube = reform(sZVG,NX,NY,4,nyrs)
sZMWcube = reform(sZMW,NX,NY,4,nyrs)
sZCMcube = reform(sZCM,NX,NY,4,nyrs)
;for y = 0, nyrs -1 do begin &$
  
;  props = {current:1, image_dimensions:[nx/4,ny/4], image_location:[ea_ulx+0.25,ea_lry+0.5], $
;  min_value:-2.5, max_value:2.5, rgb_table:70}
  
  props = {current:1, image_dimensions:[nx/4,ny/4], image_location:[ymap_ulx,ymap_lry], $
    min_value:-2.5, max_value:2.5, rgb_table:70}

YOI = 2000
y= YOI - 1982 &$
w = window(DIMENSIONS=[1000,700], window_title = string(1982+y)) &$
  temp = image(congrid(sZMWcube[*,*,1,y],NX*3,NY*3),  layout = [3,1,1],  _EXTRA=props); title = 'AMJ'+string(1992+y)
  rgbdump = temp.rgb_table & rgbdump[*,0] = [190,190,190] &$
  temp.rgb_table=rgbdump &$
  m1 = MAP('Geographic',limit=[ymap_lry,ymap_ulx,ymap_uly,ymap_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black') &$
  temp.title= 'CCI-SM AMJ'
 
  temp = image(congrid(sZMWcube[*,*,2,y],NX*3,NY*3),  layout = [3,1,2],  _EXTRA=props);title = 'JAS'+string(1992+y),
  rgbdump = temp.rgb_table & rgbdump[*,0] = [190,190,190] &$
  temp.rgb_table=rgbdump &$
  m1 = MAP('Geographic',limit=[ymap_lry,ymap_ulx,ymap_uly,ymap_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black')
  temp.title= 'CCI-SM JAS'

;  ofile2 = odir+'Zscore_EastAfrica_JAS_ECV_2009.tif'
;  write_tiff, ofile2, sZMWcube[*,*,2,y], /FLOAT

  temp = image(congrid(sZMWcube[*,*,3,y],NX*3,NY*3),  layout = [3,1,3],   _EXTRA=props);title = 'OND'+string(1992+y),
  rgbdump = temp.rgb_table & rgbdump[*,0] = [190,190,190] &$
  temp.rgb_table=rgbdump &$
  m1 = MAP('Geographic',limit=[ymap_lry,ymap_ulx,ymap_uly,ymap_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  
  m1.mapgrid.font_size=0 &$
  m1.mapgrid.color = [150, 150, 150] &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black')
  temp.title= 'CCI-SM OND'

  
;  ofile3 = odir+'Zscore_EastAfrica_OND_ECV_2009.tif'
;  write_tiff, ofile3, sZMWcube[*,*,3,y], /FLOAT

;;;;;;;;;;;NOAH;;;;;;;;;;
w = window(DIMENSIONS=[1000,700], window_title = string(1982+y)) &$

  temp = image(congrid(sZCMcube[*,*,1,y],NX*3,NY*3),  layout = [3,1,1],  _EXTRA=props);title = 'AMJ'+string(1992+y),
  rgbdump = temp.rgb_table & rgbdump[*,0] = [190,190,190] & temp.rgb_table=rgbdump &$
  m1 = MAP('Geographic',limit=[ymap_lry,ymap_ulx,ymap_uly,ymap_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black')
  temp.title= 'NOAH AMJ'

;  ofile1 = odir+'Zscore_EastAfrica_AMJ_NOAH_2009.tif'
;  write_tiff, ofile1, sZCMcube[*,*,1,y],/FLOAT
  
  temp = image(congrid(sZCMcube[*,*,2,y],NX*3,NY*3),  layout = [3,1,2],   _EXTRA=props);title = 'JAS'+string(1992+y),
  rgbdump = temp.rgb_table & rgbdump[*,0] = [190,190,190] &$
  temp.rgb_table=rgbdump &$
  m1 = MAP('Geographic',limit=[ymap_lry,ymap_ulx,ymap_uly,ymap_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black')
  temp.title= 'NOAH JAS'

;  ofile2 = odir+'Zscore_EastAfrica_JAS_NOAH_2009.tif'
;  write_tiff, ofile2, sZCMcube[*,*,2,y], /FLOAT

  temp = image(congrid(sZCMcube[*,*,3,y],NX*3,NY*3),  layout = [3,1,3],   _EXTRA=props);title = 'OND'+string(1992+y),
  rgbdump = temp.rgb_table & rgbdump[*,0] = [190,190,190] &$
  temp.rgb_table=rgbdump &$
  m1 = MAP('Geographic',limit=[ymap_lry,ymap_ulx,ymap_uly,ymap_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black')
  temp.title= 'NOAH OND'

;  ofile3 = odir+'Zscore_EastAfrica_OND_NOAH_2009.tif'
;  write_tiff, ofile3, sZCMcube[*,*,3,y], /FLOAT

w = window(DIMENSIONS=[1000,700], window_title = string(1982+y)) &$
  i = (YOI-1982)   &$   ; skip the first n-years of the timeseries when calculating the trend

  temp = image(congrid(sZVGcube[*,*,1,y],NX*3,NY*3),  layout = [3,1,1],   _EXTRA=props);title = 'AMJ'+string(1992+y),
  rgbdump = temp.rgb_table & rgbdump[*,0] = [190,190,190]&$
  temp.rgb_table=rgbdump &$
  m1 = MAP('Geographic',limit=[ymap_lry,ymap_ulx,ymap_uly,ymap_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black')
  temp.title= 'NDVI AMJ'

;  ofile1 = odir+'Zscore_EastAfrica_AMJ_NDVI_2009.tif'
;  write_tiff, ofile1, sZVGcube[*,*,1,y],/FLOAT

  temp = image(congrid(sZVGcube[*,*,2,y],NX*3,NY*3),  layout = [3,1,2],   _EXTRA=props);title = 'JAS'+string(1992+y),
  rgbdump = temp.rgb_table & rgbdump[*,0] = [190,190,190]
  temp.rgb_table=rgbdump
  m1 = MAP('Geographic',limit=[ymap_lry,ymap_ulx,ymap_uly,ymap_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$ 
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black') &$ 
  c = COLORBAR(target=temp,ORIENTATION=0,/BORDER_ON,font_size=12)
  temp.title= 'NDVI JAS'

;  ofile2 = odir+'Zscore_EastAfrica_JAS_NDVI_2009.tif'
;  write_tiff, ofile2, sZVGcube[*,*,2,y],/FLOAT

  temp = image(congrid(sZVGcube[*,*,3,y],NX*3,NY*3),  layout = [3,1,3],   _EXTRA=props);title = 'OND'+string(1992+y),
  rgbdump = temp.rgb_table & rgbdump[*,0] = [190,190,190] &$ 
  temp.rgb_table=rgbdump &$ 
  m1 = MAP('Geographic',limit=[ymap_lry,ymap_ulx,ymap_uly,ymap_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$ 
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black')
  temp.title= 'NDVI OND'

;  ofile3 = odir+'Zscore_EastAfrica_OND_NDVI_2009.tif'
;  write_tiff, ofile3, sZVGcube[*,*,3,y],/FLOAT


;; THIS WORKSHEET IS DESIGNED TO DEVELOP DATA AND GRAPHICS TO SUPPORT THE
;; MANUSCRIPT SUBMISSION TO MW SPECIAL ISSUE
;; 10/5/15 final revision (I hope)
;; borrow CHIRPS_NDVI_EAv2.pro for figures w/ ECV manuscript
;; for Rainfall totals & station density see map_CHG_Stations.pr/
;; 12/21/15 back for minor revisions
;; 05/16/16 update to work on discover started on orignal file but am branching

;May 25 and June 11,18 revisit for revisions: see revisions_Jun22.pro
;;look at Noah values at the Mpala site
;Mpala Kenya:
;mxind = FLOOR( (36.8701 - map_ulx)/ 0.25)
;myind = FLOOR( (0.4856 - map_lry) / 0.25)
;;p1 = plot(SM[mxind,myind,*,18])
;p1 = plot(mean(SM[mxind,myind,*,*],dimension=4))
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Figure 1. landcover and elevation
;Figure 2. timeseries of coverage
;Figure 3. maps of coverage
;Figure 4. timeseries of z-scores
;Figure 5. map correlations (plot here!)

;1. read in the CHIRPS v2 data (I guess I should be using the stuff from NOAH (see Noah_P variable)
;indir = '/home/chg-shrad/DATA/Precipitation_Global/CHIRPS/v2.0/'
;ifile = file_search(indir+'chirps-v2.0.March_September_1982-2013.nc')
;fileID = ncdf_open(ifile, /nowrite) &$
;rainID = ncdf_varid(fileID,'precip')
;ncdf_varget,fileID, rainID, rain
;rain = congrid(rain,117,139,32)
;rain(where(rain lt 0))= !values.f_nan
;now i mask by land and crop  in the read-in loop below.

;try using the Yemen mask...from Yemen_mask.pro
;ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input_wrsi.ea_may2nov.nc') & print, ifile ;long mask
ifile = file_search('/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/lis_input_wrsi.ea_may2nov.nc')
fileID = ncdf_open(ifile, /nowrite) &$
maskID = ncdf_varid(fileID,'WRSIMASK')
ncdf_varget,fileID, maskID, longmask
longmask(where(longmask eq 0))= !values.f_nan

long25 = congrid(longmask,117,139)
long25(where(long25 eq 0)) = !values.f_nan

long25V = congrid(longmask,118,141)
long25V(where(long25V eq 0)) = !values.f_nan

; Noah and VIC match
maskID = ncdf_varid(fileID,'LANDMASK')
ncdf_varget,fileID, maskID, land
land25 = congrid(land,117,139)
land25(where(land25 eq 0)) = !values.f_nan

land25V = congrid(land,118,141)
land25V(where(land25V eq 0)) = !values.f_nan

land2532 = rebin(land25,117,139,32)
long2532 = rebin(long25,117,139,32)

;read in the GVF map for sparse/dense veg analysis
indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/'

;ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input.noah33_eaoct2nov.nc') & print, ifile ;long mask
ifile = file_search(indir+'lis_input.MODISmode_ea.nc');lis_input_wa_elev.nc
fileID = ncdf_open(ifile, /nowrite) &$
maskID = ncdf_varid(fileID,'GREENNESS')
ncdf_varget,fileID, maskID, green
green(where(green lt 0))= !values.f_nan
green25 = congrid(green,117,139,12)

gvf = mean(green25,dimension=3,/nan)*long25 & help, gvf

;what mask was I using here?
;mask25 = congrid(mask,117,139)


;write out to ENVI
;odir = '/home/sandbox/people/mcnally/JAGdata4figs/'
;ofile = odir +'vegdensity_meanGVF_117_139.bin'
;openw,1,ofile
;writeu,1,reverse(gvf,2)
;close,1

;have to run this twice for the 1982 and 1992 plots. not ideal.
startyr = 1982 ;start with 1982 to match NDVI
endyr = 2014 
nyrs = endyr-startyr+1

;re-do for all months
startmo = 1
endmo = 12
nmos = endmo - startmo+1

;East Africa WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

ulx = (180.+map_ulx)*10.  & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10.   & lry = (50.-map_lry)*10.-1
NX = lrx - ulx + 1.5
NY = lry - uly + 2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_CHIRPSv2.001_MERRA_EA/'
data_dir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/post/'
;data_dirV = '/home/sandbox/people/mcnally/VIC_CHIRPSv2.0_MERRA_EA/' ;update theis to CHIRPSv2
data_dirV = '/discover/nobackup/projects/fame/MODEL_RUNS/VIC_OUTPUT/OUTPUT_M2C_EA/post/'
SM = FLTARR(NX,NY,nmos,nyrs)
VIC01 = FLTARR(118,141,nmos,nyrs)

VET = FLTARR(118,141,nmos,nyrs)
NET = FLTARR(NX,NY,nmos,nyrs)

Nrain = FLTARR(NX,NY,nmos,nyrs)
Vrain = FLTARR(118,141,nmos,nyrs)

;ECV = FLTARR(285, 339,12, nyrs)
;this loop reads in the selected months only
;use same land and long mask for Noah and VIC?
mask = land25
for yr=startyr,endyr do begin &$
  for i=0,nmos-1 do begin &$
  y = yr &$
  m = startmo + i &$
  if m gt 12 then begin &$
    m = m-12 &$
    y = y+1 &$
  endif &$

  fileID = ncdf_open(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_C_EA_M.A'',I4.4,I2.2,''.001.nc'')',y,m), /nowrite) &$
 
  SoilID = ncdf_varid(fileID,'SoilMoi00_10cm_tavg') &$
  ncdf_varget,fileID, SoilID, SM01 &$
  SM[*,*,i,yr-startyr] = SM01*longmask*land &$

;  SoilID = ncdf_varid(fileID,'Evap_tavg') &$
;  ncdf_varget,fileID, SoilID, ET &$
;  NET[*,*,i,yr-startyr] = ET*longmask*land &$
;
  SoilID = ncdf_varid(fileID,'Rainf_f_tavg') &$
  ncdf_varget,fileID, SoilID, P &$
  Nrain[*,*,i,yr-startyr] = P*longmask*land &$

 ;;;;;;;;;;;;;;;;;;;;;;;; VIC;;;;;  
  fileID = ncdf_open(data_dirV+STRING(FORMAT='(''FLDAS_VIC025_C_EA_M.A'',I4.4,I2.2,''.001.nc'')',y,m), /nowrite) &$
  SoilID = ncdf_varid(fileID,'SoilMoi00_10cm_tavg') &$
  ncdf_varget,fileID, SoilID, SM01V &$
  VIC01[*,*,i,yr-startyr] = SM01V*long25V*land25V &$
  
;  SoilID = ncdf_varid(fileID,'Evap_tavg') &$
;  ncdf_varget,fileID, SoilID, ET &$
;  VET[*,*,i,yr-startyr] = ET*long25V*land25V &$
;  
  SoilID = ncdf_varid(fileID,'Rainf_f_tavg') &$
  ncdf_varget,fileID, SoilID, P &$
  Vrain[*,*,i,yr-startyr] = P*long25V*land25V &$

  endfor &$
endfor
;;i can take the mean of this later and correlate with the other vars
;rain = congrid(rain,117,139,32)
;CHIRPS2532 = rain*land2532*long2532 ;now i mask by land and crop  in the read-in file.

NX = 117
NY = 139

vrain(where(vrain lt 0)) = !values.f_nan
nrain(where(nrain lt 0)) = !values.f_nan
;vet(where(vet lt 0))   = !values.f_nan
;net(where(net lt 0))   = !values.f_nan
sm(where(sm lt 0))     = !values.f_nan 
vic01(where(vic01 lt 0))  = !values.f_nan 
vicCUBE = vic01[1:NX, 1:NY,*,*];why is this one pixel smaller?
;vicCUBE_ET = VET[1:NX, 1:NY,*,*];why is this one pixel smaller?
vicCUBE_P = Vrain[1:NX, 1:NY,*,*];why is this one pixel smaller?

NOAH_SM25 = congrid(reform(SM,294,348,12*nyrs),NX,NY,nmos*nyrs)
;NOAH_ET25 = congrid(reform(NET,294,348,12*nyrs),NX,NY,nmos*nyrs)
NOAH_P25 = congrid(reform(Nrain,294,348,12*nyrs),NX,NY,nmos*nyrs)

NOAHCUBE = reform(NOAH_SM25,NX,NY,nmos,nyrs)
;NOAHCUBE_ET = reform(NOAH_ET25,NX,NY,nmos,nyrs)
NOAHCUBE_P = reform(NOAH_P25,NX,NY,nmos,nyrs)

;ECV SOIL MOISUTURE preprocessed with cdo
;data_dirE = '/home/sandbox/people/mcnally/ECV_shrad/';monthly ECV soil mositure 1982-2013 '
data_dirE = '/discover/nobackup/projects/fame/RS_DATA1/CCI_SM_v02.2/data/combined/monmean/'

;now read in the monthly data how is this going to work?
;nx, ny, 12, nyrs
;get dimensions from one of the files
  fileID = ncdf_open(strcompress(data_dirE+'CCISMv2.2_MONMEAN_AFR_2014.nc', /remove_all)) 
  SoilID = ncdf_varid(fileID,'sm')
  ncdf_varget,fileID, SoilID, ECV 
temp = size(ECV, /dimensions)
NX = temp[0]
NY = temp[1]
NZ = temp[2]

tic
startyr = 1982
endyr = 2014
nmos = 12
ECVcube = fltarr(NX, NY, NMOS, NYRS)* !values.f_nan
for yr = startyr, endyr do begin &$
  fileID = ncdf_open(strcompress(data_dirE+'CCISMv2.2_MONMEAN_AFR_'+string(yr)+'.nc', /remove_all)) &$
  SoilID = ncdf_varid(fileID,'sm') &$
  ncdf_varget,fileID, SoilID, ECV &$
  ECVcube[*,*,*,yr-startyr] = reverse(ECV,2)*0.0001 &$
endfor
toc
ECVcube(WHERE(ECVcube LT -9998)) = !VALUES.f_NAN

;try with no flag and see how it goes. I could make another file with this info.      
;FLAGID = ncdf_varid(fileID,'flag') &$
;ncdf_varget,fileID, FLAGID, FLAG
;flag = reverse(flag,2)
      

longECV = rebin(long25,nx,ny,420) & help, longECV
landECV = rebin(land25,nx,ny,420) & help, landECV

ECV = ECV*longECV*landECV
ECVCUBE0 = REFORM(ecv[*,*,(startyr-1979)*12:419-(2013-endyr)*12],NX,NY,nmos,nyrs); for 0.1 deg analysis
flagCUBE = float(REFORM(flag[*,*,(startyr-1979)*12:419-(2013-endyr)*12],NX,NY,nmos,nyrs)); for 0.1 deg analysis

;what do the flag values mean?
;1no_flag (or is zero no flag?)
;2snow_coverage_or_temperature_below_zero 
;3dense_vegetation 
;127 others_no_convergence_in_the_model_thus_no_valid_sm_estimates" ;
flagcube(where(flagcube gt 1, complement=ok))=!values.f_nan
flagcube(ok)=1
ECVCUBE = ECVCUBE0*flagcube

;I need to do some basic comparisons on the mean and std of these datasets...
;HELP, VICCUBE, ECVCUBE, NOAHCUBE, NOAHCUBE_ET, VICCUBE_ET,NOAHCUBE_P, VICCUBE_P
HELP, VICCUBE, ECVCUBE, NOAHCUBE, NOAHCUBE_P, VICCUBE_P

;;;;;;;;;;;;grab ndvicube2 from GIMMS_NDVI_EA.pro;;;;;;;
;re-initialize start yr since GIMMS always starts in 1982

NX = 117
NY = 139

;;;;;;;;;;;;;chose which years are going to be used. 1992 or 1982?
startyr = 1992
endyr = 2013
nyrs = endyr-startyr+1 & print, nyrs
;standardize function:The result is an m-column, n-row array where all columns have a mean of zero and a variance of one
;time series over the whole domain

;;;;;from the max or avg cube GIMMS NDVI script;;;;;
;long25cube = rebin(long25,NX,NY,12,32) & help, long25cube
;mask25cube = rebin(mask25,NX,NY,12,32) & help, mask25cube ;ot sure where 'mask' is/
mask25cube = rebin(long25,NX,NY,12,32) & help, mask25cube
ndvicube = ndvicube2
;ndvicube2 = ndvicube2*long25cube
ndvicube2 = ndvicube2*mask25cube

temp = mean(mean(ndvicube2,dimension=1,/nan),dimension=1,/nan)
MY_NDV = temp[*,startyr-1982:endyr-1982] & help, my_NDV

;i should probably mask to the NDVI domain
NDVImask = ndvicube2[*,*,0,0]
NDVImask(where(finite(NDVImask), complement=other))=1
NDVImask(other)=!values.f_nan
NDVImask32=rebin(ndvimask,nx, ny, nmos, 32);where else is this used besides noah2p?
NDVImask=rebin(ndvimask,nx, ny, nmos, nyrs);where else is this used besides noah2p?

MY_ECV = mean(mean(ecvcube[*,*,*,startyr-1982:endyr-1982]*ndvimask,dimension=1,/nan),dimension=1,/nan) & help, my_ECV
MY_VIC = mean(mean(VICcube[*,*,*,startyr-1982:endyr-1982]*ndvimask,dimension=1,/nan),dimension=1,/nan) & help, my_VIC
MY_NOH = mean(mean(NOAHcube[*,*,*,startyr-1982:endyr-1982]*ndvimask,dimension=1,/nan),dimension=1,/nan) & help, my_NOH

;do the different regions of interest too. not just the whole domain
;how do i subset boxes? 

;I want yrs (22/32) to be mean zero  march-sept
WET_ECV = MEAN(MY_ECV[2:8,*],DIMENSION=1,/NAN)
WET_VIC = MEAN(MY_VIC[2:8,*],DIMENSION=1,/NAN)
WET_NOH = MEAN(MY_NOH[2:8,*],DIMENSION=1,/NAN)
WET_NDV = MEAN(MY_NDV[2:8,*],DIMENSION=1,/NAN)

Z_ECV = standardize(reform(WET_ECV,1,nyrs))
Z_VIC = standardize(reform(WET_VIC,1,nyrs))
Z_NOH = standardize(reform(WET_NOH,1,nyrs))
Z_NDV = standardize(reform(WET_NDV,1,nyrs))

;read in Shrad's chirps to include here, is there CHIRPSv2?
;fileID = ncdf_open('/home/sandbox/people/mcnally/JAGdata4figs/CHIRPSv1.8/Sptially_mean_EA_CHIRPS_March_September_chirps.1982-2013.nc') &$
;rainID = ncdf_varid(fileID,'precip') &$
;ncdf_varget,fileID, rainID, P
;P = mean(mean(chirps2532,dimension=1,/nan),dimension=1,/nan)
noahcube_P2 = noahcube_p*ndvimask32
P = mean(mean(mean(noahcube_P2[*,*,2:8,*],dimension=1,/nan),dimension=1,/nan),dimension=1,/nan)

;p82 = standardize(reform(P,1,32))
pX2 = standardize(reform(P[startyr-1982:31],1,nyrs))

;1982-2013 correlations and 1992-2013 correlations F>1
;I think I'd like to re-do these for monthly...
;these are seasonal correlations March-Sept
;multi-month ECV and NDVI don't agree since ECV is 'instanstaneous'?, 1982, 1992 - little diff. masking?
print, r_correlate(Z_ECV[0,*],Z_VIC[0,*]);0.48, 0.69*, 0.56, 0.70, 0.63 | 0.55, 0.68*, 0.84
print, r_correlate(Z_ECV[0,*],Z_NOH[0,*]);0.60, 0.74*, 0.59, 0.68,0.69 | 0.61, 0.69*, 0.76 
print, r_correlate(Z_NDV[0,*],Z_ECV[0,*]);0.44, 0.54*, 0.45, 0.58,0.45 | 0.45, 0.58*, 0.58

print, r_correlate(Z_NDV[0,*],Z_NOH[0,*]);0.39, 0.40, 0.39, 0.40, 0.46  | 0.40, 0.40, 0.4
print, r_correlate(Z_VIC[0,*],Z_NDV[0,*]);0.45, 0.50, 0.41, 0.47,0.52  | 0.40, 0.45, 0.54
print, r_correlate(Z_VIC[0,*],Z_NOH[0,*]);0.90, 0.88, 0.9, 0.90,0.84   | 0.90, 0.90, 0.84

print, r_correlate(PX2[0,*],Z_ECV[0,*]); 0.41, 0.59, 0.39, 0.45   | 0.44 ,0.60*, 0.63
print, r_correlate(PX2[0,*],Z_NDV[0,*]); 0.50, 0.44, 0.44, 0.48   | 0.45, 0.41, 0.40
print, r_correlate(PX2[0,*],Z_NOH[0,*]); 0.83, 0.86, 0.84, 0.83   | 0.85, 0.88, 0.87
print, r_correlate(PX2[0,*],Z_VIC[0,*]); 0.81  0.81, 0.79, 0.77   | 0.80, 0.80, 0.74

w = window(DIMENSIONS=[1500,1200])
;r1 and r2 are for 1992 vs 1982 i guess.
R=2
p1 = plot(Z_ECV[0,*], /current, thick=2,color='r', name = 'CCI-SM', layout=[1,2,r])
p2 = plot(Z_VIC[0,*], /overplot,thick=2,color='orange', name='VIC', layout=[1,2,r])
p3 = plot(Z_NOH[0,*], /overplot,thick=2,color='blue', name = 'NOAH', layout=[1,2,r])
p4 = plot(Z_NDV[0,*], /overplot,thick=2,color='green', name = 'NDVI', layout=[1,2,r])
p5 = plot(PX2[0,*], /overplot,thick=2,color='black', name = 'CHIRPS', layout=[1,2,r])

p1.xrange = [0,nyrs-1]
xticks = indgen(nyrs+1)+startyr & print, xticks
p1.xtickinterval = 1
p1.xTICKNAME = string(xticks)
p1.xticklen=1
p1.xgridstyle=1
p1.xtext_orientation=90
!null = legend(target=[p1,p2,p3,p4,p5], position=[0.2,0.3], font_size=18, orientation=1, shadow=0)
p1.xminor=0
p1.yminor=0
p1.ytitle = 'standardized anomaly'
p1.yrange=[-3,3]
p1.font_size=18
t = TEXT(target=p1, 1, -2.8, '$\it A) 1992-2013 $',/DATA, FONT_SIZE=18)

;;make maps of seasonal std anoms so i can correlate by pixel
;; 117,138,12,22 where mean of col3 is zero

nx = 117
ny = 139

;;get the seasonal z-score from seasonal_zscore.pro.
help, sZMW,  sZCS ,  sZCM , sZVG 
help, cormap11, cormap12, cormap13, cormap14, cormap15, c

;did these get re-done?
d = mean([ [[cormap13[*,*,0]]], [[cormap11[*,*,0]]], [[cormap14[*,*,0]]] ],dimension=3)*long25*land25 & help, d

;East Africa WRSI/Noah window
ea_ulx = 22.  & ea_lrx = 51.35
ea_uly = 22.95  & ea_lry = -11.75


shapefile = '/home/code/idl_user_contrib/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'

ncolors=5 ;10 for VIC v NOAH there is a funny hash pattern in VIC v Noah, maybe becasue of re-gridding
txt =  ['MW-Noah', 'MW-VIC', 'MW-NDVI', 'NDVI-Noah', 'NDVI-VIC', 'Noah-VIC','average']
label = ['A','B','C','D','E']
w = window(DIMENSIONS=[1900,700])
;i=4 ;1/0,3/2,4/3
for i=0,4 do begin &$
  p1 = image(congrid(c[*,*,0,i], NX*3, NY*3), image_dimensions=[nx/4,ny/4], $
  ;p1 = image(congrid(d, NX*3, NY*3), image_dimensions=[nx/4,ny/4], $
  image_location=[ea_ulx,ea_lry],RGB_TABLE=64, /current, margin = 0.1, layout = [5,1,i+1])  &$
  ;image_location=[ea_ulx,ea_lry],RGB_TABLE=64, /current, margin = 0.1)  &$

  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,255] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  rgbdump[*,0] = [255,255,255] &$;[190,190,190] &$
  ;rgbdump[*,255] = [255,255,255] &$;[190,190,190] &$
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  ;p1.title = string(i+1) &$
  p1.MAX_VALUE=0.9 &$
  p1.min_value=-0.1 &$
  m1 = MAP('Geographic',limit=[ea_lry+5,ea_ulx+5.5,ea_uly-5,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [255, 255, 255] &$ ;150
  ;m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2) &$
  m = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1, THICK=2) &$  
  ;p1.title = 'average' &$
  p1.title = txt[i] &$
  p1.font_size=20 &$
  ;t = TEXT(target=p1,48,-6, '$\it A $',/DATA, FONT_SIZE=18)
  t = TEXT(target=p1,48,-6, string(label[i]),/DATA, FONT_SIZE=18)&$
endfor
   cb = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,font_size=24, position=[0.3,0.10,0.7,0.13]) 

;;;;;;;;PANELS for model, RS, NDVI comparions;;;;;;;;;
;;;;;;;;open the NDVI data from GIMMS_NDVI_EA and reshape it;;;;;;;
;where do these come from? seasonal z-score.pro
help, sZVG, sZMW, sZCM, sZCS

sZVGcube = reform(sZVG,117,139,4,22)
sZMWcube = reform(sZMW,117,139,4,22)
sZCMcube = reform(sZCM,117,139,4,22)
sZCScube = reform(sZCS,117,139,4,22)
;for y = 0, nyrs -1 do begin &$
  
  props = {current:1, image_dimensions:[nx/4,ny/4], image_location:[ea_ulx+0.25,ea_lry+0.5], $
  min_value:-2.5, max_value:2.5, rgb_table:70,  font_size: 20, MARGIN:[0.1, 0.01, 0.01, 0.1] };left, bottom, right, top
  
  ;East Africa WRSI/Noah window
  ea_ulx = 22.  & ea_lrx = 51.35
  ea_uly = 22.95  & ea_lry = -11.75

YOI = 2009
y= YOI - 1992 &$
  w = window(DIMENSIONS=[1100,900], window_title = string(1992+y)) &$
  
  temp = image(congrid(sZMWcube[*,*,1,y],NX*3,NY*3),  layout = [3,3,1],  _EXTRA=props )  &$ ;left, botton, right, top
  ;temp.title = 'AMJ'
  temp.font_size=20
  rgbdump = temp.rgb_table & rgbdump[*,0] = [255,255,255] &$
  temp.rgb_table=rgbdump &$
  ;m1 = MAP('Geographic',limit=[ea_lry,ea_ulx,ea_uly,ea_lrx], /overplot) &$
  m1 = MAP('Geographic',limit=[ea_lry+5,ea_ulx+5.5,ea_uly-5,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1, thick=2) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black') &$
 
  temp = image(congrid(sZMWcube[*,*,2,y],NX*3,NY*3),  layout = [3,3,2],  _EXTRA=props)  &$ ;left, botton, right, top
 ; temp.title = 'JAS'
  temp.font_size=20
  rgbdump = temp.rgb_table & rgbdump[*,0] = [255,255,255] &$
  temp.rgb_table=rgbdump &$
  m1 = MAP('Geographic',limit=[ea_lry+5,ea_ulx+5.5,ea_uly-5,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1, thick=2) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black')
  

  temp = image(congrid(sZMWcube[*,*,3,y],NX*3,NY*3),  layout = [3,3,3],   _EXTRA=props)
  ;temp.title = 'OND'
  temp.font_size=20
  rgbdump = temp.rgb_table & rgbdump[*,0] = [255,255,255] &$
  temp.rgb_table=rgbdump &$
  m1 = MAP('Geographic',limit=[ea_lry+5,ea_ulx+5.5,ea_uly-5,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  
  m1.mapgrid.font_size=0 &$
  m1.mapgrid.color = [150, 150, 150] &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1, thick=2) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black')

;;;;;;;;;;;NOAH;;;;;;;;;;

  temp = image(congrid(sZCMcube[*,*,1,y],NX*3,NY*3),  layout = [3,3,4],  _EXTRA=props);title = 'AMJ'+string(1992+y),
  rgbdump = temp.rgb_table & rgbdump[*,0] = [255,255,255] & temp.rgb_table=rgbdump &$
  m1 = MAP('Geographic',limit=[ea_lry+5,ea_ulx+5.5,ea_uly-5,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1, thick=2) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black')

  temp = image(congrid(sZCMcube[*,*,2,y],NX*3,NY*3),  layout = [3,3,5],   _EXTRA=props);title = 'JAS'+string(1992+y),
  rgbdump = temp.rgb_table & rgbdump[*,0] = [255,255,255] &$
  temp.rgb_table=rgbdump &$
  m1 = MAP('Geographic',limit=[ea_lry+5,ea_ulx+5.5,ea_uly-5,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1, thick=2) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black')


  temp = image(congrid(sZCMcube[*,*,3,y],NX*3,NY*3),  layout = [3,3,6],   _EXTRA=props);title = 'OND'+string(1992+y),
  rgbdump = temp.rgb_table & rgbdump[*,0] = [255,255,255] &$
  temp.rgb_table=rgbdump &$
  m1 = MAP('Geographic',limit=[ea_lry+5,ea_ulx+5.5,ea_uly-5,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1, thick=2) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black')

;;;;;;;;;;;;;;;;;;NDVI;;;;;;;;;;;;
  i = (YOI-1982)   &$   ; skip the first n-years of the timeseries when calculating the trend

  temp = image(congrid(sZVGcube[*,*,1,y],NX*3,NY*3),  layout = [3,3,7],   _EXTRA=props);title = 'AMJ'+string(1992+y),
  rgbdump = temp.rgb_table & rgbdump[*,0] =[255,255,255]&$
  temp.rgb_table=rgbdump &$
  m1 = MAP('Geographic',limit=[ea_lry+5,ea_ulx+5.5,ea_uly-5,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1, thick=2) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black')
  
  temp = image(congrid(sZVGcube[*,*,2,y],NX*3,NY*3),  layout = [3,3,8],   _EXTRA=props);title = 'JAS'+string(1992+y),
  rgbdump = temp.rgb_table & rgbdump[*,0] = [255,255,255]
  temp.rgb_table=rgbdump
  m1 = MAP('Geographic',limit=[ea_lry+5,ea_ulx+5.5,ea_uly-5,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1, thick=2) &$ 
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black') &$ 
  c = COLORBAR(target=temp,ORIENTATION=0,/BORDER_ON,font_size=12)
  
  temp = image(congrid(sZVGcube[*,*,3,y],NX*3,NY*3),  layout = [3,3,9],   _EXTRA=props);title = 'OND'+string(1992+y),
  rgbdump = temp.rgb_table & rgbdump[*,0] = [255,255,255] &$ 
  temp.rgb_table=rgbdump &$ 
  m1 = MAP('Geographic',limit=[ea_lry+5,ea_ulx+5.5,ea_uly-5,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1, thick=2) &$ 
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black')

;;;;is this the end? where are the timeseries plots?;;;;;;;;;


;
;props = {current:1, image_dimensions:[nx/4,ny/4], image_location:[ea_ulx+0.25,ea_lry+0.5], rgb_table:70};
;;min_value:-2.5, max_value:2.5
;
;;which cormap is which??
;;1 = MW-NOAH
;;3 = MW-NDVI
;;6 = NDVI-NOAH
;
;level1 = cormap3[*,*,0]*!values.f_nan
;level1(where(cormap3 gt 0.3 AND cormap1 gt 0.4, complement=other))=10
;level1(other) = !values.f_nan
;
;level2 = cormap1[*,*,0]*!values.f_nan
;level2(where(cormap1 gt 0.4 AND cormap3 lt 0.4, complement=other))=5
;level2(other) = !values.f_nan
;
;level3 = cormap6[*,*,0]
;level3(where(level3 gt 0.6, complement=other))=1
;level3(other) = !values.f_nan
;
;ncolors=5
;p1 = image(congrid(level1*long25, NX*3, NY*3), image_dimensions=[nx/4,ny/4], $
;  image_location=[ea_ulx+0.25,ea_lry+0.5],RGB_TABLE=55, /current, transparency=50)  &$
;  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
;  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
;  rgbdump[*,255] = [255,255,255] &$ ; set map values of zero to white, you can change the color
;  rgbdump[*,0] = [190,190,190] &$
;  ;rgbdump[*,255] = [190,190,190]
;  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
;  ;p1.title = string(i+1) &$
;  p1.MAX_VALUE=12.0 &$
;  p1.min_value=0 &$
;  cb = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,font_size=24) &$
;  m1 = MAP('Geographic',limit=[ea_lry,ea_ulx,ea_uly,ea_lrx], /overplot) &$
;  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
;  m1.mapgrid.color = [150, 150, 150] &$
;  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
;  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2)
;
;
;
;  ;  ofile3 = odir+'Zscore_EastAfrica_OND_NDVI_2009.tif'
;  ;  write_tiff, ofile3, sZVGcube[*,*,3,y],/FLOAT
;  ;  ofile2 = odir+'Zscore_EastAfrica_JAS_NDVI_2009.tif'
;  ;  write_tiff, ofile2, sZVGcube[*,*,2,y],/FLOAT
;  ;  ofile1 = odir+'Zscore_EastAfrica_AMJ_NDVI_2009.tif'
;  ;  write_tiff, ofile1, sZVGcube[*,*,1,y],/FLOAT
;
;  ;  ofile3 = odir+'Zscore_EastAfrica_OND_NOAH_2009.tif'
;  ;  write_tiff, ofile3, sZCMcube[*,*,3,y], /FLOAT
;
;  ;  ofile3 = odir+'Zscore_EastAfrica_OND_ECV_2009.tif'
;  ;  write_tiff, ofile3, sZMWcube[*,*,3,y], /FLOAT
;
;  ;  ofile1 = odir+'Zscore_EastAfrica_AMJ_NOAH_2009.tif'
;  ;  write_tiff, ofile1, sZCMcube[*,*,1,y],/FLOAT
;
;  ;  ofile2 = odir+'Zscore_EastAfrica_JAS_NOAH_2009.tif'
;  ;  write_tiff, ofile2, sZCMcube[*,*,2,y], /FLOAT
;  
;  
;;;;;;;;;;;;write out for shrad's plots;;;;;;;;;;
;V3 is CHIRPSv2 and longrainmask
;ofile = '/home/sandbox/people/mcnally/JAGdata4figs/seasonal_zscores_ECV_VIC_NOH_NDV_P_1982_2013_v4.csv
;hdr = ['Z_ECV', 'Z_VIC', 'Z_NOH', 'Z_NDV', 'Z_CHIRPS']
;out82 = [Z_ECV, Z_VIC, Z_NOH, Z_NDV, P82] & help, out82
;write_csv,ofile,out82, header=hdr
;
;ofile = '/home/sandbox/people/mcnally/JAGdata4figs/seasonal_zscores_ECV_VIC_NOH_NDV_1992_2013_v4.csv
;hdr = ['Z_ECV', 'Z_VIC', 'Z_NOH', 'Z_NDV', 'Z_CHIRPS']
;out92 = [Z_ECV, Z_VIC, Z_NOH, Z_NDV, P92] & help, out92
;write_csv,ofile,out92, header=hdr

;
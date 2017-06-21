;; THIS WORKSHEET IS DESIGNED TO DEVELOP DATA AND GRAPHICS TO SUPPORT THE
;; MANUSCRIPT SUBMISSION TO MW SPECIAL ISSUE

;; borrow CHIRPS_NDVI_EAv2.pro for figures w/ ECV manuscript
;for Rainfall totals & station density see map_CHG_Stations.pro

;May 25 and June 11,18 revisit for revisions
; Novermber 16, 2015 water balance plots for christa.
;November 30, 2015

startyr = 1982 ;start with 1982 since no data in 1981
endyr = 2015
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
;NX = lrx - ulx + 2
;NY = lry - uly + 2
NX = 294
NY = 348

;data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_CHIRPSv2_MERRA_SA/';FLDAS_NOAH01_B_SA_M.A201507.001.nc
;data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_CHIRPSv2_MERRA_WA/';FLDAS_NOAH01_B_SA_M.A201507.001.nc
data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_CHIRPSv2.001_MERRA_EA/';FLDAS_NOAH01_B_SA_M.A201507.001.nc

Qsub = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
Qsuf = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
Rain = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
Evap = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
SM01 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
SM02 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
SM03 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
SM04 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
LST = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
Tair = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan

;this loop reads in the selected months only
for yr=startyr,endyr do begin &$
  for i=0,nmos-1 do begin &$
  y = yr &$
  m = startmo + i &$
  if m gt 12 then begin &$
  m = m-12 &$
  y = y+1 &$
endif &$
fileID = ncdf_open(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_B_EA_M.A'',I4.4,I2.2,''.001.nc'')',y,m), /nowrite) &$

qsID = ncdf_varid(fileID,'Qs_tavg') &$
ncdf_varget,fileID, qsID, Qs &$
Qsuf[*,*,i,yr-startyr] = Qs &$

qsID = ncdf_varid(fileID,'Qsb_tavg') &$ ;Rainf_tavg
ncdf_varget,fileID, qsID, Qsb &$
Qsub[*,*,i,yr-startyr] = Qsb &$

qsID = ncdf_varid(fileID,'Evap_tavg') &$ ;Rainf_tavg
ncdf_varget,fileID, qsID, ET &$
Evap[*,*,i,yr-startyr] = ET &$

qsID = ncdf_varid(fileID,'Rainf_f_tavg') &$ ;Rainf_tavg
ncdf_varget,fileID, qsID, P &$
Rain[*,*,i,yr-startyr] = P &$

qsID = ncdf_varid(fileID,'RadT_tavg') &$ ;Rainf_tavg
ncdf_varget,fileID, qsID, T &$
LST[*,*,i,yr-startyr] = T &$

qsID = ncdf_varid(fileID,'Tair_f_tavg') &$ ;Rainf_tavg
ncdf_varget,fileID, qsID, T &$
Tair[*,*,i,yr-startyr] = T &$

qsID = ncdf_varid(fileID,'SoilMoi00_10cm_tavg') &$ ;Rainf_tavg
ncdf_varget,fileID, qsID, SM &$
SM01[*,*,i,yr-startyr] = SM &$

qsID = ncdf_varid(fileID,'SoilMoi10_40cm_tavg') &$ ;Rainf_tavg
ncdf_varget,fileID, qsID, SM &$
SM02[*,*,i,yr-startyr] = SM &$

qsID = ncdf_varid(fileID,'SoilMoi40_100cm_tavg') &$ ;Rainf_tavg
ncdf_varget,fileID, qsID, SM &$
SM03[*,*,i,yr-startyr] = SM &$

qsID = ncdf_varid(fileID,'SoilMoi100_200cm_tavg') &$ ;Rainf_tavg
ncdf_varget,fileID, qsID, SM &$
SM04[*,*,i,yr-startyr] = SM &$

NCDF_close, fileID &$
endfor &$
endfor
Qsuf(where(Qsuf lt 0)) = 0
Qsub(where(Qsub lt 0)) = 0
Evap(where(Evap lt 0)) = 0
Rain(where(Rain lt 0)) = 0
SM01(where(SM01 lt 0)) = 0
SM02(where(SM02 lt 0)) = 0
SM03(where(SM03 lt 0)) = 0
SM04(where(SM04 lt 0)) = 0
LST(where(LST lt 0)) = 0
Tair(where(Tair lt 0)) = 0

RO = Qsuf+Qsub

ingrid = fltarr(nx,ny)
ifile = '/home/sandbox/people/mcnally/yemen_mask_294x348V2.bin'
openr,1,ifile
readu,1,ingrid
close,1
;ifile = file_search('/home/sandbox/people/mcnally/westyemen_mask.tif')
;ingrid = read_tiff(ifile, GEOTIFF=g_tags)
;temp = image(reverse(ingrid,2), min_value=0)
;print, g_tags

monmask = rebin(ingrid,nx,ny,12) & help, monmask
tsmask = rebin(ingrid, nx,ny,12,nyrs) & help, tsmask

;not really sure whay she is expecting to see here...
ROyem = (RO/Rain)*tsmask
Pyem = (Rain/Rain)*tsmask
ETyem = (Evap/Rain)*tsmask
S1yem = (Sm01/Rain)*tsmask
S2yem = (Sm02/Rain)*tsmask
S3yem = (Sm03/Rain)*tsmask
S4yem = (Sm04/Rain)*tsmask
Tayem = (Tair/Rain)*tsmask
Tlyem = (LST/Rain)*tsmask

ROyem = RO*tsmask
Pyem = Rain*tsmask
ETyem = Evap*tsmask
S1yem = Sm01*tsmask
S2yem = Sm02*tsmask
S3yem = Sm03*tsmask
S4yem = Sm04*tsmask
Tayem = Tair*tsmask
Tlyem = LST*tsmask
;show the monthly averages.
a = mean(mean(royem,dimension=1,/nan),dimension=1,/nan) & help, a
b = mean(mean(Pyem,dimension=1,/nan),dimension=1,/nan) & help, b
c = mean(mean(ETyem,dimension=1,/nan),dimension=1,/nan) & help, c
d = mean(mean(S1yem,dimension=1,/nan),dimension=1,/nan) & help, c
e = mean(mean(S2yem,dimension=1,/nan),dimension=1,/nan) & help, c
f = mean(mean(S3yem,dimension=1,/nan),dimension=1,/nan) & help, c
g = mean(mean(S4yem,dimension=1,/nan),dimension=1,/nan) & help, c
h = mean(mean(Tayem,dimension=1,/nan),dimension=1,/nan) & help, c
j = mean(mean(Tlyem,dimension=1,/nan),dimension=1,/nan) & help, c

i=j
 w = WINDOW(DIMENSIONS=[1800,400])
amin=min(i,dimension=1) & help, amin
amax=max(i,dimension=1) & help, amax
amean=mean(i,dimension=1,/nan) & help, amean

p1=plot(amin, /current)
p2=plot(amax,/overplot)
p3=plot(amean,/overplot, linestyle=2)
p3.title = 'West Yemen LST/P min, max, mean'
p3.xrange=[0,33]
p3.xtickinterval=1
p3.xtickname=string(indgen(34)+1982)
p3.xminor=0
aa = mean(a,dimension=2,/nan)
bb = mean(b,dimension=2,/nan)
cc = mean(c,dimension=2,/nan)

p1 = plot(mean(a,dimension=2,/nan),bb,'*')
p1 = plot(mean(b,dimension=2,/nan),cc,/overplot, '*b')
p1 = plot(mean(c,dimension=2,/nan), bb,/overplot, '*g')
p1 = plot(mean(d,dimension=2,/nan)/100000,bb, /overplot, symbol='+',linestyle='','orange')
p1 = plot(mean(e,dimension=2,/nan)/100000,bb, /overplot, 'orange')
p1 = plot(mean(f,dimension=2,/nan)/100000, /overplot, 'orange')
p1 = plot(mean(g,dimension=2,/nan)/100000, /overplot, 'orange')
p1 = plot(mean(h,dimension=2,/nan)/10000000, /overplot, 'r')
p1 = plot(mean(j,dimension=2,/nan)/10000000,bb, /overplot, 'm')

;show the full time series
p1 = plot(mean(j,dimension=2,/nan)/100000,aa, symbol='+',linestyle='','orange')
p1 = plot(mean(j,dimension=2,/nan),aa, '*m')


p1 = plot(reform(a,12*34))
p1 = plot(reform(b,12*34), /overplot, 'b')
p1 = plot(reform(c,12*34), /overplot, 'g')
p1 = plot(reform(d,12*34)/100000, /overplot, 'orange')
p1 = plot(reform(e,12*34)/100000, /overplot, 'orange')
p1 = plot(reform(f,12*34)/100000, /overplot, 'orange')
p1 = plot(reform(g,12*34)/100000, /overplot, 'orange')
p1 = plot(reform(h,12*34)/10000000, /overplot, 'r')
p1 = plot(reform(j,12*34)/10000000, /overplot, 'm')

;show the accumulation
p1 = plot(total(reform(a,12*34),/cumulative))
p1 = plot(total(reform(b,12*34),/cumulative), /overplot, 'b')
p1 = plot(total(reform(c,12*34),/cumulative), /overplot, 'g')
p1 = plot(total(reform(d,12*34), /cumulative),/overplot, 'orange')
p1 = plot(total(reform(e,12*34),/cumulative), /overplot, 'orange')
p1 = plot(total(reform(f,12*34),/cumulative), /overplot, 'orange')
p1 = plot(total(reform(g,12*34),/cumulative), /overplot, 'orange')
p1 = plot(total(reform(h,12*34),/cumulative)/1000, /overplot, 'r')
p1 = plot(total(reform(j,12*34),/cumulative)/1000, /overplot, 'm')

;if i subtract the mean i should be able to put them on the same plot...
;then standardizing them probably helps futher..then also looking that the trends in the
;but from these I would agree that temp is going up, SM01 is going down and deeper SM is too (but less)
;p6 = plot(X,yfit,/overplot,'+r', linestyle=2,name = 'SM04')

;I can also use the NDVI data from GIMMS_NDVI_EA.pro
;this is at 0.25 degree (nativly?), 12 months, 32 yrs. Does it have a mask applied?
help, ndvicube2
;make a 25 degree yemen mask to apply to these data
help, ingrid 
ndvimask = rebin(congrid(ingrid,117,139),117,139,12,32) & help, ndvimask
yNDVI82_13 = ndvicube*ndvimask & help, yNDVI82_13
nmean = mean(mean(yndvi82_13,dimension=1, /nan), dimension=1,/nan)
nstd = standardize(nmean)
;nY = reform(nstd, 12*32)
  X = indgen(32)
for m = 0,11 do begin &$
  p1 = barplot(nstd[m,*], layout = [4,3,m+1], /current, title=month[m]) &$
  coeff = linfit(X,nstd[m,*])&$
  yfit = coeff[0]+coeff[1]*X  &$
  p1 = plot(X,yfit,/overplot,'b',thick=2)&$
  p1.yrange=[-3,3] &$
endfor

;RFE2_GDAS variables.
X=indgen(12*34) ;YEAR
;fill out the rest of the yr w. the mean?
ii = c
mi = mean(ii,dimension=2,/nan) & help, mi
ii[9:11,33] = mi[9:11]
i = standardize(ii)
Y=reform(i,12*34)
coeff = linfit(X,Y) & print, trend
yfit = coeff[0]+coeff[1]*X

p1 = plot(smooth(Y[0:403],30),'m',/overplot)
p1 = plot(X,yfit,/overplot,'b',name = 'RO',  thick=2)
p2 = plot(X,yfit,/overplot,'c',name = 'P',  thick=2)
p3 = plot(X,yfit,/overplot,'g',name = 'ET', linestyle=1, thick=2)
p4 = plot(X,yfit,/overplot,'orange', name = 'SM01', thick=2)
p5 = plot(X,yfit,/overplot,'r', linestyle=2,name = 'SM02')
p6 = plot(X,yfit,/overplot,'orange', linestyle=2,name = 'SM03')
p7 = plot(X,yfit,/overplot,'orange', linestyle=2,name = 'SM04')
p8 = plot(X,yfit,/overplot,'m',name = 'Tair', thick=2)


!null = legend(target=[p1,p2,p3,p4,p5,p6,p7,p8], orientation=0, shadow=0)
X=indgen(34) ;YEAR
month = ['jan', 'feb', 'mar','apr','may','jun','jul','aug','sep','oct','nov','dec']
;;plots by variable and month for 34 yrs, gettign hotter and drier, mostly. mostly hotter.
;It would be nice if funk and collin could connect this to the atmosphere and let me worry about the land...
for m = 0,11 do begin &$
  p1 = barplot(i[m,*], layout = [4,3,m+1], /current, title=month[m]) &$
  coeff = linfit(X,i[m,*])&$
  yfit = coeff[0]+coeff[1]*X  &$
  p1 = plot(X,yfit,/overplot,'b',thick=2)&$
  p1.yrange=[-3,3] &$
endfor

  
endfor




result = linfit(X,REFORM(a,12*34))
trendmap = FLTARR(NX,NY)
trendcor = FLTARR(NX,NY)
for y=0,NY-1 do begin &$
  for x=0,NX-1 do begin &$
  if MEAN(nave[x,y,*]) gt 0.0 then begin &$
  trend = REGRESS(X[0:403],Y[0:403],MCORRELATION=r) 

  trendcor[x,y] = r &$
endif &$
endfor &$
endfor

;try using the Yemen mask...from Yemen_mask.pro
;;oops deleted important stuff
;ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input_wrsi.ea_may2nov.nc') & print, ifile ;long mask
;fileID = ncdf_open(ifile, /nowrite) &$
;
;; Noah and VIC match
;maskID = ncdf_varid(fileID,'LANDMASK')
;ncdf_varget,fileID, maskID, land
;land25 = congrid(land,117,139)
;land25(where(land25 eq 0)) = !values.f_nan
;
;land25V = congrid(land,118,141)
;land25V(where(land25V eq 0)) = !values.f_nan
;
;land2532 = rebin(land25,117,139,32)
;
;;read in the GVF map for sparse/dense veg analysis
;
;ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input.noah33_eaoct2nov.nc') & print, ifile ;long mask
;fileID = ncdf_open(ifile, /nowrite) &$
;maskID = ncdf_varid(fileID,'GREENNESS')
;ncdf_varget,fileID, maskID, green
;green(where(green lt 0))= !values.f_nan
;green25 = congrid(green,117,139,12)
;
;gvf = mean(green25,dimension=3,/nan) & help, gvf
;
;mask25 = congrid(mask,117,139)

;write out to ENVI
;odir = '/home/sandbox/people/mcnally/JAGdata4figs/'
;ofile = odir +'vegdensity_meanGVF_117_139.bin'
;openw,1,ofile
;writeu,1,reverse(gvf,2)
;close,1

;have to run this twice for the 1982 and 1992 plots. not ideal.
startyr = 1982 ;start with 1982 to match NDVI
endyr = 2013
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
data_dir = '/home/sandbox/people/mcnally/NOAH_CHIRPSv2.0_MERRA_EA/'
data_dirE = '/home/sandbox/people/mcnally/ECV_shrad/';monthly ECV soil mositure 1982-2013 '
data_dirV = '/home/sandbox/people/mcnally/VIC_CHIRPSv2.0_MERRA_EA/' ;update theis to CHIRPSv2

SM = FLTARR(NX,NY,nmos,nyrs)
VIC01 = FLTARR(118,141,nmos,nyrs)

VET = FLTARR(118,141,nmos,nyrs)
NET = FLTARR(NX,NY,nmos,nyrs)

Nrain = FLTARR(NX,NY,nmos,nyrs)
Vrain = FLTARR(118,141,nmos,nyrs)

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
  ;v2.0
  fileID = ncdf_open(data_dir+STRING(FORMAT='(''SM01_YRMO/SM01_Noah_'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
  ;v1.8
  ;fileID = ncdf_open(data_dir+STRING(FORMAT='(''SM01_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
  SoilID = ncdf_varid(fileID,'SoilMoist_tavg') &$
  ncdf_varget,fileID, SoilID, SM01 &$
  ;SM[*,*,i,yr-startyr] = SM01*longmask &$
  SM[*,*,i,yr-startyr] = SM01*mask &$

  
  fileID = ncdf_open(data_dir+STRING(FORMAT='(''Evap_YRMO/Evap_Noah_'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
  SoilID = ncdf_varid(fileID,'Evap_tavg') &$
  ncdf_varget,fileID, SoilID, ET &$
  ;NET[*,*,i,yr-startyr] = ET*longmask &$
  NET[*,*,i,yr-startyr] = ET*mask &$

  
  fileID = ncdf_open(data_dir+STRING(FORMAT='(''Rain_YRMO/Rain_NOAH_'',I4.4,I2.2,''.nc'')',y,m), /nowrite) &$
  SoilID = ncdf_varid(fileID,'Rainf_tavg') &$
  ncdf_varget,fileID, SoilID, P &$
  ;Nrain[*,*,i,yr-startyr] = P*longmask &$
  Nrain[*,*,i,yr-startyr] = P*mask &$


  endfor &$
endfor
;;i can take the mean of this later and correlate with the other vars
;rain = congrid(rain,117,139,32)
;CHIRPS2532 = rain*land2532*long2532 ;now i mask by land and crop  in the read-in file.

NX = 117
NY = 139

nrain(where(net lt 0))       = !values.f_nan
net(where(net lt 0))       = !values.f_nan
sm(where(sm lt 0))         = !values.f_nan 

NOAH_SM25 = congrid(reform(SM,294,348,12*nyrs),NX,NY,nmos*nyrs)
NOAH_ET25 = congrid(reform(NET,294,348,12*nyrs),NX,NY,nmos*nyrs)
NOAH_P25 = congrid(reform(Nrain,294,348,12*nyrs),NX,NY,nmos*nyrs)

NOAHCUBE = reform(NOAH_SM25,NX,NY,nmos,nyrs)
NOAHCUBE_ET = reform(NOAH_ET25,NX,NY,nmos,nyrs)
NOAHCUBE_P = reform(NOAH_P25,NX,NY,nmos,nyrs)


;ECV SOIL MOISUTURE
fileID = ncdf_open(data_dirE+'Monthly_East_Africa_1979-2013_ESACCI-SOILMOISTURE-L3S-SSMV-COMBINED.nc') &$
SoilID = ncdf_varid(fileID,'sm') &$
ncdf_varget,fileID, SoilID, ECV

FLAGID = ncdf_varid(fileID,'flag') &$
  ncdf_varget,fileID, FLAGID, FLAG
flag = reverse(flag,2)

ECV(WHERE(ECV LT -9998)) = !VALUES.f_NAN
ECV = REVERSE(ECV,2)*0.0001

landECV = rebin(land25,nx,ny,420) & help, landECV

ECV = ECV*landECV
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
HELP, VICCUBE, ECVCUBE, NOAHCUBE, NOAHCUBE_ET, VICCUBE_ET,NOAHCUBE_P, VICCUBE_P
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
mask25cube = rebin(mask25,NX,NY,12,32) & help, mask25cube

ndvicube2 = ndvicube2*mask25cube

temp = mean(mean(ndvicube2,dimension=1,/nan),dimension=1,/nan)
MY_NDV = temp[*,startyr-1982:endyr-1982] & help, my_NDV

;i should probably mask to the NDVI domain
NDVImask = ndvicube2[*,*,0,0]
NDVImask(where(finite(NDVImask), complement=other))=1
NDVImask(other)=!values.f_nan
NDVImask32=rebin(ndvimask,nx, ny, nmos, 32);where else is this used besides noah2p?
NDVImask=rebin(ndvimask,nx, ny, nmos, nyrs);where else is this used besides noah2p?

HELP, ECVCUBE, NOAHCUBE, NOAHCUBE_ET, VICCUBE_ET,NOAHCUBE_P, VICCUBE_P

;how did this work before? was i always using 1982 until this section maybe...
MY_ECV = mean(mean(ecvcube[*,*,*,startyr-1982:endyr-1982]*ndvimask,dimension=1,/nan),dimension=1,/nan) & nve, my_ECV
MY_NOH = mean(mean(NOAHcube[*,*,*,startyr-1982:endyr-1982]*ndvimask,dimension=1,/nan),dimension=1,/nan) & help, my_NOH
MY_NET = mean(mean(NOAHcube_ET[*,*,*,startyr-1982:endyr-1982]*ndvimask,dimension=1,/nan),dimension=1,/nan) & help, my_NET


;;do the different regions of interest too. not just the whole domain
;how do i subset boxes? 

;I want yrs (22/32) to be mean zero 
WET_ECV = MEAN(MY_ECV[2:8,*],DIMENSION=1,/NAN)
WET_NET = MEAN(MY_NET[2:8,*],DIMENSION=1,/NAN)
WET_NOH = MEAN(MY_NOH[2:8,*],DIMENSION=1,/NAN)
WET_NDV = MEAN(MY_NDV[2:8,*],DIMENSION=1,/NAN)

Z_ECV = standardize(reform(WET_ECV,1,nyrs))
Z_NET = standardize(reform(WET_NET,1,nyrs))
Z_NOH = standardize(reform(WET_NOH,1,nyrs))
Z_NDV = standardize(reform(WET_NDV,1,nyrs))

;read in Shrad's chirps to include here, is there CHIRPSv2?
;fileID = ncdf_open('/home/sandbox/people/mcnally/JAGdata4figs/CHIRPSv1.8/Sptially_mean_EA_CHIRPS_March_September_chirps.1982-2013.nc') &$
;rainID = ncdf_varid(fileID,'precip') &$
;ncdf_varget,fileID, rainID, P
;P = mean(mean(chirps2532,dimension=1,/nan),dimension=1,/nan)
noahcube_P2 = noahcube_p*ndvimask32
P = mean(mean(mean(noahcube_P2[*,*,2:8,*],dimension=1,/nan),dimension=1,/nan),dimension=1,/nan)

;what happened here?
;p82 = standardize(reform(P,1,32))
pX2 = standardize(reform(P[startyr-1982:31],1,nyrs))

;1982-2013 correlations and 1992-2013 correlations F>1
;I think I'd like to re-do these for monthly...
;these are seasonal correlations March-Sept
;multi-month ECV and NDVI don't agree since ECV is 'instanstaneous'?, longrains mask92, NDVImask92
print, r_correlate(Z_ECV[0,*],Z_NET[0,*]);0.48, 0.69*, 0.56, 0.70 Yemen = 0.46
print, r_correlate(Z_ECV[0,*],Z_NOH[0,*]);0.60, 0.74*, 0.59, 0.68 Yemen = 0.53
print, r_correlate(Z_NDV[0,*],Z_ECV[0,*]);0.44, 0.54*, 0.45, 0.58 Yemen = 0.61

print, r_correlate(Z_NDV[0,*],Z_NOH[0,*]);0.39, 0.40, 0.39, 0.40 (good rel. is stable) Yemen = 0.76
print, r_correlate(Z_NET[0,*],Z_NDV[0,*]);0.45, 0.50, 0.41, 0.47 (ah! why is VIC still better?) Y=0.80
print, r_correlate(Z_NET[0,*],Z_NOH[0,*]);0.90, 0.88, 0.9, 0.90 Y=0.82

print, r_correlate(PX2[0,*],Z_ECV[0,*]); 0.41, 0.59, 0.39, 0.56  Y = 0.41  
print, r_correlate(PX2[0,*],Z_NDV[0,*]); 0.50, 0.44, 0.44, 0.44  Y = 0.60
print, r_correlate(PX2[0,*],Z_NOH[0,*]); 0.83, 0.86, 0.84, 0.88  Y = 0.78
print, r_correlate(PX2[0,*],Z_NET[0,*]); 0.81  0.81, 0.79, 0.80  Y = 0.86 

w = window(DIMENSIONS=[1000,600])

R=1
p1 = plot(Z_ECV[0,*], /current, thick=2,color='r', name = 'CCI-SM', layout=[1,1,r])
p2 = plot(Z_NET[0,*], /overplot,thick=2,color='orange', name='Noah ET', layout=[1,1,r])
p3 = plot(Z_NOH[0,*], /overplot,thick=2,color='blue', name = 'NOAH', layout=[1,1,r])
p4 = plot(Z_NDV[0,*], /overplot,thick=2,color='green', name = 'NDVI', layout=[1,1,r])
p5 = plot(PX2[0,*], /overplot,thick=2,color='black', name = 'CHIRPS', layout=[1,1,r])

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
t = TEXT(target=p1, 1, -2.8, '$\it B) 1992-2013 $',/DATA, FONT_SIZE=18)

;;make maps of seasonal std anoms so i can correlate by pixel
;BUT why are the table values bad?
;
;; 117,138,12,22 where mean of col3 is zero

nx = 117
ny = 139

;;get the seasonal z-score from seasonal zscore.pro
help, sZMW,  sZCS ,  sZCM , sZVG 
help, cormap11, cormap12, cormap13, cormap14, cormap15, c

;this is wrong...
d = mean([ [[cormap13[*,*,0]]], [[cormap11[*,*,0]]], [[cormap14[*,*,0]]] ],dimension=3)*long25*land25 & help, d

;East Africa WRSI/Noah window
ea_ulx = 22.  & ea_lrx = 51.35
ea_uly = 22.95  & ea_lry = -11.75



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
  ;rgbdump[*,255] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  rgbdump[*,0] = [190,190,190] &$
  rgbdump[*,255] = [190,190,190] &$
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  ;p1.title = string(i+1) &$
  p1.MAX_VALUE=0.9 &$
  p1.min_value=-0.1 &$
  cb = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,font_size=24) &$
  m1 = MAP('Geographic',limit=[ea_lry+5,ea_ulx+5.5,ea_uly-5,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2) &$
  ;p1.title = 'average' &$
  p1.title = txt[i] &$
  p1.font_size=20 &$
  ;t = TEXT(target=p1,48,-6, '$\it A $',/DATA, FONT_SIZE=18)
  t = TEXT(target=p1,48,-6, string(label[i]),/DATA, FONT_SIZE=18)&$

endfor
  
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

YOI = 2007
y= YOI - 1992 &$
  w = window(DIMENSIONS=[1000,900], window_title = string(1992+y)) &$
  
  temp = image(congrid(sZMWcube[*,*,1,y],NX*3,NY*3),  layout = [3,3,1],  _EXTRA=props )  &$ ;left, botton, right, top
  temp.title = 'AMJ'
  temp.font_size=20
  rgbdump = temp.rgb_table & rgbdump[*,0] = [190,190,190] &$
  temp.rgb_table=rgbdump &$
  ;m1 = MAP('Geographic',limit=[ea_lry,ea_ulx,ea_uly,ea_lrx], /overplot) &$
  m1 = MAP('Geographic',limit=[ea_lry+5,ea_ulx+5.5,ea_uly-5,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black') &$
 
  temp = image(congrid(sZMWcube[*,*,2,y],NX*3,NY*3),  layout = [3,3,2],  _EXTRA=props)  &$ ;left, botton, right, top
  temp.title = 'JAS'
  temp.font_size=20
  rgbdump = temp.rgb_table & rgbdump[*,0] = [190,190,190] &$
  temp.rgb_table=rgbdump &$
  m1 = MAP('Geographic',limit=[ea_lry+5,ea_ulx+5.5,ea_uly-5,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black')
  

  temp = image(congrid(sZMWcube[*,*,3,y],NX*3,NY*3),  layout = [3,3,3],   _EXTRA=props)
  temp.title = 'OND'
  temp.font_size=20
  rgbdump = temp.rgb_table & rgbdump[*,0] = [190,190,190] &$
  temp.rgb_table=rgbdump &$
  m1 = MAP('Geographic',limit=[ea_lry+5,ea_ulx+5.5,ea_uly-5,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  
  m1.mapgrid.font_size=0 &$
  m1.mapgrid.color = [150, 150, 150] &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black')

;;;;;;;;;;;NOAH;;;;;;;;;;

  temp = image(congrid(sZCMcube[*,*,1,y],NX*3,NY*3),  layout = [3,3,4],  _EXTRA=props);title = 'AMJ'+string(1992+y),
  rgbdump = temp.rgb_table & rgbdump[*,0] = [190,190,190] & temp.rgb_table=rgbdump &$
  m1 = MAP('Geographic',limit=[ea_lry+5,ea_ulx+5.5,ea_uly-5,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black')

  temp = image(congrid(sZCMcube[*,*,2,y],NX*3,NY*3),  layout = [3,3,5],   _EXTRA=props);title = 'JAS'+string(1992+y),
  rgbdump = temp.rgb_table & rgbdump[*,0] = [190,190,190] &$
  temp.rgb_table=rgbdump &$
  m1 = MAP('Geographic',limit=[ea_lry+5,ea_ulx+5.5,ea_uly-5,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black')


  temp = image(congrid(sZCMcube[*,*,3,y],NX*3,NY*3),  layout = [3,3,6],   _EXTRA=props);title = 'OND'+string(1992+y),
  rgbdump = temp.rgb_table & rgbdump[*,0] = [190,190,190] &$
  temp.rgb_table=rgbdump &$
  m1 = MAP('Geographic',limit=[ea_lry+5,ea_ulx+5.5,ea_uly-5,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black')

;;;;;;;;;;;;;;;;;;NDVI;;;;;;;;;;;;
  i = (YOI-1982)   &$   ; skip the first n-years of the timeseries when calculating the trend

  temp = image(congrid(sZVGcube[*,*,1,y],NX*3,NY*3),  layout = [3,3,7],   _EXTRA=props);title = 'AMJ'+string(1992+y),
  rgbdump = temp.rgb_table & rgbdump[*,0] = [190,190,190]&$
  temp.rgb_table=rgbdump &$
  m1 = MAP('Geographic',limit=[ea_lry+5,ea_ulx+5.5,ea_uly-5,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black')
  
  temp = image(congrid(sZVGcube[*,*,2,y],NX*3,NY*3),  layout = [3,3,8],   _EXTRA=props);title = 'JAS'+string(1992+y),
  rgbdump = temp.rgb_table & rgbdump[*,0] = [190,190,190]
  temp.rgb_table=rgbdump
  m1 = MAP('Geographic',limit=[ea_lry+5,ea_ulx+5.5,ea_uly-5,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$ 
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black') &$ 
  c = COLORBAR(target=temp,ORIENTATION=0,/BORDER_ON,font_size=12)
  
  temp = image(congrid(sZVGcube[*,*,3,y],NX*3,NY*3),  layout = [3,3,9],   _EXTRA=props);title = 'OND'+string(1992+y),
  rgbdump = temp.rgb_table & rgbdump[*,0] = [190,190,190] &$ 
  temp.rgb_table=rgbdump &$ 
  m1 = MAP('Geographic',limit=[ea_lry+5,ea_ulx+5.5,ea_uly-5,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.font_size=0 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$ 
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black')

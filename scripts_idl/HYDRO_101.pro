;the regional water balance
; 8/8/16
; 8/22/16 replotting ratios with colorbars and country boundaries
; 8/30/16 add timeseries for regions of interest
; 9/01/16 try to fix crashing problems by not using ide

;1. agreggate by HYMAP basin
;read in the basin map to see if i can average over these areas instead of rando boxes.
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro

;ifile = file_search('/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/lis_input_sa_elev_hymap_test.nc'); lis_input_ea_elev_hymapv2
ifile = file_search('/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/lis_input_ea_elev_hymapv2.nc')
VOI = 'HYMAP_basin' &$ ;
basin = get_nc(VOI, ifile)

mask = basin*!values.f_nan
good = where(basin ne 6 AND basin ne 168 AND basin ne 46 AND basin ne 111 AND basin ne 28, complement=other)
mask(good) = 1
mask(other) = !values.f_nan

cmask = basin*!values.f_nan
good = where(basin eq 6, complement=other)
;good = where(basin eq 6 AND basin ne 168 AND basin ne 46 AND basin ne 111 AND basin ne 28, complement=other)

cmask(good) = 1
cmask(other) = !values.f_nan

;1. readin the rainfall, runoff, et data > climatology from nco, cdo

data_dir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/waterbalance/'

.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro

startyr = 1982 ;there shouldn't really be anything for 1982? Yr2= 1982, Yr1=1981
endyr = 2016
nyrs = endyr-startyr+1

;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
params = get_domain01('EA')

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

;;;maps the average ratios from the FLDAS_grandmean.nc file (1982-2015)

ifile = file_search(data_dir+'FLDAS_grandmean.nc') & print, ifile
VOI = 'EoverP' &$ ;
E2P = get_nc(VOI, ifile)

VOI = 'QoverP' &$ ;
Q2P = get_nc(VOI, ifile)

VOI = 'Rainf_f_tavg' &$ ;
precip = get_nc(VOI, ifile)
precip(where(precip eq -9999))=!values.f_nan

VOI = 'Evap_tavg' &$ ;
Evap = get_nc(VOI, ifile)
Evap(where(Evap eq -9999))=!values.f_nan

VOI = 'RO_tavg' &$ ;
RO = get_nc(VOI, ifile)
RO(where(RO eq -9999))=!values.f_nan

;;;;;energy balance;;;;;;;
VOI = 'Rnet_tavg' &$ ;
Rnet = get_nc(VOI, ifile)
Rnet(where(rnet eq -9999))=!values.f_nan

VOI = 'Qh_tavg' &$ ;
Qh = get_nc(VOI, ifile)
Qh(where(Qh eq -9999))=!values.f_nan

VOI = 'Qle_tavg' &$ ;
Qle = get_nc(VOI, ifile)
Qle(where(Qle eq -9999))=!values.f_nan

VOI = 'Qg_tavg' &$ ;
Qg = get_nc(VOI, ifile)
Qg(where(Qg eq -9999))=!values.f_nan

;;;what does the corresponding IMAGE plot look like?
w = window(DIMENSIONS=[600,1000])
ncolors=10
p1 = image(RO*86400, image_dimensions=[nx/10,ny/10], $
  image_location=[map_ulx,map_lry],RGB_TABLE=73, margin = 0.1, layout = [1,3,3], /current)
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors))  &$  ; set tindex of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  ;rgbdump[*,255] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  ;rgbdump[*,0] = [255,255,255] &$;[190,190,190] &$
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.MAX_VALUE=2 &$
  p1.min_value=0 &$
  m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot, horizon_thick=1)
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [255, 255, 255] &$ ;150
  m1.mapgrid.font_size = 0

  m = MAPCONTINENTS( /COUNTRIES,HIRES=1, THICK=2) &$
  p1.title = 'Runoff' &$
  p1.font_size=12
  cb = COLORBAR(target=p1,ORIENTATION=1,/BORDER,TAPER=1, THICK=0,font_size=12)

;read in the delS from each file
;delS = FLTARR(NX,NY,nyrs)*!values.f_nan
SM = FLTARR(NX,NY,nyrs)*!values.f_nan
P = FLTARR(NX,NY,nyrs)*!values.f_nan
ET = FLTARR(NX,NY,nyrs)*!values.f_nan
RO = FLTARR(NX,NY,nyrs)*!values.f_nan

;**************************************
;**************************************
;read in from readin_chirps_noach_et.pro, readin_chirps_noach_sm.pro, readin_chirps_noach_q.pro
help, Evap_annual, SMtot_annual, RO_annual, rain_annual
;read in regions of interes from 
help, bale_xy, mpala_xy, tigray_xy, sheka_xy, yirol_xy, wyemen_xy
x = yirol_xy[0]
y = yirol_xy[1]
temp = plot(rain_annual[x,y,*],thick=2)
temp = plot(RO_annual[x,y,*], /overplot, 'green')
temp = plot(evap_annual[x,y,*], /overplot, 'b')
temp = plot(SMtot_annual[x,y,*]/100000, /overplot, 'orange')
temp.title = 'yirol, south sudan Rain(black), ET(blue), SM/100000 (orange), RO (1982-2015)'
for y = startyr,endyr do begin &$
  ;yr2 = y+1  &$
  ;delS is P1-ET1-RO1=delS1, need to make this one more flexible.
  ;ifile = file_search(data_dir+STRING(FORMAT='(''FLDAS'',I4.4,''.nc'')',y)) &$
  ;VOI = 'delS' &$ 
  ;temp = get_nc(VOI, ifile) &$
  ;delS[*,*,y-startyr] = temp &$
  
  ;read in the annual average file generated with CDO
  ifile2 = file_search(data_dir+STRING(FORMAT='(''FLDAS'',I4.4,''.nc'')',y)) &$
  VOI = 'SM_tavg' &$ 
  temp = get_nc(VOI, ifile2) &$
  SM[*,*,y-startyr] = temp &$
  
  VOI = 'Rainf_f_tavg' &$
  temp = get_nc(VOI, ifile2) &$
  P[*,*,y-startyr] = temp &$
  
  VOI = 'Evap_tavg' &$
  temp = get_nc(VOI, ifile2) &$
  ET[*,*,y-startyr] = temp &$
    
  VOI = 'RO_tavg' &$
  temp = get_nc(VOI, ifile2) &$
  RO[*,*,y-startyr] = temp &$
    
  VOI = 'RO_tavg' &$
  temp = get_nc(VOI, ifile2) &$
  RO[*,*,y-startyr] = temp &$
  
endfor

P(where(P lt -999))=!values.f_nan
ET(where(ET lt -999))=!values.f_nan
RO(where(RO lt -999))=!values.f_nan
SM(where(SM lt -999))=!values.f_nan

;congo mask
mask35 = rebin(mask,nx,ny,nyrs)

;;gotta check the yemen results
ymask = fltarr(nx,ny)
ofile = '/home/almcnall/yemen_mask_294x348V2.bin'
openr,1,ofile
readu,1,ymask
close,1
ymask35 = rebin(ymask,nx,ny,nyrs)
cmask35 = rebin(cmask,nx,ny,nyrs)

ROI = cmask35



;;;show time series and cummulative relationship for these P, ET, RO
Pavg = mean(mean(p*ROI,dimension=1, /nan), dimension=1, /nan)
Eavg = mean(mean(ET*ROI,dimension=1, /nan), dimension=1, /nan)
Qavg = mean(mean(RO*ROI,dimension=1, /nan), dimension=1, /nan)
Savg = mean(mean(SM*ROI,dimension=1, /nan), dimension=1, /nan)

delS = Savg[1:33]-Savg[0:32]
resid = Pavg-(Eavg+Qavg)
p1 = plot(delS, layout = [1,2,1], title = 'Noah change SM')
p1 = plot(resid[1:33], 'b', layout = [1,2,2], /current, title = 'P-(ET+RO)')
p1 = plot(delS, resid[1:33], '*');yemen starts with one
p1 = plot(delS, resid[0:33], '*');EA with zero
;does this shift have to do with their water yrs?

print, r_correlate(delS, resid[1:33]); west yemen = 0.64, East Africa (no congo) = 0.54, yemen needs a lag, africa doesn't...why
print, r_correlate(delS, resid[0:32]); East Africa (no congo) = 0.54, yemen needs a lag, africa doesn't...why

p1 = plot(Pavg, thick=2)
p2 = plot(Eavg, 'b', /overplot)
p3 = plot(Qavg, 'orange', /overplot)
p4 = plot(Qavg+Eavg, 'r', /overplot)
p5 = plot(Savg/100000, 'c', /overplot)
p4.title = 'P(black), ET(blue), RO(orange), RO+ET(red) Congo 1982-2015'

p1 = plot(Eavg+Qavg, Savg, '*')
  print, r_correlate(Eavg+Qavg, Savg) ;west yemen = 0.67, East Africa (no congo) = 0.91
p1 = plot(Pavg, Savg, 'b*',/overplot)
   print, r_correlate(Pavg, Savg); west yemen = 0.54, East Africa (no congo) = 0.65
   print, r_correlate(Pavg, Eavg); west yemen = 0.93, East Africa (no congo) = 0.76
   print, r_correlate(Pavg, Qavg); west yemen = 0.56, East Africa (no congo) = 0.62







;then i want to agregate different sets. I could do that in a loop I guess. Oh man i don't want to do this!
;not enough coffee in the world!
P2 = fltarr(nx, ny, nyrs)
RO2 = fltarr(nx, ny, nyrs)
ET2 = fltarr(nx, ny, nyrs)
SM2 = fltarr(nx, ny, nyrs)

;make 2 yr precip and other totals. Do these balance
for y = 1,nyrs-1 do begin &$
  P2[*,*,y-1] = total(P[*,*,y-1:y], 3) &$
  ET2[*,*,y-1] = total(ET[*,*,y-1:y], 3) &$
  RO2[*,*,y-1] = total(RO[*,*,y-1:y], 3) &$
  SM2[*,*,y-1] = total(SM[*,*,y-1:y], 3) &$
endfor


del2 = P2-ET2-RO2
dSM = SM[*,*,1:nyrs-1]-SM[*,*,0:nyrs-2]


delS(where(delS le -10)) = !values.f_nan

;one year balance
;2015-2014 = 33-22
temp1= image(dSM[*,*,32], rgb_table=66, title = 'P-ET-RO')
temp1.min_value=-0.2
temp1.max_value=0.2
c=colorbar()

;1. what is the average delSM?
temp = image(mean(delS,dimension=3, /nan)*10000000, rgb_table=66)
c=colorbar()
temp.min_value=-5
temp.max_value=5

temp2 = image(delS[*,*,33]*100000, rgb_table=66, title = 'delS')
temp2.min_value=-0.5
temp2.max_value=0.5
c=colorbar()


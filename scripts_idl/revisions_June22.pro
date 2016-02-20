;these are notes for the revisions:
; associated with which script?
; ECV_eval_paper.pro and 
;HELP, VICCUBE, ECVCUBE, NOAHCUBE, NOAHCUBE_ET, VICCUBE_ET,NOAHCUBE_P, VICCUBE_P, NDVIcube2
HELP, VICCUBE, ECVCUBE, NOAHCUBE,NOAHCUBE_P, VICCUBE_P, NDVIcube2

;time series plots for the different regions of confidence..
;this will get avg at each pixel. then can i std this?
;why do i have 1992 hard coded in here? 
M2S_ECV = mean(ecvcube[*,*,2:8,startyr-1982:31],dimension=3,/nan) & help, M2S_ECV
M2S_NOH = mean(noahcube[*,*,2:8,startyr-1982:31],dimension=3,/nan)
M2S_NDV = mean(ndvicube2[*,*,2:8,startyr-1982:31],dimension=3,/nan)
M2S_VIC = mean(viccube[*,*,2:8,startyr-1982:31],dimension=3,/nan) & help, m2s_vic
M2S_P = mean(noahcube_P[*,*,2:8,startyr-1982:31],dimension=3,/nan) & help, m2s_p

;make a monthly average for plottting NDVI, Rainfall and SM
mw_clim = mean(ecvcube[*,*,*,1992-startyr:31],dimension=4,/nan)
pr_clim = mean(noahcube_p[*,*,*,1992-startyr:31],dimension=4,/nan)
vg_clim = mean(ndvicube2[*,*,*,1992-startyr:31],dimension=4,/nan)
nh_clim = mean(noahcube[*,*,*,1992-startyr:31],dimension=4,/nan)
vc_clim = mean(viccube[*,*,*,1992-startyr:31],dimension=4,/nan)


help, mw_clim, pr_clim, vg_clim, nh_clim, vc_clim

;is this the same thing as in my seasonal z-score? yes, but that does 3-monthly
ST_MW = M2S_ECV*!values.f_nan & help, ST_MW
ST_NOH = M2S_ECV*!values.f_nan & help, ST_NOH
ST_NDV = M2S_ECV*!values.f_nan & help, ST_NDV
ST_VIC = M2S_ECV*!values.f_nan & help, ST_VIC
ST_P = M2S_ECV*!values.f_nan & help, ST_P

for X = 0, NX-1 do begin &$
  for Y = 0, NY-1 do begin &$
  ST_MW[X,Y,*]  = standardize(reform(M2S_ECV[X,Y,*],1,nyrs)) &$
  ST_NOH[X,Y,*] = standardize(reform(M2S_NOH[X,Y,*],1,nyrs)) &$
  ST_NDV[X,Y,*] = standardize(reform(M2S_NDV[X,Y,*],1,nyrs)) &$
  ST_VIC[X,Y,*] = standardize(reform(M2S_VIC[X,Y,*],1,nyrs)) &$
  ST_P[X,Y,*] = standardize(reform(M2S_P[X,Y,*],1,nyrs)) &$

  endfor &$
endfor

;now pull timeseries of interest
;Mpala Kenya:
mxind = FLOOR( (36.8701 - map_ulx)/ 0.25)
myind = FLOOR( (0.4856 - map_lry) / 0.25)

mxind = FLOOR( (37 - map_ulx)/ 0.25)
myind = FLOOR( (0.3 - map_lry) / 0.25)

;Adwa, tigray region (14,39.4) NDVI has higher freq variation that soil moisture here
txind = FLOOR( (39 - map_ulx)/ 0.25)
tyind = FLOOR( (14 - map_lry) / 0.25)

;Sheka (dense veg), veg is prob not water limited here so anti-correlation 
;makes more sense. it was even significant neg corr (-0.2) when lagged, I think
sxind = FLOOR( (35.46 - map_ulx)/ 0.25)
syind = FLOOR( (8.8 - map_lry) / 0.25);9.5 west welga
print, ST_MW[sxind,syind,*], gvf[sxind,syind]

;Bale
bxind = FLOOR( (39 - map_ulx)/ 0.25)
byind = FLOOR( (7 - map_lry) / 0.25)

;Yirol, South Sudan
yxind = FLOOR( (30.26 - map_ulx)/ 0.25)
yyind = FLOOR( (6.6 - map_lry) / 0.25)

;where was this?
hxind = FLOOR( (39.4 - map_ulx)/ 0.25)
hyind = FLOOR( (14 - map_lry) / 0.25)

;GVF map from ECV_eval paper
test = gvf  & help, test
test[mxind-1:mxind+1,myind-1:myind+1]=2
test[txind-1:txind+1,tyind-1:tyind+1]=2
test[sxind-1:sxind+1,syind-1:syind+1]=2

;composite map (D) from ECV_eval
E = D
e[mxind-1:mxind+1,myind-1:myind+1]=2
e[txind-1:txind+1,tyind-1:tyind+1]=2
e[sxind-1:sxind+1,syind-1:syind+1]=2
;;;;;;;;;;;;;;;;;;composite map;;;;;;;;;;;
ncolors=8
;p1 = image(congrid(test, NX*3, NY*3), image_dimensions=[nx/4,ny/4], $
;  image_location=[map_ulx+0.25,map_lry+0.5],RGB_TABLE=53, layout=[2,1,1])  &$
p1 = image(congrid(e*land25, NX*3, NY*3), image_dimensions=[nx/4,ny/4], $
 image_location=[map_ulx+0.25,map_lry+0.5],RGB_TABLE=64, layout=[2,1,1], /current)  &$
  p1.min_value=0.1
p1.max_value=0.9
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  ;rgbdump[*,255] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  rgbdump[*,0] = [255,255,255] &$
  rgbdump[*,255] = [255,0,255] &$
  p1.rgb_table = rgbdump
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
      ;title = 'green vegetation fraction',font_size=20)
      title = 'average correlation',font_size=20)
  shapefile = '/home/code/idl_user_contrib/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'

  m1 = MAP('Geographic',limit=[ea_lry+5,ea_ulx+7.5,ea_uly-5,ea_lrx], /overplot) &$
  p1.mapgrid.linestyle = 'none' &$
  p1.mapgrid.color = [255, 255, 255] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE =0 &$
  ;p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  m = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$

  t = TEXT(target=p1,38,0, 'MPALA',/DATA, FONT_SIZE=18)
  t = TEXT(target=p1,40,12, 'TIGRAY',/DATA, FONT_SIZE=18)
  t = TEXT(target=p1,36,8, 'ILLUBABOR',/DATA, FONT_SIZE=18)
  t = TEXT(target=p1,30,16, '(A)',/DATA, FONT_SIZE=18)
  
;;Plot the monthly clim and time series for these sites.
;;Figure 7. Mpala (M), Figure 8. Tigray (T), Figure 9. Illubidor (S)
x = sxind
y = syind

w = window(DIMENSIONS=[1500,1000])
p1 = plot(ST_MW[x,y,*], /current, thick=2,color='r',name = 'CCI-SM', layout = [1,2,1])
p2 = plot(ST_VIC[x,y,*], /overplot,thick=2,color='orange', name='VIC')
p3 = plot(ST_NOH[x,y,*], /overplot,thick=2,color='blue',name = 'NOAH')
p4 = plot(ST_NDV[x,y,*], /overplot,thick=1,color='green', name = 'NDVI')
;p5 = plot(ST_P[x,y,*], /overplot,thick=2,color='black', name = 'CHIRPS')
p1.xticklen=1
p1.xgridstyle=1
p1.xrange = [0,nyrs-1]
xticks = indgen(nyrs+1)+1992 & print, xticks
p1.xtickinterval = 1
p1.xTICKNAME = string(xticks)
!null = legend(target=[p1,p2,p3,p4,p5], position=[0.2,0.3], font_size=20, orientation=1, shadow=0)
p1.xminor=0
p1.yminor=0
p1.xtext_orientation=90
;p1.title = 'West Wellga, Ethiopia average Mar-Sept soil moisture and NDVI zscores (1992-2013) GVF='+string(gvf[x,y])+' R='+string(correlate(ST_MW[x,y,*], ST_NOH[x,y,*]))
p1.yrange=[-3,3]
p1.font_size=20
t = TEXT(target=p1, 0.5, -2.8, '(A) ',/DATA, FONT_SIZE=20)
p1.ytitle = 'standardized anomaly'
;;monthly clim
;MPALA, TIGRAY, BALE, SHEKA, Yirol

mos = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec']

;w = window(DIMENSIONS=[1500,600])
p1 = plot(standardize(reform(MW_clim[x,y,*],1,12)), /CURRENT, thick=2,color='r',name = 'CCI-SM', layout=[1,2,2])
p2 = plot(standardize(reform(VC_clim[x,y,*],1,12)), /overplot,thick=2,color='orange', name='VIC')
p3 = plot(standardize(reform(NH_clim[x,y,*], 1,12)), /overplot,thick=2,color='blue',name = 'NOAH')
p4 = plot(standardize(reform(VG_clim[x,y,*],1,12)), /overplot,thick=1,color='green', name = 'NDVI')
;p5 = plot(standardize(reform(PR_clim[x,y,*],1,12)), /overplot,thick=2,color='black', name = 'CHIRPS')
p1.xticklen=1
p1.xgridstyle=1
p1.xrange = [0,11]
xticks = indgen(11)
p1.xtickinterval = 1
p1.xTICKNAME = string(mos)
;!null = legend(target=[p1,p2,p3,p4,p5], position=[0.2,0.3], font_size=18)
p1.xminor=0
p1.yminor=0
;p1.title = 'West Wellga, Ethiopia std. average monthly NDVI, Precip and SM (1992-2013) GVF='+string(gvf[x,y])+' R='+string(correlate(MW_clim[x,y,*], NH_clim[x,y,*]))'
p1.yrange=[-3,3]
p1.font_size=20
t = TEXT(target=p1, 0.5, -2.8, '(B)',/DATA, FONT_SIZE=20)
p1.ytitle = 'standardized anomaly'





;compare the z-scores for the 2007 and 2009 examples
;vars from ECV_eval_paper
help, sZMWcube,sZCMcube,sZVGcube
YOI = 2009
yr= YOI - 1992
X = TXIND
Y = TYIND
PRINT, SZMWCUBE[X,Y,*,YR]
PRINT, SZCMCUBE[X,Y,*,YR]
PRINT, SZVGCUBE[X,Y,*,YR]

temp = image(test, min_value=0, rgb_table=4)

;MPALA, TIGRAY, BALE, SHEKA, Yirol
print, r_correlate(ST_MW[x,y,*], ST_NOH[x,y,*]);0.93,   0.25, 0.74, 0.67, 0.11 
print, r_correlate(ST_MW[x,y,*], ST_NDV[x,y,*]);0.70,  0.54, 0.51, 0.22, 0.03
print, r_correlate(ST_NOH[x,y,*], ST_NDV[x,y,*]);0.73,-0.31, 0.43, 0.17, 0.25

print, r_correlate(ST_MW[x,y,*], ST_P[x,y,*]);0.86,  0.39,   0.49, -0.5, 0.16
print, r_correlate(ST_VIC[x,y,*], ST_P[x,y,*]);0.77, 0.26, 0.63, 0.35, 0.62
print, r_correlate(ST_NOH[x,y,*], ST_P[x,y,*]);0.91, 0.61, 0.82, 0.35, 0.51
print, r_correlate(ST_NDV[x,y,*], ST_P[x,y,*]);0.83, 0.05, 0.24, -0.39, 0.18

print, r_correlate(ST_VIC[x,y,*], ST_NDV[x,y,*]);0.73, -0.3, 0.32, 0.19, 0.22
print, r_correlate(ST_MW[x,y,*], ST_VIC[x,y,*]);0.84, 0.07,  0.7, 0.6, 0.16
print, r_correlate(ST_NOH[x,y,*], ST_VIC[x,y,*]);0.83, 0.85, 0.9, 0.92, 0.6

;;print, correlation of raw, not anomalies
print, r_correlate(M2S_ECV[x,y,*], M2S_NOH[x,y,*]);0.65
print, r_correlate(ST_MW[x,y,*], ST_NDV[x,y,*]);
print, r_correlate(ST_NOH[x,y,*], ST_NDV[x,y,*]);0.78,-0.1, 0.43, 0.17, 0.25
;p1 = image(congrid(gvf, nx*3, ny*3),image_dimensions=[NX/4,NY/4], $
;  min_value=0.2,max_value=1, dimensions=[nx/100,ny/100],/overplot)


;;Agoufou 15.35400N    -1.47900W
;star = TEXT(38, 12, /DATA, '*', $
;  FONT_SIZE=25, FONT_STYLE='Bold', $
;  FONT_COLOR='white')
;  
;star = TEXT(35, 8, /DATA, '*', $
;    FONT_SIZE=25, FONT_STYLE='Bold', $
;    FONT_COLOR='white')
;
;;Wankama
;star = TEXT(2.7, 13.5, /DATA, '*', $
;  FONT_SIZE=42, FONT_STYLE='Bold', $
;  FONT_COLOR='white')
;;Mpala
;star = TEXT(39-1, 7-1, /DATA, '*', $
;  FONT_SIZE=25, FONT_STYLE='Bold', $
;  FONT_COLOR='white')
;;  ;Belefoungou-Top 9.79506     1.71450
;;  star = TEXT(1.7,9.8, /DATA, '*', $
;;       FONT_SIZE=42, FONT_STYLE='Bold', $
;;       FONT_COLOR='yellow')




VP = reform(VICCUBE_P, NX, NY, nyrs*nmos) & help,VP
NP = reform(NOAHCUBE_P, NX, NY, nyrs*nmos) & help,NP


VET = reform(VICCUBE_ET, NX, NY, nyrs*nmos) & help,VET
NET = reform(NOAHCUBE_ET, NX, NY, nyrs*nmos) & help,NET


VCM = reform(VICCUBE, NX, NY, nyrs*nmos) & help,VCM
NCM = reform(NOAHCUBE, NX, NY, nyrs*nmos) & help,NCM

ECV = reform(ECVCUBE, NX, NY, nyrs*nmos) & help,ECV

;plot time series of P/ET for VIC and NOAH

VPavg = mean(mean(VP,dimension=1,/NAN),dimension=1,/NAN)
NPavg = mean(mean(NP,dimension=1,/NAN),dimension=1,/NAN)

VEavg = mean(mean(VET,dimension=1,/NAN),dimension=1,/NAN)
NEavg = mean(mean(NET,dimension=1,/NAN),dimension=1,/NAN)

;they don't look that different to me...
p1 = plot(VEavg/VPavg, NEavg/NPavg, '*')
p1 = plot(NEavg/NPavg,/overplot,'b')

;map them
;East Africa WRSI/Noah window
ea_ulx = 22.  & ea_lrx = 51.35
ea_uly = 22.95  & ea_lry = -11.75

VETmap = mean(VET, dimension=3, /nan)
VPmap = mean(VP, dimension=3,/nan)

NETmap = mean(NET, dimension=3, /nan)
NPmap = mean(NP, dimension=3,/nan)
ncolors=12 ;10 for VIC v NOAH there is a funny hash pattern in VIC v Noah, maybe becasue of re-gridding
txt =  ['VICmean', 'NOAHmean', 'MWmean', 'VIC std', 'NOAH std', 'ECV std']
w = window(DIMENSIONS=[1400,900])
i = 3
;for i=0,5 do begin &$
  p1 = image(congrid(NPmap/30, NX*3, NY*3), image_dimensions=[nx/4,ny/4], $
  image_location=[ea_ulx+0.25,ea_lry+0.5],RGB_TABLE=55, /current, layout = [2,2,i+1])  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  ;rgbdump[*,255] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  rgbdump[*,0] = [190,190,190] &$
  ;rgbdump[*,255] = [190,190,190]
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  ;p1.title = string(i+1) &$
  ;p1.MAX_VALUE=1 &$
  ;p1.min_value=0.4 &$
  cb = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,font_size=24) &$
  m1 = MAP('Geographic',limit=[ea_lry,ea_ulx,ea_uly,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2) &$
  p1.title = 'NOAH P' &$
endfor

;are there places where NOAH MW is high but not VIC-NOAH
MW_NCM = cormap1[*,*,0] & help, MW_CM
MW_VCM =  cormap2[*,*,0]
  cormap3[x,y,*] = r_correlate(ZMW[x,y,*], ZVG[x,y,*]) &$

  cormap4[x,y,*] = r_correlate(ZVG[x,y,*], ZCM[x,y,*]) &$
  cormap5[x,y,*] = r_correlate(ZVG[x,y,*], ZCS[x,y,*]) &$
  cormap6[x,y,*] = r_correlate(ZCM[x,y,*], ZCS[x,y,*])
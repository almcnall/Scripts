;ok, so now i need to generate a z-score for the three month blocks
;if i break the yr up into 3month blocks i will have 4 periods per yr
;this code could be generalize dot produce 1 month or 3 month cubes but for now
;one month cubes are in ECV_eval and the 3 month cubes are here
;1/24/17 maybe i can update this script for chemonics needs...
;1/28/17 not recommended using zscores due to the non-normal distribution of the data, esp when rank is the goal
; see greg's method as an alternative...

;from ECV_eval_paper.pro, where does vmask come from? i think i start from 1992? these are the full 32 yrs
;NDVICUBE92 = NDVICUBE2[*,*,*,startyr-1982:endyr-1982]
HELP, VICCUBE, ECVCUBE, NOAHCUBE, NDVICUBE2; vmask defined below
dims = size(ecvcube, /dimensions)
nx = dims[0]
ny = dims[1]

;what is this stuff? maybe just reshaped
;HELP,  Y_ECVCUBE, Y_NOHCUBE, Y_NDVICUBE
;Y_NOAHCUBE =  Y_NOHCUBE
;dims = size(y_ecvcube, /dimensions)
;nx = dims[0]
;ny = dims[1]

HELP, SM01, SM02, smm3
dims = size(SM01, /dimensions)
nx = dims[0]
ny = dims[1]

;sZMAP_MW = fltarr(NX,NY,4,NYRS)*!values.f_nan
;sECV = fltarr(NX,NY,4,NYRS)*!values.f_nan
;
;sZMAP_CS = fltarr(NX,NY,4,NYRS)*!values.f_nan
;sVIC = fltarr(NX,NY,4,NYRS)*!values.f_nan
;
;sZMAP_VG = fltarr(NX,NY,4,NYRS)*!values.f_nan
;sNDV = fltarr(NX,NY,4,NYRS)*!values.f_nan

;JFM, AMJ, JAS, OND
sZMAP_CM01 = fltarr(NX,NY,4,NYRS)*!values.f_nan
sNOH01 = fltarr(NX,NY,4,NYRS)*!values.f_nan

sZMAP_CM02 = fltarr(NX,NY,4,NYRS)*!values.f_nan
sNOH02 = fltarr(NX,NY,4,NYRS)*!values.f_nan

sZMAP_CM = fltarr(NX,NY,4,NYRS)*!values.f_nan
sNOH = fltarr(NX,NY,4,NYRS)*!values.f_nan

NOAHCUBE01 = SM01
NOAHCUBE02 = SM02
NOAHCUBE = SMM3

sNOH01[*,*,0,*] = mean(NOAHCUBE01[*,*,0:2,startyr-1982:endyr-1982],dimension=3,/nan)
sNOH01[*,*,1,*] = mean(NOAHCUBE01[*,*,3:5,startyr-1982:endyr-1982],dimension=3,/nan)
sNOH01[*,*,2,*] = mean(NOAHCUBE01[*,*,6:8,startyr-1982:endyr-1982],dimension=3,/nan)
sNOH01[*,*,3,*] = mean(NOAHCUBE01[*,*,9:11,startyr-1982:endyr-1982],dimension=3,/nan)

sNOH02[*,*,0,*] = mean(NOAHCUBE02[*,*,0:2,startyr-1982:endyr-1982],dimension=3,/nan)
sNOH02[*,*,1,*] = mean(NOAHCUBE02[*,*,3:5,startyr-1982:endyr-1982],dimension=3,/nan)
sNOH02[*,*,2,*] = mean(NOAHCUBE02[*,*,6:8,startyr-1982:endyr-1982],dimension=3,/nan)
sNOH02[*,*,3,*] = mean(NOAHCUBE02[*,*,9:11,startyr-1982:endyr-1982],dimension=3,/nan)

;all 4 layers
sNOH[*,*,0,*] = mean(NOAHCUBE[*,*,0:2,startyr-1982:endyr-1982],dimension=3,/nan)
sNOH[*,*,1,*] = mean(NOAHCUBE[*,*,3:5,startyr-1982:endyr-1982],dimension=3,/nan)
sNOH[*,*,2,*] = mean(NOAHCUBE[*,*,6:8,startyr-1982:endyr-1982],dimension=3,/nan)
sNOH[*,*,3,*] = mean(NOAHCUBE[*,*,9:11,startyr-1982:endyr-1982],dimension=3,/nan)

delvar, SM01, SM02, SM03, SM04, SMM3, NOAHCUBE01, NOAHCUBE02, NOAHCUBE
;sNDV[*,*,0,*] = mean(NDVICUBE2[*,*,0:2,startyr-1982:endyr-1982],dimension=3,/nan)
;sNDV[*,*,1,*] = mean(NDVICUBE2[*,*,3:5,startyr-1982:endyr-1982],dimension=3,/nan)
;sNDV[*,*,2,*] = mean(NDVICUBE2[*,*,6:8,startyr-1982:endyr-1982],dimension=3,/nan)
;sNDV[*,*,3,*] = mean(NDVICUBE2[*,*,9:11,startyr-1982:endyr-1982],dimension=3,/nan)
;
;sECV[*,*,0,*] = mean(ECVCUBE[*,*,0:2,startyr-1982:endyr-1982],dimension=3,/nan)
;sECV[*,*,1,*] = mean(ECVCUBE[*,*,3:5,startyr-1982:endyr-1982],dimension=3,/nan)
;sECV[*,*,2,*] = mean(ECVCUBE[*,*,6:8,startyr-1982:endyr-1982],dimension=3,/nan)
;sECV[*,*,3,*] = mean(ECVCUBE[*,*,9:11,startyr-1982:endyr-1982],dimension=3,/nan)
;
;sVIC[*,*,0,*] = mean(VICCUBE[*,*,0:2,startyr-1982:endyr-1982],dimension=3,/nan)
;sVIC[*,*,1,*] = mean(VICCUBE[*,*,3:5,startyr-1982:endyr-1982],dimension=3,/nan)
;sVIC[*,*,2,*] = mean(VICCUBE[*,*,6:8,startyr-1982:endyr-1982],dimension=3,/nan)
;sVIC[*,*,3,*] = mean(VICCUBE[*,*,9:11,startyr-1982:endyr-1982],dimension=3,/nan)

;;;;;;;4 season cubes of seasonal z-scores;;;;;;;;;;
for X = 0,NX-1 do begin &$
  for Y = 0,NY-1 do begin &$
  ;sZMAP_CS[x,y,*,*] = standardize(reform(sVIC[X,Y,*,*])) &$
  sZMAP_CM01[x,y,*,*] = standardize(reform(sNOH01[X,Y,*,*])) &$
  sZMAP_CM02[x,y,*,*] = standardize(reform(sNOH02[X,Y,*,*])) &$
  sZMAP_CM[x,y,*,*] = standardize(reform(sNOH[X,Y,*,*])) &$

  ;sZMAP_VG[x,y,*,*] = standardize(reform(sNDV[X,Y,*,*])) &$
endfor &$
endfor

;tidy up maybe not crash...
delvar, sNOAH01, SNOAH02, sNOH

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;MICROWAVE has to be done 'by hand' since there are missing values, these are wrong...
AVGMW = FLTARR(NX,NY,4)*!values.f_nan
STDMW = FLTARR(NX,NY,4)*!values.f_nan

FOR M = 0, 4 -1 DO AVGMW[*,*,M] = MEAN(sECV[*,*,M,*], DIMENSION=4, /NAN)
FOR M = 0, 4 -1 DO STDMW[*,*,M] = STDDEV(sECV[*,*,M,*], DIMENSION=4, /NAN)

sZMAP_MW = fltarr(NX,NY,4,NYRS)*!values.f_nan
;Standardize for each month
FOR Y = 0, NYRS-1 DO BEGIN &$
  FOR M = 0,4-1 DO BEGIN &$
  sZMAP_MW[*,*,M,Y] = (sECV[*,*,M,Y]-AVGMW[*,*,M])/STDMW[*,*,M] &$
ENDFOR &$
ENDFOR

;might as well check out the correlations while I am here:
sZMW = reform(szmap_mw,NX,NY,nyrs*4)
sZCS = reform(szmap_cs,NX,NY,nyrs*4)
sZCM = reform(szmap_cm,NX,NY,nyrs*4)
sZVG = reform(szmap_vg,NX,NY,nyrs*4)

;p1 =plot(szmw[mxind,myind,*],'r', /overplot)
;p1 =plot(szcm[mxind,myind,*],'b', /overplot)
;p1 =plot(szcs[mxind,myind,*],'c', /overplot)
;p1 =plot(szvg[mxind,myind,*],'g', /overplot)

;PIXELWISE CORRELATION for full time series
cormap11 = fltarr(nx,ny,2)*!values.f_nan
cormap12 = fltarr(nx,ny,2)*!values.f_nan
cormap13 = fltarr(nx,ny,2)*!values.f_nan
cormap14 = fltarr(nx,ny,2)*!values.f_nan
cormap15 = fltarr(nx,ny,2)*!values.f_nan
cormap16 = fltarr(nx,ny,2)*!values.f_nan

for x = 0,NX-1 do begin &$
  for y =0, NY-1 do begin &$
  cormap11[x,y,*] = r_correlate(sZMW[x,y,*], sZCM[x,y,*]) &$
  cormap12[x,y,*] = r_correlate(sZMW[x,y,*], sZCS[x,y,*]) &$
  cormap13[x,y,*] = r_correlate(sZMW[x,y,*], sZVG[x,y,*]) &$

  cormap14[x,y,*] = r_correlate(sZVG[x,y,*], sZCM[x,y,*]) &$
  cormap15[x,y,*] = r_correlate(sZVG[x,y,*], sZCS[x,y,*]) &$
  cormap16[x,y,*] = r_correlate(sZCM[x,y,*], sZCS[x,y,*]) &$
endfor &$
endfor

sig1 = cormap11[*,*,1]
sig1(where(sig1 lt 0.05, complement=other)) = 1
sig1(other)=!values.f_nan

sig2 = cormap12[*,*,1]
sig2(where(sig2 lt 0.05, complement=other)) = 1
sig2(other)=!values.f_nan

sig3 = cormap13[*,*,1]
sig3(where(sig3 lt 0.05, complement=other)) = 1
sig3(other)=!values.f_nan

sig4 = cormap14[*,*,1]
sig4(where(sig4 lt 0.05, complement=other)) = 1
sig4(other)=!values.f_nan

sig5 = cormap15[*,*,1]
sig5(where(sig5 lt 0.05, complement=other)) = 1
sig5(other)=!values.f_nan

sig6 = cormap16[*,*,1]
sig6(where(sig6 lt 0.05, complement=other)) = 1
sig6(other)=!values.f_nan

;whats not working here?
;make a vic mask, WHY VIC NOT NOAH? VIC HAS WEIRD SPECILES
vmask = fltarr(117,139)*!values.f_nan
vmask( where(finite(sZCM[*,*,0]),complement=other))=1
vmask(other)=!values.f_nan

;and veg mask for the NDVI correlations.
vegmask = Szmap_vg[*,*,0,0]*!values.f_nan
vegmask(where(finite(Szmap_vg), complement=other))=1
vegmask(other)=!values.f_nan

;make an matrix with the corr and sig values for faster mapping:
c = fltarr(NX, NY, 2, 6)
c[*,*,*,0] = [ [[cormap11[*,*,0]*land25]], [[sig1]]  ]
c[*,*,*,1] = [ [[cormap12[*,*,0]*land25]], [[sig2]]  ]
c[*,*,*,2] = [ [[cormap13[*,*,0]*land25*vegmask]], [[sig3]]  ]
c[*,*,*,3] = [ [[cormap14[*,*,0]*land25*vegmask]], [[sig4]]  ]
c[*,*,*,4] = [ [[cormap15[*,*,0]*land25*vegmask]], [[sig5]]  ]
c[*,*,*,5] = [ [[cormap16[*,*,0]*land25*vmask]], [[sig6]]  ]

;;then move over to ECV_eval_paper.pro


;;;;;;;;;the monthly version of what is above, from ECV_eval_paper. pro;;;;;;;;;;;;;;;;;;;;;
ZMAP_MW = fltarr(NX,NY,12,NYRS)*!values.f_nan
ZMAP_CS = fltarr(NX,NY,12,NYRS)*!values.f_nan
ZMAP_CM = fltarr(NX,NY,12,NYRS)*!values.f_nan
ZMAP_VG = fltarr(NX,NY,12,NYRS)*!values.f_nan
;there might be too many missing values for this to work with the CCI_SM.
;my other method might work better since i can /NAN
for X = 0,NX-1 do begin &$
  for Y = 0,NY-1 do begin &$
  ZMAP_CS[x,y,*,*] = standardize(reform(VICCUBE[X,Y,*,startyr-1982:endyr-1982])) &$
  ZMAP_CM[x,y,*,*] = standardize(reform(NOAHCUBE[X,Y,*,startyr-1982:endyr-1982])) &$
  ZMAP_VG[x,y,*,*] = standardize(reform(NDVICUBE2[X,Y,*,startyr-1982:endyr-1982])) &$
endfor &$
endfor

;;MICROWAVE has to be done 'by hand' since there are missing values.
AVGMW = FLTARR(NX,NY,12)*!values.f_nan
STDMW = FLTARR(NX,NY,12)*!values.f_nan

FOR M = 0, 12 -1 DO AVGMW[*,*,M] = MEAN(ECVCUBE[*,*,M,startyr-1982:endyr-1982], DIMENSION=4, /NAN)
FOR M = 0, 12 -1 DO STDMW[*,*,M] = STDDEV(ECVCUBE[*,*,M,startyr-1982:endyr-1982], DIMENSION=4, /NAN)

ZMAP_MW = fltarr(NX,NY,12,NYRS)*!values.f_nan
;Standardize for each month, fix this.
FOR Y = 0, NYRS-1 DO BEGIN &$
  FOR M = 0,12-1 DO BEGIN &$
  ZMAP_MW[*,*,M,Y] = (ECVCUBE[*,*,M,(startyr+y)-1982]-AVGMW[*,*,M])/STDMW[*,*,M] & print, (startyr+y)-1982 &$
ENDFOR &$
ENDFOR

ZMW = reform(zmap_mw,NX,NY,nyrs*12)
ZCS = reform(zmap_cs,NX,NY,nyrs*12)
ZCM = reform(zmap_cm,NX,NY,nyrs*12)
ZVG = reform(zmap_vg,NX,NY,nyrs*12)
;
odir = '/home/sandbox/people/mcnally/JAGdata4figs/ZSCORE_MO/'
;;
;ofile = odir+'zcore_by_month4pixelcorrelation_CCI_117.139.264.bin'
;openw,1,ofile
;writeu,1,reverse(ZMW,2)
;close,1
;
;ofile = odir+'zcore_by_month4pixelcorrelation_VIC01_117.139.264.bin'
;openw,1,ofile
;writeu,1,reverse(ZCS,2)
;close,1
;
;ofile = odir+'zcore_by_month4pixelcorrelation_NOAH01_117.139.264.bin'
;openw,1,ofile
;writeu,1,reverse(ZCM,2)
;close,1
;
;ofile = odir+'zcore_by_month4pixelcorrelation_NDVI_117.139.264.bin'
;openw,1,ofile
;writeu,1,reverse(ZVG,2)
;close,1

p1 =plot(zmw[mxind,myind,*],'r', /overplot)
p1 =plot(zcm[mxind,myind,*],'b', /overplot)


;PIXELWISE CORRELATION for full time series
cormap1 = fltarr(nx,ny,2)*!values.f_nan
cormap2 = fltarr(nx,ny,2)*!values.f_nan
cormap3 = fltarr(nx,ny,2)*!values.f_nan
cormap4 = fltarr(nx,ny,2)*!values.f_nan
cormap5 = fltarr(nx,ny,2)*!values.f_nan
cormap6 = fltarr(nx,ny,2)*!values.f_nan

for x = 0,NX-1 do begin &$
  for y =0, NY-1 do begin &$
  tmp = where(finite(ZVG[x,y,*]),count) &$
  if count eq 0 then continue &$
  cormap1[x,y,*] = r_correlate(ZMW[x,y,*], ZCM[x,y,*]) &$
  cormap2[x,y,*] = r_correlate(ZMW[x,y,*], ZCS[x,y,*]) &$
  cormap3[x,y,*] = r_correlate(ZMW[x,y,*], ZVG[x,y,*]) &$

  cormap4[x,y,*] = r_correlate(ZVG[x,y,*], ZCM[x,y,*]) &$
  cormap5[x,y,*] = r_correlate(ZVG[x,y,*], ZCS[x,y,*]) &$
  cormap6[x,y,*] = r_correlate(ZCM[x,y,*], ZCS[x,y,*]) &$
endfor &$
endfor

;;write out for ENVI play:
;ofile = odir+'corr_NOAH_VIC_117.139.264.bin'
;openw,1,ofile
;writeu,1,reverse(cormap6[*,*,0],2)
;close,1

;ofile = odir+'corr_NOAH_CCI_117.139.264.bin'
;openw,1,ofile
;writeu,1,reverse(cormap1[*,*,0],2)
;close,1
;
;ofile = odir+'corr_NOAH_NDVI_117.139.264.bin'
;openw,1,ofile
;writeu,1,reverse(cormap4[*,*,0],2)
;close,1
;
;ofile = odir+'corr_CCI_NDVI_117.139.264.bin'
;openw,1,ofile
;writeu,1,reverse(cormap3[*,*,0],2)
;close,1

sig1 = cormap1[*,*,1]
sig1(where(sig1 lt 0.05, complement=other)) = 1
sig1(other)=!values.f_nan

sig2 = cormap2[*,*,1]
sig2(where(sig2 lt 0.05, complement=other)) = 1
sig2(other)=!values.f_nan

sig3 = cormap3[*,*,1]
sig3(where(sig3 lt 0.05, complement=other)) = 1
sig3(other)=!values.f_nan

sig4 = cormap4[*,*,1]
sig4(where(sig4 lt 0.05, complement=other)) = 1
sig4(other)=!values.f_nan

sig5 = cormap5[*,*,1]
sig5(where(sig5 lt 0.05, complement=other)) = 1
sig5(other)=!values.f_nan

sig6 = cormap6[*,*,1]
sig6(where(sig6 lt 0.05, complement=other)) = 1
sig6(other)=!values.f_nan

;make a vic mask
vmask = fltarr(117,139)*!values.f_nan
vmask( where(finite(ZCS[*,*,0]),complement=other))=1
vmask(other)=!values.f_nan

;and veg mask for the NDVI correlations.
vegmask = zmap_vg[*,*,0,0]*!values.f_nan
vegmask(where(finite(zmap_vg), complement=other))=1
vegmask(other)=!values.f_nan


;make an matrix with the corr and sig values for faster mapping:
c = fltarr(NX, NY, 2, 6)
c[*,*,*,0] = [ [[cormap1[*,*,0]*land25]], [[sig1]]  ]
c[*,*,*,1] = [ [[cormap2[*,*,0]*land25]], [[sig2]]  ]
c[*,*,*,2] = [ [[cormap3[*,*,0]*land25]], [[sig3]]  ]
c[*,*,*,3] = [ [[cormap4[*,*,0]*land25]], [[sig4]]  ]
c[*,*,*,4] = [ [[cormap5[*,*,0]*land25]], [[sig5]]  ]
c[*,*,*,5] = [ [[cormap6[*,*,0]*land25]], [[sig6]]  ]


;East Africa WRSI/Noah window
ea_ulx = 22.  & ea_lrx = 51.35
ea_uly = 22.95  & ea_lry = -11.75

ncolors=4 ;10 for VIC v NOAH there is a funny hash pattern in VIC v Noah, maybe becasue of re-gridding

w = window(DIMENSIONS=[1400,900])
;i=0
for i=0,4 do begin &$
p1 = image(congrid(c[*,*,0,i]*c[*,*,1,i], NX*3, NY*3), image_dimensions=[nx/4,ny/4], $
  image_location=[ea_ulx+0.25,ea_lry+0.5],RGB_TABLE=55, /current, layout = [3,2,i+1])  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  ;rgbdump[*,255] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  rgbdump[*,0] = [190,190,190] &$
  ;rgbdump[*,255] = [190,190,190]
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.title = string(i+1) &$
  p1.MAX_VALUE=0.8 &$
  p1.min_value=0 &$
  cb = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,font_size=12) &$
  m1 = MAP('Geographic',limit=[ea_lry,ea_ulx,ea_uly,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2) &$
  endfor
  P1.TITLE='VIC v NOAH'


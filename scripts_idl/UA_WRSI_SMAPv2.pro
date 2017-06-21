pro UA_WRSI_SMAP
;modified from RFE_quantiles_SOS
;6/18/14 this code includes my rainfall simulations to quantify the uncertainty associated with ubRFE errors and WRSI errors.
;some of this was shown in Verdin and Klaver (2002), hopefully my results agree
;I was thinking of testing the simulations on 2002 and 2005 since they were obvious wet and dry years in Senegal
; 06/25/14 
; 07/25/14 moved one of the other UA scripts here. 
; 08/19/14 trying to come up with a story and make sure i went though appropriate steps.
; 10/17/14 regress SM(all) vs WRSI(all)...this might be big. Might as well do P too.
;
;****simulate some rainfall timeseries*******does this start 2001
;pick a random number between +/- 20% and modify the rainfall for a given day by that amount
;2002 and 2005 to see what happens to Senegal
;I want the new range to be from 0.2 to 1.2, width =1, shift by 0.2

;;;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)


;make the wrsi color table available
wkdir = '/home/source/mcnally/scripts_idl/'
cd, wkdir
.compile make_wrsi_cmap.pro

;*********************************************************************
;open and read in the rainfall dekads
ifile = file_search('/home/sandbox/people/mcnally/ubRFE04.19.2013/dekads/sahel/2*.img');these are 2001-2012

nx = 720
ny = 350
nz = n_elements(ifile);432 = 12*36

ingrid = fltarr(nx,ny)
rcube = fltarr(nx,ny,nz)

;make a big stack and then reform...
for i = 0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[i]  &$
  readu,1,ingrid &$
  close,1 &$
  
  rcube[*,*,i] = ingrid &$
endfor

;why is stdev multiplied by 0.5? why was i looking at rain std and var?
;RSTDEV_05 = STDDEV(RCUBE,dimension=3, /NAN)*0.5
;RVAR = VARIANCE(RCUBE,dimension=3,/NAN)

byyear = reform(rcube,nx,ny,36,12)

;;;;;regress this against WRSI for revisions;;;;;
;well correlated at northern reaches and highest coeff in north central
nx = 720
ny = 350
nz = 11

rgrid = fltarr(nx,ny,nz)

rfile = file_search('/home/chg-mcnally/EOS_WRSI_ubRFE2001_2012_staticSOS.img')
openr,1,rfile
readu,1,rgrid
close,1

;plot Rgrid
year = string(indgen(11)+2001) & help, year
ncolors=256
for i=0,11-1 do begin &$
  p1 = image(byte(rgrid[*,0:249,i]) ,layout=[3,4,i+1], image_dimensions=[72.0,25.0], image_location=[-20,-5], $
  dimensions=[nx,750], RGB_TABLE =make_wrsi_cmap(),/current) &$
  ;c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [200,200,200]&$
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.title = year[i] &$
  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 6 &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_show = 0 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)&$
endfor


;get the annual totals 2001-2011
rain_tot = total(byyear[*,*,*,0:10],3,/nan)

cormap_r = fltarr(nx,ny)
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    cormap_r[x,y]=regress(reform(rain_tot[x,y,*]),reform(rgrid[x,y,*])) &$
  endfor &$
endfor
temp = image(cormap_r,rgb_table=20)
c = COLORBAR(target=p1,ORIENTATION=0, font_size=20)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;PERTURB 2002;;;;;;;;;;;;;
yr2002 = byyear[*,*,*,1]
pert = 0.2 ;assume 20% error 
seed = 6
;how do i make this a random number between 1.2 and 0.8 (+/-20%)?
E = randomu(seed,100*36)*0.4+0.8
sims02 = fltarr(nx,ny,36,100)

count = 0
for y = 0,100-1 do begin &$
  for d = 0, 36-1 do begin &$
       sims02[*,*,d,y] = yr2002[*,*,d]*E[count] &$
       count++ &$
  endfor &$
endfor

;nx,ny,dek,yr is an acceptable format. Then i won't have to re-form
for i = 0,100-1 do begin &$
  temp = plot(sims05[wxind,wyind,*,i], /overplot) &$
endfor

;;;;how does PAW itself relate to WRSI outputs?;;;;;;;;
ifile = file_search('/home/sandbox/people/mcnally/SMAP_JHM_PAPER/wrsiPAW_grid_2001_2012_750.350.img') & print, ifile; this has 22 values not 36
;is this the same as this 
;rfile = file_search('/home/chg-mcnally/sahel_ubRFE_PAW36_2001-2012_LGP_WHC_PET.img') & print, rfile ;is this the one i used for regress?

nx = 720
ny = 350
paw = fltarr(nx,ny,22,12)
openr,1,ifile
readu,1,paw
close,1
tot_paw = total(paw,3,/nan)
;stdmap = stddev(paw[*,*,0:10,*],dimension=3)
;make a histogram of the rpaw data
;pdf = HISTOGRAM(paw(where(paw gt 0)), binsize=1, locations=xbin)
;p1 = plot(xbin,pdf)
;
;pdf = HISTOGRAM(sm0xgrid(where(sm0xgrid gt 0.3)),binsize=0.01, locations=xbin)
;p1 = plot(xbin,pdf).

cormap_r = fltarr(nx,ny)
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
  cormap_r[x,y]=regress(reform(tot_paw[x,y,0:10]),reform(rgrid[x,y,*])) &$
endfor &$
endfor
meanpaw = mean(tot_paw[*,*,0:10],dimension=3,/nan)
temp = image(meanpaw,rgb_table=20)
c = COLORBAR(target=p1,ORIENTATION=0, font_size=20)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;how do the perturbed inputs correlate/regress w/ resulting outputs
sims02 = fltarr(nx,ny,36,100)
ifile = file_search('/home/sandbox/people/mcnally/SMAP_JHM_PAPER/ubfe_2002_sim_720.350.36.100.bin') & print, ifile
openr,1,ifile
readu,1,sims02
close,1
tot02 = total(sims02,3,/nan)
;p1= plot(tot02[wxind,wyind,*], /overplot)

;;;;read in the WRSI02 rainfall sims to correlate and regress;;;;;;
nx = 720
ny = 350
ifile = file_search('/home/sandbox/people/mcnally/SMAP_JHM_PAPER/wrsi_grid_2002_750.350.sim100.img')
wsim02 = fltarr(nx,ny,100)
openr,1,ifile
readu,1,wsim02
close,1

cormap_r = fltarr(nx,ny)
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
  cormap_r[x,y]=correlate(reform(tot02[x,y,*]),reform(wsim02[x,y,*])) &$
endfor &$
endfor
temp = image(cormap_r,rgb_table=20)
c = COLORBAR(target=p1,ORIENTATION=0, font_size=20)


;ofile = '/home/sandbox/people/mcnally/ubfe_2005_sim_720.350.36.100.bin'
;openw,1,ofile
;writeu,1,sims05
;close,1



;*****************************************************************************
;**********soil moisture simulation with the original data (not scaled)********
;lfile = file_search('/home/sandbox/people/mcnally/SMAP_JHM_PAPER/sm0x2grid_720.250.396_2001.2011.bin')
;use scaled data for regress coeff comparisons
lfile = file_search('/home/chg-mcnally/SM0X2_scaled4WRSI_720_350_396.img') & print, lfile

;typical file dimensions
nx = 720
ny = 350
nz = 431
yy = 250

SM0Xgrid = fltarr(nx,350,396)
;SM0Xgrid = fltarr(nx,yy,396)

openr,1,Lfile
readu,1,sm0xgrid
close,1

sm02cube = reform(sm0xgrid,nx,ny,36,11)
sm2002 = sm02cube[*,*,*,1]
seed = 6
E = randomu(seed,100*36)*0.4+0.8
simsSM02 = fltarr(nx,350,36,100)

;check and see how this gets read into the WRSI file before writing it out.

count = 0
for y = 0,100-1 do begin &$
  for d = 0, 36-1 do begin &$
  simsSM02[*,*,d,y] = sm2002[*,*,d]*E[count] &$
  count++ &$
endfor &$
endfor

;nx,ny,dek,yr is an acceptable format. Then i won't have to re-form
for i = 0,100-1 do begin &$
  temp = plot(simsSM02[wxind,wyind,*,i]/100, /overplot) &$
endfor

;;;;regress all of the SM totals against WRSI;;;;;;;
SM_tot = total(SM02cube,3,/nan)
;read in all the SM0x WRI
lfile = file_search('/home/sandbox/people/mcnally/SMAP_JHM_PAPER/EOS_WRSI_SM0X2_2001_2010_staticSOS.img')

wrsi = fltarr(nx,350,12)
openr,1,lfile
readu,1,wrsi
close,1

wrsi = wrsi[*,0:249,0:9]
sm_tot = sm_tot[*,0:249,0:9]
meansm = mean(sm_tot,dimension=3,/nan)

cormap_n = fltarr(nx,250)
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
  cormap_n[x,y]=regress(reform(SM_tot[x,y,*]),reform(wrsi[x,y,*])) &$
endfor &$
endfor

stdmap = stddev(sm02cube[*,*,0:9,*],dimension=3)

temp = image(meansm,rgb_table=20)
c = COLORBAR(target=p1,ORIENTATION=0, font_size=20)
temp.max_value=1000


;;;regress the simulation to look at correlationa and slope;;;;;;;;
;ofile = '/home/sandbox/people/mcnally/NOAHSM0Xorg_2005_sim_720.250.36.100.bin'
ifile = file_search('/home/sandbox/people/mcnally/SMAP_JHM_PAPER/ECVMWorg_2002_sim_720.350.36.100.bin') & print, ifile
simsSM02 = fltarr(nx,350,36,100)

openr,1,ifile
readu,1,simsSM02
close,1

;is that regression coeff going to be sensitive to mean? probably if it is the slope
totECV02 = total(simsSM02,3)
;p1=plot(mean(mean(totecv02,dimension=1,/nan),dimension=1,/nan),'*')

;;now open the ECV MW 2002 sims...the rescaled or the original?
; I haven't done this part of the analysis before so i guess it is up to me
; if we assume that we always need to rescale different inputs then i think we want to look 
; at the original data with the errors (maybe check to see if results are different with the re-scaled
; just to check since i can't remember if changing the mean and stdev of the data would change the regression coeff
; it seems like it might change that but not the correlation.

ecv_wrsi02 = fltarr(720,250,100)
ifile = file_search('/home/sandbox/people/mcnally/SMAP_JHM_PAPER/wrsi_ECV_2002_750.250.sim100.img') & print, ifile
openr,1,ifile
readu,1,ecv_wrsi02
close,1

;now correalte and regress the ECV perturbed tot and the WRSI outputs
cormap_r = fltarr(nx,250)
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
  cormap_r[x,y]=correlate(reform(totECV02[x,y,*]),reform(ecv_wrsi02[x,y,*])) &$
endfor &$
endfor
temp = image(cormap_r,rgb_table=20)
c = COLORBAR(target=p1,ORIENTATION=0, font_size=20)
;*******************************************
;i rescaled the purtubed data on 7/25 according to scaleNoah4wrsi.pro
;10/19 remake the sim data for 2002 cause i overwrote it, actually i didn't over write this one, but the one
;in scaleNoah4wrsi.pro
mfile = file_search('/home/chg-mcnally/ECV_microwaveSM_dekadal.2001.2010.img'); this needs to be divided by 10,000 for VWC (or 100 for %)
nx = 720
ny = 350
mpawcube = fltarr(nx,ny,36,10)

openr,1,mfile
readu,1,mpawcube
close,1
mpawgrid = reform(mpawcube,nx,ny,360)

;pad this out so it is as long as the other time series. 2001-2011?
pad = fltarr(nx,350,36)
pad[*,*,*] = !values.f_nan
mpawgrid = [ [[mpawgrid]], [[pad]] ]
mpawcube = reform(mpawgrid, nx, 350, 36,11)

nx = 720
ny = 350

sm02cube = reform(mpawgrid,nx,ny,36,11)
sm2002 = sm02cube[*,*,*,4]
seed = 6
E = randomu(seed,100*36)*0.4+0.8
simsSM02 = fltarr(nx,ny,36,100)

;check and see how this gets read into the WRSI file before writing it out.

count = 0
for y = 0,100-1 do begin &$
  for d = 0, 36-1 do begin &$
    simsSM02[*,*,d,y] = sm2002[*,*,d]*E[count] &$
    count++ &$
  endfor &$
endfor


;nx,ny,dek,yr is an acceptable format. Then i won't have to re-form
for i = 0,100-1 do begin &$
  temp = plot(simsSM02[wxind,wyind,*,i]/100, /overplot) &$
endfor

; here is the ofile...then it needs to be rescaled? remake this for 2002
;ofile = '/home/sandbox/people/mcnally/SMAP_JHM_PAPER/ECVMWorg_2002_sim_720.350.36.100.bin'
;openw,1,ofile
;writeu,1,simsSM02
;close,1


;********************************************************************* *
rfile = file_search('/home/chg-mcnally/EOS_WRSI_ubRFE2001_2012_staticSOS.img')
l2file = file_search('/home/chg-mcnally/EOS_WRSI_SM0X2_2001_2010_staticSOS.img')
mfile = file_search('/home/chg-mcnally/EOS_WRSI_MW_2001_2010_staticSOS.img')

nx = 720
ny = 350
nz = 11

l2grid = fltarr(nx,ny,nz)
mgrid = fltarr(nx,ny,nz)
rgrid = fltarr(nx,ny,nz)

openr,1,rfile
readu,1,rgrid
close,1

openr,1,l2file
readu,1,l2grid
close,1

openr,1,mfile
readu,1,mgrid
close,1

;do I have a wrsi mask?
r10 = rgrid[*,*,0:9]
m10 = mgrid[*,*,0:9]
l10 = l2grid[*,*,0:9]
C = COLORBAR(TARGET=temp,ORIENTATION=0,/BORDER_ON, $
  POSITION=[0.3,0.04,0.7,0.07], FONT_SIZE=24)



;;;simulations
;ifile1 = file_search('/home/sandbox/people/mcnally/wrsi_grid_2002_750.350.sim100.img') & print, ifile1
;ifile2 = file_search('/home/sandbox/people/mcnally/wrsi_Noah1m_2002_750.250.sim100.img') & print, ifile2 
;ifile3 = file_search('/home/sandbox/people/mcnally/wrsi_ECV_2002_750.250.sim100.img') & print, ifile3
;ifile4 = file_search('/home/sandbox/people/mcnally/wrsiPAW_grid_2002_750.350.sim100.img') & print, ifile4

;
ifile1 = file_search('/home/sandbox/people/mcnally/wrsi_grid_2005_750.350.sim100.img') & print, ifile1
ifile2 = file_search('/home/sandbox/people/mcnally/wrsi_Noah1m_2005_750.250.sim100.img') & print, ifile2
ifile3 = file_search('/home/sandbox/people/mcnally/wrsi_ECV_2005_750.250.sim100.img') & print, ifile3

;map_ulx = -20.00 & map_lrx = 52
;map_uly =  20.00 & map_lry = -5

map_ulx = -20.00 & map_lrx = 52
map_uly =  20.00 & map_lry = -5
;greg's way of nx, ny-ing
ulx = (180.+map_ulx)*10. & lrx = (180.+map_lrx)*10.
uly = (50.-map_uly)*10. & lry = (50.-map_lry)*10.
gNX = lrx - ulx
gNY = lry - uly

NX = 720
NY = 250
NS = 100

ingrid1 = fltarr(nx,350,ns)
openr,1,ifile1
readu,1,ingrid1
close,1

ingrid1 = ingrid1[*,0:249,*]


ingrid4 = fltarr(nx,350,22,ns)
openr,1,ifile4
readu,1,ingrid4
close,1

ingrid4 = ingrid4[*,0:249,*,*]

ingrid2 = fltarr(nx,ny,ns)
openr,1,ifile2
readu,1,ingrid2
close,1

ingrid3 = fltarr(nx,ny,ns)
openr,1,ifile3
readu,1,ingrid3
close,1

ecv = mean(ingrid3,dimension=3,/nan)
ecv100 = rebin(ecv,720,250,100)
lim = where(finite(ecv100) AND ecv100 gt 0)


;what is mean WRSI for each product?
nve, ingrid1(lim)

;differentiate between nans and 0s!
sd1 = stddev(ingrid1[*, 0:249,*], dimension=3, /nan);rfe
sd2 = stddev(ingrid2[*, 0:249,*], dimension=3, /nan);Noah
sd3 = stddev(ingrid3[*, 0:249,*], dimension=3, /nan);ecv

sd4 = stddev(ingrid4[*, 0:249,*,*], dimension=4, /nan);paw


m1 = mean(ingrid1[*, 0:249,*], dimension=3, /nan);rfe
m2 = mean(ingrid2[*, 0:249,*], dimension=3, /nan);Noah
m3 = mean(ingrid3[*, 0:249,*], dimension=3, /nan);ecv
m4 = mean(ingrid4[*, 0:249,*,*], dimension=4, /nan);paw


cv1 = sd1/m1
cv2 = sd2/m2
cv3 = sd3/m3
;cv4 = sd4/m4 & help, cv4



;assume ECV has fewest number of fintie pnts
;ECV = 13949, Noah = 18096, RFE = 10797, huh, maybe ECV is not low bar
lim = where(finite(sd1) AND sd1 gt 0) & help, lim



pmap_ulx = -18.65 & pmap_lrx = 25.85
pmap_uly =  17.65 & pmap_lry =  5.35


w = WINDOW(WINDOW_TITLE='Plotting Stuff',DIMENSIONS=[500,1000])

ncolors=10
p1 = image(rgrid[*,*,0], image_dimensions=[NX/10,NY/10],layout = [1,3,3], image_location=[map_ulx,map_lry], dimensions=[nx,ny], $
  rgb_table=56, title = 'cv3 2005',max_value=0.5, /CURRENT)
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
    rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
    rgbdump[*,0] = [200,200,200]
  rgbdump[*,0] = [211,211,211]
p1.rgb_table = rgbdump
C = COLORBAR(TARGET=p1,ORIENTATION=0,/BORDER_ON, $
  POSITION=[0.3,0.04,0.7,0.07], FONT_SIZE=24)
  p1 = MAP('Geographic',LIMIT = [pmap_lry, pmap_ulx, pmap_uly, pmap_lrx], /overplot)
  p1.mapgrid.linestyle = 6 &$
    p1.mapgrid.color = [150, 150, 150] &$
    p1.mapgrid.label_show = 0
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0, 0, 0], thick=2)

ncolors=256
p1 = image(byte(rgrid[*,*,0]) ,layout=[1,4,1], image_dimensions=[72.0,25.0], image_location=[-20,-5], $
;p1 = image(byte(mean(ingrid1[*,0:249,*],dimension=3,/nan)) ,layout=[1,4,1], image_dimensions=[72.0,25.0], image_location=[-20,-5], $
  dimensions=[nx,750], RGB_TABLE =make_wrsi_cmap()) &$
  t = TEXT(target=p1, -18, 1, '$\it a) Avg Sim2005 Original (bucket) WRSI$',/DATA, FONT_SIZE=18)
;c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 6 &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_show = 0 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)

p1 = image(byte(mean(ingrid2,dimension=3,/nan)),layout=[1,4,2], image_dimensions=[72.0,25.0], image_location=[-20,-5], $
  RGB_TABLE=make_wrsi_cmap(), /CURRENT) &$
  t = TEXT(target=p1, -18, 1, '$\it b) Avg Sim2005 Noah (0-40cm) WRSI$',/DATA, FONT_SIZE=18)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 6 &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_show = 0 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)


p1 = image(byte(mean(ingrid3,dimension=3,/nan)),layout=[1,4,3], image_dimensions=[72.0,25.0], image_location=[-20,-5], $
  RGB_TABLE=make_wrsi_cmap(), /CURRENT) &$
  t = TEXT(target=p1, -18, 1, '$\it c) Avg Sim2005 ECV microwave WRSI$',/DATA, FONT_SIZE=18)
c = COLORBAR(ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 6 &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_show = 0 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)

;what plots do i want? 1. the mean of the sim should be close to the mean of the single realiz. no?

;***************************************
;*********67th percentile******************************
;probability that a pixel in 2013 is above the historic 67th percentile (1/2 stdev).
;for the forecasts comparisons ajust by eoswrsi[9:293,0:338,*]...this seems to aligh better [0:290,5:338,*]
;these results look the same as they did with the old data...
;EOSWRSI = eoswrsi[9:293,0:338,*]
;why doesn't this really work? it seems like everything is wet wet wet!

EOSWRSI = ingrid

eoswrsi(where(eoswrsi le 0, count)) = !values.f_nan & print, count
eoswrsi(where(eoswrsi ge 253, count)) = !values.f_nan & print, count ;non of these were produced in IDL WRSI

dims = SIZE(eosWRSI, dimension=1)
nx = dims[0]
ny = dims[1]
nz = dims[2]

prob67 = fltarr(nx,ny)
prob33 = fltarr(nx,ny)

prob75 = fltarr(nx,ny)
prob25 = fltarr(nx,ny)

h67 = fltarr(nx,ny)
h33 = fltarr(nx,ny)
h75 = fltarr(nx,ny)
h25 = fltarr(nx,ny)

;ranks position of the 67th and 33rd percentiles
index67 = (nz-1)*0.67
index33 = (nz-1)*0.33
index75 = (nz-1)*0.75
index25 = (nz-1)*0.25

;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

x = wxind
y = wyind
for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
  ;skip nans
  test = where(finite(EOSWRSI[x,y,*]),count) &$
  if count eq -1 then continue &$

  ;look at one pixel time series at a time
  pix = EOSWRSI[x,y,*] &$
  ;this sorts the historic timeseries from smallest to largest
  index = sort(pix) &$
  sorted = pix(index) &$
  ;then find the index of the 67th percentile

  ;return the value
  per67 = sorted(index67) &$
  h67[x,y] = per67 &$

  per33 = sorted(index33) &$
  h33[x,y] = per33 &$

  ;  per75 = sorted(index75) &$
  ;  h75[x,y] = per75 &$
  ;
  ;  per25 = sorted(index25) &$
  ;  h25[x,y] = per25 &$

  ;****now count the number of ensemble members that are above/below***
  ;so something funny happens here.
  ;1. sort the values.
  ;2. count the number of values above/below percentile.

  wet67 = where(eosWRSI[x,y,*] ge per67, count67) &$
  dry33 = where(eosWRSI[x,y,*] le per33, dcount33) &$

  prob67[x,y] = float(count67)/100. &$
  prob33[x,y] = float(dcount33)/100. &$

  ;  wet = where(eosWRSI[x,y,*] ge per75, count1) &$
  ;  dry = where(eosWRSI[x,y,*] le per25, dcount1) &$
  ;
  ;  prob75[x,y] = float(count1)/100. &$
  ;  prob25[x,y] = float(dcount1)/100. &$

endfor  &$;x
endfor;y

;what was the green-brown color bar that i used for the pptx? 66? blue/red = 72
;fix up this one to match other mappies.
prob25(where(prob25 eq 1))=!values.f_nan
prob75(where(prob75 eq 1))=!values.f_nan

prob67(where(prob67 eq 1))=!values.f_nan
prob33(where(prob33 eq 1))=!values.f_nan

;map_ulx = 22.05 & map_lrx = 51.35
;map_uly = 22.95 & map_lry = -11.75



ncolors = 7
w = WINDOW(WINDOW_TITLE='Plotting Stuff',DIMENSIONS=[600,600])
p1 = image(prob33, image_dimensions=[NX/10,NY/10], image_location=[map_ulx,map_lry], $
  RGB_TABLE=74, MIN_VALUE=0.01,max_value=0.75, title = 'Prob of Sept30 WRSI below 33th percentile', /CURRENT)
rgbind = reverse(FIX(FINDGEN(ncolors)*255./(ncolors-1)))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [200,200,200]

;rgbdump[*,0] = [255,255,255] ; set map values of zero to white, you can change the color
;p1.rgb_table = reverse(rgbdump,2)  ; reassign the colorbar to the image
p1.rgb_table = rgbdump  ; reassign the colorbar to the image

c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
  POSITION=[0.3,0.06,0.7,0.09], font_size=24)

;
p1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot)
p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 18
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)


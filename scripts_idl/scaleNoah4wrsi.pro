pro scaleNoah4wrsi

;this is to scale the Noah SM02 outputs to the RPAW so that I can calcualte WRSI
;originally from Dirmeyer et al. (2004) but equation from Koster et al. (2009)
;this should be done with the dekadal values.
;rescaling the NSM ...swear i tried this with microwave recently...
;1/17/2014 updating the code to work on Rain
;1/27/2014 rescaling the MW soil moisture too for comparisons and fixing the code...
;1/29 so i think that the code is fixed byt NDVI still has crazy high correlation. AND my connection is slow.
;7/25/2014 revisit this script since I want to scale the pertubed data for UA. Good to see that I did average upper two layers
;7/27/2014 for realz, finish the f'ing paper, Ah! make everything nx=720,ny=250
;10/19/2014 back for more revisions, accidently overwrote a file

;L1file = file_search('/home/chg-mcnally/fromKnot/EXP01/dekadal/Sm01_*.img')
;L2file = file_search('/home/chg-mcnally/fromKnot/EXP01/dekadal/Sm02_*.img')
;mfile = file_search('/home/chg-mcnally/ECV_microwaveSM_dekadal.2001.2010.img'); this needs to be divided by 10,000 for VWC (or 100 for %)

rfile = file_search('/home/chg-mcnally/sahel_ubRFE_PAW36_2001-2012_LGP_WHC_PET.img');take the mean and variance from this
;ifile = file_search('/home/sandbox/people/mcnally/ECVMWorg_2002_sim_720.350.36.100.bin');just use the 2002 mean and stddev? i guess.
ifile = file_search('/home/sandbox/people/mcnally/ECVMWorg_2005_sim_720.350.36.100.bin');just use the 2002 mean and stddev? i guess.
;ifile = file_search('/home/sandbox/people/mcnally/NOAHSM0Xorg_2005_sim_720.250.36.100.bin')
;ifile = file_search('/home/sandbox/people/mcnally/NOAHSM0Xorg_2005_sim_720.250.36.100.bin')

;typical file dimensions
nx = 720
ny = 350
nz = 431
;yy = 250

;initialize arrays
;inSM1 = fltarr(nx,yy)
;inSM2 = fltarr(nx,yy)
;inSM3 = fltarr(nx,yy)

;SM01grid = fltarr(nx,yy,n_elements(L1file))
;SM02grid = fltarr(nx,yy,n_elements(L2file))
;SM03grid = fltarr(nx,yy,n_elements(L3file))

;npawgrid = fltarr(nx,ny,nz)

mpawcube = fltarr(nx,ny,36,10)
;rpawcube = fltarr(nx,ny,36,12)
simcube = fltarr(nx,250,36,100)

openr,1,rfile
readu,1,rpawcube
close,1

;to be in %VWC these need to be divided by 100
openr,1,ifile
readu,1,simcube
close,1

;rpawgrid = reform(rpawcube,nx,ny,432)
;rpawgrid(where(rpawgrid eq 0))=!values.f_nan
;rpawcube(where(rpawcube eq 0))=!values.f_nan
;put a cap on crazy RFE values that might mess up my scaling
RPAWCUBE(WHERE(RPAWCUBE GT 700))=700
;********************************************
;*********************************************
;
;openr,1,mfile
;readu,1,mpawcube
;close,1
;mpawgrid = reform(mpawcube,720,350,360)
;
;;pad this out so it is as long as the other time series. 2001-2011?
;pad = fltarr(nx,350,36)
;pad[*,*,*] = !values.f_nan
;mpawgrid = [ [[mpawgrid]], [[pad]] ]
;mpawcube = reform(mpawgrid, nx, 350, 36,11)
;
;;read in Noah soil moistures....
;for i=0,n_elements(L1file)-1 do begin &$
;  openr,1,L1file[i] &$
;  readu,1,inSM1 &$
;  close,1 &$
;  
;  openr,1,L2file[i] &$
;  readu,1,inSM2 &$
;  close,1 &$
;  
;;  openr,1,L3file[i] &$
;;  readu,1,inSM3 &$
;;  close,1 &$
;  
;  ;0-10, 10-40, 40-100, 100-200
;  SM01grid[*,*,i] = inSM1/10 &$
;  SM02grid[*,*,i] = inSM2/30 &$
;  ;SM03grid[*,*,i] = inSM3/60 &$
;  
;endfor
;
;;soil moisture depths are 10,30,60,100 (0-10, 10-40, 40-100, 100-200cm)
;;average before cubing
;SM0X2grid = fltarr(nx,250,n_elements(SM01grid[0,0,*]))
;
;for i = 0, n_elements(SM01grid[0,0,*])-1 do begin &$
;  SM0X2grid[*,*,i] = mean( [ [[SM01grid[*,*,i]]], [[SM02grid[*,*,i] ]] ], dimension=3, /nan) &$
;endfor
;
;;ofile = '/home/chg-mcnally/sm0x2grid_720.250.396_2001.2011.bin'
;;openw,1,ofile
;;writeu,1,sm0x2grid
;;close,1
;;cube it! do i still have to do this?
;;SM01cube = reform(sm01grid,720,250,36,11) ;this is 10cm deep...
;;SM02cube = reform(sm02grid,720,250,36,11); this is 30 cm deep i think (10-40cm) 
;SM0X2cube = reform(SM0X2grid, 720,250,36,11);
;;SM0X3cube = reform(SM0X3grid, 720,250,36,11);
;
;;check to see if I have all my cubies
;;npawcube = npawcube[*,*,*,0:11]
;rpawcube = rpawcube[*,*,*,0:11]

;******** mask out the dry season to keep my means appropriate**** 
season = mean(rpawcube[*,0:249,*,*], dimension = 4, /nan)
season(where(finite(season))) = 1

;make all NAN's in RPAW zeros and THEN mask season. (can't recall why i did this)
rzeros = rpawcube[*,0:249,*,*]
good = where(finite(rpawcube), complement=nans)
rzeros(nans) = 0 ;ok, looks like that works...but then i should go back and make the others nan's?

;now mask out the dekads at each point with NANs
;ok I think that this does it!
;dnpaw = fltarr(nx,250,36,11)
;dmpaw = fltarr(nx,250,36,11)
drpaw = fltarr(nx,250,36,11)
;dsm0x2 = fltarr(nx,250,36,11)
;dsm0x3 = fltarr(nx,250,36,11)
dsim   = fltarr(nx,250,36,100)

;this could prob be done sans loop if i rebin(season[x,y,z,100])
for x = 0,720-1 do begin &$
  for y = 0,250-1 do begin &$
    for yr = 0, n_elements(dsim[0,0,0,*])-1 do begin &$
      ;dnpaw[x,y,*,yr] = npawcube[x,y,*,yr]*season[x,y,*] &$
      ;dsm0x2[x,y,*,yr] = sm0x2cube[x,y,*,yr]*season[x,y,*] &$
      ;dsm0x3[x,y,*,yr] = sm0x3cube[x,y,*,yr]*season[x,y,*] &$
      ;dmpaw[x,y,*,yr] = mpawcube[x,y,*,yr]*season[x,y,*] &$
      
      ;this masks out the approprtiate seasonality:
      dsim[x,y,*,yr] = simcube[x,y,*,yr]*season[x,y,*] &$
      if yr lt 11 then drpaw[x,y,*,yr] = rzeros[x,y,*,yr]*season[x,y,*] else continue &$

    endfor &$
  endfor &$
endfor

;now, remake the cubes into grids
;npawgrid = reform(dnpaw,nx,350, 396)
;mpawgrid = reform(dmpaw,nx,350, 396)
;sm0x2grid = reform(dsm0x2,nx,350,396)
;sm0x3grid = reform(dsm0x3,nx,350,396)
rpawgrid0 = reform(drpaw,nx,250,396)
simgrid = reform(dsim,nx,250,3600)
rpawgrid200 = reform(drpaw[*,*,*,4])

help, npawcube, rpawcube, sm01cube,  sm02cube, sm0x2cube, sm0x3cube, mpawcube
help, npawgrid, rpawgrid, sm01grid,  sm02grid, sm0x2grid, sm0x3grid, mpawgrid

;***********************************************************************
;now I can look at the NDVI, RFE, and two noah soil moistures for comparison...

wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;soooo, so i do this scaling in the time series by dekad?
; where Noah (a) is to be used in WRSI(B)
; where NWET (a) is to be used in WRSI(B)
; where MW   (a) is to be used in WRSI(B)
;wB = fltarr(nx,yy,36,11)*!values.f_nan
;wB = fltarr(nx,yy,36,10)*!values.f_nan

;so what i need to do is the mean and std for each pixel over the whole TS, not each dek.
;so i think I want to be working with the grids not the cubes....
;make the mean and std maps for each data set.

;the mean maps can be done w/ out a loop right?
;pix_avg1 = mean(mpawgrid,  dimension=3, /nan)
;pix_avg2 = mean(sm0x2grid, dimension=3, /nan)
;pix_avgB = mean(rpawgrid0,  dimension=3, /nan)

;so I want the Sim. to have mean 10 and stdev 38

pix_avgBS = mean(rpawgrid200,  dimension=3, /nan)
pix_avgAS = mean(simgrid,dimension=3,/nan)

NX=720
NY=250
;sigmaA1 = fltarr(nx,ny)*!values.f_nan
;sigmaA2 = fltarr(nx,ny)*!values.f_nan

sigmaAS = fltarr(nx,ny)*!values.f_nan

;sigmaA3 = fltarr(nx,ny)
;sigmaA4 = fltarr(nx,ny)
sigmaB  = fltarr(nx,ny)*!values.f_nan

;use the loop to calculate the stdev, there may be a way to do this without a loop?
;this would also be faster if i used some mask...
for x=0, nx -1 do begin &$
  print, x &$
  for y = 0,ny-1 do begin   &$
      ;normalize and then adjust by RPAW mean and stdev. 
;      SMA1 = mpawgrid[x,y,*] &$
;      SMA2 = sm0x2grid[x,y,*] &$
;      SMB = rpawgrid0[x,y,*] &$
      
      ;for the simulations
      SMB = rpawgrid200[x,y,*] &$
      SMAS = simgrid[x,y,*] &$

      
      test = where(finite(SMAS), count) &$
      if count eq 0 then continue &$
      
;      sigmaA1[x,y] = stddev(SMA1, /NAN)  &$
;      sigmaA2[x,y] = stddev(SMA2, /NAN)  &$
      
      sigmaB[x,y]  = stddev(SMB, /NAN)  &$
      sigmaAS[x,y]  = stddev(SMAS, /NAN)  &$

  endfor &$
endfor

;wb1 = fltarr(nx,ny,396)
;wb2 = fltarr(nx,ny,396)
wbS = fltarr(nx,ny,3600)

;wb3 = fltarr(nx,ny,396)
;wb4 = fltarr(nx,ny,396)

for d = 0,n_elements(simgrid[0,0,*])-1 do begin &$
  ;wB1[*,*,d] = ( (mpawgrid[*,*,d]-pix_avg1)/sigmaA1) *sigmaB+pix_avgB  &$ 
  ;wB2[*,*,d] = ( (sm0x2grid[*,*,d]-pix_avg2)/sigmaA2) *sigmaB+pix_avgB  &$ 
  wBS[*,*,d] = ( (simgrid[*,*,d]-pix_avgAS)/sigmaAS) *sigmaB+pix_avgBS  &$

;  wB3[*,*,d] = ( (sm0x3grid[*,*,d]-pix_avg3)/sigmaA3) *sigmaB+pix_avgB  &$ 
;  wB4[*,*,d] = ( (npawgrid[*,*,d]-pix_avg4)/sigmaA4) *sigmaB+pix_avgB  &$ 
endfor

;ok, so the re-scaled 2002 simulations have a reasonable mean and stddev (WBS) vs
;the 2002 rpaw pix_avgBS. not sure why it isn't perfect but I guess it was done on a grid by grid basis.
;I am not sure sure that is correct, in reality i would like all 2002 simulations to have that mean and avg

wb1(where(wb1 lt 0)) = !values.f_nan
wb2(where(wb2 lt 0)) = !values.f_nan
wb3(where(wb3 lt 0)) = !values.f_nan
wb4(where(wb4 lt 0)) = !values.f_nan

;I think I'd like to smooth these values? or at least fill in the funny Nans, so that they don't
;casue problems in the WRSI...

avgWB = mean(WBS, dimension=3, /nan)
avgRP = mean(rpawgrid200, dimension=3, /nan)

;look and see it its ok, seems ok...
ncolors=256
 temp = image(avgWB,  RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), min_value=0, max_value=200,image_dimensions=[72.0,25.0], image_location=[-20,-5], $ 
            dimensions=[nx,ny])
 c = COLORBAR(target=temp,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
 temp.title = 'Avg Noah Sim  2005'
  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 52], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [220, 0, 0], thick=2)

;;now go run these data through the WRSI...
;      SMA1 = mpawgrid[x,y,*] &$
;      SMA2 = sm0x2grid[x,y,*] &$
;      SMA3 = sm0x3grid[x,y,*] &$      
;      SMA4 = npawgrid[x,y,*] &$
;      SMB = rpawgrid[x,y,*] &$
;ECV_MW_scaled4WRSI.img  SM01_scaled4WRSI.img  SM0X_scaled4WRSI.img
;NWET_scaled4WRSI.img    SM02_scaled4WRSI.img
ofile1 = '/home/chg-mcnally/ECV_MW2005_scaled4WRSI.img'
ofile1 = '/home/chg-mcnally/SM0X2_2005_scaled4WRSI.img'

;ofile2 = '/home/chg-mcnally/SM0X2_scaled4WRSI.img'
;ofile3 = '/home/chg-mcnally/SM0X3_scaled4WRSI.img'
;ofile4 = '/home/chg-mcnally/NWET_scaled4WRSI.img'

;openw,1,ofile1
;writeu,1,wbs
;close,1

;**********reshape and write out individual files ***********
;also in mask4idl WRSI
;ifile = file_search('/home/chg-mcnally/ECV_MW2005_scaled4WRSI.img') & print, ifile
ifile = file_search('/home/chg-mcnally/SM0X2_2005_scaled4WRSI.img') & print, ifile

NX = 720
NY = 250
NZ = 3600

ingrid = fltarr(nx,ny,nz)

openr,1,ifile
readu,1, ingrid
close,1

ingrid(where(ingrid lt 0))=!values.f_nan
;check the map and wankama time series
temp = image(mean(ingrid, dimension=3,/nan), rgb_table=4)

out = reform(ingrid,nx,ny,36,100)
temp = plot(out[wxind,wyind,*,0])
temp = plot(out[wxind,wyind,*,10], /overplot, thick=2)


for i = 0,100-1 do begin &$
  ogrid = out[*,*,*,i] &$
  ofile = strcompress('/home/sandbox/people/mcnally/MWSM_sim/Noah1m_2005_sim_720.250.36.'+string(format='(I2.2)',i)+'.bin', /remove_all) & print, ofile  &$
  openw,1,ofile  &$
  writeu,1,ogrid  &$
  close,1  &$
endfor


wb5=wb4
wb5(where(wb5 gt 600))=600
;check you histograms!
indata = wb3(where(finite(wb3)))
;indata = rpawgrid0(where(finite(rpawgrid0)))
tmphist = histogram(indata,NBINS=40,OMAX=omax,OMIN=omin)
bplot = barplot(tmphist,FILL_COLOR='yellow')
nticks = 5
xticks = STRARR(nticks)
for i=0,nticks-1 do xticks(i) = STRING(FORMAT='(I-)',FLOOR(omin + (i * (omax - omin) / (nticks -1))))
bplot.xtickname = xticks
bplot.title = 'Histogram of SM0X3-Plant Avail Water'

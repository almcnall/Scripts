pro NDVI2paw

;i moved make_filteredNDVI to here 
;3/21/2013 - updated the code to use the new AMMA2013 data for a longer time series. 
;5/02/2013 updated this script to fit NDVI to PAW calculated by the WRSIcode.

;********************NOW FIT THE N-PAW**********************
;ifile = file_search('/jabber/chg-mcnally/sahel_ubRFE_PAW36_2001-2011_LGP16.img')
;ifile = file_search('/jabber/chg-mcnally/sahel_ubRFE_PAW36_2001-2012_LGP_WHC.img')
;ifile = file_search('/jabber/chg-mcnally/sahel_ubRFE_SWB36_2001-2012_LGP_WHC.img')
;ifile = file_search('/jabber/chg-mcnally/sahel_ubRFE_PAW36_2001-2012_LGP_WHC_PET.img'); i think this one is good.
;ifile2 = file_search('/jabber/chg-mcnally/sahel_ubRFE_PAW36_2001-2012_LGP_WHC_PET_staticSOS.img')
mfile = file_search('/jower/sandbox/mcnally/ECV_soil_moisture/monthly/sahel/ECV_SM*.img')

nx = 720
ny = 350 
nz = n_elements(mfile)

ingrid = fltarr(nx,ny)
mwgrid = fltarr(nx,ny,nz)

for i = 0,n_elements(mfile)-1 do begin &$
  openr,1,mfile[i] &$
  readu,1,ingrid &$
  close,1 &$
  
  mwgrid[*,*,i] = ingrid &$
endfor  

mwdeks = rebin(mwgrid,nx,ny,360); now we have dekadal microwave soil moisture. yay!
mw36 = reform(mwdeks,nx,ny,36,10)
;ofile = '/jabber/chg-mcnally/ECV_microwaveSM_dekadal.2001.2010.img'
;openw,1,ofile
;writeu,1,mw36
;close,1

;wait on this, do sites individully first.
;PAW36grid = mean(PAW36,dimension = 4,/nan)

;make or read in the average NDVI for each pixel
ifile = file_search('/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/sahel/data.{2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012}*img')
;ifile = file_search('/jabber/chg-mcnally/sahel_avg_dekadal_NDVI.img'); don't both with this one, i need the full TS anyway

nx = 720
ny = 350
;nz = 36
nz = n_elements(ifile)

ingrid = fltarr(nx,ny)
ndvi = fltarr(nx,ny,nz)

for f = 0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[f] &$
  readu,1,ingrid &$
  close,1 &$
  ndvi[*,*,f] = ingrid &$
endfor 
ndvi36 = reform(ndvi,nx,ny,36,12)
;NDVIavg = mean(ndvi36,dimension=4, /nan)

;****************test the fits for the individual sites**************
;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5) / 0.10)

;****Nalohou-Top, Benin  9.74407     1.60580  
nxind = FLOOR((1.6058 + 20.) / 0.10);says it is 144...2006-2007 (2009)
nyind = FLOOR((9.74407 + 5) / 0.10)

;Belefoungou-Top 9.79506     1.71450  
bxind = FLOOR((1.7145 + 20.) / 0.10)
byind = FLOOR((9.79506 + 5) / 0.10)

;p1 = plot(mean(ndvi36[axind,ayind,*,*], dimension=4, /nan))
;p2 = plot(mean(mw36[axind,ayind,*,*]/5000, dimension=4, /nan), /overplot,'c')
;
;p1 = plot(mean(ndvi36[x,y,*,*], dimension=4, /nan),/overplot)
;p2 = plot(mean(mw36[x,y,*,*]/5000, dimension=4, /nan), /overplot,'c')
NWET = fltarr(nx,ny,431)*!values.f_nan
outparams = fltarr(nx,ny,5)

;xx=wxind
;yy=wyind
for xx=0,nx-1 do begin &$
  for yy=0,ny-1 do begin &$
  navg = mean(ndvi36[xx,yy,*,*], dimension=4, /nan) &$
  avgmw = mean(mw36[xx,yy,*,*], dimension=4, /nan) &$
  index = where(finite(avgmw), complement=null, count) &$
  if count le 5 then continue &$
  ;this is a convoluted way to make sure that it is a continuous time series with non nans...
  start = fltarr(n_elements(index))*!values.f_nan &$
  for i = 0,n_elements(index)-2 do begin &$
    if index[i] eq index[i+1]-1 then start[i]=index[i] &$
  endfor &$
  good = where(finite(start)) &$
  Y1 = avgmw(start[good]) &$
  Y = Y1([0]:[n_elements(Y1)-2]) &$
  X1 = navg(start[good]) &$
  if stdev(x1) lt 0.0001 then continue &$
  X2 = X1[1:N_elements(x1)-1] &$
  ;X3 = X1[2:N_elements(x1)-1] &$
  ;X = [  transpose(X1[0:n_elements(x1)-3]), transpose(X2), transpose(X3) ]  &$
  X = [  transpose(X1[0:n_elements(x1)-2]), transpose(X2)]  &$
  if n_elements(Y) le 4 then continue &$
  reg = regress(X,Y,const=const,correlation=corr,yfit=yfit, sigma=sigma) &$
  outparams[xx,yy,*] = [const, reg[0],reg[1], corr[0], corr[1]] &$
  ;est = const+reg[0]*ndvi[xx,yy,0:429]+reg[1]*ndvi[xx,yy,1:430]+reg[2]*ndvi[xx,yy,2:431] &$
  est = const+reg[0]*ndvi[xx,yy,0:430]+reg[1]*ndvi[xx,yy,1:431] &$
   NWET[xx,yy,*] = est  &$
  endfor &$
  print, xx,yy &$
endfor
print, 'done'

pad = fltarr(nx,ny,1)
pad[*,*,*]=!values.f_nan
nwetfull = [[[nwet]],[[pad]]]

ofile = strcompress('/jabber/chg-mcnally/sahel_NSM_microwave.720.350.432_2001_2012.img')
openw,1,ofile
writeu,1,nwetfull
close,1



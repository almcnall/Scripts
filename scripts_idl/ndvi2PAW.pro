pro NDVI2paw

;i moved make_filteredNDVI to here 
;3/21/2013 - updated the code to use the new AMMA2013 data for a longer time series. 
;5/02/2013 updated this script to fit NDVI to PAW calculated by the WRSIcode.
;
;*************Niger sites**************************************
;pfile = file_search('/jabber/chg-mcnally/WKPAW_wfill_2006_2008_SOS.16.18.18.14_LGP16.csv')
nfile = file_search('/jabber/chg-mcnally/AMMAVeg/NDVI_WK_2001_2012.csv')
rfile = file_search('/jabber/chg-mcnally/sahel_ubRFE_PAW_dynSOS_WHC_LGP.img')
;rfile = file_search('/jabber/chg-mcnally/WKPAW_RFE_2005_2012_dynSOS_LGP16.csv')


ndvi = read_csv(nfile)
;paw = read_csv(pfile)
rpaw = read_csv(rfile)

wkNDVI = float(ndvi.field1)
ncube = reform(wkNDVI,36,12)

;pcube = transpose([[paw.field1],[paw.field2], [paw.field3],[paw.field4]])
rpcube = transpose([[rpaw.field01],[rpaw.field02], [rpaw.field03],[rpaw.field04],[rpaw.field05],[rpaw.field06], [rpaw.field07],[rpaw.field08],$
  [rpaw.field09],[rpaw.field10], [rpaw.field11]])

;****make a time series of the paw filling in the correct spaces********
SOS=[19, 18,  16,  18,  15,  19,  17,  17,  16,  18,  18] ;for the RFE data at Wankama
PAWTS = fltarr(36,n_elements(SOS));
LGP=16
for yr = 0,n_elements(SOS)-1 do begin &$
  start = 0  &$
  ph1 = SOS[yr]-2 & print, ph1  &$
  ph2 = SOS[yr]-1 & print, ph2 &$
  ph3 = SOS[yr]-1+LGP-1 & print, ph3 &$
  ph4 = SOS[yr]+LGP-1 & print, ph4 &$
  fin = 35  &$
  PAWTS[start:ph1,yr] = !values.f_nan  &$
  PAWTS[ph2:ph3,yr] = rpcube[yr,*]  &$
  PAWTS[ph4:fin,yr] = !values.f_nan  &$
endfor

pavg = mean(pawts, dimension=2,/nan)
navg = mean(ncube, dimension=2,/nan)

;now regress the short/avg timeseries
;how am i supposed to know where to start? why is it 15?
Y = pavg[14:31]
;two lags
X = [ transpose(navg[14:31]),transpose(navg[15:32]) ]
reg = regress(X,Y,const=const,correlation=corr,yfit=yfit, sigma=sigma) & print, const, transpose(reg)
est = const+reg[0]*navg[0:34]+reg[1]*navg[1:35]

temp = plot(mean(pawts[*,*], dimension=2,/nan), thick=3, 'm')
temp = plot(mean(ncube[*,*], dimension=2,/nan)*500,thick=2, 'b', /overplot)
temp = plot(est,thick = 3, linestyle = 2, 'grey', /overplot)

;***and for all three years?*******
est2 = const+reg[0]*wkNDVI[0:394]+reg[1]*wkNDVI[1:395]

temp = plot(est2[0:394], thick=2,linestyle=2, 'g')
temp = plot(reform(pawts,396),thick=2,'b', /overplot)
temp.title = 'Wankama 2001-2011, RFE-PAW(solid), N-PAW(dashed)'

print, r_correlate(est[13:32],pavg[13:32])
p1=plot(est, 'g')
p1=plot(savg,/overplot)


;***************************for the whole sahel*****************************
;***************************************************************************
;**********FILL OUT THE TIME SERIES OF PAW SO IT IS 36 DEKS*****************

;SOSfile = file_search('/jabber/chg-mcnally/SOSsahel_ubRFE_2001_2001.img')
SOSfile = file_search('/home/mcnally/regionmasks/SOSsahel.img')
PAWfile = file_search('/jabber/chg-mcnally/sahel_ubRFE_PAW_dynSOS_WHC_LGP_PET.img')
;ssfile = file_search('/jabber/chg-mcnally/sahel_ubRFE_PAW_staticSOS_WHC_LGP_PET.img')
ifile = file_search('/home/mcnally/regionmasks/LGPsahel.img')

nx = 720
ny = 350
nz = 12

;SOSgrid = fltarr(nx,ny,nz)
sosgrid = bytarr(nx,ny)
PAWgrid = fltarr(nx,ny,22,nz)
PAWgrid2 = fltarr(nx,ny,22,nz)
lgpgrid = bytarr(nx,ny)


PAWTS = fltarr(36,12)
PAW36 = fltarr(nx,ny,36,12)

openr,1,SOSfile
readu,1,SOSgrid
close,1

openr,1,PAWfile
readu,1,pawgrid
close,1

openr,1,ifile
readu,1,lgpgrid
close,1

;openr,1,ssfile
;readu,1,pawgrid2
;close,1

;it would probably be better to put this loop in the WRSI code so that they are just written out
; appropriately in the grid.
for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
     SOS = SOSgrid[x,y,*] &$
     for yr = 0,n_elements(SOS)-1 do begin &$
      if SOS[yr] gt 20 then continue &$
      if SOS[yr] lt 2 then continue &$
      ;print, SOS[yr] &$
      LGP = LGPgrid[x,y] &$
      if LGP eq 0 then continue &$
      start = 0  &$
      ph1 = SOS[yr]-2 &$
      ph2 = SOS[yr]-1 &$
      ph3 = SOS[yr]-1+LGP-1 &$
      ph4 = SOS[yr]+LGP-1 &$
      if ph4 ge 36 then continue &$ 
      fin = 35  &$
      PAWTS[start:ph1,yr] = !values.f_nan  &$
      PAWTS[ph2:ph3,yr] = pawgrid[x,y,0:LGP-1,yr]  &$
      PAWTS[ph4:fin,yr] = !values.f_nan  &$
      PAW36[x,y,*,yr] = PAWTS[*,yr] &$
    endfor &$  
  endfor &$
endfor

;*****************same thing for the static SOS***************
;for x = 0, nx-1 do begin &$
;  for y = 0, ny-1 do begin &$
;      SOS = SOSgrid[x,y] &$
;      if SOS gt 20 then continue &$
;      if SOS lt 2 then continue &$
;      ;print, SOS &$
;      LGP = LGPgrid[x,y] &$
;      if LGP eq 0 then continue &$
;      start = 0  &$
;      ph1 = SOS-2 &$
;      ph2 = SOS-1 &$
;      ph3 = SOS-1+LGP-1 &$
;      ph4 = SOS+LGP-1 &$
;      if ph4 ge 36 then continue &$ 
;      fin = 35  &$
;    for yr = 0,n_elements(PAWgrid[0,0,0,*])-1 do begin &$  
;      PAWTS[start:ph1,yr] = !values.f_nan  &$
;      PAWTS[ph2:ph3,yr] = pawgrid2[x,y,0:LGP-1,yr]  &$
;      PAWTS[ph4:fin,yr] = !values.f_nan  &$
;      PAW36[x,y,*,yr] = PAWTS[*,yr] &$
;    endfor &$  
;  endfor &$
;endfor
;***************************************************************
;make sure the RPAW looks ok
;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5) / 0.10)

;****Nalohou-Top, Benin  9.74407     1.60580  
nxind = FLOOR((1.6058 + 20.) / 0.10);says it is 144...2006-2007 (2009)
nyind = FLOOR((9.74407 + 5) / 0.10)

p1=plot(mean(paw36[wxind,wyind,*,*], dimension=4,/nan))
p1=plot(mean(paw36[axind,ayind,*,*], dimension=4,/nan), /overplot, 'c')
p1=plot(mean(paw36[nxind,nyind,*,*], dimension=4,/nan), /overplot,'b')
ofile = strcompress('/jabber/chg-mcnally/sahel_ubRFE_PAW36_2001-2012_LGP_WHC.img', /remove_all)
;ofile = strcompress('/jabber/chg-mcnally/sahel_ubRFE_PAW36_2001-2012_LGP_WHC_PET_staticSOS.img', /remove_all)
;
;openw,1,ofile
;writeu,1,PAW36
;close,1

;********************NOW FIT THE N-PAW**********************
;ifile = file_search('/jabber/chg-mcnally/sahel_ubRFE_PAW36_2001-2011_LGP16.img')
;ifile = file_search('/jabber/chg-mcnally/sahel_ubRFE_PAW36_2001-2012_LGP_WHC.img')
;ifile = file_search('/jabber/chg-mcnally/sahel_ubRFE_SWB36_2001-2012_LGP_WHC.img')
ifile = file_search('/jabber/chg-mcnally/sahel_ubRFE_PAW36_2001-2012_LGP_WHC_PET.img'); i think this one is good.
;ifile2 = file_search('/jabber/chg-mcnally/sahel_ubRFE_PAW36_2001-2012_LGP_WHC_PET_staticSOS.img')

nx = 720
ny = 350 

paw36 = fltarr(nx,ny,36,12)

openr,1,ifile
readu,1,paw36
close,1
DYNpaw = paw36

openr,1,ifile2
readu,1,paw36
close,1

STApaw = paw36

;then take the average PAW for each grid
;PAW36(where(PAW36 eq 0)) = !values.f_nan
STAPAW(where(STAPAW eq 0)) = !values.f_nan
DYNPAW(where(DYNPAW eq 0)) = !values.f_nan

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

p1 = plot(mean(ndvi36[axind,ayind,*,*], dimension=4, /nan))
p2 = plot(mean(STApaw[axind,ayind,*,*]/500, dimension=4, /nan), /overplot,'c')
p2 = plot(mean(DYNpaw[axind,ayind,*,*]/500, dimension=4, /nan), /overplot,'b')

;ofile = strcompress('/jabber/chg-mcnally/sahel_avg_dekadal_NDVI.img')
;openw,1,ofile
;writeu,1,NDVI36grid
;close,1

outparams = fltarr(nx,ny,4)
NPAW = fltarr(nx,ny,431)
outyfit = fltarr(nx,ny,22)


;now go through and regress the ndvi36 to the paw36.
for xx = 0,nx-1 do begin  &$
  ;xx = wxind
  for yy = 0, ny-1 do begin  &$
    ;yy = wyind
    ;if mean(navg) eq -1 then continue  &$
    navg = mean(ndvi36[xx,yy,*,*], dimension=4, /nan) &$
    pavg = mean(DYNpaw[xx,yy,*,*], dimension=4, /nan) &$
    ;deal with the NANs in the PAW
    index = where(finite(pavg), count)  &$
    if count eq 0 then continue  &$
    Y = pavg[index[0]:index[count-2]]  &$
    ;two lags, ugh missing an index...sometimes at beigingin and some at end wtf
    X = [ transpose(navg[index[0]:index[count-2]]),transpose(navg[index[0]+1:index[count-2]+1]) ]  &$
    reg = regress(X,Y,const=const,correlation=corr,yfit=yfit, sigma=sigma) &$
    outparams[xx,yy,*] = [const, reg[0],reg[1], corr[1]]   &$
   ;make the full npaw cube!
   est = const+reg[0]*ndvi[xx,yy,0:430]+reg[1]*ndvi[xx,yy,1:431]  &$
   NPAW[xx,yy,*] = est  &$
  endfor &$
endfor 

NPAW(where(NPAW lt 0))=0
;ofile = strcompress('/jabber/chg-mcnally/sahel_NPAW_2001_2012.img', /remove_all)
ofile = strcompress('/jabber/chg-mcnally/sahel_NPAW_2001_2012_PET_DYNSOS.img', /remove_all)

openw,1,ofile
writeu,1,NPAW
close,1

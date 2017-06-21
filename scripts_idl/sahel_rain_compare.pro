pro sahel_rain_compare

;the purpose of this script is to compare the CMAP, CSCDP and RFE over the sahel window, as pre-compare
;for the LIS-Noah runs (how does FLDAS compare to GDAS?) I guess I should look at both RFE and ubRFE
;gosh I wonder how it will compare to CSCDP! eak. Is everyone in 0.1 degrees?


;******************read in all the data********************************
cfile = file_search('/jower/LIS/data/CMAP_afr/sahel/cmap_rain1.*.img')
bfile = file_search('/jower/LIS/data/CSCDP_afr/sahel/cscdp.*.tif');not really tifs...
rfile = file_search('/jabber/LIS/Data/CPCOriginalRFE2/monthly/sahel/all_products.bin.*.img')
ufile = file_search('/jabber/LIS/Data/ubRFE04.19.2013/monthly/sahel/all_products.bin.*.img')
;pete's chirps...
pfile = file_search('/jower/sandbox/mcnally/CHIRPS_monthly/chirps.{2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012}*.tif')

nx = 720
ny = 350
nzc = n_elements(cfile)
nz = n_elements(bfile)

bufferc = fltarr(nx,ny)
bufferb = fltarr(nx,ny)
bufferr = fltarr(nx,ny)
bufferu = fltarr(nx,ny)

ingridc = fltarr(nx,ny,nzc)

ingridb = fltarr(nx,ny,nz)
ingridr = fltarr(nx,ny,nz)
ingridu = fltarr(nx,ny,nz)
ingridp = fltarr(nx,ny,nz)

xrt = (751-1)-3/0.1  &$;RFE goes to 55, sahel goes to 52 plus an extra pixel
ybot = (35/0.1)+1   &$ ;sahel starts at -5S
ytop = (801-1)-10/0.1  &$; &$sahel stops at 30N
xlt = 1.     &$          ;and I guess sahel starts at 19W, rather than 20....

ingridc[*,*,*] = !values.f_nan

for i = 0,n_elements(bfile)-1 do begin &$
  openr,1,bfile[i] &$
  openr,2,rfile[i] &$
  openr,3,ufile[i] &$  
  
  readu,1,bufferb &$
  readu,2,bufferr &$
  readu,3,bufferu &$
  temp = congrid(reverse(read_tiff(pfile[i],R,G,B,geotiff=geotiff),2),751,801) &$

  sahel = temp[xlt:xrt,ybot:ytop] &$
  ingridp[*,*,i]  = sahel &$
  
  close,1 &$
  close,2 &$
  close,3 &$
 
  ingridb[*,*,i] = bufferb &$
  ingridr[*,*,i] = bufferr &$
  ingridu[*,*,i] = bufferu &$
endfor 

for i = 0,n_elements(cfile)-1 do begin &$
  openr,1,cfile[i] &$
  readu,1,bufferc &$
  close,1 &$
  
  ingridc[*,*,i] = bufferc &$
endfor
ingridc(where(ingridc lt 0))=!values.f_nan
;fix up ingridp...regrid and clip to sahel
ingridp(where(ingridp eq 9999.0))=!values.f_nan

;***************************calculate statitiscs of interest & save them**********************
;monthly comparisions....
;check out the months
sta_cube = reform(ingridb,nx,ny,12,12)
rfe_cube = reform(ingridr,nx,ny,12,12)
urf_cube = reform(ingridu,nx,ny,12,12)
cmp_cube = reform(ingridc,nx,ny,12,11)
chp_cube = reform(ingridp,nx,ny,12,12)


;I should look at rank correlation, mean bias error and mean absolute error.
;maps of mean absolute error abs(model-observed)/12

mo = [1,2,3,4,5,6,7,8,9,10,11,12]
maegrid = fltarr(nx,ny,n_elements(mo))
maegrid[*,*,*]=!values.f_nan

;mask out the ocean
test = where(finite(urf_cube),complement=null)
rfe_cube(null) = !values.f_nan
sta_cube(null) = !values.f_nan
cmp_cube(null) = !values.f_nan
chp_cube(null) = !values.f_nan

for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,ny-1 do begin &$
     test = where(finite(urf_cube[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     maegrid[x,y,m]=(mean(abs(cmp_cube[x,y,mo[m]-1,*]-sta_cube[x,y,mo[m]-1,*]),/nan))/mean(sta_cube[x,y,mo[m]-1,*]) &$
    endfor  &$
  endfor  &$
  print,x,y &$
endfor 
maegrid(where(maegrid gt 1))=1
;ofile = '/jabber/chg-mcnally/mae_cmp_stav2.img'
;openw,1,ofile
;writeu,1,maegrid
;close,1

mbegrid = fltarr(nx,ny,n_elements(mo))
mbegrid[*,*,*]=!values.f_nan

;dinku et all calls this mean error (ME)
for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,ny-1 do begin &$
     test = where(finite(urf_cube[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     mbegrid[x,y,m]=mean(chp_cube[x,y,mo[m]-1,*]-sta_cube[x,y,mo[m]-1,*],/nan) &$
    endfor  &$
  endfor  &$
 print,x,y &$
endfor

;ofile = '/jabber/chg-mcnally/mbe_chrps_sta.img'
;openw,1,ofile
;writeu,1,mbegrid
;close,1

;sta_cube, rfe_cube,urf_cube,cmp_cube,chp_cube

biasgrid = fltarr(nx,ny,n_elements(mo))
biasgrid[*,*,*]=!values.f_nan

for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,ny-1 do begin &$
     test = where(finite(urf_cube[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     biasgrid[x,y,m]=cmp_cube[x,y,mo[m]-1,*]/sta_cube[x,y,mo[m]-1,*] &$
    endfor  &$
  endfor  &$
 print,x,y &$
endfor
;biasgrid(where(biasgrid gt 2))=2
;ofile = '/jabber/chg-mcnally/bias_cmp_sta.img'
;openw,1,ofile
;writeu,1,biasgrid
;close,1

;****************by country***************************
meefile = file_search('/jabber/chg-mcnally/mbe_*sta.img')
maefile = file_search('/jabber/chg-mcnally/mae*v2.img')
biafile = file_search('/jabber/chg-mcnally/bias*.img')

  ;***compare standardized soil mositure by crop zones***********************
cfile = file_search('/jabber/chg-mcnally/cz_mask_sahel.img')

nx = 720
ny = 350
nz = 12

cgrid = fltarr(nx,ny)

openr,1,cfile
readu,1,cgrid
close,1

cgrid = cgrid[*,0:249]

burkina = where(cgrid eq 1, count) & print, count
chad = where(cgrid eq 2, count) & print, count
mali = where(cgrid eq 3, count) & print, count
niger = where(cgrid eq 4, count) & print, count
senegal = where(cgrid eq 5, count) & print, count


ingrid = fltarr(nx,ny,nz)
allgrid = fltarr(nx,ny,nz,n_elements(meefile))
for i = 0,n_elements(meefile)-1 do begin &$
  openr,1,maefile[i] &$
  readu,1,ingrid &$
  close,1 &$
  
  allgrid[*,*,*,i] = ingrid &$
endfor
 meegrid = allgrid
 maegrid = allgrid
 biagrid = allgrid
;get the RPAW, NPAW, SM01, SM02, and SMMW for each country (averged over? J,A,S?)
;rain  then NDVI
;******************************************** 

;NigerSM = fltarr(3,12,4)
;SenegalSM = fltarr(3,12,4)
;MaliSM = fltarr(3,12,4)
;BurkinaSM = fltarr(3,12,4)
;ChadSM = fltarr(3,12,4)

MEarray = fltarr(4,5,12)
MAEarray= fltarr(4,5,12)
BIAarray = fltarr(4,5,12)

for m = 0,n_elements(meegrid[0,0,*,0])-1 do begin &$
  for p = 0,n_elements(meegrid[0,0,0,*])-1 do begin &$
    
    mee = meegrid[*,*,m,p] &$
    mae = maegrid[*,*,m,p] &$
    bia = biagrid[*,*,m,p] &$
    
    MEarray[p,*,m] =  [mean(mee(burkina),/nan),mean(mee(chad),/nan),mean(mee(mali), /nan),mean(mee(niger), /nan),mean(mee(senegal), /nan)] &$
    MAEarray[p,*,m] =  [mean(mae(burkina),/nan),mean(mae(chad),/nan),mean(mae(mali), /nan),mean(mae(niger), /nan),mean(mae(senegal), /nan)] &$
    BIAarray[p,*,m] =  [mean(bia(burkina),/nan),mean(bia(chad),/nan),mean(bia(mali), /nan),mean(bia(niger), /nan),mean(bia(senegal), /nan)] &$

  endfor &$    
endfor;i           
             
             
             
             
             

;****************correlation map******************************
;Wankama 2006 - 2011 (13.6456,2.632 )
;wxind = FLOOR((2.632 + 20.) / 0.10)
;wyind = FLOOR((13.6456 + 5) / 0.10)
;
x = wxind
y = wyind

corgrid = fltarr(nx,ny,n_elements(mo))
corgrid[*,*,*]=!values.f_nan

;I guess this is where i should be doing the scatter quads...
for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,ny-1 do begin &$
     test = where(finite(urf_cube[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     corgrid[x,y,m]=correlate(cmp_cube[x,y,mo[m]-1,0:10],sta_cube[x,y,mo[m]-1,0:10]) &$
    endfor  &$
  endfor  &$
 print,x,y &$
endfor

p1=image(corgrid[*,*,6], rgb_table=20)

;ofile = '/jabber/chg-mcnally/cor_cmp_sta.img'
;openw,1,ofile
;writeu,1,corgrid
;close,1

;****************************************************
;*****************at sites**************************

;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5) / 0.10)


;Belefoungou-Top 9.79506     1.71450  
bxind = FLOOR((1.7145 + 20.) / 0.10)
byind = FLOOR((9.79506 + 5) / 0.10)

;the full time series
p1=plot(ingridb[wxind,wyind,*], thick=2)
p1=plot(ingridr[wxind,wyind,*], /overplot,'b')
p1=plot(ingridu[wxind,wyind,*], /overplot,'c')
p1=plot(ingridc[wxind,wyind,*], /overplot,'g')
p1=plot(ingridp[wxind,wyind,*], /overplot,'m')
;june time plot

m=9
x = wxind
y = wyind
p1=plot(sta_cube[x,y,m-1,*], thick = 2, name = 'CSCDP station')
p2=plot(rfe_cube[x,y,m-1,*], /overplot,'b', name = 'rfe')
p3=plot(urf_cube[x,y,m-1,*], /overplot,'c', name = 'ub rfe')
p4=plot(cmp_cube[x,y,m-1,*], /overplot,'g', name = 'cmap')
!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3]) 
p1.title=' Belefoungou, Benin 2001-2012 month '+string(m)

;june scatter plot
;p1=plot(sta_cube[wxind,wyind,6-1,*])
p2=plot(rfe_cube[x,y,m-1,*],sta_cube[x,y,m-1,*], '*b', name = 'rfe')
p3=plot(urf_cube[x,y,m-1,*],sta_cube[x,y,m-1,*], '*c',/overplot, name = 'ub rfe')
p4=plot(cmp_cube[x,y,m-1,*],sta_cube[x,y,m-1,*], '*g', /overplot, name = 'cmap')
p2.title=' Belefougou 2001-2012 month '+string(m)
p2.xminor=0
p2.yminor=0
!null = legend(target=[p2,p3,p4], position=[0.2,0.3]) 

p2.xrange=[120,325]
p2.yrange=[120,325]
p5=plot([120,325], [120,325], /overplot)


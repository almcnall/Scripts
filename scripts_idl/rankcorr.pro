pro rankcorr

;correlate the monthly cubes that I make in make_moncube_API...

;nfile = file_search('/jabber/chg-mcnally/filterNDVI_sahel/moncubie/stack*img')
;afile = file_search('/jabber/LIS/Data/API_sahel/moncubie/stack*.img')
vfile = file_search('/jabber/chg-mcnally/AMMAVeg/mask_bare75_sahel.img')
;crap i accidently edited these....do i want n=12,36 or 108? there are 12 
nfile = file_search('/jabber/chg-mcnally/filterNDVI_sahel/moncubie/stack_SMest.img')
afile = file_search('/jabber/LIS/Data/API_sahel/moncubie/stack_API_sahel.img')

nx = 720
ny = 350
nz = 12
;nz = 108
;nz = 36

apicube = fltarr(nx,ny,nz)
smncube = fltarr(nx,ny,nz)
cormap  = fltarr(nx,ny,2);the value and the significance are in 3d
Kcormap  = fltarr(nx,ny,2);kendall rather than default spearman

openr,1,vfile
readu,1,vegmask
close,1
vegmask(where(vegmask eq 0.))=!values.f_nan

openr,1,nfile
readu,1,smncube
close,1

openr,1,afile
readu,1,apicube
close,1
;
;for x = 0, nx-1 do begin &$
;  for y = 0,ny -1 do begin &$
;   good = where(finite(apicube[x,y,*]), count) &$
;   if count le 0 then continue &$
;   print,count,x,y &$
;   cormap[x,y,*] = r_correlate(apicube[x,y,*],smncube[x,y,*]) &$
;   Kcormap[x,y,*] = r_correlate(apicube[x,y,*],smncube[x,y,*], /KENDALL) &$
;  endfor &$
;endfor

;ofile = '/jabber/chg-mcnally/cormapJJA_spermanAPI_NDVIfilter.img'
;openw,1,ofile
;writeu,1,cormap
;close,1
;
;ofile = '/jabber/chg-mcnally/cormapJJA_KendallAPI_NDVIfilter.img'
;openw,1,ofile
;writeu,1,Kcormap
;close,1
;
vfile = file_search('/jabber/chg-mcnally/AMMAVeg/mask_bare75_sahel.img')
ifile = file_search('/jabber/chg-mcnally/cormapJJA_KendallAPI_NDVIfilter.img')
;ifile = file_search('/jabber/chg-mcnally/cormapJJA_spermanAPI_NDVIfilter.img')

nx = 720
ny = 350
nz = 108

vegmask = fltarr(nx,ny)
cormap  = fltarr(nx,ny,2);the value and the significance are in 3d
Kcormap  = fltarr(nx,ny,2);kendall rather than default spearman

openr,1,ifile
readu,1,cormap
close,1

openr,1,vfile
readu,1,vegmask
close,1
vegmask(where(vegmask eq 0.))=!values.f_nan

pos = cormap[*,*,0]
good = where(cormap[*,*,0] gt 0,complement=neg)
pos(neg) = !values.f_nan
pos = pos*vegmask 

sig = where(cormap[*,*,1] le 0.01, complement = insig)
pos(insig) = !values.f_nan

p1 = image(pos, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 20)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

  
  
;******also try the monthly rank correlations!********
;not sure if I am doing this once correctly either. but at least now I have monthly data
;*****************************************************
afile = file_search('/jabber/LIS/Data/API_sahel/monthly/API_sahel_moncubieJJA.img')
nfile = file_search('/jabber/chg-mcnally/filterNDVI_sahel/monthly/SMest_moncubieJJA.img')
vfile = file_search('/jabber/chg-mcnally/AMMAVeg/mask_bare75_sahel.img')

nx = 720
ny = 350
nz = 12

vegmask = fltarr(nx,ny)
apigrid = fltarr(nx,ny,nz)
esmgrid = fltarr(nx,ny,nz)
cormap  = fltarr(nx,ny,2);the value and the significance are in 3d
Kcormap  = fltarr(nx,ny,2);kendall rather than default spearman

openr,1,vfile
readu,1,vegmask
close,1
vegmask(where(vegmask eq 0.))=!values.f_nan

openr,1,afile
readu,1,apigrid
close,1

openr,1,nfile
readu,1,esmgrid
close,1

for x = 0, nx-1 do begin &$
  for y = 0,ny -1 do begin &$
   good = where(finite(apigrid[x,y,*]), count) &$
   if count le 0 then continue &$
   print,count,x,y &$
   cormap[x,y,*] = r_correlate(apigrid[x,y,*],esmgrid[x,y,*]) &$
   Kcormap[x,y,*] = r_correlate(apigrid[x,y,*],esmgrid[x,y,*], /KENDALL) &$
  endfor &$
endfor

pos = cormap[*,*,0]
good = where(cormap[*,*,0] gt 0,complement=neg)
pos(neg) = !values.f_nan
pos = pos*vegmask 

sig = where(cormap[*,*,1] le 0.05, complement = insig)
pos(insig) = !values.f_nan

bin = where(finite(pos))
pos(bin) = 999.


p1 = image(pos, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 20)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

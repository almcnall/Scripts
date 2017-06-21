pro Noah_inputs

;the purpose of this script is to prep all the Noah input forcing and params for easy investigation over the sahel domain
;i think clip_globe2sahel will be useful
;revisit 10/1/14 to see if there is anythign useful re: GVF here

;mask by ROI

;mask by ROIs
ifile = file_search('/home/sandbox/people/mcnally/yemen_shp/YM_agzone_294x384')
;ifile = file_search('/home/sandbox/people/mcnally/yemen_shp/YM_agzone_300x320')
;nx = 300
;ny = 320

nx = 294
ny = 348

agzn = bytarr(nx,ny)
openr,1,ifile
readu,1,agzn
close,1
agzn = reverse(agzn,2)

;1=arabian sea      2=desert
;3=highlands        4=temperate highlands
;5=internal plateau 6=redsea
;subset the areas in the red& highx2
mask = fltarr(nx,ny)
good = where(agzn eq 3 OR agzn eq 4 OR agzn eq 6, complement=other)
mask(good)=1
mask(other)=!values.f_nan
;make this match the file of interest...
mask = rebin(mask,nx,ny,24)

mask3 = fltarr(nx,ny)
good = where(agzn eq 3, complement=other)
mask3(good)=1
mask3(other)=!values.f_nan
;make this match the file of interest...
mask3 = rebin(mask,nx,ny,12)

mask4 = fltarr(nx,ny)
good = where(agzn eq 4, complement=other)
mask4(good)=1
mask4(other)=!values.f_nan
;make this match the file of interest...
mask4 = rebin(mask,nx,ny,12)

;*******************read in all of the parameter files*****************
;now I think they are all in this netcdf file
ifile = file_search('/home/sandbox/people/mcnally/lis_input.noah33_eaoct2nov.nc')
;select the greenveg fraction
fileID = ncdf_open(ifile) &$
gvfID = ncdf_varid(fileID,'GREENNESS') &$
ncdf_varget,fileID, gvfID, GVF

gvf(where(gvf lt -999.))=!values.f_nan

;for regions 3,4,6
yemenGVF = GVF*mask
y3GVF = GVF*mask3
y4GVF = GVF*mask4

;there seems to be no fine distinctions in this part of yemen
; I should do the same thing for the WRSI mask
p1 = plot(mean(mean(yemenGVF,dimension=1,/nan),dimension=1,/nan))
p2 = plot(mean(mean(y3GVF,dimension=1,/nan),dimension=1,/nan), /overplot, 'b')
p3 = plot(mean(mean(y4GVF,dimension=1,/nan),dimension=1,/nan), /overplot, 'b')

xticks = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'] & print, xticks
p1.xTICKNAME = string(xticks)
p1.xminor = 0
p1.yminor = 0
p1.xtickinterval = 1

;can I compare this to NDVI?
;using the NAVE and NMAX from the CHIRPS_NDVI_EA 
yemenNDVI = NAVE*mask
ts = mean(mean(yemenNDVI,dimension=1,/nan),dimension=1,/nan)
anom = ts-mean(ts)
tmpplt = barplot(anom, /overplot, 'b')








;sndfile = file_search('/jower/LIS/data/UMD/10KM/sand_FAO.1gd4r')
;clyfile = file_search('/jower/LIS/data/UMD/10KM/clay_FAO.1gd4r')
;txtfile = file_search('/jower/LIS/RUN/UMD/10KM/soiltexture_STATSGO-FAO.1gd4r')
;umdfile = file_search('/jower/LIS/RUN/UMD/10KM/landcover_UMD.1gd4r')
;elvfile = file_search('/jower/LIS/RUN/UMD/10KM/elev_GTOPO30.1gd4r')
;see albedo and gvf below....

mo = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec']

NX = 3600
NY = 1500
NZ = 13

buffer = fltarr(nx,ny)
sndgrid = fltarr(NX,NY)
clygrid = fltarr(NX,NY)
umdgrid = fltarr(nx,ny,nz)
elvgrid = fltarr(nx,ny)
albgrid = fltarr(nx,ny,12)
grngrid = fltarr(nx,ny,12)

openr,1,sndfile
readu,1,sndgrid
close,1
byteorder,sndgrid,/XDRTOF

openr,1,clyfile
readu,1,clygrid
close,1
byteorder,clygrid,/XDRTOF

openr,1,umdfile
readu,1,umdgrid
close,1
byteorder,umdgrid,/XDRTOF

openr,1,elvfile
readu,1,elvgrid
close,1
byteorder,elvgrid,/XDRTOF

for i = 0,n_elements(mo)-1 do begin &$
 albfile = file_search('/jower/LIS/RUN/UMD/10KM/albedo_NCEP.'+mo[i]+'.1gd4r') &$
 openr,1,albfile &$
 readu,1,buffer &$
 close,1 &$
 byteorder,buffer,/XDRTOF &$
 albgrid[*,*,i] = buffer &$

 grnfile = file_search('/jower/LIS/RUN/UMD/10KM/gvf_NCEP.'+mo[i]+'.1gd4r') &$
 openr,1,grnfile &$
 readu,1,buffer &$
 close,1 &$
 byteorder,buffer,/XDRTOF &$
 grngrid[*,*,i] = buffer &$
endfor  

;****clip to the sahel window************
;bottom is at 60...
w = ((180-20)*10)
e = ((180+52)*10)-1
s = (60-5)*10 ;60 is the eqautor...
n = ((60+30)*10)-1

;soil window
sndsahl = sndgrid[w:e,s:n]
clysahl = clygrid[w:e,s:n]
umdsahl = umdgrid[w:e,s:n,*]
elvsahl = elvgrid[w:e,s:n]
albsahl = albgrid[w:e,s:n,*]
grnsahl = grngrid[w:e,s:n,*]
bbgrn = congrid(reform(grnsahl[bxind,byind,*]),36)

;sahel(where(sahel lt 0)) = !values.f_nan
;*****************************************
;clip out and save file so that i can make the FC and WP maps
ofile = strcompress('/jabber/chg-mcnally/gvf_12mo_10KMsahel.1gd4r', /remove_all)
openw,1,ofile
writeu,1,grnsahl
close,1

;*****************look at forcing vars***************
grnsahl(where(grnsahl lt 0)) = !values.f_nan
p1 = image(mean(grnsahl[*,*,5:9],dimension=3, /nan), rgb_table=4)

sndsahl(where(sndsahl lt 0)) = !values.f_nan
p1 = image(sndsahl*rmask, rgb_table=4)

clysahl(where(clysahl lt 0)) = !values.f_nan
p1 = image(clysahl*rmask, rgb_table=4)

ncolors=256           
p1 = image(mean(grnsahl[*,*,5:9],dimension=3, /nan), image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=20)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
p1.title = 'Average NCEP GVF Jun-October ' 
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])  

;***green vegfraction*****
p1=plot(grnsahl[axind,ayind,*], name = 'AG, Mali', thick = 3)
p2=plot(grnsahl[wxind,wyind,*], name = 'WK, Niger', 'orange', /overplot, thick=3)
p3=plot(grnsahl[bxind,byind,*], name = 'BB, Benin', 'b', /overplot, thick=3)
xtickvalues=indgen(12)
xtickname = mo
p1.xtickname=xtickname
p1.xtickvalues=xtickvalues
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) 
;
;**************************look at water balance**************
pfile = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/dekadal/Rainf_*.img')
efile = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/dekadal/Evap*.img')
rfile = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/dekadal/Qsuf*.img')
s1file = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/dekadal/Sm01*.img')
tfile = file_search('/jower/sandbox/mcnally/fromKnot/EXP02/dekadal/TVeg*.img')

nx = 720
ny = 250
buffer=fltarr(nx,ny)
raingrid = fltarr(nx,ny,n_elements(pfile))
evapgrid = fltarr(nx,ny,n_elements(efile))
runogrid = fltarr(nx,ny,n_elements(rfile))
sm01grid = fltarr(nx,ny,n_elements(s1file))
tveggrid = fltarr(nx,ny,n_elements(tfile)) ; this might be ugly...what is the diff w/ the umd runs?

for i = 0,n_elements(pfile)-1 do begin &$  
  openr,1,pfile[i]  &$
  readu,1,buffer &$
  close,1 &$
  raingrid[*,*,i]=buffer &$
  
  openr,1,efile[i] &$
  readu,1,buffer &$
  close,1 &$
  evapgrid[*,*,i] = buffer &$

  openr,1,rfile[i] &$
  readu,1,buffer &$
  close,1 &$
  runogrid[*,*,i] = buffer &$
  
  openr,1,s1file[i] &$
  readu,1,buffer &$
  close,1 &$
  sm01grid[*,*,i] = buffer &$
  
  openr,1,tfile[i] &$
  readu,1,buffer &$
  close,1 &$
  tveggrid[*,*,i] = buffer &$
endfor
;check and make sure the data looks ok
;Wankama 2006 - 2011
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5.) / 0.10)

;Belefoungou-Top 9.79506     1.71450  
bxind = FLOOR((1.7145 + 20.) / 0.10)
byind = FLOOR((9.79506 + 5) / 0.10)

raincube = reform(raingrid,nx,ny,36,11)
evapcube = reform(evapgrid,nx,ny,36,11)
runocube = reform(runogrid,nx,ny,36,11)
tvegcube = reform(tveggrid,nx,ny,36,11)

;which parts of the rainy season am i interested in? I was doing this with monthly data before...

;*******************the annual water balance ************************
;*******I don't think this is good to look at**************************
;*****************the rainyr goes from march to march....
;rainyr = fltarr(36,11)
rainyr=fltarr([nx,ny,11])
for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
   for i = 0,10 do begin &$
    if i eq 10 then rainyr[x,y,i] = total(reform(raincube[x,y,*,i]), /nan)*86400 &$
    if i eq 10 then continue &$
    rainyr[x,y,i] = total([ reform(raincube[x,y,6:35,i]),reform(raincube[x,y,0:5,i+1])], /nan)*86400 &$
  endfor &$
endfor 

evapyr=fltarr([nx,ny,11])
for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
   for i = 0,10 do begin &$
    if i eq 10 then evapyr[x,y,i] = total(reform(evapcube[x,y,*,i]), /nan)*86400 &$
    if i eq 10 then continue &$
    evapyr[x,y,i] = total([ reform(evapcube[x,y,6:35,i]),reform(evapcube[x,y,0:5,i+1])], /nan)*86400 &$
  endfor &$
endfor 

runoyr=fltarr([nx,ny,11])
for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
   for i = 0,10 do begin &$
    if i eq 10 then runoyr[x,y,i] = total(reform(runocube[x,y,*,i]), /nan)*86400 &$
    if i eq 10 then continue &$
    runoyr[x,y,i] = total([ reform(runocube[x,y,6:35,i]),reform(runocube[x,y,0:5,i+1])], /nan)*86400 &$
  endfor &$
endfor 


tvegyr=fltarr([nx,ny,11])
for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
   for i = 0,10 do begin &$
    if i eq 10 then tvegyr[x,y,i] = total(reform(tvegcube[x,y,*,i]), /nan)*86400 &$
    if i eq 10 then continue &$
    tvegyr[x,y,i] = total([ reform(tvegcube[x,y,6:35,i]),reform(tvegcube[x,y,0:5,i+1])], /nan)*86400 &$
  endfor &$
endfor 
;the problem with looking that the whole season is that Noah doesn't do the dry season well....
p1=plot((runoyr[wxind,wyind,*]/ rainyr[wxind,wyind,*])*100)
p1=plot((evapyr[wxind,wyind,*]/ rainyr[wxind,wyind,*])*100, /overplot, 'b')
;***what percent of precip is WRSI-AET?********


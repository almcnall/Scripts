pro sahel_stm

;the purpose of this program is to calculate the short term dekadal means for 
;comparing noah and api and ndvi filter anomalies..maybe I should skip 
;the anomalies to start to see how the means do

;*********make short term mean maps for calculating anomalies**********************************
file02 = '/jower/sandbox/mcnally/EXPA46_dekads/sm02/sm02_stack2001_2011.img'
num = file_search('/jower/sandbox/mcnally/EXPA46_dekads/sm02/2*img');363 10 yrs +3 extras...prolly zeros/nans
afile = file_search('/jabber/Data/mcnally/API_soilmoisture_2001_2011.img');nx,ny,396
anum = file_search('/jabber/LIS/Data/API_sahel/APIsahel_*')
vfile = file_search('/jabber/Data/mcnally/filterNDVI_soilmoisture_2001_2011.img');cube of filtered NDVI


nx = long(720)
ny = long(350)
nz = long(n_elements(num))
anz = long(n_elements(anum))

apigrid = fltarr(nx,ny,anz-2)
filtergrid = fltarr(nx,ny,anz-6)
ningrid = fltarr(nx,ny,nz)

cormap1 = fltarr(nx,ny)
cormap2 = fltarr(nx,ny)
cormap3 = fltarr(nx,ny)

openr,1, file02
readu,1, ningrid
close,1

openr,1, afile
readu,1, apigrid
close,1

openr,1, vfile
readu,1, filtergrid
close,1

ningrid = ningrid[*,*,0:359]
apigrid = apigrid[*,*,0:359]
veggrid = filtergrid[*,*,0:359]

for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    ;rsq1 = correlate(ningrid[x,y,*], apigrid[x,y,*]) &$
    rsq2 = correlate(ningrid[x,y,*], veggrid[x,y,*]) &$
    rsq3 = correlate(apigrid[x,y,*], veggrid[x,y,*]) &$
    ;rsq = correlate(apigrid[xind,yind,*], filtered[xind,yind,*]) &$
    cormap1[x,y] = rsq1 &$
    cormap2[x,y] = rsq2 &$
    cormap3[x,y] = rsq3 &$
  endfor &$
endfor

;**********************STMS*******************************
sm02stm = mean(reform(ningrid,nx,ny,36,10),dimension=4,/nan)
apistm = mean(reform(apigrid,nx,ny,36,10),dimension=4,/nan)
vegstm = mean(reform(veggrid,nx,ny,36,10),dimension=4,/nan)

;****************check out the correlations with the STMS********           
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    rsq1 = correlate(sm02stm[x,y,*], apistm[x,y,*]) &$
    rsq2 = correlate(sm02stm[x,y,*], vegstm[x,y,*]) &$
    rsq3 = correlate(apistm[x,y,*], vegstm[x,y,*]) &$
    
    cormap1[x,y] = rsq1 &$
    cormap2[x,y] = rsq2 &$
    cormap3[x,y] = rsq3 &$
  endfor &$
endfor

mask = where(cormap1 lt 0.5)
cormap1(mask) = !values.f_nan

mask = where(cormap2 lt 0.5)
cormap2(mask) = !values.f_nan

MASK = WHERE(CORMAP3 LT 0.5)
CORMAP3(MASK) = !VALUES.F_NAN

p1 = image(cormap2, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 20)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  p1.title = 'correlation between NOAH stm and NDVI-filter stm' 

;*******calcualte anomalies*********
apianom = fltarr(nx,ny,360)
veganom = fltarr(nx,ny,360)
sm02anom = fltarr(nx,ny,360)

cnt=0
;go through each dekad for the 10yrs
for f = 0,359 do begin &$
;take the stms
  if cnt eq 36 then cnt = 0 &$
  api    = apistm[*,*,cnt] &$
  filter = vegstm[*,*,cnt] &$
  noahsm = sm02stm[*,*,cnt] &$

;subtract the stms from the full grids 
  apianom[*,*,f]  = apigrid[*,*,f] - api &$
  veganom[*,*,f]  = veggrid[*,*,f] - filter &$
  sm02anom[*,*,f] = ningrid[*,*,f] - noahsm &$
  
  cnt++ &$
  
endfor   

;****************check out the correlations with the STMS********           
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    ;rsq1 = correlate(sm02anom[x,y,*], apianom[x,y,*]) &$
    ;rsq2 = correlate(sm02anom[x,y,*], veganom[x,y,*]) &$
    rsq3 = correlate(apianom[x,y,*], veganom[x,y,*]) &$
    
    ;cormap1[x,y] = rsq1 &$
    ;cormap2[x,y] = rsq2 &$
    cormap3[x,y] = rsq3 &$
  endfor &$
endfor

mask = where(cormap1 lt 0.5)
cormap1(mask) = !values.f_nan

mask = where(cormap2 lt 0.3)
cormap2(mask) = !values.f_nan

MASK = WHERE(CORMAP3 LT 0.3)
CORMAP3(MASK) = !VALUES.F_NAN

p1 = image(cormap3, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 20)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  p1.title = 'correlation between API anom and filtered NDVI anom'
;*****************check*************
temp = image(mean(ingrid,dimension = 3, /nan), rgb_table = 20)
;Wankama Niger
wxind = FLOOR((2.633 + 20.) / 0.10)
wyind = FLOOR((13.6454 + 5) / 0.10)

;Mpala Kenya:
mxind = FLOOR((36.8701 + 20.) / 0.10)
myind = FLOOR((0.4856 + 5) / 0.10)

;;KLEE Kenya
kxind = FLOOR((36.8669 + 20.) / 0.10)
kyind = FLOOR((0.2825 + 5) / 0.10)

temp = plot(sm02stm[wxind,wyind,*])
temp = plot(sm02stm[mxind,myind,*], thick=3)
temp = plot(sm02stm[kxind,kyind,*], 'g', /overplot,thick=3)

temp = plot(apianom[wxind,wyind,*], thick=3)
temp = plot(veganom[wxind,wyind,*], thick=3, /overplot,'b')
temp = plot(sm02anom[wxind,wyind,*]/1000, 'g', /overplot,thick=3)
;looks like api and noah anomalies are highly correlated here....


;***********************************************


pad = fltarr(nx,ny,2)
pad[*,*,*] = !values.f_nan
apipad = [[[apigrid]], [[pad]]]

apistm = mean(reform(apipad,nx,ny,36,11),dimension=4,/nan)
apicube = reform(apipad,nx,ny,36,11)



;does this really do it?
pad = fltarr(nx,ny,6)
filterpad = [[[filtered]], [[pad]]]
filterstm = mean(reform(filterpad,nx,ny,36,11),dimension=4,/nan)
filtercube = reform(filterpad,nx,ny,36,11)
;calculate the Sept 2003 and Sept 2009 anomalies (25-27)
api2003 = (apicube[*,*,26,2]-apistm[*,*,26])*wmask 
filter2003 = (filtercube[*,*,26,2]-filterstm[*,*,26])*wmask 
api2009 = (apicube[*,*,26,8]-apistm[*,*,26])*wmask 
filter2009 = (filtercube[*,*,26,8]-filterstm[*,*,26])*wmask 

 minx = min([api2003,api2009,filter2003,filter2009],/nan) & print, minx
 ;maxx = max([api2003,api2009,filter2003,filter2009],/nan) & print, maxx
 maxx = 0.05
 api2003[0,0] = minx 
 api2009[0,0] = minx
 filter2003[0,0] = minx
 filter2009[0,0] = minx
  api2003[1,0] = maxx 
 api2009(where(api2009 gt maxx))=maxx
 ;filter2003[1,0] = maxx
 filter2009(where(filter2009 gt maxx)) = maxx
 filter2003(where(filter2003 gt maxx)) = maxx
 
p1 = image(filter2003, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 10)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])             
p1.title = 'Filtered NDVI 2003 Anomaly'
p1.title.font_size = 16
p1.save,strcompress('/jabber/sandbox/mcnally/'+p1.title.string+'.jpg', /remove_all),RESOLUTION=200
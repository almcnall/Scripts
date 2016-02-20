pro corr_api_ndvi_ubrfe

;the purpose of this script is to correlate the api, ndvi-sm, and ndvi-precip cubes
;also see corr_rain_NDVI.pro
;I need the ndvi cube, the precip cube (if I am going to redo them
;I'll also need the API and NDVI_est_SM cube
;revist on 10/3/2013 to see if we can include the MW in the mix. must stay focused :)


;*******include the MW in the correlation mix
;Introduce the microwave soil moisture, how does it compare to obserations & what do coefficients look like?

afile = file_search('/raid/chg-mcnally/API_2001_2012_sahel_v2.img')
ffile = file_search('/raid/chg-mcnally/filterNDVI_soilmoisture_2001Jan_2012Oct_lag2.img')
mfile = file_search('/raid/chg-mcnally/ECV_microwaveSM_dekadal.2001.2010.img')
nx = 720
ny = 350
nz = 428

apigrid = fltarr(nx,ny,nz)
filter  = fltarr(nx,ny,425)
cormapAN = fltarr(nx,ny)
cormapAM = fltarr(nx,ny)
cormapNM = fltarr(nx,ny)
mwgrid = fltarr(nx,ny,36,10)

openr,1,mfile
readu,1,mwgrid
close,1

openr,1,afile
readu,1,apigrid
close,1

openr,1,ffile
readu,1,filter
close,1

;fitst make everything only 2001-2010
apigrid = apigrid[*,*,0:359]
nsmgrid = filter[*,*,0:359]
mwgrid = reform(mwgrid,nx,ny,360)

;reform everything to only look at summer months. May-October? 13-28
apicube = reform(apigrid,nx,ny,36,10)
nsmcube = reform(nsmgrid,nx,ny,36,10)
mwcube  = reform(mwgrid,nx,ny,36,10)

apiSUM = reform(apicube[*,*,12:27,*],nx,ny,160)
nsmSUM = reform(nsmcube[*,*,12:27,*],nx,ny,160)
mwSUM  = reform(mwcube[*,*,12:27,*],nx,ny,160)


;;correlate apigrid and filtered grid and see what we get....

for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    rsqAN = correlate(apiSUM[x,y,*], nsmSUM[x,y,*]) &$
    rsqAM = correlate(apiSUM[x,y,*], mwSUM[x,y,*]) &$
    rsqNM = correlate(nsmSUM[x,y,*], mwSUM[x,y,*]) &$
    cormapAN[x,y] = rsqAN &$
    cormapAM[x,y] = rsqAM &$
    cormapNM[x,y] = rsqNM &$
  endfor &$
endfor


ofile = '/raid/chg-mcnally/NSM_APIcorr_2001_2010.img'
openw,1,ofile
writeu,1,cormapAN
close,1

ofile = '/raid/chg-mcnally/MW_APIcorr_2001_2010.img'
openw,1,ofile
writeu,1,cormapAM
close,1

ofile = '/raid/chg-mcnally/NSM_MWcorr_2001_2010.img'
openw,1,ofile
writeu,1,cormapNM
close,1

;********the standard NDVI cummulative rainfall correlation plot- repeat nicholson/others******
;map the 4 dek cummulative rainfall & ndvi, maybe check....
;read in UBRFE -- do I have this for RFE2 as well?
;read in the big cube of rainfall data so i can check out the correponding timeseries.
ifile = file_search('/jabber/LIS/Data/ubRFE2/dekads/sahel/*.img')
;ifile = file_search('/jabber/LIS/Data/CPCOriginalRFE2/dekads/sahel/*.img')

nx = 720
ny = 350
nz = 396

ingrid = fltarr(nx,ny)
ubcube = fltarr(nx,ny,nz)

for i = 0,n_elements(ifile)-1 do begin &$
  ;i = 0
  openr,1,ifile[i]  &$
  readu,1,ingrid &$
  close,1 &$
  
  ubcube[*,*,i] = ingrid &$
endfor

;add up the current + three previous dekads (nicholson says 3 previous months (9deks!)...how do i decide?)
sumrain = fltarr(nx,ny,nz)
sumrain[*,*,*] = !values.f_nan
;highest lag0 correlation at current+9 dekads of rainfall
for d = 7,nz-1 do begin &$
  sumrain[*,*,d] = total(ubcube[*,*,d-7:d],3,/nan) &$
endfor

;read in the NDVI cube to investigate correlation with cummulative rainfall
nfile = file_search('/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/sahel/data*.img')
ingrid = fltarr(nx,ny)
ncube = fltarr(nx,ny,nz)
for n = 0,n_elements(nfile)-1 do begin &$
  openr,1,nfile[n] &$
  readu,1,ingrid &$
  close,1  &$
  ncube[*,*,n] = ingrid &$
  
endfor

cor = fltarr(nx,ny)
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    cor[x,y] = correlate(sumrain[x,y,7:387],ncube[x,y,7:387]) &$
  endfor &$
endfor

ofile = '/jabber/Data/mcnally/NDVI_UBRFcorr.img'
openw,1,ofile
writeu,1,cor
close,1



  p1 = image(cor, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table=20)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  p1.title = 'correlation between NDVI and current + 7 dekads of UBRFE2 rainfall'
  p1.title.font_size = 14
;test = image(ingrid, rgb_table = 4)
xind = FLOOR((2.633 + 20.) / 0.10)
yind = FLOOR((13.6454 + 5) / 0.10)
temp = plot(ncube[xind,yind,*])

  
lag=[0,1,2,3,4,5]
print, c_correlate(sumrain[xind,yind,9:387],ncube[xind,yind,9:387],lag);
print, c_correlate(ubcube[xind,yind,3:390],ncube[xind,yind,3:390],lag); 5 lag for rain and ndvi

;read in FCLIM data to make annual rainfall total mask (how would I plot contours?)
fx = 1501
fy = 1601
fz = 12
climgrid = LONARR(fx,fy,fz)

climfile = file_search('/jabber/LIS/Data/FCLIM_Afr/*.img')
openr,1, climfile
readu,1, climgrid
close,1

climgrid = float(climgrid[*,*,*])
null = where(climgrid lt 0, count) & print, count
climgrid(null) = !values.f_nan
totclim = reverse(total(climgrid,3, /nan),2)
temp = image(totclim, rgb_table=20)

;matches up correctly
totclimCoarse = congrid(totclim, 751,801)
xrt = (751-1)-3/0.1  ;RFE goes to 55, sahel goes to 52 plus an extra pixel
ybot = (35/0.1)+1    ;sahel starts at -5S
ytop = (801-1)-10/0.1  ; &$sahel stops at 30N
xlt = 1.              ;and I guess sahel starts at 19W, rather than 20....
sahel = totclimcoarse[xlt:xrt,ybot:ytop] 

out = where(sahel gt 1200. OR sahel lt 150., complement = in, count) & print, count
mask = intarr(nx,ny)
mask(in) = 1
mask(out) = 0

ofile = '/jabber/Data/mcnally/FCLIMshael_rainmask4NDVI.img'
;openw,1,ofile
;writeu,1,mask
;close,1


maskedcor = cor*mask
  p1 = image(maskedcor, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table=20)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  p1.title = 'correlation between NDVI and current + 7 dekads of UBRFE2 rainfall (150-1200mm annual rainfall)'
  p1.title.font_size = 24

;*******from the other script...may be duplicate
;this can/should get moved over to the plot section when i see what works.
;?is the API KLEE with 3 or 6 dekads? the csv file is with 3...how bout the map?
amfile = file_search('/jabber/LIS/Data/ubRFE2/dekads/horn/horn_API_2001_2012vMpala3v2.img'); funny intercept
nffile = file_search('/jabber/chg-mcnally/filterNDVI_soilmoisture_2001_2012_Mpala.img');
;amfile = file_search('/jabber/LIS/Data/ubRFE2/dekads/horn_API_2001_2012vKLEE3.img')
;nffile = file_search('/jabber/Data/mcnally/filterNDVI_soilmoisture_2001_2011_KLEE.img');

nx = 250
ny = 350
nz = 428
nnz = 425 ; i should prolly this so that it is 425
api = fltarr(nx,ny,nz)

openr,1,amfile
readu,1,api
close,1

;make api the same length as the NDVI SM est
api = api[*,*,0:nnz-1]

filter = fltarr(nx,ny,nnz)
openr,1,nffile
readu,1,filter
close,1

cormap = fltarr(nx,ny)
for X = 0,NX-1 do begin &$
  for Y = 0,NY-1 do begin &$
     rsq = correlate(api[x,y,*], filter[x,y,*]) &$
     cormap[x,y] = rsq &$
  endfor &$
endfor
cormap2=cormap
mve, cormap2(where(finite(cormap2)))
mask = where(cormap2 lt 0.5)
cormap2(mask) =  !values.f_nan

p1 = image(cormap2, image_dimensions=[25.0,35.0], image_location=[27,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 20)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
p1 = MAP('Geographic',LIMIT = [-5, 27, 30, 52], /overplot)
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])  

;*****correlate the niger, mpala and Klee maps over the horn***********
;****grab the API estimates from the different maps******
;*****had I already pulled the local NDVI somewhere?*****

anfile = file_search('/jabber/LIS/Data/ubRFE2/dekads/horn_API_2001_2012NP.img')
amfile = file_search('/jabber/LIS/Data/ubRFE2/dekads/horn_API_2001_2012MP.img')
akfile = file_search('/jabber/LIS/Data/ubRFE2/dekads/horn_API_2001_2012KP.img')

nnfile = file_search('/jabber/chg-mcnally/filterNDVI_soilmoisture_2001_2012_WANK.HORN.img')
nkfile = file_search('/jabber/chg-mcnally/filterNDVI_soilmoisture_2001_2012_KLEE.img')
nmfile = file_search('/jabber/chg-mcnally/filterNDVI_soilmoisture_2001_2012_Mpala.img')


kfile = file_search('/jabber/chg-mcnally/AMMASOIL/KLEE_dekad.csv')
mfile = file_search('/jabber/chg-mcnally/AMMASOIL/Mpala_dekad.csv')

nx = 250
ny = 350
anz = 428
nnz = 425

NPhorn = fltarr(nx,ny,nnz)
KPhorn = fltarr(nx,ny,nnz)
MPhorn = fltarr(nx,ny,nnz)

aNPhorn = fltarr(nx,ny,anz)
aKPhorn = fltarr(nx,ny,anz)
aMPhorn = fltarr(nx,ny,anz)

openr,1,nnfile
readu,1,NPhorn
close,1

openr,1,nkfile
readu,1,KPhorn
close,1

openr,1,nmfile
readu,1,MPhorn
close,1

openr,1,anfile
readu,1,aNPhorn
close,1

openr,1,akfile
readu,1,aKPhorn
close,1

openr,1,amfile
readu,1,aMPhorn
close,1

;correlate the niger estimates 
ncormap = fltarr(nx,ny)
for X = 0,NX-1 do begin &$
  for Y = 0,NY-1 do begin &$
     rsq = correlate(aNPhorn[x,y,0:424], NPhorn[x,y,*]) &$
     ncormap[x,y] = rsq &$
  endfor &$
endfor


;correlate the Mpala estimates 
mcormap = fltarr(nx,ny)
for X = 0,NX-1 do begin &$
  for Y = 0,NY-1 do begin &$
     rsq = correlate(aMPhorn[x,y,0:424], MPhorn[x,y,*]) &$
     mcormap[x,y] = rsq &$
  endfor &$
endfor

;correlate the KLEE estimates 
kcormap = fltarr(nx,ny)
for X = 0,NX-1 do begin &$
  for Y = 0,NY-1 do begin &$
     rsq = correlate(aKPhorn[x,y,0:424], KPhorn[x,y,*]) &$
     kcormap[x,y] = rsq &$
  endfor &$
endfor
diff = ncormap-mcormap
cormap2=diff
mve, cormap2(where(finite(cormap2)))
mask = where(cormap2 lt 0.5)
cormap2(mask) =  !values.f_nan

p1 = image(diff, image_dimensions=[25.0,35.0], image_location=[27,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 6, title = 'Niger minus Mpala')
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
p1 = MAP('Geographic',LIMIT = [-5, 27, 30, 52], /overplot)
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0, 0, 120])

ofile = 

mobs = read_csv(mfile)
mobs = float(mobs.field1)

kobs = read_csv(kfile)
kobs = float(kobs.field1)

;Mpala Kenya:
mxind = FLOOR((36.8701 - 27.) / 0.10);this says cor is 0.67...
myind = FLOOR((0.4856 + 5) / 0.10)

;KLEE
kxind = FLOOR((36.8669 - 27.) / 0.10)
kyind = FLOOR((0.2825 + 5) / 0.10)

pad = fltarr(1,1,4)
pad[*,*,*] = !values.f_nan

pNPhorn = [[[NPhorn[mxind,myind,360:427]]], [[pad]]] & help, pNPhorn
pKPhorn = [[[KPhorn[mxind,myind,360:427]]], [[pad]]] & help, pKPhorn
pMPhorn = [[[MPhorn[mxind,myind,360:427]]], [[pad]]] & help, pMPhorn

p1 = plot((pNPhorn-mean(pNPhorn, /nan))*250,'r')
p2 = plot(pKPhorn-mean(pKPhorn, /nan),'g', /overplot)
p3 = plot(pMPhorn-mean(pMPhorn,/nan),'b', /overplot)
p4 = plot(mobs-mean(mobs,/nan),thick=3, /overplot)
;I need to add in the obs....I should pad them out so I see the estimates beyond the obs.

p1.title = 'Different API parameter estimates at Mpala'
p1.name = 'Niger params'
p2.name = 'KLEE params'
p3.name = 'Mpala params'
p4.name = 'obs'
null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=18) ;
p1.title.font_size = 16
p1.ytitle = '%VWC'

;*************************************************
pNPhorn = [[[NPhorn[kxind,kyind,360:427]]], [[pad]]] & help, pNPhorn
pKPhorn = [[[KPhorn[kxind,kyind,360:427]]], [[pad]]] & help, pKPhorn
pMPhorn = [[[MPhorn[kxind,kyind,360:427]]], [[pad]]] & help, pMPhorn

p1 = plot((pNPhorn-mean(pNPhorn, /nan))*250,'r')
p2 = plot(pKPhorn-mean(pKPhorn, /nan),'g', /overplot)
p3 = plot(pMPhorn-mean(pMPhorn,/nan),'b', /overplot)
p4 = plot(kobs-mean(kobs,/nan),thick=3, /overplot)
;I need to add in the obs....I should pad them out so I see the estimates beyond the obs.

p1.title = 'Different API parameter estimates at KLEE'
p1.name = 'Niger params'
p2.name = 'KLEE params'
p3.name = 'Mpala params'
p4.name = 'obs'
null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=18) ;
p1.title.font_size = 16
p1.ytitle = '%VWC'


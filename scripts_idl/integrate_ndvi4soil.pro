pro integrate_NDVI4soil

;the purpose of this program is to re-create the Nicholson and Farrar (1994) analysis for west africa
;using the eMODIS and FAO soil map. 

 ifile = file_search('/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/sahel/data*.img')
 mfile = file_search('/jabber/chg-mcnally/FCLIMshael_rainmask4NDVI.img')
 
 nx = 720
 ny = 350
 nz = (12*36)
 
 ingrid = fltarr(nx,ny)
 ndvi = fltarr(nx,ny,nz)
 ndvi[*,*,*] = !values.f_nan
 mask = intarr(nx,ny)
 
 openr,1,mfile
 readu,1,mask ;I can't remember what the mask is...150-2000mm?
 close,1
 mask = float(mask)
 
 mask(where(mask eq 0)) = !values.f_nan
  
for i = 0, n_elements(ifile)-1 do begin &$
  openr,1,ifile[i] &$
  readu,1,ingrid &$
  close,1 &$
  
  ndvi[*,*,i] = ingrid &$
endfor

ndvicube = reform(ndvi,nx,ny,36,12)
avgndvi = mean(ndvicube,dimension=4,/nan)
avgndvi = mean(avgndvi,dimension=3,/nan)
avgndvi(where(avgndvi lt 0))=!values.f_nan
avgndvi=avgndvi*mask

xind = FLOOR((2.633 + 20.) / 0.10)
yind = FLOOR((13.6454 + 5) / 0.10)

p1 = plot(ndvi[xind,yind,*])

;pool the NDVI by rainfall totals 

;pool the NDVI by FAO soil type - this seems like a good task for regression trees...
;texture or percent sand, silt, clay? I could make it continuous by using something like WP calculated 
;with the saxton PTF.
ifile = file_search('/jabber/chg-mcnally/AMMASOIL/soiltexture_STATSGO-FAO_10KMSahel.1gd4r')
 nx = 720
 ny = 350

ingrid = fltarr(nx,ny)
openr,1,ifile
readu,1,ingrid
close,1

;what is the annual NDVI for these differnt soil types?
Sand = where(ingrid eq 1)
nve, avgndvi(sand)
;this is what cappelaere says and looks about right...
LoamSnd = where(ingrid eq 2) 
nve, avgndvi(loamsnd)

;Wankama is a sandy loam according to FAO
SndLoam = where(ingrid eq 3)
nve, avgndvi(sndloam)

Sltloam = where(ingrid eq 4)
nve, avgndvi(sltloam)

Silt = where(ingrid eq 5)
nve, avgndvi(silt)

Loam = where(ingrid eq 6)
nve, avgndvi(loam)
;Mpala is a sandy clay loam...
SndClyLoam = where(ingrid eq 7)
nve, avgndvi(sndclyloam)

sltClyLoam = where(ingrid eq 8);none?
nve, avgndvi(sltclyloam)

ClyLoam = where(ingrid eq 9)
nve, avgndvi(clyloam)

SandCly = where(ingrid eq 10)
nve, avgndvi(sandcly)

SiltCly = where(ingrid eq 11)
nve, avgndvi(siltcly)

Clay = where(ingrid eq 12)
nve, avgndvi(clay)

OM = where(ingrid eq 13)
nve, avgndvi(OM)

Water = where(ingrid eq 14)
nve, avgndvi(water)

BedRk = where(ingrid eq 15)
nve, avgndvi(bedrk)

other = where(ingrid eq 16)
nve, avgndvi(other)


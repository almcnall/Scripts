pro make_FC_WP
;Make wilting point, field capacity map

;first, get the soil texture map....for africa/sahel. 
ifile = file_search('/jabber/chg-mcnally/AMMASOIL/soiltexture_STATSGO-FAO_10KMSahel.1gd4r')

nx = 720
ny = 350

ingrid = fltarr(nx,ny)

openr,1, ifile
readu,1, ingrid
close,1

WPgrid = fltarr(nx,ny)
maskgrid = fltarr(nx,ny)

MASK = where(ingrid eq 12, complement=good, count) & print, count
maskgrid(good) = 1
maskgrid(MASK) = !values.f_nan


Sand = where(ingrid eq 1)
WPgrid(sand) = 0.01

;this is what cappelaere says and looks about right...
LoamSnd = where(ingrid eq 2) 
WPgrid(loamSnd) = 0.028

;Wankama is a sandy loam according to FAO
SndLoam = where(ingrid eq 3)
WPgrid(SndLoam) = 0.047

Sltloam = where(ingrid eq 4)
WPgrid(sltloam) = 0.084

Silt = where(ingrid eq 5)
WPgrid(silt) = 0.084

Loam = where(ingrid eq 6)
WPgrid(Loam) = 0.066

;Mpala is a sandy clay loam...
SndClyLoam = where(ingrid eq 7)
WPgrid(SndClyLoam) = 0.067

sltClyLoam = where(ingrid eq 8)
WPgrid(SltClyLoam) = 0.12

ClyLoam = where(ingrid eq 9)
WPgrid(ClyLoam) = 0.103

SandCly = where(ingrid eq 10)
WPgrid(SandCly) = 0.1

SiltCly = where(ingrid eq 11)
WPgrid(SiltCly) = 0.126

Clay = where(ingrid eq 12)
WPgrid(Clay) = 0.138 ;we also know that this wiliting point is absurdly low. 

OM = where(ingrid eq 13)
WPgrid(OM) = 0.066

Water = where(ingrid eq 14)
WPgrid(Water) = 0

BedRk = where(ingrid eq 15)
;WPgrid(BedRk) = 0.006
WPgrid(BedRk) = 0.


other = where(ingrid eq 16)
WPgrid(other) = 0.028

WPgrid(where(WPgrid eq 0)) = !values.f_nan

;am i happy with this wiliting point map? would it be better to subtract out the loamy sand and reset it?

;ofile = strcompress('/jabber/chg-mcnally/WiltPoint_sahel.img', /remove_all)
;openw,1,ofile
;writeu,1,WPgrid
;close,1



;then get the WHC map, so that I can subtract the wilting point to find FC
;the units must be off hu? I use the WHC for scale (mm) while WP, FC are %
;****get WHC*******
nx = 720
ny = 350
ifile = file_search('/home/mcnally/regionmasks/WHCsahel.img')
whcgrid = bytarr(nx,ny)

openr,1,ifile
readu,1,whcgrid
close,1

whcgrid = float(whcgrid)

;ok, so what we are going to do is to get a map of porperly scaled VWC by 
;subtracting Niger WP from local WP and subtracting this from the estimated value.

;first, read in my estimates soil moisture....
ifile = file_search('/jabber/chg-mcnally/filterNDVI_sahel/filterNDVI_soilmoisture_200101_2012.10.2.img')

nx = 720
ny = 350
nz = 425 

filtered = fltarr(nx,ny,nz)
openr,1,ifile
readu,1,filtered
close,1

;If all the soils were sandy-ish then we can map then plant avaialble water...
;that means we need the annual average so cube it then take the min/max
pad = fltarr(nx,ny,7)
pad[*,*,*] = !values.f_nan
filterpad = [[[filtered]], [[pad]]]
filterpad = reform(filterpad,nx,ny,36,12)

;where are my stations? ;13.6476;2.6337;
;sahel window= 19W, 52E, -5S, 30N
xind = FLOOR((2.633 + 20.) / 0.10)
yind = FLOOR((13.6454 + 5) / 0.10)

wilt = min(filtered[*,*,*], dimension = 3, /nan)
field = max(filtered[*,*,*], dimension = 3, /nan)
avail = abs(field-wilt)

p1 = image(avail, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 4)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

;correct for the Niger wilting point 4.7% (0.047) and local wilting point (varies...)
;the observed wilting point is lower that this, but this is the FAO value for sandy loam which seemed to work in the paper.

;open the WPgrid file if necessary..../jabber/chg-mcnally/WiltPoint_sahel.img'

adjPAW = fltarr(nx,ny,nz)
;the mask masks out too much! maybe i should just mask out clay sites? and after? i wouldn't want to not gernerate data where we need it e.g. kenya
for i = 0,nz-1 do begin &$
  adjPAW[*,*,i] = filtered[*,*,i] - (0.028 - WPgrid) &$  
endfor 

p1 = image(mean(adjpaw, dimension = 3, /nan), image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 4)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

;now estimate the FC - again this will proabably only work for sites with high sand content - not sure how to mask this FAO res. might not be 
;good enought so I'll do it all for now...
FC = fltarr(nx,ny)
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    FC[x,y] = max(adjPAW[x,y,*]) &$
  endfor &$
endfor

p1 = image(diffmap, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 4)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

;my methods will really have to justify this mix of FAO and observed business....
ofile = strcompress('/jabber/chg-mcnally/FieldCapacity_sahel.img', /remove_all)
openw,1,ofile
writeu,1,FC
close,1

;ok, so that was one way to try to do things....the other is to use the actual PTF's outlined in Reynolds et al. 2000 to get a higher res
;version of the % sand, silt, clays -- not sure how much of a difference it will make. 
;saxton model from Reynolds et al. 2000
;I need to chop thse down to the sahel window...
cfile = file_search('/jabber/chg-mcnally/AMMASOIL/clay_FAO_10KMsahel.1gd4r')
sfile = file_search('/jabber/chg-mcnally/AMMASOIL/sand_FAO_10KMsahel.1gd4r')

PSAND = fltarr(nx,ny)
PCLAY = fltarr(nx,ny)

openr,1,cfile
readu,1,PCLAY
close,1
PCLAY=PCLAY*100

openr,1,sfile
readu,1,PSAND
close,1
PSAND=PSAND*100

PSIfc = 33 ;check and see what literature recommends for FC in Niger
PSIwp = 1500

PSI = PSIwp
mask = fltarr(nx,ny) 
theta = fltarr(nx,ny)

;the Saxton models is only valid for sand and clay
;percentages greater than 5%  and clay content less than 60%
;it is giving me a very narrow range of FC and WP for the different soil types.
out = where(PCLAY le 5 OR PSAND le 5 OR PCLAY gt 60, complement = good)
mask(out) = !values.f_nan
mask(good) = 1


for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$ 
    A = 100*exp(-4.396 - 0.0715*PCLAY[x,y] - 0.0004880*PSAND[x,y]^2 - 0.00004285*(PSAND[x,y]^2)*PCLAY[x,y]) &$
    B = -3.14 - 0.00222*PCLAY[x,y]^2 - 0.00003484*(PSAND[x,y]^2)*PCLAY[x,y] &$
    ;print, A, B
    ;calculating FC or WP? make sure PSI is correct
    theta[x,y] = (Psi/A)^(1/B) &$
  endfor &$
endfor  

           
  p1 = image(theta, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 20)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

;this comment is a little concerning....
;! THE FOLLOWING 5 PARAMETERS ARE DERIVED LATER IN REDPRM.F FROM THE SOIL
;!  DATA, AND ARE JUST GIVEN HERE FOR REFERENCE AND TO FORCE STATIC
;!  STORAGE ALLOCATION. -DAG LOHMANN, FEB. 2001
;
; SMCREF        ! Reference soil moisture (onset of soil moisture stress in transpiration)
; SMCWLT        ! Wilting point soil moisture content
; SMCDRY        ! Air dry soil moisture content limits
; DWSAT         ! Saturated soil diffusivity
; F1            ! Used to compute soil diffusivity/conductivity

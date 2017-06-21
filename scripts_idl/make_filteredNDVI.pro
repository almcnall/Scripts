;****MAKE THE FILTRED NDVI DATA*******************************************************
;see ndvi2soilmoisture instead of using this file.


ifile = file_search('/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/sahel/data*img')
vfile = file_search('/jabber/Data/mcnally/AMMAVeg/mask_bare75_sahel.img')

nx = 720
ny = 350
nz = n_elements(ifile)

ingrid = fltarr(nx,ny)
cube = fltarr(nx,ny,nz)
vegmask = fltarr(nx,ny)

;read in veg mask outside o' loop
openr,1,vfile
readu,1,vegmask
close,1
vegmask(where(vegmask eq 0.))=!values.f_nan

;make a big stack of ndvi files - so i have timeseries 2001-2011
for f = 0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[f] &$
  readu,1,ingrid &$
  close,1 &$
 ;mask out bare ground places....
  ingrid = ingrid*vegmask  &$
  cube[*,*,f] = ingrid &$
endfor 

;coefficents from matlab, i could solve for these in IDL just to have them all in one spot.
; Would just need avg SM and avg NDVI (36 values)
b =   [0.0005, -0.3615, 0.5924]
filtered =fltarr(nx,ny,nz-2)
;apply the ndvi filter 
for x = 0,nx -1 do begin &$
  for y = 0, ny-1 do begin &$
  if total(cube[x,y,*]) lt 0 then continue &$
  filtered[x,y,*] = b[0]+b[1]*cube[x,y,0:nz-1]+b[2]*cube[x,y,1:nz-2]  &$
  ;test = b[0]+b[1]*cube[xind,yind,0:nz-1]+b[2]*cube[xind,yind,1:nz-2]
 endfor &$
endfor
;ofile = '/jabber/Data/mcnally/filterNDVI_soilmoisture_2001_2011.img'
;openw, 1, ofile
;writeu,1, filtered
;close,1
;where are my stations? ;13.6476;2.6337;
;sahel window= 19W, 52E, -5S, 30N
xind = FLOOR((2.633 + 20.) / 0.10)
yind = FLOOR((13.6454 + 5) / 0.10)

;i should clip NDVI to horn window for the sake of speed.
;read in the horn data
nx = 250
ny = 350
nz = 426
cube = fltarr(nx,ny,nz)
ifile = '/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/horn/horn_2001_2012.img'
openr,1,ifile
readu,1,cube
close,1

cube = horn

b =   [0.0005, -86.5514, 146.980]
filtered =fltarr(nx,ny,nz-2)
;apply the ndvi filter 
for x = 0,nx -1 do begin &$
  for y = 0, ny-1 do begin &$
  if total(cube[x,y,*]) lt 0 then continue &$
  filtered[x,y,*] = b[0]+b[1]*cube[x,y,0:nz-1]+b[2]*cube[x,y,1:nz-2]  &$
  ;test = b[0]+b[1]*cube[xind,yind,0:nz-1]+b[2]*cube[xind,yind,1:nz-2]
 endfor &$
endfor

;see how it looks...
temp = image(mean(filtered,dimension=3, /nan), rgb_table=4)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
             
;I prolly shouldn't do this here but....
afile = file_search('/jabber/LIS/Data/ubRFE2/dekads/horn_API_2001_2012.img')
openr,1,afile
readu,1,api
close,1

cormap = fltarr(nx,ny)
for X = 0,NX-1 do begin &$
  for Y = 0,NY-1 do begin &$
     rsq = correlate(api[x,y,0:423], filtered[x,y,*]) &$
     cormap[x,y] = rsq &$
  endfor &$
endfor


p1 = image(cormap, image_dimensions=[25.0,35.0], image_location=[27,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 20)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
p1 = MAP('Geographic',LIMIT = [-5, 27, 30, 52], /overplot)
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])  

;I guess I should check the exact spot hu? what are the silly cordinates?
;Mpala Kenya:
xind = FLOOR((36.8701 - 27.) / 0.10);this says cor is 0.67...
yind = FLOOR((0.4856 + 5) / 0.10)


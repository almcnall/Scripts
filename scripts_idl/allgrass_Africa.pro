PRO allgrass_Africa

; this program changes all of the landcover types to grass (or crop) for the globe. 
; Africa:  20W - 55E,  40S - 40N  75 x  80   degrees      300 x 320  pixels

;UMD landcover types (13):
;0 - Evergreen needle
;1 - Evergreen broadleaf
;2 - Deciduous needle
;3 - Deciduous broadleaf
;4 - Mixed cover
;5 - Woodland
;6 - Woodland/Grassland
;7 - closed shrubland
;8 - open shrubland
;9 - grassland
;10- cropland
;11- bare
;12- urban

indir = strcompress("/jower/LIS/RUN/UMD/10KM/",/remove_all)
cd, indir

file   = file_search('landcover_UMD.1gd4r_crop') ;read in 
ofile  = strcompress('landcover_UMD.1gd4r_crop', /remove_all)        ;write out to grass file

inx   =  3600
iny   =  1500
ibands = 13

globe  = fltarr(inx,iny,ibands)
oglobe = fltarr(inx,iny,ibands)

   openu,1,file
   readu,1,globe                                ;persiann data starting at 0.125 deg chopping africa
   close,1   

byteorder,globe,/XDRTOF
mve, globe

oglobe = globe

for i = 0,ibands-1 do begin &$
  print, i &$
  if i eq 10 then oglobe[*,*,i] = 100. else oglobe[*,*,i] = 0. &$
endfor
  
  byteorder,oglobe,/XDRTOF
  openw, 2,ofile
  writeu,2,oglobe
  close,2
end
;  
;  FOR k= 0,ibands-1 DO BEGIN ; just do the rainy months
;      k=1
;      window,k,xsize=outx, ysize=outy
;      pos1 = [.05,.05,.91,.95] ;for full window

; tvim Display an image with provisions for color,plot and axis titles, oplot capability
; scaling for colors, dealing w/ invalid data, displays true color images

      ;if the viariable is blue high, red low (rainfall, runoff)
;      loadct,12,rgb_table=tmpct ;34 is rainbow, 3 is red scale
;      tmpct = reverse(tmpct,1)
;      tvlct,tmpct                 
;       
;      tvim,oglobe(*,*,0),range=[0,625,100], /scale,lcharsize=1.8, /noframe, pos = pos1
;      map_set, 0,0,/cont,/cyl,limit=[-27,-22,50,62],/noerase, /noborder,pos=pos2, mlinethick=1,color=100, /grid
;      ;map_set limits [latmin,lonmin,latmax,lonmax]
;      map_continents, /countries, color=black,   mlinethick=2
;endfor ;k-each band 

   


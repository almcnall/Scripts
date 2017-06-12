pro clip_globe2sahel 

;*****clip out soil and veg masks! for now I will use the named classes
;ifile = file_search('/jower/LIS/data/UMD/10KM/sand_FAO.1gd4r')
ifile = file_search('/jower/LIS/data/UMD/10KM/clay_FAO.1gd4r')
;ifile = file_search('/jower/LIS/RUN/UMD/10KM/soiltexture_STATSGO-FAO.1gd4r')
;ifile = file_search('/jower/LIS/RUN/UMD/10KM/landcover_UMD.1gd4r')

NX = 3600
NY = 1500
NZ = 13
ingrid = fltarr(NX,NY)
;veg = fltarr(NX,NY,NZ)

openr,1,ifile
readu,1,ingrid
close,1

byteorder,ingrid,/XDRTOF

;bottom is at 60...
w = ((180-20)*10)
e = ((180+52)*10)-1
s = (60-5)*10 ;60 is the eqautor...
n = ((60+30)*10)-1

;soil window
sahel = ingrid[w:e,s:n,*]
sahel(where(sahel lt 0)) = !values.f_nan

;clip out and save file so that i can make the FC and WP maps
ofile = strcompress('/jabber/chg-mcnally/AMMASOIL/clay_FAO_10KMsahel.1gd4r', /remove_all)
openw,1,ofile
writeu,1,sahel
close,1


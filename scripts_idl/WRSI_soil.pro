;# Development script to take Earth Observed precipitation and soil moisture and get crop yield
;# Written by Mark Carroll
;# Initial date 02/15/2012
;# Updated 02/23/2012
;# Added values for testing Indiana 03/21/2012
; moved over to IDL 12/28/12
; greg wrote separate funtions (see WRSI_millet.pro), now this just has inputs.
; modifying greg's code to work for the soil moisture bucket 1/17/2013
 
;****get WHC*******
ifile = file_search('/home/mcnally/regionmasks/whc3.bil')
whcgrid = bytarr(751,801)
openr,1,ifile
readu,1,whcgrid
close,1

whcgrid = reverse(whcgrid,2)
;Wankama Niger (prolly should double check this...)
xind = FLOOR((2.633 + 20.05) * 10.0)
yind = FLOOR((13.6454 + 40.05) * 10.0)

WHC = whcgrid(xind,yind)

;******get LGP***********
ifile = file_search('/home/mcnally/regionmasks/lgp_ws_sahelwindow.img')
lgpgrid = fltarr(720,350)
openr,1,ifile
readu,1,lgpgrid
close,1

;Wankama Niger
xind = FLOOR((2.6496 + 20.) / 0.10)
yind = FLOOR((13.6496 + 5) / 0.10)

LGP = lgpgrid(xind,yind) 

;****get climatological SOS***********
ifile = file_search('/home/mcnally/regionmasks/SOS/waw7033dt.bil')
sosgrid = bytarr(751,801)

openr,1,ifile
readu,1,sosgrid
close,1

sosgrid = reverse(sosgrid,2)

;Wankama Niger (prolly should double check this...)
xind = FLOOR((2.633 + 20.05) * 10.0)
yind = FLOOR((13.6454 + 40.05) * 10.0)

SOS = sosgrid(xind,yind);17

;*****get soil moisture observations*********
ifile = file_search('/jabber/chg-mcnally/AMMASOIL/observed_TKWK1WK2.csv')
soil = read_csv(ifile)
wk240 = reform(float(soil.field3),36,4)
;wk270 = reform(float(soil.field4),36,4)


  ;*******get EROS PET*****************
  ifile = file_search('/jabber/chg-mcnally/EROSPET/wankama_dekadPET_2005_2008.csv')
  potevp = read_csv(ifile)
  PETcube = reform(potevp.field1,36,4)*10
  
   ; not sure if these belong here but will be read in from a file eventually
  FC = 0.09
  WP = 0.03
  scale = WHC/(FC-WP)
  ;PAW = (SOIL-WP)* scale
for y = 0,3 do begin &$
  soil = (wk240[*,y]-WP)*scale &$
  pet = pETcube[*,y] &$ 
  new_wrsi = WRSI(soil, pet, WHC = WHC, LGP = LGP) &$
  ;I fixed the SOS at 17 : 1/17/2013
  ; p1 = plot(soil) &$ 
  print, new_wrsi &$
endfor

end

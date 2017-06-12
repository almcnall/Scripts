;the purpose of this script is to make the 0.1 degree eMODIS files the same window 
;as the sahel window that i have been using.I'll have to clip it out from the larger africa window since the west africa window is too small....
;sahel window= 19W, 52E, -5S, 30N
;west africa window = 19W, 35E?, 2S, 25Nish
;careful to use BYTE and the scaling factor for the NDVI but not the RFE!
;****************Chop down NDVI inputs to calculate to filter for SM****************************
ifile = file_search('/jabber/LIS/Data/ubRFE04.19.2013/monthly/all_products.bin.*.img')
;ifile = file_search('/jabber/LIS/Data/CPCOriginalRFE2/monthly/all_products.bin.*.img')

nx = 751
ny = 801

nz = n_elements(ifile) ;shorter for the NDVI files..missing last 4 deks
ingrid = fltarr(nx,ny)
sahelarray = fltarr(720,350,nz)

for f = 0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[f] &$
  readu,1,ingrid &$
  close,1 &$
  
  ingrid(where(ingrid gt 30000.)) = !values.f_nan  &$;1000mm/day cap *30 days
  ;ingrid = reverse(ingrid,2) &$
  ;chop down the file to the sahel window 
  xrt = (751-1)-3/0.1  &$;RFE goes to 55, sahel goes to 52 plus an extra pixel
  ybot = (35/0.1)+1   &$ ;sahel starts at -5S
  ytop = (801-1)-10/0.1  &$; &$sahel stops at 30N
  xlt = 1.     &$          ;and I guess sahel starts at 19W, rather than 20....
  sahel = ingrid[xlt:xrt,ybot:ytop] &$
  sahelarray[*,*,f] = sahel &$
  
 ;write out each file individually...and prolly the stack
 ;ofile = strcompress('/jabber/LIS/Data/CPCOriginalRFE2/monthly/sahel/'+strmid(ifile[f],41,28), /remove_all) &$
 ofile = '/jabber/LIS/Data/ubRFE04.19.2013/monthly/sahel/'+strmid(ifile[f],41,28) &$
  
  print, ofile  &$
  openw,1,ofile  &$
  writeu,1,sahel &$
  close,1 &$
endfor
print, 'hold'
end
;*********does it work?********
;ifile = file_search('/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/sahel/data*')
;nx = 720
;ny = 350
;
;ingrid = fltarr(nx,ny)
;
;openr,1,ifile[0]
;readu,1,ingrid
;close,1
;
;****map it***********
;tot = total(sahelarray,3,/nan)/11
;roi = where(tot gt 1500)
;tot(roi) = !values.f_nan
;  p1 = image(tot, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
;           rgb_table=20)
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07])
;  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
;  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
;;
;xind = FLOOR((2.633 + 20.) / 0.10)
;yind = FLOOR((13.6454 + 5) / 0.10)
;
;temp = plot(sahelarray[xind,yind,*])



;the purpose of this script is to make the 0.1 degree eMODIS/RFE2 files the Sahel window used in dissertation and realted papers 
;sahel window= 19W, 52E, -5S, 30N
;west africa window = 19W, 35E?, 2S, 25Nish
;careful to use BYTE and the scaling factor for the NDVI but not the RFE!
;updated 6/17/2014 to use Pete's CPC RFE dekads (tiff). 

;****************Chop down NDVI inputs to calculate to filter for SM****************************
ifile = file_search('/home/sandbox/people/mcnally/ubRFE04.19.2013/dekads/2013*.img')
;where did I make these dekads? maybe: make_dekads_ubRFE2.pro
;these go from (March) 200003 to...201406 (no land mask, ocean included, no nulls, just zeros)
ifile = file_search('/raid/Staging2rain/RFE2/dekads/data*tiff') & help, ifile

ingrid = read_tiff(ifile[0],geotiff=geotiff) & help, ingrid
;ifile= file_search('/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/data.{2012}*.img');do rest of yrs. 

nx = 751
ny = 801
nz = n_elements(ifile)
;ingrid = bytarr(nx,ny); for the NDVI files 
ingrid = fltarr(nx,ny)
sahelarray = fltarr(720,350,nz)

for f = 0,n_elements(ifile)-1 do begin &$
;  openr,1,ifile[f] &$
;  readu,1,ingrid &$
;  close,1 &$
  ingrid = read_tiff(ifile[f],geotiff=geotiff)
  
  ingrid(where(ingrid gt 10000.)) = !values.f_nan  &$;1000mm/day cap *10 days
  ingrid = reverse(ingrid,2) &$
  ;chop down the file to the sahel window 
  xrt = (751-1)-3/0.1  &$;RFE goes to 55, sahel goes to 52 plus an extra pixel
  ybot = (35/0.1)+1   &$ ;sahel starts at -5S
  ytop = (801-1)-10/0.1  &$; &$sahel stops at 30N
  xlt = 1.     &$          ;and I guess sahel starts at 19W, rather than 20....
  sahel = ingrid[xlt:xrt,ybot:ytop] &$
  ;sahel = (sahel-100.)/100. &$ ;do I need this??
  sahelarray[*,*,f] = sahel &$
  
  ;write out all of the spatial subset files. Did I do this for UBRFE or did I just calculate extra API?
 ;ofile = '/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/sahel/'+strmid(ifile[f],54,19) &$
  
 ;write out each file individually...and prolly the stack 
 ;don't love naming convention, will this mess up dwnstream?
 ofile = strcompress('/home/sandbox/people/mcnally/RFE2_sahel/dekads/'+strmid(ifile[f],31,18), /remove_all) &$
 ;ofile = '/jabber/LIS/Data/ubRFE04.19.2013/dekads/sahel/'+strmid(ifile[f],40,19) &$

  write_tiff, ofile, sahel, geotiff=geotiff, /FLOAT
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



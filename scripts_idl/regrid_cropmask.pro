pro regrid_cropmask

ifile = file_search('/jabber/chg-mcnally/crop_mask.img')

nx = 1500
ny = 1600

ingrid = fltarr(nx,ny)
openr,1,ifile
readu,1,ingrid
close,1

good = where(ingrid gt 0, complement = bad)
ingrid(good) = 1
ingrid(bad) = !values.f_nan

;rebin to 0.1 degree before chopping to sahel window...use congrid since not integer multiples
deg01 = congrid(ingrid, 751,801)

  xrt = (751-1)-3/0.1  &$;RFE goes to 55, sahel goes to 52 plus an extra pixel
  ybot = (35/0.1)+1   &$ ;sahel starts at -5S
  ytop = (801-1)-10/0.1  &$; &$sahel stops at 30N
  xlt = 1.     &$          ;and I guess sahel starts at 19W, rather than 20....
  
  sahel = deg01[xlt:xrt,ybot:ytop] &$

ofile = '/jabber/chg-mcnally/cropmask_01deg_sahel.img'

openw,1,ofile
writeu,1,sahel
close,1
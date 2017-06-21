ifile = file_search('/jabber/chg-mcnally/filterNDVI_sahel/TEST_SMest_2009.img')
nx = 720
ny = 350
nz = 36

ingrid = fltarr(nx,ny,nz)

openr,1,ifile
readu,1,ingrid
close,1

mve, ingrid(where(finite(ingrid)))

temp = image(ingrid[*,*,0], rgb_table=4)

;Wankama Niger
xind = FLOOR((2.6496 + 20.) / 0.10)
yind = FLOOR((13.6496 + 5) / 0.10)

;Mpala Kenya:
mxind = FLOOR((36.8701 + 20.) / 0.10)
myind = FLOOR((0.4856 + 5) / 0.10)

;;KLEE Kenya
kxind = FLOOR((36.8669 + 20.) / 0.10)
kyind = FLOOR((0.2825 + 5) / 0.10)

temp = plot(ingrid[mxind,myind,*])
temp = plot(ingrid[kxind,kyind,*], /overplot, 'g')

;ugh, it looks like 2011 should be less than 2009, unless the dates are just so..wtf.
;what dekads are JAS? Dek 19-27
temp = plot(ingrid[xind,yind,*], /overplot,'b')

print, mean(ingrid[xind,yind,18:26], /nan) ;2011 = 0.0504 ; 2009 = 0.0519  --- is the range really that small that it will make a difference??




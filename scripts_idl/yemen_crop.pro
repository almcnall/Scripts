UMD_cropmap
;the purpose of this script is to make an approximate crop map for yemen 
;so that i can test out the irrigation scheme
;i think that i will group crop type by water requirement (Qat and Grapes vs cereals)
;and elevation since the best growing zones appear to be in the mountains.
;http://www.lib.utexas.edu/maps/middle_east_and_asia/yemen_land_use_2002.jpg
;
ifile = file_search('/home/sandbox/people/mcnally/UMD_N125C19.1gd4r') & print, ifile
;19 crops at 0.125 degree, -124.9375W, 25.0625N (left and bottom...)
nx = 464
ny = 224
nz = 19

ingrid = fltarr(nx,ny,nz)
openr,1,ifile
readu,1,ingrid
close,1

byteorder,ingrid, /XDRTOF
temp = image(total(ingrid,3))
;if i am going to use the other yemen files i need to make sure that they are also big endian...
; but it looks like they are...

ifile = file_search('/home/chg-mcnally/regionmasks/landcover_UMD_yemen_crop.1gd4r')
ingrid = fltarr(121,81,14)
openr,1,ifile
readu,1,ingrid
close,1

mve, ingrid

;ok make a similar-ish map for Yemen
;maybe start with globe....
;
ifile = file_search('/home/chg-mcnally/regionmasks/landcover_UMD.1gd4r')
nx = 3600
ny = 1500
nz = 13

ingrid = fltarr(nx,ny,nz)
openr,1,ifile
readu,1,ingrid
close,1

byteorder,ingrid, /XDRTOF
temp = image(total(ingrid,3))

;take this map, and add in the vegetation that i am interested in...
left = (180+42)/0.1
right = (180+54)/0.1
bot = (60+12)/0.1
top = (60+20)/0.1

;I think that i am 10 pixels short....
yemen = ingrid[left:right, bot:top,*]
temp = image(total(yemen,3))

;ok, so how do i modify the values of interest?
;1. anywhere that is vegetated i think should be considerd
;   potential crop growing, I think the small amount of cropland
;   probably only applies to some "industrial farms", maybe a coffee
;   plantation or grapes...

;make a layer with all potential vegetation types 6-11
veg = total(yemen[*,*,5:10],3)
veg(where(veg gt 0))=100
;now i can think about dividing up this layer into different crop types
;the different percentatges might be a reasonable approx for the different croptypes


yp1 =  [ [[yemen]], [[veg]], [[veg]],[[veg]],[[veg]],[[veg]],[[veg]],[[veg]],[[veg]],[[veg]],[[veg]],[[veg]], $
         [[veg]],[[veg]],[[veg]],[[veg]],[[veg]],[[veg]],[[veg]],[[veg]] ]
byteorder,yp1, /XDRTOF

;add new crop types!
ofile = strcompress('/home/chg-mcnally/regionmasks/landcover_UMD_yemen_crop.1gd4r')
openw ,1,ofile
writeu,1,yp1
close ,1

;check out the format of the CONUS irrigation map:
;so this really is just a landmask, nothing irrigationy about it...
;maybe for my first run i will just irrigate all of yemen....
ifile = file_search('/home/chg-mcnally/regionmasks/IRR_N125_mask.1gd4r')
nx = 464
ny = 224

ingrid = fltarr(nx,ny)

openr,1,ifile
readu,1,ingrid
close,1
byteorder,yp1, /XDRTOF

p1 = image(ingrid)

;check out the gripc
ifile = file_search('/home/chg-mcnally/regionmasks/irrigtype_salmon2013.flt')
nx = 86400
ny = 36000

ingrid = fltarr(nx,ny)
openr,1,ifile
readu,1,ingrid
close,1

;check on the WRSIclim map. is it in big endian and 0-99? and irrigation percentage

ifile = file_search('/home/chg-mcnally/regionmasks/newirr.percent.eighth.bin')
nx = 464
ny = 224
ingrid = fltarr(nx,ny)

openr,1,ifile
readu,1,ingrid
close,1
byteorder,ingrid, /XDRTOF

;now double check the WRSIclim map
ifile = file_search('/home/chg-mcnally/regionmasks/WRSIclim_yemen.bil')
ingrid = bytarr(121,81)

openr,1,ifile
readu,1,ingrid 
close,1
mve, ingrid

ingrid = float(ingrid)
ingrid = reverse(ingrid,2)
byteorder,ingrid, /XDRTOF

;eww, i hope i didn't mess up the previous openfile, probably the landcov. opps it did
ofile = ('/home/chg-mcnally/regionmasks/test_irr_percent_yemen.bil')
openw,1,ofile
writeu,1,ingrid
close,1


;to make this work as the irrigation fraction map it need to be float, big endian









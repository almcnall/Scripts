;yemen_wrsi_landmask
;
;4/2/2014 WRSI requires a landmask file. I will use the UMD veg map to do this
;first clip vegetype12 to yemen domain

nx = 3600
ny = 1500
nz = 13

ifile = file_search('/home/chg-mcnally/regionmasks/landcover*.1gd4r')
ingrid = fltarr(nx,ny,nz)

openr,1,ifile
readu,1,ingrid
close,1

byteorder,ingrid,/XDRTOF

temp = image(ingrid[*,*,11])

;clip to yemen...
;clipping the congrid of mpet, the other is tooooo small...
yleft = (180+42)/0.10
yright= (180+54)/0.10
ybot  = (60+12)/0.10
ytop  = (60+20)/0.10

;so how do i decide what percent of bare ground to mask out? 90%
yemen = ingrid[yleft:yright, ybot:ytop,*]
tot = total(yemen,3)
ocean = where(tot eq 0)
temp = image(yemen)

mask = yemen[*,*,11]

veg = where(mask lt 90,complement = bare)
mask(veg) = 2
mask(bare) = 1
mask(ocean) = !values.f_nan

temp = image(mask, rgb_table=4, min_value=-1)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100]) 

ofile = '/home/chg-mcnally/regionmasks/yemenmask.bil'
mask = reverse(byte(mask),2)

openw,1,ofile
writeu,1,mask
close,1


;how is the actual mask formatted?
ifile = file_search('/home/chg-mcnally/regionmasks/ekwmask.bil')
ekgrid = bytarr(297,351)
openr,1,ifile
readu,1,ekgrid
close,1

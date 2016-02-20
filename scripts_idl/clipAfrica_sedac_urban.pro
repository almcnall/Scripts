PRO clipAfrica_sedac

; this program subsets the trmmv6 data to the Africa domain. Global TRMM 0-360 (lon), 50S-50N (lat)
; Africa:  20W - 55E,  40S - 40N  75 x  80   degrees, 301 x 321  pixels @ 0.25 deg, 751 x 801 @ 0.1 degree
; 

ifile = file_search('/jabber/sandbox/mcnally/ndvi4luce/glurextents.bil')

inx = 43200. ;global fclim at 0.00833 degree
iny = 16800.

outx = 301.   ;africa domain at 0.1 degree (to match RFE2)
outy = 321.

globe = bytarr(inx,iny)
afr = fltarr(outx,outy)

openu,1,ifile
readu,1,globe
close,1

globe = reverse(globe,2)
temp = image(globe)

globe = float(globe)
null = where(globe eq 0, count)
globe(null)=!values.f_nan

;how do i get these dimensions?
res = 0.00833333
west = (180-20)/res
east = (180+55)/res
north = (56+40)/res
south = (56-40)/res
afr= globe(west:east,south:north) ;Africa:  20W - 55E,  40S - 40N  75 x  80   degrees      
temp = image(afr)
;ooops something is a bit off here but i'm tired..
coarse = congrid(afr,301,321)
p1 = image(coarse, image_dimensions=[301/4,321/4], image_location=[-20,-40], dimensions=[301/10,321/10], $
           rgb_table = 20)
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-40, -20, 40, 55], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

ofile= strcompress('/jabber/sandbox/mcnally/ndvi4luce/AFR_glurextents.bil')
    
openw,2,ofile
writeu,2,coarse
close,2 
  


   


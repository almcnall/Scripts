PRO clipAfrica_sedac

; this program subsets the trmmv6 data to the Africa domain. Global TRMM 0-360 (lon), 50S-50N (lat)
; Africa:  20W - 55E,  40S - 40N  75 x  80   degrees, 301 x 321  pixels @ 0.25 deg, 751 x 801 @ 0.1 degree
; 

ifile = file_search('/jabber/sandbox/mcnally/SEDAC_2010/glds10ag15.bil')

inx = 1440. ;global fclim at 0.05 degree
iny = 572.

outx = 301.   ;africa domain at 0.1 degree (to match RFE2)
outy = 321.

globe = lonarr(inx,iny)
afr = fltarr(outx,outy)

openu,1,ifile
readu,1,globe
close,1

globe = reverse(globe,2)
byteorder, globe, /XDRTOF
globe = float(globe)
null = where(globe eq 0, count)
globe(null)=!values.f_nan

afr= globe(640:940,72:72+320) ;Africa:  20W - 55E,  40S - 40N  75 x  80   degrees      
;temp = image(afr)

p1 = image(afr, image_dimensions=[301/4,321/4], image_location=[-20,-40], dimensions=[inx/10,iny/10], $
           rgb_table = 20)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-40, -20, 40, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

ofile= strcompress('/jabber/sandbox/mcnally/SEDAC_2010/AFR_glds10ag15.img')
    
openw,2,ofile
writeu,2,afr
close, 2 
  


   


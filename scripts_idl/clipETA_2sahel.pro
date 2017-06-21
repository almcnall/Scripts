clipETA_2sahel
;these files are stored as 0-255 bytes and 0-255% of normal, the tiffs are plotted as 7 classes but IDL rgb will plot individual values. 
; to get actual ET multiple these values by average monthly ET. THis could be another good use of the Noah model...
;1. generate average monthly ET
;2. cultiply SSEB by monthly ET to get the AET for that month
;3. compare to modeled ET. 
;4. is there a large difference over areas that we presume are irrigated or swampy?
;jan 14,2016 wonder if there is anything useful in here?

xrt = (751-1)-3/0.1  &$;RFE goes to 55, sahel goes to 52 plus an extra pixel
ybot = (34/0.1)+4   &$ ;sahel starts at -5S (+1) (40-5=35), 38-5=33,. ugh, not sure why this works but prolly has something
;to do with 38.
ytop = ((801-1)-11/0.1)+3  &$; &$sahel stops at 30N (-10)
xlt = 1.     &$          ;and I guess sahel starts at 19W, rather than 20....

ifile = file_search('/home/sandbox/people/mcnally/ETA/*.tif')

for i = 0,n_elements(ifile)-1 do begin &$
  ingrid = read_tiff(ifile[i], R,G,B,geotiff=geotiff) &$
  ingrid = reverse(ingrid,2) &$
  ingrid = congrid(ingrid,751,801) &$
  ;sahel = ingrid[xlt:xrt,ybot:ytop] &$
  stack[*,*,i] =ingrid &$

;  ofile = '/jabber/chg-mcnally/ETA/sahel/'+strmid(ifile[i],24,20)+'.img' &$
;  openw,1,ofile &$
;  writeu,1,sahel &$
;  close,1 &$
endfor 


p1=image(sahel, rgb_table=20)

;What does it mean that the image location is shifted...that means that my grid's won't line up quite right...
  p1 = image(sahel, RGB_TABLE=20,image_dimensions=[72.0,35.0], image_location=[-20,-5], $ 
             dimensions=[nx/100,ny/100],title = 'ETA') &$ 
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20) &$
  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 52], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

pro clipMOD16_2sahel

;this took some nudging for the MOD16
xrt = (751-1)-3/0.1  &$;RFE goes to 55, sahel goes to 52 plus an extra pixel
ybot = (34/0.1)+11   &$ ;sahel starts at -5S (+1) (40-5=35), 38-5=33,. ugh, not sure why this works but prolly has something
;to do with 38.
ytop = ((801-1)-11/0.1)+10  &$; &$sahel stops at 30N (-10)
xlt = 1.     &$          ;and I guess sahel starts at 19W, rather than 20....


;get the new g_tag from this example that i saved in ENVI:
exfile = file_search('/home/mcnally/MOD16_sahel_example.tif')
example = read_tiff(exfile,R,G,B,geotiff=g_tags);so, these are taged in upside down envi land....will idl flip the tag?


ifile = file_search('/jower/sandbox/mcnally/MOD16/Africa/*.tif')
for i = 0,n_elements(ifile)-1 do begin &$
  ingrid = read_tiff(ifile[i], R,G,B,geotiff=geotiff) &$
  ingrid = reverse(ingrid,2) &$
  ingrid = congrid(ingrid,751,801) &$
  sahel = ingrid[xlt:xrt,ybot:ytop] &$
  sahelflip = reverse(sahel,2) &$
  ofile = '/jower/sandbox/mcnally/MOD16/Africa/sahel/'+strmid(ifile[i],36,12)+'.10'+strmid(ifile[i],51,19) &$
  write_tiff, ofile, sahelflip, geotiff=g_tags, /SHORT &$
  print, strmid(ifile[i],36,12)+'.10'+strmid(ifile[i],51,19) &$
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

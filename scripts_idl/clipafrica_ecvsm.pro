pro clipAfrica_ECVSM

ifile = file_search('/raid/chg-mcnally/ECV_soil_moisture/monthly/ECV_SM_2000*')
;ifile = file_search('/raid/chg-mcnally/ECV_soil_moisture/dekads/ECV_2000*')

nx = 1440
ny = 720

outx = 301
outy = 321
  
ingrid = fltarr(nx,ny)
afr = fltarr(outx,outy,n_elements(ifile))

for i = 0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[i] &$
  readu,1,ingrid &$
  close,1 &$
  
  ingrid = reverse(ingrid,2) &$
  ;ops that doesn't work...
  afr[*,*,i] = ingrid(640:940,200:520) &$
endfor  

;added on 11/15 clip to EAwindow and write as tiff
;clip to horn
afr01 = congrid(afr,751,801,n_elements(ifile))
xrt = (20+51.35)/0.1  ;RFE goes to 55, sahel goes to 52 plus an extra pixel
ybot = (40-11.75)/0.1   ;sahel starts at -5S
ytop = (40+22.05)/0.1  ; &$sahel stops at 30N
xlt =  (20+22.95)/0.1              ;and I guess sahel starts at 19W, rather than 20....
horn = afr01[xlt:xrt,ybot:ytop,*] ;285, 298, 360

;read in the envifile so i can get the header info.
intiff = read_tiff('/home/mcnally/LIS_WRSIeg.tif', GEOTIFF=g_tags)
  
  
for i = 0,n_elements(horn[0,0,*])-1 do begin &$
  ofile = strcompress('/raid/chg-mcnally/ECV_soil_moisture/monthly/horn/ECV_SM_'+strmid(ifile[i],51,6)+'.tif') &$
  write_tiff, ofile, horn[*,*,i],geotiff=g_tags, /FLOAT &$
  print, 'wrote '+ofile &$
endfor

;clip to sahel
afr01 = congrid(afr,751,801,n_elements(ifile))

xrt = (751-1)-3/0.1  ;RFE goes to 55, sahel goes to 52 plus an extra pixel
ybot = (35/0.1)+1   ;sahel starts at -5S
ytop = (801-1)-10/0.1  ; &$sahel stops at 30N
xlt = 1.              ;and I guess sahel starts at 19W, rather than 20....
sahel = afr01[xlt:xrt,ybot:ytop,*]
;temp = image(mean(sahel, dimension=3, /nan),rgb_table=4)

;outdir = '/jower/sandbox/mcnally/ECV_soil_moisture/monthly/sahel/'
;outdir = '/jower/sandbox/mcnally/ECV_soil_moisture/dekads/sahel/'
for i = 0,n_elements(ifile)-1 do begin &$
  ofile = outdir+strmid(ifile[i],48,17) & print, ofile &$
  outgrid = sahel[*,*,i] &$

  openw,1,ofile &$
  writeu,1,outgrid &$
  close,1 &$
endfor


p1 = image(mean(sahel, dimension=3, /nan), image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=4)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, -20, 18, 52], /overplot)
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  
  ;check at a point...
  print, ((sahel[wxind, wyind,*])
  

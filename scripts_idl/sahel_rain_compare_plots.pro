pro sahel_rain_compare_plots

bfile = file_search('/jabber/chg-mcnally/mbe_*_sta.img')
afile = file_search('/jabber/chg-mcnally/mae_*_sta.img')
cfile = file_search('/jabber/chg-mcnally/cor_*_sta.img')

nx=720
ny=350
nz=12
name = ['CHIRPS', 'CMAP', 'RFE', 'ubRFE']
mname = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul','Aug', 'Sep','Oct','Nov','Dec']
ingrid = fltarr(nx,ny,nz)

;***************mean absolute error*************************
for i=0,n_elements(afile)-1 do begin &$
  openr,1,afile[i] &$
  readu,1,ingrid &$
  close,1 &$
  for m=6,6 do begin  &$
    p1 = image(ingrid[*,*,m], RGB_TABLE=20,image_dimensions=[72.0,35.0], image_location=[-20,-5], $ 
               min_value=0, max_value=60, dimensions=[nx/100,ny/100]) &$
    c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20) &$
    p1.title = 'mean absolute error '+mname[m]+'('+name[i]+' vs CSCDP krigged stations)' &$
    p1 = MAP('Geographic',LIMIT = [0, -20, 18, 52], /overplot) &$
    p1.mapgrid.linestyle = 'dotted' &$
    p1.mapgrid.color = [150, 150, 150] &$
    p1.mapgrid.label_position = 0 &$
    p1.mapgrid.label_color = 'black' &$
    p1.mapgrid.FONT_SIZE = 12 &$
    p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])   &$
   endfor &$
 endfor
 
 ;**************mean bias error***************************
  ncolors=256 
 for i=0,n_elements(bfile)-1 do begin &$
  openr,1,bfile[i] &$
  readu,1,ingrid &$
  close,1 &$
  for m=6,6 do begin  &$
    p1 = image(ingrid[*,*,m], RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),image_dimensions=[72.0,35.0], image_location=[-20,-5], $ 
               min_value=-60, max_value=60, dimensions=[nx/100,ny/100]) &$
    c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20) &$
    p1.title = 'mean bias error '+mname[m]+'('+name[i]+' vs CSCDP krigged stations)' &$
    p1 = MAP('Geographic',LIMIT = [0, -20, 18, 52], /overplot) &$
    p1.mapgrid.linestyle = 'dotted' &$
    p1.mapgrid.color = [150, 150, 150] &$
    p1.mapgrid.label_position = 0 &$
    p1.mapgrid.label_color = 'black' &$
    p1.mapgrid.FONT_SIZE = 12 &$
    p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])   &$
   endfor &$
 endfor
 
 ;***********correlations*******************************
 for i=0,n_elements(cfile)-1 do begin &$
  openr,1,cfile[i] &$
  readu,1,ingrid &$
  close,1 &$
  for m=6,6 do begin  &$
    p1 = image(ingrid[*,*,m], RGB_TABLE=20,image_dimensions=[72.0,35.0], image_location=[-20,-5], $ 
               min_value=0, max_value=0.8, dimensions=[nx/100,ny/100]) &$
    c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20) &$
    p1.title = 'correlation '+mname[m]+'('+name[i]+' vs CSCDP krigged stations)' &$
    p1 = MAP('Geographic',LIMIT = [0, -20, 18, 52], /overplot) &$
    p1.mapgrid.linestyle = 'dotted' &$
    p1.mapgrid.color = [150, 150, 150] &$
    p1.mapgrid.label_position = 0 &$
    p1.mapgrid.label_color = 'black' &$
    p1.mapgrid.FONT_SIZE = 12 &$
    p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])   &$
   endfor &$
 endfor
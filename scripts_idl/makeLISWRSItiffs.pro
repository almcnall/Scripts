pro makeLISWRSItiffs

;11/14/2013 another modification to subsets the Sahel window and the WRSI window to the Funk zone.
;
;all the files are there but no data....so I think that is the same window but 27W
;10/16/2013: modified this script to match Shrad's Horn domain so that i can look at VIC and Noah data.
;I should start with the rainfall, but that might be a waste of time if the chirps are crappy. 
;jan 6, do this for the MAMs as well.

;ifile = file_search(strcompress('/raid/chg-mcnally/LISWRSI_OUTPUT/postprocess/EXP{0,1}??/20??022{8,9}0000.d01.gs4r', /remove_all))
exps=['L83','L84', 'L85','L86','L87','L88','L89','L90','L91','L92','L93','L94', 'L95','L96','L97','L98','L99','L00','L01','L02',$
      'L03','L04','L05','L06','L07','L08','L09','L10','L11','L12', 'L13']

ifile = strarr(n_elements(exps))
;read in the envifile so i can get the header info.
intiff = read_tiff('/home/chg-mcnally/EAtiffs/LIS_WRSIeg.tif', GEOTIFF=g_tags)
for i = 0,n_elements(exps)-1 do begin &$
  ff = file_search(strcompress('/raid/chg-mcnally/LISWRSI_OUTPUT/postprocess/EXP'+exps[i]+'/????11300000.d01.gs4r', /remove_all)) &$   
  ifile[i] = ff &$ 
endfor

nx = 285
ny = 339
nz = 40

ingrid = fltarr(nx,ny,nz)
heos = fltarr(nx,ny, n_elements(ifile))
yr = indgen(31)+1983
ncolors = 256 ;this has to be set to 256 to get the pink no-start (253).

for i = 0, n_elements(ifile)-1 do begin &$
  
  openr,1,ifile[i] &$
  readu,1,ingrid  &$
  close,1 &$
 
  heos = ingrid[*,*,3] &$
  ;heos(where(heos ge 253)) = !values.f_nan &$
  ;this ofile is for the OND that crosses yr 
  ;ofile = strcompress('/home/chg-mcnally/EAtiffs/MAM/EOS_WRSI.'+strmid(ifile[i],49,2)+strmid(ifile[i],54,2)+'.tif') &$
  ofile = strcompress('/home/chg-mcnally/EAtiffs/MAM/EOS_WRSI.'+string(yr[i])+'.tif', /remove_all) &$ 
  ;write_tiff, ofile, reverse(heos,2) ,geotiff=g_tags, /FLOAT &$
  print, 'wrote '+ofile &$

  ;make sigures that look like the EROS ones...
  ;w = WINDOW(DIMENSIONS=[500,500]) &$
  p1 = image(byte(heos), image_dimensions=[nx/10,ny/10], image_location=[23.2,-11.5],dimensions=[500,500], RGB_TABLE=make_wrsi_cmap(),  MIN_VALUE=0) &$
  p1.title = string(yr[i]) &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [255,250,250] &$
  p1.rgb_table = rgbdump   &$

  c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON, font_size=18)  &$
  ;what is shrad's domain again? -1.875 deg S to 7.875 deg N and 36.125 deg E and 49.625 deg E, what is the eros window?
  p1 = MAP('Geographic',LIMIT = [-11, 23, 20, 50], /overplot) &$
  p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [255, 250, 250] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES, thick=2,  COLOR = [120, 120, 120]) &$
  ;************************************** 
  ofile = strcompress('/home/mcnally/MAM_wrsi_IMGS/EOS_WRSI'+string(yr[i])+'.jpg', /remove_all) &$
  ;p1.save,ofile ,RESOLUTION=200 &$
endfor

temp=image(heos, rgb_table=4)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])


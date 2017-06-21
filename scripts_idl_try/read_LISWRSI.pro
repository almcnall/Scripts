;read LIS_netcdf output for yemen

ifile = file_search('/home/chg-mcnally/LIS_HIST_200910100000.d01.nc')

fileID = ncdf_open(ifile, /nowrite) &$
wrsiID = ncdf_varid(fileID,'WRSI_inst')
ncdf_varget,fileID, wrsiID, eos_wrsi

swiID = ncdf_varid(fileID,'SWI_inst')
ncdf_varget,fileID, swiID, eos_swi

eos_wrsi(where(eos_wrsi gt 252))= 0
eos_swi(where(eos_swi gt 252)) = 0

ncolors=256
p1 = image(byte(eos_swi),RGB_TABLE = make_swi_cmap(),image_dimensions = [12.0,8.0],$
               image_location=[42,12],dimensions=[120,80]) &$ 
               c = COLORBAR(target = p1,ORIENTATION = 0,/BORDER_ON,POSITION = [0.3,0.04,0.7,0.07], font_size=20, range=[0,100]) 
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image

  p1 = MAP('Geographic',LIMIT = [12,42, 20, 54], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2) 



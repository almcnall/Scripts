WRSI_USGS_plots_WA

;this script makes plots of the LIS-WRSI (CHIRPS) similar to what is found on the USGS website
;WRSI and WRSI anomalies

;make the wrsi color table available
wkdir = '/home/source/mcnally/scripts_idl/'
cd, wkdir
.compile make_wrsi_cmap.pro

indir = '/home/chg-mcnally/LISWRSI_OUTPUT/LIS7/'
;ifile = file_search(indir+'WA_MAY2NOV_WRSI_inst_CHIRPS_8114.nc')
ifile = file_search(indir+'WRSI_inst_2013.nc');WRSI_inst_2013.nc

fileID = ncdf_open(ifile, /nowrite) &$
wrsiID = ncdf_varid(fileID,'WRSI_inst') &$
ncdf_varget,fileID, wrsiID, EOSwrsi

;nx = 446,ny = 124,nz = 33
dims = size(EOSwrsi, /dimensions)
NX = dims[0]
NY = dims[1]WA  
NZ = dims[2]

; west africa domain
map_ulx = -18.65 & map_lrx = 25.85
map_uly = 17.65 & map_lry = 5.35
;greg's way of nx, ny-ing
ulx = (180.+map_ulx)*10. & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10. & lry = (50.-map_lry)*10.-1
NX = lrx - ulx + 2 ;not sure why i have to add 2...
NY = lry - uly + 2
year = indgen(33)+1981
;just plot 2011: i=29
for i = 0,n_elements(EOSwrsi[0,0,*])-1 do begin &$
  i = 32
  p1 = image(byte(EOSwrsi[*,*,i]), image_dimensions=[nx/10,ny/10],image_location=[map_ulx,map_lry], $
            RGB_TABLE=make_wrsi_cmap(),MIN_VALUE=0, title ='FLDAS WRSI-CHIRPS'+ string(year[i]))  &$
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24) &$
 
  tmpclr = p1.rgb_table &$
  ;tmpclr[*,0] = [211,211,211] &$
  tmpclr[*,0] = [102,178,255] &$

  p1.rgb_table = tmpclr &$
 
 ;p1 = MAP('Geographic',LIMIT = [-10, 24,10 ,51], /overplot)
 
  p1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot) &$
  p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
 

;  p1.mapgrid.label_position = 0 &$
;  p1.mapgrid.label_color = 'black' &$
;  p1.mapgrid.FONT_SIZE = 18 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) &$
 endfor
 
 ;how to calculate the anomaly when the value is a flag?
 ; can't use the anomaly field with the CHIRPS data. gotta do it by hand.
; 
;indir = '/home/chg-mcnally/LISWRSI_OUTPUT/LIS7/'
;ifile = file_search(indir+'WA_APR2DEC_WRSIa_inst_CHIRPS_8114.nc')
;
;fileID = ncdf_open(ifile, /nowrite) &$
;wrsiaID = ncdf_varid(fileID,'WRSIa_inst') &$
;ncdf_varget,fileID, wrsiaID, EOSwrsia

ncolors = 10
p1 = image(diffNov15*mask, RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),image_dimensions=[285/10,339/10]

ncolors=10
 for i = 0,n_elements(EOSwrsia[0,0,*])-1 do begin &$
  p1 = image(byte(EOSwrsia[*,*,i]), image_dimensions=[nx/10,ny/10],image_location=[map_ulx,map_lry], $
            RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), title =string(year[i]), min_value=50, max_value=150)  &$
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24) &$
 
  tmpclr = p1.rgb_table &$
  tmpclr[*,0] = [211,211,211] &$
  p1.rgb_table = tmpclr &$
 
 ;p1 = MAP('Geographic',LIMIT = [-10, 24,10 ,51], /overplot)
 
  p1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot) &$
  p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
;  p1.mapgrid.label_position = 0 &$
;  p1.mapgrid.label_color = 'black' &$
;  p1.mapgrid.FONT_SIZE = 18 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) &$
 endfor
 
 
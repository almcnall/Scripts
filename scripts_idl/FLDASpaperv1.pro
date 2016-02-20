;working on figures for the FLDAS paper

;(1) median EOS WRSI for southern Africa with CHIRPS and RFE2 2001-2014


;make the wrsi color table available
wkdir = '/home/source/mcnally/scripts_idl/'
cd, wkdir
.compile make_wrsi_cmap.pro

;indir = '/home/chg-mcnally/LISWRSI_OUTPUT/LIS7/'
indir = '/home/sandbox/people/mcnally/WRSI_Sep2Feb_SA_CHIRPS/'

;read in the historic EOS so I am make the median
ifile = file_search(indir+'WRSI_EOS_*.nc')
hEOS = fltarr(486,443,n_elements(ifile))

for i = 0, n_elements(ifile)-1 do begin &$
  fileID = ncdf_open(ifile[i], /nowrite) &$
  ;wrsiID = ncdf_varid(fileID,'WRSI_inst') &$
  wrsiID = ncdf_varid(fileID,'WRSI_TimeStep_inst') &$
  ncdf_varget,fileID, wrsiID, EOSwrsi &$
  hEOS[*,*,i] = EOSWRSI &$
endfor

indir2 = '/home/sandbox/people/mcnally/WRSI_Sep2Feb_SA_RFE2/'

;read in the historic EOS so I am make the median
ifile = file_search(indir2+'WRSI_EOS_*.nc')
rEOS = fltarr(486,443,n_elements(ifile))

for i = 0, n_elements(ifile)-1 do begin &$
  fileID = ncdf_open(ifile[i], /nowrite) &$
  ;wrsiID = ncdf_varid(fileID,'WRSI_inst') &$
  wrsiID = ncdf_varid(fileID,'WRSI_TimeStep_inst') &$
  ncdf_varget,fileID, wrsiID, EOSwrsi &$
  rEOS[*,*,i] = EOSWRSI &$
endfor
rEOSnull = rEOS
rEOSnull(where(rEOSnull le 0))=0.5
medEOS_rfe = MEDIAN(rEOSnull,dimension=3)

;starts with 198202 (end of 81-82 season)
;ends with 201502 (end of 14-15 season)
startyr = 1982
endyr = 2015
nyrs = (endyr-startyr) +1
;(1) use the median since we have strange values in there...why is this max 100? not 255?
EOSnull = hEOS
EOSnull(where(EOSnull le 0))=0.5 ;do that things don't explode when divide by zero


sYOI = 2002
eYOI = 2015
medEOS_2000 = MEDIAN(EOSnull[*,*,sYOI-startyr:eYOI-startyr], dimension=3)

;South africa domain
map_ulx = 6.05 & map_lrx = 54.55
map_uly = 6.35 & map_lry = -37.85
;greg's way of nx, ny-ing
ulx = (180.+map_ulx)*10. & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10. & lry = (50.-map_lry)*10.-1
NX = lrx - ulx + 2 ;not sure why i have to add 2...
NY = lry - uly + 2
year = indgen(34)+82


p1 = image(byte(medEOS_rfe), image_dimensions=[nx/10,ny/10],image_location=[map_ulx+0.25,map_lry], $
  ;RGB_TABLE=make_wrsi_cmap(),MIN_VALUE=0, layout=[6,6,35-(i+1)], /current, title = string(year[i]))  &$
  RGB_TABLE=make_wrsi_cmap(),MIN_VALUE=0, /current)  &$
p1.title = 'median RFE EOS WRSI (Feb 2002-Feb 2015)'
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
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)


;but only get the median
medEOS = MEDIAN(EOSnull, dimension=3); this however has a low bias becasue all these simulations had a slow start. but thats ok for the set up...


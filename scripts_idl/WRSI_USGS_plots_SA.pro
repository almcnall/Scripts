WRSI_USGS_plots_SA

;this script makes plots of the LIS-WRSI (CHIRPS) similar to what is found on the USGS website
;WRSI and WRSI anomalies
;1/23/16 revisit for SAfrica forecasts
;2/20/16 use for Dalia's GPM SOS plots

;make the wrsi color table available
;on Rain
;wkdir = '/home/source/mcnally/scripts_idl/'
;on gs617
;wkdir = '/data0/almcnall/scripts_idl'
;on dali
wkdir = '/home/almcnall/Scripts/scripts_idl/

cd, wkdir
;.compile make_wrsi_cmap.pro
.compile make_sos_cmap.pro

;indir = '/home/sandbox/people/mcnally/WRSI_Sep2Feb_SA/'
;indir = '/data0/almcnall/data/'
indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/


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


;read in the simululated EOS 
ifile = file_search(indir+'/SIM/WRSI_EOS_*.nc')
EOS = fltarr(486,443,n_elements(ifile))

for i = 0, n_elements(ifile)-1 do begin &$
  fileID = ncdf_open(ifile[i], /nowrite) &$
  ;wrsiID = ncdf_varid(fileID,'WRSI_inst') &$
  wrsiID = ncdf_varid(fileID,'WRSI_TimeStep_inst') &$
  ncdf_varget,fileID, wrsiID, EOSwrsi &$
  EOS[*,*,i] = EOSWRSI &$
endfor
;nx = 486, ny = 443, nz = 33
dims = size(hEOS, /dimensions)
NX = dims[0]
NY = dims[1]
NZ = dims[2]

;South africa domain
map_ulx = 6.05 & map_lrx = 54.55
map_uly = 6.35 & map_lry = -37.85
;greg's way of nx, ny-ing
ulx = (180.+map_ulx)*10. & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10. & lry = (50.-map_lry)*10.-1
gNX = lrx - ulx + 2 ;not sure why i have to add 2...
gNY = lry - uly + 2
year = indgen(34)+82

for i = 0,n_elements(hEOS[0,0,*])-1 do begin &$
 ; p1 = image(byte(hEOS[*,*,i]), image_dimensions=[nx/10,ny/10],image_location=[map_ulx+0.25,map_lry], $
  p1 = image(byte(medEOS), image_dimensions=[nx/10,ny/10],image_location=[map_ulx+0.25,map_lry], $
            ;RGB_TABLE=make_wrsi_cmap(),MIN_VALUE=0, layout=[6,6,35-(i+1)], /current, title = string(year[i]))  &$
            RGB_TABLE=make_wrsi_cmap(),MIN_VALUE=0, /current, title = 'median EOS WRSI')  &$

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
 
 ;compurte the probaility that EOS WRIS is <80% of normal.
 ;(1) determine 'nornmal' with the 1982-2014 data. (have to recompute first)
 ;(2) computer percent of normal of EOS WRSI 
 ;- get plots set up with fake mean EOS
 
;(1) use the median since we have strange values in there...why is this max 100? not 255?
EOSnull = hEOS
EOSnull(where(EOSnull le 0))=0.5 ;do that things don't explode when divide by zero
medEOS = MEDIAN(EOSnull, dimension=3); this however has a low bias becasue all these simulations had a slow start. but thats ok for the set up...

;;alternatively make flag values = 25 and use the mean (althought I think i like median...)
;EOSwrsi2 = EOSwrsi
;EOSwrsi2(where(EOSwrsi2 eq -9999.0))= !values.f_nan
;EOSwrsi2(where(EOSwrsi2 ge 253))= 25
;clim = mean(EOSwrsi2, dimension=3) & help, clim

;EOSwrsi2(where(EOSwrsi2 gt 253))= 0
;clim(where(clim lt 0))=!values.f_nan
;clim(where(clim gt 253))=25

EOSa = fltarr(NX,NY,NZ)

for y = 0, n_elements(EOS[0,0,*])-1 do begin &$
  EOSa[*,*,y] = EOS[*,*,y]/medEOS &$
endfor
 
;check out one anomaly map, or all, oops.
ncolors = 10
 for i = 0,n_elements(EOSa[0,0,*])-1 do begin &$
  p1 = image(byte(EOSa[*,*,i]*100), image_dimensions=[nx/10,ny/10],image_location=[map_ulx,map_lry], $
            RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), min_value=50, max_value=150)  &$
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24) &$
  p1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot) &$
  p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) &$
 endfor
 
 ;ok, what i want to know is ...of the 32 maps what is the P that a pixel is below normal?
;if pixel below 80% then dry (on each map) 
; what percent of all the maps is the pixel dry, norm, wet

;ok first classify pixels on all maps
class = EOSa*!values.f_nan
below = where(EOSa le 80)
normal = where(EOSa gt 80 AND EOSa le 120)
above = where(EOSa gt 120)

class(below) = 50
class(normal) = 100
class(above) = 150

;right, can't just take the average cause that is kinda
; 0 (at least with these maps)
;should work better with the other average map...


 diff = byte(EOSa[*,*,32]*100)-EOSwrsia[*,*,32]
 ;difference between CHIRPS internal anomaly and WRSIa
   p1 = image(diff, image_dimensions=[nx/10,ny/10],image_location=[map_ulx,map_lry], $
            RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), title =string(year[i]), min_value=-50, max_value=50)  &$
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
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  
  ;;make the SOS plots for souther africa that look like USGS:
  ;indir = '/home/sandbox/people/mcnally/GPM_SOS4Dalia/'
  ;indir='/data0/almcnall/data/'
  indir='/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/SOS4Dalia/'
  ifile1 = file_search(indir+'/RFE_LIS_HIST_201602202330.d01.nc') & print, ifile1
  ifile2 = file_search(indir+'/CHIRPS_LIS_HIST_201602202330.d01.nc') & print, ifile2
  IFILE3 = FILE_SEARCH(INDIR+'/IMERG_LIS_HIST_201602202330.d01.nc') & PRINT, IFILE3

  NX = 486
  NY = 443

;  ingrid = ulonarr(NX,NY)
;  openr,1,ifile
;  readu,1,ingrid
;  close,1
;  ingrid = float(ingrid)
;  ingrid(where(ingrid gt 60))=!values.f_nan
    
fileID = ncdf_open(ifile1, /nowrite) &$
sosID = ncdf_varid(fileID,'SOS_inst') &$
ncdf_varget,fileID, sosID, SOS_RFE

fileID = ncdf_open(ifile2, /nowrite) &$
  sosID = ncdf_varid(fileID,'SOS_inst') &$
  ncdf_varget,fileID, sosID, SOS_CHP
  
fileID = ncdf_open(ifile3, /nowrite) &$
 sosID = ncdf_varid(fileID,'SOS_inst') &$
 ncdf_varget,fileID, sosID, SOS_GPM
 
SOS_RFE(where(SOS_RFE le 0))=!values.f_nan
SOS_CHP(where(SOS_CHP le 0))=!values.f_nan
SOS_GPM(where(SOS_GPM le 0))=!values.f_nan

temp = image(SOS_RFE-SOS_GPM,min_value=-10, max_value=10, rgb_table=4, /buffer)
temp.save,'TEST.png',RESOLUTION=300

;ok, I want the colorbar to start in September and End in Feb
add = where(SOS_RFE ge 1 AND SOS_RFE le 24)
SOS_RFE(add)=SOS_RFE(add)+36

add = where(SOS_CHP ge 1 AND SOS_CHP le 24)
SOS_CHP(add)=SOS_CHP(add)+36

add = where(SOS_GPM ge 1 AND SOS_GPM le 24)
SOS_GPM(add)=SOS_GPM(add)+36
  
  ;South africa domain
  map_ulx = 6.05 & map_lrx = 54.55
  map_uly = 6.35 & map_lry = -37.85
  ;greg's way of nx, ny-ing
  ulx = (180.+map_ulx)*10. & lrx = (180.+map_lrx)*10.-1
  uly = (50.-map_uly)*10. & lry = (50.-map_lry)*10.-1
  gNX = lrx - ulx + 2 ;not sure why i have to add 2...
  gNY = lry - uly + 2


 ncolors = 17
 months=['sep','','','oct','','','nov','','','dec','','','jan','','','','nostart']
 index = [    25,26,27,   28,29,30,   31, 32,33,  34,35,36,  37,38,39,40, 60]-0.5
 col_names=['medium purple', 'medium orchid', 'orchid',  'dodger blue', 'deep sky blue', 'sky blue','green', 'yellow green', 'lime green',   'tomato', 'coral', 'light salmon', 'tan', 'sandy brown', 'peru',  'saddle brown', 'yellow']
   ; w = WINDOW(DIMENSIONS=[700,900])
      tmptr = CONTOUR(SOS_CHP,FINDGEN(NX)/10.+map_ulx, FINDGEN(NY)/10.+map_lry, $ ;
      ASPECT_RATIO=1, Xstyle=1,Ystyle=1, $
      ;RGB_TABLE=ct,/FILL, C_VALUE=index,RGB_INDICES=FIX(FINDGEN(ncolors)*255./ncolors), $
      /FILL, C_VALUE=index,C_COLOR=col_names, $     
      TITLE='SOS CHIRPS', /BUFFER)  &$
      m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot) &$;
      m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2) &$
      tmptr.mapgrid.linestyle = 'none'  &$ ; could also use 6 here
      tmptr.mapgrid.FONT_SIZE = 0 &$
      cb = colorbar(target=tmptr,ORIENTATION=0, /BORDER,TAPER=0,THICK=0, TITLE='Dekad Onset of rains')
      cb.tickvalues = (FINDGEN(17))
      cb.tickname = MONTHS
      tmptr.save,'CHIRPS.png'
      close 
 

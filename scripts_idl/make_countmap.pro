pro make_countmap

;11/02/16 separated out this module from scenarioTri for generateing countmaps from ESP.
;this was originally done with the bootstrap method. but now switching to vanilla/traditional
;01/27/17 revisit
;01/30/17 after running ESP script, use this to make a countmap for each yr and var of interest.

.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro

;yrs used for the ESPing
startyr = 1982
endyr = 2015 ;do i have 2016 estimates?
nyrs = endyr-startyr+1

yr = indgen(nyrs)+1982 & print, yr


params = get_domain01('EA')
eNX = params[0]
eNY = params[1]
emap_ulx = params[2]
emap_lrx = params[3]
emap_uly = params[4]
emap_lry = params[5]

NX = eNX
NY = eNY

;; if not read it in or run make_permap.pro
permap = fltarr(nx, ny, 12, 3)
ifile = file_search('/discover/nobackup/projects/fame/MODEL_RUNS/EA_Noah33/ESPvanilla/SM01_NOAH_permap_294_348_12_3_1982_2016.bin')
openr, 1, ifile
readu, 1, permap
close,1

;first make sure you have the threshold map
help, permap
;feb_permap = permap[*,*,1,*]
;mar_permap = permap[*,*,2,*]

;;;forecast intialization date 
startd = '20170330' ;'20170228'
;make sure i am looking at the right runs
NOAHdir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/'
indir2 = NOAHdir+'Noah33_CHIRPS_MERRA2_EA/ESPvanilla/Noah33_CM2_ESPV_EA/'+string(startd)
;indir2 = NOAHdir+'Noah33_RFE_GDAS_EA/ESPvanilla/Noah33_RG_ESPV_EA/'+string(startd)

;;generate countmap for a given month;;;;;
;m = month of interest from countmap e,g, february...
;percentile map bases at end of month, while ESP at first. e.g. MarchESP=FEBper

;ESPmonth march
ESP_M = 6 ;jajnuary=1, feb=2, Mar1=3 April1=4, May1=5, June1=6
PER_M = ESP_M-1
M = PER_M-1
;PERmonth PerM = M-1

ifile = file_search(strcompress(indir2+'/????/SURFACEMODEL/????'+STRING(format='(I2.2)', ESP_M) +'/LIS_HIST*.nc', /remove_all))
help, ifile
;;;;;read in the daily estimate;;;;
countmap = fltarr(NX,NY,3)*0
dry = fltarr(NX, NY)*0
for i = 0, n_elements(ifile)-1 do begin &$
  ;for m = 0, 11 do begin &$
  VOI = 'SoilMoist_tavg' &$
  ;read in all soil layers
  SM = get_nc(VOI, ifile[i]) &$
  ;just keep the top layer
  SMlayer = SM[*,*,0] &$ 
  ;count n times that soil is less than 0.33 threshold  
  dry = SMlayer lt permap[*,*,M,0] &$
  countmap[*,*,0] = countmap[*,*,0] + dry &$
  ;count n times that soil is less than 0.67 threshold 
  avg = SMlayer lt permap[*,*,M,2] &$
  countmap[*,*,1] = countmap[*,*,1] + avg &$
  print, i &$
endfor

;add the analogue yrs (2012, 2004) in a couple more times
AN1 = '2004'
ifile = file_search(strcompress(indir2+'/'+AN1+'/SURFACEMODEL/'+AN1+STRING(format='(I2.2)', ESP_M) +'/LIS_HIST*.nc', /remove_all))
;add 2012 ...do 8  more times
for j = 0,7 do begin &$  
  VOI = 'SoilMoist_tavg' &$
  ;read in all soil layers
  SM = get_nc(VOI, ifile) &$
  ;just keep the top layer
  SMlayer = SM[*,*,0] &$
  ;count n times that soil is less than 0.33 threshold
  dry = SMlayer lt permap[*,*,M,0] &$
  countmap[*,*,0] = countmap[*,*,0] + dry &$
  ;count n times that soil is less than 0.67 threshold
  avg = SMlayer lt permap[*,*,M,2] &$
  countmap[*,*,1] = countmap[*,*,1] + avg &$
  print, j &$
endfor 
  
;finalize the count map 3/2-2/3-1/3
ifile = file_search(strcompress(indir2+'/????/SURFACEMODEL/????'+STRING(format='(I2.2)', ESP_M) +'/LIS_HIST*.nc', /remove_all))

countmap[*,*,2] = n_elements(ifile)+16 ;say that 100% of values are wet (+16 for the weighted exp
countmap[*,*,2] = countmap[*,*,2]-countmap[*,*,1]; wet-average
countmap[*,*,1] = countmap[*,*,1]-countmap[*,*,0]; average - dry

;three panel count map
map_ulx = emap_ulx & min_lon = map_ulx
map_lry = emap_lry & min_lat = map_lry
map_uly = emap_uly & max_lat = map_uly
map_lrx = emap_lrx & max_lon = map_lrx

indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/'
mfile_E = file_search(indir+'lis_input_ea_elev.nc')

VOI = 'LANDCOVER'
LC = get_nc(VOI, mfile_E)
range = where(LC[*,*,6] gt 0.3, complement=other)
rmask = fltarr(NX,NY)+1.0
rmask(other)=!values.f_nan
rmask(range)=1

;;water and baresoil mask
indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/'
mfile_E = file_search(indir+'lis_input.MODISmode_ea.nc')

VOI = 'LANDCOVER'
LC = get_nc(VOI, mfile_E)
bare = where(LC[*,*,15] eq 1, complement=other)
water = where(LC[*,*,16] eq 1, complement=other)
Emask = fltarr(eNX,eNY)+1.0
Emask(bare)=!values.f_nan
Emask(water)=!values.f_nan

w = WINDOW(WINDOW_TITLE='June 1 outlook',DIMENSIONS=[NX+1600,NY+200])
xsize=0.10
ysize=0.10
mlim = [min_lat,min_lon,max_lat,max_lon]
ifile = file_search(strcompress(indir2+'/????/SURFACEMODEL/????'+STRING(format='(I2.2)', ESP_M) +'/LIS_HIST*.nc', /remove_all))
ncolors = n_elements(ifile)+16 ;IBBP=20, UMD=14
tercile = ['dry', 'avg', 'wet']

for i = 0,2 do begin &$
  m1 = MAP('Geographic',LIMIT=mlim,/CURRENT,horizon_thick=1, layout = [3,1,i+1])  &$
  p1 = image(countmap[*,*,i]*emask*rmask,rgb_table=20,image_dimensions=[nx*xsize,ny*ysize], image_location=[map_ulx,map_lry], $
  MAP_PROJECTION='Geographic', XSTYLE=1, YSTYLE=1, /OVERPLOT) &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1)) &$
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  ;rgbdump[*,0:(256/ncolors)] = rebin([190,190,190],3,(256/ncolors)+1)  &$
 ; rgbdump[*,0] = rebin([0,255,255],3,1)  &$
  p1.rgb_table = rgbdump  &$
  ;use this if using all colors, not needed for nsims/2
  p1.min_value = 0.5  &$
  p1.max_value = ncolors+0.5  &$
  p1.title = 'count of '+tercile[i] &$
  if i eq 2 then c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON, POSITION=[0.96,0.08,0.99,0.9])  &$
  m1.mapgrid.linestyle = 6 &$
  m1.mapgrid.label_show = 0  &$
  m1.mapgrid.label_position = 0  &$
  mc = MAPCONTINENTS(shapefile, /COUNTRIES,COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=mlim)  &$
endfor

p1.title = 'ncolors'

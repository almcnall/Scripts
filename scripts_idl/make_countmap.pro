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
startd = '20170315' ;'20170228'
;make sure i am looking at the right runs
NOAHdir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/'
indir2 = NOAHdir+'Noah33_CHIRPS_MERRA2_EA/ESPvanilla/Noah33_CM2_ESPV_EA/'+string(startd)
;indir2 = NOAHdir+'Noah33_RFE_GDAS_EA/ESPvanilla/Noah33_RG_ESPV_EA/'+string(startd)

;;generate countmap for a given month;;;;;
;m = month of interest from countmap e,g, february...
;percentile map bases at end of month, while ESP at first. e.g. MarchESP=FEBper

;ESPmonth march
ESP_M = 6 ;january=1, feb=2, Mar1=3 April1=4, May1=5
PER_M = ESP_M-1
M = PER_M-1
;PERmonth PerM = M-1

;change this so it matches month of interest
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

;finalize the count map 3/2-2/3-1/3
countmap[*,*,2] = n_elements(ifile) ;say that 100% of values are wet
countmap[*,*,2] = countmap[*,*,2]-countmap[*,*,1]; wet-average
countmap[*,*,1] = countmap[*,*,1]-countmap[*,*,0]; average - dry

moist = ['dry', 'avg', 'wet']
;;;look at it or write it out if needed;;;;;
w=window()
for i = 0,2 do begin &$
  temp = image(countmap[*,*,i], rgb_table=20, layout=[3,1,i+1], /current, min_value=0, max_value=36) &$
  if i eq 2 then c=colorbar() &$
  temp.title = 'count of '+string(moist[i]) &$
endfor

;check out the threshold maps
w=window() 
for M = 0,11 do begin &$  
  ;for i = 0,2 do begin &$
    i=1 &$   
    temp = image(permap[*,*,M,i], rgb_table=20, layout=[3,4,m+1], /current, min_value=0, max_value=0.4) &$
    if i eq 2 then c=colorbar() &$
    temp.title = 'month= '+string(M+1)  &$
  endfor &$
endfor
temp.save, '/home/almcnall/IDLplots/tritest3.png'

ofile = strcompress('/home/almcnall/IDLplots/countmap_294_348_3_SM01.bin')
openw,1,ofile
writeu,1,countmap
close,1

pro make_countmap

;11/02/16 separated out this module from scenarioTri for generateing countmaps from ESP.
;this was originally done with the bootstrap method. but now switching to vanilla/traditional
;01/27/17 revisit
;01/30/17 after running ESP script, use this to make a countmap for each yr and var of interest.

;;read in the permap rather than running make_permap.pro
permap = fltarr(nx, ny, 12, 3)
ifile = '/home/almcnall/IDLplots/SM01_permap_294_348_12_3.bin'
openr, 1, ifile
readu, 1, permap
close,1

;first make sure you have the threshold map
help, permap
;now i just have to count my forecasts.

startd = '20161231'
;indir2 = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/ESPtest/Noah33_CM2_ESPboot_OCT2015JAN2016/ENS/ens???/post/'
NOAHdir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/'
indir2 = NOAHdir+'Noah33_CHIRPS_MERRA2_EA/ESPvanilla/Noah33_CM2_ESPV_EA/'+string(startd)

;each ensemble e.g. E1982 needs to post process its months (what script does this? can i do this with my regular
;scripts and just point it to the ESP directory .../YYYY/SURFACEMODEL/(all months)

;for years 1982 - 2015 used to projected rest-of-season
;YYYY = 1982
;proj = '????01'
;proj = ['198301', '198302', '198303', '198304']
;this gets all daily SM estimates from January.
M=0 ;january
ifile = file_search(strcompress(indir2+'/????/SURFACEMODEL/????01/LIS_HIST*.nc', /remove_all))

;;;;;;read in monthly estimates;;;;
;MM=11
;ifile2 = file_search(strcompress(indir2+'FLDAS_NOAH01_C_EA_M.A2015'+string(MM)+'.001_*', /remove_all))
;SM01 = fltarr(NX, NY, n_elements(ifile2))
;;so read in each of these files,
;for i = 0, n_elements(ifile2)-1 do begin &$
;  VOI = 'SoilMoi00_10cm_tavg' &$
;  SM = get_nc(VOI, ifile2[i]) &$
;  SM01[*,*,i] = SM &$
;endfor
;;;;;;;;;;;;;;;;;
;
;;;;;read in the daily estimate;;;;
countmap = fltarr(NX,NY,3)*0
dry = fltarr(NX, NY)*0
M = 0
for i = 0, n_elements(ifile)-1 do begin &$
  ;for m = 0, 11 do begin &$
  VOI = 'SoilMoist_tavg' &$
  ;read in all soil layers
  SM = get_nc(VOI, ifile[i]) &$
  ;just keep the top layer
  SM01 = SM[*,*,0] &$ 
  dry = SM01 lt permap[*,*,M,0] &$
  countmap[*,*,0] = countmap[*,*,0] + dry &$
  ;i shouldn't have to do the between since i can subtract at the end since it should equal 100.
  avg = SM01 lt permap[*,*,M,2] &$
  countmap[*,*,1] = countmap[*,*,1] + avg &$
endfor

;3/2-2/3-1/3
countmap[*,*,2] = 1054
countmap[*,*,2] = countmap[*,*,2]-countmap[*,*,1]
countmap[*,*,1] = countmap[*,*,1]-countmap[*,*,0]

temp = image(countmap[*,*,2], /buffer, rgb_table=20)
c=colorbar()
temp.save, '/home/almcnall/IDLplots/tritest3.png'

ofile = strcompress('/home/almcnall/IDLplots/countmap_294_348_3_SM01.bin')
openw,1,ofile
writeu,1,countmap
close,1

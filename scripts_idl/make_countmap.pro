pro make_countmap

;11/02/16 separated out this module from scenarioTri for generateing countmaps from ESP.
;this was originally done with the bootstrap method. but now switching to vanilla/traditional

;first make sure you have the threshold map
help, permap
;now i just have to count my forecasts.

startd = '20160930'
;indir2 = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/ESPtest/Noah33_CM2_ESPboot_OCT2015JAN2016/ENS/ens???/post/'
NOAHdir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/'
indir2 = NOAHdir+'Noah33_CHIRPS_MERRA2_EA/ESPvanilla/Noah33_CM2_ESPV_EA/'+string(startd)

;each ensemble e.g. E1982 needs to post process its months (what script does this? can i do this with my regular
;scripts and just point it to the ESP directory .../YYYY/SURFACEMODEL/(all months)

MM=11
ifile2 = file_search(strcompress(indir2+'FLDAS_NOAH01_C_EA_M.A2015'+string(MM)+'.001_*', /remove_all))

SM01 = fltarr(NX, NY, n_elements(ifile2))
;so read in each of these files,
for i = 0, n_elements(ifile2)-1 do begin &$
  VOI = 'SoilMoi00_10cm_tavg' &$
  SM = get_nc(VOI, ifile2[i]) &$
  SM01[*,*,i] = SM &$
endfor

;check the value at each pixel? or can i do whole map vs the threshold, count
;help, permap[*,*,MM-1,*]

;;;first look at the low percentile map
countmap = fltarr(NX,NY,3)*0

for j = 0, n_elements(SM01[0,0,*])-1 do begin &$

    ;do I need the where statement? no this should give me a map of ones.
    dry = SM01[*,*,j] lt permap[*,*,MM-1,0] &$
    countmap[*,*,0] = countmap[*,*,0] + dry &$

    ;i shouldn't have to do the between since i can subtract at the end since it should equal 100.
    ;but how do i do the subtraction?
    avg = SM01[*,*,j] lt permap[*,*,MM-1,2] &$
    countmap[*,*,1] = countmap[*,*,1] + avg &$

endfor
countmap[*,*,2] = 100
countmap[*,*,2] = countmap[*,*,2]-countmap[*,*,1]
countmap[*,*,1] = countmap[*,*,1]-countmap[*,*,0]

ofile = strcompress('/home/almcnall/2015'+string(MM)+'_countmap_294_348_3.bin',/remove_all)
openw,1,ofile
writeu,1,countmap
close,1

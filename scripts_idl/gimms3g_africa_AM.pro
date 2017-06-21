pro GIMMS3g_africa
; Code orginially from laura harrison, updated on March 10, 2015 to add new data.
; this code stacks bimonthly NDVI for 1981-present and saves it to a new file (integer; divide data by 10000 to get NDVI values e.g. -1 will be water; -5 no data)
; AFRICA EXTENT
; GIMMS3G NDVI
; This dataset is an inverse cartographic transformation and mosaicing of the
;    GIMMS AVHRR 8-km Albers Conical Equal Area continentals AF, AZ, EA, NA, and
;    SA to a global 1/12-degree Lat/Lon grid.
; 

; clip global data to this area:
  xcoord1 = -20
  xcoord2 = 55
  ycoord1 = -40
  ycoord2 = 40

; output file dim: nx= 900  ny= 960, nband= 720 


  indir = '/home/NDVI/GIMMS-3g_v_2015/';  /home/NDVI/GIMMS-3g/'
  ;outdir = '/home/NDVI/GIMMS-3g/regional_cubes/'
  outdir = '/home/sandbox/people/mcnally/regionalcube_GIMMS'
  fout = strcompress(outdir + 'GIMMS3g_africa.img',/remove_all)

  nx = 4320
  ny = 2160
; resolution: 1/12 = 12 grid cells per degree.

; from -180 to -20. The 160th degree from the left of data is -20W. 12 grid cells per degree.
	ulx = 160. * 12.
; from -20W to 55E is 75 degrees. 160deg + 75deg from the left of the data is 55E. Subtract 1 to not overshoot.
	lrx = 235. * 12. -1
; data starts at the bottom (90S)
; from 90S to 40S is 50 degrees
	lry = 50. * 12.
; to 40N is another 80 degrees. 50deg + 80deg from th bottom is 40N. Subtract 1 to not overshoot.
	uly = 130. * 12. -1

	nx_clip = lrx-ulx+1
	ny_clip = uly-lry+1

  ;cd,indir
  
  year = [82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,00,01,02,03,04,05,06,07,08,09,10,11,12,13]
  yrstr = STRING(format='(I2.2)', year)
  numyr = n_elements(year)
  
  month = ['jan','jan','feb','feb','mar','mar','apr','apr','may','may','jun','jun','jul','jul','aug','aug','sep','sep','oct','oct','nov','nov','dec','dec']
  num = [1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12]
  monum = string(format='(I2.2)', num)
  
  ;pa = REPLICATE("a",n_elements(year))
  ;pb = REPLICATE("b",n_elements(year))
  ;period = reform(transpose([[pa],[pb]]),1,n_elements(pa)*2)

  period = ['a','b','a','b','a','b','a','b','a','b','a','b','a','b','a','b','a','b','a','b','a','b','a','b']
  nfiles = n_elements(year) * n_elements(month)/2 * 2

; generate first part of file names (so read in in correct order)
  i = 0
  j = 0
  k = 0
  fn1 = strarr(nfiles)
  for i = 0,(numyr-1) do begin &$
    ;for p = 0,11 do begin &$
    k = i*24 &$
    ;how doesnt this work?
    j = indgen(24,start=k) &$
    fn1[j] = strcompress(indir + 'geo' + yrstr[i] + month + '15' + period +'*',/remove_all) &$
   ;fn1[j] = file_search(strcompress(indir + 'geo' + yrstr[i] + month + '15' + period[p] +'*',/remove_all)) &$
   ;endfor &$
  endfor
  
  ;trying to figure out how to rename these awful files, start here:
  for i = 0,n_elements(monum)-1 do begin
   ofile = outdir + strmid(ifile,21,13)+'_'+strmid(ifile,35,4)+monnum(i)+

  ;NDVI = intarr(nx_clip,ny_clip,nfiles)
  i=0 &$
  for i= 0,(nfiles)-1 do begin &$
    ifile = file_search(strcompress(fn1[i], /remove_all)) &$
    print, ifile &$
;    datin = intarr(ny,nx) &$
;    openr,1,ifile &$
;    readu,1,datin &$
;    close,1 &$
;    datin = swap_endian(datin,/SWAP_IF_LITTLE_ENDIAN) &$
;    datin = rotate(datin,3) &$
;
;  ; clip the global extent to desired country extent.
;    clp = intarr(nx_clip,ny_clip) &$
;    clp = datin[ulx:lrx,lry:uly]    &$ 
;   ofile = '/home/sandbox/people/mcnally/regionalcube_GIMMS/ &$
;  ; place in stack
;    ;NDVI[*,*,i] = reverse(clp,2)
;    delvar,clp, datin &$
  endfor

  
; write to new file
;tmp=image(NDVI[*,*,0])
    openw,1,fout
    writeu,1,NDVI
    close,1

; to write header I open this data in envi and input samples = 900; lines=960; bands=720; integer; bsq
; then edit map info to:
; coord of tie points= 1.0, 1.0 (envi reads first grid cell as '1' and the tie point uses the left edge of cell)
; -20E, 40N
; res = 0.0833333
print, 'the end!' 

end 


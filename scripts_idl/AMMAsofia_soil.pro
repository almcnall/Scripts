pro AMMAsofia_soil

;the purpose of this script is to read in both the soil and rainfall data, 
;subset the data so that I am looking at two or three regions and do some
;summary statistics on these two regions. If I need to do time series or spatial stats
;I may have to move back over to matlab but I think that this will work for now. 
;
;*************read in files*****************************
indir= '/home/mcnally/lischeck/'
cd, indir

rf = file_search('monthlyrain_143plus2.csv')
sf = file_search('soil40._matlab.csv'); this is only at 40cm I guess I need to make 
;                                       some more of these but it is a good start
rfname = indir+rf
sfname = indir+sf

rfile = read_csv(rfname,count=count, missing_value=-9999.9)
sfile = read_csv(sfname,missing_value=-9999.9)

index = where(rfile.field1 gt -9998.,count)
rlat = rfile.field1(index)
rlon = rfile.field2(index)
ryr = rfile.field3(index)
rmo = rfile.field4(index)
rain = rfile.field5(index)

good = where(sfile.field1 gt -9998.,count)
slat = sfile.field1(good)
slon = sfile.field2(good)
syr = sfile.field3(good)
smo = sfile.field4(good)
sm = sfile.field5(good)

rlatlons=[transpose(rlat),transpose(rlon)]
slatlons=[transpose(slat),transpose(slon)]

;***************dealing with duplicate latlons RAIN************************
;; Step 1: Map your columns 2 and 3 into a single unique index
  col1ord = ord(rlatlons[0,*])
  col2ord = ord(rlatlons[1,*])
  index = col1ord + (max(col1ord)+1)*col2ord ;this turns the 2 cols into a single unique index
; Step 2: Use histogram to find which ones have the same unique index 
  h = histogram(index, reverse_indices=ri) ;list of subscripts that contribute to each bin
; Step 3: Get the first one in each bin, and put back in sorted order 
  keep = ri[ri[where(h gt 0)]] 
  keep = keep[sort(keep)] 
; Step 4: Print/write them out without the nans
  runqlatlon = rlatlons[*,keep] 
  runqlatlon = reform(runqlatlon(where(finite(runqlatlon))),2,110) ;the 111 will have to change when reading other files
;********************************************************************


;***************dealing with duplicate latlons SOIL************************
;; Step 1: Map your columns 2 and 3 into a single unique index
  col1ord = ord(slatlons[0,*])
  col2ord = ord(slatlons[1,*])
  index = col1ord + (max(col1ord)+1)*col2ord ;this turns the 2 cols into a single unique index
; Step 2: Use histogram to find which ones have the same unique index 
  h = histogram(index, reverse_indices=ri) ;list of subscripts that contribute to each bin
; Step 3: Get the first one in each bin, and put back in sorted order 
  keep = ri[ri[where(h gt 0)]] 
  keep = keep[sort(keep)] 
; Step 4: Print/write them out without the nans
  sunqlatlon = slatlons[*,keep] 
  sunqlatlon = reform(sunqlatlon(where(finite(sunqlatlon))),2,49) ;the 111 will have to change when reading other files
;********************************************************************
;***what is up with these sofia stations, hu?
month = [1,2,3,4,5,6,7,8,9,10,11,12]
yr = [2005,2006,2007,2008]

;**************all rainstations, lumped*****************************
rarray=fltarr(5,12)
rarray[*,*]=!VALUES.F_NAN
rcubie=fltarr(4,12,6)
rcubie[*,*,*]=!VALUES.F_NAN
cntr=0
rmac=fltarr(5,48)
for i = 0, n_elements(yr)-1 do begin
  for j = 0,n_elements(month)-1 do begin
    ;I should get rid of this when I know that it eq the average accross yrs.
    moyrR = !VALUES.F_NAN
    moyrR = rain(where(ryr eq yr[i] AND rmo eq month(j), count))
    if count le 1 then begin
    cntr++
    continue
    endif
    ravg = mean(moyrR, /nan) 
    if count gt 1 then rstdev = stdev(moyrR)
    rcv = rstdev/ravg ;coefficent of variation, signal to noise ratio, dimensionless
    rStderr = stdev(moyrR)/sqrt(count)
    uCI = ravg+(rStderr*1.96)
    lCI = ravg-(rStderr*1.96)
    Rcubie[i,j,*] = [ravg,rstdev,rcv,rStderr,uCI,lCI]
    rmac[*,cntr]=[yr[i], month[j],ravg,uCI,lCI] ;use trasnspose, reform instead
    cntr++
  endfor 
endfor

;****calculate the shorterm monthly mean*****************
rstm=mean(rcubie[*,*,0], dimension=1, /nan) & print, transpose(rstm)
ranom=fltarr(4,12)

cntr=0
for i=0,n_elements(yr)-1 do begin
  ranom[i,*]=rcubie[i,*,0]-rstm
endfor

;***************same with wet sites*****************************
;what is up with these stations? I need to look at them individualy
;arrayWet=fltarr(5,12)
;arrayWet[*,*]=!VALUES.F_NAN
;Wetcubie=fltarr(4,12,8)
;Wetcubie[*,*,*]=!VALUES.F_NAN
;Wetmac=fltarr(5,48)
sofiacubie=fltarr(9,48,3)
sofiacubie[*,*,*]=!VALUES.F_NAN
count=0

sofiasites = sunqlatlon(*,where(sunqlatlon[1,*] gt 2.7,count))
month = [1,2,3,4,5,6,7,8,9,10,11,12]
yr = [2005,2006,2007,2008]
cntr=0
 for k=0,n_elements(sofiasites[0,*])-1 do begin
   cntr=0
   for i = 0, n_elements(yr)-1 do begin
     for j = 0,n_elements(month)-1 do begin  
   
    sofiaSM=sm(where(syr eq yr[i] AND smo eq month[j] and slat eq sofiasites[0,k] AND slon eq sofiasites[1,k], count)) & print, count
    if count eq 0 then begin
      cntr++
      continue
    endif
    sofiacubie[k,cntr,*] = [sofiasites[0,k], sofiasites[1,k], sofiaSM]
    cntr++
    avg=mean(sofiacubie[*,*,2], dimension=1, /nan)
    p1=plot(avg)
    p1=plot(sofiacubie[0,*,2], /overplot, color='green', linestyle=3)
    p1=plot(sofiacubie[1,*,2], /overplot, color='blue')
    p1=plot(sofiacubie[2,*,2], /overplot, color='orange')
    p1=plot(sofiacubie[3,*,2], /overplot, color='green')
    p1=plot(sofiacubie[4,*,2], /overplot, color='red')
    p1=plot(sofiacubie[5,*,2], /overplot, color='cyan')
    p1=plot(sofiacubie[6,*,2], /overplot, color='grey')
    p1=plot(sofiacubie[7,*,2], /overplot, color='orange', linestyle=2)
    p1=plot(sofiacubie[8,*,2], /overplot, color='blue',linestyle=2)

    endfor
  endfor 
endfor

wstm=mean(wetcubie[*,*,2], dimension=1, /nan) & print, transpose(wstm)
dstm=mean(drycubie[*,*,2], dimension=1, /nan) & print, transpose(dstm)
wanom=fltarr(4,12)
danom=fltarr(4,12)

cntr=0
for i=0,n_elements(yr)-1 do begin
  wanom[i,*]=wetcubie[i,*,2]-wstm
  danom[i,*]=drycubie[i,*,2]-dstm
endfor

 end
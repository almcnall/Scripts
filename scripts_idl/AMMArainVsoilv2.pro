pro AMMArainVsoilv2

;the purpose of this script is to read in both the soil and rainfall data, 
;subset the data so that I am looking at two or three regions and do some
;summary statistics on these two regions. If I need to do time series or spatial stats
;I may have to move back over to matlab but I think that this will work for now. 
;
;*************read in files*****************************
;indir= '/home/mcnally/lischeck/' ;i think that I got rid of this directory...
cd, indir

rf = file_search('monthlyrain_143plus2.csv')
sf = file_search('soil90_matlab.csv'); this is only at 40cm I guess I need to make 
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
  sunqlatlon = reform(sunqlatlon(where(finite(sunqlatlon))),2,50) ;the 111 will have to change when reading other files
;********************************************************************

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

;good=where(finite(ranom), complement=bad)
;ranom(bad)=0
;ranomplot=reform(transpose(ranom),1,48)
;p1=barplot(ranomplot[12:47]); this might look like the dry site...
;p1=barplot(ranom[1,*])
;p1=barplot(ranom[2,*], color='red',/overplot)

;****************************cluster my soil moisture into two groups********************************
;**************Dry stations (NW & SE by month, averaged over all 4 yrs, use this as the mean for anamolies*******
arrayDry=fltarr(5,12)
arrayDry[*,*]=!VALUES.F_NAN
Drycubie=fltarr(4,12,8)
Drycubie[*,*,*]=!VALUES.F_NAN
cntr=0
drymac=fltarr(5,48)
for i = 0, n_elements(yr)-1 do begin
  for j = 0,n_elements(month)-1 do begin
    ;I should get rid of this when I know that it eq the average accross yrs.
    moyrDry = !VALUES.F_NAN
    moyrDry = sm(where(syr eq yr[i] AND smo eq month(j) AND slatlons[1,*] lt 2.7,count))
    if count le 1 then begin
    cntr++
    continue
    endif
    savg = mean(moyrDry, /nan) 
    sstdev = stdev(moyrDry)
    scv = sstdev/savg ;coefficent of variation, signal to noise ratio, dimensionless
    sStderr = stdev(moyrDry)/sqrt(count)
    uCI = savg+(sStderr*1.96)
    lCI = savg-(sStderr*1.96)
    Drycubie[i,j,*] = [yr[i],month[j],savg,sstdev,scv,sStderr,uCI,lCI]
    drymac[*,cntr]=[yr[i],month[j],savg,uCI,lCI]
    cntr++
  endfor 
endfor

;p3=plot(dmoavg, title='Dry stations with CIs',color='blue',xtickname=string(month))
;p4=plot(dmouCI, /overplot, color='blue', linestyle=2)
;p5=plot(dmolCI, /overplot, color='blue', linestyle=2)

;*******calculate monthly averages*********
dmoavg=fltarr(n_elements(month))
dmouCI=fltarr(n_elements(month))
dmolCI=fltarr(n_elements(month))
for i=0, n_elements(month)-1 do begin
  dmoavg[i] = mean(drycubie[*,i,2],/nan);this is the same as the dstm
  dmouCI[i] = mean(drycubie[*,i,6],/nan)
  dmolCI[i] = mean(drycubie[*,i,7],/nan)
endfor

;p3=plot(dmoavg, title='Dry stations with CIs',color='blue',xtickname=string(month))
;p4=plot(dmouCI, /overplot, color='blue', linestyle=2)
;p5=plot(dmolCI, /overplot, color='blue', linestyle=2)

;***************same with wet sites*****************************
;what is up with these stations? I need to look at them individualy
arrayWet=fltarr(5,12)
arrayWet[*,*]=!VALUES.F_NAN
Wetcubie=fltarr(4,12,8)
Wetcubie[*,*,*]=!VALUES.F_NAN
Wetmac=fltarr(5,48)
cntr=0

for i = 0, n_elements(yr)-1 do begin
  for j = 0,n_elements(month)-1 do begin
    ;I should get rid of this when I know that it eq the average accross yrs.
    moyrWet = !VALUES.F_NAN
    moyrWet = sm(where(syr eq yr[i] AND smo eq month(j) AND slatlons[1,*] gt 2.7,count))
    if count le 1 then begin
      cntr++
      continue
    endif
    savg = mean(moyrWet, /nan) 
    sstdev = stdev(moyrWet)
    scv = sstdev/savg ;coefficent of variation, signal to noise ratio, dimensionless
    sStderr = stdev(moyrDry)/sqrt(count)
    uCI = savg+(sStderr*1.96)
    lCI = savg-(sStderr*1.96)
    Wetcubie[i,j,*] = [yr[i],month[j],savg,sstdev,scv,sStderr,uCI,lCI]
    
    Wetmac[*,cntr]=[yr[i],month[j],savg,uCI,lCI]
    cntr++
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

;just for barplots....
;wanomplot=reform(transpose(wanom),1,48)
;index=where(finite(wanomplot), complement=wbad)
;wanomplot(wbad)=0
;danomplot=reform(transpose(danom),1,48)
;index=where(finite(danomplot), complement=dbad)
;danomplot(dbad)=0
;
;p1=barplot(wanomplot,index=1,nbars=4, fill_color='purple')
;p2=barplot(danomplot,index=4,nbars=4, fill_color='orange',/overplot)
;p1=barplot(wanomplot, title='wet site anomalies 2005 to 2008')
;p2=barplot(danomplot, title='dry site anomalies 2005 to 2008')
;e.g.
;
p1=plot(drymac[2,*],color='blue', title='wet and dry sites 2005 to 2008')
;p1=plot(drymac[1,*], /overplot, color='blue',linestyle=2)
;p1=plot(drymac[2,*], /overplot, color='blue',linestyle=2)
;
p1=plot(wetmac[2,*], /overplot,color='orange')
;p1=plot(wetmac[1,*], /overplot, color='orange',linestyle=2)
;p1=plot(wetmac[2,*], /overplot, color='orange',linestyle=2)
;
;p1=plot(wetmac[0,*]-drymac[0,*],color='grey')

;rsq = correlate(wetmac[2,*], drymac[2,*]) & print, rsq
;lag = [-5,-4,-3,-2,-1,0,1,2,3,4,5]
;
;;*********crosscorrelation of wet and dry sites, the wet sites do lead the dry*****************
;good1=where(drymac[0,*] gt 0, count) & print, count
;scorr = c_correlate(wetmac[2,good1], drymac[2,good1],lag) & print, scorr
;p1=plot(scorr, xtickname=string(lag), title='crosscorr wet and dry sites');
;
;good=where(wetmac[0,*] gt 0)
;p2=plot(wetmac[2,good], color='blue',title='wet and dry sites and CIs') 
;p2=plot(wetmac[3,good], color='blue',/overplot, linestyle=2)
;p2=plot(wetmac[4,good], color='blue',/overplot, linestyle=2)
;p2=plot(drymac[2,good], color='orange', /overplot)
;p2=plot(drymac[3,good], color='orange', /overplot, linestyle=2)
;p2=plot(drymac[4,good], color='orange', /overplot, linestyle=2)
;
;good2=where(danomplot gt 0, count) & print, count
;asccorr = c_correlate(wanomplot(good2), danomplot(good2),lag) & print, ccorr 
;p1=plot(asccorr, xtickname=string(lag), title='crosscorr wet and dry site anomplies');there could be a yr lag in the wet sites, dunno
;p1=barplot(wanomplot(good2),nbars=2, color='red')
;p1=barplot(danomplot)
;
;good3=where(rmac[0,*] gt 0 AND wetmac[0,*] gt 0,count) & print, count
;rccorr = c_correlate(wetmac[0,good3], rmac[0,good3],lag) & print, rccorr ;maybe I need to try this with anamolies since the scale are so different
;p1=plot(rccorr, xtickname=string(lag), title='crosscorr wet soil and rain')
;
;;good4=where(rmac[0,*] gt 0, count) & print, count
;rdccorr = c_correlate(drymac[0,good3], rmac[0,good3],lag) & print, rdccorr ;maybe I need to try this with anamolies since the scale are so different
;p1=plot(rdccorr, xtickname=string(lag), title='crosscorr dry soil and rain');big neg corr at 3 months. what is this?
;
;;how do I plot these on 2 axis?
;p1=plot(drymac[0,good4])
;p1=plot(rmac[0,good4], /overplot, color='blue')
;
;ccorr = c_correlate(danomplot, ranomplot,lag) & print, ccorr ;maybe I need to try this with anamolies since the scale are so different
;good=where(ranomplot gt 0, count) & print, count
;ccorr = c_correlate(danomplot(good), ranomplot(good),lag) & print, ccorr ;maybe I need to try this with anamolies since the scale are so different


print, 'hold here'

;I still need to make these anomaly plots!!**********************
;*******calculate monthly averages*********
;wmoavg=fltarr(n_elements(month))
;wmouCI=fltarr(n_elements(month))
;wmolCI=fltarr(n_elements(month))
;for i=0, n_elements(month)-1 do begin
;  wmoavg[i] = mean(wetcubie[*,i,0],/nan)
;  wmouCI[i] = mean(wetcubie[*,i,4],/nan); looks like stderr is a communitive property...is that ok?>
;  wmolCI[i] = mean(wetcubie[*,i,5],/nan)
;endfor
;
;p3=plot(wmoavg, /overplot, color='orange')
;p4=plot(wmouCI, /overplot, color='orange', linestyle=2)
;p5=plot(wmolCI, /overplot, color='orange', linestyle=2)






;p5=plot(arrayNW[*,2], /overplot)

;*********wet stations*********************************
;South Southeast stations n=19...
print, 'pls stop here'
arraySSE=fltarr(5,12)
arraySSE[*,*]=!VALUES.F_NAN
for j=0,n_elements(month)-1 do begin
  moindexSSE=sm(where(smo eq month(j) AND slatlons[0,*] lt 13.56 AND slatlons[1,*] gt 2.7,count))
  if count le 1 then continue
  savg = mean(moindexSSE) ;try this when I get home 10/9/11
  sstdev = stdev(moindexSSE)
  Stderr = stdev(moindexSSE)/sqrt(count)
  uCI = savg+(Stderr*1.96)
  lCI = savg-(Stderr*1.96)
  ;use arraySSE[0,*] later for the mean
  arraySSE[*,j]=[savg,sstdev,Stderr,uCI,lCI]
endfor

;p8=plot(arraySSE[0,*],/overplot,color='orange')
;p9=plot(arraySSE[3,*], /overplot,linestyle=4,color='orange')
;p9b=plot(arraySSE[4,*], /overplot,linestyle=4,color='orange')
;
;p9c=plot(arraySSE[0,*]-arrayDry[0,*],/overplot)
;p3.name = 'NW mean'
;p6.name = 'SE mean'
;p8.name = 'SSE mean'
;
;!null = legend(target=[p3,p6,p8], position=[0.2,0.3]) ; not sure how this line works...

;***************rainfall!**************************
;**********monthly mean and stdev for all of the data together*******************

rarray=fltarr(5,12)
rarray[*,*]=!VALUES.F_NAN
rStderr=fltarr(12)
for i=0,n_elements(month)-1 do begin
  rmoindex=rain(where(rmo eq month(i), count))& print, count
  if count le 1 then continue
  ravg = mean(rmoindex) ;try this when I get home 10/9/11
  rstdev = stdev(rmoindex)
  rStderr = stdev(rmoindex)/sqrt(count)
  uCI = ravg+(rStderr*1.96)
  lCI = ravg-(rStderr*1.96)
  rarray[*,i]=[ravg,rstdev,rStderr,uCI,lCI]
  
endfor  
;p10=plot(rarray[0,*],title='all rainfall stations')
;p11=plot(rarray[3,*], /overplot)
;p11b=plot(rarray[4,*], /overplot)

;************************************************************************************************

;month = [1,2,3,4,5,6,7,8,9,10,11,12]

;**********time series anamolies rainfall***********************

tsarray = fltarr(n_elements(yr), n_elements(month))
tsarray[*,*] = !VALUES.F_NAN
ts=fltarr(48) ;4*12 yr*months
ts[*]=!VALUES.F_NAN
cnt=0
for i=0, n_elements(yr)-1 do begin
  for j=0, n_elements(month)-1 do begin
    ;data does not start till sept 2005
    if yr[i] eq 2005 and month[j] lt 9 then begin
      cnt++
      continue
    endif 
   
    rmoindex=rain(where(rmo eq month(j) AND ryr eq yr[i], count))& print, count
    yrmoavg= mean(rmoindex,/NAN)
    if count gt 1 then yrmostdv = stdev(rmoindex)
 
    anom = yrmoavg - rarray[0,j] & print, yrmoavg, rarray[i,j], anom, yr[i], month[j]
    tsarray[i,j] = anom ;in an array
    ts[cnt] = anom ;in one macarroni
    cnt++
   endfor
endfor 

;get rid of NANs for the bar plots
good=where(finite(ts), complement=bad, count)
ts(bad)= 0

yr1=indgen(3)*0+2005
yr2=indgen(3)*0+2006
yr3=indgen(3)*0+2007
yr4=indgen(3)*0+2008
xaxis=[yr1,yr2,yr3,yr4]
b1=barplot(ts,xtickname=string(xaxis), title='rainfall anomalies Sept 2005 to Dec 2008')

;***********************soil moisture anomolies for the two different groups***************

dtsarray = fltarr(n_elements(yr), n_elements(month))
dtsarray[*,*] = !VALUES.F_NAN
dts=fltarr(48) ;4*12 yr*months
dts[*]=!VALUES.F_NAN
cnt=0
for i=0, n_elements(yr)-1 do begin
  for j=0, n_elements(month)-1 do begin
    dindex=sm(where(syr eq yr[i] AND smo eq month(j) AND slatlons[1,*] lt 2.7,count)) ;this lumps all but the wet spot
    dmoyravg = mean(dindex,/nan)
    danom = dmoyravg - arrayDry[0,j] & print, dmoyravg, arrayDry[0,j], danom, yr[i], month[j]
    dtsarray[i,j] = danom ;in an array
    dts[cnt] = danom ;in one macarroni
    cnt++
  endfor
endfor
b1d=barplot(dts, title='soil moisture anamolies Sept 2005 to Dec 2008')
print, 'wait here'










     
;make the -9999s NaNs so that I can use the total function
bad = where(prv24 lt -9998,complement=good, count)
prv24[bad]=!VALUES.F_NAN

daycum = fltarr(415)
daycum[*]=!VALUES.F_NAN
hrcnt = 0
dycnt = 0

dyr = fltarr(1186) ;8months*4yrs*120*2 measures perday
dmo = fltarr(1186)
ddy = fltarr(1186)
dlat = fltarr(1186)
dlon = fltarr(1186)
newdy = fltarr(1186)
outdat = fltarr(6,1186)

;******agregate to daily values***********************************
for a = 0,n_elements(prv24)-1 do begin
  ;a=0
  daycum[hrcnt] = prv24[a] ;the values for a day have to go into a vector so that I can use the total function
  hrcnt++ ;advance the hour counter within the day
 ;this takes care of the final value that can't handle a+1

 if a eq n_elements(prv24)-1 then newdy[dycnt] = total(daycum[*],/NAN) else $ ;this take care of last day
 if dy[a] ne dy[a+1] AND total(finite(daycum)) eq 0 then begin
  newdy[dycnt]=!VALUES.F_NAN 
  print, 'nan!'
  
  dyr[dycnt]= yr[a]
  dmo[dycnt]= mo[a]
  ddy[dycnt]= dy[a]
  dlat[dycnt]= lat[a]
  dlon[dycnt]= lon[a]
  
   daycum[*] = !VALUES.F_NAN
   hrcnt = 0 
   dycnt++ 
 endif else if dy[a] ne dy[a+1] then begin
    newdy[dycnt] = total(daycum[*],/NAN) ;sums up everything but the nans
    dyr[dycnt]= yr[a]
    dmo[dycnt]= mo[a]
    ddy[dycnt]= dy[a]
    dlat[dycnt]= lat[a]
    dlon[dycnt]= lon[a]
    
    daycum[*] = !VALUES.F_NAN
    hrcnt = 0 
    dycnt++ 
 endif

    if dycnt eq n_elements(newdy) then break
endfor;a  
print, 'hold here'
outdat[*,*]=[transpose(dyr),transpose(dmo),transpose(ddy),transpose(dlat),transpose(dlon),transpose(newdy)]
;*******************************************************************************
;ofile='/home/mcnally/lischeck/ul_132stations.csv'
;write_csv,ofile,outdat
;ok,now what do I do with this rainall data? What format what the other stuff in?
;p1=plot(outdat[5,0:234])
outarr=fltarr(5,45)

;***********make this monthly so I can matlab it********************
year=[2005., 2006., 2007., 2008.]
month = [3,4,5,6,7,8,9,10,11]
p=0
for d=0,n_elements(unqlatlon[0,*])-1 do begin ;from the daily files
 for y=0,n_elements(year)-1 do begin
   for m=0,n_elements(month)-1 do begin
    cc=where(dlat eq unqlatlon[0,d] AND dlon eq unqlatlon[1,d] AND dyr eq year[y] AND dmo eq month[m],count);the lat lon is correclty advancing but the others are not :(
    if count eq 0 then continue
    motot=total(newdy(cc), /NAN) ;these will get confused between no data and no rain....
    outarr[*,p]=[dlat(cc[0]),dlon(cc[0]),year[y], month[m],motot]
    p++
    if (p eq 45) then break
  endfor;m
 endfor;y
endfor;d

ofile='/home/mcnally/lischeck/ulmonthly_132stations.csv'
write_csv,ofile,outarr
;****************************************************


print, 'pause here,pls'
  ;********find unique dates***********************
;;make a list of unqdates[125] and loop through them (or where through them....)
; a=rem_dup(datetime)
; unqdaytime=datetime(a[107:231]);the first 0-106 are the station names that are also in col1
;   uqyr = strmid(unqdaytime,0,4)
;   uqmo = strmid(unqdaytime,5,2)
;   uqdy = strmid(unqdaytime,8,2)
;
;;added this so I can look at the station lat/lons in each pixel
;station=fltarr(2,61,5) ;lat/lon, max num of stations, 5 regions
;station[*,*,*]= -9999.
;;****************define the groups of stations that belong to each pixel*****************
;for i = 0, n_elements(unqpix[0,*])-1  do begin
;  grp = where(xy[0,*] eq unqpix[0,i] AND xy[1,*] eq unqpix[1,i]) ;uh, I guess I have to do this in a loop   
;  for j=0,n_elements(grp)-1 do begin ;I know that there are only 5 groups/pixels in this case. 
;    ;j=4 ;first element in lc when i=0
;    buffer=where(lat eq unqlatlon(0,grp[j]) and lon eq unqlatlon(1,grp[j]))
;    if j eq 0 then index=buffer else index = [index, buffer];geez that took a while. 
;    station[*,j,i]= unqlatlon(*,grp[j]) ;now I can get the lat/lon of stations in a region
;  endfor;j
;print, 'did it work?'
;  for k=0,n_elements(uqyr)-1 do begin ;i = 0 = ul
;    if k eq 0 then stat = fltarr(7,n_elements(uqyr))
;    if k eq 0 then stat[*,*] = !VALUES.F_NAN
;    stat[0,k] = uqyr(k) ;fills in the yr,mo,day
;    stat[1,k] = uqmo(k)
;    stat[2,k] = uqdy(k)
;    
;    cc = where(yr(index) eq uqyr[k] AND mo(index) eq uqmo[k] AND dy(index) eq uqdy[k],count) 
;    if count eq 0 then continue
;    ;what do I do when the dates start late? this just takes the mean of the first 2.
;    
;    stat[3,k] = mean(pramnt(index(cc)),/NAN) ; if (i eq 0) then ul = index ;upper left
;    stat[4,k] = min(pramnt(index(cc)),/NAN)
;    stat[5,k] = max(pramnt(index(cc)),/NAN)
;    stat[6,k] = stddev(pramnt(index(cc)),/NAN)
;    ;mve,(pramnt(lc(cc))) ;I should save the min, max, mean, std dev and n_elements...but will have to do this with another command.
;  endfor; k
;
;  if (i eq 0) then ul = stat ;upper left 
;  if (i eq 1) then lc = stat;lower center
;  if (i eq 2) then uc = stat ;upper center
;  if (i eq 3) then lr = stat ;lower right ;these do not start until 2006-May-14 what are the numbers filling in the array?
;  if (i eq 4) then ll = stat ;lower left  ; the do not start until 2007-May-18
;  
;endfor;i
;
;;now I need to match these up with the rfe2 grids....
;;avgrain = [ ul[0:3,*], lc[3,*], uc[3,*], lr[3,*], ll[3,*]]; look at the averages for the days
;
;;*************replace the values in the rfe files *******************
; print, 'stop here please'
;cd, '/jabber/LIS/Data/ubRFE2/'
;ingrid=fltarr(751,801)
;;replace all of the grids of interest from 2005 to 2008. That mean ll (all zeros 2205&6) and lr (all zeros 2005)
;; this might be a problem....
;fname=file_search('*{2005,2006,2007,2008}*') ;ug, I think that this is a problem for lower left and lower right....
;
;for m=0, n_elements(fname)-1 do begin
;  openr,1,fname[m]
;  readu,1,ingrid
;  byteorder,ingrid, /XDRTOF
;  close,1
;  
;  ;zero out the unqpix....
;  ingrid(unqpix[0,0], unqpix[1,0]) = 0.
;  ingrid(unqpix[0,1], unqpix[1,1]) = 0.
;  ingrid(unqpix[0,2], unqpix[1,2]) = 0.
;  ingrid(unqpix[0,3], unqpix[1,3]) = 0.
;  ingrid(unqpix[0,4], unqpix[1,4]) = 0.
;  
; ofile = strcompress('/jabber/LIS/Data/AMMArfe_grid/'+fname[m], /remove_all)
; openw,1,ofile
; byteorder,ingrid,/XDRTOF
; writeu,1,ingrid
; close,1
;  
;endfor; m
;
;cd, '/jabber/LIS/Data/AMMArfe_grid/'
;
;for l=0, n_elements(uqyr)-1 do begin
;  ;l=0
;  rfile = file_search('all_products.bin.'+uqyr[l]+uqmo[l]+uqdy[l]); this is only for days when vals were recorded
;  openr,1,rfile
;  readu,1,ingrid
;  byteorder,ingrid,/XDRTOF
;  close, 1
;  
;  ;as long as the value is a number then replace it...starting 20050827
;  if finite(ul(3,l)) eq 1 then ingrid(unqpix[0,0], unqpix[1,0]) = ul(3,l) ; the first entry of the dates there are 125 of these...make sure these are in correct order
;  if finite(lc(3,l)) eq 1 then ingrid(unqpix[0,1], unqpix[1,1]) = lc(3,l)
;  if finite(uc(3,l)) eq 1 then ingrid(unqpix[0,2], unqpix[1,2]) = uc(3,l)
;  if finite(lr(3,l)) eq 1 then ingrid(unqpix[0,3], unqpix[1,3]) = lr(3,l);these start later.
;  if finite(ll(3,l)) eq 1 then ingrid(unqpix[0,4], unqpix[1,4]) = ll(3,l);these start later. 
; 
; ofile = strcompress('/jabber/LIS/Data/AMMArfe_grid/'+rfile, /remove_all)
; openw,1,ofile
; byteorder,ingrid,/XDRTOF
; writeu,1,ingrid
; close,1
;endfor ;l
; 
;print, 'hello'  
;**************find stations in the box i need***************
;uldays=fltarr(100)
;ulindex=where(unqlatlon[0,*] gt 13.55 AND unqlatlon[1,*] lt 2.65 AND unqlatlon[1,*] gt 2.55, count)
;for a=0,n_elements(ulindex)-1 do uldays(a)=where(lat210 eq unqlatlon[0,ulindex(a)] AND lon210 eq unqlatlon[1,ulindex(a)])

;;************file for joel to make chg_ids for the postgres database*************
;unqlat = unqlatlon[0,*]
;unqlon = unqlatlon[1,*]
;;write_csv,'/home/mcnally/latlon4joel.csv', unqlat[*], unqlon[*] 
;
;;********change lon-lat to xy*********************
; xy=intarr(2,n_elements(unqlon))
;  
; xy[0,*] = reform((unqlon+19.95)*10); becasue it is -29.95W and (2.5*20 = 50pixels) that is .05 off of 20 which should be the center of the pixel.
; xy[1,*]= reform((unqlat+39.95)*10) ;becasue it is -39.95S
;
;;********find uniqe pixels************************
; col1ord = ord(xy[0,*])
; col2ord = ord(xy[1,*])
; index = col1ord + (max(col1ord)+1)*col2ord ;this turns the 2 cols into a single unique index
;; Step 2: Use histogram to find which ones have the same unique index 
;  h = histogram(index, reverse_indices=ri) ;list of subscripts that contribute to each bin
;; Step 3: Get the first one in each bin, and put back in sorted order 
;  keep = ri[ri[where(h gt 0)]] 
;  keep = keep[sort(keep)] 
;  unqpix = xy[*,keep]

 end
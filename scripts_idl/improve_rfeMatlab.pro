pro improve_rfeMatlab

;the purpose of this script is to replace the five pixels that cover the  niger study site with 
;the station data avaialable from AMMA. I guess that I should modify all rfe2 day, not just the 
;ones where data was recorded assuming that rainfall was only recorded when present....this might take some thought. 

;which lat lon go into which pixel? unqlatlon is from AMMArain.pro
;*************get lat and lon*****************************
indir= '/jabber/Data/mcnally/AMMARain/'
cd, indir

ff= file_search('143-CL.Rain_Nc.csv')
fname= indir+ff
valid= query_ascii(fname,info) ;checks compatability with read_ascii

myTemplate = ASCII_TEMPLATE(fname); go to line 100.
rain143 = read_ascii(fname, delimiter=';' ,template=myTemplate)

pramnt  = rain143.FIELD11 
datetime  = rain143.FIELD01 ; date i need to fill in this vector
  yr = strmid(datetime,0,4)
  mo = strmid(datetime,5,2)
  dy = strmid(datetime,8,2)

lat = rain143.FIELD02 ; latitude 
lon = rain143.FIELD03 ; longitude
latlons=[ reform(lat,1,n_elements(lat)), reform(lon,1,n_elements(lon)) ]

print, 'stop for real'
;***************dealing with duplicate latlons************************
;; Step 1: Map your columns 2 and 3 into a single unique index
  col1ord = ord(latlons[0,*])
  col2ord = ord(latlons[1,*])
  index = col1ord + (max(col1ord)+1)*col2ord ;this turns the 2 cols into a single unique index
; Step 2: Use histogram to find which ones have the same unique index 
  h = histogram(index, reverse_indices=ri) ;list of subscripts that contribute to each bin
; Step 3: Get the first one in each bin, and put back in sorted order 
  keep = ri[ri[where(h gt 0)]] 
  keep = keep[sort(keep)] 
; Step 4: Print/write them out without the nans
  unqlatlon = latlons[*,keep] 
  unqlatlon = reform(unqlatlon(where(finite(unqlatlon))),2,108) ;the 108 will have to change when reading other files

;************file for joel to make chg_ids for the postgres database*************
unqlat = unqlatlon[0,*]
unqlon = unqlatlon[1,*]
;write_csv,'/home/mcnally/latlon4joel.csv', unqlat[*], unqlon[*] 

;********change lon-lat to xy*********************
 xy=intarr(2,n_elements(unqlon))
  
 xy[0,*] = reform((unqlon+19.95)*10); becasue it is -29.95W and (2.5*20 = 50pixels) that is .05 off of 20 which should be the center of the pixel.
 xy[1,*]= reform((unqlat+39.95)*10) ;becasue it is -39.95S

;********find uniqe pixels************************
 col1ord = ord(xy[0,*])
 col2ord = ord(xy[1,*])
 index = col1ord + (max(col1ord)+1)*col2ord ;this turns the 2 cols into a single unique index
; Step 2: Use histogram to find which ones have the same unique index 
  h = histogram(index, reverse_indices=ri) ;list of subscripts that contribute to each bin
; Step 3: Get the first one in each bin, and put back in sorted order 
  keep = ri[ri[where(h gt 0)]] 
  keep = keep[sort(keep)] 
  unqpix = xy[*,keep]
  
;********find unique dates***********************
;make a list of unqdates[125] and loop through them (or where through them....)
 a=rem_dup(datetime)
 unqdaytime=datetime(a[107:231]);the first 0-106 are the station names that are also in col1
   uqyr = strmid(unqdaytime,0,4)
   uqmo = strmid(unqdaytime,5,2)
   uqdy = strmid(unqdaytime,8,2)

;added this so I can look at the station lat/lons in each pixel
station=fltarr(2,61,5) ;lat/lon, max num of stations, 5 regions
station[*,*,*]= -9999.

print, 'stop here too'
;****************define the groups of stations that belong to each pixel*****************
for i = 0, n_elements(unqpix[0,*])-1  do begin
  grp = where(xy[0,*] eq unqpix[0,i] AND xy[1,*] eq unqpix[1,i]) ;this groups the lat/lons (converted to pixel) into a 'region'  
  for j = 0,n_elements(grp)-1 do begin ;for each region 
    buffer = where(lat eq unqlatlon(0,grp[j]) and lon eq unqlatlon(1,grp[j])) ; buffer is the index each time through the loop
    if j eq 0 then index=buffer else index = [index, buffer];then the array index stores all of the relevant indices for the group.
    station[*,j,i]= unqlatlon(*,grp[j]) ;now I can get the lat/lon of stations in a region
  endfor;j
  
  ;what does this loop do? Outputs yr,mo,day,mean,min,max,stdev
  for k=0,n_elements(uqyr)-1 do begin ;i = 0 = ul
    if k eq 0 then stat = fltarr(7,n_elements(uqyr))
    if k eq 0 then stat[*,*] = !VALUES.F_NAN
    stat[0,k] = uqyr(k) ;fills in the yr,mo,day
    stat[1,k] = uqmo(k)
    stat[2,k] = uqdy(k)
    
    cc = where(yr(index) eq uqyr[k] AND mo(index) eq uqmo[k] AND dy(index) eq uqdy[k],count) ;finds all the stations that apply
    if count eq 0 then continue
    ;what do I do when the dates start late? this just takes the mean of the first 2.
    
    stat[3,k] = mean(pramnt(index(cc)),/NAN) ; if (i eq 0) then ul = index ;upper left
    stat[4,k] = min(pramnt(index(cc)),/NAN)
    stat[5,k] = max(pramnt(index(cc)),/NAN)
    stat[6,k] = stddev(pramnt(index(cc)),/NAN)
    ;mve,(pramnt(lc(cc))) ;I should save the min, max, mean, std dev and n_elements...but will have to do this with another command.
  endfor; k

  if (i eq 0) then ul = stat ;upper left 
  if (i eq 1) then lc = stat;lower center
  if (i eq 2) then uc = stat ;upper center
  if (i eq 3) then lr = stat ;lower right ;these do not start until 2006-May-14 what are the numbers filling in the array?
  if (i eq 4) then ll = stat ;lower left  ; the do not start until 2007-May-18
  
endfor;i

;now I need to get the monthly averages for each station. Maybe not worry about what quadrant they fall into
;since the ll and lr won't have the full time series anyway.
outarr=fltarr(5,20,n_elements(unqlatlon[0,*]))
outarr[*,*,*]=-9999.

year=[2005., 2006., 2007., 2008.]
month = [5,6,7,8,9,10]
p=0
for l=0,n_elements(unqlatlon[0,*])-1 do begin
  ;l=2;tester
  c=where(lat eq unqlatlon[0,l] AND lon eq unqlatlon[1,l]) ;for each lat/lon position
 for m=0,n_elements(year)-1 do begin
  ;m=0
  for n=0,n_elements(month)-1 do begin
  ;n=4
    cc=where(yr(c) eq year[m] AND mo(c) eq month[n],count);the lat lon is correclty advancing but the others are not :(
    if count eq 0 then continue
    motot=total(pramnt(c(cc)))
    outarr[*,p,l]=[lat(c[0]),lon(c[0]),year[m], month[n],motot]
    p++
  endfor;n
 endfor;m
 p=0
endfor;l

  lat143=outarr[0,*,*]
  lon143=outarr[1,*,*]
  yrs143=outarr[2,*,*]
  mos143=outarr[3,*,*]
  totmo143 = outarr[4,*,*]
  ofile=strcompress('/home/mcnally/lischeck/rain143_matlab.csv')
  write_csv,ofile,lat143,lon143,yrs143,mos143,totmo143
; print, [reform(yr(cc),1,n_elements(cc)),reform(mo(cc),1,n_elements(cc)),reform(dy(cc),1,n_elements(cc)),reform(pramnt(cc),1,n_elements(cc))]
; print, total(pramnt(cc))
 ;how did I do this for the soil moisture?
;sm=outarr(4,*,0)
;p1=plot(sm(where sm gt 0)))
 print, 'hold here'
;
 end
pro AMMArainv133

;10/5/11: the purpose of this script is to read in the data from file 133 and see if there are any useful 
;stations in the upper left corner 13.5 to 13.6, 2.65 to 2.75 that I can use to compare to my soil moisture observations. 
;I subset these lines from 132-CE.Rain_Nc.csv into 132-CE.Rain_upleft.csv becasue the original
;was such a big file (taking a long time to load/read)
;There are two additional stations that I can include:
;13.6496;2.64920
;13.6455;2.62110
;but they appear to be in precip amount for the previous hour...is that useful? 
;some modifications were made to the original script on 2/5/212

;
;1-date
;2-latitude
;3-longitude
;4-altitude
;5-hauteur sol
;6-Droplet Number(no unit)
;7-Droplet Size(mm)
;8-Drop Size Distribution(m-4)
;9-Fall velocity(m/s)
;10-Liquid Water Content(g.m-3)
;11-Precipitation Amount(mm)
;12-Precipitation Amount (previous 12 hours)(mm)
;13-Precipitation Amount (previous 24 hours)(mm)
;14-Precipitation Amount (previous 30 minutes)(mm)
;15-Precipitation Amount (previous 3 hours)(mm)
;16-Precipitation Amount (previous 5 minutes)(mm)
;17-Precipitation Amount (previous 6 hours)(mm)
;18-Precipitation Amount (previous hour)(mm)
;19-Precipitation Amount (previous second)(mm)
;20-Precipitation Amount (since January 1)(mm)
;21-Precipitation Rate(mm/h)
;22-Precipitation Rate HASSE(mm/h)
;23-Precipitation Rate ORG(mm/h)
;
indir= '/jabber/Data/mcnally/AMMARain/'
cd, indir

ff= file_search('132-CE.Rain_upleft.csv')

myTemplate = ASCII_TEMPLATE(fname); go to line 100.
rain132 = read_ascii(ff, delimiter=';' ,template=myTemplate)

;first create a new table that gets rid of bad lines, and add site IDs for the west and east raingauge
datetime  = rain132.FIELD01 ; date i need to fill in this vector
datetime = [transpose(datetime), transpose(datetime)] ;this makes an array that I can add a site ID to.

yr = fix(strmid(datetime,0,4))
mo = fix(strmid(datetime,5,2))
dy = fix(strmid(datetime,8,2))
hr = strmid(datetime[0:10],11,10) ; how did I deal with this before?

doy = YMD2DN(yr, mo,dy)

lat = rain132.FIELD02 
lon = rain132.FIELD03
;latlons=[reform(lat,1,n_elements(lat)), reform(lon,1,n_elements(lon))]
rain  = rain132.FIELD18 ;uh, this is precip in the previous hour. What is theo's data?

siteID=fltarr(n_elements(yr))
table=[transpose(yr), transpose(doy), transpose(lon), transpose(lat), transpose(siteID), transpose(rain)]

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
  unqlatlon = reform(unqlatlon(where(finite(unqlatlon))),2,2) ;the 108 will have to change when reading other files

prv24 = rain132.FIELD13 ; 1171 values are not -9999

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
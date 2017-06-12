pro improve_rfe

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
;****************define the groups of stations that belong to each pixel*****************
for i = 0, n_elements(unqpix[0,*])-1  do begin
  grp = where(xy[0,*] eq unqpix[0,i] AND xy[1,*] eq unqpix[1,i]) ;uh, I guess I have to do this in a loop   
  for j=0,n_elements(grp)-1 do begin ;I know that there are only 5 groups/pixels in this case. 
    ;j=4 ;first element in lc when i=0
    buffer=where(lat eq unqlatlon(0,grp[j]) and lon eq unqlatlon(1,grp[j]))
    if j eq 0 then index=buffer else index = [index, buffer];geez that took a while. 
    station[*,j,i]= unqlatlon(*,grp[j]) ;now I can get the lat/lon of stations in a region
  endfor;j
print, 'did it work?'
  for k=0,n_elements(uqyr)-1 do begin ;i = 0 = ul
    if k eq 0 then stat = fltarr(7,n_elements(uqyr))
    if k eq 0 then stat[*,*] = !VALUES.F_NAN
    stat[0,k] = uqyr(k) ;fills in the yr,mo,day
    stat[1,k] = uqmo(k)
    stat[2,k] = uqdy(k)
    
    cc = where(yr(index) eq uqyr[k] AND mo(index) eq uqmo[k] AND dy(index) eq uqdy[k],count) 
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

;now I need to match these up with the rfe2 grids....
;avgrain = [ ul[0:3,*], lc[3,*], uc[3,*], lr[3,*], ll[3,*]]; look at the averages for the days

;*************replace the values in the rfe files *******************
 print, 'stop here please'
cd, '/jabber/LIS/Data/ubRFE2/'
ingrid=fltarr(751,801)
;replace all of the grids of interest from 2005 to 2008. That mean ll (all zeros 2205&6) and lr (all zeros 2005)
; this might be a problem....
fname=file_search('*{2005,2006,2007,2008}*') ;ug, I think that this is a problem for lower left and lower right....

for m=0, n_elements(fname)-1 do begin
  openr,1,fname[m]
  readu,1,ingrid
  byteorder,ingrid, /XDRTOF
  close,1
  
  ;zero out the unqpix....
  ingrid(unqpix[0,0], unqpix[1,0]) = 0.
  ingrid(unqpix[0,1], unqpix[1,1]) = 0.
  ingrid(unqpix[0,2], unqpix[1,2]) = 0.
  ingrid(unqpix[0,3], unqpix[1,3]) = 0.
  ingrid(unqpix[0,4], unqpix[1,4]) = 0.
  
 ofile = strcompress('/jabber/LIS/Data/AMMArfe_grid/'+fname[m], /remove_all)
 openw,1,ofile
 byteorder,ingrid,/XDRTOF
 writeu,1,ingrid
 close,1
  
endfor; m

cd, '/jabber/LIS/Data/AMMArfe_grid/'

for l=0, n_elements(uqyr)-1 do begin
  ;l=0
  rfile = file_search('all_products.bin.'+uqyr[l]+uqmo[l]+uqdy[l]); this is only for days when vals were recorded
  openr,1,rfile
  readu,1,ingrid
  byteorder,ingrid,/XDRTOF
  close, 1
  
  ;as long as the value is a number then replace it...starting 20050827
  if finite(ul(3,l)) eq 1 then ingrid(unqpix[0,0], unqpix[1,0]) = ul(3,l) ; the first entry of the dates there are 125 of these...make sure these are in correct order
  if finite(lc(3,l)) eq 1 then ingrid(unqpix[0,1], unqpix[1,1]) = lc(3,l)
  if finite(uc(3,l)) eq 1 then ingrid(unqpix[0,2], unqpix[1,2]) = uc(3,l)
  if finite(lr(3,l)) eq 1 then ingrid(unqpix[0,3], unqpix[1,3]) = lr(3,l);these start later.
  if finite(ll(3,l)) eq 1 then ingrid(unqpix[0,4], unqpix[1,4]) = ll(3,l);these start later. 
 
 ofile = strcompress('/jabber/LIS/Data/AMMArfe_grid/'+rfile, /remove_all)
 openw,1,ofile
 byteorder,ingrid,/XDRTOF
 writeu,1,ingrid
 close,1
endfor ;l
 
print, 'hello'  
 end
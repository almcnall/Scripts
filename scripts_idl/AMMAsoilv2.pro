pro AMMAsoilv2
;this will read the files in the 201107210633233198/ that contain all of the soil moisture/CS615 data it will save the data
;if the location is within the RFE2 box: 13.65N to 13.45N, 2.55E to 2.85E


indir= '/jabber/Data/mcnally/AMMASOIL/'
cd, indir

;fname1 = file_search('89-CE.SW_Odc.csv');in Benin.
fname2 = file_search('107*Ncb.csv') ;this one is just one station but is inside the rfe2 pixels start here.
fname3 = file_search('110*.csv');both sites outside the rfe2 rainfall box by 8km to the north and south :( 
fname4 = file_search('108*Nc.csv') ;this one is just one station but is inside the rfe2 pixels start here.
fname5 = file_search('210*Nc.csv') ;this one is just one station but is inside the rfe2 pixels start here.

valid = query_ascii(fname3,info) ;checks compatability with read_ascii
print, valid
myTemplate = ASCII_TEMPLATE(fname3); this allows me to recognize field001 is a date/time string.
buffer3 = read_ascii(fname3, delimiter=';' ,template=myTemplate);

valid = query_ascii(fname4,info) ;checks compatability with read_ascii
print, valid
myTemplate = ASCII_TEMPLATE(fname4); this allows me to recognize field001 is a date/time string.
buffer4 = read_ascii(fname4, delimiter=';' ,template=myTemplate);

valid = query_ascii(fname5,info) ;checks compatability with read_ascii
print, valid
myTemplate = ASCII_TEMPLATE(fname5); this allows me to recognize field001 is a date/time string.
buffer5 = read_ascii(fname5, delimiter=';' ,template=myTemplate)

flag=-9999.9

datetime = buffer2.FIELD001[*];
lat = buffer2.FIELD002[*] ; 4 stations - sofia, toni and wankama (x2)
lon = buffer2.FIELD003[*]

datetime = buffer3.FIELD001[*];
lat = buffer3.FIELD002[*] ; 4 stations - sofia, toni and wankama (x2)
lon = buffer3.FIELD003[*]

datetime = buffer4.FIELD01[*];
lat = buffer4.FIELD02[*] ; 4 stations - sofia, toni and wankama (x2)
lon = buffer4.FIELD03[*]

datetime = buffer5.FIELD01[*];
lat = buffer5.FIELD02[*] ; 4 stations - sofia, toni and wankama (x2)
lon = buffer5.FIELD03[*]

;***************dealing with duplicate latlons************************
;; Step 1: Map your columns 2 and 3 into a single unique index
lat = reform(lat, 1, n_elements(lat))
lon = reform(lon, 1, n_elements(lon))
latlons = [lat, lon]

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
  unqlatlon = reform(unqlatlon(where(finite(unqlatlon))),2,50) ;the 50 will have to change when reading other files
;***********************************************************************

;datetime = buffer108.FIELD01[*];
;lat = buffer108.FIELD02[*] ; 4 stations - sofia, toni and wankama (x2)
;lon = buffer108.FIELD03[*] 

;datetime = buffer108.FIELD01[*];
;lat = buffer108.FIELD02[*] ; 4 stations - sofia, toni and wankama (x2)
;lon = buffer108.FIELD03[*] ;
;
;datetime = buffer110.FIELD001[*];?
;lat = buffer110.FIELD002[*] ; 13.440, 13.6476
;lon = buffer110.FIELD003[*] ; 2.62990, 2.63370

;datetime = buffer107.FIELD001[*];how many measurements per day?
;lat = buffer107.FIELD002[*] ;13.5311 there is only one site in this file... 
;lon = buffer107.FIELD003[*] ; 2.66130 

;datetime = buffer89.FIELD001[*];how many measurements per day?
;lat = buffer89.FIELD002[*] ;13.5311 - there are 17 different lats in #89
;lon = buffer89.FIELD003[*] ; 2.66130 - and 17 different lons (really? is that true?)in #89
;
;SM00Xcm = buffer107.FIELD008[*];
;SM010cm = buffer107.FIELD020[*]; 
;SM120cm = buffer107.FIELD032[*] 
;SM150cm = buffer107.FIELD044[*];
;SM100cm = buffer107.FIELD056[*];
;SM020cm = buffer107.FIELD068[*];
;SM025cm = buffer107.FIELD080[*]
;SM250cm = buffer107.FIELD092[*];
;SM200cm = buffer107.FIELD104[*];
;SM040cm = buffer107.FIELD116[*]
;SM050cm = buffer107.FIELD128[*];
;SM005cm = buffer107.FIELD140[*];
;SM0X5cm = buffer107.FIELD152[*];
;SM060cm = buffer107.FIELD164[*]; 
;SM080cm = buffer107.FIELD176[*];

SM00Xcm = buffer107.FIELD008[*];
SM010cm = buffer107.FIELD020[*]; 
SM120cm = buffer107.FIELD032[*] 
SM150cm = buffer107.FIELD044[*];
SM100cm = buffer107.FIELD056[*];
SM020cm = buffer107.FIELD068[*];
SM025cm = buffer107.FIELD080[*]
SM250cm = buffer107.FIELD092[*];
SM200cm = buffer107.FIELD104[*];
SM040cm = buffer107.FIELD116[*]
SM050cm = buffer107.FIELD128[*];
SM005cm = buffer107.FIELD140[*];
SM0X5cm = buffer107.FIELD152[*];
SM060cm = buffer107.FIELD164[*]; 
SM080cm = buffer107.FIELD176[*];


;SM00Xcm = buffer107.FIELD008[*];none for 89
;SM010cm = buffer89.FIELD020[*]; good for 110, 89
;SM120cm = buffer89.FIELD032[*] ; one strange nan value, good for 89
;SM150cm = buffer89.FIELD044[*];good for 110
;SM100cm = buffer89.FIELD056[*];good for 110
;SM020cm = buffer89.FIELD068[*];one strange nan value
;SM025cm = buffer89.FIELD080[*]
;SM250cm = buffer89.FIELD092[*];good for 100
;SM200cm = buffer89.FIELD104[*];good for 110
;SM040cm = buffer89.FIELD116[*]
;SM050cm = buffer89.FIELD128[*];good for 110
;SM005cm = buffer89.FIELD140[*];good for 107, not 110
;SM0X5cm = buffer89.FIELD152[*];double check for 107 b/c I did n't have them labled right, no vals for 110
;SM060cm = buffer89.FIELD164[*]; 
;SM080cm = buffer89.FIELD176[*];


;***********************************
;after reading in all of the data from 107, 108 and 210 then I should sort it for the lat-lons that fall within
; domain specified in the lis runs....225/535-227/534



;test plot
day1 = reform(datetime[0:39],1,40);2006-06-20 2pm-midnight
p11 = plot(SM250cm[0:39])

;starting 6/20-6/30, looks like rain on 6/27/2006 (for how long? what is the relationship between rain and SM at these depths?)
;it looks like it infiltrates fast and difference between moisture at shallow and deep layers becomes less. 
p01=plot(SM250cm[0:1000],XTICKNAME=strmid(datetime[0:1000:96],5,5))
p02=plot(SM05cm[0:1000],/overplot, color='blue')


;p9.name = '2004-05' ;3
;p10.name = '2005-06' ;4
;p11.name = '2006-07' ;5
;
;!null = legend(target=[p9,p10,p11], position=[0.2,0.55]) 


;declare variables and size of array
i = long(1) &  pos = long(1) & buffer = string(1) & dates = strarr(line)  &  lats = fltarr(line) 
lons = fltarr(line)  &  elevs = fltarr(line)   & sunhrs=fltarr(line)

;soil moisture 2at different depths (cm)
smCS615s = fltarr(line) & smCS616s = fltarr(line)
sm010s = fltarr(line) & sm120s = fltarr(line) & sm150s = fltarr(line) 
sm100s = fltarr(line) & sm020s = fltarr(line) & sm025s = fltarr(line) 
sm250s = fltarr(line) & sm200s = fltarr(line) & sm040s = fltarr(line)
sm050s = fltarr(line) & sm05as = fltarr(line) & sm05bs = fltarr(line)
sm060s = fltarr(line) & sm080s = fltarr(line)

;Create varaibles to hold date, and other vars
buffer=' ' &  date=' '  &  i=0  &  lat=0.  &  lon =0.  &  elev =0.  &  sunhr=0. 
smCS615 = 0. & smCS616 = 0.
sm010 = 0. & sm120 = 0. & sm150 = 0. 
sm100 = 0. & sm020 = 0. & sm025 = 0. 
sm250 = 0. & sm200 = 0. & sm040 = 0.
sm050 = 0. & sm05a = 0. & sm05b = 0.
sm060 = 0. & sm080 = 0.


;Open data file for input
openr,1,ff 

;initalize counter
;using the while loop instead of the do loop with # of lines
;for i=0,line[0]-1 do begin 
 
 ;current, read, test, exit or set position, read with format
  POINT_LUN, -1, pos ;get current position
 
  readf,1,buffer 
  if strcmp(buffer,'#',1) OR strcmp(buffer,'',10) then continue ;if the line is the #station name don't read (string compare) ;

  point_lun,1,pos & ;if the line is not the station name the read with formating
  readf,1,buffer 
  parse=strsplit(buffer,';', /extract)

  date  = parse(0) 
  month = fix(strmid(date,5,2))     & day=fix(strmid(date,8,2))  & year=fix(strmid(date,0,4)) 
  hr    = fix(strmid(date,11,2))    & mn=fix(strmid(date,14,2))  & sec = fix(strmid(date,17,4))
  julian = julday(month,day,year,hr,mn,sec)
   
  lat  = parse(1)
  lon  = parse(2)
  elev = parse(3)
  sunhr   = parse(4)
  smCS615 = parse(5)
  smCS616 = parse(6)
  sm010 = parse(7) 
  sm120 = parse(8)
  sm150 = parse(9) 
  sm100 = parse(10)
  sm020 = parse(11)
  sm025 = parse(12)
  sm250 = parse(13)
  sm200 = parse(14)
  sm040 = parse(15) 
  sm050 = parse(16)
  sm05a = parse(17)
  sm05b = parse(18)
  sm060 = parse(19)
  sm080 = parse(20)
  i++ ;advance i when there is actually data to read :)
 
  dates(i) = julian   &   lats(i)= lat  &   lons(i) = lon   &   elevs(i) = elev  &  sunhrs(i)=sunhr  

  ;smCS615s(i) = smCS615 & smCS616s(i) = smCS616 ;these appear to have no data
  sm010s(i) = sm010 & sm120s(i) = sm120 & sm150s(i) = sm150 
  sm100s(i) = sm100 & sm020s(i) = sm020 & sm025s(i) = sm025  
  sm250s(i) = sm250 & sm200s(i) = sm200 & sm040s(i) = sm040
  sm050s(i) = sm050 & sm05as(i) = sm05a & sm05bs(i) = sm05b
  sm060s(i) = sm060 & sm080s(i) = sm080

endwhile ;k
close,1
plot,dates(0:i),sm010s(0:i) ;there are blank lines at the end...

end
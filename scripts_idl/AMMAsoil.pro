pro AMMAsoil
;this script reads amma data from csv files from the amma database, this file may have been doing some unecessary string parsing
;now I see that there is a v2 -- go to version 2.
;
;AM 6/9/11
;variables in this file (from the header...)
;date;latitude;longitude;altitude;hauteur sol;Soil Moisture/CS615 Period;Soil Moisture/CS616 Period;
;Soil Moisture @ 10 cm; Soil Moisture @ 1.2 m;Soil Moisture @ 1.5 m;
;Soil Moisture @ 1 m;   Soil Moisture @ 20 cm;Soil Moisture @ 25 cm; Soil Moisture @ 2.5 m;Soil Moisture @ 2 m;
;Soil Moisture @ 40 cm; Soil Moisture @ 50 cm;Soil Moisture @ 5 cm;  Soil Moisture @ 5 cm (2);
;Soil Moisture @ 60 cm; Soil Moisture @ 80 cm;

indir= '/jabber/Data/mcnally/amma/'
cd, indir

ff= file_search('*66.csv')
valid= query_ascii(ff,info) ;checks compatability with read_ascii uh, what file was this?
print, valid

line = info.lines ;how many lines are in the file...these do not all contain data...65536 seem to be text/blank

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
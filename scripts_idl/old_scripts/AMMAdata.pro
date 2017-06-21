pro AMMAdata 
;this script reads amma data from csv files that have the header removed
;AM 6/9/11

indir= 'C:\Users\mcnally\Documents\Dissertation\AMMA_data\143-CL.Rain_Nc.csv\'
cd, indir

ff= file_search('*noheader*')
fname= indir+ff
valid= query_ascii(fname,info) ;checks compatability with read_ascii
print, valid

line = info.lines ;how many lines are in the file...but there are lines with station names (89)

;declare variables and size of array
i=long(1) &  pos=long(1) & buffer=string(1) & dates=strarr(line)   &   lats=fltarr(line)   &   lons = fltarr(line)
elevs = fltarr(line)   &   sunhrs=fltarr(line)   &   rains=fltarr(line)  
  
;Open data file for input
openr,1,ff 

;Create varaibles to hold date, and other vars
buffer=' ' &  date=' ' &  i=0  &  lat=0.  &  lon =0.  &  elev =0.  &  sunhr=0.  &  rain=0.

;WHILE (~EOF(1)) DO BEGIN  ;using the while loop instead of the do loop with # of lines
for i=0,line[0]-1 do begin
 
 ;current, read, test, exit or set position, read with format
 POINT_LUN, -1, pos ;get current position
 
 readf,1,buffer
 print, buffer
 if strcmp(buffer, '#',1) then continue ;if the line is the #station name don't read (string compare)

 point_lun,1,pos & ;if the line is not the station name the read with formating
 readf,1, $
 FORMAT= '(A21,1X,F8.4,F8.4,F9.1,F9.1,F3.1)', date, lat, lon, elev, sunhr, rain &
 i++ 
 
 dates(i) = date   &   lats(i)= lat  &   lons(i) = lon   &   elevs(i) = elev   ;
 &  sunhrs(i)=sunhr  &   rains(i)=rain
endfor
;endwhile ;k
close,1

end
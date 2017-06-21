pro read_RainTheov2

;the purpose of this program is to read the gridded station data that Theo sent. I used the ncdump output to help
; know what I was trying to read in. Initially i was making this much more complicated than necessary. this time (4/3/13) 
;I just read in the data, agregated to daily (every 8 values) and wrote out a new file. 

indir = strcompress('/jabber/chg-mcnally/AMMARain/',/remove_all)
cd, indir

fname = file_search('rainfield*.nc')
;for i = 0,n_elements(fname)-1 do begin &$
  i = 0
  fileID = ncdf_open(fname[i], /nowrite) &$
  varname = ncdf_vardir(fileID) & print, varname
  rainID = ncdf_varid(fileID,'rainfall') &$
  timeID = ncdf_varid(fileID,'time') &$
  lonID = ncdf_varid(fileID,'longitude')
  latID = ncdf_varid(fileID,'latitude')

  ncdf_varget,fileID,timeID,timedata
  ncdf_varget,fileID,lonID,londata
  ncdf_varget,fileID,latID,latdata
  ncdf_varget,fileID,rainID,raindata
  
 ;**********Agregate these data to daily****************
d = 0
cnt = 0
day = fltarr(n_elements(raindata[*,0,0]), n_elements(raindata[0,*,0]), 365)
tot = 0

for x = 0, n_elements(raindata[*,0,0])-1 do begin &$
  for y = 0, n_elements(raindata[0,*,0])-1 do begin &$
    for z = 0, n_elements(raindata[0,0,*])-1 do begin &$
      tot = tot + raindata[x,y,z] &$
      cnt++  &$
      if cnt eq 8 then day[x,y,d] = tot &$
      if cnt eq 8 then d++  &$
      if cnt eq 8 then tot = 0 &$
      if cnt eq 8 then cnt = 0 &$  
    endfor  &$;z
    d = 0 &$
    cnt = 0 &$
    tot = 0 &$
  endfor  &$;y
endfor;x

ofile = strcompress('/jabber/chg-mcnally/AMMARain/Theo_rain_2005_daily.img')
openw,1,ofile
writeu,1,day
close,1

;*****************************************************      
 ;nx = 6
;ny = 4
;raindata=lonarr(nx,ny,2921*4+8)
;timedata=fltarr(2921*4+8)
;;use this vector to tell raindata how to fill in the array.
;is=[0,2921,5842,8763];position of start index
;ie=[2920,5841,8762,11691];position of end index 
  
  
  

  nrain=n_elements(rain[0,0,*]) &$
  ;print, nrain
  raindata[*,*,is[i]:ie[i]] = rain &$
  timedata[is[i]:ie[i]] = time &$
endfor;i

print, 'did it work?'
  ;convert the epoch time to a datetime I can read 
  timeUTC=intarr(6,11688)
  temp=intarr(6,n_elements(timedata))
  rain2=lonarr(nx,ny,11688)
  
  count=0 ;need a counter since there are duplicates
  for j=0, n_elements(timedata)-1 do begin &$
    buffer=systime(0,timedata[j], /utc)
    temp[*,j]=bin_date(buffer)
    if j eq 0 then begin
      timeUTC[*,count]=temp[*,j]
      rain2[*,*,count]=raindata[*,*,j]
    endif
    if j gt 0 and temp[3,j] ne temp[3,j-1] then begin
      timeUTC[*,count]=temp[*,j]
      rain2[*,*,count]=raindata[*,*,j]
      count++
      if count ge n_elements(timeUTC[0,*]) then continue
      ;LIS name convention  3B42V6.2009123121
      yyyy=STRING(timeUTC[0,count])
      mm=STRING(FORMAT='(I2.2)',timeUTC[1,count])
      dd=STRING(FORMAT='(I2.2)',timeUTC[2,count])
      hh=STRING(FORMAT='(I2.2)',timeUTC[3,count])
      ofile=strcompress('/jower/LIS/data/theo_rain/theo.'+yyyy+mm+dd+'.img', /remove_all)
      
    endif
  endfor;j

scalefactor=0.01
rain2=rain2*scalefactor

;get rid of the digits past hour...
timeUTC=timeUTC[0:3,*]

cumrain=fltarr(nx,ny)
daytot=fltarr(nx,ny,(365*4)+1)

;ok, now i have to aggregate the hourly to daily
months=[1,2,3,4,5,6,7,8,9,10,11,12]
count=0
for i=1,n_elements(raindata[0,0,*])-2 do begin &$
   if timeUTC[2,i] eq timeUTC[2,i+1] then begin &$
    cumrain[*,*]=raindata[*,*,i]+cumrain &$
   endif else if timeUTC[2,i] ne timeUTC[2,i+1] then begin &$
    daytot[*,*,count]=cumrain &$
    count++ ;advance the day
    cumrain[*,*]= 0 ;clear the array
   endif &$
endfor 
    
  scalefactor=0.01
  raindata=daytot*scalefactor
;ok, now I want this daily data in a format that can be compared to the ftip
;or maybe since they are all three hourly we can compare them that way?
;write out the daily data

;ofile='/jabber/Data/mcnally/AMMARain/rain4soil/theo_daily2005_2008.dat'
;openw,1,ofile
;writeu,1,raindata

;box around the millet/fallow sites, not really close to Ramier... 
ROI1=reform(raindata[4,2,0:1459],365,4)
;  ROI2=reform(raindata[0,0,0:1459],365,4);lower left corner
;  ROI3=reform(raindata[5,3,0:1459],365,4);upper right corner
;ofile='/jabber/Data/mcnally/AMMARain/rain4soil/ROI_theo.rain.2005_2008.dat'
;openw,1, ofile
;writeu,1,ROI1
;close,1

print, 'hold here'

 end
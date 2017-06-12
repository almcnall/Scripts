pro EIR_structurev3

; the purpose of this program is to compile a data set for each study site in the 
; EIR database that contains the Average Temperature, min Temp, maxTemp and rainfall 
; for the transmission season during the study and the climatology of the transmission season 
; 8/18/11 this is version 2 where I try to include the year round transmission....
; The MARA map is used to determine the middle month of the transmission season since this (start/end month) is the key
; information that is missing from the EIR file. I assume that the length of season from the EIR file is 'truth'. In many
; cases the length of season calculated from the map is close to that recorded in the EIR file, but sometimes they are very
; different.
;try to fix it again 1/17/2012! for real this time!

months = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec']

;read in the new csv file w/  c_name,lon,lat,seasonality (LOS),siteSOS,siteEOS,EI
eirfile = '/home/mcnally/luce_sites/location_SOS_EOS_LOS2_EIR.csv'
;location_SOS_EOS_LOS2_EIR.csv',c_name,lon,lat,seasonality,siteSOS,siteEOS,mapLOS,EIR 

buffer  = read_csv(eirfile, count = count, missing_value = -999 )

c_name  = buffer.field1
lon     = buffer.field2
lat     = buffer.field3
season  = buffer.field4 
mapSOS  = buffer.field5
mapEOS  = buffer.field6
mapLOS  = buffer.field7
EIR     = buffer.field8

;I could try to guess these from the map later, but for now I will just ignore them
;chnage the NAs to -999s then convert string to float so that I can actual use this LOS value
flag=where(season eq 'NA', count)
season(flag)='-999'
season=float(season)

;*******************************************
;length of season, start of season issues: 7/6/11

;FIRST - find the peak of the transmission season based on the maps
Peakmo = fltarr(193) 
adjsos = fltarr(193)

;finding the peak month of the season - already did this but whatever
ez = where(mapSOS le mapEOS)
Peakmo(ez) = mapSOS(ez) + (mapEOS(ez) - mapSOS(ez))/2

;hd is more complicated it needs to be broken down even futher
hd = where(mapSOS gt mapEOS AND mapEOS ne 1)
Peakmo(hd) = [(12.-mapSOS(hd) + mapEOS(hd))/2.] - (12.-mapSOS(hd))

hdd=where(mapSOS gt mapEOS AND mapEOS eq 1)
Peakmo(hdd) = ((12-mapSOS(hdd) +1)/2) + mapSOS(hdd)

;USE the SEASON info to pick out the months of interest
;1. divide the season in half. 
;   a)for the easy cases subtract this from the peak and add this to the peak
;   b)for the hard cases...look at an example.
halfseason=season/2
;not sure I can totally justify the rounding.
adjsos(ez)=ceil(peakmo(ez)-halfseason(ez))
adjsos(hdd)=ceil(peakmo(hdd)-halfseason(hdd))
adjsos(hd)=ceil(12 -abs(peakmo(hd)-halfseason(hd)))
;sanity check 
print, [transpose(mapsos), transpose(mapeos), $
        transpose(season), transpose(peakmo), transpose(adjsos)]
;print, [transpose(mapsos(hd)), transpose(mapeos(hd)), transpose(peakmo(hd)),transpose(season(hd)),  transpose(adjsos(hd))]
;print, [transpose(mapsos(ez)), transpose(mapeos(ez)), transpose(peakmo(ez)), transpose(season(ez)),transpose(adjsos(ez))]
adjsos=adjsos-1 ;this fixes the index so that jan=1, dec=13
;****************************************************************
;USE these points at the end to exclude what ever got calculated
toss=where(season lt 0 or mapSOS eq 0)
adjsos(toss)=-999.
;****************************************************************
;the outter loop is through the sites, then say average from positionN:positionN+LOS
tempdat=fltarr(193,12)
mintempdat=fltarr(193,12)
maxtempdat=fltarr(193,12)

transTavg=fltarr(193)
transTavg[*]=-999.

transTmin=fltarr(193)
transTmin[*]=-999.

transTmax=fltarr(193)
transTmax[*]=-999.

openr,1, '/home/mcnally/luce_sites/allsites_avgTemp_timeseries.dat'
readu,1,tempdat
close,1

openr,1, '/home/mcnally/luce_sites/allsites_minTemp_timeseries.dat'
readu,1,mintempdat
close,1

openr,1, '/home/mcnally/luce_sites/allsites_maxTemp_timeseries.dat'
readu,1,maxtempdat
close,1

tempdat=[[tempdat],[tempdat]] ;this lets us cross the dec-jan boundary (useful elsewhere?)
mintempdat=[[mintempdat],[mintempdat]]
maxtempdat=[[maxtempdat],[maxtempdat]]

i=0
for i=0,n_elements(lon)-1 do begin ;for each of the 193 sites
  if season[i] le 0. then continue
  if mapSOS[i] eq 0. then continue
  
  transTavg[i]=mean(tempdat[i,adjsos[i]:adjsos[i]+season[i]])
  transTmin[i]=mean(mintempdat[i,adjsos[i]:adjsos[i]+season[i]])
  transTmax[i]=mean(maxtempdat[i,adjsos[i]:adjsos[i]+season[i]])
  
  
  print, i
endfor
;condense the file so it can write more fields..
lonlat=[transpose(lon), transpose(lat)]


ofile='/home/mcnally/luce_sites/avg_transtempsv2.csv'
write_csv, ofile,EIR,season,transTavg,transTmin,transTmax
print, 'hold here'
end

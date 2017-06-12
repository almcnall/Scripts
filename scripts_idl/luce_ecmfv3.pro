pro luce_ecmfv3

;The purpose of this script is to read the daily short term mean fields of tmin, tmax, tavg from the ecmwf data and 
; extract it for the sites where we have malaria sites and average it by month.  

;column headers for the ECMWF_10yravg.dat file 
;tlat, tlon, tavg, tmax, tmin]
ncol = 5
nrow = 1909728
buffer=dblarr(ncol,nrow)

ifile='/home/mcnally/luce_sites/ECMWF_10yravg.dat'
openr,1,ifile
readu,1,buffer
close, 1

tlat=buffer[0,*]
tlon=buffer[1,*]
tavg=buffer[2,*]
tmax=buffer[3,*]
tmin=buffer[4,*]

;Site lat(dd) lon(dd) source  Shp_lat Shp_lon
xycords = '/home/mcnally/luce_sites/location_SOS_EOS_LOS2_EIR.csv'
;location_SOS_EOS_LOS2_EIR.csv',c_name,lon,lat,seasonality,siteSOS,siteEOS,mapLOS,EIR 
 
ifile = read_csv(xycords) 
lon = ifile.field2
lat = ifile.field3
lonlats=[transpose(lon), transpose(lat)]

;round site coordinates(lonlats) to the nearest 0.25 b/c ecmwf is at 0.25 degrees 
roundcoords=float(round(lonlats*4))/4

;initialize as zero so that deks can be summed to months
  avgmonthtot = 0
  minmonthtot = 0
  maxmonthtot = 0 
  
  ;initialize output arrays - 193 sites x 12 months
  monthavg = fltarr(193,12)
  monthmin = fltarr(193,12)
  monthmax = fltarr(193,12)
  
  
for i=0,n_elements(roundcoords[0,*])-1 do begin ;for all sites
    ;select just the lat/lons where the 193 sites are located
    match = where(tlon eq roundcoords[0,i] AND tlat eq roundcoords[1,i])
    ;get the relevant variable (and whole timeseries) for each site.
    avgtimeseries=tavg(match)  
    mintimeseries=tmin(match)
    maxtimeseries=tmax(match)
     
    mcount=0
    dcount=0
    monthtot=0
  for j=0,n_elements(match)-1 do begin  
      ;total up every 3 dekads so that I have monthly averages
      avgmonthtot = avgtimeseries[j]+avgmonthtot
      minmonthtot = mintimeseries[j]+minmonthtot
      maxmonthtot = maxtimeseries[j]+maxmonthtot
           
      dcount++
      if dcount eq 3 then begin
        monthavg[i,mcount] = avgmonthtot/3
        monthmin[i,mcount] = minmonthtot/3
        monthmax[i,mcount] = maxmonthtot/3
        
        mcount++
        dcount=0
        
        avgmonthtot = 0
        minmonthtot = 0
        maxmonthtot = 0 
      endif

    endfor;j
endfor;i

print, i

;write them all out to separate files...
openw,1,'/home/mcnally/luce_sites/allsites_avgTemp_timeseries.dat'
writeu,1,monthavg
close,1

openw,2,'/home/mcnally/luce_sites/allsites_minTemp_timeseries.dat'
writeu,2,monthmin
close,2

openw,3,'/home/mcnally/luce_sites/allsites_maxTemp_timeseries.dat'
writeu,3,monthmax
close,3

end
    
  

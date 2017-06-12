pro make_chirps_global_daily_netcdf_cube_p05, year, last_month, last_day, tifroot, netcdfroot, version, cvtag, comments

;	year		= 2012
;	last_month	=    2
;	last_day	=    8
;	tifroot    	= '/home/CHIRPS/daily/v2.0/tifs/p05/'
;	tifroot    	= '/home/sandbox/chirps/v2.0/daily_downscaled_by_monthly/global_full_rescale/'
;	netcdfroot 	= '/home/CHIRPS/daily/v2.0/netcdf/sub/'
;	version 	= 'Version 2.0'
;	cvtag		= 'chirps-v2.0.'
;	comments	= ' '

;________________________________________________________________________________________________________
print,systime()
restore, '/home/chg-pete/idl_saves/dexs.sav'

dim       				 = [31,28,31, 30,31,30, 31,31,30,  31,30,31]       ; Days in Month
som_Jday  				 = [0,31,   59,90,120,151,181,212,243,273,304,334]    ; Start of Month
if(year mod 4 eq 0) then        dim(1)   =  29
if(year mod 4 eq 0) then        som_Jday = [0,31,   60,91,121,152,182,213,244,274,305,335,366]

numdays = som_Jday(last_month - 1) + last_day 		&	print, numdays

caldat, julday(), mm,dd,yy	&	date_created = decakilodex(yy)+'-'+centadex(mm)+'-'+centadex(dd)

netcdffile = netcdfroot+cvtag+decakilodex(year)+'.days_p05.nc'

ds80 = fltarr(numdays)
data = fltarr(7200,2000,numdays) - 9999.0
gotem = intarr(numdays)

for month = 1, last_month do begin
    for day = 1, 31 do begin
	dex = som_Jday(month - 1) + day
;	tiffile   = tifroot+decakilodex(year)+'/'+cvtag+decakilodex(year)+'.'+centadex(month)+'.'+centadex(day)+'.tif'
	tiffile   = tifroot+decakilodex(year)+'/'+cvtag+decakilodex(year)+'.'+centadex(month)+'.'+centadex(day)+'.tif'
	fexists   = file_test(tiffile) 	
	if(              dex le numdays) then    gotem(dex-1) = fexists
	if(              dex le numdays) then     ds80(dex-1) = float(julday(month,day,year) - julday(1,1,1980))
	if(fexists  AND  dex le numdays) then data(*,*,dex-1) = reverse(read_tiff(tiffile),2)
    endfor
endfor

print, ' '	&	print, '  found ',total(gotem),' input days, hoping for ',numdays	&	print, ' '
print,systime()


;________________________________________________________________________________________________________


long_name 		= 'Climate Hazards group InfraRed Precipitation with Stations'
units			= 'mm/day'
missing_value  		= -9999.
standard_name		= 'convective precipitation rate'
time_step 		= 'day'
geostatial_lat_min	=  -50.
geostatial_lat_max	=   50.
geostatial_lon_min	=  -180.
geostatial_lon_max	=   180.

creator_name 		= 'Pete Peterson'
creator_email 		= 'pete@geog.ucsb.edu'
institution 		= 'Climate Hazards Group.  University of California at Santa Barbara'
ftp_url   		= 'ftp://chg-ftpout.geog.ucsb.edu/pub/org/chg/products/CHIRPS-latest/'

Conventions		= 'CF-1.6'
faq			= 'http://chg-wiki.geog.ucsb.edu/wiki/CHIRPS_FAQ'
title  			= 'CHIRPS '+version
history  		= 'created by Climate Hazards Group'
documentation  		= 'http://pubs.usgs.gov/ds/832/'
website  		= 'http://chg.geog.ucsb.edu/data/chirps/index.html'
reference  		= 'Funk, C.C., Peterson, P.J., Landsfeld, M.F., Pedreros, D.H., Verdin, J.P., Rowland, J.D., Romero, B.E., Husak, G.J., Michaelsen, J.C., and Verdin, A.P., 2014, A quasi-global precipitation time series for drought monitoring: U.S. Geological Survey Data Series 832, 4 p., http://dx.doi.org/110.3133/ds832. '
acknowledgements  	= 'The Climate Hazards Group InfraRed Precipitation with Stations development process was carried out through U.S. Geological Survey (USGS) cooperative agreement #G09AC000001 "Monitoring and Forecasting Climate, Water and Land Use for Food Production in the Developing World" with funding from: U.S. Agency for International Development Office of Food for Peace, award #AID-FFP-P-10-00002 for "Famine Early Warning Systems Network Support," the National Aeronautics and Space Administration Applied Sciences Program, Decisions award #NN10AN26I for "A Land Data Assimilation System for Famine Early Warning," SERVIR award #NNH12AU22I for "A Long Time-Series Indicator of Agricultural Drought for the Greater Horn of Africa," The National Oceanic and Atmospheric Administration award NA11OAR4310151 for "A Global Standardized Precipitation Index supporting the US Drought Portal and the Famine Early Warning System Network," and the USGS Land Change Science Program.'

;________________________________________________________________________________________________________

fexists = file_test(tiffile)	&	print, fexists

;  if(fexists) then begin
;    print, tiffile
;    chirps = reverse(read_tiff(tiffile),2)	;	read in CHIRPS data

    COMPILE_OPT IDL2                             ; Set compile options
    
    nx   =  7200                                 ; Size of y-dimension
    xmin = -179.975                              ; Minimum longitude
    xmax =  179.975                              ; Maximum longitude
    dx   = (xmax - xmin)/(nx - 1)                ; Longitude spacing
    x    = xmin + dx*FINDGEN(nx)                 ; Compute x-coordinates
    ny   =  2000                                 ; Size of x-dimension
    ymin = -49.975                               ; Minimum latitude
    ymax =  49.975                               ; Maximum latitude
    dy   = (ymax - ymin)/(ny - 1)                ; Latitude spacing
    y    = ymin + dy*FINDGEN(ny)                 ; Compute y-coordinates
    
    
    id   = NCDF_CREATE(netcdffile, /CLOBBER, /NETCDF4_FORMAT)

    xid  = NCDF_DIMDEF(id, 'longitude', nx)                     ; Define y-dimension
    yid  = NCDF_DIMDEF(id, 'latitude',  ny)                     ; Define x-dimension
    tid  = NCDF_DIMDEF(id, 'time', numdays)                 	; Define z-dimension
    
    vid = NCDF_VARDEF(id, 'latitude',         yid, /float, /CONTIGUOUS)     ; Define latitude variable
    vid = NCDF_VARDEF(id, 'longitude',        xid, /float, /CONTIGUOUS)     ; Define longitude variable
    vid = NCDF_VARDEF(id, 'precip', [xid,yid,tid], /float,      GZIP=5)     ; Define chirps variable
    vid = NCDF_VARDEF(id, 'time',             tid, /float, /CONTIGUOUS)     ; Define time variable
    
    NCDF_ATTPUT, id, /CHAR, /GLOBAL, 'Conventions', 	Conventions		; Some Global Attributes
    NCDF_ATTPUT, id, /CHAR, /GLOBAL, 'title', 		title			; Some Global Attributes
    NCDF_ATTPUT, id, /CHAR, /GLOBAL, 'history', 	history			; Some Global Attributes
    NCDF_ATTPUT, id, /CHAR, /GLOBAL, 'version', 	version			; Some Global Attributes
    NCDF_ATTPUT, id, /CHAR, /GLOBAL, 'date_created', 	date_created   		; Some Global Attributes
    NCDF_ATTPUT, id, /CHAR, /GLOBAL, 'creator_name', 	creator_name    	; Some Global Attributes
    NCDF_ATTPUT, id, /CHAR, /GLOBAL, 'creator_email', 	creator_email    	; Some Global Attributes
    NCDF_ATTPUT, id, /CHAR, /GLOBAL, 'institution', 	institution    		; Some Global Attributes
    NCDF_ATTPUT, id, /CHAR, /GLOBAL, 'documentation', 	documentation		; Some Global Attributes
    NCDF_ATTPUT, id, /CHAR, /GLOBAL, 'reference', 	reference		; Some Global Attributes
    NCDF_ATTPUT, id, /CHAR, /GLOBAL, 'comments', 	comments		; Some Global Attributes
    NCDF_ATTPUT, id, /CHAR, /GLOBAL, 'acknowledgements', acknowledgements	; Some Global Attributes
    NCDF_ATTPUT, id, /CHAR, /GLOBAL, 'ftp_url', 	ftp_url    		; Some Global Attributes
    NCDF_ATTPUT, id, /CHAR, /GLOBAL, 'website', 	website			; Some Global Attributes
    NCDF_ATTPUT, id, /CHAR, /GLOBAL, 'faq', 		faq    			; Some Global Attributes

    NCDF_ATTPUT, id, /CHAR, 'longitude',      'units',          'degrees_east'          ; Write longitude units attribute
    NCDF_ATTPUT, id, /CHAR, 'longitude',      'standard_name',  'longitude'             ; Write longitude units attribute
    NCDF_ATTPUT, id, /CHAR, 'longitude',      'long_name',      'longitude'             ; Write longitude units attribute
    NCDF_ATTPUT, id, /CHAR, 'longitude',      'axis',           'X'                     ; Write longitude axis attribute

    NCDF_ATTPUT, id, /CHAR, 'latitude',       'units',          'degrees_north'         ; Write latitude units attribute
    NCDF_ATTPUT, id, /CHAR, 'latitude',       'standard_name',  'latitude'              ; Write latitude units attribute
    NCDF_ATTPUT, id, /CHAR, 'latitude',       'long_name',      'latitude'              ; Write latitude units attribute
    NCDF_ATTPUT, id, /CHAR, 'latitude',       'axis',           'Y'                     ; Write latitude axis attribute

    NCDF_ATTPUT, id, /CHAR, 'time',  'units',                   'days since 1980-1-1 0:0:0'     ; Write time units attribute
    NCDF_ATTPUT, id, /CHAR, 'time',  'standard_name',           'time'                          ; Write time standard_name attribute
;    NCDF_ATTPUT, id, /CHAR, 'time',  'calendar',                'proleptic_gregorian'           ; Write time calendar attribute
;    NCDF_ATTPUT, id, /CHAR, 'time',  'axis',                    'Z'                             ; Write time axis attribute
;  *** changed above 2 lines to below 2 lines 2015.09.24 based on suggestions from Dave Allured  - pete
    NCDF_ATTPUT, id, /CHAR, 'time',  'calendar',                'gregorian'           ; Write time calendar attribute	; changed on 2015.09.24
    NCDF_ATTPUT, id, /CHAR, 'time',  'axis',                    'T'                             ; Write time axis attribute

    NCDF_ATTPUT, id, /CHAR, 'precip',  'units',                 units                   ; Write chirps units attribute
    NCDF_ATTPUT, id, /CHAR, 'precip',  'standard_name',         standard_name           ; Write chirps standard_name attribute
    NCDF_ATTPUT, id, /CHAR, 'precip',  'long_name',             long_name               ; Write chirps long_name attribute
    NCDF_ATTPUT, id, /CHAR, 'precip',  'time_step',             time_step               ; Write chirps time_step attribute
    NCDF_ATTPUT, id, 'precip',  'missing_value',        missing_value           ; Write chirps missing_value attribute
    NCDF_ATTPUT, id, 'precip',  '_FillValue',           missing_value           ; Write chirps missing_value attribute
    NCDF_ATTPUT, id, 'precip',  'geostatial_lat_min',   geostatial_lat_min      ; Write chirps geostatial_lat_min attribute
    NCDF_ATTPUT, id, 'precip',  'geostatial_lat_max',   geostatial_lat_max      ; Write chirps geostatial_lat_max attribute
    NCDF_ATTPUT, id, 'precip',  'geostatial_lon_min',   geostatial_lon_min      ; Write chirps geostatial_lon_min attribute
    NCDF_ATTPUT, id, 'precip',  'geostatial_lon_max',   geostatial_lon_max      ; Write chirps geostatial_lon_max attribute 


    NCDF_CONTROL, id, /ENDEF                            ; Exit define mode
    
    NCDF_VARPUT, id, 'longitude',   	x               ; Write longitude to file
    NCDF_VARPUT, id, 'latitude',    	y               ; Write latitude to file
    NCDF_VARPUT, id, 'precip', 		data          ; Write chirps to file
    NCDF_VARPUT, id, 'time',            ds80   ; Write time to file
    
    NCDF_CLOSE, id                                      ; Close netCDF output file
;  endif
    
print,systime()
end



pro read_ecoclimap

;the purpose of this program is to read the gridded station data that Theo sent. I used the ncdump output to help
; know what I was trying to read in (2/6/12)added some om 4/10/12 to compare the cummulative rainfall patterns 
; with Raimer et al. (2009) and the East station data. They don't really seem to agree so I am going back to the station
; data for a while. 
;also try this to look at the ecoclimap data
 ;lat =     12.875       14.125   (26) = 26
 ;lon =     1.5750       3.1250   (32) = 32

;indir = strcompress('/jabber/Data/mcnally/AMMARain/',/remove_all)
;fname=file_search(indir+'rainfield*.nc')
fname = file_search('/jabber/chg-mcnally/AMMAVeg/ECOCLIMAP2/ALMIP2_ECOCLIMAP2_05_Niger.nc')
i = 0
;open the file
;for i=0,n_elements(fname)-1 do begin
  fileID = ncdf_open(fname[i], /nowrite)
;time longitude latitude sand clay rsmin droot dsoil lai (fraction of) veg z0v alb_vis alb_nir
  varname = ncdf_vardir(fileID) & print, varname
  ;rainID = ncdf_varid(fileID,'rainfall')
  timeID = ncdf_varid(fileID,'time')
  lonID = ncdf_varid(fileID,'longitude')
  latID = ncdf_varid(fileID,'latitude')
  sandID = ncdf_varid(fileID,'sand')
  clayID = ncdf_varid(fileID,'clay')
  rsminID = ncdf_varid(fileID,'rsmin')
  drootID = ncdf_varid(fileID,'droot')
  dsoilID = ncdf_varid(fileID,'dsoil')
  laiID = ncdf_varid(fileID,'lai')
  vegID = ncdf_varid(fileID,'veg')
  
  ;ncdf_varget,fileID,rainID,raindata
  ncdf_varget,fileID,timeID,timedata
  ncdf_varget,fileID,lonID,londata
  ncdf_varget,fileID,latID,latdata
  ncdf_varget,fileID,sandID,sanddata
  ncdf_varget,fileID,clayID,claydata
  
  ncdf_varget,fileID,rsminID,rsmindata
  ncdf_varget,fileID,drootID,drootdata
  ncdf_varget,fileID,dsoilID,dsoildata
  ncdf_varget,fileID,laiID,laidata
  ncdf_varget,fileID,vegID,vegdata
  
 

timeUTC=intarr(6,n_elements(timedata))
;convert the epoch time to a nice date string  
for i=0, n_elements(timedata)-1 do begin
  buffer=systime(0,timedata[i], /utc) 
  ;make a new vector with a datestring that I can read
  timeUTC[*,i]=bin_date(buffer)
endfor

  scalefactor=0.01
  ;raindata=raindata*scalefactor ;where did the scale factor come from?

;added this part in on 4/10/12 to compare the cummulative rainfall patterns 
; with Raimer et al. (2009) and the East station data.these don't really seem to agree...  
j=3 ;col
k=3 ;row
cum05=fltarr(n_elements(raindata[j,k,*]))
for i=1,n_elements(raindata[j,k,*])-1 do begin &$
  cum05[0]=raindata[j,k,0] &$
  cum05[i]=cum05[i-1]+raindata[j,k,i] &$
endfor
  ;p1=plot(cum05*scalefactor) 
  p1=plot(cum05*scalefactor, /overplot, thick=2, 'g') 
  print, 'hold please'
;make the three hourly data into daily data:what happened to the code here?!

;  avgrain=mean(raindata, dimension=3)
;  avgrain=congrid(avgrain,6*100,4*100)
;  p1=image(avgrain)
  
 ;make the data more friendly to look at
 min=where(raindata eq -999990, count)
;ncdf_inquire=returns a structure with info about the open file 
filestruct = ncdf_inquire(fileID) & help, filestruct ;this gives me the number of var/att/dims but not there names. 
  ndims = filestruct.ndims ;dimensions (3)
  nvars = filestruct.nvars; variables (5)
  ngatts = filestruct.ngatts;global attributes (7)
  recdim = filestruct.recdim ;id number of the unlimited dimension (2)

;if vars are found, get varnames (from Gumley pp. 
;read the 7 global file attributes (conventions, title, institution,source,history,comment,references)
j = 0 
globalattname = ncdf_attname(fileID,j,/global);returns name of attribute file given its ID: 0-6
varname = ncdf_vardir(fileID) & print, varname
attname = ncdf_attdir(fileID, 'rainfall') & print, attname

;var_ID returns the id of the variable, once I know their names
rainID = ncdf_varid(fileID,'rainfall')

;retrieves the values from the variable of interest, last argument is the new array where data lives. 
unit=strarr(2)
ncdf_varget, fileID, rainID, raindata ;raindata is the nx=6, ny=4, nz=2921
unitq=ncdf_attinq(fileID, rainID,'units')
ncdf_attget, fileID, rainID, 'units', string(unit)

p1 = plot(raindata[4,2,*]);what are your units??
;this rainfall data does not seem quite right, is it really a rainfall rate? should there be a cap on these silly large values?
plothist,raindata[4,2,*], /autobin, YRANGE=[0,20], xrange=[0,40],/fill, title='3hrly rainfall '+fname[0]

end
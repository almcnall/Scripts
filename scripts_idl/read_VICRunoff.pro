pro read_VICRuoff

;the purpose of this program is to read the netCDF data that andy converted from grib, is is the VIC GLDAS data
; I only need runoff but I accidently downloaded all of the available variables. 

gtag_1Deg = { ModelTiepointTag: [0,0,0, -20,40,0], $
                ModelPixelScaleTag: [1,1,0], $
                GTModelTypeGeoKey:    2,         $  ; (ModelTypeGeographic)
                GTRasterTypeGeoKey:   1,         $  ; (RasterPixelIsArea)
                GeographicTypeGeoKey: 4326,      $  ; (GCS_WGS_84)
                GeogAngularUnitsGeoKey: 9102s    $  ; Angular_Degree
          }


indir = strcompress('/jabber/sandbox/mcnally/VIC_runoff/netcdf/',/remove_all)
cd, indir

fname=file_search('*.nc')

i = 0
;open the file
fileID = ncdf_open(fname[i], /nowrite)

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
attname = ncdf_attdir(fileID, 'SSRUN_GDS0_SFC_ave4h') & print, attname

;var_ID returns the id of the variable, once I know their names
lonID = ncdf_varid(fileID,'g0_lon_1')
runoffID = ncdf_varid(fileID,'SSRUN_GDS0_SFC_ave4h')
subroID = ncdf_varid(fileID,'BGRUN_GDS0_SFC_ave4h')
;made some changes up to here in prep for reading the VIC runoff......1/26/12

;retrieves the values from the variable of interest, last argument is the new array where data lives. 
unit = strarr(2)
ncdf_varget, fileID, runoffID, runoffdata ;raindata is the nx=6, ny=4, nz=2921
ncdf_varget, fileID, lonID, londata
unitq = ncdf_attinq(fileID, runoffID,'units')
ncdf_attget, fileID, runoffID, 'units', string(unit)
ncdf_attget, fileID, runoffID, 'center', string(unit)

;ok this works now lets put it in a loop and write out the files!

max=where(runoffdata eq   1.00000e+20, count)
runoffdata(max)=!VALUES.F_NAN
p1 = image(runoffdata)

runoffdata=reverse(runoffdata,2) ;flip so it can be read in envi
runoffdata=runoffdata*86400 ;convert to mm
;lets try writing out just runoff to binary or something. GeoTiff!
write_tiff, '/home/mcnally/runoff.tiff' , runoffdata, /float, geotiff=gtag_1Deg

end
pro read_VICSM

;the purpose of this program is to read the netCDF data that andy converted from grib, is is the VIC GLDAS data
;Narcissa want surface and subsurface runoff, soil moisture, and rainfall. 

;SOIL_M_GDS0_DBLY:long_name = "Soil moisture content" ;
;SOIL_M_GDS0_DBLY:units = "kg/m^2" ;


gtag_1Deg = { ModelTiepointTag: [0,0,0, -20.5,40.5,0], $
                ModelPixelScaleTag: [1,1,0], $
                GTModelTypeGeoKey:    2,         $  ; (ModelTypeGeographic)
                GTRasterTypeGeoKey:   1,         $  ; (RasterPixelIsArea)
                GeographicTypeGeoKey: 4326,      $  ; (GCS_WGS_84)
                GeogAngularUnitsGeoKey: 9102s    $  ; Angular_Degree
          }

indir = strcompress('/jabber/sandbox/mcnally/VIC_runoff/netcdf/',/remove_all)
odir = strcompress('/jabber/sandbox/mcnally/VIC_runoff/binary/SoilMoist/', /remove_all)
file_mkdir, odir
cd, indir

fname=file_search('*.nc')

for i= 0,n_elements(fname)-1 do begin
;open the file
  fileID = ncdf_open(fname[i], /nowrite)
  runoffID = ncdf_varid(fileID,'SOIL_M_GDS0_DBLY');I know the name from using some other functions, ncdump is prolly best
  ncdf_varget, fileID, runoffID, runoffdata ;

  ;make the data more friendly to look at
  max=where(runoffdata eq   1.00000e+20, count)
  runoffdata(max)=!VALUES.F_NAN
  runoffdata=reverse(runoffdata,2) ;flip so it can be read in envi
  ;runoffdata=runoffdata*86400 ;convert to mm


  write_tiff, odir+strmid(fname[i],0,39)+'.tiff' , runoffdata, /float, geotiff=gtag_1Deg
  ncdf_close, fileID
endfor;i

end
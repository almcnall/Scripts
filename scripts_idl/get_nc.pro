FUNCTION get_nc, invar, ifile

;1/4/16 this function cleans up the reading of netcdf files a little.

if ifile eq '' then retall
fileID = ncdf_open(ifile, /nowrite)
varID = ncdf_varid(fileID,invar)
ncdf_varget,fileID, varID, OUTDAT

return, outdat
NCDF_close, fileID

END
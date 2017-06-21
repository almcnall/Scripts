pro alexi
;checking out the alexi data
;regrid and make a time series for the western mask

NX = 1450
NY = 1650
NZ = 4500

map_ulx = 21.439  & map_lrx = 60.56
map_uly = 38.508  & map_lry = -6.008

ulx = (180.+map_ulx)*47.  & lrx = (180.+map_lrx)*47.
uly = (50.-map_uly)*47.   & lry = (50.-map_lry)*47.
NX = lrx - ulx + 1
NY = lry - uly + 1

ingrid = fltarr(nx, ny, nz)
buffer = fltarr(nx,ny)
ifile = file_search('/home/sandbox/people/mcnally/alexi_data/EDY7_MENAE_TERR/2013/EDY*')

for i = 0, n_elements(ifile)-1 do begin &$
  i=0
  openr,1,ifile[i]
  readu,1,buffer
  close,1 
 
 buffer(where(buffer lt 0)) = !values.f_nan
  
  ingrid[*,*,i] =

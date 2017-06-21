pro read_SMAP
;the purpose of this script is to read in the simulated smap data
;is this data different than what is currently (2/22/2013) available at http://nsidc.org/data/smap/restricted-data/simulation_data.html
;this seems to be in the EASE-grid format and uses an equal area projection.

;filename = file_search('/jabber/sandbox/mcnally/SMAP/SMAP_L3_SM_AP_20030501_001.h5')
;fname = file_search('/jabber/sandbox/mcnally/SMAP/SMAP_L3_*.bin')
fname = file_search('/home/mcnally/afr_geog_test')


; READ IN FILE AND GET MAP INFO
   ENVI_OPEN_DATA_FILE, fname, r_fid=fid
   ENVI_FILE_QUERY, fid, ns=ns, nl=nl, nb=nb
   print, 'samples = ', ns
   print, 'lines = ', nl
   print, 'bands = ', nb
   tmp_map_info = ENVI_GET_MAP_INFO(FID = fid)

 in_proj = ENVI_GET_PROJECTION(FID=fid) ;ugh, did I need this from the header info? what kind of projection is this?
 out_proj = ENVI_PROJ_CREATE(/geographic)

   ENVI_CONVERT_PROJECTION_COORDINATES, $
      tmp_map_info.ps(0), tmp_map_info.ps(1), in_proj, $
      xsize, ysize, out_proj

  ENVI_CONVERT_FILE_MAP_PROJECTION,$ 
    dims=[-1L,0,ns-1,0,nl-1],fid=fid,o_proj=out_proj,$
    out_name='~/test_transform',POS=[0],o_pixel_size=[0.1, 0.1]



;all the content of the hdr file goes into struct
struct = h5_parse(filename,/read_data)
;fid = H5F_CREATE('file.h5')
help,struct.SOIL_MOISTURE_RETRIEVAL_DATA

latitude  = struct.SOIL_MOISTURE_RETRIEVAL_DATA.cell_lat._data
longitude = struct.SOIL_MOISTURE_RETRIEVAL_DATA.cell_lon._data

;Soil moisture retrieved from combined radiometer and radar data units = cm^3/cm
soil_moist  =  struct.SOIL_MOISTURE_RETRIEVAL_DATA.soil_moisture
clay      = struct.SOIL_MOISTURE_RETRIEVAL_DATA.clay_fraction

;nx = 3852
;ny = 1632
grid = reverse(soil_moist._DATA,2) 
claygrid = reverse(clay._DATA,2) ;too bad it has the same stripes as the may data.
;email ...: Narendra.N.Das@jpl.nasa.gov

temp = image(grid, rgb_table = 4)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)

;write it out as a binary file the projection info won't be retained....             
ofile = '/jabber/sandbox/mcnally/SMAP/SMAP_L3_20030501.bin'
grid = reverse(grid,2)
openw,1,ofile
writeu,1,grid
close,1
;try the "envi_convert_file_map_projection" function            
;look at: '/jabber/sandbox/shared/hollywood/Niger/Validation2007/ntf2gtif.pro'


;it would be nice to overlay some country boundaries here...maybe clip down to africa window
;
west =  (180-20.)/.0934579
east = (180+55)/0.0934579 & print, east
south = (55-40)/0.0934579 & print, south
north = (55+80)/0.0934579 & print, north
; I think that it should end up being nx = 802, ny = 856, but actually i have 803 x 1285

Afgrid = grid[west:east,south:north]
temp = image(Afgrid, rgb_table = 4)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
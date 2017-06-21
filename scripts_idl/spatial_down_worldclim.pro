;spatial downscaling attempt but worldclim hasn't been enabled yet? maybe for afghanistan?
ifile1 = file_search('/home/mcnally/Rain*nd.nc')
fileID = ncdf_open(ifile1) &$
  smID = ncdf_varid(fileID,'Rainf_f_tavg') &$
  ncdf_varget,fileID, smID, rnd
  
  ifile2 = file_search('/home/mcnally/Rain*sd.nc')
  fileID = ncdf_open(ifile2) &$
    smID = ncdf_varid(fileID,'Rainf_f_tavg') &$
    ncdf_varget,fileID, smID, rsd
  
  ;where is yeemen in this box, duh, no rain at end of Oct in yemen.
  ;maybe see how much diff it makes over africa (short rain)
  ; uuugh, i am not seeing any difference here. whats up with dat?
  
  ;East Africa WRSI/Noah window
  map_ulx = 22.  & map_lrx = 51.35 &$
    map_uly = 22.95  & map_lry = -11.75 &$
    bot = (7)/0.01 & top = (2-map_lry)/0.01  &$
    left = (35-map_ulx)/0.01 & right = (40-map_ulx)/0.01  &$


temp = image(mean(rnd[left:right, bot:top,*], dimension=3), rgb_table=4)

diff = rsd[left:right, bot:top,*]-rnd[left:right, bot:top,*] & help, diff

temp = image(rsd[left:right, bot:top,*], dimension=3), rgb_table=4)

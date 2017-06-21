pro clip_MOD16tiff

;this program clips out the global MOD16 to the 1501x1601 africa window.
;8/15/2013 modified the script to clip MOD16 to the 0.05 degree window.(1500x1600), 60S to 70N?

ifile = file_search('/jower/sandbox/mcnally/MOD16/MOD16A2_ET_0.05deg_GEO_*.tif')
stack = fltarr(1500,1600)

;get the new g_tag from this example that i saved in ENVI:
exfile = file_search('/home/mcnally/MOD16_example.tif')
example = read_tiff(exfile,R,G,B,geotiff=g_tags);so, these are taged in upside down envi land....will idl flip the tag?

;first clip to the RFE window....these won't read into envi properly (upside down) 
for j=0,N_elements(ifile)-1 do begin &$
  MET = read_tiff(ifile[j]) &$
  MET = reverse(MET,2) &$
  CLIP = MET[3200:4699,400:2199-200] &$
  clipflip = reverse(clip,2) &$
  ofile = strcompress('/jower/sandbox/mcnally/MOD16/Africa/'+strmid(ifile[j],29,34), /remove_all) &$
  write_tiff, ofile, clipflip, geotiff=g_tags, /SHORT &$
  ;stack = mean([ [[CLIP]],[[stack]] ], dimension=3) &$
  print, strmid(ifile[j],29,34) &$
endfor

;1500,1600 0.05 africa window...
;temp = image(reverse(clipflip,2)/100, rgb_table=4);1500,1600 isn't bad....



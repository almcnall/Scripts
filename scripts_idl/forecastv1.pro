;so now the question is, do conditions in september predict conditions in december? 
;how would this work? plot all sept vs dec. for what area the whole thing?
;
sfile = file_search('/raid/chg-mcnally/horn/ubrfe_horn_20??{25,26,27}.tif')
dfile = file_search('/raid/chg-mcnally/horn/ubrfe_horn_20??{31,32,33}.tif')

nx = 240
ny = 350

sgrid = fltarr(nx,ny,n_elements(sfile))
dgrid = fltarr(nx,ny,n_elements(dfile))

for i = 0,n_elements(sfile)-1 do begin &$
  sbuffer = read_tiff(sfile[i],GEOTIFF=g_tags) &$
  sgrid[*,*,i] = sbuffer &$
  dbuffer = read_tiff(dfile[i], GEOTIFF=g_tags) &$
  dgrid[*,*,i] = dbuffer &$
endfor

s = mean(mean(sgrid, dimension=1, /nan), dimension=1, /nan)
d = mean(mean(dgrid, dimension=1, /nan), dimension=1, /nan)

p1 = plot(s,d, '*')

p1=plot(s)
p2=plot(d, /overplot, linestyle=2)
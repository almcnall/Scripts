;the purpose of this script is to make seasonal totals 2001-2011 for kat
;I should redo this in after subtracting out the wilting point and other improvements (fill out till present etc)

;reading in the TIFF
ifile = file_search('/jabber/sandbox/mcnally/ForKatNDVI/Mali_soil_moist_AMNFT.tif')
masm = read_tiff(ifile,GEOTIFF=g_tags);

;reading in the binary file....
ifile = file_search('/jabber/sandbox/mcnally/ForKatNDVI/Mali_soil_moist_AMNF')
nx = 164
ny = 148
nz = 390

ingrid = fltarr(nx,ny,nz)
openr,1,ifile
readu,1,ingrid
close,1

ingrid = reverse(ingrid,2)
null = where(ingrid lt 0)
ingrid(null) = !values.f_nan

pad = fltarr(nx,ny,6)
pad[*,*,*] = !values.f_nan

fullgrid = [[[ingrid]],[[pad]]] & help, fullgrid
year = ['2001', '2002', '2003','2004', '2005', '2006', '2007', '2008', '2009','2010','2011']

;kat requested july-december dekads 19:33
BFcube = reform(fullgrid,nx,ny,36,n_elements(year))
outgrid = fltarr(nx,ny,11)

for y = 0,n_elements(year)-1 do begin &$
   buffer = total(BFcube[*,*,18:32,y],3,/nan) &$
   outgrid[*,*,y] = buffer &$
   ofile = strcompress('/jabber/sandbox/mcnally/ForKatNDVI/Mali_totSM_JASON.'+year[y]+'.tiff', /remove_all) &$
   write_tiff, ofile, reverse(buffer,2), geotiff=g_tags, /FLOAT &$
   print, ofile &$
endfor

;write out outgrid to tiff so that they can read it easy or did i do this in envi before?
;I can use the same g_tag as I had before....

 


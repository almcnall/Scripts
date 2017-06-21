pro make_climCHIRPS

;make a clim of the CHIRPSv1.8
yyyy = indgen(33)+1981 & print, yyyy
mm = ['01','02','03','04','05','06','07','08','09','10','11','12']
;spet,apr,jun,nov 
dim = [31,28,31,  30,31,30,  31,31,30,  31,30,31]
infile = file_search('/home/ftp_out/products/CHIRPS-1.8/africa_daily/tifs/africa_p05_tif/????/chirps-v1.8.*.tif')
infile8113 =  infile[0:12173-120]

mon = strmid(infile8113,89,2) & print, mon[0]
day = strmid(infile8113,92,2) & print, day[0]
info = read_tiff(infile8113[0], GEOTIFF=g_tags)
dims = size(info, /dimensions)

NX = dims[0]
NY = dims[1]

;for a given month
for m = 0,n_elements(mm)-1 do begin &$

  ;pull files for all 33 years
  foi = infile8113(where(strmid(infile8113,89,2) eq mm[m])) &$
  ;then look at the day
  for d = 0,dim[m]-1 do begin &$
    dd = string(format='(I2.2)',d+1) &$
    dfile = foi(where(strmid(foi,92,2) eq dd)) & print, dfile[0] &$
    stack = fltarr(NX,NY,n_elements(dfile))  &$
    for j = 0,n_elements(dfile)-1 do begin &$
      temp = read_tiff(dfile[j]) &$
      temp(where(temp eq -9999.0)) = !values.f_nan &$
      stack[*,*,j]=temp &$
    ;jl
    endfor &$
      out = mean(stack,dimension=3, /nan) & print, mean(out,/nan)&$
      ofile = strcompress('/home/sandbox/people/mcnally/CHIRPS-1.8/avg30yr/chirps-v1.8.'+mm[m]+'.'+dd+'.tif', /remove_all) &$
      write_tiff, ofile, out,geotiff=g_tags, /FLOAT &$
    endfor &$
 endfor;m
 


    
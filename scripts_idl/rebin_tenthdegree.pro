pro rebin_tenthdegree

;this program shapes up the unbiased daily data so that it can be ingested into the lis. 

exp  = 'EXP024'
name = 'cmap'

dubrf_dir = strcompress('/gibber/lis_data/OUTPUT/'+exp+'/NOAH/daily', /remove_all)
odir      = strcompress('/gibber/lis_data/OUTPUT/'+exp+'/NOAH/tenth_deg_day', /remove_all)

file_mkdir, odir

cd, dubrf_dir

dayub_file = file_search('rain*.img')

inx  = 301. ; number of cols in 0.25deg input data
iny  = 321. ; number of rows in 0.25deg input data
outx = 751. ; number of cols in 0.10deg input data
outy = 801. ; number of rows in 0.10deg input data

ingrid  = fltarr(inx,iny)
outgrid = fltarr(outx,outy)
tenthgrid = fltarr(outx,outy)

for i=0, n_elements(dayub_file)-1 do begin
  
  yr  = strmid(dayub_file[i],5,4)
  mo  = strmid(dayub_file[i],9,2)
  day = strmid(dayub_file[i],11,2)
  
  openu,1, dayub_file[i]
  readu,1, ingrid
  tenthdeg = congrid(ingrid,outx,outy)
  
  good = 0
  bad  = 0
  good = WHERE(FINITE(tenthdeg),complement=bad)
  flag = -999.0
  tenthdeg[bad] = flag
  
  ;envi shows other negative values, not sure if they exsist....
  tenthdeg(where(tenthdeg lt 0)) = -999.0
 

  direction = 2
  tenthdeg[*,*] = REVERSE(tenthdeg[*,*],direction)


  byteorder,tenthdeg,/XDRTOF
  ofile = strcompress(odir+'/all_products.bin.'+yr+mo+day, /remove_all)
  print, ofile
  openw, 2,ofile
  writeu,2,tenthdeg
  print, 'writing '+ofile+'

close, /all
endfor

end  
 
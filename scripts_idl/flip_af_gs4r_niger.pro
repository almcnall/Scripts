pro flip_AF_gs4r_niger,date,year,expdir,nx,ny,nbands
;post processing script for niger/amma runs 9/6/11

;expdir = 'EXPA02'
;date = '20040101'
;year = '2004' 

wdir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/"+year+"/"+date+"/",/remove_all)
print,wdir
cd,wdir 

files = file_search('*gs4r')
direction = 2 ;files are upsidedown

;hu, wonder what my dimensions are....I think that these are right and that my data is bad.
nx     = long(nx)
ny     = long(ny)
;nbands = 37. ;rad x4, heatflux x3, rain x4, evap x7, flow x2, albedo, SMx6, soiltemp x4, intercept, wind, tair, qair
nyuk   = 2.

data_in  = fltarr((nx*ny)+nyuk,nbands)
data_out = fltarr(nx   ,ny    ,nbands)

file_mkdir,'deyuk'

for i=0,n_elements(files)-1 do begin

  ; open up file and read unformatted into 'data_in'
  openr,lun,files[i],/get_lun
  readu,lun,data_in
  
  ; start J FOR loop to cycle through bands and flip them upside down
  for j=0,nbands-1 do begin
    tmp = data_in[0:(nx*ny)-1,j]
    tmp = reform(tmp,nx,ny)
    data_out[*,*,j] = tmp
    data_out[*,*,j] = REVERSE(data_out[*,*,j],direction)
  endfor ; close J FOR loop
  close,lun
  free_lun,lun

  ; write output file in subdirectory
  cd,'deyuk'
  openw,lun,files[i],/get_lun
  writeu,lun,data_out
  close,lun
  free_lun,lun

  ; come back up one level
  cd,'..'
; close I FOR loop
endfor

;print, 'hi'
; end program
end

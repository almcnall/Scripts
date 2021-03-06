pro flip_AF_gs4r,date,year

wdir = strcompress("/jower/LIS/Code/src/OUTPUT/Zoundsb/NOAH/"+year+"/"+date+"/",/remove_all)

print,wdir
cd,wdir 
print,wdir
cd,wdir 

files = file_search('*gs4r')
; flip direction
direction = 2

nx     = 301.
ny     = 321.
nbands = 31.
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


; end program
end

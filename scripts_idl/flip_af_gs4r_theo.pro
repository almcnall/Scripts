pro flip_AF_gs4r_theo,date,year,expdir,nx,ny,nbands
;post processing script for niger/amma runs 9/6/11


wdir = strcompress("/jabber/LIS/OUTPUT/"+expdir+"/NOAH32/"+year+"/"+date+"/",/remove_all)

print,wdir
cd,wdir 

files = file_search('*gs4r')
direction = 2 ;files are upsidedown

;nx     = 16.
;ny     = 11.
nyuk   = 2.

data_in  = fltarr((nx*ny)+nyuk,nbands)
data_out = fltarr(nx   ,ny    ,nbands)

deyuk=strcompress("/jabber/LIS/OUTPUT/"+expdir+"/postprocess/"+year+"/"+date+"/",/remove_all)
;file_mkdir,'deyuk'
file_mkdir,deyuk


for i=0,n_elements(files)-1 do begin

  ; open up file and read unformatted into 'data_in'
  openr,lun,files[i],/get_lun
  readu,lun,data_in
  
  ; start J FOR loop to cycle through bands and flip them upside down
  for j=0,nbands-1 do begin 
    ;tmp = data_in[0:(nx*ny)-1,j]
    tmp = data_in[1:(nx*ny),j] ;this changed on 3/8/12...I hope that this works!
    
    tmp = reform(tmp,nx,ny)
    data_out[*,*,j] = tmp
    data_out[*,*,j] = REVERSE(data_out[*,*,j],direction)
  endfor ; close J FOR loop
  close,lun
  free_lun,lun

  ; write output file in subdirectory
  cd,deyuk
  openw,lun,files[i],/get_lun
  writeu,lun,data_out
  close,lun
  free_lun,lun

  ; come back up one level
  cd, wdir
; close I FOR loop
endfor

;end program
end

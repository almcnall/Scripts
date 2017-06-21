pro flip_AF_gs4r_malawi,date,year

;scripts for processing soni's different biased and unbiased RFE2 runs
;'RFE2_UMDVeg, EXPORU'
;name   = 'RFE2_StaticRoot' ;I think that is is corn with static rooting depth
;expdir = 'EXPORS'          ;root static

;name   = 'RFE2_UMDVeg'
;expdir = 'EXPORU'

;name   = 'RFE2_StaticRoot'
;expdir = 'EXPORS'

;name   = 'RFE2_DynCrop'
;expdir = 'EXPORC'

;name   = 'RFE2Unbiased_DynCrop'
;expdir = 'EXPURC'

name   = 'RFE2Unbiased_UMDVeg'
expdir = 'EXPURU'

wdir = strcompress("/gibber/lis_data/"+name+"/output/"+expdir+"/NOAH32/"+year+"/"+date+"/",/remove_all)
print,wdir
cd,wdir 

files = file_search('*gs4r')
direction = 2 ;files are upsidedown

nx     = 31.
ny     = 77.
nbands = 9. ; soilx4, evap*2, rain, root moisture, air temp
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

;3/31/2014 clip pete's chrips down to the yemen domain so that i can use
;them in the idl wrsi.
;
;this might be the time to write a script to do this in R :)
ifile = file_search('/raid/ftp_out/products/CHIRPS-1.7/dekads/africa/*.tif')

nx = 1500
ny = 1600


yleft = (20+42)/0.05
yright = (20+54)/0.05
ybot = (40+12)/0.05
ytop = ny-((40-20)/0.05)

stack = fltarr(241,161,n_elements(ifile))
ym_stack = fltarr(121,81,n_elements(ifile))

;so i need to clip these down to the yemen domain...
for i = 0, n_elements(ifile)-1 do begin &$
 data = read_tiff(ifile[i]) &$
 data = reverse(data,2) &$
 yclip = data[yleft:yright, YBOT:YTOP] &$
 
 Y_agg = congrid(yclip,121,81) &$
 ;stack[*,*,i] = yclip &$ 
 ;make sure that these align ok and then write them out to the sandbox. looks good!
 ym_stack[*,*,i] = y_agg &$
 ofile = strcompress('/raid2/sandbox/people/mcnally/CHIRPS-1.7/dekads/yemen/'+strmid(ifile[i],48,25), /remove_all) &$
; openw,1,ofile &$
; writeu,1,y_agg &$
; close,1 &$
 print, 'writing'+ofile &$
endfor

;and clip this et to yemen too...appears to have been regridded to 0.1 degree.
ifile = file_search('/home/sandbox/people/mcnally/pet_binary/afr/dekads/*img')
ingrid = fltarr(751,801)

yleft = (20+42)/0.10
yright= (20+54)/0.10
ybot  = (40+12)/0.10
ytop = (40+20)/0.10
ympet = fltarr(121,81,n_elements(ifile))

for i = 0, n_elements(ifile)-1 do begin &$
  openr,1,ifile[i] &$
  readu,1,ingrid &$
  close,1 &$
;but for now i will just use the average dekadal PET, so stack and then average...
  ympet[*,*,i] = ingrid[yleft:yright, ybot:ytop] &$

;  ofile = strcompress('/home/sandbox/people/mcnally/pet_binary/yemen/dekads/'+strmid(ifile[i],51,10), /remove_all) &$
;  openw,1,ofile &$
;  writeu,1,ympet &$
;  close,1 &$
  print, 'writing'+ofile &$
endfor

ypetcube = reform(ympet,121,81,36,12)
ypet_avg = mean(ypetcube,dimension=4)
ofile = '/home/sandbox/people/mcnally/PET_yemen.img'
openw,1,ofile
writeu,1,ypet_avg
close,1

  
  
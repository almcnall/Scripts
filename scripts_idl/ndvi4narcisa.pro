pro ndvi4narcisa 
;
;the purpose of this program is to read those crappy txt file
;chris suggested using the readf function and the 'reformat' function but I don't know what there are yet

;put the file path in here....
ifile='/home/mcnally/ndvi_index2.txt'
ndvi=read_ascii(ifile)

index=ndvi.field1[0,*] ;this does not actually seem to be the index that joel came up with...
row=ndvi.field1[1,*]
col=ndvi.field1[2,*]
lon=ndvi.field1[3,*]
lat=ndvi.field1[4,*]

nx=828
ny=447
ndvimap=fltarr(nx,ny)

for i=0,nx-1 do begin &$
  for j=0,ny-1 do begin &$
   ndvimap[i,j]=index[j] &$
  endfor
endfor

end


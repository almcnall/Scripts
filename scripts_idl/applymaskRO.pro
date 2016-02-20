;the purpose of this program is to mask out the arid regions on the R) maps and make nice looking maps to send to the group.
;i don't think i'll end up using this one...
nx=751
ny=801

mask=intarr(nx,ny)
ifile=file_search('/jabber/sandbox/mcnally/ndvi4luce/mask_ndvi020.img')

openr,1,ifile
readu,1,mask
close,1

mask=reverse(mask,2)
mask(where(mask eq 0))=-9999

;mask out the scaled R0 using the new NDVI mask...
;so the worldclim data is at 0.01 degree..and my mask is at 0.1 degree...
x = 9001
y = 9601
ingrid=fltarr(x,y)

mask=congrid(mask,x,y)
;apply aridity mask
imap=file_search('/jabber/LIS/Data/worldclim/africa/scaled_R0/R0_??v2.img')

for i=0,n_elements(imap)-1 do begin &$
  openr,1,imap[i]  &$
  readu,1,ingrid &$
  close,1 &$
  ;temp=image(ingrid)  &$

  outgrid=ingrid*mask  &$
  temp=image(outgrid, rgb_table=4) &$
endfor  
;  ofile=strmid(imap[i],0,49)+'masked.img' & print, ofile  &$
;  openw,1,ofile   &$
;  writeu,1,outgrid   &$
;  close,1   &$
endfor;i

cbar = COLORBAR(ORIENTATION=1, $
POSITION=[0.90, 0.2, 0.95, 0.75])

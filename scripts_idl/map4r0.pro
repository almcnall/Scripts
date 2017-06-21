pro map4r0
;the purpose of this program is to make maps of the r0 transmission.
;and mask out the regions where it is too dry for transmission, using the NDVI mask.
;the mask needs to be applied before the data are scaled....go back.

indir='/jabber/LIS/Data/worldclim/africa/scaled_R0/'
ifile=file_search(indir+'R0*.img')
;mfile=file_search('/jabber/sandbox/mcnally/ndvi4luce/mask_ndvi_0.05.img')

nx=751
ny=801

ingrid=fltarr(nx,ny)
month=['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'] 
for i=0,n_elements(ifile)-1 do begin
;open the file
openr,1,ifile[i]
readu,1,ingrid
close,1

;ingrid=congrid(ingrid,mx,my)
;temp=image(ingrid*mask)
;new functions:
;size returns num dimension, nx,ny, data type (e.g. 4=float) and total size nx*ny
;ncolors=256
maxval=15
minval=-15
ingrid[0,0]=maxval
ingrid[0,1]=minval
ncolors=256
tmpgr = image(ingrid,RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),image_dimensions=[75,80], image_location=[-20,-40],$
              dimensions=[nx/10,ny/10], font_size=20)
tmpgr.rgb_table=reverse(tmpgr.rgb_table,2)
cbar = COLORBAR(ORIENTATION=1, $
POSITION=[0.90, 0.2, 0.95, 0.75])
tmpgr.title=string(month[i])
tmpgr = MAP('Geographic',LIMIT = [-40, -20, 40, 55], /overplot)
tmpgr = MAPCONTINENTS(/COUNTRIES)

endfor
print, 'hold'
end


pro MlandVchirps
;this scripr compares MERRA-land monthly precip with CHIRPS daily
;Climatological Monthly mean (Shrad will use, Princeton, GPCP and Amy will use MERRA or
;any other independent dataset)

;1. agregate CHIRPS to monthly and put in same units as MERRA (or change MERRA to mm/month rather than kg/m2/s
;have to deal with n days in a month (86400*n_days_in_month)
;2. put both dataset on the same grid. what is merra-land? 2 degree?

;we'll go with GPCP becasue it is adler from umd 
;gfile = file_search('/raid/chg-shrad/DATA/Global_Precip_data_set/GPCP/precip.mon.mean_1979-2012.nc')
;fileID = ncdf_open(gfile, /nowrite) &$
;gpcpID = ncdf_varid(fileID,'precip') &$
;ncdf_varget,fileID, gpcpID, gpcp
;4/16/2014 now adding in the arc data for daily analysis (prolly should agregate to monthly too...)

;i'll go with huffman since that is what leibman uses
;excpet that is breaks up africa stupid this one does too...huffman (110 yrs 1901-2010 i think, and I want 1981-2010
gcfile = file_search('/raid/chg-shrad/DATA/Global_Precip_data_set/GPCC/precip.mon.total.v6.nc')
fileID = ncdf_open(gcfile, /nowrite) &$
gpccID = ncdf_varid(fileID,'precip') &$
ncdf_varget,fileID, gpccID, gpcc
gpcc = reverse(gpcc,2)
left = (0+55)/0.5
right = (360-20)/0.5
bot = (50)/0.5
top = (180-50)/0.5
glb_shift=[gpcc[680:719,bot:top,960:1319],gpcc[0:110,bot:top,960:1319]]
gpc2 = reform(congrid(glb_shift,300,320,360),300,320,12,30)
gpc2(where(gpc2 lt 0)) = !values.f_nan

cdir = '/home/sandbox/chirps/v1.8/daily_downscaled_by_monthly_full_rescale/p25/'
mm = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']
m_stack = fltarr(300,320,12,30)
year = indgen(30)+1981

;make monthly chirps
for y = 0, n_elements(year)-1 do begin &$
  for m = 0,n_elements(mm)-1 do begin &$
    cfile = file_search(strcompress(cdir+string(year[y])+'/chirps.'+string(year[y])+'.'+mm[m]+'.??.tif', /remove_all)) &$
    stack = fltarr(300,320, n_elements(cfile)) &$
    for f = 0, n_elements(cfile)-1 do begin &$
      ingrid = read_tiff(cfile[f]) &$
      stack[*,*,f] = ingrid &$
    endfor &$
    m_stack[*,*,m,y] = reverse(total(stack,3),2) &$
  endfor  &$
endfor  
m_stack(where(m_stack lt 0)) = !values.f_nan

;byteorder,m_stack,/XDRTOF


;make monthly ARCs...what are the dimensions on these?
;extend the time series if it looks at all good.

adir = '/home/ARC2/daily/'
;adir = file_search('/home/sandbox/people/mcnally/ARC2/*')

mm = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']
year = indgen(30)+1984 & print, year
;maybe these are not floats...ugh, just wait and use pete's tiffs...
;a_stack = fltarr(751,801,12,n_elements(year))
a_stack = fltarr(300,320,12,n_elements(year))

ingrid = fltarr(751,801)

;ugh, there are missing days in here I guess that is ok
for y = 0, n_elements(year)-1 do begin &$
  for m = 0,n_elements(mm)-1 do begin &$
    afile = file_search(strcompress(adir+'africa_arc.'+string(year[y])+mm[m]+'??.tif', /remove_all)) &$
    if n_elements(afile) le 1 then continue &$ 
    stack = fltarr(751,801, n_elements(afile)) &$
    for f = 0, n_elements(afile)-1 do begin &$
      ingrid = read_tiff(afile[f]) &$
      stack[*,*,f] = ingrid &$
    endfor &$
    if n_elements(afile) lt 25 then stack[*,*,*] = !values.f_nan &$
    a_stack[*,*,m,y] = congrid(reverse(total(stack,3, /nan),2),300,320) &$
  endfor  &$
endfor 
 
a_stack(where(a_stack lt 0)) = !values.f_nan

;read in merra-land
lm = [31,28,31,  30,31,30,  31,31,30, 31,30,31] 
merra = fltarr(300,320, n_elements(mm),30) &$

for m = 0, n_elements(mm)-1 do begin &$
  mfile = file_search('/home/sandbox/people/mcnally/MERRA-Land/monthly/*{Nx.198{1,2,3,4,5,6,7,8,9},Nx.199?,Nx.2???}'+mm[m]+'.SUB.nc') &$
  for y = 0, 30-1 do begin &$
    fileID = ncdf_open(mfile[y], /nowrite) &$
    mlandID = ncdf_varid(fileID,'prectot') &$
    ncdf_varget,fileID, mlandID, mland  &$
    ;why does only the last month have values?
    merra[*,*,m,y] = congrid(mland* 86400 * lm[m],300,320) &$
  endfor &$
endfor

merra(where(merra lt 0))=!values.f_nan

;make a mask for merra (funny that they call it land....)
;this mask isn't working for some reason
nx=300
ny=320
diff_mo = fltarr(nx,ny,12)
for y = 0,11 do begin &$
  diff_mo[*,*,y] = mean(merra[*,*,y,*],dimension=4, /nan)-(mean(m_stack[*,*,y,*],dimension=4, /nan) ) &$
endfor
mask = total(diff_mo,3)
land = where(finite(mask), complement = ocean)
mask(ocean) = !values.f_nan
mask(land) = 1

;following liebman...
;**********1. mean annual precip***********
;******************************************
MAP_chirps = mean(total(m_stack,3, /nan), dimension=3,/nan) & help, MAP_chirps
MAP_gpc2 = mean(total(gpc2,3, /nan), dimension=3,/nan) & help, MAP_gpc2
MAP_merra = mean(total(merra,3, /nan), dimension=3,/nan) & help, MAP_merra
MAP_arc2 = mean(total(a_stack,3,/nan),dimension=3, /nan)

;subset the yemen window:
left = (20+42)/0.25
right= (20+54)/0.25
bot = (40+12)/0.25
top = (40+19)/0.25

yMAP_chirps = MAP_chirps[left:right,bot:top]
yMAP_gpc2 = MAP_gpc2[left:right,bot:top]
yMAP_merra = MAP_merra[left:right,bot:top]
yMAP_arc2 = MAP_arc2[left:right, bot:top]

yMask = mask[left:right, bot:top]

ncolors = 30
p1 = image(MAP_arc2*mask,layout = [4,1,4],RGB_TABLE=20, /current,image_dimensions=[nx/4,ny/4], image_location=[-20,-40], $ 
              dimensions=[nx,ny])
p1.title = 'MAP ARC2'
p1.min_value = 0
p1.max_value = 1500

rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
;;rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
;c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.1,0.7,0.13], font_size=20, range=[0,100])

p1 = MAP('Geographic',LIMIT = [-40, -20, 40, 55], /overplot) &$
p1.mapgrid.linestyle = 6 &$
p1.mapgrid.color = [150, 150, 150] &$
p1.mapgrid.label_show = 0 &$
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=1)
;****************************************************
;2. climatological monthly mean**********************
nx = 300
ny = 320
mm_chirps = fltarr(nx,ny,12)
mm_merra = fltarr(nx,ny,12)
mm_gpcc = fltarr(nx,ny,12)
mm_arc2 = fltarr(nx,ny,12)

for m = 0, n_elements(mm) -1 do begin &$
  mm_merra[*,*,m] = mean(merra[*,*,m,*],dimension=4) &$
  mm_chirps[*,*,m] = mean(m_stack[*,*,m,*], dimension=4) &$
  mm_gpcc[*,*,m] = mean(gpc2[*,*,m,*], dimension=4) &$
  mm_arc2[*,*,m] = mean(a_stack[*,*,m,*], dimension=4) &$
endfor

ymm_merra = mm_merra[left:right,bot:top,*]
ymm_chirps = mm_chirps[left:right,bot:top,*]
ymm_gpcc = mm_gpcc[left:right,bot:top,*]
ymm_arc2 = mm_arc2[left:right,bot:top,*]

  
ystack = reform([[  [ymm_chirps]],[[ymm_gpcc]], [[ymm_merra]], [[ymm_arc2]] ],49,29,12,4) & help, stack

stack = reform([[  [mm_chirps]],[[mm_gpcc]], [[mm_merra]], [[mm_arc2]] ],300,320,12,4) & help, ystack

month = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']
nam = ['chirp', 'gpcc', 'merra-land', 'arc2']

;plot every month for one product 
ncolors=6
nx = 49
ny = 29
for m = 0, n_elements(mm)-1 do begin &$
 ;specify which product to plot
  n=0 &$
;  p1 = image(stack[*,*,m,n]*mask,layout = [4,3,m+1],RGB_TABLE=33, /current,image_dimensions=[nx/4,ny/4], image_location=[-20,-40], $ 
;              dimensions=[nx*10,ny*10]) &$
  p1 = image(ystack[*,*,m,n]*ymask,layout = [4,3,m+1],RGB_TABLE=5, /current,image_dimensions=[nx/4,ny/4], image_location=[42,12], $ 
              dimensions=[nx*10,ny*10]) &$             
  p1.title = month[m]+' mean '+nam[n] &$
  p1.min_value = 0 &$
  p1.max_value = 30 &$
    
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = reverse(p1.rgb_table,2) & rgbdump = CONGRID(rgbdump[*,rgbind],3,256) &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [200,200,200] &$
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  if m eq 0 then c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,POSITION=[0.95, 0.2, 0.96, 0.75], taper=0,font_size=20, range=[0,100]) &$
  ;p1 = MAP('Geographic',LIMIT = [-40, -20, 40, 55], /overplot) &$
   p1 = MAP('Geographic',LIMIT = [12, 42, 19, 54], /overplot) &$
  
  
  p1.mapgrid.linestyle = 6 &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_show = 0 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=1) &$
    
  ;endfor &$
endfor

;calculate number of raindays...save more often!

cdir = '/home/sandbox/chirps/v1.8/daily_downscaled_by_monthly_full_rescale/p25/'
mm = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']
year = indgen(13)+2001
c_stack = fltarr(300,320,12,n_elements(year))

;count number of rain days 2000-2013
for y = 0, n_elements(year)-1 do begin &$
  for m = 0,n_elements(mm)-1 do begin &$
    cfile = file_search(strcompress(cdir+string(year[y])+'/chirps.'+string(year[y])+'.'+mm[m]+'.??.tif', /remove_all)) &$
    stack = fltarr(300,320, n_elements(cfile)) &$
    for f = 0, n_elements(cfile)-1 do begin &$
      ingrid = read_tiff(cfile[f]) &$
      
      ;read the daily file and flag rain/norain
      ingrid(where(ingrid gt 1, complement = no))=1 &$
      ingrid(no) = 0 &$
      stack[*,*,f] = ingrid &$
    endfor &$
    c_stack[*,*,m,y] = reverse(total(stack,3),2) &$
  endfor  &$
endfor  
nd_chirps = mean(c_stack,dimension=4) & help, nd_chirps

;read in merra and count number of rain days for the west africa window
;-20E, 17N,3N,25W - what is the weird resolution for merra again?
; double check units, not sure what daily average will look like?

;read in merra-land daily west africa
nx = 114
ny = 161
m_stack = fltarr(nx,ny, n_elements(mm),n_elements(year))
mdir = '/home/sandbox/people/mcnally/MERRA-Land/daily_subset/'
for y = 0, n_elements(year)-1 do begin &$
  for m = 0,n_elements(mm)-1 do begin &$
    mfile = file_search(strcompress(mdir+'*Nx.'+string(year[y])+mm[m]+'*.SUB.nc',/remove_all)) &$
    stack = fltarr(nx,ny,n_elements(mfile)) &$
    for f = 0, n_elements(mfile)-1 do begin &$
      fileID = ncdf_open(mfile[f], /nowrite) &$
      mlandID = ncdf_varid(fileID,'prectot') &$
      ncdf_varget,fileID, mlandID, mland  &$
      ;why does only the last month have values?
      merra = mland* 86400 &$
      merra(where(merra gt 1, complement=no))=1 &$
      merra(no)=0 &$
      stack[*,*,f] = merra &$
    endfor &$
    m_stack[*,*,m,y] = total(stack,3) &$
  endfor  &$
endfor  
nd_merra = mean(m_stack,dimension=4) & help, nd_merra 
nd_merra25 = congrid(nd_merra,300,320,12) & help, nd_merra25

;count number of rain days ARC2 2000-2013
nx = 300
ny = 320
a_stack = fltarr(nx,ny, n_elements(mm),n_elements(year))
adir = '/home/ARC2/daily/'
for y = 0, n_elements(year)-1 do begin &$
  for m = 0,n_elements(mm)-1 do begin &$
   ; cfile = file_search(strcompress(cdir+string(year[y])+'/chirps.'+string(year[y])+'.'+mm[m]+'.??.tif', /remove_all)) &$
   afile = file_search(strcompress(adir+'africa_arc.'+string(year[y])+mm[m]+'??.tif', /remove_all)) &$
   stack = fltarr(300,320, n_elements(afile)) &$
    for f = 0, n_elements(afile)-1 do begin &$
      ingrid = read_tiff(afile[f]) &$
      ;read the daily file and flag rain/norain
      ingrid(where(ingrid gt 1, complement = no))=1 &$
      ingrid(no) = 0 &$
      stack[*,*,f] = congrid(ingrid,nx,ny) &$
    endfor &$
    a_stack[*,*,m,y] = reverse(total(stack,3),2) &$
  endfor  &$
endfor  
nd_arc2 = mean(a_stack,dimension=4) & help, nd_arc2

;*****Africa comparison******
ncolors=5
nx = 300
ny = 320
for m = 0, n_elements(mm)-1 do begin &$
   ;specify which product to plot
    n=3 &$
    p1 = image(nd_arc2[*,*,m]*mask,layout = [4,3,m+1],RGB_TABLE=5, /current,image_dimensions=[nx/4,ny/4], image_location=[-20,-40], $ 
              dimensions=[nx*4,ny*4]) &$
    p1.title = month[m]+' mean '+nam[n] &$
    p1.min_value = 0 &$
    p1.max_value = 25 &$
    
    rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
    rgbdump = reverse(p1.rgb_table,2) & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
    rgbdump[*,0] = [200,200,200] &$
    p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
    if m eq 0 then c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,POSITION=[0.95, 0.2, 0.96, 0.75], taper=0,font_size=20, range=[0,100]) &$
p1 = MAP('Geographic',LIMIT = [-40, -20, 40, 55], /overplot) &$
p1.mapgrid.linestyle = 6 &$
p1.mapgrid.color = [150, 150, 150] &$
p1.mapgrid.label_show = 0 &$
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=1) &$
    
  ;endfor &$
endfor

;*****Yemen comparison******

;subset the yemen window:
left = (20+42)/0.25
right= (20+54)/0.25
bot = (40+12)/0.25
top = (40+19)/0.25

ynd_chirps = nd_chirps[left:right,bot:top,*]
ynd_merra = nd_merra25[left:right,bot:top,*]
ynd_arc2 = nd_arc2[left:right, bot:top,*]

yMask = mask[left:right, bot:top]
ncolors=5
nx = 49
ny = 29
for m = 0, n_elements(mm)-1 do begin &$
   ;specify which product to plot
    n=2 &$
    p1 = image(ynd_merra[*,*,m]*ymask,layout = [4,3,m+1],RGB_TABLE=5, /current,image_dimensions=[nx/4,ny/4], image_location=[42,12], $ 
              dimensions=[nx*4,ny*4]) &$
    p1.title = month[m]+' mean '+nam[n] &$
    p1.min_value = 0 &$
    p1.max_value = 25 &$
    
    rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
    rgbdump = reverse(p1.rgb_table,2) & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
    rgbdump[*,0] = [200,200,200] &$
    p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
    if m eq 0 then c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,POSITION=[0.95, 0.2, 0.96, 0.75], taper=0,font_size=20, range=[0,100]) &$
p1 = MAP('Geographic',LIMIT = [12, 42, 19, 54], /overplot) &$

p1.mapgrid.linestyle = 6 &$
p1.mapgrid.color = [150, 150, 150] &$
p1.mapgrid.label_show = 0 &$
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=1) &$
    
  ;endfor &$
endfor



;ok, we're in the same dimensions. now what? correlation maps?
;that one point looks good!
p1=plot(merra[180,80,0,*], /overplot)
p1=plot(m_stack[180,80,0,*], /overplot)

nx = 300
ny = 320
cormap = fltarr(nx,ny,12)*!values.f_nan
for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
    for m = 0, 12 -1 do begin &$
    cormap[x,y,m] = correlate(merra[x,y,m,*], m_stack[x,y,m,*]) &$
    endfor &$
  endfor &$
endfor

p1 = image(cormap[*,*,10], rgb_table=20, title = 'nov', layout = [3,1,3], min_value=-0.5, max_value=0.98, /current)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.1,0.7,0.13], font_size=20, range=[0,100])

;look at the climatological mean...
nx=300
ny=320
diff_mo = fltarr(nx,ny,12)
for y = 0,11 do begin &$
  diff_mo[*,*,y] = mean(merra[*,*,y,*],dimension=4)-( mean(m_stack[*,*,y,*],dimension=4) ) &$
endfor
mask = total(diff_mo,3)
land = where(finite(mask), complement = ocean)
mask(ocean) = !values.f_nan
mask(land) = 1

;Bias/ difference between MERRA_land and CHIRPS
ncolors = 40
temp = image(diff_mo[*,*,10]*mask,/current,layout = [3,1,3],RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), min_value=-300, max_value=300)
temp.title = 'nov'
c = COLORBAR(target=temp,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.1,0.7,0.13], font_size=20, range=[0,100])

;Percent of the seasonal total?
tot = mean(total(merra[*,*,*,*],3),dimension=3)
ctot = mean(total(m_stack[*,*,*,*],3),dimension=3)

m_perc = fltarr(nx,ny,12)
c_perc = fltarr(nx,ny,12)

for m = 0, 11 do begin &$
  mon = mean(merra[*,*,m,*],dimension=4) &$
  m_perc[*,*,m] = (mon/tot)*100 &$
  
  c_mon = mean(m_stack[*,*,m,*],dimension=4) &$
  c_perc[*,*,m] = (c_mon/ctot)*100 &$
endfor
 for m = 0, 11 do begin &$
 temp  = image(m_perc[*,*,m]*mask, layout = [2,1,1],rgb_table=20, min_value=0, max_value=40, title = 'merra'+month[m]) &$
 temp  = image(c_perc[*,*,m]*mask, layout = [2,1,2],rgb_table=20, min_value=0,/current, max_value=40, title = 'chirp'+month[m]) &$
 c = COLORBAR(target=temp,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.1,0.7,0.13], font_size=20, range=[0,100]) &$
 endfor
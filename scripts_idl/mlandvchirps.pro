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
;4/21/2014 - reviewing the treatment of null data, the units of merra-land and making side-by side plots
;seems like agreeing with ARC is a good start and then suggesting that explicit applications check 
;the number of raindays if that is important for the specfici application
;9/25 revisit for yemen comparisons

;these monthly totals might be interesting.
;;;;;;;;;;;;;;this file no longer exsisits....ooops. should copy to my home dir
;gcfile = file_search('/home/chg-shrad/DATA/Global_Precip_data_set/GPCC/precip.mon.total.v6.nc')
;fileID = ncdf_open(gcfile, /nowrite) &$
;gpccID = ncdf_varid(fileID,'precip') &$
;ncdf_varget,fileID, gpccID, gpcc
;gpcc = reverse(gpcc,2)
;left = (0+55)/0.5
;right = (360-20)/0.5
;bot = (50)/0.5
;top = (180-50)/0.5
;glb_shift=[gpcc[680:719,bot:top,960:1319],gpcc[0:110,bot:top,960:1319]]
;gpc2 = reform(congrid(glb_shift,300,320,360),300,320,12,30)
;gpc2(where(gpc2 lt 0)) = !values.f_nan

;read in the monthly chirps that i made from daily, yes, monthly chirps exisist
;but i wanted to make sure i was consistant for my analysis of the daily files

;*****some CHIRPS go from 1984 to 2013 per shrad's analysis
;I should probably switch to my netcdf outputs....
cfile = file_search('/home/sandbox/people/mcnally/CHIRPS_eval/chirps_mon_*');201012.bil
;data_dir = '/home/sandbox/people/mcnally/NOAH_CHIRP_MERRA/CHIRPS_YRMO/'
;nx = 294
;ny = 348
;
;startyr = 1981
;endyr = 2013
;nyrs = endyr-startyr+1
;
;;for east africa use 3-6 for yemen use 3-9
;startmo = 1
;endmo = 12
;nmos = endmo - startmo+1
;
;
;chirp = FLTARR(NX,NY,12,nyrs)
;ycnt =0
;;this loop reads in the selected months only
;for yr = startyr,endyr do begin &$
;  for i=0,nmos-1 do begin &$
;  y = yr &$
;  m = startmo + i &$
;  if m gt 12 then begin &$
;  m = m-12 &$
;  y = y+1 &$
;endif &$
;fileID = ncdf_open(data_dir+STRING(FORMAT='(''CHIRPS_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
;; fileID = ncdf_open(data_dir+STRING(FORMAT='(''CHIRPS_'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
;;RainID = ncdf_varid(fileID,'TotalPrecip_tavg') &$
;RainID = ncdf_varid(fileID,'Rainf_f_inst') &$
;ncdf_varget,fileID, RainID, RAIN &$
;;generates the seasonal total for months of interest
;chirp[*,*,m-1,ycnt] = RAIN &$
;
;;chirp[*,*,yr-startyr] = chirp[*,*,yr-startyr] + RAIN*864000 &$
;endfor &$
;  ycnt++ &$
;endfor

;m_stack = fltarr(300,320,12,30)
;year = indgen(33)+1981 & print, year
;nx = 300
;ny = 320
;ingrid = fltarr(nx,ny)
;stack = fltarr(nx,ny,n_elements(cfile)) 
;;read these into a stack then reshape to cube(month, year)
;for i = 0, n_elements(cfile)-1 do begin &$
;  openr,1,cfile[i] &$
;  readu,1,ingrid &$
;  close,1 &$
;  
;  stack[*,*,i] = ingrid &$
;endfor
;
;m_stack = reform(stack,nx,ny,12,30)
;m_stack(where(m_stack lt 0)) = !values.f_nan

;*****ARC2 goes from 1984 to 2013******
staryr = 1984
endyr  = 2013
nyrs = (endyr-startyr)+1

nx = 300
ny = 320
afile = file_search('/home/sandbox/people/mcnally/CHIRPS_eval/arc2_mon_*.bil')

ingrid = fltarr(nx,ny)
stack = fltarr(nx,ny,n_elements(afile)) 

for i = 0, n_elements(afile)-1 do begin &$
  openr,1,afile[i] &$
  readu,1,ingrid &$
  close,1 &$
  
  stack[*,*,i] = ingrid &$
endfor
a_stack = reform(stack,nx,ny,12,30)
a_stack(where(a_stack lt 0)) = !values.f_nan

;read in merra-land...eww this might be a problem...oops where did this go?
;I should probably be reading in the daily values anyway, no?
;read in merra-land monthly...
lm = [31,28,31,  30,31,30,  31,31,30, 31,30,31] 
merra = fltarr(300,320,12,30) &$
mm = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']

;make a chirps mask for merra and arc -- this looks fine.

mask = mean(total(a_stack,3, /nan),dimension=3, /nan) & help, mask
land = where(mask gt 0, complement = ocean)
mask(ocean) = !values.f_nan
mask(land) = 1

for m = 0, n_elements(mm)-1 do begin &$
  mfile = file_search('/home/sandbox/people/mcnally/MERRA-Land/monthly/*{Nx.198{4,5,6,7,8,9},Nx.199?,Nx.2???}'+mm[m]+'.SUB.nc') &$
  for y = 0, 30-1 do begin &$
    fileID = ncdf_open(mfile[y], /nowrite) &$
    mlandID = ncdf_varid(fileID,'prectot') &$
    ncdf_varget,fileID, mlandID, mland  &$
    merra25 = congrid(mland* 86400 * lm[m],300,320) &$
    ;why does only the last month have values?
    merra[*,*,m,y] = merra25*mask &$
  endfor &$
endfor

merra(where(merra lt 0))=!values.f_nan

;following liebman...
;**********1. mean annual precip***********
;******************************************
;MAP_chirps = mean(total(m_stack,3, /nan), dimension=3,/nan) & help, MAP_chirps
;MAP_gpc2 = mean(total(gpc2,3, /nan), dimension=3,/nan) & help, MAP_gpc2
MAP_merra = mean(total(merra,3, /nan), dimension=3,/nan) & help, MAP_merra
MAP_arc2 = mean(total(a_stack,3,/nan),dimension=3, /nan)


;Yemen Highland window
ymap_ulx = 43. & ymap_lrx = 45.
ymap_uly = 17. & ymap_lry = 12.5

ea1 = 22
ea2 = 11.75

af1=-20
af2=-40

;this is not quite right yet
yulx = (ymap_ulx-af1)*4.  & ylrx = (ymap_lrx-af1)*4.-1
yuly = (ymap_uly-af2)*4.   & ylry = (ymap_lry-af2)*4.-1

;yemen box 20.5 x 48
hNX = hlrx - hulx + 1.5
hNY = huly -hlry + 2

;Africa mean annual rainfall figure
ncolors=12
p1 = image(congrid(mean(chirp, dimension=3, /NAN), NX*3, NY*3), image_dimensions=[nx/10,ny/10],image_location=[map_ulx+0.25,map_lry+0.5], $
  RGB_TABLE=64)  &$

;subset the yemen window:
left = (20+42)/0.25
right= (20+54)/0.25
bot = (40+12)/0.25
top = (40+19)/0.25

;yMAP_chirps = MAP_chirps[left:right,bot:top]
;yMAP_gpc2 = MAP_gpc2[left:right,bot:top]
yMAP_merra = MAP_merra[left:right,bot:top]
yMAP_arc2 = MAP_arc2[left:right, bot:top]

yMask = mask[left:right, bot:top]

ncolors = 30
p1 = image(MAP_merra*mask,layout = [4,1,4],RGB_TABLE=20, /current,image_dimensions=[nx/4,ny/4], image_location=[-20,-40], $ 
              dimensions=[nx,ny])
p1.title = 'MAP GPCC'
p1.min_value = 0
p1.max_value = 1500

rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
;;rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.1,0.7,0.13], font_size=20, range=[0,100])

p1 = MAP('Geographic',LIMIT = [-40, -20, 40, 55], /overplot) &$
p1.mapgrid.linestyle = 6 &$
p1.mapgrid.color = [150, 150, 150] &$
p1.mapgrid.label_show = 0 &$
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=1)

;****************************************************
;2. climatological monthly mean**********************
;****I think that this is part of pete's usual thing...its always good to repeat work
;especially when some people want certain results to be true :)
;plus i want it for yemen anyway
nx = 300
ny = 320
mm_chirps = fltarr(nx,ny,12)
mm_merra = fltarr(nx,ny,12)
mm_gpcc = fltarr(nx,ny,12)
mm_arc2 = fltarr(nx,ny,12)

for m = 0, n_elements(mm) -1 do begin &$
  mm_merra[*,*,m] = mean(merra[*,*,m,*],dimension=4,/nan) &$
  mm_chirps[*,*,m] = mean(m_stack[*,*,m,*], dimension=4,/nan) &$
  mm_gpcc[*,*,m] = mean(gpc2[*,*,m,*], dimension=4,/nan) &$
  mm_arc2[*,*,m] = mean(a_stack[*,*,m,*], dimension=4,/nan) &$
endfor

ymm_merra = mm_merra[left:right,bot:top,*]
ymm_chirps = mm_chirps[left:right,bot:top,*]
ymm_gpcc = mm_gpcc[left:right,bot:top,*]
ymm_arc2 = mm_arc2[left:right,bot:top,*]

  
ystack = reform([[  [ymm_chirps]],[[ymm_arc2]],[[ymm_gpcc]], [[ymm_merra]]  ],49,29,12,4) & help, stack

stack = reform([[  [mm_chirps]],[[mm_arc2]],[[mm_gpcc]], [[mm_merra]] ],300,320,12,4) & help, ystack

month = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']
nam = ['chirps', 'arc2','gpcc', 'merra-land']

;**********Horn of Africa*************
;subsetters...
;subset the Horn window:
hleft = (20+26)/0.25
hright= ((20+55)/0.250)-1
hbot = (40-12)/0.25
htop = ((40+25)/0.25)

hnx = 116
hny = 149

;one product, 12 months
w=window()
for m = 0, n_elements(mm)-1 do begin &$
  for n = 0,1 do begin &$   
   ;specify which product to plot
    if n eq 0 then p=1 else p=2 &$
    p1 = image(stack[HLEFT:HRIGHT,HBOT:HTOP,m,n]*mask[hleft:hright, hbot:htop],layout = [2,1,p],RGB_TABLE=5, /current,image_dimensions=[hnx/4,hny/4], image_location=[26,-12], $ 
              dimensions=[hnx*2,hny*2]) &$
    p1.title = month[m]+' mean '+nam[n] &$
    p1.min_value = 0 &$
    p1.max_value = 500 &$
    
    rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
    rgbdump = reverse(p1.rgb_table,2) & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
    rgbdump[*,0] = [200,200,200] &$
    p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
    if n eq 0 then c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.1,0.7,0.13], taper=0,font_size=20, range=[0,100]) &$
    
;p1 = MAP('Geographic',LIMIT = [-40, -20, 40, 55], /overplot) &$
; p1 = MAP('Geographic',LIMIT = [12, 42, 19, 54], /overplot) &$
p1 = MAP('Geographic',LIMIT = [-12, 26, 25, 55], /overplot) &$


p1.mapgrid.linestyle = 6 &$
p1.mapgrid.color = [150, 150, 150] &$
p1.mapgrid.label_show = 0 &$
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=1) &$
    
  endfor &$
    w=window() &$
endfor


;****************************************************************************
;calculate number of raindays...save more often!
;don't forget to close your netcdf files

;make a new mask for this part, rather than the merra mask.

cdir = '/home/sandbox/chirps/v1.8/daily_downscaled_by_monthly_full_rescale/p25/'
mm = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']
year = indgen(13)+2001
c_stack = fltarr(300,320,12,n_elements(year))

month = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']
nam = ['chirp', 'arc2','gpcc', 'merra-land']

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

;not the best mask due to splotch in north africa where it hasn't rained in 13 yrs?
nd_chirps = mean(c_stack,dimension=4) & help, nd_chirps
mask = total(total(c_stack,4),3) & help, mask
land = where(mask gt 0, complement=water)
mask(land)=1
mask(water)=!values.f_nan
;read in merra and count number of rain days for the west africa window
;-20E, 17N,3N,25W - what is the weird resolution for merra again?
; double check units, not sure what daily average will look like?

;read in merra-land daily
;i think i need to check my units here. when i total it does it look like the monthly totals??

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
      ncdf_close,fileID &$
      ;why does only the last month have values?
      ;not sure this is correct units conversion
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


;**********Horn of Africa*************
;subsetters...
;subset the Horn window:
hleft = (20+26)/0.25
hright= ((20+55)/0.250)-1
hbot = (40-12)/0.25
htop = ((40+25)/0.25)

hnx = 116
hny = 149
nd_both= reform([[[nd_chirps]],[[nd_arc2]]],300,320,12,2)

;one product, 12 months
w=window()
for m = 0, n_elements(mm)-1 do begin &$
  for n = 0,1 do begin &$   
   ;specify which product to plot
    if n eq 0 then p=1 else p=2 &$
    p1 = image(nd_both[HLEFT:HRIGHT,HBOT:HTOP,m,n]*mask[hleft:hright, hbot:htop],layout = [2,1,p],RGB_TABLE=5, /current,image_dimensions=[hnx/4,hny/4], image_location=[26,-12], $ 
              dimensions=[hnx*2,hny*2]) &$
    p1.title = month[m]+' mean '+nam[n] &$
    p1.min_value = 0 &$
    p1.max_value = 25 &$
    
    rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
    rgbdump = reverse(p1.rgb_table,2) & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
    rgbdump[*,0] = [200,200,200] &$
    p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
    if n eq 0 then c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.1,0.7,0.13], $
                                 taper=0,font_size=20, range=[0,100],title='n_raindays') &$
    
;p1 = MAP('Geographic',LIMIT = [-40, -20, 40, 55], /overplot) &$
; p1 = MAP('Geographic',LIMIT = [12, 42, 19, 54], /overplot) &$
p1 = MAP('Geographic',LIMIT = [-12, 26, 25, 55], /overplot) &$


p1.mapgrid.linestyle = 6 &$
p1.mapgrid.color = [150, 150, 150] &$
p1.mapgrid.label_show = 0 &$
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=1) &$
    
  endfor &$
    w=window() &$
endfor

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


;**********Horn of Africa*************
;subsetters...
;subset the Horn window:
hleft = (20+23)/0.25
hright= ((20+55)/0.25)-1
hbot = (40-12)/0.25
htop = ((40+40)/0.25)-1

hnx = 128
hny = 208

for m = 0, n_elements(mm)-1 do begin &$
   ;specify which product to plot
    n=2 &$
    p1 = image(nd_merra25[HLEFT:HRIGHT,HBOT:HTOP,m]*mask[hleft:hright, hbot:htop],layout = [4,3,m+1],RGB_TABLE=5, /current,image_dimensions=[hnx/4,hny/4], image_location=[23,-12], $ 
              dimensions=[hnx*4,hny*4]) &$
    p1.title = month[m]+' mean '+nam[n] &$
    p1.min_value = 0 &$
    p1.max_value = 25 &$
    
    rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
    rgbdump = reverse(p1.rgb_table,2) & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
    rgbdump[*,0] = [200,200,200] &$
    p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
    if m eq 0 then c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,POSITION=[0.95, 0.2, 0.96, 0.75], taper=0,font_size=20, range=[0,100]) &$
;p1 = MAP('Geographic',LIMIT = [-40, -20, 40, 55], /overplot) &$
; p1 = MAP('Geographic',LIMIT = [12, 42, 19, 54], /overplot) &$
p1 = MAP('Geographic',LIMIT = [-12, 23, 40, 55], /overplot) &$


p1.mapgrid.linestyle = 6 &$
p1.mapgrid.color = [150, 150, 150] &$
p1.mapgrid.label_show = 0 &$
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=1) &$
    
  ;endfor &$
endfor
;****************************************************************************



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
 
 ;might need this later for yemen specs
 for m = 0, n_elements(mm)-1 do begin &$
 ;specify which product to plot
  n=0 &$
  p1 = image(stack[*,*,m,n]*mask,layout = [4,3,m+1],RGB_TABLE=5, /current,image_dimensions=[nx/10,ny/10], image_location=[-20,-40], $ 
              dimensions=[nx*4,ny*4]) &$
;  p1 = image(ystack[*,*,m,n]*ymask,layout = [4,3,m+1],RGB_TABLE=5, /current,image_dimensions=[nx/4,ny/4], image_location=[42,12], $ 
;              dimensions=[nx*10,ny*10]) &$             
  p1.title = month[m]+' mean '+nam[n] &$
  p1.min_value = 0 &$
  ;p1.max_value = 30 &$
   p1.max_value=500 &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = reverse(p1.rgb_table,2) & rgbdump = CONGRID(rgbdump[*,rgbind],3,256) &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [200,200,200] &$
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  if m eq 0 then c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,POSITION=[0.95, 0.2, 0.96, 0.75], taper=0,font_size=20, range=[0,100]) &$
  p1 = MAP('Geographic',LIMIT = [-40, -20, 40, 55], /overplot) &$
  ; p1 = MAP('Geographic',LIMIT = [12, 42, 19, 54], /overplot) &$
  
  
  p1.mapgrid.linestyle = 6 &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_show = 0 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=1) &$
    
  ;endfor &$
endfor

;************************************
;one product, 12 months
for m = 0, n_elements(mm)-1 do begin &$  
   ;specify which product to plot
    n=0 &$
    p1 = image(stack[HLEFT:HRIGHT,HBOT:HTOP,m,n]*mask[hleft:hright, hbot:htop],layout = [4,3,m+1],RGB_TABLE=5, /current,image_dimensions=[hnx/4,hny/4], image_location=[26,-12], $ 
              dimensions=[hnx*4,hny*4]) &$
    p1.title = month[m]+' mean '+nam[n] &$
    p1.min_value = 0 &$
    p1.max_value = 500 &$
    
    rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
    rgbdump = reverse(p1.rgb_table,2) & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
    rgbdump[*,0] = [200,200,200] &$
    p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
    if m eq 0 then c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,POSITION=[0.95, 0.2, 0.96, 0.75], taper=0,font_size=20, range=[0,100]) &$
;p1 = MAP('Geographic',LIMIT = [-40, -20, 40, 55], /overplot) &$
; p1 = MAP('Geographic',LIMIT = [12, 42, 19, 54], /overplot) &$
p1 = MAP('Geographic',LIMIT = [-12, 26, 25, 55], /overplot) &$


p1.mapgrid.linestyle = 6 &$
p1.mapgrid.color = [150, 150, 150] &$
p1.mapgrid.label_show = 0 &$
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=1) &$
    
  ;endfor &$
endfor


;side by side months for yemen.p1 = MAP('Geographic',LIMIT = [12, 42, 19, 54], /overplot)
;one month x 2 products, ugh i don't know how to code this. by hand first.
;for m = 0,12-1 do begin &$
   ;specify month
    m=4
   ;specify which product to plot
    n=3 &$
    if n eq 0 then p=1 else p=2 
    p1 = image(ystack[*,*,m,n]*ymask,layout = [2,1,p],RGB_TABLE=5, /current,image_dimensions=[49/4,29/4], image_location=[42,12], $ 
              dimensions=[49*4,29*2]) &$
    p1.title = month[m]+' mean '+nam[n] &$
    p1.min_value = 0 &$
    p1.max_value = 20 &$
    
    rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
    rgbdump = reverse(p1.rgb_table,2) & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
    rgbdump[*,0] = [200,200,200] &$
    p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
    if n eq 0 then c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.1,0.7,0.13], taper=0,font_size=20, range=[0,100], title='mm/month') &$
;p1 = MAP('Geographic',LIMIT = [-40, -20, 40, 55], /overplot) &$
 p1 = MAP('Geographic',LIMIT = [12, 42, 19, 54], /overplot) &$
;p1 = MAP('Geographic',LIMIT = [-12, 23, 40, 55], /overplot) &$


p1.mapgrid.linestyle = 6 &$
p1.mapgrid.color = [150, 150, 150] &$
p1.mapgrid.label_show = 0 &$
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=1) &$
    
  ;endfor &$
endfor
 
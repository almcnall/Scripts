pro yemen_station
;this script compares the gridded rainfall to the stations from the farquarhson paper
;also plots the mean annual total for CHIRPS and ARC2
; now it looks like the problem might be with the LIS 6-hrly precip
; maybe I need to look at the tot_precip
; 11/5/14 revisiting for the meetings coming up: 
; how do these data compare with (1)CHIRPS stations (2) Karim stations (3) pdf stations (4) WorldCLim
; 11/7/14 use this script to re-organize the CHG rainfall stations. 


;these data are from chirps_daily_0.25 degree different from 6-hrly LIS outputs
cfile = file_search('/home/sandbox/people/mcnally/CHIRPS_eval/chirps_mon_*');201012.bil
;m_stack = fltarr(300,320,12,30)
;year = indgen(33)+1981 & print, year
nx = 300
ny = 320
ingrid = fltarr(nx,ny)
stack = fltarr(nx,ny,n_elements(cfile)) 
;read these into a stack then reshape to cube(month, year)
for i = 0, n_elements(cfile)-1 do begin &$
  openr,1,cfile[i] &$
  readu,1,ingrid &$
  close,1 &$
  
  stack[*,*,i] = ingrid &$
endfor

m_stack = reform(stack,nx,ny,12,33)
m_stack(where(m_stack lt 0)) = !values.f_nan

;*****ARC2 goes from 1984 to 2013******
;readin monthly ARCs...we are missing a month somewheres...
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

;;;;;;;;plot yemen annual rainfall;;;;;;;;;;;;
;africa window

;East Africa WRSI/Noah window
map_ulx = -20.  & map_lrx = 55
map_uly = 40  & map_lry = -40

;broader yemen window
hmap_ulx = 42.5 & hmap_lrx = 51.
hmap_uly = 18 & hmap_lry = 12.5

hulx = (hmap_ulx-20)*4.  & hlrx = (hmap_lrx-20)*4.-1
huly = (40+hmap_uly)*4.   & hlry = (40+hmap_lry)*4.-1

;yemen box 20.5 x 48
hNX = hlrx - hulx + 1.5
hNY = huly -hlry + 2

;YEMEN mean annual rainfall figure
tot = mean(total(a_stack,3,/nan),dimension=3,/nan)
ncolors=24
p1 = image(congrid(tot, NX*3, NY*3), image_dimensions=[nx/4,ny/4],image_location=[map_ulx,map_lry], $
  RGB_TABLE=64)  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.title = 'avg rainfall' &$
  p1.max_value=800
c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,font_size=18) &$
 ; m1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot) &$
  m1 = MAP('Geographic',LIMIT = [hmap_lry,hmap_ulx,hmap_uly ,hmap_lrx], /overplot) &$

  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  m1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0, 0, 0], THICK = 2)

;***GPCC*****
;Shrad's netcdf version
gcfile = file_search('/home/chg-shrad/DATA/Precipitation_Global/GPCC/precip.mon.total.v6.nc')
fileID = ncdf_open(gcfile, /nowrite) &$
gpccID = ncdf_varid(fileID,'precip') &$
ncdf_varget,fileID, gpccID, gpcc
gpcc = reverse(gpcc,2)
left = (0+55)/0.5
right = (360-20)/0.5
bot = (50)/0.5
top = (180-50)/0.5
glb_shift=[gpcc[680:719,bot:top,960:1319],gpcc[0:110,bot:top,960:1319]]
;uh, why does this show only 30 yrs of data?
gpc2 = reform(congrid(glb_shift,300,320,1320),300,320,12,110)
gpc2(where(gpc2 lt 0)) = !values.f_nan




;so these are what I want to plot....
ab = mean(a_stack[bxind,byind,*,*],dimension=4);187mm
as = mean(a_stack[saxind,sayind,*,*],dimension=4);574
az = mean(a_stack[zxind,zyind,*,*],dimension=4);182
at = mean(a_stack[txind,tyind,*,*],dimension=4);415mm
ad = mean(a_stack[dxind,dyind,*,*],dimension=4);280mm
aa = mean(a_stack[axind,ayind,*,*],dimension=4);59mm
asy = mean(a_stack[sxind,syind,*,*],dimension=4);88mm

print, transpose([ab,as,az,at,ad,aa,asy])

cb = mean(m_stack[bxind,byind,*,*],dimension=4);187mm
cs = mean(m_stack[saxind,sayind,*,*],dimension=4);574
cz = mean(m_stack[zxind,zyind,*,*],dimension=4);182
ct = mean(m_stack[txind,tyind,*,*],dimension=4);415mm
cd = mean(m_stack[dxind,dyind,*,*],dimension=4);280mm
ca = mean(m_stack[axind,ayind,*,*],dimension=4);59mm
csy = mean(m_stack[sxind,syind,*,*],dimension=4);88mm

print, transpose([cb,cs,cz,ct,cd,ca,csy])

gb = mean(gpc2[bxind,byind,*,*],dimension=4)
gs = mean(gpc2[saxind,sayind,*,*],dimension=4)
gz = mean(gpc2[zxind,zyind,*,*],dimension=4)
gtz = mean(gpc2[txind,tyind,*,*],dimension=4)
gd = mean(gpc2[dxind,dyind,*,*],dimension=4)
ga = mean(gpc2[axind,ayind,*,*],dimension=4)
gsy = mean(gpc2[sxind,syind,*,*],dimension=4)

print, transpose([gb,gs,gz,gtz,gd,ga,gsy])

p1 = plot(bani_uwair, layout=[1,4,1],yrange=[0,50])
p2 = plot(ab, layout=[1,4,2], /CURRENT, yrange=[0,50])
p3 = plot(cb, layout=[1,4,3], /CURRENT,yrange=[0,50])
p4 = plot(gb, layout=[1,4,4], /CURRENT,yrange=[0,50])
p1.title = 'bani_uwair: station, arc2, chirps,gpcc'

p1 = plot(zabid, layout=[1,4,1])
p2 = plot(az, layout=[1,4,2], /CURRENT)
p3 = plot(cz, layout=[1,4,3], /CURRENT)
p4 = plot(gz, layout=[1,4,4], /CURRENT)
yrange=[0,100]
p1.yrange=yrange
p2.yrange=yrange
p3.yrange=yrange
p4.yrange=yrange
p1.title = 'Zabid: station, arc2, chirps,gpcc'


p1 = plot(taiz, layout=[1,4,1])
p2 = plot(at, layout=[1,4,2], /CURRENT)
p3 = plot(ct, layout=[1,4,3], /CURRENT)
p4 = plot(gtz, layout=[1,4,4], /CURRENT)
yrange=[0,120]
p1.yrange=yrange
p2.yrange=yrange
p3.yrange=yrange
p4.yrange=yrange
p1.title = 'Taiz: station, arc2, chirps,gpcc'

p1 = plot(dhalla, layout=[1,4,1])
p2 = plot(ad, layout=[1,4,2], /CURRENT)
p3 = plot(cd, layout=[1,4,3], /CURRENT)
p4 = plot(gd, layout=[1,4,4], /CURRENT)
yrange=[0,120]
p1.yrange=yrange
p2.yrange=yrange
p3.yrange=yrange
p4.yrange=yrange
p1.title = 'Dhalla: station, arc2, chirps,gpcc'

p1 = plot(aden, layout=[1,4,1])
p2 = plot(aa, layout=[1,4,2], /CURRENT)
p3 = plot(ca, layout=[1,4,3], /CURRENT)
p4 = plot(ga, layout=[1,4,4], /CURRENT)
yrange=[0,20]
p1.yrange=yrange
p2.yrange=yrange
p3.yrange=yrange
p4.yrange=yrange
p1.title = 'Aden: station, arc2, chirps,gpcc'

p1 = plot(seiyun, layout=[1,4,1])
p2 = plot(asy, layout=[1,4,2], /CURRENT)
p3 = plot(csy, layout=[1,4,3], /CURRENT)
p4 = plot(gsy, layout=[1,4,4], /CURRENT)
yrange=[0,30]
p1.yrange=yrange
p2.yrange=yrange
p3.yrange=yrange
p4.yrange=yrange
p1.title = 'seiyun: station, arc2, chirps,gpcc'




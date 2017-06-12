mask4idlWRSI
;7/7/2014 make this mask in hopes of speeding up the WRSI runs
;and split up the giant sim files so that i don't use up too much memory
;
;would it be faster if these were not all held in memory? how long does 1 run take?
 ;ifile = file_search('/home/sandbox/people/mcnally/ubfe_2005_sim_720.350.36.100.bin')
ifile = file_search('/home/sandbox/people/mcnally/ubfe_2002_sim_720.350.36.100.bin')

map_ulx = -20.00 & map_lrx = 52
map_uly =  30.00 & map_lry = -5
;greg's way of nx, ny-ing
ulx = (180.+map_ulx)*10. & lrx = (180.+map_lrx)*10.
uly = (50.-map_uly)*10. & lry = (50.-map_lry)*10.
gNX = lrx - ulx 
gNY = lry - uly

NX = 720
NY = 350
ND = 36
NS = 100

ingrid = fltarr(nx,ny,nd,ns)
openr,1,ifile
readu,1,ingrid
close,1

;***rainfall mask****************
;make it, save it, then read it back in...
mask = mean(total(ingrid,3),dimension=3)

;mask out countries east of Chad
mx = 180+30*10
mask[480:719,*]=!values.f_nan

p1 = image(mask, image_dimensions=[NX/10,NY/10], image_location=[map_ulx,map_lry], dimensions=[nx,ny], $
  rgb_table=4, title = 'mask')
c = colorbar(target=p1,orientation=0,/border_on, $
  position=[0.3,0.04,0.7,0.07], font_size=24)
p1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly, map_lrx], /overplot)
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])


mask(where(mask le 40.)) = !values.f_nan
mask(where(mask gt 40.)) = 10000
ofile = '/home/chg-mcnally/RAINmask.img'
openw,1,ofile
writeu,1,mask
close,1

;*******also break up these simulations so that they are not all in the same file
for i = 0,NS-1 do begin &$
  out = ingrid[*,*,*,i] &$
  ofile = strcompress('/home/sandbox/people/mcnally/ubrf_sim/ubrf_2002_sim_720.350.36.'+string(format='(I2.2)',i)+'.bin', /remove_all) & print, ofile  &$
  openw,1,ofile  &$
  writeu,1,out  &$
  close,1  &$
endfor

;******do the same thing for the soil moisture simulations****
;why am I not using: /home/chg-mcnally/ECV_MW2005_scaled4WRSI.img?
;                    /home/chg-mcnally/SM0X2_2005_scaled4WRSI.img? was this the old version?
;                    I think I must have changed some files names so that I can't trace this all back...
;ifile = file_search('/home/sandbox/people/mcnally/NOAH1m_2002_sim_720.350.36.100.bin')
;ifile = file_search('/home/sandbox/people/mcnally/NOAH1m_2005_sim_720.350.36.100.bin')
;ifile = file_search('/home/sandbox/people/mcnally/NOAH1m_2005_sim_720.350.36.100.bin')
ifile = file_search('/home/sandbox/people/mcnally/ECVMWorg_2002_sim_720.350.36.100.bin'); is this right?

map_ulx = -20.00 & map_lrx = 52
map_uly =  30.00 & map_lry = -5
;greg's way of nx, ny-ing
ulx = (180.+map_ulx)*10. & lrx = (180.+map_lrx)*10.
uly = (50.-map_uly)*10. & lry = (50.-map_lry)*10.
gNX = lrx - ulx
gNY = lry - uly

NX = 720
NY = 350
ND = 36
NS = 100

ingrid = fltarr(nx,ny,nd,ns)
openr,1,ifile
readu,1,ingrid
close,1

;I might want to check the mean and stddev against the WRSI PAW...looks like I did the scaling in "scaleNoah4wrsi.pro"
file = file_search('/home/sandbox/people/mcnally/wrsiPAW_grid_2002_750.350.sim100.img') & print, file

grid = fltarr(nx,ny,22,ns)
openr,1,file
readu,1,grid
close,1


for i = 0,NS-1 do begin &$
  out = ingrid[*,*,*,i] &$
  ofile = strcompress('/home/sandbox/people/mcnally/MWSM_sim/ECVSM_2002_sim_720.350.36.'+string(format='(I2.2)',i)+'.bin', /remove_all) & print, ofile  &$
  openw,1,ofile  &$
  writeu,1,out  &$
  close,1  &$
endfor

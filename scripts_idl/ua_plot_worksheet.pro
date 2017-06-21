UA_plot_worksheet

;ok, so now what do i do with these outputs now that i have them?
;Q1. We know that we perturbed rainfall by 20% how did that impact the R-WRSI two different years in sengal?
;The mean/standard deviation of the PAW and NOAH should match. 
;10/19 revisit for revisions

;ifile = file_search('/home/sandbox/people/mcnally/wrsiSM_grid_2005_750.350.sim100.img')
;ifile = file_search('/home/sandbox/people/mcnally/wrsiSM_grid_2002_750.350.sim100.img')

ifile2 = file_search('/home/sandbox/people/mcnally/wrsiSM_grid_2002_750.350.sim100.img')
ifile5 = file_search('/home/sandbox/people/mcnally/wrsiSM_grid_2005_750.350.sim100.img')

map_ulx = -20.00 & map_lrx = 52
map_uly =  30.00 & map_lry = -5
;greg's way of nx, ny-ing
ulx = (180.+map_ulx)*10. & lrx = (180.+map_lrx)*10.
uly = (50.-map_uly)*10. & lry = (50.-map_lry)*10.
gNX = lrx - ulx
gNY = lry - uly

NX = 720
NY = 350
NS = 100

ingrid2 = fltarr(nx,ny,ns)
openr,1,ifile2
readu,1,ingrid2
close,1


ingrid5 = fltarr(nx,ny,ns)
openr,1,ifile5
readu,1,ingrid5
close,1
;if we perturb the inputs by 20% what is the range of outputs that we get?
;how does this differ between the wet (2005) and dry (2002) year in Sengal and other places?
;eoswrsi = ingrid
;map the standard deviation of the simulations:
eosSTD2 = fltarr(nx,ny)
eosSTD5 = fltarr(nx,ny)

for x = 0,nx-1 do begin &$
  for y = 0, ny-1 do begin &$
  a = where(finite(ingrid2[X,Y,*]), count)  &$
  if count eq 0 then continue &$
  eosSTD2[x,y] = stddev(ingrid2[x,y,*])&$
  eosSTD5[x,y] = stddev(ingrid5[x,y,*])&$

endfor &$
endfor



;zoom in on sahel:
lry = 2
ulx = -20
uly = 18
lrx = 30

p1 = image(eosSTD2, image_dimensions=[NX/10,NY/10], layout = [1,2,1], image_location=[map_ulx,map_lry], dimensions=[nx,ny], $
  rgb_table=4, title = 'standard deviation with soil moisture perturbations 2002', max_value=5)
  
p1 = image(eosSTD5, image_dimensions=[NX/10,NY/10], layout = [1,2,2], image_location=[map_ulx,map_lry], dimensions=[nx,ny], $
  rgb_table=4, title = 'standard deviation with soil moisture perturbations 2005', max_value=5, /CURRENT)
  
  tmpclr = p1.rgb_table
  tmpclr[*,0] = [211,211,211]
  p1.rgb_table = tmpclr
c = colorbar(target=p1,orientation=0,/border_on, $
  position=[0.3,0.04,0.7,0.07], font_size=24)
p1 = MAP('Geographic',LIMIT = [lry,ulx,uly,lrx], /overplot)
p1.mapgrid.linestyle = 'none'
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

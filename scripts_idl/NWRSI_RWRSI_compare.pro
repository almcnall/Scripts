;compare RFE and N-SM WRSI 3/13/2013
;
nfile = file_search('/jabber/chg-mcnally/EOS_WRSI_NDVI2001_2011.img')
rfile = file_search('/jabber/chg-mcnally/EOS_WRSI_RFE2001_2011.img')

nx = 720
ny = 350
nz = 12

ngrid = fltarr(nx,ny,nz)
rgrid = fltarr(nx,ny,nz-1)

openr,1,nfile
readu,1,ngrid
close,1

openr,1,rfile
readu,1,rgrid
close,1

diff = fltarr(nx,ny,nz-1)
for i = 0,nz-3 do begin &$
  diff[*,*,i] = rgrid[*,*,i] - ngrid[*,*,i] &$
  ;temp = image(diff[*,*,i], rgb_table=6, title = string(i)) &$
  mve, rgrid[*,*,i] &$
  ;mve, ngrid[*,*,i] &$
endfor

avgdiff = mean(diff, dimension = 3, /nan)

avgdiff(where(avgdiff eq 0)) = !values.f_nan
avgdiff(where(avgdiff gt 50)) = 50
avgdiff(where(avgdiff lt -50)) = -50

p1 = image(avgdiff, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
            RGB_TABLE=4, title = 'Avg Difference RFE-NDVI')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])


;eak! this doesn't look anything like the EROS WRSI -- maybe the SOS matters that much. This is fixed SOS.
p1 = image(rgrid[*,*,3], image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
            RGB_TABLE=make_wrsi_cmap(),MIN_VALUE=0, title = '2004 RFE_PAW WRSI')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
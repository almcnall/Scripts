

;the old SOS map
nx = 720
ny = 350
nz = 12

ifile = file_search('/home/mcnally/regionmasks/SOSsahel.img')
sosgrid = bytarr(nx,ny)

openr,1,ifile
readu,1,sosgrid
close,1

;check new SOS map

ingrid = fltarr(nx,ny,nz)
qstack = fltarr(nx,ny,nz,3)
ifile = file_search('/jabber/chg-mcnally/SOSsahel_q*.csv')

for i = 0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[i] &$
  readu,1,ingrid &$
  close,1 &$

  qstack[*,*,*,i] = ingrid &$
endfor 

;what is the variance (0,1,2...or more?)
i=0
varmap = variance(qstack[*,*,i,*],dimension=4)
varmap(where(varmap gt 10))=10
p1 = image(varmap,rgb_table=4)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)

qstack(where(qstack gt 25))=!values.F_NAN
diff = fltarr(nx,ny,nz)
for i = 0,12 -1 do begin &$
  diff[*,*,i] = qstack[*,*,i,1]-qstack[*,*,i,2] &$
  diff(where(diff gt 8))=0. &$
endfor

p1 = image(mean(diff,dimension=3), image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
            RGB_TABLE=4, title = '2001 Diff in SOS')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)

p1 = image(ingrid[*,*,0], image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
            RGB_TABLE=make_wrsi_cmap(),MIN_VALUE=0, title = '2004 RFE_PAW WRSI')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
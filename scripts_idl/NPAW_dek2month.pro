pro NPAW_dek2month
;the purpose of this script is to get the average NPAW/RPAW for each month...then i can use this to correlate (anomalies?) with NoahSM

;rfile = file_search('/jabber/chg-mcnally/sahel_ubRFE_PAW36_2001-2012_LGP_WHC_PET.img')
;nfile = file_search('/jabber/chg-mcnally/sahel_NPAW_2001_2012_PET_DYNSOS.img')
;nfile = file_search('/jabber/chg-mcnally/sahel_NDVI_AET36_2001-2012_LGP_WHC.img');this files is bad.
;rfile = file_search('/jabber/chg-mcnally/sahel_ubRFE_AET36_2001-2012_LGP_WHC.img');this files is bad.
rfile = file_search('/jabber/chg-mcnally/sahel_SM01_AET36_2001-2012_LGP_WHC.img');this files is bad.

;***can i make the insitu data monthly too?********
;added this 6/27/2013
ifile = file_search('/jabber/chg-mcnally/AMMASOIL/AMMA2013/dekads/Agoufou*{0.3,0.4,0.6}*csv')

A103 = read_csv(ifile[0])
A203 = read_csv(ifile[1])
A304 = read_csv(ifile[2])
A106 = read_csv(ifile[3])
A206 = read_csv(ifile[4])
aarray = transpose([[a103.field1],[a203.field1],[a304.field1],[a106.field1],[a206.field1]]) & help, aarray

ifile = file_search('/jabber/chg-mcnally/AMMASOIL/AMMA2013/dekads/Wankama_sm_0.{1,4,7}*.csv')

WK14 = read_csv(ifile[0])
WK47 = read_csv(ifile[1])
WK71 = read_csv(ifile[2])
warray = transpose([[wk14.field1],[wk47.field1],[wk71.field1]]) & help, sarray

ifile = file_search('/jabber/chg-mcnally/AMMASOIL/AMMA2013/dekads/Belefoungou-Top_sm_{0.2,0.4,0.6}*.csv')

BB20 = read_csv(ifile[0])
BB40 = read_csv(ifile[1])
BB60 = read_csv(ifile[2])

barray = transpose([[float(bb20.field1)],[float(bb40.field1)],[float(bb60.field1)]]) & help, barray

cube2 = fltarr(5,n_elements(barray[0,*])/3)
temp2 = fltarr(5,3)*!values.f_nan
cnt=0
m=0
for i = 0,n_elements(aarray[0,*])-1 do begin &$
  ;temp[*,*,cnt] = npawgrid[*,*,i] &$
  temp2[*,cnt] = aarray[*,i] &$
  cnt++ &$
  ;if cnt eq 3 then cube[*,*,m]=mean(temp,dimension=3,/nan) &$
  if cnt eq 3 then cube2[*,m]=mean(temp2,dimension=2,/nan) &$
  if cnt eq 3 then m++ &$
  if cnt eq 3 then cnt = 0 &$
endfor

ofile = '/jabber/chg-mcnally/agoufou.103.203.304.106.206.SM_monthly2005_2008.csv'
write_csv,ofile,cube2

;******************************************
nfile = file_search('/jabber/chg-mcnally/sahel_NSM_microwave.img')
nx = 720
ny = 350
nz = 431

nwetgrid = fltarr(nx,ny,nz)
openr,1,nfile
readu,1,nwetgrid
close,1

pad = fltarr(nx,ny,1)
pad[*,*,*]=!values.f_nan
nwetgrid = [[[nwetgrid]],[[pad]]]

;these match for AET, unlike RPAW
rpawgrid = fltarr(nx,ny,36,12)
npawgrid = fltarr(nx,ny,36,12)


openr,1,rfile
readu,1,rpawgrid
close,1
rpawgrid = reform(rpawgrid,nx,ny,432)
rpawgrid(where(rpawgrid eq 0))=!values.f_nan

;openr,1,nfile
;readu,1,npawgrid
;close,1
;;for AET
;npawgrid = reform(npawgrid,nx,ny,432)
;npawgrid(where(npawgrid eq 0))=!values.f_nan
;
;;pad = fltarr(nx,ny,1)
;;pad[*,*,*]=!values.f_nan
;;npawgrid = [[[npawgrid]],[[pad]]]
;
;npaw36 = reform(npawgrid,nx,ny,36,12)
;rpaw36 = reform(rpawgrid,nx,ny,36,12)

;I think that I should just take the average of every three?
;cube are the 12 month * 12 year cubes for the AETr and AETn
;cube = fltarr(nx,ny,144)
;temp = fltarr(nx,ny,3)*!values.f_nan
cube2 = fltarr(nx,ny,144)
temp2 = fltarr(nx,ny,3)*!values.f_nan
cnt=0
m=0
for i=0,n_elements(nwetgrid[0,0,*])-1 do begin &$
  ;temp[*,*,cnt] = npawgrid[*,*,i] &$
  temp2[*,*,cnt] = nwetgrid[*,*,i] &$
  cnt++ &$
  ;if cnt eq 3 then cube[*,*,m]=mean(temp,dimension=3,/nan) &$
  if cnt eq 3 then cube2[*,*,m]=mean(temp2,dimension=3,/nan) &$
  if cnt eq 3 then m++ &$
  if cnt eq 3 then cnt = 0 &$
endfor
nwetcube = reform(cube2,720,350,12,12)
ofile = '/jabber/chg-mcnally/sahel_NSM_microwave_monthly_12yrs.img'
openw,1,ofile
writeu,1,nwetcube
close,1

;see if this worked...doesn't look like it right now
;Wankama 2006 - 2011
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)


cormap=fltarr(nx,ny,12)
;monthly cubes
npawcube = reform(cube,nx,ny,12,12)
rpawcube = reform(cube2,nx,ny,12,12)
p1=plot(rpawcube[wxind,wyind,*,0], /overplot, 'b')


  p1 = image(mean(rpawcube[*,*,6,*], dimension=4, /nan), RGB_TABLE=20,image_dimensions=[72.0,35.0], image_location=[-20,-5], $ 
             dimensions=[nx/100,ny/100],title = 'August RFE-derived AET (mm)') &$ 
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20) &$
  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 52], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

ofile = '/jabber/chg-mcnally/nAET_monthly.img'
openw,1,ofile
writeu,1,npawcube
close,1

ofile = '/jabber/chg-mcnally/SM01_AET_monthly.img'
openw,1,ofile
writeu,1,rpawcube
close,1
;
;for x=0,nx-1 do begin &$
;  for y=0,ny-1 do begin &$
;    for m=0,11 do begin &$
;    test = where(finite(npawcube[x,y,m,*]), complement=null) &$
;    if n_elements(test) ne 12 then continue &$
;    cormap[x,y,m]=correlate(npawcube[x,y,m,*], rpawcube[x,y,m,*]) &$
;  endfor &$
;endfor


temp=image(cormap[*,*,4], rgb_table=20, min_value=0, max_value=0.6)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

p1 = plot(cube[wxind,wyind,*]);npaw
p1 = plot(cube2[wxind,wyind,*], /overplot,'b');rpaw


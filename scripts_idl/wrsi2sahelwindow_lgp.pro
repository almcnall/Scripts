pro wrsi2sahelwindow
;the purpose of this program is to play with the WRSI data that Diego gnerated for me.2000-2011 I want to look at the difference
;between 2003 (wet) and 2009(dry) 2000[0], 2001[1]

;concatinate the files of interest in the command line since the spaces are awful...

;ifile = file_search('/jabber/chg-mcnally/EROS_WRSI/west_Africa/all_Index_EOS.bil')
;ifile = file_search('/jabber/chg-mcnally/EROS_WRSI/west_Africa/all_WRSIanom.bil') ; West Sahel Africa_WRSI_anoml_EOS_2000.bil
;ifile = file_search('/jabber/Data/mcnally/EROS_WRSI/west_Africa/*Index_EOS*.bil');ah the file names are awful with spaces!
ifile = file_search('/home/mcnally/regionmasks/lgp_ws.bil')


;west africa window = 
left = -18.75 ;W
top  = 17.75  ;N
right  = 25.95;E 26.06
bottom = 5.25 ;N

inx = 448
iny = 126

outx = 720
outy = 350

ingrid = bytarr(inx,iny)
 
  openr,1,ifile
  readu,1,ingrid
  close,1
  ingrid = float(reverse(ingrid,2))
  ingrid(where(ingrid ge 254)) = !values.f_nan
  
a = fltarr((20.+left)/.10,iny) ;
b = fltarr((52-right)/.10,iny); right
c = fltarr(outx,abs(-5 - bottom)/.10) ;bottom
d = fltarr(outx,(30 - top)/.10)

outgrid = [a,ingrid,b]
outgrid = [[c],[outgrid],[d]]
help, outgrid

ofile = '/home/mcnally/regionmasks/lgp_ws_sahelwindow.img'
openw, 1,ofile
writeu,1,outgrid
close, 1

p1 = image(outgrid, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[outx/100,outy/100], $
           rgb_table = 10)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  p1.title = '2003 WRSI anomaly'
  p1.title.font_size=14
  p1.save,strcompress('/jabber/sandbox/mcnally/'+p1.title.string+'.jpg', /remove_all),RESOLUTION=200
  
  ;make a WRSI mask for the other data maps...
  in = where(finite(outgrid[*,*,0]), complement=null)
  wmask = outgrid[*,*,0]
  wmask(in) = 1
  wmask(null) = !values.f_nan
  
;# Development script to take Earth Observed precipitation and soil moisture and get crop yield
;# Written by Mark Carroll
;# Initial date 02/15/2012
;# Updated 02/23/2012
;# Added values for testing Indiana 03/21/2012
; moved over to IDL 12/28/12
; greg wrote separate funtions (see WRSI_millet.pro), now this just has inputs.
;1/30/2013: This is the file for the (point) inputs -- to be used with the compiled WRSI_millet_PR.pro

;y = 3 ; 0=2005, 1=2006; 2=2007; 3=2008

;****get WHC*******
ifile = file_search('/home/mcnally/regionmasks/whc3.bil')
whcgrid = bytarr(751,801)
openr,1,ifile
readu,1,whcgrid
close,1

whcgrid = reverse(whcgrid,2)
;Wankama Niger (prolly should double check this...)
xind = FLOOR((2.633 + 20.05) * 10.0)
yind = FLOOR((13.6454 + 40.05) * 10.0)

WHC = whcgrid(xind,yind)

;******get LGP***********
ifile = file_search('/home/mcnally/regionmasks/lgp_ws_sahelwindow.img')
lgpgrid = fltarr(720,350)
openr,1,ifile
readu,1,lgpgrid
close,1

;Wankama Niger for sahel window 720/350
xind = FLOOR((2.6496 + 20.) / 0.10)
yind = FLOOR((13.6496 + 5) / 0.10)

LGP = lgpgrid(xind,yind) 

;****get climatological SOS***********
ifile = file_search('/home/mcnally/regionmasks/SOS/waw7033dt.bil')
sosgrid = bytarr(751,801)

openr,1,ifile
readu,1,sosgrid
close,1

sosgrid = reverse(sosgrid,2)

;Wankama Niger (prolly should double check this...)
xind = FLOOR((2.633 + 20.05) * 10.0)
yind = FLOOR((13.6454 + 40.05) * 10.0)

SOS = sosgrid(xind,yind);17

;*****Get rainfall********rfe, ubrfe, sta from Wankama East
;check out the difference between zeros and NANs in these rain data...
ifile = file_search('/jabber/chg-mcnally/AMMARain/RFE_UBRFE_and_station_dekads.csv')
wfile = file_search('/jabber/chg-mcnally/AMMARain/wankamaWest_station_dekads.csv')
west = read_csv(wfile)
rainf = read_csv(ifile) 

ubrf = reform(rainf.field2,36,4)
rfe2 = reform(rainf.field1,36,4)
sta  = reform(rainf.field3,36,4)
wsta = reform(west.field1,36,4)
  ;replace assumed missing data with NAN
  wsta[*,0] = !values.f_nan
  wsta[11:20,2] = !values.f_nan
  ;reform into vector so i can merge it with east station data
  wsta = reform(wsta,144)
avgsta = [[rain.field3],[wsta]]
avgsta = reform(mean(avgsta,dimension=2,/nan),36,4);

  ;*******get EROS PET*****************
  ifile = file_search('/jabber/chg-mcnally/EROSPET/wankama_dekadPET_2005_2008.csv')
  potevp = read_csv(ifile)
  PETcube = reform(potevp.field1,36,4)

for y = 0,3 do begin &$
  rain = rfe2[*,y] &$
  pet = PETcube[*,y] &$
  new_wrsi = WRSI(RAIN, PET, WHC=WHC, LGP=LGP) &$
 
  ;I fixed the SOS at 17 : 1/17/2013
  ;new_sos = sos_1d(rain) & 
  print, new_wrsi &$ 
endfor

end

;check out the difference between stations and their average...looks fine
;temp = plot(reform(avgsta,144), 'r', /overplot)
;temp = plot(rain.field3, /overplot,'b')
;temp = plot(west.field1, /overplot,'g')

;xticks = ['2005','2006','2007','2008']
;p1 = plot(reform(avgsta,144), name = 'sta avg', thick = 3)
;;p2 = plot(sta[*,3], 'b', /overplot, name = 'east', thick =3)
;p3 = plot(reform(rfe2,144),'g', /overplot, name = 'rfe2', thick = 3)
;p4 = plot(reform(ubrf,144), 'm', /overplot, name = 'ubrf', thick = 3, $
;          xtickvalues = [18, 54, 90, 126], xtickinterval = 36)
;p1.xtickname = xticks
;p1.xtickfont_size = 24
;p1.ytickfont_size = 18
;lgr2 = LEGEND(TARGET = [p1, p3, p4])
;p1.title = '2005-2008 Wankama'
;p1.title.font_size = 16
;p1.ytitle = '(mm)'
;
;p1 = plot(avgsta[*,3], thick = 3, name='sta')
;p2 = plot(rfe2[*,3], 'b',thick=3, /overplot, name='rfe')
;p3 = plot(ubrf[*,3], 'g', /overplot, name='ubrfe')
;p2.title = '2008'
;lgr2 = LEGEND(TARGET = [p1, p3, p2])
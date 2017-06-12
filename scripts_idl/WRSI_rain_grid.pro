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

  ;chop down the file to the sahel window 
  xrt = (751-1)-3/0.1  &$;RFE goes to 55, sahel goes to 52 plus an extra pixel
  ybot = (35/0.1)+1   &$ ;sahel starts at -5S
  ytop = (801-1)-10/0.1  &$; &$sahel stops at 30N
  xlt = 1.     &$          ;and I guess sahel starts at 19W, rather than 20....
  WHCsahel = whcgrid[xlt:xrt,ybot:ytop]
  
ofile = strcompress('/home/mcnally/regionmasks/WHCsahel.img')
openw,1,ofile
writeu,1,WHCsahel
close,1

;******get LGP***********
ifile = file_search('/home/mcnally/regionmasks/Sahel_LGP_Af.bil')
ingrid = bytarr(751,801)
;lgpgrid = fltarr(720,350)
openr,1,ifile
readu,1,ingrid
close,1
ingrid = reverse(ingrid,2)

;chop down the file to the sahel window 
  xrt = (751-1)-3/0.1  &$;RFE goes to 55, sahel goes to 52 plus an extra pixel
  ybot = (35/0.1)+1   &$ ;sahel starts at -5S
  ytop = (801-1)-10/0.1  &$; &$sahel stops at 30N
  xlt = 1.     &$          ;and I guess sahel starts at 19W, rather than 20....
  lgpsahel = ingrid[xlt:xrt,ybot:ytop]

ofile = strcompress('/home/mcnally/regionmasks/LGPsahel.img')
openw,1,ofile
writeu,1,LGPsahel
close,1 


;****climatological SOS***********
;ifile = file_search('/home/chg-mcnally/regionmasks/etw7006dt.bil')
;ingrid = bytarr(751,801)

openr,1,ifile
readu,1,ingrid
close,1

ingrid = reverse(ingrid,2)
  ;chop down the file to the sahel window 
  xrt = (751-1)-3/0.1  &$;RFE goes to 55, sahel goes to 52 plus an extra pixel
  ybot = (35/0.1)+1   &$ ;sahel starts at -5S
  ytop = (801-1)-10/0.1  &$; &$sahel stops at 30N
  xlt = 1.     &$          ;and I guess sahel starts at 19W, rather than 20....
  SOSsahel = ingrid[xlt:xrt,ybot:ytop]

ofile = strcompress('/home/mcnally/regionmasks/SOSsahel.img')
openw,1,ofile
writeu,1,SOSsahel
close,1
;*****Get rainfall********rfe, ubrfe, sta from Wankama East
;ubfile = file_search('/jabber/LIS/Data/ubRFE2/dekads/
ifile = file_search('/jabber/LIS/Data/CPCOriginalRFE2/dekads/sahel/2*.img');these are thru 2011

nx = 720
ny = 350
nz = 396

ingrid = fltarr(nx,ny)
rcube = fltarr(nx,ny,nz)

;make a big stack and then reform...
for i = 0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[i]  &$
  readu,1,ingrid &$
  close,1 &$
  
  rcube[*,*,i] = ingrid &$
endfor

rainyrly = reform(rcube,nx,ny,36,11) ;x,y,dek,yr
rain0508 = rainyrly[*,*,*,4:7]

  ;*******EROS PET*****************
ifile = file_search('/jabber/chg-mcnally/EROSPET/pet_binary/afr/dekads/*.img')

nx = 751
ny = 801

ingrid = fltarr(nx,ny)
pcube = fltarr(nx,ny,n_elements(ifile))

for i = 0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[i]  &$
  readu,1,ingrid &$
  close,1 &$
  
  pcube[*,*,i] = ingrid &$
endfor
;maybe I should reform this so that it only does one year at a time....
petyrly = reform(pcube,nx,ny,36,12) ;x,y,dek,yr

  ;chop down the file to the sahel window 
  xrt = (751-1)-3/0.1  &$;RFE goes to 55, sahel goes to 52 plus an extra pixel
  ybot = (35/0.1)+1   &$ ;sahel starts at -5S
  ytop = (801-1)-10/0.1  &$; &$sahel stops at 30N
  xlt = 1.     &$          ;and I guess sahel starts at 19W, rather than 20....
  petsahel = petyrly[xlt:xrt,ybot:ytop,*,*]
  
ofile = strcompress('/jabber/chg-mcnally/EROSPET/PETsahel.img')
openw,1,ofile
writeu,1,PETsahel
close,1

;********************************
nx = 720
ny = 350 

outgrid = fltarr(nx,ny,4)

for x = 0,nx-1 do begin &$
  ;x = xind
  for y = 0,ny-1 do begin &$
    ;y = yind
    if lgpsahel[x,y] eq 0 then continue &$
    for yr = 0,3 do begin &$ ;year loop - eventually this will be 11 yrs, 4 for now
      ;yr = 0 
      RAIN = rain0508[x,y,*,yr] &$ ; p1 = plot(rain,'b', title = string(x)+string(y)+string(yr))   &$
      PET = PETsahel[x,y,*,yr] &$ ; p2 = plot(pet*10,'r', /overplot)   &$
      WHC = WHCsahel[x,y] &$ ;& print, WHC &$
      LGP = LGPsahel[x,y]  &$ ;& print, LGP &$
      SOS = SOSsahel[x,y]  &$ ;& print, SOS &$
      
      new_wrsi = WRSI(RAIN, PET, WHC=WHC, LGP=LGP, SOSind=SOS) &$
      ;print, new_wrsi &$ 
    outgrid[x,y,*] = new_wrsi &$
    endfor &$ ;yr &$
  endfor &$;y
endfor &$;x
print, 'hold' &$
end

;p1 = image(petsahel[*,*,0,0], image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
;           rgb_table = 20)
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
;  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
;  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

;xind = FLOOR((2.633 + 20.05) * 10.0)
;yind = FLOOR((13.6454 + 40.05) * 10.0)
;p1 = plot(petyrly[xind,yind,*,0],'r');

;Wankama Niger for sahel window 720/350
;xind = FLOOR((2.6496 + 20.) / 0.10)
;yind = FLOOR((13.6496 + 5) / 0.10)

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
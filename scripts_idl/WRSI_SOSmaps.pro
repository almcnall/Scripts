;# Development script to take Earth Observed precipitation and soil moisture and get crop yield
;# Written by Mark Carroll
;# Initial date 02/15/2012
;# Updated 02/23/2012
;# Added values for testing Indiana 03/21/2012
; moved over to IDL 12/28/12
; greg wrote separate funtions (see WRSI_millet.pro), now this just has inputs.
; 1/30/2013: This is the file for the gridded inputs -- to be used with the compiled WRSI_millet_PR.pro
;4/29/2013 messing with the script to output new SOS maps. DO I need new SOS maps? yes? to tell the NSM when to start
;the season?

;****get WHC*******
nx = 720
ny = 350
ifile = file_search('/home/mcnally/regionmasks/WHCsahel.img')
whcgrid = bytarr(nx,ny)

openr,1,ifile
readu,1,whcgrid
close,1

;******get LGP***********
ifile = file_search('/home/mcnally/regionmasks/LGPsahel.img')
lgpgrid = bytarr(nx,ny)
openr,1,ifile
readu,1,lgpgrid
close,1

;****climatological SOS***********
ifile = file_search('/home/mcnally/regionmasks/SOSsahel.img')
sosgrid = bytarr(nx,ny)

openr,1,ifile
readu,1,sosgrid
close,1

;*****Get rainfall********rfe, ubrfe, sta from Wankama East
;ifile = file_search('/jabber/LIS/Data/ubRFE04.19.2013/dekads/sahel/2*.img');these are 2001-2012
;;ifile = file_search('/jabber/LIS/Data/CPCOriginalRFE2/dekads/sahel/2*.img');these are 2001-2012
;
;nx = 720
;ny = 350
;nz = n_elements(ifile);432 = 12*36
;
;ingrid = fltarr(nx,ny)
;rcube = fltarr(nx,ny,nz)
;
;;make a big stack and then reform...
;for i = 0,n_elements(ifile)-1 do begin &$
;  openr,1,ifile[i]  &$
;  readu,1,ingrid &$
;  close,1 &$
;  
;  rcube[*,*,i] = ingrid &$
;endfor
;
;;this lets me deal with the maps yr by yr 2001-2012
;rainyrly = reform(rcube,nx,ny,36,12) ;
;raingrd = rainyrly[*,*,*,*]

;******try quantiles**********
qfile = file_search('/jabber/chg-mcnally/AMMARain/UBRFE_cube4WRSI_*.img');2006-2008
; 25, 50, 75
nx = 720
ny = 350
nz = 432

ingrid25 = fltarr(nx,ny,nz)
ingrid50 = fltarr(nx,ny,nz)
ingrid75 = fltarr(nx,ny,nz)

openr,1,qfile[0]
openr,2,qfile[1]
openr,3,qfile[2]

readu,1,ingrid25
readu,2,ingrid50
readu,3,ingrid75

close,1
close,2
close,3

q25 = reform(ingrid25,nx,ny,36,12)
q50 = reform(ingrid50,nx,ny,36,12)
q75 = reform(ingrid75,nx,ny,36,12)

;*******EROS PET*****************
ifile = file_search('/jabber/chg-mcnally/EROSPET/PETsahel.img') ;2001-2012
nx = 720
ny = 350
ndk = 36
nyr = 12

PETgrid = fltarr(nx,ny,ndk,nyr);what yrs is this for?

  openr,1,ifile 
  readu,1,PETgrid 
  close,1
  
petyrly = reform(petgrid,nx,ny,36,12) ;x,y,dek,yr
;petgrd = petyrly[*,*,*,*]; what years do i need for comparison? 2005-2011.
petgrd = petyrly[*,*,*,*]; what years do i need for comparison? 2005-2008
;raingrd = rainyrly[*,*,*,4:7]
;********************************
nx = 720
ny = 350 

outgrid = fltarr(nx,ny,n_elements(petgrd[0,0,0,*]))
pawgrid = fltarr(nx,ny,max(lgpgrid)+1,n_elements(petgrd[0,0,0,*]))
SOSout = fltarr(nx,ny,12)

;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

for x = 0,nx-1 do begin &$
  ;x = wxind
  for y = 0,ny-1 do begin &$
    ;y = wyind
    ;loop/grid vs point
    if lgpgrid[x,y] eq 0 or sosgrid[x,y] eq 0 or sosgrid[x,y] eq 60 then continue &$
    ;if lgpgrid[x,y] eq 0 or sosgrid[x,y] eq 0 or sosgrid[x,y] eq 60 then print, 'ah!' &$
    
    for yr = 0,n_elements(petgrd[0,0,0,*])-2 do begin &$ 
     ;yr = 0 
     rain = reform(q75[x,y,*,yr:yr+1],72) &$ 
     ;*****enter the different rainfall options here*****    
     pet = reform(petgrd[x,y,*,yr:yr+1],72) &$ 
     ;rain = q25[x,y,*,yr] &$
     ;pet = petgrd[x,y,*,yr] &$
     whc = whcgrid[x,y] &$ 
     lgp = lgpgrid[x,y]  &$ 
     
     ;comment/uncomment depending on static or dynamic SOS
    ;sos_ind = sosgrid[x,y]  &$
     ;sos_ind = 13 &$
    ;new_wrsi = wrsi(rain, pet, whc=whc, lgp=lgp, sos_ind=sos_ind) &$
    new_wrsi = wrsi(rain, pet, whc=whc, lgp=lgp) &$
     
    outgrid[x,y,yr] = new_wrsi &$ 
    ;this pads out the array so that different length of growing periods can be accomadiated.   
     ;pad = fltarr(max(lgpgrid)+1 -n_elements(new_wrsi)) &$
     ;pad[*] = !values.f_nan &$
     
     ;oops might need to re-run and write this might be full of zeros.
     ;PAWpad = [new_wrsi,pad] &$
     ;pawgrid[x,y,*,yr] = new_wrsi &$
     ;PAWgrid[x,y,*,yr] = PAWpad  &$
     SOSout[x,y,yr] = new_wrsi &$
    endfor &$ ;yr 
  endfor &$ ;y
endfor

;save PAWout for comparison with NSM and station data.
PAWout = transpose(reform(PAWgrid[x,y,0:lgp-1,*])) & help, pawout

ofile = strcompress('/jabber/chg-mcnally/SOSsahel_q75.csv', /remove_all)
openw,1,ofile
writeu,1,SOSout
close,1

write_csv, ofile, SOSout


zeros = where(outgrid eq 0)
outgrid(zeros) = 255

p1 = image(outgrid[*,*,3], image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
            RGB_TABLE=make_wrsi_cmap(),MIN_VALUE=0, title = '2004 RFE_PAW WRSI')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

ofile = '/jabber/chg-mcnally/EOS_WRSI_RFE2001_2011.img'
;openw,1,ofile
;writeu,1,outgrid
;close,1



;
;;Agoufou_1 15.35400    -1.47900  
;axind = FLOOR((-1.479 + 20.) / 0.10)
;ayind = FLOOR((15.3540 + 5) / 0.10)

end


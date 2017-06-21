;# Development script to take Earth Observed precipitation and soil moisture and get crop yield
;# Written by Mark Carroll
;# Initial date 02/15/2012
;# Updated 02/23/2012
;# Added values for testing Indiana 03/21/2012
; moved over to IDL 12/28/12
; greg wrote separate funtions (see WRSI_millet.pro), now this just has inputs.
; 1/30/2013: This is the file for the gridded inputs -- to be used with the compiled WRSI_millet_PR.pro
; 5/3/2013: try it with the NPAW (plant avaialble water derived from NDVI)
;****get WHC*******
nx = 720
ny = 350
ifile = file_search('/home/mcnally/regionmasks/WHCsahel.img')
whcgrid = bytarr(nx,ny)

openr,1,ifile
readu,1,whcgrid
close,1
;Agoufou_1 15.35400    -1.47900  
;axind = FLOOR((-1.479 + 20.) / 0.10)
;ayind = FLOOR((15.3540 + 5.) / 0.10)
; print, whcgrid [axind,ayind]
;******get LGP***********
ifile = file_search('/home/mcnally/regionmasks/LGPsahel.img')
lgpgrid = bytarr(nx,ny)
openr,1,ifile
readu,1,lgpgrid
close,1

;****climatological SOS or specified SOS to match RFE***********
ifile = file_search('/jabber/chg-mcnally/SOSsahel_ubRFE_2001_2001.img')
sosgrid = fltarr(nx,ny,12)
;ifile = file_search('/home/mcnally/regionmasks/SOSsahel.img')
;sosgrid = bytarr(nx,ny)

openr,1,ifile
readu,1,sosgrid
close,1

;******get soil moisture observations/estimates*******
;i might need to adjust these first with the FAO wilting point map.
;maybe i should mask out the congo -- per the non-WRSI areas...
;ifile = file_search('/jabber/chg-mcnally/filterNDVI_sahel/filterNDVI_soilmoisture_200101_2012.10.2.img')
ifile = file_search('/jabber/chg-mcnally/sahel_NPAW_2001_2012.img')
ifile = file_search('/jabber/chg-mcnally/sahel_NSWB_2001_2012.img')

nx = 720
ny = 350
nz = 431

filter  = fltarr(nx,ny,nz)
openr,1,ifile
readu,1,filter
close,1

pad = fltarr(nx,ny,1)
pad[*,*,*] = !values.f_nan
ffull = [ [[filter]], [[pad]] ]

;reform into years....
soilgrid = reform(ffull,nx,ny,36,12)
soilgrd = soilgrid[*,*,*,*]

 ;*******EROS PET*****************
ifile = file_search('/jabber/chg-mcnally/EROSPET/PETsahel.img')
nx = 720
ny = 350
ndk = 36
nyr = 12

PETgrid = fltarr(nx,ny,ndk,nyr)

  openr,1,ifile 
  readu,1,PETgrid 
  close,1
 
pet = reform(petgrid,nx,ny,36,12)
petgrd = pet[*,*,*,*]
;********************************
;first make a FC and WP map from the FAO values. 
;THEN compare these values to others found in the literatuer at spp. points.

;****************read in field capacity************
;FC = 0.09
;WP = 0.03
nx = 720
ny = 350
;
;FCfile = file_search('/jabber/chg-mcnally/FieldCapacity_sahel.img');what file is this?? did I invent this one?
;WPfile = file_search('/jabber/chg-mcnally/WiltPoint_sahel.img')
;;WHCfile = file_search('/home/mcnally/regionmasks/WHCsahel.img')
;
;FCgrid = fltarr(nx,ny)
;WPgrid = fltarr(nx,ny)
;WHCgrid = float(WHCgrid) ;read in earlier....
;WHCgrid(where(WHCgrid eq 0)) = !values.F_nan
;
;openr,1,FCfile
;readu,1,FCgrid ;this is a little wonkey
;close,1
;
;FCgrid(where(FCgrid lt 0)) = !values.F_nan
;
;openr,1,WPfile
;readu,1,WPgrid
;close,1
;
;;WPgrid[*,*]=0.028
;
;PAW = FCgrid-WPgrid
;;plant avaialable water cannot be less than the wilting point.
;PAW(where(PAW le 0.006)) = !values.f_nan
;
;scale = WHCgrid/PAW
;
outgrid = fltarr(nx,ny,12)
pawgrid = fltarr(nx,ny,max(lgpgrid)+1,n_elements(petgrd[0,0,0,*]))
pawout = fltarr(10,n_elements(petgrd[0,0,0,*]))

;******************read in climatologies**********************
;nfile = file_search('/jabber/chg-mcnally/PAW_NDVI_clim.img')
;rfile = file_search('/jabber/chg-mcnally/PAW_RFE_clim.img')
;
;nclim = fltarr(nx,ny)
;rclim = fltarr(nx,ny)
;
;openr,1,nfile
;readu,1,nclim
;close,1
;
;openr,1,rfile
;readu,1,rclim
;close,1
;*************************************************************
xind = FLOOR((2.6496 + 20.) / 0.10)
yind = FLOOR((13.6496 + 5.) / 0.10)
for x = 0,nx-1 do begin &$
  ;x = xind
  for y = 0,ny-1 do begin &$
    ;y = yind
    for yr = 0, n_elements(petgrd[0,0,0,*])-2 do begin &$ 
      if lgpgrid[x,y] eq 0 OR SOSgrid[x,y] eq 0 OR SOSgrid[x,y,yr] eq 60 OR mean(soilgrid[x,y,*,*],/nan) eq 0 then continue &$    
      SOIL = REFORM(soilgrd[x,y,*,yr:yr+1],72) &$ 
      PET = REFORM(PETgrd[x,y,*,yr:yr+1],72) &$ 
      ;p1=plot(soil) & p1=plot(pet,/overplot,'g')
      WHC = WHCgrid[x,y] &$ 
      LGP = LGPgrid[x,y]  &$ 
      SOS_ind = SOSgrid[x,y,yr]  &$
      ;I added these two after having modified the code to write out the PAW from RFE & NDVI
;      rmean = rclim[x,y] &$
;      nmean = nclim[x,y] &$
      ;new_wrsi = WRSI(SOIL, PET, WHC=WHC, LGP=LGP, SOS_ind=SOS_ind, rmean = rmean, nmean = nmean) &$
      
      new_wrsi = WRSI(SOIL, PET, WHC=WHC, LGP=LGP, SOS_ind=SOS_ind) &$
      outgrid[x,y,yr] = new_wrsi &$
      ;this pads out the array so that different length of growing periods can be accomadiated.   
     ;pad = fltarr(max(lgpgrid)+1 -n_elements(new_wrsi)) &$
     ;pad[*] = !values.f_nan &$
     ;PAWpad = [new_wrsi,pad] &$
     ;PAWgrid[x,y,*,yr] = PAWpad  &$
               
    endfor &$ ;yr &$
  endfor &$;y
endfor

outgrid(where(outgrid lt 0))=0

ofile = '/jabber/chg-mcnally/EOS_WRSI_NDVI2001_2012vSWB.img'
openw,1,ofile
writeu,1,outgrid
close,1

zeros = where(outgrid eq 255)
outgrid(zeros) = 0

;ofile = strcompress('/jabber/chg-mcnally/PAW_NDVI_climSOS_sahel.img')
;Array[720, 350, 22, 11] x,y,LGP+1,yrs
;openw,1,ofile
;writeu,1,PAWgrid
;close,1
;does this start at 2000 or 2001?
temp = plot(outgrid[xind,yind,0:10])
;ok, so it runs...but most of the time it says that SM is sufficient. check out how the scaling and PAW look?

p1 = image(outgrid[*,*,1], image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
            RGB_TABLE=make_wrsi_cmap(), title = '2012 NDVI_PAW WRSI')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
end

m=fltarr(12)
for i=0,11 do begin &$
  m[i] = mean(outgrid[*,*,i], /nan) &$
endfor 


;Wankama Niger for sahel window 720/350
;xind = FLOOR((2.6496 + 20.) / 0.10)
;yind = FLOOR((13.6496 + 5) / 0.10)
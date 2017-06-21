;# Development script to take Earth Observed precipitation and soil moisture and get crop yield
;# Written by Mark Carroll
;# Initial date 02/15/2012
;# Updated 02/23/2012
;# Added values for testing Indiana 03/21/2012
; moved over to IDL 12/28/12
; greg wrote separate funtions (see WRSI_millet.pro), now this just has inputs.
; 1/30/2013: This is the file for the gridded inputs -- to be used with the compiled WRSI_millet_PR.pro
; 5/3/2013: try it with the NPAW (plant avaialble water derived from NDVI)
; 6/16/2013 write out the AET caculated with the NPAW (and RPAW in the other script..)
; 6/22/2013 running WRSI with LIS-SM, I added a nan conditional to the WRSI function, not really
; sure why there are these gaps in the SM01/02 timeseries, but there are...maybe they scaled to lt 0..
; 6/27/2013 Did I not actually calculate WRSI before with SM01? 
; 7/07/2013 update to return SOS, AET, PAW and WRSI and run with the N-WET (NDVI-microwave combo). 
; 1/18/2014 update code to work on Rain and regenerate WRSI with the SM0X soil moisture. 
; 1/29/2014 update to run with the scales 2001-2010 datasets: ECV, SM0X3, NDVI
; 6/25/2014 update to run simulations for uncertainty analysis for paper revisions
; 7/07/2014 revisit since i need to submit these revisions! sooner the better. 
; 7/16/2014 rainfall updated now time to update the soil...
; 7/24/2014 now WRSI_rain_gridv2.pro can handle soil moisture, so don't use this script anymore.

;****get WHC*******
nx = 720
ny = 350
ifile = file_search('/home/chg-mcnally/regionmasks/WHCsahel.img')
whcgrid = bytarr(nx,ny)

openr,1,ifile
readu,1,whcgrid
close,1

;******get LGP***********
ifile = file_search('/home/chg-mcnally/regionmasks/LGPsahel.img')
lgpgrid = bytarr(nx,ny)
openr,1,ifile
readu,1,lgpgrid
close,1

;****climatological SOS or specified SOS to match RFE***********
;ifile = file_search('/home/chg-mcnally/SOSsahel_ubRFE_2001_2001.img')
;sosgrid = fltarr(nx,ny,12)
ifile = file_search('/home/chg-mcnally/regionmasks/SOSsahel.img')
sosgrid = bytarr(nx,ny)

openr,1,ifile
readu,1,sosgrid
close,1

;******get soil moisture observations/estimates*******
;ifile = file_search('/home/chg-mcnally/SM0X3_scaled4WRSI.img')
ifile = file_search('/home/chg-mcnally/SM0X2_scaled4WRSI.img') ;how long is this time series?
;ifile = file_search('/home/chg-mcnally/NWET_scaled4WRSI.img');maybe get rid of these
;ifile = file_search('/home/chg-mcnally/ECV_MW_scaled4WRSI.img')

nx = 720
ny = 350
nz = 396
;nz = 432

;this can be used for sm01, sm02, sm0x
;WRSI appears to be very high for SM0X3...
SM0X  = fltarr(nx,ny,nz)
;sm0X = fltarr(nx,ny,36,11); 2001-2011
openr,1,ifile
readu,1,SM0X
close,1

soilgrd = reform(SM0X,720,350,36,11)
soilgrd(where(soilgrd lt 0))=!values.f_nan
 ;*******EROS PET*****************
ifile = file_search('/home/chg-mcnally/PETsahel.img')
nx = 720
ny = 350
ndk = 36
nyr = 12

PETgrid = fltarr(nx,ny,ndk,nyr)
  openr,1,ifile 
  readu,1,PETgrid 
  close,1
  ;why am i reforming this?? it was when i was adding an extra year.
temp = reform(petgrid,nx,ny,432)

;append an extra year so it runs properly
;temp =[  [[temp[*,*,*] ]], [[temp[*,*,396:431] ]]  ]
;petgrd = reform(temp,nx,ny,36,13) ;

;********************************
;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5) / 0.10)

;****Nalohou-Top, Benin  9.74407     1.60580  
nxind = FLOOR((1.6058 + 20.) / 0.10);says it is 144...2006-2007 (2009)
nyind = FLOOR((9.74407 + 5) / 0.10)

;Belefoungou-Top 9.79506     1.71450  
bxind = FLOOR((1.7145 + 20.) / 0.10)
byind = FLOOR((9.79506 + 5) / 0.10)

;***********************************************
outgrid = fltarr(nx,ny,12)
pawgrid = fltarr(nx,ny,max(lgpgrid)+1,n_elements(petgrid[0,0,0,*]))
pawout = fltarr(10,n_elements(petgrid[0,0,0,*]))
 
nyrs = n_elements(petgrid[0,0,0,*])
WRSIgrid = fltarr(nx,ny,nyrs);nx,ny,nyrs
PAWgrid = fltarr(nx,ny,max(lgpgrid)+1,nyrs)
AETgrid = fltarr(nx,ny,max(lgpgrid)+1,nyrs)
SOSout = fltarr(nx,ny,nyrs)
;*************************************************************
;******everything needs to be cubed!******
ny = 250
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    ;x = wxind  
    ;y = wyind
    for yr = 0, n_elements(petgrid[0,0,0,*])-3 do begin &$ 
      ;if lgpgrid[x,y] eq 0 OR SOSgrid[x,y] eq 0 OR SOSgrid[x,y,yr] eq 60 OR mean(soilgrd[x,y,*,*],/nan) eq 0 then continue &$ 
      if lgpgrid[x,y] eq 0 OR SOSgrid[x,y] eq 0 OR SOSgrid[x,y] eq 60 OR mean(soilgrd[x,y,*,*],/nan) eq 0 then continue &$  
       
      ;if lgpgrid[x,y] eq 0 OR SOSgrid[x,y] eq 0 OR SOSgrid[x,y,yr] eq 60 OR mean(soilgrd[x,y,*,*],/nan) eq 0 then print, 'ah!' &$    
      SOIL = REFORM(soilgrd[x,y,*,yr:yr+1],72) &$ 
      PET = REFORM(PETgrid[x,y,*,yr:yr+1],72)*10 &$ 
      ;p1=plot(soil) & p1=plot(pet,/overplot,'g')
      WHC = WHCgrid[x,y] &$ 
      LGP = LGPgrid[x,y]  &$ 
      ;SOS_ind = SOSgrid[x,y,yr]  &$
      SOS_ind = SOSgrid[x,y]  &$
      
      
      new_wrsi = WRSI(SOIL, PET, WHC=WHC, LGP=LGP, SOS_ind=SOS_ind,pawout=tmppaw,aetout=tmpaet,sosout=tempsos) &$
      outgrid[x,y,yr] = new_wrsi &$
      ;this pads out the array so that different length of growing periods can be accomadiated.   
     pad = fltarr(max(lgpgrid)+1 -n_elements(tmppaw)) &$
     pad[*] = !values.f_nan &$
     PAWpad = [tmppaw,pad] &$
     AETpad = [tmpaet,pad] &$
     
     PAWgrid[x,y,*,yr] = PAWpad  &$
     AETgrid[x,y,*,yr] = AETpad  &$         
    endfor &$ ;yr &$
  endfor &$;y
endfor
print, 'done'


outgrid(where(outgrid lt 0))=0

ofile = '/home/chg-mcnally/EOS_WRSI_NWET_2001_2010_staticSOS.img'
openw,1,ofile
writeu,1,outgrid
close,1

zeros = where(outgrid eq 255)
outgrid(zeros) = 0

;ofile = strcompress('/jabber/chg-mcnally/SM01_AET_sahel.img')
;;Array[720, 350, 22, 11] x,y,LGP+1,yrs
;openw,1,ofile
;writeu,1,PAWgrid
;close,1
;does this start at 2000 or 2001?
temp = plot(outgrid[xind,yind,0:10])
;ok, so it runs...but most of the time it says that SM is sufficient. check out how the scaling and PAW look?
yr = 4
p1 = image(mean(byte(outgrid), dimension=3), image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
            RGB_TABLE=make_wrsi_cmap(), $
            title = 'NWET_PAW WRSI '+strcompress('200'+string(yr+1),/remove_all))
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
end

;looks good for NWET-WRSI!
m=fltarr(12)
for i=0,11 do begin &$
  m[i] = mean(outgrid[*,*,i], /nan) &$
endfor 


;Wankama Niger for sahel window 720/350
;xind = FLOOR((2.6496 + 20.) / 0.10)
;yind = FLOOR((13.6496 + 5) / 0.10)
;old input files incase this jan29 version doesn't work out.
;;ifile = file_search('/jabber/chg-mcnally/filterNDVI_sahel/filterNDVI_soilmoisture_200101_2012.10.2.img')
;ifile = file_search('/jabber/chg-mcnally/sahel_NPAW_2001_2012_PET_DYNSOS.img')
;ifile = file_search('/jabber/chg-mcnally/SM01_scaled4WRSI.img');
;ifile = file_search('/jabber/chg-mcnally/SM02_scaled4WRSI.img');
;ifile = file_search('/home/chg-mcnally/SM0X_scaled4WRSI.img');
;ifile = file_search('/jabber/chg-mcnally/NWET_scaled4WRSI.img')

;******otherstuff******
;;all this stuff is to deal with the mising dekad in the NPAW data
;pad = fltarr(nx,ny,1)
;pad[*,*,*] = !values.f_nan
;ffull = [ [[filter]], [[pad]] ]
;ffull(where(ffull lt 0))=0
;;reform into years....
;soilgrid = reform(ffull,nx,ny,36,12)
;soilgrd = soilgrid[*,*,*,*]

;and now I want to pad out the last year of the SM01, SM02, SM0X so that I can get all of 2011...
;not sure if these should be nx=250 or nx=350...
;pad = sm0X[*,*,*,10] & help, pad
;vectSM0X = reform(sm0X,720,250,396) & help, vectSM0X
;cat = [ [[vectSM0X]],[[pad]]  ] & help, cat
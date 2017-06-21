;# Development script to take Earth Observed precipitation and soil moisture and get crop yield
;# Written by Mark Carroll
;# Initial date 02/15/2012
;# Updated 02/23/2012
;# Added values for testing Indiana 03/21/2012
; moved over to IDL 12/28/12
; greg wrote separate funtions (see WRSI_millet.pro), now this just has inputs.
; 1/30/2013: This is the file for the gridded inputs -- to be used with the compiled WRSI_millet_PR.pro
; 7/6/2012: updated to return SOS, AET, PAW and WRSI
; 10/4/2013 migrated to Rain
; 1/30/2014 thinking about re-running with the static SOS map to make the results for paper #2 more independant/stable
; 3/27/2014 figure out to calculate SOS for Yemen and make a climSOS map, also need climWRSI, so maybe I should
; be working over here and testing my LGP map. This might justify a new version...see WRSI_yemen_PR
; 6/17/14 thinking about how to re-run this for uncertainty analysis...just do ensemble forcings. 
; 6/25/14 trying to run the ensemble...
; 7/15/2014 these results seem too wet...because I had not multiplied the PET x 10 ...looks better now.
; 7/16/2014 can i add the soil sims in here and just call a different executable

;********************************
;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Agoufou_1 15.35400    -1.47900
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5) / 0.10)

;****Nalohou-Top, Benin  9.74407     1.60580
;nxind = FLOOR((1.6058 + 20.) / 0.10);says it is 144...2006-2007 (2009)
;nyind = FLOOR((9.74407 + 5) / 0.10)

;Belefoungou-Top 9.79506     1.71450
bxind = FLOOR((1.7145 + 20.) / 0.10)
byind = FLOOR((9.79506 + 5) / 0.10)

;Niamey,Airport 13.483334,2.1666667
nxind = FLOOR((2.16667 + 20.) / 0.10)
nyind = FLOOR((13.4833 + 5) / 0.10)

;****get WHC*******
nx = 720
ny = 350
ifile = file_search('/home/chg-mcnally/regionmasks/WHCsahel.img') & print, ifile
whcgrid = bytarr(nx,ny)

openr,1,ifile
readu,1,whcgrid
close,1

;******get LGP***********
ifile = file_search('/home/chg-mcnally/regionmasks/LGPsahel.img') & print, ifile
lgpgrid = bytarr(nx,ny)
openr,1,ifile
readu,1,lgpgrid
close,1

;****climatological SOS***********
;use this for the SMAP paper
ifile = file_search('/home/chg-mcnally/regionmasks/SOSsahel.img') & print, ifile
sosgrid = bytarr(nx,ny)

openr,1,ifile
readu,1,sosgrid
close,1

;*******EROS PET*****************
ifile = file_search('/home/chg-mcnally/PETsahel.img') ;2001-2012
nx = 720
ny = 350
ndk = 36
nyr = 12

PETgrid = fltarr(nx,ny,ndk,nyr)

  openr,1,ifile 
  readu,1,PETgrid 
  close,1
  
  ;adjust the units? maybe this is why everything was so wet in my sim runs
  PETgrid = PETgrid*10
;add an extra yr to the petgrid so that it can run full 2012
;and multiply by 10 to get the units correct
;temp = reform(petgrid,nx,ny,432)
;temp =[  [[temp[*,*,*] ]], [[temp[*,*,396:431] ]]  ] 
;EROSpet = reform(temp,nx,ny,36,13);x,y,dek,yr

;for simulations i only want a single yr of PET...
PET02 = PETgrid[*,*,*,1]
;PET04 = PETgrid[*,*,*,3]
;PET05 = PETgrid[*,*,*,4]

PET02x2 = [ [[pet02]], [[pet02]] ]
;PET04x2 = [ [[pet04]], [[pet04]] ]
;PET05x2 = [ [[pet05]], [[pet05]] ]


;*******run with rainfall or soil moisture?****
;.compile /home/source/mcnally/scripts_idl/WRSI_millet_PR.pro
.compile /home/source/mcnally/scripts_idl/WRSI_millet_SM.pro



;***rainfall mask****************
ifile = file_search('/home/chg-mcnally/RAINmask.img')
mask = fltarr(NX,NY)
openr,1,ifile
readu,1,mask
close,1

mask(where(mask gt 0)) = 1

mask = rebin(mask,nx,ny,36)

;***********************************Gridded rainfall*************************
;I think it is better to read them one at a time...but i guess i need two years, so two at at time i, i+1
;checking out the uncertainty of 2002 and 2005 for starters
;ifile = file_search('/home/sandbox/people/mcnally/ubRFE04.19.2013/dekads/sahel/byyear/*.img');these are 2001-2012
;ifile = file_search('/home/sandbox/people/mcnally/RFE2_sahel/dekads/data.20{01,02,03,04,05,06,07,08,09,10,11,12,13}*.tiff')

;these are by year....
;ifile = file_search('/home/sandbox/people/mcnally/ubrf_sim/ubrf_2002_sim_720.350.36.??.bin')
;ifile = file_search('/home/sandbox/people/mcnally/ubrf_sim/ubrf_2005_sim_720.350.36.??.bin')
;
;NX = 720
;NY = 350
;ND = 36
;
;ingrid = fltarr(nx,ny,nd)
;ingrid2 = fltarr(nx,ny,nd)
;
;rcube = fltarr(nx,ny,nd,2)

;************************************Gridded Soil moisture**********************
;ifile = file_search('/home/chg-mcnally/SM0X3_scaled4WRSI.img')
;ifile = file_search('/home/chg-mcnally/SM0X2_scaled4WRSI.img')
;ifile = file_search('/home/chg-mcnally/NWET_scaled4WRSI.img')
;ifile = file_search('/home/chg-mcnally/ECV_MW_scaled4WRSI.img')
ifile = file_search('/home/sandbox/people/mcnally/ECVSM_2002_sim_720.250.36.??.bin')
;ifile = file_search('/home/sandbox/people/mcnally/MWSM_sim/Noah1m_2005_sim_720.250.36.??.bin')

;nz = 396
;nz = 432

;this can be used for sm01, sm02, sm0x
;;WRSI appears to be very high for SM0X3...
;SM0X  = fltarr(nx,ny,nz)
;;sm0X = fltarr(nx,ny,36,11); 2001-2011
;openr,1,ifile
;readu,1,SM0X
;close,1
;
;soilgrd = reform(SM0X,720,350,36,11)
;soilgrd(where(soilgrd lt 0))=!values.f_nan

NX = 720
NY = 250
ND = 36

ingrid = fltarr(nx,ny,nd)
ingrid2 = fltarr(nx,ny,nd)

scube = fltarr(nx,ny,nd,2)

;******initialize depending on station or whole sahel******
nyrs = n_elements(ifile)

;to run simulations for a specific year, these will have to be renamed
PETcube = PET02x2
;PETcube = PET05x2
;PETcube = PET04x2

WRSIgrid = fltarr(nx,ny,nyrs);nx,ny,nyrs
PAWgrid = fltarr(nx,ny,max(lgpgrid)+1,nyrs)
AETgrid = fltarr(nx,ny,max(lgpgrid)+1,nyrs)
SOSout = fltarr(nx,ny,nyrs)
KCgrid = fltarr(nx,ny,max(lgpgrid)+1,nyrs)

;read in two years...
for yr = 0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[yr]  &$
  readu,1,ingrid &$
  close,1 &$
  ingrid = ingrid*mask &$
  
  ;concatinate relevent pet into a 720x350x72
  
  if yr eq n_elements(ifile)-1 then begin &$
    ;rcube = [ [[ingrid]],[[ingrid]] ] &$
    scube = [ [[ingrid]],[[ingrid]] ] &$

    ;line below is for multi-year runs, not single year sim
    ;PETcube = [ [[PETgrid[*,*,*,yr] ]], [[PETgrid[*,*,*,yr]]] ] &$
  endif else begin &$
    openr,1,ifile[yr+1] &$
    readu,1,ingrid2 &$
    close,1 &$
    ingrid2 = ingrid2*mask &$
    
    scube = [ [[ingrid]], [[ingrid2]] ]  &$
    ;rcube = [ [[ingrid]], [[ingrid2]] ]  &$
    ;line below is for multi-year runs, not single year sim
    ;PETcube = [ [[ PETgrid[*,*,*,yr] ]], [[PETgrid[*,*,*,yr+1] ]] ]&$
  endelse &$

for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    ;loop/grid vs point
    ;if lgpgrid[x,y] eq 0 OR sosgrid[x,y] eq 0 OR sosgrid[x,y] eq 60 OR total(rcube[x,y,*],3, /nan) lt 0 then continue &$
    if lgpgrid[x,y] eq 0 OR sosgrid[x,y] eq 0 OR sosgrid[x,y] eq 60 OR total(scube[x,y,*],3, /nan) lt 0 then continue &$

     soil = reform(scube[x,y,*],72) &$
     ;rain = reform(rcube[x,y,*],72) &$
     pet = reform(PETcube[x,y,*],72) &$
     whc = whcgrid[x,y] &$
     lgp = lgpgrid[x,y]  &$ 
  
     ;make some changes if we need static vs dynamic SOS
     sos_ind = sosgrid[x,y]  &$
     ;new_wrsi = wrsi(rain, pet, whc=whc, lgp=lgp, pawout=tmppaw, aetout=tmpaet, sos_ind=sos_ind, kcout = tmpKC) &$
     new_wrsi = WRSI(SOIL, PET, WHC=WHC, LGP=LGP, pawout=tmppaw, aetout=tmpaet, SOS_ind=SOS_ind) &$
   
    ;IF outputing WRSI/SOS/LGP (scalar) 
     wrsigrid[x,y,yr] = new_wrsi &$ 
     ;SOSout[x,y,yr] = tmpsos &$
    ;this pads out the array so that different length of growing periods can be accomadiated.   
     pad = fltarr(max(lgpgrid)+1 -n_elements(tmppaw)) &$
     pad[*] = !values.f_nan &$
     PAWpad = [tmppaw,pad] &$
     AETpad = [tmpaet,pad] &$
     ;KCpad  = [tmpKC, pad] &$
     
     PAWgrid[x,y,*,yr] = PAWpad  &$
     AETgrid[x,y,*,yr] = AETpad  &$
     ;Kcgrid[x,y,*,yr]  = KCpad   &$
    endfor &$ ;yr 
  endfor &$ ;y
  print, yr &$
endfor &$
print, 'done'

ofile = '/home/sandbox/people/mcnally/wrsi_ECV_2002_750.250.sim100.img'
openw,1,ofile
writeu,1,wrsigrid
close,1

ofile = '/home/sandbox/people/mcnally/wrsi_ECV_AET_2002_750.250.sim100.img'
openw,1,ofile
writeu,1,aetgrid
close,1

ofile = '/home/sandbox/people/mcnally/wrsi_ECV_PAW_2002_750.250.sim100.img'
openw,1,ofile
writeu,1,pawgrid
close,1

;;save PAWout for comparison with other soil moisture estimates and station data. 
;PAWout = transpose(reform(PAWgrid[x,y,0:lgpgrid[x,y]-1,*])) & help, pawout
;PAWout = transpose(reform(AETgrid[x,y,0:lgpgrid[x,y]-1,*])) & help, pawout
;KCout = transpose(reform(KCgrid[x,y,0:lgpgrid[x,y]-1,*])) & help, KCout
;;make a timeseries of the PAW
;pcube = pawout
;PAWTS = fltarr(36,11)
;;this is dumb I should always use the automated system...
;LGP=lgp
;SOS = sosout[x,y,*] & print, sos
;;SOS = [19,  18,  16,  18,  15,  19,  17,  17,  16,  18,  18,  19]
;for yr = 0,n_elements(SOS)-2 do begin &$
;  start = 0  &$
;  ph1 = SOS[yr]-2 & print, ph1  &$
;  ph2 = SOS[yr]-1 & print, ph2 &$
;  ph3 = SOS[yr]-1+LGP-1 & print, ph3 &$
;  ph4 = SOS[yr]+LGP-1 & print, ph4 &$
;  fin = 35  &$
;  PAWTS[start:ph1,yr] = !values.f_nan  &$
;  PAWTS[ph2:ph3,yr] = pcube[yr,*]  &$
;  ;PAWTS[ph2:ph3,yr] = KCout[yr,*]  &$
;  PAWTS[ph4:fin,yr] = !values.f_nan  &$
;endfor
;paw = reform(pawts,396)
;ofile = '/jabber/chg-mcnally/NiameyAP_AETc36_2002_2012_SOS.15.16.08etc_LGP10_WHC125_PET.csv'
;;write_csv,ofile,paw

zeros = where(outgrid eq 0)
outgrid(zeros) = 255

.compile /home/source/mcnally/scripts_idl/make_wrsi_cmap.pro

p1 = image(byte(wrsigrid[*,*,50]), image_dimensions=[72.0,25.0], image_location=[-20,-5], dimensions=[nx,ny], $
            rgb_table=make_wrsi_cmap(),min_value=0, title = '2002 WRSI-ECV sim 10')
  c = colorbar(target=p1,orientation=0,/border_on, $
             position=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [0, -20, 20, 30], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

;ofile = '/home/chg-mcnally/EOS_WRSI_ubRFE2001_2012_staticSOS.img'
;openw,1,ofile
;writeu,1,wrsigrid
;close,1

end


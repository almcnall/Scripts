;# Development script to take Earth Observed precipitation and soil moisture and get crop yield
;# Written by Mark Carroll
;# Initial date 02/15/2012
;# Updated 02/23/2012
;# Added values for testing Indiana 03/21/2012
; moved over to IDL 12/28/12
; greg wrote separate funtions (see WRSI_millet.pro), now this just has inputs.
; 1/30/2013: This is the file for the gridded inputs -- to be used with the compiled WRSI_millet_PR/SM.pro
; 7/6/2012: updated to return SOS, AET, PAW and WRSI
; 6/25/14: ensemble runs
; 7/16/2014 call different exe for soil v rain sims

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
  
;adjust the units
PETgrid = PETgrid*10
;add an extra yr to the petgrid so that it can run full 2012
;temp = reform(petgrid,nx,ny,432)
;temp =[  [[temp[*,*,*] ]], [[temp[*,*,396:431] ]]  ] 
;EROSpet = reform(temp,nx,ny,36,13);x,y,dek,yr

;selet PET yr for simulations 
PET02 = PETgrid[*,*,*,1]
PET02x2 = [ [[pet02]], [[pet02]] ]

;*******run with rainfall or soil moisture?****
.compile /home/source/mcnally/scripts_idl/WRSI_millet_PR.pro
;.compile /home/source/mcnally/scripts_idl/WRSI_millet_SM.pro

;***rainfall mask to speed things up****************
ifile = file_search('/home/chg-mcnally/RAINmask.img')
mask = fltarr(NX,NY)
openr,1,ifile
readu,1,mask
close,1

mask(where(mask gt 0)) = 1
mask = rebin(mask,nx,ny,36)

;***********************************Gridded rainfall*************************
;Read two yrs at at time i, i+1
ifile = file_search('/home/sandbox/people/mcnally/ubRFE04.19.2013/dekads/sahel/byyear/*.img');these are 2001-2012

;sims by indv year....
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
;ifile = file_search('/home/chg-mcnally/SM0X2_scaled4WRSI.img')
;ifile = file_search('/home/chg-mcnally/ECV_MW_scaled4WRSI.img')
ifile = file_search('/home/sandbox/people/mcnally/ECVSM_2002_sim_720.250.36.??.bin')
;ifile = file_search('/home/sandbox/people/mcnally/MWSM_sim/Noah1m_2005_sim_720.250.36.??.bin')

;nz = 396
;nz = 432

NX = 720
NY = 250
ND = 36

ingrid = fltarr(nx,ny,nd)
ingrid2 = fltarr(nx,ny,nd)

scube = fltarr(nx,ny,nd,2)

;******initialize vars for WRSI calculation******
nyrs = n_elements(ifile)
;to run simulations for a specific year, these will have to be renamed
PETcube = PET02x2

WRSIgrid = fltarr(nx,ny,nyrs)
PAWgrid  = fltarr(nx,ny,max(lgpgrid)+1,nyrs)
AETgrid  = fltarr(nx,ny,max(lgpgrid)+1,nyrs)
SOSout   = fltarr(nx,ny,nyrs)
KCgrid   = fltarr(nx,ny,max(lgpgrid)+1,nyrs)

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
   
    ;IF outputing WRSI/SOS/LGP
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
end
;ofile = '/home/sandbox/people/mcnally/wrsi_ECV_2002_750.250.sim100.img'
;openw,1,ofile
;writeu,1,wrsigrid
;close,1
;
;ofile = '/home/sandbox/people/mcnally/wrsi_ECV_AET_2002_750.250.sim100.img'
;openw,1,ofile
;writeu,1,aetgrid
;close,1
;
;ofile = '/home/sandbox/people/mcnally/wrsi_ECV_PAW_2002_750.250.sim100.img'
;openw,1,ofile
;writeu,1,pawgrid
;close,1



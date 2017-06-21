pro LGP2_36deks

;***************************for the whole sahel*****************************
;***************************************************************************
;**********FILL OUT THE TIME SERIES OF PAW SO IT IS 36 DEKS*****************
;rfile = file_search('/jabber/chg-mcnally/RPAW_AET_sahel.img')
nfile = file_search('/jabber/chg-mcnally/NPAW_AET_sahel.img')
rfile = file_search('/jabber/chg-mcnally/SM01_AET_sahel.img')

SOSfile = file_search('/jabber/chg-mcnally/SOSsahel_ubRFE_2001_2001.img')
;SOSfile = file_search('/home/mcnally/regionmasks/SOSsahel.img')
;PAWfile = file_search('/jabber/chg-mcnally/sahel_ubRFE_PAW_dynSOS_WHC_LGP_PET.img')
ifile = file_search('/home/mcnally/regionmasks/LGPsahel.img')

nx = 720
ny = 350
nz = 11

SOSgrid = fltarr(nx,ny,nz)
lgpgrid = bytarr(nx,ny)
AETgrid = fltarr(nx,ny,22,nz)
;RAETgrid2 = fltarr(nx,ny,22,nz)
;sosgrid = bytarr(nx,ny)
;PAWgrid = fltarr(nx,ny,22,nz)

;a more general name would be better but i don;t want to change it from AET to PAW through the code.
PAWTS = fltarr(36,12)
PAW36 = fltarr(nx,ny,36,12)

openr,1,SOSfile
readu,1,SOSgrid
close,1

;openr,1,PAWfile
;readu,1,pawgrid
;close,1

openr,1,rfile
readu,1,AETgrid;this file w/ ndvi and RFE is good...
close,1

openr,1,ifile
readu,1,lgpgrid
close,1

;openr,1,ssfile
;readu,1,pawgrid2
;close,1

;it would probably be better to put this loop in the WRSI code so that they are just written out
; appropriately in the grid.
for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
     SOS = SOSgrid[x,y,*] &$
     for yr = 0,n_elements(SOS)-1 do begin &$
      if SOS[yr] gt 20 then continue &$
      if SOS[yr] lt 2 then continue &$
      ;print, SOS[yr] &$
      LGP = LGPgrid[x,y] &$
      if LGP eq 0 then continue &$
      start = 0  &$
      ph1 = SOS[yr]-2 &$
      ph2 = SOS[yr]-1 &$
      ph3 = SOS[yr]-1+LGP-1 &$
      ph4 = SOS[yr]+LGP-1 &$
      if ph4 ge 36 then continue &$ 
      fin = 35  &$
      PAWTS[start:ph1,yr] = !values.f_nan  &$
      ;PAWTS[ph2:ph3,yr] = pawgrid[x,y,0:LGP-1,yr]  &$
      PAWTS[ph2:ph3,yr] = AETgrid[x,y,0:LGP-1,yr]  &$
      PAWTS[ph4:fin,yr] = !values.f_nan  &$
      PAW36[x,y,*,yr] = PAWTS[*,yr] &$
    endfor &$  
  endfor &$
endfor

ofile = strcompress('/jabber/chg-mcnally/sahel_SM01_AET36_2001-2012_LGP_WHC.img', /remove_all)

openw,1,ofile
writeu,1,PAW36 ;this also has nothing in it.
close,1
;temp = fltarr(nx,ny,36,12)
;ifile = file_search('/jabber/chg-mcnally/sahel_NDVI_AET36_2001-2012_LGP_WHC.img')
;openr,1,ifile
;readu,1,temp
;close,1

p1=image(paw36[*,*,20,0] - temp[*,*,20,0])

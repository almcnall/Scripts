pro clip2Theo

;this files orgnaizes the princeton, chirps, rfe, ubRFE, ftip to the spacetime domain of theo
;13.125N to 13.875N, 1.625E to 2.875E 
;East @ 13.6496N 2.64920E
;West @ 13.6455N 2.6211E
;
;;to compare with the wankama and TK stations write out the corrosponding theo pixel then agregate to dekad.
;Wankama 2006 - 2011
wxind = FLOOR((2.632 - 1.625) / 0.25) ;4,2
wyind = FLOOR((13.6456 - 13.125) / 0.25)

;Tondikiboro 2006-2011
txind = FLOOR((2.6956 - 1.625) / 0.25);4,1
tyind = FLOOR((13.548 - 13.125) / 0.25)
;***theo's data*******
ifile = file_search('/home/sandbox/people/mcnally/AMMARain/Theo_rain*{2005,2006,2007,2008}_daily.img')
nx = 6
ny = 4
nz = 365
nzz = 366
r05 = fltarr(nx,ny,nz)
r06 = fltarr(nx,ny,nz)
r07 = fltarr(nx,ny,nz)
r08 = fltarr(nx,ny,nzz)

ingrid2 = fltarr(nx,ny,nzz)

out=[] ; what does this do?
;read 2005-2007
for i = 0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[0] &$
  readu,1,r05 &$
  close,1 &$
  
  openr,1,ifile[1] &$
  readu,1,r06 &$
  close,1 &$
  
  openr,1,ifile[2] &$
  readu,1,r07 &$
  close,1 &$
  
  openr,1,ifile[3] &$
  readu,1,r08 &$
  close,1 &$

endfor  

;get the stats...
mve, R05
R05block = mean(mean(R05,dimension=1),dimension=1)
;average over the whole grid. I think I will actually want this as a map. 

;how to I get number of rain days map?
;change the year each time or loop it
WET = R08
WET(WHERE(WET GT 0)) = 1
WET(WHERE(WET EQ 0)) = 0
ndays = (TOTAL(WET,3))
mve, ndays
NCOLORS=12
P1 = IMAGE(CONGRID(ndays,300,200),LAYOUT=[2,2,1], RGB_TABLE=20, MIN_VALUE=0,MAX_VALUE=120, /CURRENT)
RGBIND = FIX(FINDGEN(NCOLORS)*255./(NCOLORS-1))  &$  ; SET THE INDEX OF THE COLORS TO BE PULLED
RGBDUMP = P1.RGB_TABLE & RGBDUMP = CONGRID(RGBDUMP[*,RGBIND],3,256)  ; JUST REWRITES THE DISCRETE COLORBAR

RGBDUMP[*,0] = [255,255,255] ; SET MAP VALUES OF ZERO TO WHITE, YOU CAN CHANGE THE COLOR
P1.RGB_TABLE = RGBDUMP  ; REASSIGN THE COLORBAR TO THE IMAGE
C = COLORBAR(TARGET=P1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], FONT_SIZE=20, RANGE=[0,100]) 
P1.TITLE = 'N RAINDAYS 2008: THEO'
;*************************
;I probably also want the rainfall totals 
;for the sake of the CHIPRS maybe restrict it to the growing season...may-november/jun-october (152-305)
Tot = total(R08[*,*,152:305]/100,3); ugh, what are the units here? mm x 0.01
mve, tot
NCOLORS=30
P1 = IMAGE(CONGRID(tot,300,200),LAYOUT=[2,2,4], RGB_TABLE=20, MIN_VALUE=350,MAX_VALUE=650, /CURRENT)
P1.TITLE = 'Jun-Oct Tot 2008: THEO'

RGBIND = FIX(FINDGEN(NCOLORS)*255./(NCOLORS-1))  &$  ; SET THE INDEX OF THE COLORS TO BE PULLED
RGBDUMP = P1.RGB_TABLE & RGBDUMP = CONGRID(RGBDUMP[*,RGBIND],3,256)  ; JUST REWRITES THE DISCRETE COLORBAR
RGBDUMP[*,0] = [255,255,255] ; SET MAP VALUES OF ZERO TO WHITE, YOU CAN CHANGE THE COLOR
P1.RGB_TABLE = RGBDUMP  ; REASSIGN THE COLORBAR TO THE IMAGE
C = COLORBAR(TARGET=P1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], FONT_SIZE=20, RANGE=[0,100]) 

;***********CHIRPS DATAS, never mind they are 0.25 degree********************************
ifile05 = file_search('/home/sandbox/chirps/v1.8/daily_downscaled_by_monthly_full_rescale/p25/2005/*.tif')
ifile06 = file_search('/home/sandbox/chirps/v1.8/daily_downscaled_by_monthly_full_rescale/p25/2006/*.tif')
ifile07 = file_search('/home/sandbox/chirps/v1.8/daily_downscaled_by_monthly_full_rescale/p25/2007/*.tif')
ifile08 = file_search('/home/sandbox/chirps/v1.8/daily_downscaled_by_monthly_full_rescale/p25/2008/*.tif')

ingrid = read_tiff(ifile[0])
;there isn't a great way to know if theo's data is upside-down...

nx = 300
ny = 320

rlon = 2.875
llon = 1.625
blat = 13.125
tlat = 13.875
 ;chop down the file to the sahel window 
;Theo's Niger box - may need a little adjustment - see Pete's illustration. 
xleft = FLOOR((llon + 20)/0.25)
xright = FLOOR((rlon + 20)/0.25)

ybot = FLOOR((blat + 40)/0.25)
ytop = FLOOR((tlat + 40)/0.25)

stack05 = fltarr(6,4,n_elements(ifile05))
stack06 = fltarr(6,4,n_elements(ifile06))
stack07 = fltarr(6,4,n_elements(ifile07))
stack08 = fltarr(6,4,n_elements(ifile08))

for i = 0,n_elements(ifile05)-1  do begin  &$;
  ingrid = read_tiff(ifile05[i],GEOTIFF=g_tags)&$
  ingrid = reverse(ingrid,2) &$
  theo5 = ingrid[xleft:xright, ybot:ytop] &$
  
  ingrid6 =read_tiff(ifile06[i],GEOTIFF=g_tags)&$
  ingrid6 = reverse(ingrid6,2) &$
  theo6 = ingrid6[xleft:xright, ybot:ytop] &$
  
  ingrid7 =read_tiff(ifile07[i],GEOTIFF=g_tags)&$
  ingrid7 = reverse(ingrid7,2) &$
  theo7 = ingrid7[xleft:xright, ybot:ytop] &$
  
  
  stack05[*,*,i] = theo5 &$
  stack06[*,*,i] = theo6 &$
  stack07[*,*,i] = theo7 &$
      
endfor 


for i = 0,n_elements(ifile08)-1  do begin  &$;
  ingrid = read_tiff(ifile08[i],GEOTIFF=g_tags)&$
  ingrid = reverse(ingrid,2) &$
  theo8 = ingrid[xleft:xright, ybot:ytop] &$
  stack08[*,*,i] = theo8 &$
endfor

WET = stack08
WET(WHERE(WET GT 0)) = 1
WET(WHERE(WET EQ 0)) = 0
ndays = (TOTAL(WET,3))
mve, ndays

NCOLORS=12
P1 = IMAGE(CONGRID(ndays,300,200),LAYOUT=[2,2,4], RGB_TABLE=20, MIN_VALUE=0,MAX_VALUE=120, /current)
RGBIND = FIX(FINDGEN(NCOLORS)*255./(NCOLORS-1))  &$  ; SET THE INDEX OF THE COLORS TO BE PULLED
RGBDUMP = P1.RGB_TABLE & RGBDUMP = CONGRID(RGBDUMP[*,RGBIND],3,256)  ; JUST REWRITES THE DISCRETE COLORBAR

RGBDUMP[*,0] = [255,255,255] ; SET MAP VALUES OF ZERO TO WHITE, YOU CAN CHANGE THE COLOR
P1.RGB_TABLE = RGBDUMP  ; REASSIGN THE COLORBAR TO THE IMAGE
C = COLORBAR(TARGET=P1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], FONT_SIZE=20, RANGE=[0,100]) 
P1.TITLE = 'N RAINDAYS 2008: CHIRPS'
;*************************
;I probably also want the rainfall totals 
;for the sake of the CHIPRS maybe restrict it to the growing season...may-november/jun-october (152-305)
Tot = total(stack08[*,*,152:305],3); ugh, what are the units here? mm x 0.01
mve, tot
NCOLORS=30
P1 = IMAGE(CONGRID(tot,300,200),LAYOUT=[2,2,4], RGB_TABLE=20, MIN_VALUE=350,MAX_VALUE=650, /CURRENT)
P1.TITLE = 'Jun-Oct Tot 2008: CHIRPS'

RGBIND = FIX(FINDGEN(NCOLORS)*255./(NCOLORS-1))  &$  ; SET THE INDEX OF THE COLORS TO BE PULLED
RGBDUMP = P1.RGB_TABLE & RGBDUMP = CONGRID(RGBDUMP[*,RGBIND],3,256)  ; JUST REWRITES THE DISCRETE COLORBAR
RGBDUMP[*,0] = [255,255,255] ; SET MAP VALUES OF ZERO TO WHITE, YOU CAN CHANGE THE COLOR
P1.RGB_TABLE = RGBDUMP  ; REASSIGN THE COLORBAR TO THE IMAGE
C = COLORBAR(TARGET=P1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], FONT_SIZE=20, RANGE=[0,100]) 


;**********RFE2 from 2005-2008*************************** 
;1460 = 365*4 (I am missing a day...)
;a invented Nov 13, 2007 by copying Nov 12, 2007. this shouldn't matter much for west africa dry season but may matter elsewhere.
;ifile = file_search('/jabber/LIS/Data/CPCOriginalRFE2/all_products.bin.{2005,2006,2007,2008}*');
ifile = file_search('/jabber/LIS/Data/ubRFE2/all_products.bin.{2005,2006,2007,2008}*');
nx = 751
ny = 801

;theo dimensions
rlon = 2.875
llon = 1.625
blat = 13.125
tlat = 13.875
 ;chop down the file to the sahel window 
;Theo's Niger box - may need a little adjustment
xind1 = FLOOR((llon + 20.05)/0.1)
xind2 = FLOOR((rlon + 20.05)/0.1)

yind1 = FLOOR((blat + 40.05)/0.1)
yind2 = FLOOR((tlat + 40.05)/0.1)

;JUST WANKAMA, NOT THE BOX-THEO
xind = FLOOR((2.633 + 20.05) * 10.0)
yind = FLOOR((13.6454 + 40.05) * 10.0)

;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.05) / 0.10)
ayind = FLOOR((15.3540 + 40.05) / 0.10)

;and just to totally f-up this nice script i'll read in the station data here too
;i think that the month data didn't make it in?
ifile = file_search('/jabber/chg-mcnally/AMMARain/Agoufou_daily_2005_2008.csv')
rain = read_csv(ifile)
stack = rain.field4
;stack = fltarr(14,9,n_elements(ifile))
stack = fltarr(n_elements(ifile))
ingrid = fltarr(nx,ny)
for i = 0, n_elements(ifile)-1 do begin &$
  openr,1,ifile[i] &$
  readu,1,ingrid &$
  close,1 &$
  byteorder,ingrid,/XDRTOF &$
  
  ;stack[*,*,i] = ingrid[xind1:xind2,yind1:yind2] &$
  stack[i] = ingrid[axind,ayind] &$
    
endfor 

r05 = stack[0:364]
r0 = r05
mve, r0
r0b = r0
r0tot = total(r0b) & print, r0tot
wet = where(r0b gt 0, count, complement = dry) & print, count

R06 = stack[365:729]
R0 = R06
mve, R0
r0b = R0
r0tot = total(r0b) & print, r0tot
wet = where(r0b gt 0, count, complement = dry) & print, count

R07 = stack[730:1094]
R0 = R07
mve, R0
r0b = R0
r0tot = total(r0b) & print, r0tot
wet = where(r0b gt 0, count, complement = dry) & print, count

R08 = stack[1095:1459]
R0 = R08
mve, R0
r0b = R0
r0tot = total(r0b) & print, r0tot
wet = where(r0b gt 0, count, complement = dry) & print, count

;messed up the order to check out 2005-2008
;R09 =X

R10 = stack[1460:1824]
R0 = R10
mve, R0
r0b = R0
r0tot = total(r0b) & print, r0tot
wet = where(r0b gt 0, count, complement = dry) & print, count

R11 = stack[1825:2189]
R0 = R11
mve, R0
r0b = R0
r0tot = total(r0b) & print, r0tot
wet = where(r0b gt 0, count, complement = dry) & print, count
;
;ofile = strcompress('/jabber/chg-mcnally/AMMARain/UBRFE2_TheoBox_2006_2011.img')
;openw,1,ofile
;writeu,1,stack
;close,1
;*****************************************************************************
ifile = file_search('/jabber/chg-mcnally/AMMARain/UBRFE2_TheoBox_2005_2008.img')
nx = 14
ny = 9
nz = 1461

ingrid = fltarr(nx,ny,nz)
openr,1,ifile
readu,1,ingrid
close,1

R05 = ingrid[*,*,0:364]
R0 = R05
mve, R0
r0a = mean(r0, dimension=1, /nan)
r0b = mean(r0a, dimension=1, /nan)
r0tot = total(r0b) & print, r0tot
wet = where(r0b gt 0, count, complement = dry) & print, count

R06 = ingrid[*,*,365:729]
R0 = R06
mve, R0
r0a = mean(r0, dimension=1, /nan)
r0b = mean(r0a, dimension=1, /nan)
r0tot = total(r0b) & print, r0tot
wet = where(r0b gt 0, count, complement = dry) & print, count

R07 = ingrid[*,*,730:1094] & help, r07
R0 = R07
mve, R0
r0a = mean(r0, dimension=1, /nan)
r0b = mean(r0a, dimension=1, /nan)
r0tot = total(r0b) & print, r0tot
wet = where(r0b gt 0, count, complement = dry) & print, count

R08 = ingrid[*,*,1095:1460] & help, r08
R0 = R08
mve, R0
r0a = mean(r0, dimension=1, /nan)
r0b = mean(r0a, dimension=1, /nan)
r0tot = total(r0b) & print, r0tot
wet = where(r0b gt 0, count, complement = dry) & print, count

;*****old FCLIM that I used for unbiasing********
ifile = file_search('/jabber/LIS/Data/FCLIM_Afr/Fclim_Afr_cube.img')

nx = 1501
ny = 1601
nz = 12

rlon = 2.875
llon = 1.625
blat = 13.125
tlat = 13.875
 ;chop down the file to the sahel window 
;Theo's Niger box - may need a little adjustment - see Pete's illustration. 
xind1 = FLOOR((llon + 20)/0.05)
xind2 = FLOOR((rlon + 20)/0.05)

yind1 = FLOOR((blat + 40)/0.05)
yind2 = FLOOR((tlat + 40)/0.05)

ingrid = lonarr(nx,ny,nz)
openr,1,ifile
readu,1,ingrid
close,1

ingrid = reverse(float(ingrid),2)
stack = ingrid[xind1:xind2, yind1:yind2,*]

temp =image(mean(ingrid,dimension=3, /nan))

R0 = stack
mve, R0
r0a = mean(r0, dimension=1, /nan)
r0b = mean(r0a, dimension=1, /nan)
r0tot = total(r0b)
;filtering out gt 0.05 seems reasonable?
wet = where(r0b gt 0., count, complement = dry) & print, count, total(r0b(wet))

;****get the daily 2005-2008 CHIRP(S) data******ifile = file_search('/jower/sandbox/mcnally/CHIRP2005_2008/*.tif')


;ofile = strcompress('/jabber/chg-mcnally/AMMARain/CHIRP_TheoBox_2005_2008.img', /remove_all)
;ofile = strcompress('/jabber/chg-mcnally/AMMARain/FCLIM_TheoBox.img', /remove_all)
ofile = strcompress('/jabber/chg-mcnally/AMMARain/FTIP_TheoBox_2005_2008.img', /remove_all)

openw,1,ofile
writeu,1,stack
close,1
;**********************************************************
;ifile = file_search('/jabber/chg-mcnally/AMMARain/CHIRP_TheoBox_2005_2008.img')
;ifile = file_search('/jabber/chg-mcnally/AMMARain/FCLIM_TheoBox.img')
ifile = file_search('/jabber/chg-mcnally/AMMARain/FTIP_TheoBox_2005_2008.img')


nx = 26
ny = 16
nz = 1461
;nz = 365 ; for the FCLIM

ingrid = fltarr(nx,ny,nz)

openr,1,ifile
readu,1,ingrid
close,1

R05 = ingrid[*,*,0:364]
;R0 = R05
R0 = stack
mve, R0
r0a = mean(r0, dimension=1, /nan)
r0b = mean(r0a, dimension=1, /nan)
r0tot = total(r0b)
;filtering out gt 0.05 seems reasonable?
wet = where(r0b gt 0., count, complement = dry) & print, count, total(r0b(wet))

R06 = ingrid[*,*,365:729]
R0 = R06
mve, R0
r0a = mean(r0, dimension=1, /nan)
r0b = mean(r0a, dimension=1, /nan)
r0tot = total(r0b) & print, r0tot
wet = where(r0b gt 0, count, complement = dry) & print, count

R07 = ingrid[*,*,730:1094] & help, r07
R0 = R07
mve, R0
r0a = mean(r0, dimension=1, /nan)
r0b = mean(r0a, dimension=1, /nan)
r0tot = total(r0b) & print, r0tot
wet = where(r0b gt 0, count, complement = dry) & print, count

R08 = ingrid[*,*,1095:1460] & help, r08
R0 = R08
mve, R0
r0a = mean(r0, dimension=1, /nan)
r0b = mean(r0a, dimension=1, /nan)
r0tot = total(r0b) & print, r0tot
wet = where(r0b gt 0, count, complement = dry) & print, count

;********************get the chirpS data***********************
;ifile = file_search('/jower/sandbox/mcnally/CHIRPS4discover/2008*/*')
;
;;clip first and then make daily?
;nx = 751
;ny = 801
;
;rlon = 2.875
;llon = 1.625
;blat = 13.125
;tlat = 13.875
; ;chop down the file to the sahel window 
;;Theo's Niger box - may need a little adjustment - see Pete's illustration. 
;;;Theo's Niger box - may need a little adjustment
;xind1 = FLOOR((llon + 20.05)/0.1)
;xind2 = FLOOR((rlon + 20.05)/0.1)
;
;yind1 = FLOOR((blat + 40.05)/0.1)
;yind2 = FLOOR((tlat + 40.05)/0.1)
;
;stack = fltarr(14,9,n_elements(ifile))
;ingrid = fltarr(nx,ny)
;for i = 0, n_elements(ifile)-1 do begin &$
;  openr,1,ifile[i] &$
;  readu,1,ingrid &$
;  close,1 &$
;  byteorder,ingrid,/XDRTOF &$
;  
;  stack[*,*,i] = ingrid[xind1:xind2,yind1:yind2] &$
;endfor 
;
;;ofile = strcompress('/jabber/chg-mcnally/AMMARain/CHIRPS_TheoBox_2005_6hrly.img', /remove_all)
;;openw,1,ofile
;;writeu,1,stack
;;close,1
;
;raindata = stack
;;do these by year so that i can make 2008 = 366.
;d = 0
;cnt = 0
;day = fltarr(n_elements(raindata[*,0,0]), n_elements(raindata[0,*,0]), 366)
;tot = 0
;
;for x = 0, n_elements(raindata[*,0,0])-1 do begin &$
;  for y = 0, n_elements(raindata[0,*,0])-1 do begin &$
;    for z = 0, n_elements(raindata[0,0,*])-1 do begin &$
;      tot = tot + raindata[x,y,z] &$
;      cnt++  &$
;      if cnt eq 4 then day[x,y,d] = tot &$
;      if cnt eq 4 then d++  &$
;      if cnt eq 4 then tot = 0 &$
;      if cnt eq 4 then cnt = 0 &$  
;    endfor  &$;z
;    d = 0 &$
;    cnt = 0 &$
;    tot = 0 &$
;  endfor  &$;y
;endfor;x
;
;ofile = strcompress('/jabber/chg-mcnally/AMMARain/CHIRPS_TheoBox_2008_daily.img', /remove_all)
;openw,1,ofile
;writeu,1,day
;close,1
;*************************************************************************
ifile = file_search('/jabber/chg-mcnally/AMMARain/CHIRPS_TheoBox*daily.img')
nx = 14 
ny = 9
nz = 365
ingrid = fltarr(nx,ny,nz)
openr,1,ifile[0]
readu,1,ingrid
close,1
R05=ingrid*21600
R0 = R05
mve, R0
r0a = mean(r0, dimension=1, /nan)
r0b = mean(r0a, dimension=1, /nan)
r0tot = total(r0b) & print, r0tot
wet = where(r0b gt 0, count, complement = dry) & print, count

ingrid = fltarr(nx,ny,nz)
openr,1,ifile[1]
readu,1,ingrid
close,1
R06=ingrid*21600
R0 = R06
mve, R0
r0a = mean(r0, dimension=1, /nan)
r0b = mean(r0a, dimension=1, /nan)
r0tot = total(r0b) & print, r0tot
wet = where(r0b gt 0, count, complement = dry) & print, count

ingrid = fltarr(nx,ny,nz)
openr,1,ifile[2]
readu,1,ingrid
close,1
R07=ingrid*21600
R0 = R07
mve, R0
r0a = mean(r0, dimension=1, /nan)
r0b = mean(r0a, dimension=1, /nan)
r0tot = total(r0b) & print, r0tot
wet = where(r0b gt 0, count, complement = dry) & print, count

ingrid = fltarr(nx,ny,366)
openr,1,ifile[3]
readu,1,ingrid
close,1
R08=ingrid*21600
R0 = R08
mve, R0
r0a = mean(r0, dimension=1, /nan)
r0b = mean(r0a, dimension=1, /nan)
r0tot = total(r0b) & print, r0tot
wet = where(r0b gt 0, count, complement = dry) & print, count




;*************get the princeton data********
;might have to grab this from the nasa server
;junk 

;;*******************Wankama East& WEST station data*******************************
;;East @ 13.6496N 2.64920E
;;West @ 13.6455N 2.6211E
;;ifile = file_search('/jabber/chg-mcnally/AMMARain/wankamaWest_daily_2005_2008.csv');13.6455N 2.6211E
;ifile = file_search('/jabber/chg-mcnally/AMMARain/wankamaEast_daily_2005_2008.csv');13.6496,2.6492
;;yr, DOY, rain1, rain2 (?), nothing in wkw.field3...hmmmm
;wkw = read_csv(ifile)
;
;
;R05 = wkw.field4[0:364]
;R0 = R05
;mve, R0
;r0b = R0
;r0tot = total(r0b) & print, r0tot
;wet = where(r0b gt 0, count, complement = dry) & print, count
;
;R06 = wkw.field4[365:729]
;R0 = R06
;mve, R0
;r0b = R0
;r0tot = total(r0b) & print, r0tot
;wet = where(r0b gt 0, count, complement = dry) & print, count
;
;R07 = wkw.field4[730:1094] & help, r07
;R0 = R07
;mve, R0
;r0b = R0
;r0tot = total(r0b) & print, r0tot
;wet = where(r0b gt 0, count, complement = dry) & print, count
;
;R08 = wkw.field4[1095:1459] & help, r08
;R0 = R08
;mve, R0
;r0b = R0
;r0tot = total(r0b) & print, r0tot
;wet = where(r0b gt 0, count, complement = dry) & print, count

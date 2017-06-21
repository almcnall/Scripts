getEOS_WRSI_OND_forecast
;12-3-2013 update the MAM script to deal with the OND historial and forecasts.
;turns out i ran the WRSI for the Belg May2Sept (march?) so it is only for ethiopia.
;Nov29 ran the long rains...
; Use this script for the 1993-present comparisons with shrad.
; make another than does the extra 10 years. 
;this script extracts the WRSI value from Feb 20 of each season and plots it using the WRSI colors
;set path to here or recompile: /raid/chg-users/source/husak/idl_functions/make_wrsi_cmap.pro
;5/13/14 revisiting to get forecast percentiles and hopefully compare to FSO 

;NYY is the Nov 15 forecast 
exps15=['N00','N01','N02','N03','N04','N05','N06','N07','N08','N09','N10','N11','N12','N13','N14', 'N15','N16','N17','N18','N19', $
      'N20','N21','N22','N23','N24','N25','N26','N27','N28','N29' ]
      
exps1=['F00','F01','F02','F03','F04','F05','F06','F07','F08','F09','F10','F11','F12','F13','F14', 'F15','F16','F17','F18','F19', $
      'F20','F21','F22','F23','F24','F25','F26','F27','F28','F29' ]      

;this gradb the end-of-season forecast from each of the simulations
ifile = strarr(n_elements(exps1))
for i = 0,n_elements(exps1)-1 do begin &$
  ff = file_search(strcompress('/home/chg-mcnally/LISWRSI_OUTPUT/postprocess/EXP'+exps1[i]+'/201402280000.d01.gs4r', /remove_all)) &$
  ifile[i] = ff &$
endfor

nx = 285
ny = 339
nz = 40
ingrid = fltarr(nx,ny,nz)
heos = fltarr(nx,ny,n_elements(ifile))
feos1 = fltarr(nx,ny,n_elements(ifile))

for i=0, n_elements(ifile)-1 do begin &$
  openr,1,ifile[i] &$
  readu,1,ingrid  &$
  close,1 &$
  
  feos1[*,*,i] = ingrid[*,*,3] &$
endfor
;heos(where(heos ge 253))=!values.f_nan

Nov1_fx = feos1
Nov15_fx = feos
 
 ;******WHAT DO THE RAINFALL, WRSI AND SWI LOOKS
 ; LIKE FOR THE SEASON?
nx = 285
ny = 339
nz =  40

exps=['N00','N01','N02','N03','N04','N05','N06','N07','N08','N09','N10','N11','N12','N13','N14', 'N15','N16','N17','N18','N19', $
      'N20','N21','N22','N23','N24','N25','N26','N27','N28','N29' ]

ingrid = fltarr(nx,ny,40)
exprain = fltarr(nx,ny,18,n_elements(exps))
expswi = fltarr(nx,ny,18,n_elements(exps))
expwrsi = fltarr(nx,ny,18,n_elements(exps))

;ifile = strarr(n_elements(exps))

for i = 0,n_elements(exps)-1 do begin &$
  ;pull out the march-november months
  ff = file_search(strcompress('/raid/chg-mcnally/LISWRSI_OUTPUT/postprocess/EXP'+exps[i]+'/20??{09,10,11,12,01,02}*.gs4r', /remove_all)) &$
  for f = 0,n_elements(ff)-1 do begin &$
  openr,1,ff[f] &$
  readu,1,ingrid &$
  close,1 &$
  
  exprain[*,*,f,i] = ingrid[*,*,0] &$
  expswi[*,*,f,i] = ingrid[*,*,7] &$
  expwrsi[*,*,f,i] = ingrid[*,*,3] &$
  
  endfor &$
endfor
;mask out the rainfall to the expwrsi values (maybe do this in ENVI)
;temp=image(total(expwrsi[*,*,*,0],3,/nan))
;mask = expwrsi
;mask(where(mask ge 253))=!values.f_nan
;mask =total(mask[*,*,*,0],3,/nan)

;mask(where(mask gt 0))=1
;temp=image(total(mask[*,*,*,0],3,/nan))
shortrain = total(exprain,3,/nan)

;ofile = '/raid/chg-mcnally/MarNovRaintot.img'
;ofile = '/raid/chg-mcnally/MarNovRaintot_2000.img'
;openw,1,ofile
;writeu,1,reverse(longrain,2)
;close,1

;*******************************
;How often does a drought get below a certain threshold WRSI=80?
;open classmap and do a count.

nx = 285
ny = 339  
;it would probably be better to have these all merged...maybe next time.      
ifile = file_search('/raid/chg-mcnally/Rift_Admin2_classmap')
ifile2 = file_search('/raid/chg-mcnally/EastCentral_Admin2_classmap')

ingrid = bytarr(nx,ny)
ingride = bytarr(nx,ny)
ingridc = bytarr(nx,ny)

openr,1,ifile
readu,1,ingrid
close,1
ingrid = float(ingrid)
ingrid(where(ingrid eq 0.)) = !values.f_nan
ingrid = reverse(ingrid,2)

openr,1,ifile2
readu,1,ingride
close,1
ingride = float(ingride)
ingride(where(ingride eq 0.)) = !values.f_nan
ingride = reverse(ingride,2)

;these match up with results from ENVI.
Admin2= ['Turkana', 'WestPokot', 'Samburu', 'Baringo', 'Marakwet', 'TransNzoia', 'UasinGishu', 'Laikipia', $
         'Keiyo','NandiNorth', 'Koibatek', 'Nakuru', 'NandiSouth', 'Kericho', 'Buret', 'Narok', 'Bomet', 'TransMara', 'Kajiado']
Admin2E =[ 'Marsabit', 'Moyale' , 'Isiolo' , 'MeruNorth' ,'MeruCentral' ,'Nyandarua' ,'Tharaka' ,'Nyeri' ,'Mwingi' , 'Kirinyaga' ,'Embu' , 'MeruSouth',$
          'Mbeere' , 'Muranga' ,'Maragua' ,'Thika', 'Kiambu' , 'Machakos' , 'Kitui' ,'Makueni']
;Admin2E = ['Marsabit',  'Moyale',  'Isiolo',  'Meru.north',  'Meru.central',  'Tharaka', 'Mwingi',  'Embu',  'Meru.south' , 'Mbeere',  'Machakos',  'Kitui', 'Makueni']
;Admin2C = ['Nyandarua','Nyeri', 'Kirinyaga', 'Muranga', 'Maragua', 'Thika Kiambu']

;hari alphabet order: ['Kiambu', 'Kirinyaga', 'Maragua', 'Muranga', 'Nyandarua', 'Nyeri', 'Thika']
rain = fltarr(n_elements(Admin2),n_elements(shortrain[0,0,*]))
wrsi = fltarr(n_elements(Admin2),n_elements(shortrain[0,0,*]))

erain = fltarr(n_elements(Admin2e),n_elements(shortrain[0,0,*]))
ewrsi = fltarr(n_elements(Admin2e),n_elements(shortrain[0,0,*]))

;'0-Turkana', '1-WestPokot', 2-'Samburu',   '3-Baringo', '4-Marakwet', '5-TransNzoia', '6-UasinGishu', '7-Laikipia',   8-'Keiyo',9-'NandiNorth', 
;10-'Koibatek' 11-'Nakuru', 12-'NandiSouth' 13'Kericho', 14-'Buret',   15-'Narok',     16-'Bomet',     17-'TransMara' 18-'Kajiado']

;alphaorder RIFT:
;0/3-Baringo       1/16-Bomet        2/14-Buret      3/18-Kajiado  4/8-Keiyo      5/13-Kericho          6/10-Koibatek 7/7-Laikipia     8/4-Marakwet  9/11-Nakuru  
;10/9/12-Nandi(N/S)  11/15-Narok     12/2-Samburu 13-TransMara 14-TransNzoia      15-Turkana 16-UasinGishu  17-WestPokot
;
;EAST:
;Embu  Isiolo  Kitui Machakos  Makueni Marsabit  Mbeere  Meru Central  Meru North  Meru south  Moyale  Mwingi  Tharaka
;Marsabit Moyale  Isiolo  Meru.north  Meru.central  Tharaka Mwingi  Embu  Meru.south  Mbeere  Machakos  Kitui Makueni (class map order)

;RIFT
for i = 0,n_elements(admin2)-1 do begin &$
  dist = where(ingrid eq i+1, count) & print, count &$
  for y = 0, n_elements(shortrain[0,0,*])-1 do begin &$
  buffer2 = heos[*,*,y] &$
  buffer3 = shortrain[*,*,y] &$
  
  wrsi[i,y] = mean(buffer2(dist), /nan) &$
  rain[i,y] = mean(buffer3(dist), /nan) &$
  endfor &$
endfor 

;EAST
for i = 0,n_elements(admin2e)-1 do begin &$
  distE = where(ingride eq i+1, count) & print, count &$
  for y = 0, n_elements(shortrain[0,0,*])-1 do begin &$
  buffer2 = heos[*,*,y] &$
  buffer3 = shortrain[*,*,y] &$
  
  ewrsi[i,y] = mean(buffer2(distE), /nan) &$
  erain[i,y] = mean(buffer3(distE), /nan) &$
  endfor &$
endfor

;if I need them in Hari's yield data order...
alphaRN = [  rain[3,*], rain[16,*], rain[14,*],    rain[18,*], rain[8,*], rain[13,*],    rain[10,*], rain[7,*], rain[4,*], rain[11,*], $
         transpose(mean([rain[9,*],rain[12,*]],dimension=1,/nan)) , rain[15,*], rain[2,*],    rain[17,*], rain[5,*], rain[0,*], rain[6,*], rain[1,*]  ] 

alphaWR = [  wrsi[3,*], wrsi[16,*], wrsi[14,*],    wrsi[18,*], wrsi[8,*], wrsi[13,*],    wrsi[10,*], wrsi[7,*], wrsi[4,*], wrsi[11,*], $
         transpose(mean([wrsi[9,*],wrsi[12,*]],dimension=1,/nan)) , wrsi[15,*], wrsi[2,*],    wrsi[17,*], wrsi[5,*], wrsi[0,*], wrsi[6,*], wrsi[1,*]  ] 
         
;ok! finally, count the number of times a region is WRSI below 80
;how do i merge these two maps??
freq = fltarr(n_elements(admin2))
freqmap = ingrid
;for y = 0,n_elements(wrsi[0,*])-1 do begin &$
  for d = 0, n_elements(admin2)-1 do begin &$
    temp = where(wrsi[d,*] ge 80, complement=poor) &$
    freq[d] = n_elements(poor) &$
    freqmap(where(freqmap eq d+1)) = n_elements(poor) &$
  endfor

freqE = fltarr(n_elements(admin2e))
freqmapE = ingride
;for y = 0,n_elements(wrsi[0,*])-1 do begin &$
  for d = 0, n_elements(admin2e)-1 do begin &$
    temp = where(ewrsi[d,*] ge 80, complement=poor) &$
    freqE[d] = n_elements(poor) &$
    freqmapE(where(freqmapE eq d+1)) = n_elements(poor) &$
  endfor

;how to I merge these maps? I hope there is no overlap....
merge = total([[[freqmap]], [[freqmape]]], 3,/nan)
;take care of the 7 pixels that overlap
merge2=merge
merge2(where(merge2 gt 30))=30
;padout ingrid to match ECV (for now)
;remove the first pixel along left endge & add one on right edge
;rpad = fltarr(10,ny)
;rpad[*,*] = !values.f_nan
;ingrid=reverse(ingrid,2)
;
;ingrid2=[ingrid[10:284,*],rpad] & help, ingrid2  

;*******FINAL PLOT***********  
;vals = where(finite(merge2), complement = nulls)
merge2(where(merge2 eq 0))=-30

ncolors = 10    ; set the number of colors in the colorbar
p1 = image(merge2/30, image_dimensions=[nx/10,ny/10], image_location=[23.2,-11.5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=62,  MIN_VALUE=-0.01, MAX_VALUE=1) ; i dumped "transparency".  what the hell is that?
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
;rgbdump[*,0] = [255,255,255] ; set map values of zero to white, you can change the color
p1.rgb_table = rgbdump  ; reassign the colorbar to the image

c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON, $
              font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, 33, 5, 43], /overplot)
  p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 18 &$
  p1 = MAPCONTINENTS(/COUNTRIES, thick=5,  COLOR = [120, 120, 120])
;************************************** 
;VARIANCE MAPS
;ok! finally, count the number of times a region is WRSI below 80
;how do i merge these two maps??
varmap = ingrid
;for y = 0,n_elements(wrsi[0,*])-1 do begin &$
  for d = 0, n_elements(admin2)-1 do begin &$
    temp = variance(wrsi[d,*], /nan) &$
    varmap(where(varmap eq d+1)) = temp &$
  endfor

varmapE = ingride
;for y = 0,n_elements(wrsi[0,*])-1 do begin &$
  for d = 0, n_elements(admin2e)-1 do begin &$
    temp = variance(ewrsi[d,*], /nan) &$
    varmapE(where(varmapE eq d+1)) = temp &$
  endfor

;how to I merge these maps? I hope there is no overlap....
mergevar = total([[[varmap]], [[varmape]]], 3,/nan)
;take care of the 7 pixels that overlap
mergevar2=mergevar
;*************************************
;vals = where(finite(mergevar2), complement = nulls)
;mergevar2(nulls)=-1
mergevar2(where(mergevar2 eq 0))=-1

ncolors = 5   ; set the number of colors in the colorbar
p1 = image(mergevar2, image_dimensions=[nx/10,ny/10], image_location=[23.2,-11.5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=62,  MIN_VALUE=-0.05, MAX_VALUE=500) ; i dumped "transparency".  what the hell is that?
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
;rgbdump[*,0] = [255,255,255] ; set map values of zero to white, you can change the color
p1.rgb_table = rgbdump  ; reassign the colorbar to the image

c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON, $
              font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, 33, 5, 43], /overplot)
  p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 18 &$
  p1 = MAPCONTINENTS(/COUNTRIES, thick=5,  COLOR = [120, 120, 120])
  


;************************************** 
  
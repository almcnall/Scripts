;3/24/14 
;the purpose of this script is to make the LGP mask for Yemen.
;using the lgp_ek as a template
; if i calc LGP w/ climatological PET and precip...
; period (in days) during a year when precipitation 
; exceeds half the potential evapotranspiration. 

;read in the EROS PET,i made a clim PET for pre-2000 WRSI runs.
;check the units, compare monthly rainfall totals and average monthly PET? (maybe x30)
;good think i spent 1.5 days on something that didn't really really work.
;it says that some places have 9month growing season, which contradicts with the FAO map.
;it would be interesting to see how the FCLIM calculation differs from RFE2 average

ifile2 = file_search('/home/chg-mcnally/PET_USGS_daily/CLIM/*.bil')
nx = 360
ny = 181

mm = ['01','02','03','04','05','06','07','08','09','10','11','12']
mpet = fltarr(75,80,12)

month = strmid(ifile2,42,2) & print, month[0:40]

;read in each month, chop and average.
for i = 0, n_elements(mm)-1 do begin &$
  index = where(month eq mm[i]) &$
  f = ifile2(index) &$
  pet_stack = fltarr(75,80,n_elements(f)) &$
  for j = 0, n_elements(f)-1 do begin &$
    buffer = intarr(nx,ny) &$
    
    openr,1,f[j] &$
    readu,1,buffer &$
    close,1 &$
    byteorder,buffer,/XDRTOF &$
    
    buffer = float(buffer) &$
    buffer(where(buffer eq 0))=!values.f_nan &$
    
    buffer = reverse(buffer,2) &$
    pet_stack[*,*,j] = buffer[160:234,50:129] &$
  endfor &$
  mpet[*,*,i] = mean(pet_stack, dimension=3, /nan) &$
endfor

mpet = congrid(mpet, 751,801,12)
;temp = image(mean(mpet,dimension=3,/nan), rgb_table=4)
;clipping the congrid of mpet, the other is tooooo small...
yleft = (20+42)/0.10
yright= (20+54)/0.10
ybot  = (40+12)/0.10
ytop = (40+20)/0.10

;temp = image(mean(mpet[yleft:yright, ybot:ytop,*],dimension=3,/nan), rgb_table=4)

ympet = mpet[yleft:yright, ybot:ytop,*]

;use FCLIM for average monthly rainfall totals...there is something wrong with Dec fclim
;in the '/home/chg-mcnally/FCLIM_Afr/')
;maybe try the fclim from /home/FCLIM/2012.01.18/monthly

xt = 7200
yt = 2000
ifile = file_search('/home/FCLIM/2012.01.18/monthly/*.tif')
;readin, clip and stack
;clip = 
left = (180-20)/0.05
right = (180+55)/0.05
bottom = 10/0.05
top = yt-bottom
af_stack = fltarr(751,801,12)
ym_stack = fltarr(121,81,12)

yleft = (180+42)/0.05
yright = (180+54)/0.05
ybot = (50+12)/0.05
ytop = yt-((50-20)/0.05)

for i = 0, 12 -1 do begin &$
 data = read_tiff(ifile[i]) &$
 clip = data[left:right, bottom:top] &$
 yclip = data[yleft:yright, YBOT:YTOP] &$
 
 agg = congrid(clip,751,801) &$
 Y_agg = congrid(yclip,121,81) &$
 
 af_stack[*,*,i] = agg &$
 ym_stack[*,*,i] = y_agg &$
endfor

;ok now that i have my datas how do i make this map?
;number of months where PPT > PET/2
grow = fltarr(751,801,12)
mappy = fltarr(751,801,12)
lgp_stack = fltarr(751,801,12)

;;it worked just as well to do this as an array operation.
;for i = 0,12-1 do begin &$
;  grow = where(stack[*,*,i] gt mpet[*,*,i]/2, complement=dry, count) & print, count &$
;  monthmap = mappy[*,*,i] &$
;  monthmap(grow) = 1 &$
;  monthmap(dry) = 0 &$
;  lgp_stack[*,*,i] = monthmap &$
;endfor

;it looks much more like the expected growing season maps when I use 1/3 PET rather than 1/2
;could this be a problem with the FCLIM bias? fews/wrsi reports its growing seasons 
;in dekads...which suggests a smoother approach
  grow = where(af_stack gt mpet/4, complement=dry, count) & print, count &$
  mappy(grow) = 1
  mappy(dry) = 0
  
 ;and for yemen:
  ymappy = fltarr(121,81,12)
  ygrow = where(ym_stack gt ympet/16, complement=ydry, count) & print, count
  ymappy(ygrow) = 1
  ymappy(ydry) = 0
  
  mve, total(ymappy,3)
  outlgp = reverse(byte(total(ymappy,3)),2)
  
  ncolors = 5
  p1 = image(reverse(float(outlgp),2), rgb_table=20, image_dimensions=[12.0,8.0],$
               image_location=[42,12],dimensions=[120,80])
  c = COLORBAR(target=temp,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.1,0.7,0.13],$
              font_size=20, range=[0,100])           
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
 rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
 rgbdump[*,0] = [200,200,200]
  p1.rgb_table = rgbdump  ;
 
  p1 = MAP('Geographic',LIMIT = [12,42, 20, 54], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)
  
;I guess i should keep twizingly this for Yemen...what is the domain that i am using?
;I had 121x71....120x80 might make sense.
;nx = 123
;ny = 79
;
;Run domain lower left lat:          12.050
;Run domain lower left lon:          42.050   #  ulxmap ??. - mask
;Run domain upper right lat:         19.950   #  ulymap ?? - mask
;Run domain upper right lon:         54.350

;maybe change these to round numbers...and make sure the mask matches...
;to match the other files it has to by upsidedown, byte

ofile = strcompress('/home/chg-mcnally/regionmasks/lgp_ym.bil', /remove_all)
openw,1,ofile
writeu,1,outlgp
close,1

ifile = file_search('/home/chg-mcnally/regionmasks/lgp_ym.bil')
lgrid = bytarr(121,81)
openr,1,ifile
readu,1,lgrid
close,1

;not sure what the .blw, .stx format should be...


;*****example output file******
ifile = file_search('/raid/ftp_out/people/mcnally/lis/regionmasks/lgp_ee.bil')

ny = 579
nx = 445

ingrid = bytarr(nx,ny)

openr,1,ifile
readu,1,ingrid
close,1

ingrid2 = float(ingrid)
ingrid2(where(ingrid2 eq 0))=!values.f_nan

temp = image(reverse(INGRID2,2), rgb_table=4)

;junk*****
;
;africa = fltarr(751,801,n_elements(ifile2))
;for i = 0,n_elements(ifile2)-1 do begin &$
;  ingrid2 = intarr(nx,ny) &$
;  openr,1, ifile2[i] &$
;  readu,1, ingrid2 &$
;  close,1 &$
;
;  byteorder,ingrid2,/XDRTOF &$
;
;  ;this is what is should be....but doesn't look quite right, shifted too much
;  africa[*,*,i] = reverse(congrid(ingrid2[160:234,50:130], 751,801),2) &$
;;temp = image(africa, rgb_table=4)
;endfor
;
;;or just use the same code for the PET as for the RFE rainfall....
;
;ifile = file_search('/home/RFE2/daily/africa_rfe.20*.tif')
;
;nx = 751
;ny = 801
;
;mm = ['01','02','03','04','05','06','07','08','09','10','11','12']
;mrain = fltarr(751,801,12)
;
;month = strmid(ifile,32,2) & print, month[0:40]
;
;;read in each month and average....this works but takes a very long time
;;check with the FCLIM instead...
;for i = 0, n_elements(mm)-1 do begin &$
;  index = where(month eq mm[i]) &$
;  f = ifile(index) &$
;  rain_stack = fltarr(751,801,n_elements(f)) &$
;  for j = 0, n_elements(f)-1 do begin &$
;   ; buffer = fltarr(nx,ny) &$
;    buffer = read_tiff(f[j]) &$
;    print, 'reading'+f[j] &$
;    ;close,/all &$
;    buffer = reverse(buffer,2) &$
;    rain_stack[*,*,j] = buffer &$
;  endfor &$
;  mrain[*,*,i] = mean(rain_stack, dimension=3, /nan) &$
;endfor
;
;mpet = congrid(mpet, 751,801,12)
;temp = image(mean(mpet,dimension=3,/nan), /overplot, transparency=60)
;;******************************
;
;;which rainfall should i use? CHIRPS? or RFE? something daily....
;
;;read rainfall into cubes so i can get the average...or use fclim, no that is monthly
;
;yy = ['01', '02','03','04','05','06','07','08','09','10','11','12','13']
;mm = ['01','02','03','04','05','06','07','08','09','10','11','12']
;
;nx = 751
;ny = 801
;
;cube = fltarr(nx,ny,366)
;cube[*,*,*] = !values.f_nan
;
;
;for y = 0,n_elements(yy)-1 do begin &$
;  ifile = file_search('/home/RFE2/daily/africa_rfe.20'+yy[y]+'*.tif') &$
;  for i = 0, n_elements(ifile)-1 do begin &$
;    ingrid = read_tiff(ifile[i]) &$ 
;    if y eq 0 then cube[*,*,i] = ingrid else cube[*,*,i] = mean([[[cube[*,*,i]]], [[ingrid]]], dimension=3,/nan) &$       
;  endfor &$
;endfor
;
;cube2 = cube
;cube2(where(cube2 gt 2000, count))=2000
;cube2=reverse(cube2,2)
;
;ifile2 = file_search('/home/chg-mcnally/PET_USGS_daily/CLIM/*.bil')
;nx = 360
;ny = 181
;
;africa = fltarr(751,801,n_elements(ifile2))
;for i = 0,n_elements(ifile2)-1 do begin &$
;  ingrid2 = intarr(nx,ny) &$
;  openr,1, ifile2[i] &$
;  readu,1, ingrid2 &$
;  close,1 &$
;
;  byteorder,ingrid2,/XDRTOF &$
;
;  ;this is what is should be....but doesn't look quite right, shifted too much
;  africa[*,*,i] = reverse(congrid(ingrid2[160:234,50:130], 751,801),2) &$
;;temp = image(africa, rgb_table=4)
;endfor
;;ok, so i have annual daily rainfall, i guess i need to subset and re-grid PET
;;and then compute the LGP
;
;temp=image(mean(africa, dimension=3, /nan)/100,rgb_table=4)
; c = COLORBAR(target=temp,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.1,0.7,0.13],$
;              font_size=20, range=[0,100])
;              
;;ugh, i guess this was supposed to be monthly...maybe i can just smooth :)
;;smoothing PET is ok, smoothing rain is not. i guess just use the FCLIM
;;and making monthly averages is easy. 
;sm_pet = smooth(africa,[1,1,30])
;sm_rain = smooth(cube2,[1,1,30])
;
;
;
;


getEOS_WRSI82

; Use this script for full chirps time series.
;this script extracts the WRSI value from dek3 of Feb of each season and plots it using the WRSI colors
;set path to here or recompile: /raid/chg-users/source/husak/idl_functions/make_wrsi_cmap.pro
;1983-2012
;districts of interet are:
;Baringo
;Bomet
;Bureti
;Kajiado
;Keiyo
;Kericho
;Koibatek
;Laikipia
;Marakwet
;Nakuru
;Nandi 
;Narok
;Samburu
;Trans Mara
;Trans Nzoia
;Turkana
;Uasin Gishu
;West Pokot
;I couldn't figure this out so i did it in ENVI.....
; ifile = file_search('/raid/chg-mcnally/*shp')
; shp = OBJ_new('IDLffShape',ifile)
; shp->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
; vals = shp->getAttributes( /ALL) ;can I cat the years here?
; countries = vals.attribute_6 ;i dunno why i have to do this to make it work....
; 
;FOR x=0L, (num_ent-1) DO BEGIN &$
;   ; Get the Attributes for entity x
;   attr = shp->GetAttributes(x) &$
;   ; See if 'Colorado' is in ATTRIBUTE_1 of the attributes for
;   ; entity x
;   IF vals.attribute_6(where(vals.attribute_6 eq 'Kenya')) EQ 'Kenya' THEN BEGIN &$
;    print, 'kenya!'&$
;      ; Get entity
;;      ent = shp->GetEntity(x) &$
;;      ; Plot entity
;;      POLYFILL, (*ent.VERTICES)[0, *], (*ent.VERTICES)[1, *],COLOR=yellow  &$
;;      ; Clean-up of pointers
;;      myshape->DestroyEntity, ent  &$
;   ENDIF &$
;ENDFOR

;pase the attribute table:
lat=


ifile = file_search(strcompress('/raid/chg-mcnally/LISWRSI_OUTPUT/postprocess/EXP{0,1}*/20??022{8,9}0000.d01.gs4r', /remove_all))

nx = 285
ny = 339
nz = 40
ingrid = fltarr(nx,ny,nz)
heos = fltarr(nx,ny,n_elements(ifile))
for i=0, n_elements(ifile)-1 do begin &$
  openr,1,ifile[i] &$
  readu,1,ingrid  &$
  close,1 &$
  
  heos[*,*,i] = ingrid[*,*,3] &$
endfor
;fixing the colors and figureing out what <100 means


p1=image(heos[*,*,0], RGB_TABLE=make_wrsi_cmap())
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
;somehow this makes the water blue.
tmpclr = p1.rgb_table
tmpclr[*,0] = [170,170,255]
p1.rgb_table = tmpclr
             
;255=non-active, 254=yet to start, 253 = no start, late.
heos(where(heos ge 253))=1
;how did i extract the crop zones from the data before??
ofile = '/home/mcnally/EOS_cube_Nov23.img'
openw,1,ofile
writeu,1,reverse(heos,2)
close,1

nfile = file_search('/raid/chg-mcnally/LISWRSI_OUTPUT/postprocess/EXPN*/201402280000.d01.gs4r')
nx = 285
ny = 339
nz = 40
ingrid = fltarr(nx,ny,nz)
neos = fltarr(nx,ny,n_elements(nfile))

for i=0, n_elements(nfile)-1 do begin &$
  openr,1,nfile[i] &$
  readu,1,ingrid  &$
  close,1 &$
  
  neos[*,*,i] = ingrid[*,*,3] &$
endfor


ffile = file_search('/raid/chg-mcnally/LISWRSI_OUTPUT/postprocess/EXPF*/201402280000.d01.gs4r')
nx = 285
ny = 339
nz = 40
ingrid = fltarr(nx,ny,nz)
feos = fltarr(nx,ny,n_elements(ffile))

for i=0, n_elements(ffile)-1 do begin &$
  openr,1,ffile[i] &$
  readu,1,ingrid  &$
  close,1 &$
  
  feos[*,*,i] = ingrid[*,*,3] &$
endfor

;bot lat, left lon, top lat, right lon
;[-5, -20, 30, 52]
;
;-11.75, 22.95, 22.05, 51.35


  
   ;chop down the file to the forecast window 
  xlt = (36-22.95)/0.1  &$;RFE goes to 55, sahel goes to 52 plus an extra pixel
  ybot = (11.75-2)/0.1   &$ ;sahel starts at -5S
  ytop = ny-(22.05-8)/0.1  &$; &$sahel stops at 30N
  xrt = nx-(51.35-46)/0.1     &$          ;and I guess sahel starts at 19W, rather than 20....
  hwrsi_box = heos[xlt:xrt,ybot:ytop,*]
  fwrsi_box = feos[xlt:xrt,ybot:ytop,*]
  nwrsi_box = neos[xlt:xrt,ybot:ytop,*]
 nwrsi_box(where(nwrsi_box eq 255, count))=!values.f_nan & print, count
 p1 = image(byte(mean(nwrsi_box, dimension=3, /nan)), image_dimensions=[10.2,10.2], image_location=[36,-2], dimensions=[102/100,102/100], $
            RGB_TABLE=make_wrsi_cmap(),MIN_VALUE=0, title = 'mean Nov-15 forecast LIS-WRSI')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  
tmpclr = p1.rgb_table
tmpclr[*,0] = [170,170,255]
p1.rgb_table = tmpclr
;  
 p1 = MAP('Geographic',LIMIT = [-2, 36, 8, 46], /overplot) ;what are shrad's 
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
 

  fstats = fltarr(2,n_elements(ffile))
  hstats = fltarr(2,n_elements(ifile))
  nstats = fltarr(2,n_elements(nfile))

  fthresh = fltarr(2,n_elements(ffile))
  hthresh = fltarr(2,n_elements(ifile))
  nthresh = fltarr(2,n_elements(nfile))
  
    for i = 0,n_elements(ifile)-1 do begin &$
     hwindow = hwrsi_box[*,*,i] &$   
     ;locate the areas that are no start 255 and change to !values.f_nan
     hbad = where(hwindow[*,*] gt 100., count, complement=good) &$    
     hwindow(hbad)=!values.f_nan &$
     
     hstats[0,i] = mean(hwindow[*,*], /nan) &$
     hstats[1,i] = median(hwindow[*,*]) &$
     
     tot = where(finite(hwindow), count) &$
     high = where(hwindow gt 95, count) &$
     low = where(hwindow le 60, count) &$
     
     hthresh[0,i] = float(n_elements(high))/float(n_elements(tot))  &$
     hthresh[1,i] = float(n_elements(low))/float(n_elements(tot)) &$

  endfor
  print, hstats
  print, hthresh*100; high, low
  
 for i = 0,n_elements(nfile)-1 do begin &$
     nwindow = nwrsi_box[*,*,i] &$   
     ;locate the areas that are no start 255 and change to !values.f_nan
     nbad = where(nwindow[*,*] gt 100., count, complement=good) &$    
     nwindow(nbad)=!values.f_nan &$
     
     nstats[0,i] = mean(nwindow[*,*], /nan) &$
     nstats[1,i] = median(nwindow[*,*]) &$
     
     tot = where(finite(nwindow), count) &$
     high = where(nwindow gt 95, count) &$
     low = where(nwindow le 60, count) &$
     
     nthresh[0,i] = float(n_elements(high))/float(n_elements(tot))  &$
     nthresh[1,i] = float(n_elements(low))/float(n_elements(tot)) &$

  endfor
  print, nstats
  print, nthresh*100; high, low
  
  
  
    
  for i = 0,n_elements(ffile)-1 do begin &$
     fwindow = fwrsi_box[*,*,i] &$
     
     ;locate the areas that are no start 255 and change to !values.f_nan
     fbad = where(fwindow[*,*] gt 100., count, complement=good) &$
     
     fwindow(fbad)=!values.f_nan &$

     fstats[0,i] = mean(fwindow[*,*], /nan) &$
     fstats[1,i] = median(fwindow[*,*]) &$
     
     tot = where(finite(fwindow), count)  &$
     high = where(fwindow gt 95, count)  &$
     low = where(fwindow le 60, count)  &$
     
     fthresh[0,i] = float(n_elements(high))/float(n_elements(tot))  &$
     fthresh[1,i] = float(n_elements(low))/float(n_elements(tot)) &$
  endfor
  print, fstats
  print, fthresh*100
 
 ;histogram of the historical and forecast wrsi
 indata = fstats[0,*]
tmphist = histogram(indata,NBINS=8,OMAX=omax,OMIN=omin)
bplot = barplot(tmphist,FILL_COLOR='yellow')
nticks = 5
xticks = STRARR(nticks)
for i=0,nticks-1 do xticks(i) = STRING(FORMAT='(I-)',FLOOR(omin + (i * (omax - omin) / (nticks -1))))
bplot.xtickname = xticks
bplot.title = 'Histogram of forecast WRSI'
 
 ;WHAT DO THE RAINFALL, WRSI AND SWI LOOKS LIKE FOR THE SEASON?
b = 102
nx = 285
ny = 339
nz =  40

xlt = (36-22.95)/0.1    ;RFE goes to 55, sahel goes to 52 plus an extra pixel
ybot = (11.75-2)/0.1    ;sahel starts at -5S
ytop = ny-(22.05-8)/0.1 ; &$sahel stops at 30N
xrt = nx-(51.35-46)/0.1

ingrid = fltarr(nx,ny,40)
exprain = fltarr(b,b,24,20)
expswi = fltarr(b,b,24,20)
expwrsi = fltarr(b,b,24,20)

exps=['093','094', '095','096','097','098','099','100','101','102','103','104','105','106','107','108','109','110','111','112']

for i = 0,n_elements(exps)-1 do begin &$
  ff = file_search(strcompress('/raid/chg-mcnally/LISWRSI_OUTPUT/postprocess/EXP'+exps[i]+'/20??{10,11,12,01,02,03,04,05}*.gs4r', /remove_all)) &$
  for f = 0,n_elements(ff)-1 do begin &$
  openr,1,ff[f] &$
  readu,1,ingrid &$
  close,1 &$
  
  exprain[*,*,f,i] = ingrid[xlt:xrt,ybot:ytop,0] &$
  expswi[*,*,f,i] = ingrid[xlt:xrt,ybot:ytop,7] &$
  expwrsi[*,*,f,i] = ingrid[xlt:xrt,ybot:ytop,3] &$
  
  endfor &$
endfor

expwrsi(where(expwrsi gt 100))=!values.f_nan
box_wrsi = mean(mean(expwrsi[*,*,0:9,*], dimension=1, /nan), dimension=1,/nan) & help, box_wrsi

for p=0,20-1 do begin &$
  p1 = plot(box_wrsi[*,p], /overplot, name = 'forecast realization') &$
 endfor
p1.xminor=0
p1.yminor=0
p1.xtickname = ['Oct', 'Nov', 'Dec', 'Jan']
p1. xtickvalues = [0,3,6,9]


biggrid = rebin(expwrsi,102*2, 102*2, 24,20)

;look at November-December WRSI to see why there is such a decline.
  p1 = image(mean(biggrid[*,*,9,*], dimension=4, /nan), image_location=[36,-2], $
            RGB_TABLE=4,MIN_VALUE=0, title = 'mean Jan LIS-WRSI')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-11, 22, 15, 51], /overplot) ;what are shrad's 
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])


;what is the rainfall total for each seaon? 2010 driiest, 1997 wettest
boxtot = total(mean(mean(exprain[*,*,0:14,*],dimension=1,/nan),dimension=1,/nan),1,/nan) & print, transpose(boxtot)

;what is the average dekadal rainfall and SWI
avgdekrain = mean(mean(mean(exprain[*,*,0:14,*], dimension=1, /nan),dimension=1, /nan),dimension=2, /nan) & help, avgdekrain

expwrsi(where(expwrsi gt 100))=!values.f_nan
avgdekwrsi = mean(mean(mean(expwrsi[*,*,0:14,*], dimension=1, /nan),dimension=1, /nan),dimension=2, /nan) & help, avgdekwrsi

expswi(where(expswi gt 100))=!values.f_nan
avgdekswi = mean(mean(mean(expswi[*,*,0:14,*], dimension=1, /nan),dimension=1, /nan),dimension=2, /nan) & help, avgdekswi

p1 = plot(avgdekrain)
p1 = plot(avgdekwrsi)
p1 = plot(avgdekswi)

;**************************************************************
b=102
ningrid = fltarr(nx,ny,40)
nexprain = fltarr(b,b,24,30)
nexpswi = fltarr(b,b,24,30)
nexpwrsi = fltarr(b,b,24,30)


exps=['00','01', '02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29' ]
for i = 0,n_elements(exps)-1 do begin &$
 nf = file_search(strcompress('/raid/chg-mcnally/LISWRSI_OUTPUT/postprocess/EXPN'+exps[i]+'/20??{10,11,12,01,02,03,04,05}*.gs4r', /remove_all)) &$
  for f = 0,n_elements(nf)-1 do begin &$
  openr,1,nf[f] &$
  readu,1,ningrid &$
  close,1 &$
  
  nexprain[*,*,f,i] = ningrid[xlt:xrt,ybot:ytop,0] &$
  nexpswi[*,*,f,i] = ningrid[xlt:xrt,ybot:ytop,7] &$
  nexpwrsi[*,*,f,i] = ningrid[xlt:xrt,ybot:ytop,3] &$
  
  endfor &$
endfor

;what is the rainfall total for each seaon? 2010 driiest, 1997 wettest
boxtot = total(mean(mean(nexprain[*,*,0:14,*],dimension=1,/nan),dimension=1,/nan),1,/nan) & print, transpose(boxtot)

;plot all the different realizations for oct-may
nexpwrsi(where(nexpwrsi gt 100))=!values.f_nan
nbox_wrsi = mean(mean(nexpwrsi[*,*,0:14,*], dimension=1, /nan), dimension=1,/nan) & help, nbox_wrsi
navgdekwrsi = mean(mean(mean(nexpwrsi[*,*,0:14,*], dimension=1, /nan),dimension=1, /nan),dimension=2, /nan) & help, navgdekwrsi

for p=0,30-1 do begin &$
  p1 = plot(nbox_wrsi[*,p], /overplot, name = 'forecast realization') &$
 endfor
p2=plot(avgdekwrsi, thick=5, /overplot, name = 'historiacal avg WRSI')
p3=plot(navgdekwrsi, thick=5, 'b',/overplot, name = 'Nov-15 forecast avg WRSI')
p4=plot(favgdekwrsi, thick=3, linestyle=2, 'b',/overplot, name = 'Nov-1 forecast avg WRSI')
!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3]) ; 
p3.xminor=0
p3.yminor=0
p3.xtickname = ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar']
p3. xtickvalues = [0,3,6,9,12,15]



;now read in the forecasts and see how they compare....
b=102
fingrid = fltarr(nx,ny,40)
fexprain = fltarr(b,b,24,30)
fexpswi = fltarr(b,b,24,30)
fexpwrsi = fltarr(b,b,24,30)


exps=['00','01', '02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29' ]
for i = 0,n_elements(exps)-1 do begin &$
 ff = file_search(strcompress('/raid/chg-mcnally/LISWRSI_OUTPUT/postprocess/EXPF'+exps[i]+'/20??{10,11,12,01,02,03,04,05}*.gs4r', /remove_all)) &$
  for f = 0,n_elements(ff)-1 do begin &$
  openr,1,ff[f] &$
  readu,1,fingrid &$
  close,1 &$
  
  fexprain[*,*,f,i] = fingrid[xlt:xrt,ybot:ytop,0] &$
  fexpswi[*,*,f,i] = fingrid[xlt:xrt,ybot:ytop,7] &$
  fexpwrsi[*,*,f,i] = fingrid[xlt:xrt,ybot:ytop,3] &$
  
  endfor &$
endfor

;what is the rainfall total for each seaon? 2010 driiest, 1997 wettest
boxtot = total(mean(mean(fexprain[*,*,0:14,*],dimension=1,/nan),dimension=1,/nan),1,/nan) & print, transpose(boxtot)

;plot all the different realizations for oct-may
fexpwrsi(where(fexpwrsi gt 100))=!values.f_nan
fbox_wrsi = mean(mean(fexpwrsi[*,*,0:14,*], dimension=1, /nan), dimension=1,/nan) & help, fbox_wrsi
favgdekwrsi = mean(mean(mean(fexpwrsi[*,*,0:14,*], dimension=1, /nan),dimension=1, /nan),dimension=2, /nan) & help, favgdekwrsi

for p=0,30-1 do begin &$
  p1 = plot(fbox_wrsi[*,p], /overplot, name = 'forecast realization') &$
 endfor
p2=plot(avgdekwrsi, thick=5, /overplot, name = 'historiacal avg WRSI')
p3=plot(favgdekwrsi, thick=5, 'b',/overplot, name = 'forecast avg WRSI')
!null = legend(target=[p1,p2,p3], position=[0.2,0.3]) ; 
p3.xminor=0
p3.yminor=0
p3.xtickname = ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar']
p3. xtickvalues = [0,3,6,9,12,15]
 ; PLOT GOOD/MARGINAL/POOR AG LAND
 fwindow(good)=2
 fwindow(bad)=0
 p1=image(fwindow, rgb_table=4)
  
  ;uh, i guess i can't get stdev/variance...keep working on this.
  
  p1 = image(byte(mean(eos, dimension=3, /nan)), image_dimensions=[285,339], image_location=[22.95,-11.75], dimensions=[nx/100,ny/100], $
            RGB_TABLE=4,MIN_VALUE=0, title = 'mean LIS-WRSI')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-11, 22, 15, 51], /overplot) ;what are shrad's 
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  
w = wrsi_box
w(where(w gt 100))=!values.f_nan


;p1 = image(byte(mean(eos, dimension=3, /nan)), image_dimensions=[28.5,33.9], image_location=[22.95,-11.75], dimensions=[nx/100,ny/100], $
;            RGB_TABLE=make_wrsi_cmap(),MIN_VALUE=0, title = 'mean LIS-WRSI')
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
;  
;tmpclr = p1.rgb_table
;tmpclr[*,0] = [170,170,255]
;p1.rgb_table = tmpclr
;  
;  p1 = MAP('Geographic',LIMIT = [-2, 36, 8, 46], /overplot) ;what are shrad's 
;  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  
  
  


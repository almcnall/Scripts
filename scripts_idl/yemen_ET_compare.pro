pro yemen_ET_compare

;4/28/14 the purpose of this script is to compare the ET products over the yemen window, similar to sahel_ET and 
;rain_compare and ET_compare. I think that I should average over the irrigated non-irrigated regions.
;now I want to pull timeseries at particular points or agregated over irrgiated/rainfed
;Sanan Basin 15.267-15.433, 44.19-44.9, 22/29 also works ok.
;9/27 revisiting for October ICBA meeting, this was kinda messy....
;9/30 add rainfall to this code 
;4/9/15 can i transform this code to be the reader for the new ET data that i got from Gabriel.

;******************read in monthly ET data (RPAW, MW, LIS)********************************
;I think I have yemen in the window, given the resolution, might just grab a time series over the mts?
;modir = '/home/chg-shrad/DATA/MODIS/monthly_0.5_deg/tiff/LE/'
;mfile = file_search(strcompress(modir+'MOD16A2_LE_0.5deg_GEO_20{03,04,05,06,07,08,09,10,11,12}M??.tif',/remove_all))
;lfile = file_search('/home/chg-mcnally/fromKnot/EXP01/monthly/Evap*.img')
;ifile = file_search('/home/sandbox/people/mcnally/ETA/ETA_global/*.tif')
;*****LIS Evap 720x350 binary floats********
;do these actually start at -20 or did i move it to 19?
;nx = 720
;ny = 250

;ingridl = fltarr(120,71,n_elements(lfile))
;bufferl = fltarr(nx,ny)
;What was my old sahel window?
;map_ulx = -20.
;map_lrx = 52.
;map_uly = 20.
;map_lry = -5
startyr = 2003
endyr = 2014
ETA = fltarr(3516,1344,12,(endyr-startyr)+1)
indir = '/home/sandbox/people/mcnally/ETA_YEMEN/'
for y = startyr,endyr do begin &$
 for m = 1,12 do begin &$
  yy = strmid(string(y),6,2) &$
  ifile = file_search(strcompress(indir+string(y)+'/m'+yy+STRING(format='(I2.2)', m)+'modisSSEBopET.tif',/remove_all)) &$
  ingrid = read_tiff(ifile, geotiff=gtag) &$
  ETA[*,*,m-1,y-startyr] = reverse(ingrid,2) &$
 endfor &$
endfor

;22.3E (22.05x)-51E, 11.45'30-22.57N
map_ulx = gtag.MODELTIEPOINTTAG[3];22.05
map_lrx = 51.25
map_uly = gtag.MODELTIEPOINTTAG[4];22.95
map_lry = 11.75

ulx = (180.+map_ulx)/0.0083  & lrx = (180.+map_lrx)/0.0083 
uly = (50.-map_uly)/0.0083    & lry = (50.-map_lry)/0.0083 
NX = lrx - ulx -1
NY = lry - uly 

p1 = image(reverse(ingrid,2),image_dimensions=[NX/120,NY/120], image_location=[map_ulx,map_lry])
m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot)
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=1)

;ok so things are aligned, now read in all the data and look at it for the West Yemen window.
ymap_ulx = 43. & ymap_lrx = 45.
ymap_uly = 17. & ymap_lry = 12.5

left = (ymap_ulx-map_ulx)/0.0083  & right= (ymap_lrx-map_ulx)/0.0083
top= (ymap_uly-map_lry)/0.0083   & bot= (ymap_lry-map_lry)/0.0083

ETcube = ETA[left:right, bot:top,*,*]
ETcube = float(ETcube)
ETcube(where(etcube lt 0))=!values.f_nan
ETcube(where(etcube eq 255))=!values.f_nan

p1 = image(ETcube[*,*,0,0],image_dimensions=[242/120,543/120], image_location=[ymap_ulx+0.05,ymap_lry])
p1.rgb_table=55
rgbdump = p1.rgb_table & rgbdump[*,0] = [190,190,190] &$
p1.rgb_table=rgbdump
c = COLORBAR(target=temp,ORIENTATION=1,/BORDER_ON,font_size=12)
m1 = MAP('Geographic',limit=[ymap_lry,ymap_ulx,ymap_uly,ymap_lrx], /overplot)
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=1)

MY_ET = mean(mean(ETcube,dimension=1,/nan),dimension=1,/nan) & help, my_ET

header = ['jan', 'feb', 'mar', 'apr', 'may', 'jun','jul','aug','sep','oct','nov','dec']
ofile = '/home/sandbox/people/mcnally/YEMEN_NDVI/YEM2003_2014_ETA.csv'
write_csv,  ofile, my_ET, header=header


;oh this window goes from -20 to 52 W (need to add 2 degrees (20 pixels) to have it align [to what?])
left = (20+42)/.10
right = ((20+52)/0.10)-1
bot = (5+12)/.10
top = (5+19)/.10
buffer = fltarr(2/.10,71)

for i=0,n_elements(lfile)-1 do begin &$
   openr,1,lfile[i] &$
   readu,1,bufferl &$
   close,1 &$
   ingridl[*,*,i] = [bufferl[left:right, bot:top],buffer] &$
endfor 

;******MODIS LE global 0.5 degree**********
;subset africa from the globe
;aleft = (180-20)/0.5
;aright = (180+55)/0.5
;abot = (60-40)/0.5
;atop = (60+40)/0.5

yyleft = (180+42)/0.5
yyright = (180+54)/0.5
yybot = (60+12)/0.5
yytop = (60+19)/0.5

ingridm = intarr(25,15, n_elements(mfile))  
for i = 0, n_elements(mfile)-1 do begin &$   
   bufferm = read_tiff(mfile[i]) &$
   bufferm = reverse(bufferm,2) &$
   ingridm[*,*,i] = bufferm[yyleft:yyright, yybot:yytop] &$
endfor
ingridm = float(ingridm)
ingridm(where(ingridm eq 32767, count)) = !values.f_nan & print, count

;******Gabriel's ETa data************
;not sure why but this looked better..i didn't test 'floor' but has same number of pixels w/ w/out.
;this sux
lefty =  floor((180+42)*120)
righty = floor((180+54)*120)
boty = floor((60+12)*120)
topy = floor((60+19)*120)

;0.008333 little less than 0.001 or 1km data wowza. this takes foreva, read in if i have
;to do it again
odir = '/home/sandbox/people/mcnally/ETA/ETA_Yemen/'
ingride = bytarr(1441,834, n_elements(efile))  
for i = 0, n_elements(efile)-1 do begin &$   
   buffere = read_tiff(efile[i]) &$
   buffere = reverse(buffere,2) &$
   ofile = strcompress(odir+strmid(efile[i],44,24)) &$
   out = buffere[lefty:righty,boty:topy] &$
   openw,1,ofile &$
   writeu,1,out &$
   close,1 &$
   ingride[*,*,i] = buffere[lefty:righty, boty:topy] &$
   print, i &$
endfor


;ofile = '/home/sandbox/people/mcnally/ETA/ETA_Yemen/cube_from_global.bin'
;openw,1,ofile
;writeu,1,ingride
;close,1
yETA = float(ingride)

; getting the different datasets to line up. 
;MODIS 2003-2012 (starts in 2000 but I started late to match SSEB)
exp_ingridm = congrid(ingridm,120,71,120) & exp_ingridm = exp_ingridm[*,*,0:107]
;SSEB 2003-2012 (goes to 2014 but that is all I read in)
exp_ingride = congrid(ingride,120,71,120) & exp_ingride = exp_ingride[*,*,0:107]
; My Noah runs went from 2001-2011
exp_ingridl = ingridl[*,2:70,24:131]

;;if I chop off the botton 2 for the LIS grid they seem to agree, somehow I got off by 0.2 degrees
;add two to the top
pad = fltarr(120,2,108)
exp_ingridl = [[exp_ingridl],[pad]]

;plot everything on top of eachother
p1 = image(mean(exp_ingride, dimension=3),image_dimensions=[120/10,71/10], image_location=[42,12.2], $ 
              dimensions=[120*4,71*4])
p2 = image(mean(exp_ingridl, dimension=3),image_dimensions=[120/10,71/10], image_location=[42,12.2], $ 
              dimensions=[120*4,71*4], /overplot, transparency=60, rgb_table=4)
p2 = image(mean(exp_ingridl, dimension=3),image_dimensions=[120/10,71/10], image_location=[42,12.2], $ 
              dimensions=[120*4,71*4],/overplot, transparency=60, rgb_table=4)
p1 = MAP('Geographic',LIMIT = [12.2, 42, 19, 54], /overplot) &$
p1.mapgrid.linestyle = 6 &$
p1.mapgrid.color = [150, 150, 150] &$
p1.mapgrid.label_show = 0 &$
p1 = image(mean(exp_ingride, dimension=3),image_dimensions=[120/10,71/10], image_location=[42,12.2], $
dimensions=[120*4,71*4])
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=1)

;****calculate Noah and MOD16 % anomalies (from an average month?)****
             
;*****make some month cubes*****************************
;so the ETA means that we can only compare anomalies. in theory the irrigated
;places should have lower variability than the others. How did Gabriel compare these?
modcube  = reform(exp_ingridm,120,71,12,9)
etacube  = reform(exp_ingride,120,71,12,9)
liscube  = reform(exp_ingridl,120,71,12,9)

;these should be (standardized?) % anomalies...should i do this with cube
nx = 120
ny = 71
lanom = fltarr(nx,ny,12,9)*!values.f_nan
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    for m=0,n_elements(liscube[0,0,*,0])-1 do begin &$
      let = liscube[x,y,m,*] &$
      test = where(finite(let),count) &$
      if count le 1 then continue &$
      lsigma = stdev(let(where(finite(let)))) &$
      lanom[x,y,m,*] = (let/mean(let,/nan)) &$
    endfor &$
  endfor &$
endfor

manom = fltarr(nx,ny,12,9)*!values.f_nan
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    for m=0,n_elements(modcube[0,0,*,0])-1 do begin &$
      met = modcube[x,y,m,*] &$
      test = where(finite(met),count) &$
      if count le 1 then continue &$
      ;msigma = stdev(met(where(finite(met)))) &$
      manom[x,y,m,*] = met/mean(met,/nan)  &$
    endfor &$
  endfor &$
endfor

;****irrigation mask*****
;i am using the dominant irrigation type in the grid. what is my grid? 0.1 degree (downscale modis, aggregate GRIPC)
;ifile = file_search('/home/sandbox/people/mcnally/lis_input_cropirrig.africayemen.mode.nc')
ifile = file_search('/home/sandbox/people/mcnally/lis_input_cropirrig.africayemen.nc')

;grab the 'IRRIGTYPE'x4
;there is also surface type(?), landcover
nx = 752
ny = 802

fileID = ncdf_open(ifile, /nowrite) &$
irrgID = ncdf_varid(fileID,'IRRIGTYPE') &$
ncdf_varget,fileID, irrgID, irrgtype 

;now clip to the Yemen window...
left = (20+42)/0.10
right = (20+54)/0.10
bot = (40+12)/0.10
top = (40+19)/0.10

Yirr = irrgtype[left:right, bot:top,*]
Yirr2 = irrgtype[left:right, bot:top,*]

;so we are only dealing with 6 pixels here. it'll be important that they align correctly!
;maybe I want a little more liberty...
Yirr(where(Yirr[*,*,0] eq 1, count))=0 & print, count
Yirr(where(Yirr[*,*,1] eq 1, count))=1 & print, count
Yirr(where(Yirr[*,*,2] eq 1, count))=2 & print, count
Yirr(where(Yirr[*,*,3] eq 1, count))=3 & print, count
Yirr(where(Yirr[*,*,4] eq 1, count))=!values.f_nan & print, count

;ok, now just make a plot of gabriel's data with these irrg blocks....

ncolors=30
p1 = image(congrid(mean(etacube[*,*,*,8],dimension=3,/nan),121*3,71*3),image_dimensions=[120/10,71/10], image_location=[42,12.2], $ 
              dimensions=[120*4,71*4],  RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), min_value=50, max_value=150)
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.1,0.7,0.13], font_size=20, range=[0,100])
p1 = MAP('Geographic',LIMIT = [12.2, 42, 19, 54], /overplot) &$
p1.mapgrid.linestyle = 6 &$
p1.mapgrid.color = [150, 150, 150] &$
p1.mapgrid.label_show = 0 &$
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)

;for all crops, rainfed or irrigated
;grid lets you pull pixels for full t
crops = total(yirr2[*,*,0:1],3)
cropgrid = rebin(crops,121,71,108)
cropcube = rebin(crops,121,71,9)

rnf = yirr2[*,*,0]
rnfgrid = rebin(rnf,121,71,108)
rnfcube = rebin(rnf,121,71,9)

irr = yirr2[*,*,1]
irrgrid = rebin(irr,121,71,108)
irrcube = rebin(irr,121,71,9)

;this changes the threshold for which pixels i include or not.
subset_crop = where(cropgrid gt 0.4)
subset_irr = where(irrgrid gt 0.4)
subset_rnf = where(rnfgrid gt 0.4)

sub_crop = where(cropcube gt 0.4)
sub_irr = where(irrcube gt 0.4)
sub_rnf = where(rnfcube gt 0.4)

;plot the annual modis time series averaged over irrigated areas



etacube = float(etacube)
etacube(where(etacube eq 0))=!values.f_nan

ejan = reform(etacube[*,*,0,*])
efeb = reform(etacube[*,*,1,*])
emar = reform(etacube[*,*,2,*])
eapr = reform(etacube[*,*,3,*])




p1 = plot(ejan(subset_irr),'r+')
p1 = plot(ejan(subset_rnf),'r*',/overplot)


p1 = plot(manom(subset_crop),'*')
p1 = plot(lanom(subset_crop),'g*', /overplot)
p1 = plot(etacube(subset_crop)/100.,'r*', /overplot)

p1 = plot(manom(subset_rnf),'*')
p1 = plot(lanom(subset_rnf),'g*', /overplot)
p1 = plot(etacube(subset_rnf)/100.,'r*', /overplot)

p1 = plot(manom(subset_irr),'*')
p1 = plot(lanom(subset_irr),'g*', /overplot)
p1 = plot(etacube(subset_irr)/100.,'b*', /overplot)

;why are so many of gabriel's pixels 100%? i can't seem to tell the difference
;between rainfed and irrigated from his data but i will keep working on it.

cgrid = fltarr(nx,ny)

openr,1,cfile
readu,1,cgrid
close,1


burkina = where(cgrid eq 1, count) & print, count
chad = where(cgrid eq 2, count) & print, count
mali = where(cgrid eq 3, count) & print, count
niger = where(cgrid eq 4, count) & print, count
senegal = where(cgrid eq 5, count) & print, count
;*************************
NigerET = fltarr(3,12,11)
SenegalET = fltarr(3,12,11)
MaliET = fltarr(3,12,11)
BurkinaET = fltarr(3,12,11)
ChadET = fltarr(3,12,11)

for m = 0,n_elements(lanom[0,0,*,0])-1 do begin &$
  for y = 0,n_elements(lanom[0,0,0,*])-1 do begin &$
    ret = ranom[*,*,m,y] &$
    let = lanom[*,*,m,y] &$
    met = manom[*,*,m,y] &$
    
    NigerET[*,m,y] =  [mean(ret(niger),/nan),mean(let(niger), /nan), mean(met(niger), /nan) ] &$
    SenegalET[*,m,y] =  [mean(ret(senegal), /nan),mean(let(senegal),/nan), mean(met(senegal), /nan) ] &$
    MaliET[*,m,y] =  [mean(ret(mali), /nan),mean(let(mali), /nan), mean(met(mali), /nan) ] &$
    BurkinaET[*,m,y] =  [mean(ret(burkina), /nan),mean(let(burkina), /nan), mean(met(burkina), /nan) ] &$
    ChadET[*,m,y] =  [mean(ret(chad), /nan),mean(let(chad), /nan), mean(met(chad), /nan) ] &$
  endfor &$    
endfor;i

;T= soil moisture threshold
t=-0.3

;this is really aug/set but now i don't want to change it.
;not quite wroking try in the morning.
JARBK = mean(burkinaET[0,7:8,*], dimension=2, /nan)
JARCH = mean(chadET[0,7:8,*], dimension=2, /nan)
JARMA = mean(maliET[0,7:8,*], dimension=2, /nan)
JARNG = mean(nigerET[0,7:8,*], dimension=2, /nan)
JARSG = mean(senegalET[0,7:8,*], dimension=2, /nan)

prod_array = [jarbk, jarch, jarma, jarng, jarsg] & help, array

a = intarr(5,n_elements(jaenbk)-2)
b = intarr(5,n_elements(jaenbk)-2)
c = intarr(5,n_elements(jaenbk)-2)
d = intarr(5,n_elements(jaenbk)-2)


;the ens_array comes from the soil moisture script....
for x = 0, n_elements(ens_array[*,0])-1 do begin  &$
  for y = 0, n_elements(jaenbk)-3 do begin &$
    ;truth positive product neg = B false alarm
    if ens_array[x,y] ge 0 AND prod_array[x,y] gt t then A[x,y] = 1 else A[x,y] = 0 &$
    if ens_array[x,y] le 0 AND prod_array[x,y] gt t then B[x,y] = 1 else B[x,y] = 0 &$
    if ens_array[x,y] ge 0 AND prod_array[x,y] lt t then C[x,y] = 1 else C[x,y] = 0 &$
    if ens_array[x,y] le 0 AND prod_array[x,y] lt t then D[x,y] = 1 else D[x,y] = 0 &$
    print, A &$
  endfor &$; y
endfor;c

A_raet = total(A) 
B_raet = total(B)
C_raet = total(C)
D_raet = total(D)

;******************NOAH ET******************************
JARBK = mean(burkinaET[1,7:8,*], dimension=2, /nan)
JARCH = mean(chadET[1,7:8,*], dimension=2, /nan)
JARMA = mean(maliET[1,7:8,*], dimension=2, /nan)
JARNG = mean(nigerET[1,7:8,*], dimension=2, /nan)
JARSG = mean(senegalET[1,7:8,*], dimension=2, /nan)

prod_array = [jarbk, jarch, jarma, jarng, jarsg] & help, array

a = intarr(5,n_elements(jaenbk)-2)
b = intarr(5,n_elements(jaenbk)-2)
c = intarr(5,n_elements(jaenbk)-2)
d = intarr(5,n_elements(jaenbk)-2)

;the ens_array comes from the soil moisture script....
for x = 0, n_elements(ens_array[*,0])-1 do begin  &$
  for y = 0, n_elements(jaenbk)-3 do begin &$
    ;truth positive product neg = B false alarm
    if ens_array[x,y] ge 0 AND prod_array[x,y] gt t then A[x,y] = 1 else A[x,y] = 0 &$
    if ens_array[x,y] le 0 AND prod_array[x,y] gt t then B[x,y] = 1 else B[x,y] = 0 &$
    if ens_array[x,y] ge 0 AND prod_array[x,y] lt t then C[x,y] = 1 else C[x,y] = 0 &$
    if ens_array[x,y] le 0 AND prod_array[x,y] lt t then D[x,y] = 1 else D[x,y] = 0 &$
    print, A &$
  endfor &$; y
endfor;c

A_evap = total(A) 
B_evap = total(B)
C_evap = total(C)
D_evap = total(D)

;****************************MOD16***************************
JARBK = mean(burkinaET[2,7:8,*], dimension=2, /nan)
JARCH = mean(chadET[2,7:8,*], dimension=2, /nan)
JARMA = mean(maliET[2,7:8,*], dimension=2, /nan)
JARNG = mean(nigerET[2,7:8,*], dimension=2, /nan)
JARSG = mean(senegalET[2,7:8,*], dimension=2, /nan)

prod_array = [jarbk, jarch, jarma, jarng, jarsg] & help, array

a = intarr(5,n_elements(jaenbk)-2)
b = intarr(5,n_elements(jaenbk)-2)
c = intarr(5,n_elements(jaenbk)-2)
d = intarr(5,n_elements(jaenbk)-2)

;the ens_array comes from the soil moisture script....
for x = 0, n_elements(ens_array[*,0])-1 do begin  &$
  for y = 0, n_elements(jaenbk)-3 do begin &$
    ;truth positive product neg = B false alarm
    if ens_array[x,y] gt 0 AND prod_array[x,y] ge t then D[x,y] = 1 else D[x,y] = 0 &$ ;dinku A
    if ens_array[x,y] lt 0 AND prod_array[x,y] ge t then C[x,y] = 1 else C[x,y] = 0 &$ ;dinku B
    if ens_array[x,y] gt 0 AND prod_array[x,y] le t then B[x,y] = 1 else B[x,y] = 0 &$ ;dinku C
    if ens_array[x,y] lt 0 AND prod_array[x,y] le t then A[x,y] = 1 else A[x,y] = 0 &$ ;dinku D
    print, A &$
  endfor &$; y
endfor;c

A_mod = total(A) 
B_mod = total(B)
C_mod = total(C)
D_mod = total(D)

;*********************now compute the catagorical statistics********************

POD_w = [A_raet/(A_raet+C_raet), A_evap/(A_evap+C_evap),A_mod/(A_mod+C_mod)]
POD_d = [D_raet/(D_raet+C_raet), D_evap/(D_evap+C_evap),D_mod/(D_mod+C_mod)]
FAR = [B_raet/(B_raet+A_Raet), B_evap/(B_evap+A_evap), B_mod/(B_mod+A_mod)] 
CSI_w = [A_raet/(A_raet+B_raet+C_raet),A_evap/(A_evap+B_evap+C_evap),A_mod/(A_mod+B_mod+C_mod)]
;critical sucess index
CSI_d = [D_raet/(D_raet+B_raet+C_raet),D_evap/(D_evap+B_evap+C_evap),D_mod/(D_mod+B_mod+C_mod)]
;hits that could occur by chance
AR = [(A_raet+C_raet)*(A_raet+B_raet)/50, (A_evap+C_evap)*(A_evap+B_evap)/50, (A_mod+C_mod)*(A_mod+B_mod)/50 ]
;how well the products correspond to the mean
ETS = [ (A_raet-AR[0])/(A_raet+B_raet+C_raet-AR[0]),(A_evap-AR[1])/(A_evap+B_evap+C_evap-AR[1]), $
       (A_mod-AR[2])/(A_mod+B_mod+C_mod-AR[2])]
;how well products discrimate between wet and dry events (not super well...)
HK = [ (A_raet/(A_raet+C_raet)) - (B_raet/(B_raet+C_raet)) , (A_evap/(A_evap+C_evap)) - (B_evap/(B_evap+C_evap)), $
       (A_mod/(A_mod+C_mod)) - (B_mod/(B_mod+C_mod)) ]   
  HSS_num = [ 2*(A_raet*D_raet-B_raet*C_raet) , 2*(A_evap*D_evap-B_evap*C_evap) , 2*(A_mod*D_mod-B_mod*C_mod) ]
  HSS_den = [ (A_raet+C_raet)*(C_raet+D_raet)+(A_raet+B_raet)*(B_raet+D_raet),$
            (A_evap+C_evap)*(C_evap+D_evap)+(A_evap+B_evap)*(B_evap+D_evap),$
            (A_mod+C_mod)*(C_mod+D_mod)+(A_mod+B_mod)*(B_mod+D_mod) ]
HSS = HSS_num/HSS_den          

print, pod_w, pod_d, far, csi_w, csi_d, ets, hk, hss

mo = [1,2,3,4,5,6,7,8,9,10,11,12]
corgrid = fltarr(nx,ny,n_elements(mo))
corgrid[*,*,*]=!values.f_nan

;***correlation map for gabriel-ET and MOD16
for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,250-1 do begin &$
     test = where(finite(ranom[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     corgrid[x,y,m]=correlate(lanom[x,y,mo[m]-1,*],ganom[x,y,mo[m]-1,*]) &$
    endfor  &$
  endfor  &$
  print,x,y &$
endfor 

mod_eta_cor = corgrid
mod_lis_cor = corgrid
mod_aet_cor = corgrid

rmask=mean(raetcube[*,*,*,0], dimension=3,/nan)
good = where(finite(rmask), complement=other)
rmask(other)=!values.f_nan
rmask(good)=1

;strange that my grid is off by 0.75...yeah, for some reason the MOD16 grid is a bit off...i guess i needed that xtra pixel
p1 = image(mean(ranom[*,*,6:7,3], dimension=3, /nan)*rmask, image_dimensions=[72.0,25.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=6, min_value=-2, max_value=2,title = 'AETc avg Jul-Aug anom 2004')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) 

;***************************calculate statitiscs of interest & save them**********************
;monthly comparisions....
;**************************************************
Mstdanom=fltarr(nx,250,12,10);x,y,month,year
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    for m=0,11 do begin &$
      wMW = MW_cube[x,y,m,*] &$
      test = where(finite(wMW), count) &$
      if count le 1 then continue &$
      Mstdanom[x,y,m,*] = (wMW-mean(wMW,/nan))/stdev(wMW(where(finite(wMW)))) &$
    endfor &$
  endfor &$
endfor
;*******************************************************

Rstdanom=fltarr(nx,250,12,12);x,y,month,year
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    for m=0,11 do begin &$
      w0R = rpawcube[x,y,m,*] &$
      test = where(finite(w0R), count) &$
      if count le 1 then continue &$
      Rstdanom[x,y,m,*] = (w0R-mean(w0R,/nan))/stdev(w0R(where(finite(w0R)))) &$
    endfor &$
  endfor &$
endfor
;****************************************************
Lstdanom01=fltarr(nx,250,12,10);x,y,month,year
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    for m=0,11 do begin &$
      w01 = sm01_cube[x,y,m,*] &$
      test = where(finite(w01), count) &$
      if count le 1 then continue &$
      Lstdanom01[x,y,m,*] = (w01-mean(w01,/nan))/stdev(w01(where(finite(w01)))) &$
    endfor &$
  endfor &$
endfor
;*************************************************

;I should look at rank correlation, mean error and mean absolute error.
;maps of mean absolute error abs(model-observed)/12

mo = [1,2,3,4,5,6,7,8,9,10,11,12]
maegrid = fltarr(nx,ny,n_elements(mo))
maegrid[*,*,*]=!values.f_nan
corgrid = fltarr(nx,ny,n_elements(mo))
corgrid[*,*,*]=!values.f_nan

;*****and WRSI mask?********
rmask=mean(rpawcube[*,*,*,0], dimension=3,/nan)
good = where(finite(rmask), complement=other)
rmask(other)=!values.f_nan 
rmask(good)=1

for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,250-1 do begin &$
     test = where(finite(rpawcube[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     maegrid[x,y,m]=(mean(abs(rstdanom[x,y,mo[m]-1,*]-mstdanom[x,y,mo[m]-1,*]),/nan)) &$
    endfor  &$
  endfor  &$
  print,x,y &$
endfor 
rpawmae=maegrid
p1 = image(rpawmae[*,*,7]*rmask, rgb_table=4, max_value=1.5, title = 'RPAW std anom MAE wrt MW Aug')
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20)
             
p1 = image(rpawmae[*,0:249,7]*rmask, image_dimensions=[72.0,25.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=4, max_value=1.5,title = 'RPAW std anom MAE wrt MW Aug')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) 

;not sure this is still the mean abs error when not dividing by mean.             
for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,250-1 do begin &$
     test = where(finite(rpawcube[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     maegrid[x,y,m]=(mean(abs(lstdanom01[x,y,mo[m]-1,*]-mstdanom[x,y,mo[m]-1,*]),/nan)) &$
    endfor  &$
  endfor  &$
  print,x,y &$
endfor 
sm01mae=maegrid

p1 = image(sm01mae[*,0:249,7]*rmask, image_dimensions=[72.0,25.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=4, max_value=1.5,title = 'SM01 std anom MAE wrt MW Aug')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) 
maegrid(where(maegrid gt 1))=1
;ofile = '/jabber/chg-mcnally/mae_cmp_stav2.img'
;openw,1,ofile
;writeu,1,maegrid
;close,1
;************************ NOAH correlation w/ Microwave******************
for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,250-1 do begin &$
     test = where(finite(rpawcube[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     corgrid[x,y,m]=correlate(lstdanom01[x,y,mo[m]-1,*],mstdanom[x,y,mo[m]-1,*]) &$
    endfor  &$
  endfor  &$
  print,x,y &$
endfor 
sm01cor=corgrid
p1 = image(sm01cor[*,0:249,7]*rmask, image_dimensions=[72.0,25.0],$
           image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=4, min_value = 0, max_value=1,title = 'SM01 std anom CORRELATION wrt MW Aug')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) 
  ;************************ RPAW correlation w/ Microwave******************
for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,250-1 do begin &$
     test = where(finite(rpawcube[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     corgrid[x,y,m]=correlate(rstdanom[x,y,mo[m]-1,*],mstdanom[x,y,mo[m]-1,*]) &$
    endfor  &$
  endfor  &$
  print,x,y &$
endfor 
RPAWcor=corgrid
p1 = image(RPAWcor[*,0:249,6]*rmask, image_dimensions=[72.0,25.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=4, min_value = 0, max_value=1,title = 'RPAW std anom CORRELATION wrt MW July')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) 
;*************************************************
megrid = fltarr(nx,250,n_elements(mo))
megrid[*,*,*]=!values.f_nan

;uh, i probably have to do this with the anomalies?? or the stdized anoms?
;dinku et all calls this mean error (ME)
for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,250-1 do begin &$
     test = where(finite(rpawcube[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     megrid[x,y,m]=mean(rpawcube[x,y,mo[m]-1,*]-mw_cube[x,y,mo[m]-1,*],/nan) &$
    endfor  &$
  endfor  &$
 print,x,y &$
endfor

rpaw_megrid = megrid
temp = image(rpaw_megrid[*,*,7], rgb_table=4, min_value=-3000, max_value=-300)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20)
 
 megrid = fltarr(nx,250,n_elements(mo))
megrid[*,*,*]=!values.f_nan
            
for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,250-1 do begin &$
     test = where(finite(rpawcube[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     megrid[x,y,m]=mean(sm01_cube[x,y,mo[m]-1,*]-mw_cube[x,y,mo[m]-1,*],/nan) &$
    endfor  &$
  endfor  &$
 print,x,y &$
endfor

sm01_megrid = megrid
temp = image(sm01_megrid[*,*,7], rgb_table=4, min_value=-3000, max_value=-300)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20)

;ofile = '/jabber/chg-mcnally/mbe_chrps_sta.img'
;openw,1,ofile
;writeu,1,mbegrid
;close,1

;sta_cube, rfe_cube,urf_cube,cmp_cube,chp_cube

biasgrid = fltarr(nx,ny,n_elements(mo))
biasgrid[*,*,*]=!values.f_nan

for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,ny-1 do begin &$
     test = where(finite(urf_cube[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     biasgrid[x,y,m]=cmp_cube[x,y,mo[m]-1,*]/sta_cube[x,y,mo[m]-1,*] &$
    endfor  &$
  endfor  &$
 print,x,y &$
endfor
;biasgrid(where(biasgrid gt 2))=2
;ofile = '/jabber/chg-mcnally/bias_cmp_sta.img'
;openw,1,ofile
;writeu,1,biasgrid
;close,1

;****************by country***************************
meefile = file_search('/jabber/chg-mcnally/mbe_*sta.img')
maefile = file_search('/jabber/chg-mcnally/mae*v2.img')
biafile = file_search('/jabber/chg-mcnally/bias*.img')

  ;***compare standardized soil mositure by crop zones***********************
cfile = file_search('/jabber/chg-mcnally/cz_mask_sahel.img')

nx = 720
ny = 350
nz = 12

cgrid = fltarr(nx,ny)

openr,1,cfile
readu,1,cgrid
close,1

cgrid = cgrid[*,0:249]

burkina = where(cgrid eq 1, count) & print, count
chad = where(cgrid eq 2, count) & print, count
mali = where(cgrid eq 3, count) & print, count
niger = where(cgrid eq 4, count) & print, count
senegal = where(cgrid eq 5, count) & print, count


ingrid = fltarr(nx,ny,nz)
allgrid = fltarr(nx,ny,nz,n_elements(meefile))
for i = 0,n_elements(meefile)-1 do begin &$
  openr,1,maefile[i] &$
  readu,1,ingrid &$
  close,1 &$
  
  allgrid[*,*,*,i] = ingrid &$
endfor
 meegrid = allgrid
 maegrid = allgrid
 biagrid = allgrid
;get the RPAW, NPAW, SM01, SM02, and SMMW for each country (averged over? J,A,S?)
;rain  then NDVI
;******************************************** 

;NigerSM = fltarr(3,12,4)
;SenegalSM = fltarr(3,12,4)
;MaliSM = fltarr(3,12,4)
;BurkinaSM = fltarr(3,12,4)
;ChadSM = fltarr(3,12,4)

MEarray = fltarr(4,5,12)
MAEarray= fltarr(4,5,12)
BIAarray = fltarr(4,5,12)

for m = 0,n_elements(meegrid[0,0,*,0])-1 do begin &$
  for p = 0,n_elements(meegrid[0,0,0,*])-1 do begin &$
    
    mee = meegrid[*,*,m,p] &$
    mae = maegrid[*,*,m,p] &$
    bia = biagrid[*,*,m,p] &$
    
    MEarray[p,*,m] =  [mean(mee(burkina),/nan),mean(mee(chad),/nan),mean(mee(mali), /nan),mean(mee(niger), /nan),mean(mee(senegal), /nan)] &$
    MAEarray[p,*,m] =  [mean(mae(burkina),/nan),mean(mae(chad),/nan),mean(mae(mali), /nan),mean(mae(niger), /nan),mean(mae(senegal), /nan)] &$
    BIAarray[p,*,m] =  [mean(bia(burkina),/nan),mean(bia(chad),/nan),mean(bia(mali), /nan),mean(bia(niger), /nan),mean(bia(senegal), /nan)] &$

  endfor &$    
endfor;i           
             
             
             
             
             

;****************correlation map******************************
;Wankama 2006 - 2011 (13.6456,2.632 )
;wxind = FLOOR((2.632 + 20.) / 0.10)
;wyind = FLOOR((13.6456 + 5) / 0.10)
;
x = wxind
y = wyind

corgrid = fltarr(nx,ny,n_elements(mo))
corgrid[*,*,*]=!values.f_nan

;I guess this is where i should be doing the scatter quads...
for m = 0,n_elements(mo)-1 do begin &$
  for x = 0,nx-1 do begin &$
    for y = 0,ny-1 do begin &$
     test = where(finite(urf_cube[x,y,mo[m]-1,*]),complement=null) &$
     if n_elements(null) eq 12 then continue &$
     corgrid[x,y,m]=correlate(cmp_cube[x,y,mo[m]-1,0:10],sta_cube[x,y,mo[m]-1,0:10]) &$
    endfor  &$
  endfor  &$
 print,x,y &$
endfor

p1=image(corgrid[*,*,6], rgb_table=20)

;ofile = '/jabber/chg-mcnally/cor_cmp_sta.img'
;openw,1,ofile
;writeu,1,corgrid
;close,1

;****************************************************
;*****************at sites**************************

;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5) / 0.10)


;Belefoungou-Top 9.79506     1.71450  
bxind = FLOOR((1.7145 + 20.) / 0.10)
byind = FLOOR((9.79506 + 5) / 0.10)

;the full time series
p1=plot(ingridb[wxind,wyind,*], thick=2)
p1=plot(ingridr[wxind,wyind,*], /overplot,'b')
p1=plot(ingridu[wxind,wyind,*], /overplot,'c')
p1=plot(ingridc[wxind,wyind,*], /overplot,'g')
p1=plot(ingridp[wxind,wyind,*], /overplot,'m')
;june time plot

m=9
x = wxind
y = wyind
p1=plot(sta_cube[x,y,m-1,*], thick = 2, name = 'CSCDP station')
p2=plot(rfe_cube[x,y,m-1,*], /overplot,'b', name = 'rfe')
p3=plot(urf_cube[x,y,m-1,*], /overplot,'c', name = 'ub rfe')
p4=plot(cmp_cube[x,y,m-1,*], /overplot,'g', name = 'cmap')
!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3]) 
p1.title=' Belefoungou, Benin 2001-2012 month '+string(m)

;june scatter plot
;p1=plot(sta_cube[wxind,wyind,6-1,*])
p2=plot(rfe_cube[x,y,m-1,*],sta_cube[x,y,m-1,*], '*b', name = 'rfe')
p3=plot(urf_cube[x,y,m-1,*],sta_cube[x,y,m-1,*], '*c',/overplot, name = 'ub rfe')
p4=plot(cmp_cube[x,y,m-1,*],sta_cube[x,y,m-1,*], '*g', /overplot, name = 'cmap')
p2.title=' Belefougou 2001-2012 month '+string(m)
p2.xminor=0
p2.yminor=0
!null = legend(target=[p2,p3,p4], position=[0.2,0.3]) 

p2.xrange=[120,325]
p2.yrange=[120,325]
p5=plot([120,325], [120,325], /overplot)



;*****Noah AET compare************************************
;lfile = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/monthly/Evap*.img')
;efile = file_search('/jabber/chg-mcnally/ETA/sahel/*.img')
;
;ingridl = fltarr(720,250,n_elements(lfile))
;bufferl = fltarr(720,250)
;
;ingride = fltarr(720,350,n_elements(efile))
;buffere = bytarr(720,350)
;
;for i=0,n_elements(ifile1)-1 do begin &$
;   openr,1,lfile[i] &$
;   readu,1,bufferl &$
;   close,1 &$
;   
;   openr,1,efile[i] &$
;   readu,1,buffere &$
;   close,1 &$
;   
;   ingridl[*,*,i] = bufferl &$
;   ingride[*,*,i] = buffere &$
;endfor
;
;
;etancube = reform(ingrid2,720,350,12,12)
;
;evapcube = reform(ingrid1,720,250,12,11)
;avgevap = mean(evapcube,dimension=4);average for each month.
;anom = fltarr(720,250,12,11)
;
;for m=0,n_elements(evapcube[0,0,*,0])-1 do begin &$
;  for y = 0,n_elements(evapcube[0,0,0,*])-1 do begin &$
;  anom[*,*,m,y] = evapcube[*,*,m,y]-avgevap[*,*,m] & help, anom &$
;endfor
;ofile = '/jabber/chg-mcnally/MonthlyEvapAnom2001_2011cube_Noah32.img'
;openw,1,ofile
;writeu,1,anom
;close,1



;compare monthly NOAH anomalies and geoWRSI
;setancube=etancube[*,0:249,*,0:10]
;sranom=ranom[*,0:249,*,0:10]
;snanom=nanom[*,0:249,*,0:10]
;cormap = fltarr(nx,250,12,2)
;for x = 0,nx-1 do begin &$
;  for y = 0,250-1 do begin &$
;    for m = 0,11 do begin &$
;      ;good = where(finite(etancube[x,y,m,0:10]), count) &$
;      good = where(finite(snanom[x,y,m,0:10]), count) &$
;      if count le 1 then continue &$
;      ;print, x,y,m &$
;      ;cormap[x,y,m,*] = r_correlate(etancube[x,y,m,good], anom[x,y,m,good]) &$
;      ;cormap[x,y,m,*] = r_correlate(sranom[x,y,m,good], anom[x,y,m,good]) &$
;      cormap[x,y,m,*] = r_correlate(snanom[x,y,m,good], anom[x,y,m,good]) &$
;    endfor &$
;  endfor   &$
;endfor
;
;Raet_noah_cormap = cormap ;I get reasonable correspondance with the R-AET but not the ETa
;Naet_noah_cormap = cormap
;p1=image(naet_noah_cormap[*,*,7,0], rgb_table=20, max_value=0.8, min_value=-0.8)
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
; 
;  p1 = image(naet_noah_cormap[*,*,7,0],image_dimensions=[72.0,25.0], image_location=[-20,-5], $ 
;             dimensions=[nx/100,ny/100],title = 'N-AET vs Noah Evap Anom', rgb_table=20, min_value=0,max_value=0.7) &$ 
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
;  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
;  p1.mapgrid.linestyle = 'dotted' &$
;  p1.mapgrid.color = [150, 150, 150] &$
;  p1.mapgrid.label_position = 0 &$
;  p1.mapgrid.label_color = 'black' &$
;  p1.mapgrid.FONT_SIZE = 12 &$
;  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
;             
;
;;Wankama 2006 - 2011 (13.6456,2.632 )
;wxind = FLOOR((2.632 + 20.) / 0.10)
;wyind = FLOOR((13.6456 + 5) / 0.10)
;
;p1=plot(ingrid2[wxind,wyind,*])

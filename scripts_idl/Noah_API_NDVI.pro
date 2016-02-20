pro Noah_API_NDVI

;correlate API and SM03 anomalies
;calculate SM03 short term mean
;calculate evap short term mean
;calculate additive anomalies
;chop down rainfall (UBRfe2) for API calculations

;*******correlate API and Noah SM anomalies***********************
;then corr NDVI' and Noah evap anomalies 2005-2010
;not sure that these anomalies are correct...i should look at them
;apif = file_search('/jabber/LIS/Data/API_sahel/add_anom/APIsahelanom_{2005,2006,2007,2008,2009,2010}*.img')
;sm3f = file_search('/jabber/sandbox/mcnally/EXPA02_dekads/sm03/add_anom/sm03.anom_{2005,2006,2007,2008,2009,2010}*img')

;this is the evap
apif=file_search('/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/sahel/anom*')
sm3f = file_search('/jabber/sandbox/mcnally/EXPA02_dekads/evap/add_anom/evap.anom_{2005,2006,2007,2008}*img')
nx = 720
ny = 350
buffer = fltarr(nx,ny)
apianom = fltarr(nx,ny,36*6)
sm3anom = fltarr(nx,ny,36*6)
;open, stack and correlate! Save the correlation map so that I can easily apply different masks without processing!
for a = 0,n_elements(apif)-1 do begin &$
   ;if fix(strmid(apif[a],49,4)) lt 2005 then continue  &$
   ;if fix(strmid(apif[a],49,4)) gt 2010 then break &$
   openr,1,apif[a] &$
   readu,1,buffer &$
   close,1 &$
   ;buffer = reverse(buffer,2) &$
   apianom[*,*,a] = buffer &$
endfor 

for s = 0,n_elements(sm3f)-1 do begin &$
   ;if fix(strmid(sm3f[s],62,4)) lt 2005 then continue &$
   ;if fix(strmid(sm3f[s],62,4)) gt 2010 then break &$
 
   openr,1,sm3f[s] &$
   readu,1,buffer &$
   close,1 &$
   
   sm3anom[*,*,s] = buffer &$
endfor

;grab some timeseries of interest
lon = 2
lat = 12
x = floor((lon+19.95)*10) 
y = floor((29.95-lat)*10)
temp = plot(apianom[x,y,*]*1000)
temp = plot(sm3anom[x,y,*], /overplot, 'g')

;sm3anom=sm3anom*864000 cahnge to mm/10days
result=fltarr(nx,ny)
for x = 0,NX-1 do begin &$
  for y = 0, NY-1 do begin  &$
  ;good=where(finite(apianom[x,y,*]), count, complement=other) &$
  ;if count gt 0 then 
  result[x,y]=correlate(apianom(x,y,*),sm3anom(x,y,*)) &$
  ;result[x,y]=correlate(sahelarray(x,y,*),sm3anom(x,y,*)) &$
  
  endfor &$
endfor
vals=where(finite(sm3anom[*,*,0]), complement=null)
result(null)=!values.f_nan 

p1 = image(result*vegmask, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table=20)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
p1 = MAPCONTINENTS(/COUNTRIES)
;ofile='/jabber/Data/mcnally/AMMASOIL/correlmapNDVI_evapanom.img'
ofile='/jabber/Data/mcnally/AMMASOIL/correlmapAPI_SM03anom.img'
;openw,1,ofile
;writeu,1,result
;close,1

;try different masks to highlight where api is valid (soil type)
;loamysand, sand, sandyloam
 maskfile=file_search('/jabber/Data/mcnally/AMMASOIL/mask_*.img')
 mask=fltarr(720,350)
 openr,1,maskfile[0]
 readu,1,mask
 close,1
 
 mask(where(mask eq 0))=!values.f_nan
 sand=result*mask
 
 vegmask = fltarr(720,350)
 ifile = file_search('/jabber/Data/mcnally/AMMAVeg/mask_bare75_sahel.img')
 openr,1,ifile
 readu,1,vegmask
 close,1
 
 vegmask(where(vegmask eq 0))=!values.f_nan
  p1 = image(sand*vegmask, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table=20)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])


;*****************calculate the short-term mean for the sm03/evap so i can calc anomalies******************
;e.g. get the first dekad for all years (10) and put them into a monthly cube, take the average of the cube and write it out
NX = 720
NY = 350
bigcube = fltarr(nx,ny,36)
cnt = 1 ;start at one since it is dek1 not dek0
ingrid=fltarr(nx,ny)
for m = 1,12 do begin &$
  for d = 1,3 do begin &$
  mm = string(format='(I2.2)',m) &$
  dk = string(format='(I2.2)',d) &$
  ifile = file_search(strcompress('/jabber/sandbox/mcnally/EXPA02_dekads/sm03/????'$ &$
       +mm+dk+'*img', /remove_all))  &$
       print, ifile &$
       cube = fltarr(NX,NY,n_elements(ifile)) &$   
    for f = 0,n_elements(ifile)-1 do begin &$
      openr,1,ifile[f]  &$
      readu,1,ingrid &$
      close,1 &$
    
      ingrid=reverse(ingrid,2) &$
      cube[*,*,f]=ingrid &$
    endfor &$
    sm03avg = mean(cube, dimension=3, /nan) &$
    ofile = strcompress(strmid(ifile[0],0,43)+'sm03.stm_dek'+$
            string(format='(I2.2)',cnt),/remove_all) &$
;    print, ofile &$
;    openw,1,ofile  &$
;    writeu,1,sm03avg &$
;    close,1 &$
    bigcube[*,*,cnt-1]=sm03avg &$
    cnt++ &$
  endfor  &$ ;d
endfor  ;m 


;grab some timeseries of interest
;ah! what is wrong with the first few deks?? funny not smooth
lon = 3
lat = 14
x = floor((lon+19.95)*10) 
y = floor((29.95-lat)*10)
temp = plot(bigcube[x,y,*],/overplot, 'black', thick=3)

;do i have a cube of 2005?



 print, 'hold'
 cube(where(cube lt 0.001))=!values.f_nan

;***********************calculate addative anomlies for soil moisture/evap....
;***is this part correct?
;this only goes up through january 2011. Why?
nx = 720
ny = 350
sm03 = fltarr(nx,ny)
stm  = fltarr(nx,ny)
cnt =  0
;ifile = file_search('/jabber/sandbox/mcnally/EXPA02_dekads/sm03/20*.img')
;stmfile=file_search('/jabber/sandbox/mcnally/EXPA02_dekads/sm03/sm03.stm*')
ifile = file_search('/jabber/sandbox/mcnally/EXPA02_dekads/evap/20*.img')
stmfile=file_search('/jabber/sandbox/mcnally/EXPA02_dekads/evap/evap.stm*')
cube=fltarr(nx,ny,n_elements(ifile))
;is this correct?
for f = 0,n_elements(ifile)-1 do begin &$

;open the soil moisture dekads
  openr,1,ifile[f]  &$
  readu,1,sm03 &$
  close,1 &$
  sm03 = reverse(sm03,2) &$

;open the short term mean 1-36..it looks like these were calculated incorrectly. or something 
;is shifted...
  if cnt eq 36 then cnt = 0 &$
  openr,1,stmfile[cnt] &$
  readu,1,stm &$
  close,1 &$
  
  sm03anom = sm03 - stm &$
  cnt++ &$
  
  cube[*,*,f]=sm03anom &$
  
;  ofile = strmid(ifile[f],0,43)+'add_anom/sm03.anom_'+strmid(ifile[f],43,12) &$  
  ofile = strmid(ifile[f],0,43)+'add_anom/evap.anom_'+strmid(ifile[f],43,12) &$
  openw,1,ofile &$
  writeu,1,sm03anom &$
  close,1 &$
  
endfor
;***************************API STUFF***********************************************************
;****************Chop down rainfall/NDVI inputs and calculate API****************************
;ifile= file_search('/jabber/LIS/Data/ubRFE2/dekads/20*.img')
ifile= file_search('/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/anom.{2005,2006,2007,2008,2009,2010}*.img');am i doing all years?? no just the years of the EXPA02 

nx=751
ny=801
;nz=396
nz = n_elements(ifile) ;why is this shorter?? weird.
ingrid = bytarr(nx,ny)
sahelarray = fltarr(720,350,nz)

for f = 0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[f] &$
  readu,1,ingrid &$
  close,1 &$
  
  ingrid=reverse(ingrid,2) &$
  ;chop down the file to the sahel window when it is upsidedown
  xrt=(751-1)-3/0.1  &$;RFE goes to 55, sahel goes to 52 plus an extra pixel
  ybot=(35/0.1)+1   &$ ;sahel starts at -5S
  ytop=(801-1)-10/0.1  &$; &$sahel stops at 30N
  xlt=1.     &$          ;and I guess sahel starts at 19W, rather than 20....
  sahel=ingrid[xlt:xrt,ybot:ytop] &$
  sahel = (sahel-100.)/100. &$
  sahelarray[*,*,f]=sahel &$
  
  ;write out all of the spatial subset files. Did I do this for UBRFE or did I just calculate extra API?
  ofile = '/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/sahel/'+strmid(ifile[f],54,19) &$
  print, ofile  &$
  openw,1,ofile  &$
  writeu,1,sahel &$
  close,1 &$
endfor
;write out sahel window to separate files...I wonder if I'll change the domain for the next runs.
;what side up is this??
;sahelarray=reverse(sahelarray,2)
;ofile='/jabber/LIS/Data/ubRFE2/dekads/sahel_2001_2011.img'
;openw,1,ofile
;writeu,1,sahelarray
;close,1
rain=sahelarray
;**********************Calculating API*****************************
;not sure if this actually works since i got it running in matlab first 9/20/12

ifile=file_search('/jabber/LIS/Data/ubRFE2/dekads/sahel_2001_2011.img')
nx = 720
ny = 350
nz = 396

openr,1,ifile
readu,sahelarray
close,1

;parameters fit in matlab result = [0.0003 0.7027 0.0327];
beta = 0.0003
gamma = 0.7027
const = 0.0327

est=fltarr(nx,ny,nz)
;calculate API
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    for t = 1,nz-1 do begin &$
    sum = 0 &$
    rain = reform(sahelarray[x,y,*],nz)  &$
    for n = 0,min([6, t-1]) do begin  &$;%go back over the last 6 dekads &$
        sum = sum + gamma^n * rain[t-n] &$
    endfor  &$
    est[x,y,t] = beta * sum + const &$
  endfor 

;******************write out each of the est maps into its own file**********************
;vert cat 36 times then transpose, reform.

;ifile=file_search('/jabber/LIS/Data/ubRFE2/dekads/sahel_API*')
ifile = file_search('/jabber/chg-mcnally/sahel_API_200101_201232.img')

nx = 720
ny = 350
nz = 428

apigrid = fltarr(nx,ny,nz)
openr,1,ifile
readu,1,apigrid
close,1


yyyy=[2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012]
y=0
cnt=0
for i=0,n_elements(apigrid[0,0,*])-1 do begin &$
 for y=0,36-1 do begin &$
  for m=1,12 do begin &$
    for d=1,3 do begin &$
      ofile=strcompress('/jabber/LIS/Data/API_sahel/APIsahel_'+string(yyyy[y])+string(format='(I2.2)',m) $
                         +string(d)+'.img',/remove_all) &$
      openw,1,ofile &$
      writeu,1,apigrid[*,*,cnt] &$
      close,1 &$
      
      print, ofile &$
      cnt++ &$
      print, cnt &$
    endfor &$;d &$
  endfor &$;m &$
 endfor &$; y &$
 y++ &$
endfor;i

;***********generate API anomalies**********************************
;get all the dek1 for all the januaries and take their average ...this will make a nx,ny,36 matrix
;is there anything in the files?

ifile=file_search('/jabber/LIS/Data/API_sahel/APIsahel_20*.img')
openr,1,ifile[1]
readu,1,ingrid
close,1
temp=image(ingrid, rgb_table=4)

nx = 720
ny = 350
nz = 36

ingrid=fltarr(nx,ny)
buffer=fltarr(nx,ny,11)
;was i producing files of annual API??
outgrid=fltarr(nx,ny,nz)

cnt = 0
for m = 1,12 do begin  &$
  mm = string(format='(I2.2)',m) &$
  for d = 1,3 do begin &$
    ifile = file_search(strcompress('/jabber/LIS/Data/API_sahel/APIsahel_20??'+mm+string(d)+'*.img', /remove_all)) &$
    for f = 0,n_elements(ifile)-1 do begin &$
      openr,1,ifile[f] &$
      readu,1,ingrid &$
      close,1  &$
      
      buffer[*,*,f]=ingrid &$
    endfor &$ ;f
    avg = mean(buffer,dimension=3,/nan) &$
    outgrid[*,*,cnt] = avg &$
       
;    dek=string(format='(I2.2)',cnt+1)  &$ 
;    ofile=strcompress('/jabber/LIS/Data/API_sahel/stm_API/API_'+dek+'.img',/remove_all) 
;    & print,ofile  &$ 
;    openw,1,ofile  &$ 
;    writeu,1,avg  &$ 
;    close,1  &$ 
    
    cnt++ &$
  endfor  &$ 
endfor   ;m

;*****clip out soil and veg masks! for now I will use the named classes

ifile = file_search('/jower/LIS/RUN/UMD/10KM/soiltexture_STATSGO-FAO.1gd4r')
;ifile = file_search('/jower/LIS/RUN/UMD/10KM/landcover_UMD.1gd4r')

NX = 3600
NY = 1500
NZ = 13
ingrid = fltarr(NX,NY)
;veg = fltarr(NX,NY,NZ)

openr,1,ifile
readu,1,ingrid
close,1

byteorder,ingrid,/XDRTOF

;bottom is at 60...
w = ((180-20)*10)
e = ((180+52)*10)-1
s = (60-5)*10 ;60 is the eqautor...
n = ((60+30)*10)-1

;soil window
sahel = ingrid[w:e,s:n,*]
sahel(where(sahel lt 0)) = !values.f_nan

;clip out and save file so that i can make the FC and WP maps
ofile = strcompress('/jabber/chg-mcnally/AMMASOIL/soiltexture_STATSGO-FAO_20KMSahel.1gd4r', /remove_all)
openw,1,ofile
writeu,1,sahel
close,1

;9/22/2012 - clipped out the window, next mask out the soil types of interest.
p1 = image(sahel, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 38)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0, 0, 0])
  
;what are the soil types at my different sites?
;Mpala Kenya:
xind = FLOOR((36.8701 + 20.) / 0.10)
yind = FLOOR((0.4856 + 5) / 0.10)
print,'Mpala soil ='+ sahel[xind,yind] ;Mpala - 0.65

;KLEE Kenya
xind = FLOOR((36.8669 + 20.) / 0.10)
yind = FLOOR((0.2825 + 5) / 0.10)
print,'KLEE soil ='+ sahel[xind,yind] ;Mpala - 0.65

;Wankama Niger
xind = FLOOR((2.633 + 20.) / 0.10)
yind = FLOOR((13.6454 + 5) / 0.10)
print,'Wankama soil ='+ sahel[xind,yind] ;Mpala - 0.65

  
  
;what kind of soil is generally there?
;1-sand 2-loamy sand 3-sandy loam = green, sandy clay loam = yellow, sand = black
;sand = where(sahel eq 1., complement=other)
;****veg mask*****
bare = where(sahel[*,*,11] gt 75, count, complement=green)
mask = sahel[*,*,11]
mask(green) = 1.
mask(bare) = 0.

loamy_sand=where(sahel eq 2., complement = other)
mask(loamy_sand) = 1

sandy_loam=where(sahel eq 3., complement = other)
mask(sandy_loam) = 1

mask=sahel
highsand=where(sahel le 3, complement=other)
mask(highsand) = 1
mask(other) = 0


temp=image(mask, rgb_table=4)
;*******multiply by the API map to mask*****
ofile='/jabber/Data/mcnally/AMMASOIL/mask_highsand_sahel.img'
ofile='/jabber/Data/mcnally/AMMAVeg/mask_bare75_sahel.img'

openw,1,ofile
writeu,1,mask
close,1

;*********************************
;start correlating the API and Noah SM anomalies
;first find the API anomalies & Noah anomalies
;this still needs a little work starting on monday morning
nx = 720
ny = 350

api = fltarr(nx,ny)
stm = fltarr(nx,ny)
ifile = file_search('/jabber/LIS/Data/API_sahel/APIsahel_*')
cnt = 0
for f = 0,n_elements(ifile)-1 do begin &$
  ;f = 0
  openr,1,ifile[f] &$
  readu,1,api &$
  close,1 &$
  
  stmfile = file_search('/jabber/LIS/Data/API_sahel/stm_API/API_*.img') &$
  
  if cnt eq 36 then cnt=0 &$
  openr,1,stmfile[cnt] &$
  readu,1,stm &$
  close,1 &$
  print, stmfile[cnt] &$
  cnt++ &$
  
  ;I should prolly try both additive and multiplicative means...additive first
  aanom = api - stm  &$
  
;  ofile = strcompress(strmid(ifile[f],0,35)+'anom_'+strmid(ifile[f],36,12), /remove_all) & print, ofile  &$
;  openw,1,ofile  &$
;  writeu,1,aanom  &$
;  close,1  &$
 
 endfor


 

end 
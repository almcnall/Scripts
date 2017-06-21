pro CHIRPS_ARC_RFE_YEMEN

;10.7.14 moved the 0.25 degree rainfall comparison here from the CHIRPS_NDVI script
;now I have a CHIRPS-ARC-RFE comparison so it is easier to say something about my model outputs.
;now include the Worldclim and GPCC if handy
;maybe merge this code with the yemen_station. pro
;09.12.15 revisit (i want to look at twitter) for new Yemen plot showing water supply."the water management is conflict mangement"


  ;1=arabian sea
  ;2=desert
  ;3=highlands
  ;4=temperate highlands
  ;5=internal plateau
  ;6=redsea
  ;subset the areas in the red& highx2
  
  ;mask by ROIs
  ifile = file_search('/home/sandbox/people/mcnally/yemen_shp/YM_agzone_300x320'); continental africa 0.25 degree
  nx = 300
  ny = 320

  agzn = bytarr(nx,ny)
  openr,1,ifile
  readu,1,agzn
  close,1
  agzn = reverse(float(agzn),2)
  
  ;*********
  startyr = 2001
  endyr = 2013
  nyrs = endyr-startyr+1

  ;for east africa use 3-6 for yemen use 3-9
  startmo = 1
  endmo = 12
  nmos = endmo - startmo+1
;;;;;;;;;;;;;;;;***GPCC****;;;;;;;;;;;;;;;;;;;;;
;these are already monthly data....
;;;using the 30yr TS;;;;;;;
;glb_shift=[gpcc[ulx:719,lry:uly,960:1319],gpcc[0:lrx,lry:uly,960:1319]]
;get glb_shift from /home/source/mcnally/scripts_idl/clipAfrica_GPCC.pro 

help, glb_shift

;uh, why does this show only 30 yrs of data?
gpccstart = 1901
gpccend = 2014
gpccyrs = (gpccend - gpccstart) + 1 & print, gpccyrs

gpc2 = reform(congrid(glb_shift,300,320,gpccyrs*12),300,320,12,gpccyrs)
gpc2(where(gpc2 lt 0)) = !values.f_nan

startyr = 2001
endyr = 2014 ;end yr <2011
nyrs = (endyr-startyr)+1 & print, nyrs

startmo = 1
endmo = 12
nmos = (endmo -startmo)+1 & print, nmos
;just look at yrs of interest e.g. 2001-2010
gpcc_yoi = gpc2[*,*,*,startyr-1901:gpccyrs-1] & help, gpcc_yoi

;;;;;;;the Ethiopia-Yemen window for Worldclim;;;;;;;;;;;;;;;;
;;;;i can probably make another one of these for the east africa domain but its not really necsaryy
;;;;;;do i have the different africa domains for worldclim?;;;;
;nx = 200, ny = 151, nz = 12
ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input.reorg_WORLDCLIM.nc')
fileID = ncdf_open(ifile, /nowrite) &$
  wclimID = ncdf_varid(fileID,'PPTCLIM') &$
  ncdf_varget,fileID, wclimID, wclim
     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;what is the annual total rainfall for Yemen and different regions (see mask), and how does each product 
; represent monthly climatolology? [start back here Monay, then sujay can add ensembles :)]
;
 data_dir1 = '/home/ftp_out/people/mcnally/FLDAS/Yemen1KM/'
 data_dir2 = '/home/ftp_out/people/mcnally/FLDAS/NOAH_RFE2_GDAS_EA/'
 data_dir3 = '/home/ftp_out/people/mcnally/FLDAS/NOAH_CHIRPSv2_MERRA_EA/'
 data_dir4 = '/home/sandbox/people/mcnally/CHIRPS_ARC2_eval/CPC_ARC/';chirps_mon_* 201012.bil
 ;data_dir2 = '/home/RFE2/monthly/'
 ; data_dir3 = '/home/chg-shrad/DATA/Precipitation_Global/GPCC/'

  NX = 300
  NY = 320

ARC = FLTARR(300,320,nmos,nyrs)
RAIN2 = fltarr(300,320)
CHIRPS01 = FLTARR(294,348,nmos,nyrs)
CHIRPS001 = FLTARR(201,501,nmos,nyrs)

RFE = FLTARR(294,348,nmos,nyrs)

  
  ;this loop reads in the selected months only
  for yr=startyr,endyr do begin &$
    for i=0,nmos-1 do begin &$
    y = yr &$
    m = startmo + i &$
    if m gt 12 then begin &$
    m = m-12 &$
    y = y+1 &$
  endif &$
  
  fileID = ncdf_open(data_dir1+STRING(FORMAT='(''FLDAS_NOAH001_B_YM_M.A'',I4.4,I2.2,''.001.nc'')',y,m), /nowrite) &$ ; FLDAS_NOAH001_B_YM_M.A201505.001.nc
  RainID = ncdf_varid(fileID,'Rainf_tavg') &$
  ncdf_varget,fileID, RainID, RAIN &$
  CHIRPS001[*,*,i,yr-startyr] = RAIN*86400 &$
  
  ;for the netcdf chirps at 0.1KM
  fileID = ncdf_open(data_dir3+STRING(FORMAT='(''FLDAS_NOAH01_B_EA_M.A'',I4.4,I2.2,''.001.nc'')',y,m), /nowrite) &$
  RainID = ncdf_varid(fileID,'Rainf_tavg') &$
  ncdf_varget,fileID, RainID, RAIN &$
  CHIRPS01[*,*,i,yr-startyr] = RAIN*86400*30 &$
  
  fileID = ncdf_open(data_dir2+STRING(FORMAT='(''FLDAS_NOAH01_A_EA_M.A'',I4.4,I2.2,''.001.nc'')',y,m), /nowrite) &$
  RainID = ncdf_varid(fileID,'Rainf_tavg') &$
  ncdf_varget,fileID, RainID, RAIN &$
  RFE[*,*,i,yr-startyr] = RAIN*86400*30 &$

  ifile = file_search(data_dir4+STRING(FORMAT='(''arc2_mon_'',I4.4,I2.2,''.bil'')',y,m)) &$
  openr,1,ifile &$
  readu,1, RAIN2 &$
  close,1 &$
  ARC[*,*,i,yr-startyr] = RAIN2 &$

endfor &$
endfor
;check and see whAT I HAVE GOT
; remember that chirps is in kg/m2/s...*86400
help, CHIRPS01, CHIRPS001, RFE, ARC, gpcc_yoi, wclim

wclim(where(wclim lt 0)) = !values.f_nan
chirps01(where(chirps01 lt 0)) = !values.f_nan
chirps001(where(chirps001 lt 0)) = !values.f_nan
rfe(where(rfe lt 0)) = !values.f_nan
arc(where(arc lt 0)) = !values.f_nan
gpcc_yoi(where(gpcc_yoi lt 0)) = !values.f_nan

;quic,k plot
;ingrid = gpcc_yoi
;i++
;temp = image(total(ingrid[*,*,7,*],4,/nan), layout = [6,1,i], max_value=25, /current)

;;;put all of these on the same grid. Ewww. Probably the east africa window, since that is what the mask uses.

;;reduce the size of the arc (0.25) and gpcc (0.25)
;;East Africa WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75
;calculate NX and NY for the crop map
ulx = (20.+map_ulx)*4. & lrx = (20.+map_lrx)*4.
uly = (40.+map_uly)*4. & lry = (40.+map_lry)*4.
;this is off by one in the y-direction...
NX = (lrx - ulx)+1
NY = (uly - lry)+1

print, nx, ny
;congrid must only work on 3-d arrays.
arc_EA = reform(congrid(reform(arc[ulx:lrx, lry:uly,*,*],118,139,12*nyrs),294,348,12*nyrs), 294,348,12,nyrs)
gpcc_EA = reform(congrid(reform(gpcc_yoi[ulx:lrx, lry:uly,*,*],118,139,12*nyrs),294,348,12*nyrs), 294,348,12,nyrs)
agzn_EA = rebin(reform(congrid(reform(agzn[ulx:lrx, lry:uly],118,139),294,348), 294,348),294,348,nmos,nyrs)

help, arc_ea, gpcc_ea, chirps01, rfe, agzn_EA

;;pad out the worldclim and CHIRPS001 at some point...
;
;1=arabian sea
;2=desert
;3=highlands
;4=temperate highlands ; the high-highlands
;5=internal plateau
;6=redsea

;annual rainfall for all of yemen from the different products
;I think we're all in same units now..RFE needs a max...
YEM_mask = agzn_ea
good = where(agzn_ea gt 0, complement=bad)
YEM_mask(good) = 1
YEM_mask(bad) = !values.f_nan

HIGH_mask = agzn_ea
good = where(agzn_ea eq 3, complement=bad)
HIGH_mask(good) = 1
HIGH_mask(bad) = !values.f_nan

Thigh_mask = agzn_ea
good = where(agzn_ea eq 4, complement=bad)
Thigh_mask(good) = 1
Thigh_mask(bad) = !values.f_nan

H_mask = agzn_ea
good = where(agzn_ea eq 4 OR agzn_ea eq 3, complement=bad)
H_mask(good) = 1
H_mask(bad) = !values.f_nan

;average annual rainfall to map
ym_arc = mean(total(arc_ea,3,/nan), dimension=3,/nan) & help, ym_arc
ym_gpcc = mean(total(gpcc_ea,3,/nan), dimension=3,/nan) & help, ym_gpcc
ym_rfe = mean(total(rfe,3,/nan), dimension=3,/nan) & help, ym_rfe
ym_chirps01 = mean(total(chirps01,3,/nan), dimension=3,/nan) & help, ym_chirps01

;am i biasing these by area? I must be...
mask = H_mask[*,*,0,0]
print,'    arc','  gpcc', '  rfe', '  chirps'
print, mean(ym_arc*mask,/nan), mean(ym_gpcc*mask,/nan), mean(ym_rfe*mask,/nan), mean(ym_chirps01*mask,/nan) 

;plot the season cycle from each...why are my means so low??
mask = H_mask
p1 = plot(mean(mean(mean(arc_ea*mask,dimension=4,/nan),dimension=1,/nan), dimension=1,/nan), color = 'red', name  = 'arc')
p2 = plot(mean(mean(mean(gpcc_ea*mask,dimension=4,/nan),dimension=1,/nan), dimension=1,/nan), color = 'orange', name  = 'gpcc', /overplot)
p3 = plot(mean(mean(mean(chirps01*mask,dimension=4,/nan),dimension=1,/nan), dimension=1,/nan), color = 'green', name  = 'CHIRPS01', /overplot)
p4 = plot(mean(mean(mean(rfe*mask,dimension=4,/nan),dimension=1,/nan), dimension=1,/nan), color = 'blue', name  = 'RFE', /overplot)
!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=18, orientation=1, shadow=0)

;maps of average Yemen rainfall 
shapefile = '/home/code/idl_user_contrib/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'
ncolors = 10
;1368X768
cnt=3
;w = WINDOW(DIMENSIONS=[900,900])
;for mo=0,6 do begin &$
  ;for YOI = 1981,2013 do begin &$
  ;w = WINDOW(WINDOW_TITLE=string(YOI),DIMENSIONS=[700,700]) &$
  p1 = image(CONGRID(ym_arc*mask,NX*1.8,NY*18),RGB_TABLE=64,FONT_SIZE=14, $
  AXIS_STYLE=0,MAP_PROJECTION='Geographic',LIMIT=[map_lry+20,map_ulx+20,map_uly,map_lrx], $
  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry], /current, layout = [2,2,cnt], margin=[0.1,0.1,0.1,0.1])  &$

  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [200,200,200] &$
  p1.rgb_table = rgbdump &$
  p1.title ='ARC' &$
  p1.mapgrid.linestyle = 6 &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.FONT_SIZE = 0 &$
  p1.min_value=0 &$
  p1.max_value=500 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black') &$
  cb = colorbar(target=p1,ORIENTATION=1,FONT_SIZE=14) 
  ;cb.tickvalues = [0,1,2,3,4,5]+0.5 &$
  cnt++ &$
endfor

;quic,k plot
i=1
ingrid = chirps01*yem_mask
i++
temp = image(total(ingrid[*,*,7,*],4,/nan), layout = [6,1,i], max_value=25, /current)
nve, ingrid

;what is annual rainfall in all of yemen and the different regions?


;rfe2 = reverse(congrid(rfe,300,320,13),2)

dims = size(RAIN, /dimensions)
NX = dims[0]
NY = dims[1]

;;;;;;;;plot the different products for the different sites, correlation would get this...
;redo this bit with the new csv filess

ifiles = file_search('/home/sandbox/people/mcnally/Yemen_stations/*csv') & print, ifiles
cormat1 = fltarr(5,2)
cormat2 = fltarr(5,2)
biasmat = fltarr(5)

for i = 0, n_elements(ifiles)-1 do begin &$
  ;read in the station lat/lon and data
  indat = read_csv(ifiles[i], header=1)  &$
  ;print, ifiles[i]
  stanam = indat.(0) &$
  lonx = indat.(1) &$
  laty = indat.(2) &$
  elev = indat.(3) &$
  sta1 = indat.(4) &$
  sta2 = indat.(5) &$
  
  ;find the pixel for worldclim ethiopia-Yemen window,
  ;;;;;;Ethiopia-Yemen window;;;;;;;;
    wmap_ulx = 30.05  & wmap_lrx = 49.95 &$
    wmap_uly = 20.15  & wmap_lry = 5.15 &$
  
    wxind = FLOOR((lonx[0] - wmap_ulx) / 0.1) &$
    wyind = FLOOR((laty[0] - wmap_lry) / 0.1) &$
  
  ;find pixel for others w. RFE2 0.25 degree window
    map_ulx = -20.  & map_lrx = 55. &$
    map_uly = 40  & map_lry = -40 &$
  ;
  xind = FLOOR((lonx[0] - map_ulx) / 0.25) &$
  yind = FLOOR((laty[0] - map_lry) / 0.25) &$
  
  gpcc_mm = reform(mean(gpc2[xind,yind,*,*],dimension=4,/nan),12) &$
  arc2_mm = reform(mean(atot[xind,yind,*,*],dimension=4,/nan),12) &$
  rfe2_mm = reform(mean(rtot[xind,yind,*,*], dimension=4,/nan),12) &$
  chrp_mm = reform(mean(ctot[xind,yind,*,*], dimension=4,/nan),12) &$
  
  wclm_mm = reform(wclim[wxind,wyind,*],12) &$
;  
  cormat1[0,*] =  r_correlate(sta1,gpcc_mm) &$
  cormat1[1,*] =  r_correlate(sta1,arc2_mm) &$
  cormat1[2,*] =  r_correlate(sta1,rfe2_mm) &$
  cormat1[3,*] =  r_correlate(sta1,chrp_mm) &$
  cormat1[4,*] =  r_correlate(sta1,wclm_mm) &$
  
  biasmat[0]  = mean((gpcc_mm-sta1)) &$
  biasmat[1] =  mean((arc2_mm-sta1)) &$
  biasmat[2] =  mean((rfe2_mm-sta1)) &$
  biasmat[3] =  mean((chrp_mm-sta1)) &$
  biasmat[4] =  mean((wclm_mm-sta1)) &$    
 
  ;print, stanam[0],lonx[0],laty[0], cormat1[*,0] &$
  print, stanam[0],lonx[0],laty[0], biasmat[*] &$

;  cormat2[0,*] =  r_correlate(sta2,gpcc_mm) &$
;  cormat2[1,*] =  r_correlate(sta2,arc2_mm) &$
;  cormat2[2,*] =  r_correlate(sta2,rfe2_mm) &$
;  cormat2[3,*] =  r_correlate(sta2,chrp_mm) &$
;  cormat2[4,*] =  r_correlate(sta2,wclm_mm) &$
;  if mean(sta2) eq -999. then cormat2 = cormat2*!values.f_nan  &$
;
;  print, stanam[0], cormat2[*,0] &$
endfor


;plot for the Farquarson et al, stations
p1=plot(gpcc_mm,'r', thick=2, name='gpcc')
p2=plot(arc2_mm, /overplot,'orange',thick=2, name='arc2')
p3=plot(rfe2_mm, /overplot,'g',thick=2, name='rfe2')
p4=plot(chrp_mm, /overplot,'b',thick=2, name='CHIRPS')
p5=plot(sta1, /overplot,'c',thick=2, name='F96 station')
p6 = plot(wclm_mm,'m', /overplot,thick=2, name='wclim')
p7 = plot(sta2,'GREY', /overplot,thick=2, name='yw STATION')

leg = LEGEND(TARGET=[P1,P2,P3,p4,p5,p6,P7],  FONT_SIZE=14,shadow=0,linestyle=6)

print, r_correlate(sta1,sta2);0.71

print, r_correlate(sta1,gpcc_mm);0.82
print, r_correlate(taiz,arc2_mm);0.85
print, r_correlate(taiz,rfe2_mm);0.44
print, r_correlate(taiz,chrp_mm);0.73
print, r_correlate(taiz,wclm_mm);0.81





print, total(gpcc_mm)
print, total(arc2_mm)
print, total(rfe2_mm)
print, total(chrp_mm)







;Africa mean annual rainfall figure
ncolors=12
p1 = image(congrid(mean(rfe2, dimension=3, /NAN), NX*3, NY*3), image_dimensions=[nx/4,ny/4],image_location=[map_ulx,map_lry]) &$
  p2 = image(congrid(mean(mask, dimension=3, /NAN), NX*3, NY*3), image_dimensions=[nx/4,ny/4],image_location=[map_ulx,map_lry], /overplot, transparency=80) &$

  p1.RGB_TABLE=64  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.title = 'avg rainfall' &$
  ;p1.max_value=1200; GHA
  p1.max_value=600 ; yemen
c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,font_size=18) &$
  ;m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot) &$
  m1 = MAP('Geographic',LIMIT = [hmap_lry,hmap_ulx,hmap_uly ,hmap_lrx], /overplot) &$

  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  m1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0, 0, 0], THICK = 2)


c = mean(mean(chirp*mask, dimension=1,/nan),dimension=1,/nan)
m1 = mean(c)
m2 = stddev(c)

ym_arc = mean(mean(arc2*mask, dimension=1,/nan),dimension=1,/nan)
am1 = mean(ym_arc)

ym_rfe = mean(mean(rfe2*mask, dimension=1,/nan),dimension=1,/nan)
rm1 = mean(ym_rfe)

tmpplt=barplot(ym_rfe-rm1, thick=3, xrange=[0,12])
xticks = indgen(13)+2001 & print, xticks
tmpplt.xTICKNAME = string(xticks)
tmpplt.xminor = 0
tmpplt.yminor = 0
tmpplt.xtickinterval = 0
tmpplt.yrange = [-60,60]

print, r_correlate(c,ym_arc)     ;0.39
print, r_correlate(ym_rfe,ym_arc);0.73 
print, r_correlate(c,ym_rfe)     ;0.34

;histogram of chirps and arc data in the yemen mask
c = ym_avg8114
a = ym_arc

omin=min([c,a])
omax=max([c,a])

pdf_a=histogram(a,locations=xbin,bins=10)
p1=barplot(xbin,pdf_a, xrange=[omin,omax])

pdf_c=histogram(c,locations=xbin,bins=10)
p2=barplot(xbin,pdf_c, xrange=[omin,omax])

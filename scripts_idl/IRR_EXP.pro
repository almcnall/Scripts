pro IRR_EXP

;10/3/14 looking at the irrigation experiments LHFLX, SM01, IRRwater. Overall irrigiaton is well 
; correlated with soil mositure and ET and I need to change the settings for PET since that output is weird.
; 10/22/14 does ECV soil moisture detect irrigation? Especially in west africa for the SMAP paper...
; 
;datadir = '/home/sandbox/people/mcnally/Noah_IRRG/'
;Noah33_EthYemen_CONSTCROP/
;Noah33_EthYemen_MODLCGRIPC/

startyr = 1981
endyr = 2013
nyrs = endyr-startyr+1

;for east africa use 3-6 for yemen use 3-9
startmo = 5
endmo = 10
nmos = endmo - startmo+1

;;;;;;Ethiopia-Yemen window;;;;;;;;
map_ulx = 30.05  & map_lrx = 49.95
map_uly = 20.15  & map_lry = 5.15

ulx = (180.+map_ulx)*10.  & lrx = (180.+map_lrx)*10.
uly = (50.-map_uly)*10.   & lry = (50.-map_lry)*10.
NX = lrx - ulx + 1 ;these match the netcdf file, good!
NY = lry - uly + 1

data_dir = '/home/sandbox/people/mcnally/Noah_IRRG/'
data_dir0 = '/home/sandbox/people/mcnally/NOAH_CHIRP_MERRA/'

irrtot_MD = fltarr(nx,ny,nyrs)
irrtot_CC = fltarr(nx,ny,nyrs)
evaptot_CC = fltarr(nx,ny,nyrs)
evaptot_MD = fltarr(nx,ny,nyrs)

evaptot = fltarr(294,348,nyrs)


SM01tot_MD = fltarr(nx,ny,nyrs)
SM01tot_CC = fltarr(nx,ny,nyrs)
SM01tot = fltarr(294,348,nyrs)

PETtot_CC = fltarr(nx,ny,nyrs)
PETtot_MD = fltarr(nx,ny,nyrs)
QSUFtot_MD = fltarr(nx,ny,nyrs)
QSUFtot_CC = fltarr(nx,ny,nyrs)


for yr = startyr,endyr do begin &$
  for i=0,nmos-1 do begin &$
    y = yr &$
    m = startmo + i &$
    
;    fileID = ncdf_open(data_dir+STRING(FORMAT='(''Noah33_EthYemen_MODLCGRIPC/IRRG_YRMO/IRRG_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
;    irrgID = ncdf_varid(fileID,'IrrigatedWater_tavg') &$
;    ncdf_varget,fileID, irrgID, IRRG &$
;    irrtot_MD[*,*,yr-startyr] = irrtot_MD[*,*,yr-startyr] + IRRG &$
;    
;    ifile = file_search(data_dir+STRING(FORMAT='(''Noah33_EthYemen_CONSTCROP/IRRG_YRMO/IRRG_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m)) &$
;    fileID2 = ncdf_open(ifile, /nowrite) &$
;    irrgID2 = ncdf_varid(fileID2,'IrrigatedWater_tavg') &$
;    ncdf_varget,fileID2, irrgID2, IRRG2 &$
;    irrtot_CC[*,*,yr-startyr] = irrtot_CC[*,*,yr-startyr] + IRRG2 &$
;    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    ifile = file_search(data_dir+STRING(FORMAT='(''Noah33_EthYemen_CONSTCROP/Evap_YRMO/Evap_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m)) &$
;    fileID = ncdf_open(ifile, /nowrite) &$
;    evapID = ncdf_varid(fileID,'Evap_tavg') &$
;    ncdf_varget,fileID, evapID, EVAP &$
;    evaptot_CC[*,*,yr-startyr] = evaptot_CC[*,*,yr-startyr] + EVAP &$
;    
;    ifile = file_search(data_dir+STRING(FORMAT='(''Noah33_EthYemen_MODLCGRIPC/Evap_YRMO/Evap_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m)) &$
;    fileID2 = ncdf_open(ifile, /nowrite) &$
;    evapID2 = ncdf_varid(fileID,'Evap_tavg') &$
;    ncdf_varget,fileID2, evapID2, EVAP2 &$
;    evaptot_MD[*,*,yr-startyr] = evaptot_MD[*,*,yr-startyr] + EVAP2 &$
    
    ;;;;;;;No irrigation EVAP;;;;;;;;
    ifile = file_search(data_dir0+STRING(FORMAT='(''Evap_YRMO/Evap_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m)) &$
    fileID = ncdf_open(ifile, /nowrite) &$
    evapID = ncdf_varid(fileID,'Evap_tavg') &$
    ncdf_varget,fileID, evapID, EVAP &$
    evaptot[*,*,yr-startyr] = evaptot[*,*,yr-startyr] + EVAP &$
    
;    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    ifile = file_search(data_dir+STRING(FORMAT='(''Noah33_EthYemen_MODLCGRIPC/SM01_YRMO/SM01_Noah'',I4.4,''.'',I2.2,''.nc'')',y,m)) &$
;    fileID = ncdf_open(ifile, /nowrite) &$
;    smID = ncdf_varid(fileID,'SoilMoist_tavg') &$
;    ncdf_varget,fileID, smID, SM01 &$
;    SM01tot_MD[*,*,yr-startyr] = SM01tot_MD[*,*,yr-startyr] + SM01 &$
;    
;    ifile = file_search(data_dir+STRING(FORMAT='(''Noah33_EthYemen_CONSTCROP/SM01_YRMO/SM01_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m)) &$
;    fileID2 = ncdf_open(ifile, /nowrite) &$
;    smID2 = ncdf_varid(fileID2,'SoilMoist_tavg') &$
;    ncdf_varget,fileID2, smID2, SM012 &$
;    SM01tot_CC[*,*,yr-startyr] = SM01tot_CC[*,*,yr-startyr] + SM012 &$
;    
    ;no irrigation exp;;;;;;;SM01_Noah2013_12.nc
    ifile = file_search(data_dir0+STRING(FORMAT='(''SM01_YRMO/SM01_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m)) &$
    fileID = ncdf_open(ifile, /nowrite) &$
    smID = ncdf_varid(fileID,'SoilMoist_tavg') &$
    ncdf_varget,fileID, smID, SM01 &$
    SM01tot[*,*,yr-startyr] = SM01tot[*,*,yr-startyr] + SM01 &$

 ;;;;;;;;;;;;;;;;;   
;    ifile = file_search(data_dir+STRING(FORMAT='(''Noah33_EthYemen_MODLCGRIPC/PET_YRMO/PET_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m)) &$
;    fileID = ncdf_open(ifile, /nowrite) &$
;    petID = ncdf_varid(fileID,'PotEvap_acc') &$
;    ncdf_varget,fileID, petID, PET &$
;    PETtot_MD[*,*,yr-startyr] = PETtot_MD[*,*,yr-startyr] + PET &$
;      
 ;;;;;;;;;;;;;;;;;
;    ifile = file_search(data_dir+STRING(FORMAT='(''Noah33_EthYemen_MODLCGRIPC/QSUF_YRMO/Qsuf_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m)) &$
;    fileID = ncdf_open(ifile, /nowrite) &$
;    qsufID = ncdf_varid(fileID,'Qs_tavg') &$
;    ncdf_varget,fileID, qsufID, QSUF &$
;    QSUFtot_MD[*,*,yr-startyr] = QSUFtot_MD[*,*,yr-startyr] + QSUF &$
;    
;    ifile = file_search(data_dir+STRING(FORMAT='(''Noah33_EthYemen_CONSTCROP/QSUF_YRMO/Qsuf_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m)) &$
;    fileID = ncdf_open(ifile, /nowrite) &$
;    qsufID = ncdf_varid(fileID,'Qs_tavg') &$
;    ncdf_varget,fileID, qsufID, QSUF &$
;    QSUFtot_cc[*,*,yr-startyr] = QSUFtot_cc[*,*,yr-startyr] + QSUF &$
       
  endfor &$
endfor

irrtot_cc(where(irrtot_cc lt 0))=!values.f_nan
irrtot_md(where(irrtot_md lt 0))=!values.f_nan

evaptot_cc(where(evaptot_cc lt 0))=!values.f_nan
evaptot_md(where(evaptot_md lt 0))=!values.f_nan
evaptot(where(evaptot lt 0))=!values.f_nan

sm01tot_cc(where(sm01tot_cc lt 0))=!values.f_nan
sm01tot_md(where(sm01tot_md lt 0))=!values.f_nan
sm01tot(where(sm01tot lt 0))=!values.f_nan

;pettot_md(where(pettot_md lt 0))=!values.f_nan
;pettot_cc(where(pettot_cc lt 0))=!values.f_nan
;QSUFtot_md(where(QSUFtot_md lt 0))=!values.f_nan
;QSUFtot_cc(where(QSUFtot_cc lt 0))=!values.f_nan

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;make the clip the non-irrigated domain to the IRR domain
;East Africa WRSI/Noah window
ea_ulx = 22.  & ea_lrx = 51.35
ea_uly = 22.95  & ea_lry = -11.75

;;;;;;;;;the yemen-ethipia subset;;;;;;;;
yulx = (map_ulx-ea_ulx)*10.  & ylrx = (map_lrx-ea_ulx)*10.
ylry = (map_lry-ea_lry)*10.   & yuly = (map_uly-ea_lry)*10.

eySM = sm01tot[yulx:ylrx, ylry:yuly,*] & help, eysm
eyET = evaptot[yulx:ylrx, ylry:yuly,*] & help, eyET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;write out an example to make mask in envi
;outdat = reverse(mean(irrtot_CC,dimension=3),2)
;ofile = '/home/sandbox/people/mcnally/yemen_eth4mask_200x151.img'
;openw,1,ofile
;writeu,1,outdat
;close,1

;read in and map the different crop types, greenness etc.
;LANDCOVER,IRRIGFRAC
  ifile = file_search('/home/sandbox/people/mcnally/lis_input.EthYmn.constcrop_gripc.nc')
  ifile = file_search('/home/sandbox/people/mcnally/lis_input.EthYmn.modislc_gripc.nc')

  fileID = ncdf_open(ifile, /nowrite)
  lndID = ncdf_varid(fileID,'LANDCOVER')
  ncdf_varget,fileID, lndID, land
  
  fileID = ncdf_open(ifile, /nowrite)
  irrID = ncdf_varid(fileID,'IRRIGFRAC')
  ncdf_varget,fileID, irrID, IRRG
  
  
  ;Yemen Highland window
  hmap_ulx = 43. & hmap_lrx = 45.
  hmap_uly = 17. & hmap_lry = 12.5 


;plot different yemen maps
ncolors=10
p1 = image(congrid(mean(eyEt*86400, dimension=3), NX*3, NY*3), image_dimensions=[nx/10,ny/10],image_location=[map_ulx,map_lry],RGB_TABLE=64)  &$
;p1 = image(congrid(total(land[*,*,8:13],3), NX*3, NY*3), image_dimensions=[nx/10,ny/10],image_location=[map_ulx,map_lry],RGB_TABLE=20)  &$
;p2 = image(congrid(mean(mask, dimension=3), NX*3, NY*3), min_value=0,image_dimensions=[nx/10,ny/10],image_location=[map_ulx,map_lry],RGB_TABLE=4, /overplot, transparency=80)

rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.title = 'Landcover' &$
  ;p1.max_value=20
  p1.min_value=0
c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,font_size=18) &$
  ;m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot) &$
  m1 = MAP('Geographic',LIMIT = [hmap_lry,hmap_ulx,hmap_uly ,hmap_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [50, 50, 50] &$
  m1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0,0,0], THICK = 2)
  
  ;mask out the yemen highlands for averaging
  
  ;mask by ROIs
  ifile = file_search('/home/sandbox/people/mcnally/yemen_shp/YM_agzone_200x151')
  agzn = bytarr(nx,ny)
  openr,1,ifile
  readu,1,agzn
  close,1
  agzn = reverse(agzn,2)

  ;1=arabian sea
  ;2=desert
  ;3=highlands
  ;4=temperate highlands
  ;5=internal plateau
  ;6=redsea
  ;subset the areas in the red& highx2
  mask = fltarr(nx,ny)
  good = where(agzn eq 3 OR agzn eq 4 OR agzn eq 6, complement=other)
  mask(good)=1
  mask(other)=!values.f_nan
  mask = rebin(mask,nx,ny,33)
  
  irrmd  = mean(mean(irrtot_md*mask,dimension=1,/nan),dimension=1,/nan)
  irrcc  = mean(mean(irrtot_cc*mask,dimension=1,/nan),dimension=1,/nan)
  evapmd = mean(mean(evaptot_md*mask,dimension=1,/nan),dimension=1,/nan)
  evapcc = mean(mean(evaptot_cc*mask,dimension=1,/nan),dimension=1,/nan)
  smmd   = mean(mean(sm01tot_md*mask,dimension=1,/nan),dimension=1,/nan)
  smcc   = mean(mean(sm01tot_cc*mask,dimension=1,/nan),dimension=1,/nan)
  sm   = mean(mean(eySM*mask,dimension=1,/nan),dimension=1,/nan)
  et = mean(mean(eyET*mask,dimension=1,/nan),dimension=1,/nan)

  p1=barplot((et-mean(et))*86400, thick=3, xrange=[0,32])
  xticks = indgen(33)+1981 & print, xticks
  p1.xTICKNAME = string(xticks)
  p1.xminor = 1
  p1.yminor = 0
  p1.xtickinterval = 2
  p1.yrange = [-2,2]


;  petcc  = mean(mean(pettot_cc*mask,dimension=1,/nan),dimension=1,/nan)
;  petmd  = mean(mean(pettot_md*mask,dimension=1,/nan),dimension=1,/nan)
;  qsfmd  = mean(mean(qsuftot_md*mask,dimension=1,/nan),dimension=1,/nan)
;  qsfcc  = mean(mean(qsuftot_cc*mask,dimension=1,/nan),dimension=1,/nan)
   
  print, correlate(irrmd, irrcc);0.98
  
;irrigation seems to be driven by low SM and Evap 
  print, r_correlate(irrmd, evapmd);-0.79, -0.82 (rank)
  print, r_correlate(irrcc, evapcc);-0.82, -0.9 more irrigation yield more neg corr, dry yr need more added water?
  print, r_correlate(irrmd, smmd)  ;-0.68, -0.62 (not sig)
  print, r_correlate(irrcc, smcc)  ;-0.73, -0.77 both evap and SM are more strongly correlated with irrg when there is more irrg.
 
  
  print, r_correlate(evapmd, smmd)  ;0.94, 0.83 ok, so soil moisture and ET coary and more irr is needed in dry yrs
  print, r_correlate(evapcc, smcc)  ;0.92, 0.82 ok, so soil moisture and ET coary and more irr is needed in dry yrs
  
  print, r_correlate(sm, smmd);1.0 0.98 the non0irrigated and irrgated sm are well correlated
  print, r_correlate(et, evapmd);0.99 0.97 the non0irrigated and irrgated ET are well correlated

  print, correlate(evapmd, petmd)  ;0.33 - no real rel. between PET and ET
  print, correlate(evapcc, petcc)  ;0.34 - no real rel. between PET and ET
  print, correlate(smmd, petmd)  ;0.39 - no real rel. between PET and SM
  print, correlate(smcc, petcc)  ;0.39 - no real rel. between PET and SM
  print, correlate(qsfcc, petcc)  ;0.10 - no real rel. between PET and RO
  print, correlate(irrcc, petcc)  ;-0.10 - no real rel. between PET and RO


  
  print, r_correlate(smcc, qsfcc)  ;0.75, 0.72 (rank) - wetter soil, more RO
  print, r_correlate(smmd, qsfmd)  ;0.71, 0.72 (rank) - wetter soil, more RO


  p1 = plot(mean(mean(irrtot_md*86400*mask,dimension=1,/nan),dimension=1,/nan),name='irr MODIS landcov', thick=2)
  p2 = plot(mean(mean(irrtot_cc*86400*mask,dimension=1,/nan),dimension=1,/nan),name='irr MAIZE landcov', /overplot, 'c', thick=2)
 
  p3 = plot(mean(mean(evaptot_cc*mask*86400,dimension=1,/nan),dimension=1,/nan),name='evap MAIZE landcov', /overplot, 'c', thick=3)
  p4 = plot(mean(mean(evaptot_md*mask*86400,dimension=1,/nan),dimension=1,/nan),name='evap MODIS landcov', /overplot, linestyle=2, thick=3)
  ;p5 = plot(mean(mean(eyET*mask*86400,dimension=1,/nan),dimension=1,/nan),name='evap_No irr MODIS landcov', /overplot,'orange', linestyle=2, thick=3)

  p6 = plot(mean(mean(sm01tot_cc*mask,dimension=1,/nan),dimension=1,/nan),name='SM01 MAIZE landcov', /overplot, 'c',linestyle=3, thick=3)
  p7 = plot(mean(mean(sm01tot_md*mask,dimension=1,/nan),dimension=1,/nan),name='SM01 MODIS landcov', /overplot, linestyle=3, thick=3)
  ;p8 = plot(mean(mean(eysm*mask,dimension=1,/nan),dimension=1,/nan),name='SM01_No irr MODIS landcov', /overplot, 'orange',linestyle=3, thick=3)

;  p7 = plot(mean(mean(pettot_cc/10*mask,dimension=1,/nan),dimension=1,/nan),name='PET MAIZE landcov', /overplot, 'c',linestyle=4, thick=2)
;  p8 = plot(mean(mean(pettot_md/10*mask,dimension=1,/nan),dimension=1,/nan),name='PET MODIS landcov', /overplot, linestyle=4, thick=2)
;  p9 = plot(mean(mean(qsuftot_md*100000*mask,dimension=1,/nan),dimension=1,/nan),name='Qsuf MODIS landcov', /overplot, linestyle=5, thick=2)
;  p10 = plot(mean(mean(qsuftot_cc*100000*mask,dimension=1,/nan),dimension=1,/nan),name='Qsuf MAIZE landcov', /overplot,'c', linestyle=5, thick=2)


  p1.xrange=[0,32]
  xticks = indgen(33)+1981 & print, xticks
  xticks = indgen(9)+2005 & print, xticks

  p6.xTICKNAME = string(xticks)
  p7.xminor = 0
  p1.yminor = 0
  p1.xtickinterval = 3 
  !null = legend(target=[p6,p7], position=[0.2,0.3])


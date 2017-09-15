pro hyperwall_anoms

;;this is to make anomaly plots for the hyperwall

startyr = 1982 ;start with 1982 since no data in 1981
endyr = 2017
nyrs = endyr-startyr+1

;re-do for all months
startmo = 1
endmo = 12
nmos = endmo - startmo+1
;;first calculate the monthly means for the different soil moisture layers (esp SM02)

;;from readin_chirps_noah_sm_AF.pro
help, smm3
;if i want to do total storage i guess i should do the full column?

;revisit when the runs are complete
;SM02clim = mean(sm02, dimension=4, /nan)
SMm3clim = mean(smm3[*,*,*,0:34], dimension=4, /nan) ;just the 1982-2016 (not 2017)
;what if i mask before anomalies? the ocean will be zero
SMclim = rebin(smm3clim,nx,ny,nmos,nyrs) & help, smclim
SManom = Smm3-SMclim & help, SManom
  
  ;;;;;;;;;this is a CONTOUR plot;;;;;;;;;;;
  ;;;read in landcover MODE to grab sparse veg mask;;;
  ;;;;eastern, southern africa;;;;;;
 ; indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/' ;i would rather have hymap...
  indir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/AFRICA/LDT_run/'
  mfile_E = file_search(indir+'lis_input_af_elev.nc') ;'lis_input.MODISmode_ea.nc')
  ;mfile_S = file_search(indir+'lis_input_sa_elev_mode.nc')
  ;mfile_W = file_search(indir+'lis_input_wa_elev_mode.nc')

  params = get_domain01('AF')
  
  eNX = params[0]
  eNY = params[1]
  emap_ulx = params[2]
  emap_lrx = params[3]
  emap_uly = params[4]
  emap_lry = params[5]

  map_ulx = emap_ulx & min_lon = map_ulx
  map_lry = emap_lry & min_lat = map_lry
  map_uly = emap_uly & max_lat = map_uly
  map_lrx = emap_lrx & max_lon = map_lrx
  NX = eNX
  NY = eNY
  
  ; VOI = 'HYMAP_basin'
  ; LC = get_nc(VOI, mfile_E)
  ; water = where(LC eq 8, complement=other)
  ; Vmask = fltarr(eNX,eNY)+1.0
  ; Vmask(water)=1
  ; Vmask(other)=!values.f_nan
  ;Vmask[*,140:347]=!values.f_nan

  VOI = 'LANDCOVER'
  LC = get_nc(VOI, mfile_E)
  LAND = total(LC,3)
  bare = where(LC[*,*,15] eq 1, complement=green)
  ground = where(LAND gt 0, complement=ocean); this deosn't quite work

;ocean and desert mask - is there a better way?
  Emask = fltarr(eNX,eNY)
  Emask(bare)= 999
  Emask(ocean)=-999

  shapefile = '/discover/nobackup/almcnall/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'
  mask = emask
  
  mlim = [min_lat,min_lon,max_lat,max_lon]
  m1 = MAP('Geographic',LIMIT=mlim,/CURRENT,horizon_thick=1)
  xsize=0.10
  ysize=0.10
  mask=emask
  
  emaskcube = rebin(emask,nx,ny,nmos,nyrs)
  ;first constrain the values between -20 to 20, then apply the very large and very small mask
  smanom(where(smanom ge 20))=20
  smanom(where(smanom le -20))=-20
  
  smanom=smanom+emaskcube 
  
  smanom(where(smanom gt 20))=21
  smanom(where(smanom lt -20))=-21
  
mname = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']  
yname = string(indgen(nyrs)+1982)
;some value adjustment to get the mask to work.
;some problems on low end, nicer colorbar pls. Usually do this with contour but..
for y = 33,34 do begin &$
 for y = 33,33 do begin &$
 ; w = WINDOW(DIMENSIONS=[700,819], /buffer) &$;works for EA 4104x2304

 ; w = WINDOW(DIMENSIONS=[1000,2304],/buffer) &$;works for EA 4104x2304

  ;m1 = MAP('Geographic',LIMIT=mlim,/CURRENT,horizon_thick=1) &$

  yr = y+1982 &$
  for mo = 0,11 do begin &$
  w = WINDOW(DIMENSIONS=[700,819]) &$;works for EA 4104x2304
  m1 = MAP('Geographic',LIMIT=mlim,/CURRENT,horizon_thick=1) &$

    mon = STRING(format='(I2.2)', mo+1) &$
  ;ncolors=21 &$
  ingrid = smm3[*,*,mo,y] &$
  ;ingrid = smanom[*,*,mo,y] &$
;  ingrid(where(ingrid ge 20))= 20 &$
;  ingrid(where(ingrid le -20))=-20 &$
 ; bin = floor((255./(ncolors-1)))
  tmpgr = image(ingrid,rgb_table=74,image_dimensions=[nx/10,ny/10], image_location=[map_ulx,map_lry], $
     MAP_PROJECTION='Geographic', XSTYLE=1, YSTYLE=1, /OVERPLOT) &$
    ; tmpgr.max_value = 50 ;for anomalies min_value=-21, max_value=21,
    ; tmpgr.min_value = -1
    ;rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
    rgbdump = tmpgr.rgb_table &$
    ;rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
    rgbdump[*,255] = [222,222,222] &$ ; set map values of zero to white, you can change the color
    rgbdump[*,0] = [171,217,233]&$
    tmpgr.rgb_table = rgbdump &$
    
  cb = COLORBAR(TARGET=tmpgr, POSITION=[0.05,0.02,0.95,0.04],FONT_SIZE=11,/BORDER) &$
   tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0 &$
  ;position = x1,y1, x2, y2
  mc = MAPCONTINENTS(shapefile, /COUNTRIES,COLOR=[82,82,82],FILL_BACKGROUND=0,LIMIT=mlim, thick=1) &$
  tmpgr.title = 'Water Storage Anomaly '+strcompress(mname[mo]+'  '+yname[y]) &$
  tmpgr.title = 'Water Storage '+strcompress(mname[mo]+'  '+yname[y]) &$

 ; ofile = strcompress('/home/almcnall/HW_'+string(yr)+string(mon)+'v2.png', /remove_all) &$
 ; ofile = strcompress('/home/almcnall/SMTOT_'+string(yr)+string(mon)+'.png', /remove_all) &$

  ;tmpgr.save, ofile, RESOLUTION=270 &$
  endfor &$
endfor



  ;;tmptr.save,'/home/almcnall/WaterAvail24mo_Apr.png'
  close
 
 ;;write out absolute values...also divide by population?? Do i have continental population? 
 
 tifftemp = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/HYPERWALL/AF.tif' 
  temp = read_tiff(tifftemp,R,G,B,geotiff=g_tags)
  ;;write out for Jossy
;2017-startyr
sstart = 2009-startyr & print, sstart
sstop = 2017-startyr & print, sstop
for y=sstart,sstop do begin &$
  yr = y+1982 &$
  for mo =0, 11 do begin &$
    mon = STRING(format='(I2.2)', mo+1) &$
    ofile1 = strcompress('/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/HYPERWALL/AF_SOILSTORE_ANOM_751x801_'+string(yr)+string(mon)+'.tif', /remove_all) &$
    ofile2 = strcompress('/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/HYPERWALL/AF_SOILSTORE_751x801_'+string(yr)+string(mon)+'.tif', /remove_all) &$

    ogrid1 = reverse(SManom[*,*,mo,y]*mask,2) &$
    ogrid2 = reverse(SMM3[*,*,mo,y],2) &$

    write_tiff, ofile1,ogrid1 ,/FLOAT,geotiff=g_tags &$
    write_tiff, ofile2,ogrid2 ,/FLOAT,geotiff=g_tags &$

    ;ofile = strcompress('/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/HYPERWALL/AF_SOILSTORE_ANOM_751x801_'+string(yr)+string(mon)+'.bin', /remove_all) &$
    ;print, ofile &$
    ;openw,1,ofile &$
    ;writeu,1,SManom[*,*,mo,y]*mask &$
    ;close,1 &$
  endfor &$
endfor
  
  

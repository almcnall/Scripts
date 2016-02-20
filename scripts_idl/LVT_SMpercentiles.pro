pro LVT_SMpercentiles

;08/13/15 percentiles computed in LVT moved from getSM_percentiles_EA
; this script makes plots based on the drought monitor and computes the drought severity index. 
; Not sure how this will be in the netcdf files, but the soil moisture percentiles for sure. Add other things like SPI later. 
; 9/29/15 does this include the USDM color scheme? yes. Update to use the FILES4GESDISC rather than the LVT_percentiles
; 10/9/15 compute drought severity index for ethiopia region of interest. 
; 12/9/15 update for AGU
; 01/7/15 update for southen africa

;  NX = 294
;  NY = 348

;East Africa WRSI/Noah window
;map_ulx = 22.  & map_lrx = 51.35
;map_uly = 22.95  & map_lry = -11.75

;Southern Africa WRSI/Noah window
;Southern Africa (37.85 S - 6.35 N; 6.05 E - 54.55 E)
;NX = 486, NY = 443
map_ulx = 6.05  & map_lrx = 54.55
map_uly = 6.35  & map_lry = -37.85

;  data_dir = '/home/sandbox/people/mcnally/LVT_percentiles/EA_percentiles/'
;  ;get the NX NY from the netcdf file
;  fileID = ncdf_open(data_dir+'Percentile_TS.201401010000.d01.nc', /nowrite) &$
;  SoilID = ncdf_varid(fileID,'SoilMoist_from_SoilMoist_v_SoilMoist_ds1') &$
;  ncdf_varget,fileID, SoilID, SM01
;  dims = size(SM01, /dimensions)
;  NX = dims[0]
;  NY = dims[1]

data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_CHIRPSv2.001_MERRA_SA/';FLDAS_NOAH01_B_SA_M.A201507.001.nc
;data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_RFE2_GDAS_SA/';FLDAS_NOAH01_B_SA_M.A201507.001.nc

;data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_CHIRPSv2.001_MERRA_EA/';FLDAS_NOAH01_B_SA_M.A201507.001.nc
;fileID = ncdf_open(data_dir+STRING('FLDAS_NOAH01_B_EA_M.A200101.001.nc'), /nowrite)
fileID = ncdf_open(data_dir+STRING('FLDAS_NOAH01_B_SA_M.A200101.001.nc'), /nowrite)
;fileID = ncdf_open(data_dir+STRING('FLDAS_NOAH01_A_SA_M.A200101.001.nc'), /nowrite)


;get the NX NY from the netcdf file
qsID = ncdf_varid(fileID,'SM01_Percentile') &$ ;
  ncdf_varget,fileID, qsID, SMP &$
  dims = size(SMP, /dimensions)
NX = dims[0]
NY = dims[1]
NCDF_close, fileID

  ;read in percentiles from LVT
  startyr = 1982
  endyr = 2015
  nyrs = endyr-startyr+1

  ;these percentiles are 0-100
  startmo = 1
  endmo = 12
  nmos = endmo - startmo+1
  SM = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
  ;this loop reads in the selected months only
  for yr=startyr,endyr do begin &$
    for i=0,nmos-1 do begin &$
    y = yr &$
    m = startmo + i &$
    if m gt 12 then begin &$
    m = m-12 &$
    y = y+1 &$
  endif &$
  fileID = ncdf_open(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_B_SA_M.A'',I4.4,I2.2,''.001.nc'')',y,m), /nowrite) &$; 200101.001.nc'), /nowrite)
  ;fileID = ncdf_open(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_A_SA_M.A'',I4.4,I2.2,''.001.nc'')',y,m), /nowrite) &$; 200101.001.nc'), /nowrite)

  ;fileID = ncdf_open(data_dir+STRING(FORMAT='(''Percentile_TS.'',I4.4,I2.2,''010000.d01.nc'')',y,m), /nowrite) &$
  ;SoilID = ncdf_varid(fileID,'SoilMoist_from_SoilMoist_v_SoilMoist_ds1') &$
  SoilID = ncdf_varid(fileID,'SM01_Percentile') &$
  ncdf_varget,fileID, SoilID, SM01 &$
  SM[*,*,i,yr-startyr] = SM01 &$
  NCDF_close, fileID &$
endfor &$
endfor
sm(where(sm lt 0))   = !values.f_nan ;CHIRPS MERRA

;for each month in the time series classify these using the USDM scheme
;from US drought monitor (0-2 = exceptional D4=5; 3-5 = extreme D3=4); 6-10=severe D2=[3];
;                         11-20=moderate D1=[2]; 21-30 = abnormal dry D0=[1]; >30 not drought D00[0]
  npc = sm*!values.f_nan
  npc(where(sm le 0.02)) = 5 &$
  npc(where(sm gt 0.02 AND sm le 0.05)) = 4 &$
  npc(where(sm gt 0.05 AND sm le 0.10)) = 3 &$
  npc(where(sm gt 0.10 AND sm le 0.20)) = 2 &$
  npc(where(sm gt 0.21 AND sm le 0.30)) = 1 &$
  npc(where(sm gt 0.3))  = 0

;shapefile = '/home/code/idl_user_contrib/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'
ncolors = 6
CLASS = [' > normal ', 'abnormally dry', 'moderate drought', 'severe drought', 'extreme drought', 'exceptional drought']
month = ['jan','feb','mar','apr','may','jun','jul','aug']
;1368X768
cnt=1
w = WINDOW(WINDOW_TITLE='SM percentile-drought classes',DIMENSIONS=[900,700])
for YOI = 1984,2015 do begin &$
  ;show 1984, 2002, 2015
  YOI=2015
  mo = 11 &$
;for mo=9,10 do begin &$
  ;for YOI = 1981,2013 do begin &$
  ;w = WINDOW(WINDOW_TITLE=string(YOI),DIMENSIONS=[700,700]) &$
  p1 = image(CONGRID(npc[*,*,mo,YOI-startyr],NX*1.8,NY*18),RGB_TABLE=65,FONT_SIZE=14, $
  AXIS_STYLE=0,MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], $
  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry], /current, layout = [2,1,2], margin=[0.1,0.1,0.1,0.1])  &$

  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [200,200,200] &$
  p1.rgb_table = rgbdump &$
  p1.title = 'Dec 2015' &$
  p1.mapgrid.linestyle = 6 &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.FONT_SIZE = 0 &$
  p1.min_value=-0.5 &$
  p1.max_value=5.5 &$
  ;mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black') &$  
  cnt++ &$
  ;p1.save,strcompress('/home/sandbox/people/mcnally/figs4kyle/EA_SMpercentile.Mar,Sep_'+string(YOI)+'_.jpg', /remove_all),RESOLUTION=200 &$
endfor  &$
 ; cb = colorbar(target=p1,ORIENTATION=1,FONT_SIZE=14, POSITION=[0.14,0.3,0.16,0.6]) &$
  cb = colorbar(target=p1,ORIENTATION=1,FONT_SIZE=14) &$
  cb.tickvalues = [0,1,2,3,4,5] &$
  cb.tickname = CLASS &$
  cb.minor=0
  cb.TEXT_ORIENTATION=25

;for multipannel plot
;   cb = colorbar(target=p1,ORIENTATION=0,FONT_SIZE=12, POSITION=[0.22,0.05,0.29,0.9]) &$
;   cb.tickvalues = [0,1,2,3,4]+0.5 &$
;   cb.tickname = CLASS &$
;   cb.minor=0 &$
endfor

;;;;;;compute the drought severity index;;;;;;;;;;
npcvect = reform(npc,nx,ny,12*nyrs);was 34
ndrought = intarr(nx,ny,12*nyrs)
nseverity = fltarr(nx,ny,12*nyrs)

cnt=0

for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$

  nts = npcvect[x,y,*] &$
  for z = 1, n_elements(nts)-1 do begin &$

  if nts[z] ge 2 AND nts[z-1] ge 2 then cnt++ else cnt = 0 &$
  nseverity[x,y,z] = cnt*nts[z] &$
  ndrought[x,y,z] = cnt &$
  ; if  cnt gt 0 then print, cnt &$
endfor &$
endfor &$
endfor

;Gabarone Drought Severity Index is currently in getSM_percentiles

;;;southern Africa;;;;;;
;Gabarone Dame
gxind = FLOOR( (25.926 - map_ulx)/ 0.1)
gyind = FLOOR( (-24.5 - map_lry) / 0.1)

;Lesotho 29.5S, 28.5 E
lxind = FLOOR( (28.5 - map_ulx)/ 0.1)
lyind = FLOOR( (-29.5 - map_lry) / 0.1)

;Hwane Dam Swaziland 26.2S, 31E
hxind = FLOOR( (31 - map_ulx)/ 0.1)
hyind = FLOOR( (-26.2 - map_lry) / 0.1)

;Namibia Winkhoek, 22 S, 17E
nxind = FLOOR( (17 - map_ulx)/ 0.1)
nyind = FLOOR( (-22 - map_lry) / 0.1)

;Kariba Dam, Zambia, Zimbabwae 17S, 27.5E
kxind = FLOOR( (27.5 - map_ulx)/ 0.1)
kyind = FLOOR( (-17 - map_lry) / 0.1)


;
;;Kenya HESS window
;hmap_ulx = 24. & hmap_lrx = 51.
;hmap_uly = 10. & hmap_lry = -10
;
;;Ethiopia Drought Amhara 11.6608N 37.9578E, Tigray = (14,39.4), Afar= 11.81667N, 41.416667
;hmap_ulx = 37.5 & hmap_lrx = 38.0
;hmap_uly = 12. & hmap_lry = 11.
;
;hmap_ulx = 39 & hmap_lrx = 40
;hmap_uly = 14.5 & hmap_lry = 13.5
;
;hmap_ulx = 40.75 & hmap_lrx = 41.5
;hmap_uly = 12 & hmap_lry = 11.5
;
;;BOX1
;hmap_ulx = 40.9 & hmap_lrx = 41.9
;hmap_uly = 11.45 & hmap_lry = 10.65
;
;;BOX3
;hmap_ulx = 39.1 & hmap_lrx = 40.2
;hmap_uly = 9.35 & hmap_lry = 7.95
;
;
;hulx = (hmap_ulx-22)*10.  & hlrx = (hmap_lrx-22)*10.-1
;huly = (11.75+hmap_uly)*10.   & hlry = (11.75+hmap_lry)*10.-1
;
;;kenya box 270.5 x 203
;hNX = hlrx - hulx + 1.5
;hNY = huly - hlry + 2
xind = nxind
yind = nyind
p1 = barplot(mean(mean(nseverity[xind-5:xind+5,yind-5:yind+5,*],dimension=1,/NAN),dimension=1,/NAN))
;p1 = barplot(mean(mean(nseverity[hulx:hlrx,hlry:huly,*],dimension=1,/NAN),dimension=1,/NAN))

p1.xrange=[0,407]
p1.xtickinterval=12
p1.xtickname=strmid(string(indgen(nyrs+1)+startyr),6,2)
p1.xminor=1
p1.yrange =[0,15]
p1.title = 'Namibia'


p1.title = 'East Rift 7.95N-9.35N, 39.1-40.2E'

;output for ENVI, now how to add the admin 2 units for ROIs?
;Also show slice ...eg. map that flags conditions as 'severe' click on ROI for how it compares to past events.
;e.g. current drought in Ethiopia (or something from January in southern Africa)
;ofile = '/home/sandbox/people/mcnally/EA_drought_severity_1981_2015.bin'
;openw,1,ofile
;writeu,1,reverse(nseverity,2)
;close,1

;ofile = '/home/sandbox/people/mcnally/EA_SMpercentile_class_Aug2015.bin'
;openw,1,ofile
;writeu,1,reverse(npc[*,*,7,33],2)
;close,1

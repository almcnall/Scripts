getSM_percentiles_EastAfrica

;5/13/14 similar to the geoEOS_WRSI_OND this script is going to look at the predicted EOS percentiles, hope to compare to FSOs
; ah, this old stuff is in binary vs the new netcdf
;6/3/14 update with re-done historic runs. still might be problems with the forecast? How would the forecasts work in LIS now?
;9/15/14  plots for Verdin's SERVIR meeting
;9/22/14  MAM plots too?
;11/18/14 revisit for Boulder meeting. Show WRSI percentiles/anomalies
;12/11/14 revisit to put OND and MAM anomalies into a single timeseries.
;04/24/15 make soil mositure percentiles March-October
;04/27/15 make soil moisture percentiles for Southern Africa
;06/05/15 update to CHIRPSv2.0 and into 2015
;07/08/15 update and use a baseline 1981-2014
;08/17/15 update with the LVT computed percentiles. pretty close to my initial attempt.
;09/03/15 compare/plot Feb/Mar/April soil moisture percentiles vs Africa Hazards Outlook
;09/10/15 update to use the GES DISC percentiles

;Southern Africa WRSI/Noah window
;Southern Africa (37.85 S - 6.35 N; 6.05 E - 54.55 E)
;NX = 486, NY = 443
map_ulx = 6.05  & map_lrx = 54.55
map_uly = 6.35  & map_lry = -37.85

;southern Africa WRSI mask
fileID = ncdf_open('//home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input_wrsi.sa.nc', /nowrite) &$
  SoilID = ncdf_varid(fileID,'WRSIMASK') &$
  ncdf_varget,fileID, SoilID, SAmask

data_dir = '/home/ftp_out/people/mcnally/FLDAS/NOAH_CHIRPSv2_MERRA_SA/';FLDAS_NOAH01_B_SA_M.A201507.001.nc
fileID = ncdf_open(data_dir+STRING('FLDAS_NOAH01_B_SA_M.A200101.001.nc'), /nowrite) 

;get the NX NY from the netcdf file
qsID = ncdf_varid(fileID,'SM01_Percentile') &$ ;
ncdf_varget,fileID, qsID, SMP &$
dims = size(SMP, /dimensions)
NX = dims[0]
NY = dims[1]

;read in percentiles from LVT
startyr = 1981
endyr = 2015
nyrs = endyr-startyr+1

;these percentiles are 0-100
startmo = 1
endmo = 12
nmos = endmo - startmo+1
SMper = FLTARR(NX,NY,nmos,nyrs)
;this loop reads in the selected months only
for yr=startyr,endyr do begin &$
  for i=0,nmos-1 do begin &$
  y = yr &$
  m = startmo + i &$
  if m gt 12 then begin &$
  m = m-12 &$
  y = y+1 &$
endif &$

fileID = ncdf_open(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_B_SA_M.A'',I4.4,I2.2,''.001.nc'')',y,m), /nowrite) &$
qsID = ncdf_varid(fileID,'SM01_Percentile') &$ ;
ncdf_varget,fileID, qsID, SMP &$
SMper[*,*,i,yr-startyr] = SMP &$

endfor &$
endfor
sm = smper
sm(where(sm lt 0))   = !values.f_nan ;CHIRPS MERRA
smper(where(smper lt 0))   = !values.f_nan ;CHIRPS MERRA

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

  shapefile = '/home/code/idl_user_contrib/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'
ncolors = 6
CLASS = [' > normal ', 'abnormally dry', 'moderate drought', 'severe drought', 'extreme drought', 'exceptional drought']
;1368X768
cnt=1
w = WINDOW(WINDOW_TITLE='SM percentile-drought classes',DIMENSIONS=[900,700])
YOI =2015
for mo=0,6 do begin &$
  ;for YOI = 1981,2013 do begin &$
  ;w = WINDOW(WINDOW_TITLE=string(YOI),DIMENSIONS=[700,700]) &$
  p1 = image(CONGRID(npc[*,*,mo,YOI-startyr]*samask,NX*1.8,NY*18),RGB_TABLE=65,FONT_SIZE=14, $
  ;p1 = image(CONGRID(SM01*SAMask,NX*1.8,NY*18),RGB_TABLE=72,FONT_SIZE=14, $
  AXIS_STYLE=0,MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], $
  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry], /current, layout = [4,3,cnt], margin=[0.1,0.1,0.1,0.1])  &$
  ;IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry], /current, margin=[0.1,0.1,0.1,0.1])  &$

  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [200,200,200] &$
  p1.rgb_table = rgbdump &$
  ;p1.title =string(YOI) &$
  p1.mapgrid.linestyle = 6 &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.FONT_SIZE = 0 &$
  p1.min_value=0 &$
  p1.max_value=5 &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black') &$
  ;cb = colorbar(target=p1,ORIENTATION=1,FONT_SIZE=14, POSITION=[0.14,0.3,0.16,0.6]) &$
  ;cb.tickvalues = [0,1,2,3,4,5]+0.5 &$
  ;  cb.tickname = CLASS &$
  ;  cb.minor=0 &$
  cnt++ &$
  ;p1.save,strcompress('/home/sandbox/people/mcnally/figs4kyle/EA_SMpercentile.Mar,Sep_'+string(YOI)+'_.jpg', /remove_all),RESOLUTION=200 &$
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
;zero out the months that have not happened yet
nseverity[*,*,415:419]=!values.f_nan
ndrought[*,*,415:419]=!values.f_nan
;Gabarone Drought Severity Index is currently in getSM_percentiles
;plot the drought severity in the gabarone Gabarrone Botswanna botswanna region...grepable
gmap_lry = -28
gmap_ulx = 21
gmap_uly = -21
gmap_lrx = 30

gmap_lry = -26
gmap_ulx = 23
gmap_uly = -21
gmap_lrx = 26

gulx = (gmap_ulx-map_ulx)/0.1  & glrx = (gmap_lrx-map_ulx)/0.1
guly = (gmap_uly-map_lry)/0.1   & glry = (gmap_lry-map_lry)/0.1


ROIanom = mean(mean(nseverity[gulx:glrx,glry:guly,0:419],dimension=1,/nan),dimension=1,/nan)
p1 = barplot(roianom)
p1.xrange=[0,419]
p1.xtickinterval=12
p1.xtickname=strmid(string(indgen(nyrs+1)+startyr),6,2)
p1.xminor=1

;write out drought severity so i can look in ENVI
ofile = '/home/sandbox/people/mcnally/DSI4ENVI_SA_486_443_420.bin'
openw,1,ofile
writeu,1,nseverity
close,1

ofile = '/home/sandbox/people/mcnally/SM_CNT4ENVI_SA_486_443_420.bin'
openw,1,ofile
writeu,1,ndrought
close,1





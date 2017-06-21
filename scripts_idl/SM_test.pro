;;; JUST A WORKSHEET TO FIDDLE AROUND WITH SM DATA FROM THE DIFFERENT MODEL OUTPUTS

mo_names = ['January','February','March','April','May','June', $
            'July','August','September','October','November','December']
mo_init = ['J','F','M','A','M','J','J','A','S','O','N','D']
startyr = 1982          ; this is the first year that all data is available
moi = 8


;;;; READIN NOAH NETCDF FILES AND GET SOIL MOISTURE FOR EAST AFRICA
data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_CHIRPSv2.001_MERRA2_EA/'
fnames = FILE_SEARCH(data_dir,STRING('FLDAS_NOAH01_C_EA_M.A????',moi,'.001.nc',f='(a,I2.2,a)')) 
nyrs = N_ELEMENTS(fnames)
;ncdf_list,fnames[0],/VARIABLES, /DIMENSIONS, /GATT, /VATT
fid = NCDF_OPEN(fnames[0],/NOWRITE)
NCDF_VARGET,fid,25,lon
NCDF_VARGET,fid,26,lat

NX = N_ELEMENTS(lon)    
NY = N_ELEMENTS(lat)
min_lon = MIN(lon)      & max_lon = MAX(lon)
min_lat = MIN(lat)      & max_lat = MAX(lat)
mlim = [min_lat,min_lon,max_lat,max_lon]
xsize = ABS(lon[1]-lon[0])
ysize = ABS(lat[1]-lat[0])

SM = FLTARR(NX,NY,NYRS)	; soil moisture
SMp = FLTARR(NX,NY,NYRS) ; soil moisture percentiles
for i=0,nyrs-1 do begin
   fid = NCDF_OPEN(fnames[i],/NOWRITE)
   SoilID = ncdf_varid(fid,'SoilMoi00_10cm_tavg')
;   SoilID = ncdf_varid(fid,'SoilMoi10_40cm_tavg')
;   SoilID = ncdf_varid(fid,'SoilMoi40_100cm_tavg')
;   SoilID = ncdf_varid(fid,'SoilMoi100_200cm_tavg')
   ncdf_varget,fid, SoilID, SM01
   SM[*,*,i] = SM01
   SoilpID = ncdf_varid(fid,'SM01_Percentile')
   NCDF_VARGET,fid,SoilpID,SMP01
   SMp[*,*,i] = SMP01
endfor


;;;; READIN VIC NETCDF FILES AND GET SOIL MOISTURE FOR EAST AFRICA
data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/VIC_CHIRPSv2.001_MERRA2_EA/'
fnames = FILE_SEARCH(data_dir,STRING('FLDAS_VIC025_C_EA_M.A????',moi,'.001.nc',f='(a,I2.2,a)'))
nyrs = N_ELEMENTS(fnames)
;ncdf_list,fnames[0],/VARIABLES, /DIMENSIONS, /GATT, /VATT
fid = NCDF_OPEN(fnames[0],/NOWRITE)
ncdf_varget,fid,24,lon
ncdf_varget,fid,25,lat

NX = N_ELEMENTS(lon)
NY = N_ELEMENTS(lat)
min_lon = MIN(lon)      & max_lon = MAX(lon)
min_lat = MIN(lat)      & max_lat = MAX(lat)
mlim = [min_lat,min_lon,max_lat,max_lon]
xsize = ABS(lon[1]-lon[0])
ysize = ABS(lat[1]-lat[0])

SM = FLTARR(NX,NY,NYRS) ; soil moisture
for i=0,nyrs-1 do begin
   fid = NCDF_OPEN(fnames[i],/NOWRITE)
;   SoilID = ncdf_varid(fid,'SoilMoi00_10cm_tavg')
   SoilID = ncdf_varid(fid,'SoilMoi10_160cm_tavg')
;   SoilID = ncdf_varid(fid,'SoilMoi160_190cm_tavg')
   ncdf_varget,fid, SoilID, SM01
   SM[*,*,i] = SM01
endfor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; ONLY ONE OF THE PREVIOUS TWO SECTIONS SHOULD BE RUN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

yoi = 2015	; year of interest
w = WINDOW(DIMENSIONS=[400,600])

tmpdata = (SM[*,*,yoi-startyr] - MEAN(SM,DIMENSION=3)) / STDDEV(SM,DIMENSION=3)
ncolors = 13
index = [MIN(tmpdata,/NAN), -2.0, -1.5, -1.25, -1.0, -0.75, -0.5, $
         0.5, 0.75, 1.0, 1.25, 1.5, 2.0, MAX(tmpdata,/NAN)]
m1 = MAP('Geographic',LIMIT=mlim,/CURRENT)
tmpgr = CONTOUR(tmpdata, $
   FINDGEN(NX)*(xsize) + min_lon, FINDGEN(NY)*(ysize) + min_lat, $
   RGB_TABLE=70, /FILL, ASPECT_RATIO=1, BACKGROUND_COLOR='light gray', $
   C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./(ncolors-1)), $
   MAP_PROJECTION='Geographic', XSTYLE=1, YSTYLE=1, /OVERPLOT)
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
tmpgr.title = STRING('Standardized 10-40cm Soil Moisture Anomaly !C',mo_names[moi-1],' ',yoi,f='(a,a,a,I4.4)')
cb = COLORBAR(TARGET=tmpgr, POSITION=[0.05,0.06,0.95,0.08],TITLE='Z-Score',FONT_SIZE=11,/BORDER)
mc = MAPCONTINENTS(/COUNTRIES,COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=mlim)


;; PICK A POINT AND LOOK AT THE HISTORICAL DISTRIBUTION
x = 175
y = 185
print,'selected point = '+STRING(lon[x])+', '+STRING(lat[y])

h = HISTOGRAM(SM[x,y,*],MIN=MIN(SM[x,y,*]),MAX=MAX(SM[x,y,*]),NBINS=12,LOCATIONS=hlocs)
tmpplt = BARPLOT(hlocs,h)

tmpgr = PLOT(SM[x,y,*],SMp[x,y,*],'ob')


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; SOME STATS STUFF WITH MULTI-MONTH ACCUMULATIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; JUST A WORKSHEET TO FIDDLE AROUND WITH SM DATA FROM THE DIFFERENT MODEL OUTPUTS

mo_names = ['January','February','March','April','May','June', $
            'July','August','September','October','November','December']
mo_init = ['J','F','M','A','M','J','J','A','S','O','N','D']
startyr = 1982          ; this is the first year that all data is available
startmo = 10
endmo = 12
if startmo le endmo then nmos = endmo - startmo +1  $
   else nmos = endmo - startmo +13

; set some parameters for read-in and mapping
data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_CHIRPSv2.001_MERRA2_EA/'
fname = data_dir+STRING('FLDAS_NOAH01_C_EA_M.A',startyr,startmo,'.001.nc',f='(a,I4.4,I2.2,a)')
fid = NCDF_OPEN(fname,/NOWRITE)
NCDF_VARGET,fid,25,lon
NCDF_VARGET,fid,26,lat

NX = N_ELEMENTS(lon)
NY = N_ELEMENTS(lat)
min_lon = MIN(lon)      & max_lon = MAX(lon)
min_lat = MIN(lat)      & max_lat = MAX(lat)
map_lim = [min_lat,min_lon,max_lat,max_lon]
xsize = ABS(lon[1]-lon[0])
ysize = ABS(lat[1]-lat[0])


;;;; READIN NOAH NETCDF FILES AND GET SOIL MOISTURE FOR EAST AFRICA

for i=0,nmos-1 do begin 
   moi = startmo +i
   if moi gt 12 then moi = moi -12
   data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_CHIRPSv2.001_MERRA2_EA/'
   fnames = FILE_SEARCH(data_dir,STRING('FLDAS_NOAH01_C_EA_M.A????',moi,'.001.nc',f='(a,I2.2,a)'))
   nyrs = N_ELEMENTS(fnames)
   ;ncdf_list,fnames[0],/VARIABLES, /DIMENSIONS, /GATT, /VATT
   fid = NCDF_OPEN(fnames[0],/NOWRITE)

   SM = FLTARR(NX,NY,NYRS) ; soil moisture
   for j=0,nyrs-1 do begin
      fid = NCDF_OPEN(fnames[j],/NOWRITE)
      SoilID = ncdf_varid(fid,'SoilMoi00_10cm_tavg')
   ;   SoilID = ncdf_varid(fid,'SoilMoi10_40cm_tavg')
   ;   SoilID = ncdf_varid(fid,'SoilMoi40_100cm_tavg')
   ;   SoilID = ncdf_varid(fid,'SoilMoi100_200cm_tavg')
      ncdf_varget,fid, SoilID, SM01
      SM[*,*,j] = SM01
   endfor
   if i eq 0 then SMtot = SM $
      else SMtot = SMtot + SM
endfor
SMtot = SMtot / nmos	; convert to average monthly SM
nyrs = N_ELEMENTS(SMtot[0,0,*])

n_neg = TOTAL(SMtot lt 0.0000,3)
glocs = WHERE(n_neg eq 0)
gind = ARRAY_INDICES([NX,NY],glocs,/DIMENSIONS)

SMtot[WHERE(SMtot lt 0.0000)] = !VALUES.F_NAN

;; get the ranks of the seasonal sums
.compile Get_Ranks.pro
RankTime = TIC('Time to calculate ranks')
ssnrnk = FLTARR(SIZE(SMtot,/DIMENSIONS)) - 1.
for i=0,N_ELEMENTS(glocs)-1 do $
  ssnrnk[gind[0,i],gind[1,i],*] = GET_RANKS(SMtot[gind[0,i],gind[1,i],*])
TOC, RankTime


;;; Make some graphics of the data
w = WINDOW(DIMENSIONS=[900,900])

ncolors = 8
index = [-1.5, -0.5, 1.5, 2.5, 3.5, nyrs-2.5, nyrs-1.5, nyrs-0.5, nyrs+0.5] 
col_names = ['light gray','sienna','orange red','orange','white','aqua','dodger blue','dark blue']
m1 = MAP('Geographic',LIMIT=map_lim,/CURRENT)
tmpgr = CONTOUR(ssnrnk[*,*,-1],FINDGEN(NX)/10. + min_lon, FINDGEN(NY)/10. + min_lat,$
   /FILL, ASPECT_RATIO=1, C_VALUE=index, C_COLOR=col_names,  $
   MAP_PROJECTION='Geographic', XSTYLE=1, YSTYLE=1, /OVERPLOT)
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
tmpgr.mapgrid.FONT_SIZE = 10
;grtitle = TEXT(0.5,0.9,STRING(FORMAT='(''October to Present Rainfall Rank'',I4.4)',year), ALIGNMENT=0.5,FONT_SIZE=16)
grtitle = TEXT(0.5,0.955,'Soil Moisture Rank '+STRING(startyr+nyrs-1,f='(I4.4)'), ALIGNMENT=0.5,FONT_SIZE=16)
mc = MAPCONTINENTS(/COUNTRIES, COLOR=[70,70,70],FILL_BACKGROUND=0,THICK=2,LIMIT=map_lim )
cb = colorbar(RGB_TABLE=col_names[*,1:-1],ORIENTATION=1,/BORDER,POSITION=[0.92,0.15,0.96,0.85],TAPER=0, $
   TEXT_ORIENTATION=90,FONT_SIZE=10)
cb.TICKVALUES = FINDGEN(N_ELEMENTS(col_names[0,1:-1])) + 0.5
cb.TICKNAME = ['Driest','Second Driest','Third Driest',' ','Third Wettest','Second Wettest','Wettest']

tmpdat = (SMtot[*,*,-1] - MEAN(SMtot,DIMENSION=3)) / STDDEV(SMtot,DIMENSION=3)
; now map tmpdat
tmpgr.erase
ncolors = 13
index = [MIN(tmpdat[*,*,-1],/NAN), -2.0, -1.5, -1.25, -1.0, -0.75, -0.5, $
         0.5, 0.75, 1.0, 1.25, 1.5, 2.0, MAX(tmpdat[*,*,-1],/NAN)]
m1 = MAP('Geographic',LIMIT=map_lim,/CURRENT)
tmpgr = CONTOUR(tmpdat,FINDGEN(NX)/10. + min_lon, FINDGEN(NY)/10. + min_lat,$
   RGB_TABLE=make_cmap(256), /FILL, ASPECT_RATIO=1, BACKGROUND_COLOR='light gray', $
   C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./(ncolors-1)), $
   MAP_PROJECTION='Geographic', XSTYLE=1, YSTYLE=1, /OVERPLOT)
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
tmpgr.mapgrid.FONT_SIZE = 10
grtitle = TEXT(0.5,0.955,'Normalized Soil Moisture',ALIGNMENT=0.5,FONT_SIZE=16)
mc = MAPCONTINENTS(/COUNTRIES, COLOR=[70,70,70],FILL_BACKGROUND=0,THICK=2,LIMIT=map_lim )
cb = colorbar(target=tmpgr,ORIENTATION=1,/BORDER,POSITION=[0.96,0.25,0.98,0.7])
;tmpgr.save,STRING('/home/ftp_out/people/husak/CurSSN/SPI_',dekstr[startdek-1],'Thru',dekstr[enddek-1],'.png',f='(a,a,a,a,a)'), $
;   RESOLUTION=100

ncolors = 8
index = [-1.5, -0.5, 2.5, 6.5, 10.5, nyrs-2.5, nyrs-1.5, nyrs-0.5, nyrs+0.5]
col_names = ['light gray','sienna','orange red','orange','white','aqua','dodger blue','dark blue']
m1 = MAP('Geographic',LIMIT=map_lim,/CURRENT)
tmpgr = CONTOUR(ssnrnk[*,*,-1],FINDGEN(NX)/10. + min_lon, FINDGEN(NY)/10. + min_lat,$
   /FILL, ASPECT_RATIO=1, C_VALUE=index, C_COLOR=col_names,  $
   MAP_PROJECTION='Geographic', XSTYLE=1, YSTYLE=1, /OVERPLOT)
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
tmpgr.mapgrid.FONT_SIZE = 10
;grtitle = TEXT(0.5,0.9,STRING(FORMAT='(''October to Present Rainfall Rank'',I4.4)',year), ALIGNMENT=0.5,FONT_SIZE=16)
grtitle = TEXT(0.5,0.955,'Soil Moisture Rank '+STRING(startyr+nyrs-1,f='(I4.4)'), ALIGNMENT=0.5,FONT_SIZE=16)
mc = MAPCONTINENTS(/COUNTRIES, COLOR=[70,70,70],FILL_BACKGROUND=0,THICK=2,LIMIT=map_lim )
cb = colorbar(RGB_TABLE=col_names[*,1:-1],ORIENTATION=1,/BORDER,POSITION=[0.92,0.15,0.96,0.85],TAPER=0, $
   TEXT_ORIENTATION=90,FONT_SIZE=10)
cb.TICKVALUES = FINDGEN(N_ELEMENTS(col_names[0,1:-1])) + 0.5
cb.TICKNAME = ['1-2','3-6','7-10',' ','Third Wettest','Second Wettest','Wettest']


;;; HISTOGRAM FOR A GIVEN LOCATION
x = 225
y = 185
print,'selected point = '+STRING(lon[x])+', '+STRING(lat[y])

h = HISTOGRAM(SMtot[x,y,*],MIN=MIN(SMtot[x,y,*]),MAX=MAX(SMtot[x,y,*]),NBINS=12,LOCATIONS=hlocs)
tmpplt = BARPLOT(hlocs,h,TITLE=STRING('Long: ',lon[x],' Lat: ',lat[y],f='(a,F6.2,a,F6.2)'))
tmpmn = MEAN(SMtot[x,y,*])	& tmpstd = STDDEV(SMtot[x,y,*])
tmpline = POLYLINE([tmpmn,tmpmn],[MIN(tmpplt.YRANGE),MAX(tmpplt.YRANGE)],':2',/DATA)
tmpline = [tmpline, POLYLINE([tmpmn-tmpstd,tmpmn-tmpstd],[MIN(tmpplt.YRANGE),MAX(tmpplt.YRANGE)],'r:2',/DATA)]
tmpline = [tmpline, POLYLINE([tmpmn+tmpstd,tmpmn+tmpstd],[MIN(tmpplt.YRANGE),MAX(tmpplt.YRANGE)],'r:2',/DATA)]




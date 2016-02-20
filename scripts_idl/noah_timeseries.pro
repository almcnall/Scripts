;read in these data and look at the time series over the WRSI MAM/OND mask
;i could also pull a time series at molly's points.
;
; this is uncomformtable but i'll get over it. new stuff always is.
;do the same thing with the GDAS data
data_dir = '/home/sandbox/people/mcnally/NOAH_CHIRP_MERRA/SM01_YRMO/'
data_dirG = '/home/sandbox/people/mcnally/NOAH_CHIRP_GDAS/SM01_YRMO/'


startyr = 2001
endyr = 2013
nyrs = endyr-startyr+1

startmo = 9
endmo = 11
nmos = endmo - startmo+1
cnt=0
stack = fltarr(294,348,nyrs*nmos)*!values.f_nan

SM = FLTARR(294,348,nyrs)
SMg = FLTARR(294,348,nyrs)

for yr=startyr,endyr do begin &$
  for i=0,nmos-1 do begin &$
  y = yr &$
  m = startmo + i &$
  if m gt 12 then begin &$
    m = m-12 &$
    y = y+1 &$
  endif &$
  fileID = ncdf_open(data_dir+STRING(FORMAT='(''SM01_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
  SoilID = ncdf_varid(fileID,'SoilMoist_tavg') &$
  ncdf_varget,fileID, SoilID, SM01 &$
  SM[*,*,yr-startyr] =  SM[*,*,yr-startyr] +SM01 &$
  
  fileID = ncdf_open(data_dirG+STRING(FORMAT='(''SM01_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
  SoilID = ncdf_varid(fileID,'SoilMoist_tavg') &$
  ncdf_varget,fileID, SoilID, SM01g &$
  SMg[*,*,yr-startyr] =  SMg[*,*,yr-startyr] +SM01g &$
  
  ;stack[*,*,cnt] = SM01 &$
  ;cnt++ &$
  endfor  &$
endfor
stack(where(stack lt -999.0))=!values.f_nan
sm(where(sm le 0))=!values.f_nan
smg(where(smg le 0))=!values.f_nan


;read in the longrain/short rain mask:
ifile = file_search('/home/sandbox/people/mcnally/lis_input_wrsi.ea_oct2feb.nc') & print, ifile
fileID = ncdf_open(ifile, /nowrite) &$
  maskID = ncdf_varid(fileID,'WRSIMASK')
ncdf_varget,fileID, maskID, shortmask

;compute anomaly for the OND
;ondclim = rebin(mean(sm,dimension=3,/nan),294,348,nyrs)& help, ondclim
;ondanom = (sm-ondclim)*rebin(shortmask,294,348,nyrs)
;
;compute the anomaly for MAM
mamclim = rebin(mean(sm,dimension=3,/nan),294,348,nyrs)& help, mamclim
mamanom = (sm-mamclim)*rebin(shortmask,294,348,nyrs)

mamclimg = rebin(mean(smg,dimension=3,/nan),294,348,nyrs)& help, mamclim
mamanomg = (smg-mamclimg)*rebin(shortmask,294,348,nyrs)



;compute the anomaly for the MAM Belg mask (mar2sept)
;read in the belg rain mask:
ifile = file_search('/home/sandbox/people/mcnally/lis_input_wrsi.ea_mar2sep.nc') & print, ifile
fileID = ncdf_open(ifile, /nowrite) &$
maskID = ncdf_varid(fileID,'WRSIMASK')
ncdf_varget,fileID, maskID, belgmask

mamclim = rebin(mean(sm,dimension=3,/nan),294,348,nyrs)& help, mamclim ;same as above
belanom = (sm-mamclim)*rebin(belgmask,294,348,nyrs)

mamclimg = rebin(mean(smg,dimension=3,/nan),294,348,nyrs)& help, mamclim ;same as above
belanomg = (smg-mamclimg)*rebin(belgmask,294,348,nyrs)

cormap = fltarr(nx,ny)
for x = 0,NX-1 do begin &$
  for y =0, NY-1 do begin &$
  cormap[x,y] = correlate(smg[x,y,*], sm[x,y,*]) &$
endfor &$
endfor


;East Africa WRSI/Noah window
ea_ulx = 22.  & ea_lrx = 51.35
ea_uly = 22.95  & ea_lry = -11.75

NX=294
NY=348

ncolors = 20
w = WINDOW(WINDOW_TITLE='Plotting Stuff',DIMENSIONS=[700,900])

p1 = image(congrid(cormap*shortmask, NX*3, NY*3), image_dimensions=[nx/10,ny/10],image_location=[ea_ulx+0.45,ea_lry+0.5],RGB_TABLE=20,/current)  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.title = 'GDAS+CHIRPS, GDAS+RFE correlation 2001-2013 OND short sm01' &$
  p1.max_value=1
p1.min_value=0.5
c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,font_size=18) &$
  m1 = MAP('Geographic',limit=[ea_lry,ea_ulx+5,ea_uly-10,ea_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  m1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0, 0, 0], THICK = 2)


p1=barplot(mean(mean(belanom,dimension=1,/nan),dimension=1,/nan))
p1.xrange=[0,nyrs-1]
p1.xtickname=string(indgen(nyrs)+startyr)
p1.xminor=0

merraTS = (mean(mean(belanom,dimension=1,/nan),dimension=1,/nan))
GDASTS = (mean(mean(belanom,dimension=1,/nan),dimension=1,/nan))
merra81TS = (mean(mean(belanom,dimension=1,/nan),dimension=1,/nan))
;compute the anomaly for each month in the TS this ended in April 2014
monclim = mean(reform(stack,294,348,nmos,nyrs),dimension=4,/nan)
mon = reform(rebin(monclim,294,348,12,nyrs),294,348,nmos*nyrs) & help, mon

;averge these for the WRSI MAM mask, get that from the lis.input_file
;this is still a very large mask considering that we know that there is subregional variability
;maybe that is a question re: the scale of droughts that are detected


mask = rebin(shortmask,294,348,n_elements(stack[0,0,*])) & help, mask
eashort = (stack-mon)*mask

p1=plot(mean(mean(eashort,dimension=1,/nan),dimension=1,/nan))
p1.xtickinterval=12
p1.xminor=0
p1.xtickname=string(indgen(nyrs)+startyr)
zeroline = POLYLINE(p1.XRANGE,[400.0,400.0],'--',COLOR='Gray',TARGET=p1,/DATA)


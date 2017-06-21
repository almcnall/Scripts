pro ethiopia_site_SM
;the purpose of this script is to compare the GDAS+CHIRPS and MERRA+CHIRPS SM outputs from Noah
;to the locations in the Ethiopia spreadsheet...I plotted thoes two datasets for yemen in 
;if I want to comapre ET checkout yemen_ET_compare
;for now just keep EA soil moisture
;;now for the soil moisture...compare GDAS/CHIRPS, GDAS/RFE (old!) and MERRA

startyr = 2001
endyr = 2010
nyrs = endyr-startyr+1

;March-June is fine for EA but should use March-Sept for Yemen.
startmo = 3
endmo = 10
nmos = endmo - startmo+1

;East Africa WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

ulx = (180.+map_ulx)*10.  & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10.   & lry = (50.-map_lry)*10.-1
NX = lrx - ulx + 1.5
NY = lry - uly + 2

data_dirR = '/home/chg-mcnally/fromKnot/EXP01/monthly/' ;
data_dirG = '/home/sandbox/people/mcnally/NOAH_CHIRP_GDAS/SM01_YRMO/'
data_dir = '/home/sandbox/people/mcnally/NOAH_CHIRP_MERRA/SM01_YRMO/'
data_dirE = '/home/chg-mcnally/ECV_soil_moisture/monthly/horn/' ;maybe too many holes in these data. maybe ok for TS though

SM = FLTARR(NX,NY,nyrs)
SMG = FLTARR(NX,NY,nyrs)
SM01R = fltarr(720,250)
SMR = FLTARR(720,250,nyrs)
ECV = FLTARR(285, 339,12, nyrs)
;this loop reads in the selected months only
for yr=startyr,endyr do begin &$
  for i=0,nmos-1 do begin &$
  y = yr &$
  m = startmo + i &$
  if m gt 12 then begin &$
  m = m-12 &$
  y = y+1 &$
endif &$
;ugh, shouldn't these be cumulative??! like the rainfall?
fileID = ncdf_open(data_dir+STRING(FORMAT='(''SM01_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
SoilID = ncdf_varid(fileID,'SoilMoist_tavg') &$
ncdf_varget,fileID, SoilID, SM01 &$
SM[*,*,yr-startyr] =  SM[*,*,yr-startyr] +SM01 &$

fileID = ncdf_open(data_dirG+STRING(FORMAT='(''SM01_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
SoilID = ncdf_varid(fileID,'SoilMoist_tavg') &$
ncdf_varget,fileID, SoilID, SM01G &$
;generates the seasonal total for months of interest it is a percent...
SMG[*,*,yr-startyr] =  SMG[*,*,yr-startyr] +SM01G &$

ifile = file_search(data_dirR+STRING(FORMAT='(''Sm01_'',I4.4,I2.2,''.img'')',y,m)) &$
openr,1,ifile &$
readu,1,SM01R &$
close,1 &$
;generates the seasonal total for months of interest it is a percent...
SMR[*,*,yr-startyr] = SMR[*,*,yr-startyr] + SM01R/100 &$

ifile = file_search(data_dirE+STRING(FORMAT='(''ECV_SM_'',I4.4,I2.2,''.tif'')',y,m)) &$
MW01 = read_tiff(ifile) &$
;ECV[*,*,yr-startyr] = ECV[*,*,yr-startyr] + MW01/10000 &$ ;this doesn't work, too many holes in data
ECV[*,*,i,yr-startyr] = MW01/10000.&$

endfor &$
endfor
;these are the east africa window from MERRA/GDAS runs
sm(where(sm lt 0)) = !values.f_nan
smg(where(smg lt 0)) = !values.f_nan
;sahel window from RFE runs
smr(where(smr lt 0)) = !values.f_nan

;;;resize this ECV data and pad out;;;;;;;
ECV01 = total(ECV[*,*,startmo-1:endmo-1,*],3,/nan)
left = rebin(fltarr(10,339)*!values.f_nan,10,339,nyrs)
ECVsm =[ left,ecv01 ] & help, ecvsm
;my old sahel window?
map_ulx = -20.  & map_lrx = 52.
map_uly = 20.  & map_lry = -5


;East Africa WRSI/Noah window
ea_ulx = 22.  & ea_lrx = 51.35
ea_uly = 22.95  & ea_lry = -11.75

;;;;;;;;;Resize RFE-sahel to east africa window;;;;;;;;
ulx = (ea_ulx-map_ulx)*10.  & lrx = (ea_lrx-map_ulx)*10.
;lry = (map_lry-ea_lry)*10.   & uly = (map_uly-ea_lry)*10.
bot  = (abs(ea_lry-map_lry)*10)+1 & top = ((ea_uly-map_uly)*10)+1
bot_pad = rebin(fltarr(nx, bot)*!values.f_nan,nx,bot,nyrs)
top_pad = rebin(fltarr(nx, top)*!values.f_nan,nx,top,nyrs)


eaSMr0 = smr[ulx:lrx, *,*]
eaSMr= [ [[bot_pad],[eaSMr0]] , [top_pad]] & help, eaSMr

;bad1ethcal,bad2ethcal,bad3ethcal,bad4ethcal,bad5ethcal
;ok how how to pull the time series for the points of interest 47 had worst yr 2001-2010
sta = read_csv('/home/mcnally/Ethiopia_sitetable_AMEdit.csv', header=1)
lat = sta.field02
lon = sta.field03
bad1 = transpose(sta.(9)+7)
bad2 = transpose(sta.(10)+7)
bad3 = transpose(sta.(11)+7)
bad4 =transpose( sta.(12)+7)
bad5 = transpose(sta.(13)+7)
array = [bad1,bad2,bad3,bad4,bad5]

a = indgen(19)+1996
mat = intarr(19,85)*6
for j = 0,n_elements(array[0,*])-1 do begin &$
  for i = 0,19-1 do begin &$
    mat[i,j]= where(a[i] eq array[*,j]) &$
  endfor 
fill = indgen(19-5)+6  
mat(where(mat eq -1)) = mean(fill)
a = correlate(transpose(mat))
list= array_indices(a,where(a eq 1))
;try pca on matrix of ranks
PCA, mat
fd = PCOMP(mat, EIGENVALUES=evalues, COEFFICIENTS=evectors, /DOUBLE)


list2=list
for i=0,n_elements(list[0,*])-1 do begin &$
  if list2[0,i] ne list2[1,i] then print, list2[*,i] &$
end
;make a histogram of the rpaw data
pdf = HISTOGRAM(list2[0,*], binsize=1, locations=xbin)
p1 = barplot(xbin,pdf)

pdf = HISTOGRAM([bad1,bad2], binsize=1, locations=xbin)
p2 = barplot(xbin,pdf, layout=[1,5,2],/current)

pdf = HISTOGRAM([bad1,bad2,bad3], binsize=1, locations=xbin)
p3 = barplot(xbin,pdf, layout=[1,5,3],/current)

pdf = HISTOGRAM([bad1,bad2,bad3,bad4], binsize=1, locations=xbin)
p4 = barplot(xbin,pdf, layout=[1,5,4],/current)

pdf = HISTOGRAM([bad1,bad2,bad3,bad4,bad5], binsize=1, locations=xbin)
p5 = barplot(xbin,pdf, layout=[1,5,5],/current)
;p1.xtickname=indgen(16)+1997

;x is longitude, y is latitude!

;ecv,CM,CG,RG
staANOM = fltarr(4,nyrs,n_elements(lat))
for s = 0,n_elements(lat)-1 do begin &$
  x = floor((lon[s]-ea_ulx)/0.10) & print, x &$
  y = floor((lat[s]-ea_lry)/0.10) & print, y &$
  staanom[0,*,s] = ecvsm[x,y,*]-mean(ecvsm[x,y,*],/nan) &$
  staanom[1,*,s] = sm[x,y,*]-mean(sm[x,y,*],/nan) &$
  staanom[2,*,s] = smg[x,y,*]-mean(smg[x,y,*],/nan) &$
  staanom[3,*,s] = easmr[x,y,*]-mean(easmr[x,y,*],/nan) &$
endfor

;list the corerlation between CM-CG, CG-RG, RG-CM
;col 1 is importance of FORCE, col2 is sim between CHIRP-RFE, col3 is insensitive
;;ahg, there is a logic puzzle here, what is it? this is what ratio indices are for :)
;i could map the ratio of indices for a sensitivity map.
;the station are really only good for checking agreement w/ people. 
;this ration index 
;ratio of 2:3 would be importance of foring v rain (if col2>col3 then FORCE is more similar, if col2<col3 then rain is more sim)
corlist = fltarr(3,n_elements(lat))
for d =0,3 do begin 
  for s = 0,n_elements(lat)-1 do begin &$
    m = correlate(staanom[1:3,*,s]) &$
    corlist[*,s] =[ m[1],m[2],m[5] ] &$
  endfor
  

for s = 20,n_elements(lat)-20 do begin &$
  x = floor((lon[s]-ea_ulx)/0.10) & print, x &$
  y = floor((lat[s]-ea_lry)/0.10) & print, y &$

  w = window() &$
  p1=plot(ecvsm[x,y,*]-mean(ecvsm[x,y,*],/nan),'orange', name='ecv') &$
  p2=plot(sm[x,y,*]-mean(sm[x,y,*],/nan),'r', name='CHIRP+MERRA',/overplot) &$
  p3=plot(smg[x,y,*]-mean(smg[x,y,*],/nan),'b', name='CHIRP+GDAS',/overplot) &$
  p4=plot(easmr[x,y,*]-mean(easmr[x,y,*],/nan),'c', name='RFE+GDAS',/overplot) &$
  onelinex = POLYLINE(p1.XRANGE,[0,0],'--',COLOR='Gray',TARGET=p1,/DATA) &$
  p1.xrange=[0,9] &$
  !null = legend(target=[p1,p2,p3,p4],  position=[1,1,0,0]) &$
  xticks = indgen(10)+2001 & print, xticks &$
  p1.xTICKNAME = string(xticks) &$
  p1.xminor = 1 &$
  p1.yminor = 0 &$
  p1.yrange=[-0.5,0.5] &$
  p1.title=string(sta.field01[s])+string([[sta.field11[s],sta.field12[s]+7,sta.field13[s]+7]]) &$
endfor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

smg(where(smg lt 0)) = !values.f_nan
dims = size(SM01g, /dimensions)

dims = size(SM, /dimensions)

NX = dims[0]
NY = dims[1]

corCMCG = fltarr(nx,ny,2)
for x = 0,NX-1 do begin &$
  for y =0, NY-1 do begin &$
  ;corCMCG[x,y] = correlate(smg[x,y,*], sm[x,y,*]) &$
  corCMCG[x,y,*] = r_correlate(smg[x,y,*], easmr[x,y,*]) &$

endfor &$
endfor

;Africa mean annual SM figure
;i should be using the appropriate mask...but it doesn't totally make sense why correlation is so poor to the east.
ncolors=20
;p1 = image(congrid(mean(SMg, dimension=3, /NAN), NX*3, NY*3), image_dimensions=[nx/10,ny/10],image_location=[ea_ulx,ea_lry],RGB_TABLE=64)  &$
p1 = image(congrid(corCMCG[*,*,0], NX*3, NY*3), image_dimensions=[nx/10,ny/10],image_location=[ea_ulx+0.25,ea_lry+0.5],RGB_TABLE=20)  &$
  
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.title = 'GDAS+CHIRPS, GDAS+RFE r_correlation 2001-2011 mar-oct sm01' &$
  p1.max_value=1
p1.min_value=0
c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,font_size=18) &$
  m1 = MAP('Geographic',limit=[ea_lry,ea_ulx,ea_uly,ea_lrx], /overplot) &$
  ;m1 = MAP('Geographic',LIMIT = [hmap_lry,hmap_ulx,hmap_uly ,hmap_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  m1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0, 0, 0], THICK = 2)
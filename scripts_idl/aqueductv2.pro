;this script is to calculate the aquestat indices
;baseline water stress = available flow/withdrawals....
;12/12/14 revisit for AGU, 02/10/14 sahel baseline water stress esp 2012, 04/17/2015 try to compute monthly blue water availability
;04/27/2015 compute monthly BLWS for Southern Africa. 
;09/03/2015 revisit for more routine monthly BLWS.this index is good for highlighting where population centers are, 
; try overlay with with the drought serverity index for a better index. 
;9/23/15 working out units with ian
;10/8/15 compute water availability indices for Ethiopia regions of interest. 
;10/26/15 water avail maps as in Schol green water flow (ET), green water storge(SM), bluewater(runoff+deep aquifer)
; I could use one of the groundwater maps from the British geological survey, maybe just add these later.
; more info on groundwater use and supply here 
; http://www.iwmi.cgiar.org/Publications/Books/PDF/groundwater_availability_and_use_in_sub-saharan_africa_a_review_of_15_countries.pdf
; not sure how many layers of SM i should look at...blegh, maybe skip "green water"
;10/28/15  ok, computer monthly water avail 1981-2014 in prep for new SRI weighted by population 
;11/9/15 verdin really wants monthly falkenmark - first show all months, then try composite.
;11/11/15 finally making contour maps and time series plots of avg H20avil
;11/15/15 fixing them up to be presentable
;11/24/15 request for Ethiopia zoom on water avail plots (and I want SRI-12)
;12/7/15 

startyr = 1982 ;start with 1982 since no data in 1981
endyr = 2015
nyrs = endyr-startyr+1

;re-do for all months
startmo = 1
endmo = 12
nmos = endmo - startmo+1

;West Africa (5.35 N - 17.65 N; 18.65 W - 25.85 E)
; west africa domain
;map_ulx = -18.65 & map_lrx = 25.85
;map_uly = 17.65 & map_lry = 5.35

;East Africa WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

;Southern Africa WRSI/Noah window
;Southern Africa (37.85 S - 6.35 N; 6.05 E - 54.55 E) 
;NX = 486, NY = 443
;map_ulx = 6.05  & map_lrx = 54.55
;map_uly = 6.35  & map_lry = -37.85

ulx = (180.+map_ulx)*10.  & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10.   & lry = (50.-map_lry)*10.-1
NX = lrx - ulx + 2 
NY = lry - uly + 2


;data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_CHIRPSv2.001_MERRA_SA/';FLDAS_NOAH01_B_SA_M.A201507.001.nc
;data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_CHIRPSv2.001_MERRA_WA/';FLDAS_NOAH01_B_SA_M.A201507.001.nc
data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_CHIRPSv2.001_MERRA_EA/';FLDAS_NOAH01_B_SA_M.A201507.001.nc

Qsub = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
Qsuf = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan

;this loop reads in the selected months only
for yr=startyr,endyr do begin &$
  for i=0,nmos-1 do begin &$
  y = yr &$
  m = startmo + i &$
  if m gt 12 then begin &$
    m = m-12 &$
    y = y+1 &$
  endif &$
  fileID = ncdf_open(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_B_EA_M.A'',I4.4,I2.2,''.001.nc'')',y,m), /nowrite) &$
  
  qsID = ncdf_varid(fileID,'Qs_tavg') &$
  ncdf_varget,fileID, qsID, Qs &$
  Qsuf[*,*,i,yr-startyr] = Qs &$
 
  qsID = ncdf_varid(fileID,'Qsb_tavg') &$ ;Rainf_tavg
  ncdf_varget,fileID, qsID, Qsb &$
  Qsub[*,*,i,yr-startyr] = Qsb &$
  
  NCDF_close, fileID &$
  endfor &$ 
endfor
Qsuf(where(Qsuf lt 0)) = 0
Qsub(where(Qsub lt 0)) = 0


RO = Qsuf+Qsub
ROmm  = RO*86400*30 ;YES

;;;;Plot population;;;;;;;
indir = '/home/sandbox/people/mcnally/Africa-POP/'
;POP = read_tiff(indir+'EAfrica_POP_10km.tiff'); /home/sandbox/people/mcnally/Africa-POP/EAfricaYEM_POP_10km.tiff
POP = read_tiff(indir+'EAfricaYEM_POP_10km.tiff')

;POP = read_tiff(indir+'SAfrica_POP_10km.tiff')
;POP = read_tiff(indir+'WAfrica_POP_10km.tiff')

popmask = pop*!values.f_nan
rural = where(pop le 1, complement = urban)
popmask(urban)=1

;add the landmask to the pop mask
ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input_ea_elev.nc')
fileID = ncdf_open(ifile) 
qsID = ncdf_varid(fileID,'LANDMASK') 
ncdf_varget,fileID, qsID, landmask 
landmask(where(landmask eq 0))=!values.f_nan

temp =image(popmask*landmask, min_value=0)

popmask=popmask*landmask

;;compute m3 per capita per month
;initialize variables
;what is the population?
pop12 = rebin(pop,NX,NY,nmos) & help, pop12
popcube  = rebin(pop,NX,NY,nmos,nyrs) & help, popcube

;how much runoff is there every month?
help, ROmm
;how much RO per person per month? I guess multiplying by 1000 gets us from mm to m3?
CMPPcube = (ROmm/popcube)*1000      & help, CMPPcube
;what is the average per person per month (show 12 months)

;take the ratio of the observed CMPP to the average CMPP, 
monRO = mean(ROmm,dimension=4,/nan) & help, monRO
monCMPP  = (monRO/pop12)*1000      & help, monCMPP

month = ['jan', 'feb', 'mar','apr','may','jun','jul','aug','sep','oct','nov','dec']
CLASS = ['absolute scarcity ', 'scarcity', 'stress', 'no stress']

;;;;;; THIS is a pretty good map of water scarcity by month;;;;;;;
;FIGURE 1. Shows average monthly per capita water availability in East Africa 
;  ncolors=4
;  ;i=0
;  w = WINDOW(DIMENSIONS=[700,900]) &$
; for i = 10,11 do begin &$
;  p1 = image(congrid(monCMPP[*,*,i]*popmask, NX*3, NY*3), image_dimensions=[NX/10,NY/10],  $
;  image_location=[map_ulx,map_lry],RGB_TABLE=72, MARGIN=[0.01, 0.01, 0.01, 0.1],layout = [4,3,i+1], /current )  &$ ;left, botton, right, top
;  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
;  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
;  rgbdump[*,0] = [190,190,190] &$
; 
;  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
;  p1.title = string(month[i]) &$
;  p1.MAX_VALUE=160 &$
;  m1 = MAP('Geographic',limit=[map_lry+10,map_ulx+10,map_uly,map_lrx], /overplot) &$
;  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
;  m1.mapgrid.color = [150, 150, 150] &$
;  m1.mapgrid.font_size = 0 &$
;  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
;  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2) &$
;endfor 
; cb = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,font_size=12)
;  cb.tickvalues = [0,20,60,100,140]+10 &$
;  cb.tickname = CLASS &$
;  cb.minor=0
;  cb.TEXT_ORIENTATION=15
; shapefile = '/home/code/idl_user_contrib/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'

;include zoom into Ethiopia, not as easy with contour as image...
EthCMPP = moncmpp[100:NX-1,150:NY-1,*] & help, EthCMPP
EthPOP = popmask[100:NX-1,150:NY-1] & help, EthPOP
dims = size(EthCMPP, /dimension)
eNX = dims[0]
eNY = dims[1]

  ncolors = 4
  RGB_INDICES=[0,41,82,142]
  index = [0,41,82,142];[0,20,60,100,140];  C_VALUE=index,,max_value=200,min_value=0, 
  ;make these match with falkenmark
w = WINDOW(DIMENSIONS=[900,700])
ct=colortable(25,/reverse)
for i = 0, 11 do begin &$
  ;tmptr = CONTOUR(moncmpp[*,*,i]*popmask,FINDGEN(NX)/10.+map_ulx, FINDGEN(NY)/10.+map_lry, $ ;
  tmptr = CONTOUR(ETHcmpp[*,*,i]*EthPOP,FINDGEN(eNX)/10.+map_ulx+10, FINDGEN(eNY)/10.+map_lry+15, $ ;
    RGB_TABLE=ct, ASPECT_RATIO=1, Xstyle=1,Ystyle=1,$ ;3x256 array
    /FILL, C_VALUE=index,RGB_INDICES=FIX(FINDGEN(ncolors)*255./ncolors), $
    TITLE=month[i],layout=[4,3,i+1], /CURRENT)  &$
  m1 = MAP('Geographic',limit=[map_lry+15,map_ulx+10,map_uly,map_lrx], /overplot) &$;
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
    m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2) &$
    tmptr.mapgrid.linestyle = 'none'  &$ ; could also use 6 here
    tmptr.mapgrid.FONT_SIZE = 0 &$
endfor
cb = colorbar(target=tmptr,ORIENTATION=0,TAPER=1,/BORDER, TITLE='runoff per capita ($m^{3} month^{-1}$)', position=[0.3,0.04,0.7,0.07]) 
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;now I would like to sum the months that have water scaricity
;do scarcity and absolute scaricity (<83)
help, monCMPP  
countmap = monCMPP[*,*,*]*!values.f_nan
  i=0
 for i=0,11 do begin &$ 
  temp = monCMPP[*,*,i]*popmask &$ 
  scarce = where(temp lt 83, complement=other) &$ 
  temp(scarce)=1  &$ 
  temp(other)=0  &$ 
  countmap[*,*,i]=temp  &$ 
 endfor
 
 ;;;plot is not totally right but getting close;;;;;
 ;;;need to pull out some time series to show examples in Ethiopia for current drought;;;;;
 ;but where?
 nmos=total(countmap,3,/nan)
; ncolors=13
; i=0
; w = WINDOW(DIMENSIONS=[700,900]) &$
;   ;for i = 0,11 do begin &$
;   p1 = image(congrid(nmos*popmask, NX*3, NY*3), image_dimensions=[NX/10,NY/10],  $
;   image_location=[map_ulx,map_lry],RGB_TABLE=72, MARGIN=[0.01, 0.01, 0.01, 0.1], /current )  &$ ;left, botton, right, top
;   rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
;   rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
;    p1.rgb_table = reverse(p1.rgb_table) &$
;    rgbdump[*,0] = [190,190,190] &$
;    p1.rgb_table = rgbdump
;   p1.MAX_VALUE=12.5 &$
;   p1.min_value=-0.5
;   m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot) &$
;   m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
;   m1.mapgrid.color = [150, 150, 150] &$
;   m1.mapgrid.font_size = 0 &$
;   mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
;   m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2) &$
; endfor
; cb = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,font_size=12)
; cb.tickvalues = [20,60,100,140] &$
;   cb.tickname = CLASS &$
;   cb.minor=0
; cb.TEXT_ORIENTATION=15
 
;;;try the contour version;;;;;
 ncolors = 12
 index = findgen(12);  RGB_INDICES=[0,63,127,190,255],
 
 
 ;include zoom into Ethiopia, not as easy with contour as image...
 EthCMPP = moncmpp[100:NX-1,150:NY-1,*] & help, EthCMPP
 EthPOP = popmask[100:NX-1,150:NY-1] & help, EthPOP
 dims = size(EthCMPP, /dimension)
 eNX = dims[0]
 eNY = dims[1]
 
 w = WINDOW(DIMENSIONS=[900,700])
   tmptr = CONTOUR((nmos+1)*popmask,FINDGEN(NX)/10. + map_ulx, FINDGEN(NY)/10. + map_lry, $
   RGB_TABLE=74,/FILL, ASPECT_RATIO=1, C_VALUE=index,RGB_INDICES=FIX(FINDGEN(ncolors)*255./ncolors), $
   TITLE='n months of stress', MAP_PROJECTION='geographic',Xstyle=1,Ystyle=1, /CURRENT)  &$
   tmptr.rgb_table = reverse(tmptr.rgb_table,2)
   tmptr.mapgrid.linestyle = 'none'  &$ ; could also use 6 here
   tmptr.mapgrid.FONT_SIZE = 0 &$
   m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot) &$;
   mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
   m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2) &$
 cb = colorbar(target=tmptr,ORIENTATION=0,TAPER=1,/BORDER, TITLE='n months w/ water stress', position=[0.3,0.04,0.7,0.07])
 
 ;;;ethiopia zoom
 w = WINDOW(DIMENSIONS=[900,700])
 tmptr = CONTOUR((nmos+1)*popmask,FINDGEN(NX)/10. + map_ulx, FINDGEN(NY)/10. + map_lry, $
   RGB_TABLE=74,/FILL, ASPECT_RATIO=1, C_VALUE=index,RGB_INDICES=FIX(FINDGEN(ncolors)*255./ncolors), $
   TITLE='n months of stress', MAP_PROJECTION='geographic',Xstyle=1,Ystyle=1, /CURRENT)  &$
   tmptr.rgb_table = reverse(tmptr.rgb_table,2)
 tmptr.mapgrid.linestyle = 'none'  &$ ; could also use 6 here
   tmptr.mapgrid.FONT_SIZE = 0 &$
   m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot) &$;
   mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
   m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2) &$
   cb = colorbar(target=tmptr,ORIENTATION=0,TAPER=1,/BORDER, TITLE='n months w/ water stress', position=[0.3,0.04,0.7,0.07])

;;;;next I want an average time series for the drought area, vs 2013 and 2014.
;Ethiopia Drought Amhara 11.6608N 37.9578E, Tigray = (14,39.4), Afar= 11.81667N, 41.416667
;get the time series from the places i selected for LVT...
help, CMPPcube, monCMPP

;now pull timeseries of interest
;;western africa;;;
wxind = FLOOR((2.632 - map_ulx) / 0.10) 
wyind = FLOOR((13.6456 - map_lry) / 0.10)

test = popmask & test[gxind,gyind]=10

;;;southern Africa;;;;;;
;Gabarone Dame
gxind = FLOOR( (25.926 - map_ulx)/ 0.1)
gyind = FLOOR( (-24.5 - map_lry) / 0.1)

;;;;East Africa;;;;;;;
;;Mpala Kenya:
;mxind = FLOOR( (36.8701 - map_ulx)/ 0.1)
;myind = FLOOR( (0.4856 - map_lry) / 0.1)
;
;;Adwa, tigray region (14,39.4) NDVI has higher freq variation that soil moisture here
;txind = FLOOR( (39 - map_ulx)/ 0.1)
;tyind = FLOOR( (14 - map_lry) / 0.1)
;
;;Sheka (dense veg), veg is prob not water limited here so anti-correlation 
;;makes more sense. it was even significant neg corr (-0.2) when lagged, I think
;sxind = FLOOR( (35.46 - map_ulx)/ 0.1)
;syind = FLOOR( (8.8 - map_lry) / 0.1);9.5 west welga
;
;;Bale
;bxind = FLOOR( (39 - map_ulx)/ 0.1)
;byind = FLOOR( (7 - map_lry) / 0.1)
;
;;Yirol, South Sudan
;yxind = FLOOR( (30.26 - map_ulx)/ 0.1)
;yyind = FLOOR( (6.6 - map_lry) / 0.1)

month = ['jan', 'feb', 'mar','apr','may','jun','jul','aug','sep','oct','nov','dec']

xind = gxind
yind = gyind
YOI = 2015
YOI2 = 2014

;p1 = barplot(mean(mean(monCMPP[hulx:hlrx,hlry:huly,*],dimension=1,/NAN),dimension=1,/NAN),fill_color='c', name='avg')
p1 = barplot(mean(mean(monCMPP[xind,yind,*],dimension=1,/NAN),dimension=1,/NAN),fill_color='c', name='avg')
p2 = plot(mean(mean(CMPPcube[xind,yind,*,YOI-startyr],dimension=1,/NAN),dimension=1,/NAN), /overplot, thick=3, name=string(YOI))
p3 = plot(mean(mean(CMPPcube[xind,yind,*,YOI2-startyr],dimension=1,/NAN),dimension=1,/NAN), /overplot, thick=3, linestyle=2, name=string(YOI2))

p3.yrange=[0,600]
p3.xrange=[0,11]
p3.xtickinterval=1
p3.xtickname=month
p3.xminor=0
line=polyline([0,11],[83,83],/data,target=p3,/overplot)
;p1.title = string([hmap_lrx, hmap_ulx, hmap_uly, hmap_lry])
p1.title = 'Mpala Kenya 37E, 0.3N';'Adwa, Tigray (39.4E,14N)';;'Yirol, South Sudan (30.26E, 6.6N)';'Bale (39E,7N)';Sheka (35.46,8.8N)';
!null = legend(target=[p1,p2,p3], position=[0.2,0.3]) 
p3.ytitle = 'runoff (m3) per person per month'


p1 = plot(mean(mean(CMPPcube[hulx:hlrx,hlry:huly,*,32],dimension=1,/NAN),dimension=1,/NAN), /overplot, thick=5, linestyle=2)
p1 = plot(mean(mean(CMPPcube[hulx:hlrx,hlry:huly,*,31],dimension=1,/NAN),dimension=1,/NAN), /overplot, thick=5, linestyle=2)
p1 = plot(mean(mean(CMPPcube[hulx:hlrx,hlry:huly,*,30],dimension=1,/NAN),dimension=1,/NAN), /overplot, thick=5, linestyle=3)
p1 = plot(mean(mean(CMPPcube[hulx:hlrx,hlry:huly,*,29],dimension=1,/NAN),dimension=1,/NAN), /overplot, thick=5, linestyle=2)

p1.xrange=[0,407]
p1.xtickinterval=12
p1.xtickname=strmid(string(indgen(nyrs+1)+startyr),6,2)
p1.xminor=1
p1.yrange =[0,5]
p1.title = 'East Rift 7.95N-9.35N, 39.1-40.2E'

 
;interannual metrics of interest - important for questions related to rainfall totals
;annRO = mean(total(ROmm,3,/nan),dimension=3,/nan) & help, annRO
;STDannRO = stddev(total(ROmm,3,/nan),dimension=3,/nan) & help, STDannRO
;CVannRO = STDannRO/annRO
;this computes the percent annomlay of monthly water avail.
;this was a good first look for the ucsb meeting, but now moving on.
;CMPPanom = ROmm*!values.f_nan
;
;for y = 0,34 do begin &$
;  for m = 0,11 do begin &$
;    CMPPanom[*,*,m,y] = CMPPcube[*,*,m,y]/monCMPP[*,*,m] &$
;  endfor &$
;endfor

;;;;plots forllowing schol et al. 2008
ncolors=12
  ;p1 = image(congrid(annCMPP, NX*3, NY*3), image_dimensions=[NX/10,NY/10],  $
  p1 = image(congrid(test, NX*3, NY*3), image_dimensions=[NX/10,NY/10],  $
  image_location=[map_ulx,map_lry],RGB_TABLE=72, MARGIN=[0.01, 0.01, 0.01, 0.1], /current )  &$ ;left, botton, right, top
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [190,190,190] &$

  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  ;p1.title = string(yr[i]) &$
  ;p1.MAX_VALUE=600 &$
  cb = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,font_size=12) &$
  m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2) &$  
  
  
;;;old
;
;ncolors=100 ;10 for VIC v NOAH there is a funny hash pattern in VIC v Noah, maybe becasue of re-gridding
;;nx = 294
;;ny = 348
;nx = 486
;ny = 443
;i=1
;;x direction is ~1degree and y is ~0.5 degree..
;ulx = (180.+map_ulx)/1.29  & lrx = (180.+map_lrx)/1.29
;uly = (55+map_uly)/0.93   & lry = (55.+map_lry)/0.93
;
;print, ulx, lrx, uly, lry
;aqNX = lrx - ulx
;aqNY = uly - lry
;
;afr = aqdt[ulx:lrx,lry:uly]
;afr(where(afr lt 0)) = !values.f_nan
;
;afr01 = congrid(afr,NX,NY) & help, afr01
;afr01month = rebin(congrid(afr/12,NX,NY),NX,NY,12,nyrs)  

;this was the average monthly stress. how about all 32 yrs?
;for BLWS use rgb_table=55
;w = window(DIMENSIONS=[1400,600])
;AnnRO = mean(total(RO,/nan),dimension=3,/nan)
;AnnRain = mean(total(rain*86400*30,3,/nan),dimension=3,/nan)
  
;for x = 0,NX-1 do begin &$
;  for y = 0,NY-1 do begin &$
;      zCMPP[X,Y,*,*] = standardize(reform(CMPPcube[X,Y,*,*])) &$
;  endfor &$
;endfor
;avgCMPP = rebin(monCMPP,294,348,12,35)
;
;CMPPanom = avgCMPP-CMPPcube
;
;temp = image(CMPPanom[*,*,0,34])
;annET = mean(total(ETmm,3,/nan),dimension=3,/nan) & help, annET
; read in withdrals (m3), subset to africa
;indir = '/home/sandbox/people/mcnally/AQUEDUCT/withdrawal/'
;average total runoff/average population
; subtract total runoff for a given yr.
;annCMPP = (annRO/pop)*1000 & help, annCMPP
;ifile = file_search(indir+'*lat_lon2.tif')
;aqdt = read_tiff(ifile,R,G,B,geotiff=geotiff);i think that this is 55S-85N

;aqdt = reverse(aqdt,2) ;5.4x10^10m3 of withdrawls/yr...how much rainfall do i estimate?
;aqdt(where(aqdt lt -999.))=!values.f_nan

;;;;plot irrigation;;;;;;
;ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input.SA.modislc_gripc.nc')
;fileID = ncdf_open(ifile, /nowrite)
;landID = ncdf_varid(fileID,'IRRIGTYPE') &$
;  ncdf_varget,fileID, landID, GRIPC
;dims = size(GRIPC, /dimensions) & print, dims
;NX = dims[0]
;NY = dims[1]
;NZ = dims[2]
;what does average monthly water availability look like? the value is a basin avg in km3 and these are 10km2 pixels
; km3 = 1x10^18 mm3, 1*10^-15 = cm3, and multiply TBW*10^6 (1,000,000) to change mm to km ...this makes everything 10^7
;max withdrawls are still more than available H20, where?;

;no irrigated ag stress is 0-30
;BLWS = mWTH/mTBW
;
;how does 2014 water stress differ from the average?
;pop35 = rebin(pop,294,348,35) & help, pop35
;RO35 = total(ROmm,3,/nan) & help, RO35
;CMPP35 = (RO35/pop35)*1000
  
  
  
;;;;TBW anomalies
ncolors=25
w = window(DIMENSIONS=[1400,600])
for YOI=2008,2014 do begin &$
;for i=0,4 do begin &$
  p1 = image(congrid(TBWanom_JFM[*,*,YOI-startyr], NX*3, NY*3), image_dimensions=[NX/10,NY/10], $
  image_location=[map_ulx,map_lry],RGB_TABLE=70, /current, layout = [4,2,2015-YOI], $
  MARGIN=[0.02, 0.01, 0.02, 0.1])  &$ ;left, botton, right, top
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  ;rgbdump[*,255] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  ;rgbdump[*,0] = [190,190,190] &$
  ;rgbdump[*,255] = [190,190,190]
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.title = string(YOI) &$
  p1.MAX_VALUE=5 &$
  p1.min_value=-5 &$
  cb = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,font_size=24) &$
  ;  cb.tickvalues = [0.1,0.3,0.5,0.7] &$
  ;  cb.tickname = CLASS &$
  ;  cb.minor=0 &$
  ;m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot) &$
  m1 = MAP('Geographic',limit=[-28,18,-21,30], /overplot) &$

  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1) &$
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=2) &$
 ;endfor &$
endfor

;show a time series of TBW anomalies for this region November-March 1981-2013
;limit=[-28,21,-21,30]
gmap_lry = -28
gmap_ulx = 21
gmap_uly = -21
gmap_lrx = 30

gulx = (gmap_ulx-map_ulx)/0.1  & glrx = (gmap_lrx-map_ulx)/0.1
guly = (gmap_uly-map_lry)/0.1   & glry = (gmap_lry-map_lry)/0.1

print, gulx, glrx, guly, glry


ROIanom = mean(mean(TBWanom_JFM[gulx:glrx,glry:guly,*],dimension=1,/nan),dimension=1,/nan)
p1 = barplot(roianom)
p1.xrange = [0,nyrs-1]
xticks = indgen(nyrs+1)+startyr & print, xticks
p1.xtickinterval = 1
p1.xTICKNAME = strmid(string(xticks),6,2)
p1.xminor = 0
;p1.yrange=[-2.5,2.5]
afr(where(afr lt 0)) = !values.f_nan


;;;;;;now add in the irrigated ag.
;ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input.EA.modislc_gripc.nc')
;fileID = ncdf_open(ifile, /nowrite)
;
;irrgID = ncdf_varid(fileID,'IRRIGFRAC') &$
;ncdf_varget,fileID, irrgID, IRRG_f
;
;irrgID = ncdf_varid(fileID,'IRRIGTYPE') &$
;  ncdf_varget,fileID, irrgID, IRRG_t
;
;cropID = ncdf_varid(fileID,'CROPTYPE') &$
;  ncdf_varget,fileID, cropID, CROP
;dims = size(CROP, /dimensions)
;crop(where(crop lt 0)) = !values.f_nan
;
;landID = ncdf_varid(fileID,'LANDCOVER') &$
;  ncdf_varget,fileID, landID, LAND
;dims = size(LAND, /dimensions)
;
;nx = dims[0]
;ny = dims[1]
;nz = dims[2]

;mask IRR values where irrigation is present
;IRR and WTH should be in comprable units...

irrmask = irrg_f
irrmask(where(irrmask gt 0, complement=other))=1
irrmask(other)=0

irrmask12=rebin(irrmask,nx,ny,12)
irrmask32=rebin(irrmask,nx,ny,12,nyrs)

ag = irrmask12*mIrr
ag32 = irrmask32*Irr
WTHs = rebinafr;scale this?

help, ag32, TBW, WTHs

BLWS = WTHs/(TBW-ag32) & help, BLWS
;worst rainy seasons March-Sept
M2S = mean(mean(mean(BLWS[*,*,2:8,*],dimension=1,/nan),dimension=1,/nan),dimension=1,/nan)
p1=barplot(m2s-mean(m2s))
p1.xrange = [0,nyrs-1]
xticks = indgen(nyrs+1)+startyr & print, xticks
p1.xtickinterval = 1
p1.xTICKNAME = string(xticks)
p1.xminor=0
p1.yminor=0
p1.title = 'East Africa domain average March-Sept BLWS anom (1982-2013)'
p1.yrange=[-.1,.1]
p1.title.font_size=18



tmpgr = image(congrid(afr,446,124), RGB_TABLE=64, MIN_VALUE=0., $
  TITLE='Aqueduct_withdrawals',FONT_SIZE=14, MAX_VALUE=1000000000, $
   AXIS_STYLE=0,MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], $
  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry])
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
tmpgr.mapgrid.FONT_SIZE = 10
m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.])
cb = colorbar(target=tmpgr,ORIENTATION=0,FONT_SIZE=0)
tmpgr.save,strcompress('/home/sandbox/people/mcnally/'+tmpgr.title.string+'.jpg', /remove_all),RESOLUTION=200
;get Qsurf and Qsub (k/m2/s = mm/s) 3.16x10^7 sec/yr total annual runoff (per pixel)



;read in Shrad's VIC data mm/day (mm/yr)
;ifile = file_search('/home/sandbox/people/mcnally/VIC_RO/RO_yearsum_1982_2010.nc')
;fileID = ncdf_open(ifile, /nowrite) &$
;  qsID = ncdf_varid(fileID,'RUNOFF') &$
;  ncdf_varget,fileID, qsID, VIC
;VIC(where(VIC lt 0)) = !values.f_nan
;VIC(where(VIC gt 5000))=!values.f_nan
;
;;pad out left side of the figure
;left_pad = rebin(fltarr(24,127)*!values.f_nan,24,127,29) & help, left_pad
;top_pad = rebin(fltarr(117,12)*!values.f_nan,117,12,29) & help, top_pad
;;1981-2010
;eaVIC = [ [ left_pad, vic], [top_pad] ]
;PAD = fltarr(117,139)*!values.f_nan
;;VIC81 = [ [[PAD]],[[eaVIC]] ]
;VIC81 = eavic


 ;looks like i just did surface runoff. what does Qsub look like here...and i did do from 1981.
 ;data from Noah_CHIRPSvS5, what yrs are these?
 ;;;;;;;;;East Africa;;;;;;;
;ifile = file_search('/home/sandbox/people/mcnally/AQUEDUCT/Qs_yearsum_1981_2014.nc')
;fileID = ncdf_open(ifile, /nowrite) &$
;qsID = ncdf_varid(fileID,'Qs_tavg') &$
;ncdf_varget,fileID, qsID, Qsurf
;Qsurf(where(Qsurf lt 0)) = !values.f_nan
;
;ifile = file_search('/home/sandbox/people/mcnally/AQUEDUCT/Qsb_yearsum_1981_2014.nc')
;fileID = ncdf_open(ifile, /nowrite) &$
;qsbID = ncdf_varid(fileID,'Qsb_tavg') &$
;ncdf_varget,fileID, qsbID, Qsub
;Qsub(where(Qsub lt 0)) = !values.f_nan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ifile = file_search('/home/sandbox/people/mcnally/NOAH_CHIRPS_MERRA_WA/Qs_yearsum_1981_2014.nc')
fileID = ncdf_open(ifile, /nowrite) &$
  qsID = ncdf_varid(fileID,'Qs_tavg') &$
  ncdf_varget,fileID, qsID, Qsurf
Qsurf(where(Qsurf lt 0)) = !values.f_nan

ifile = file_search('/home/sandbox/people/mcnally/NOAH_CHIRPS_MERRA_WA/Qsb_yearsum_1981_2014.nc')
fileID = ncdf_open(ifile, /nowrite) &$
  qsbID = ncdf_varid(fileID,'Qsb_tavg') &$
  ncdf_varget,fileID, qsbID, Qsub
Qsub(where(Qsub lt 0)) = !values.f_nan


;read in the longrain/short rain mask:
;ifile = file_search('/home/sandbox/people/mcnally/lis_input_wrsi.ea_oct2feb.nc') & print, ifile
ifile = file_search('/home/sandbox/people/mcnally/lis_input_wrsi.wa.mode.nc') & print, ifile
fileID = ncdf_open(ifile, /nowrite) &$
maskID = ncdf_varid(fileID,'WRSIMASK')
ncdf_varget,fileID, maskID, shortmask
shortmask(where(shortmask eq 0)) = !values.f_nan
RO = Qsurf+Qsub

;0.25 degree for VIC
;qsurf25 = congrid(qsurf,117,139,34)
;qsub25 = congrid(qsub,117,139,34)
;RO25 = congrid(RO,117,139,34)

;average over select regions
;mask for the highwithdrawl regions? Correlation is good R=0.8
;Kenya, Ethipia and Yemen plots would be better
;mask=rebinafr
;mask(where(mask gt 1000000000, complement=other))=1
;mask(other)=!values.f_nan
;mask29=rebin(mask,117,139,29)
;p1=image(mask, max_value=1, min_value=0)

;East Africa WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

;Nile Basin Runoff
bot = (10-map_lry)/0.25 & top = (18-map_lry)/0.25 & print, bot, top
left = (32.5-map_ulx)/0.25 & right = (37-map_ulx)/0.25 & print, left, right

;Southern Kenya Runoff
left = (37.5-map_ulx)/0.25 & right = (40-map_ulx)/0.25 & print, left, right
bot = (abs(map_lry)-4)/0.25 & top = (abs(map_lry)-1)/0.25 & print, bot, top

;any regions of interest in West Africa?
map_ulx = -18.65 & map_lrx = 25.85
map_uly = 17.65 & map_lry = 5.35

;Niger
bot = (10-map_lry)/0.1 & top = (15-map_lry)/0.1 & print, bot, top
left = (0-map_ulx)/0.1 & right = (10-map_ulx)/0.1 & print, left, right

;Senegal
bot = (14-map_lry)/0.1 & top = (15-map_lry)/0.1 & print, bot, top
left = (-15-map_ulx)/0.1 & right = (-10-map_ulx)/0.1 & print, left, right

;Mali
bot = (12-map_lry)/0.1 & top = (15-map_lry)/0.1 & print, bot, top
left = (-6-map_ulx)/0.1 & right = (-2-map_ulx)/0.1 & print, left, right


check = rebinafr
check[left:right, bot:top]=5
p1=image(check, min_value=0, max_value=10)
p2=image(rebinafr,/overplot, rgb_table=4, transparency=60)

;shortmask25 = rebin(congrid(shortmask,117,139),117,139,nyrs)
;Look at the mean across the whole domain, and the shortmask
VTS = mean(mean(Qsurf[left:right,bot:top,*],dimension=1,/nan),dimension=1,/nan)
NTS = mean(mean(Qsub[left:right,bot:top,*],dimension=1,/nan),dimension=1,/nan)
ATS = mean(mean(RO[left:right,bot:top,*],dimension=1,/nan),dimension=1,/nan)
;BTS = mean(mean(vic81[left:right,bot:top,*],dimension=1,/nan),dimension=1,/nan)

;p1=plot(vts/2, thick=2, /overplot)
w = WINDOW(WINDOW_TITLE=string('runoff'),DIMENSIONS=[1500,500])
;p2 = plot(nts/4, 'b', /current)
p4 = plot(ats, /current,'b', thick=2)
;p4 = plot(nts, /overplot,'g', thick=2)
p4.xrange=[0,34] &$
  ;p2.xmajor= 1&$
p4.xtickname=string(indgen(18,increment=2)+1981)
p4.xminor = 1 & p4.yminor = 0
p4.ytitle = 'runoff (kg/m2)'
p4.title='LIS7-Noah33 Runoff, Niger (10N-15N, 0E-10E)'
p4.save,strcompress('/home/sandbox/people/mcnally/Niger_Runoff.jpg', /remove_all),RESOLUTION=200 &$

print, r_correlate(bts,ats)

;;;;;;;;;;baseline water stress;;;;;;;;;;;;;
;what happened here?
;how to convert cubic meters/yr into mm/mo
;wcube = rebin(congrid(afr,294,348),294,348,34) & help, wcube
;wcube = rebin(congrid(afr,117,139),117,139,nyrs) & help, wcube
wcube = rebin(congrid(afr,446,124),446,124,34) & help, wcube

help, wcube, ro
wcube_scale = wcube/10000
ro_scale = ro*(86400*365)
BLWS = Wcube_scale/RO_scale & nve, blws

;ofile = '/home/sandbox/people/mcnally/waterstress_2000_2013.img
;openw,1,ofile
;writeu,1,a[*,*,0:13]
;close,1

nx = 446
ny = 124
ncolors = 20
yr = indgen(34)+1981
y=2012
;yr = [2001,2002]
w = WINDOW(DIMENSIONS=[600,900])
;good to multiply by: *100000000
for y = 20, n_elements(yr)-1 do begin &$
  ncolors=3  &$
  ;p1 = image(mean(blws, dimension=3, /nan)*shortmask, RGB_TABLE=65,layout=[1,3,1],/CURRENT, $
  p1 = image(blws[*,*,2012-1981]*shortmask, RGB_TABLE=65,layout=[1,3,3],/CURRENT, $
  FONT_SIZE=14, AXIS_STYLE=0,MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], $
  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry]) &$
  p1.min_value=-0.5 &$
  p1.max_value=100 &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [200,200,200] &$
  p1.rgb_table = rgbdump &$
  p1.title = 'Water Stress 2012' &$ ;+string(yr[y])
  ;p1.title = 'Baseline Water Stress (1981-2014)' &$ ;+string(yr[y])
  p1.mapgrid.linestyle = 6 &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.FONT_SIZE = 0 &$
  m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.], thick=2) &$
  cb = colorbar(target=p1,ORIENTATION=0,FONT_SIZE=0) &$
  ;p1.save,strcompress('/home/sandbox/people/mcnally/waterstress.jpg', /remove_all),RESOLUTION=200 &$
endfor

BLWS = mean(a[*,*,0:13], dimension=3, /nan)
ncolors = 256
;same thing for the anomaly but and the cmap color scheme
for i = 0, n_elements(yr)-2 do begin &$
  tmpgr = image((a[*,*,i]-BLWS)/10000000,  RGB_TABLE=reverse(CONGRID(make_cmap(ncolors),3,256),2), max_value=0.2,min_value=-0.2,$
  ;tmpgr = image(mean(a, dimension=3, /nan), RGB_TABLE=65, MIN_VALUE=0.,layout=[3,5,i+1], /CURRENT,$
  TITLE=yr[i],FONT_SIZE=14, $
  AXIS_STYLE=0,MAP_PROJECTION='Geographic',LIMIT=[map_lry,map_ulx,map_uly,map_lrx], $
  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry]) &$
  tmpgr.mapgrid.linestyle = 6 &$
  tmpgr.mapgrid.label_position = 0 &$
  tmpgr.mapgrid.FONT_SIZE = 0 &$
  m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.], thick=2) &$
  cb = colorbar(target=tmpgr,ORIENTATION=1,FONT_SIZE=12) &$
  tmpgr.save,strcompress('/home/sandbox/people/mcnally/BLWSa_'+tmpgr.title.string+'.jpg', /remove_all),RESOLUTION=200 &$
endfor

;seasonal variability : stddev/mean monthly avg supply (RO)
data_dir='/home/sandbox/people/mcnally/NOAH_CHIRP_MERRA/'

nx = 294
ny = 348

QsubMO = fltarr(nx,ny,12)
Q = fltarr(294,348,12,34)*!values.f_nan
for m = 1,12 do begin &$
  ifile =  file_search(data_dir+STRING(FORMAT='(''/Qsub_YRMO/Qsb_Noah????_'',I2.2,''.nc'')',m)) &$
  for i = 0,n_elements(ifile)-1 do begin &$
  fileID = ncdf_open(ifile[i]) &$
  qsbID = ncdf_varid(fileID,'Qsb_tavg') &$
  ncdf_varget,fileID, qsID, Qsub &$
  Q[*,*,m-1,i] =  Qsub &$
endfor &$
QsubMO[*,*,m-1] = mean(Q[*,*,m-1,*], dimension=4, /nan) &$
endfor
QsubMO(where(QsubMO lt 0)) = !values.f_nan
;seasonal variability...not sure how useful this one is. except maybe as a tutorial
svar = stddev(QsubMO,dimension=3,/nan)
svag = mean(QsubMO,dimension=3,/nan)


;;;;;;;;drought severity with monthly SM percentiles (maybe try with ECV as well?);;;;;;;;;;;;;
; do i have these runs for the other africa masks? i can do the belg mask

data_dir='/home/sandbox/people/mcnally/NOAH_CHIRP_MERRA/'

;I should probably make sure that the yrs exist. e.g Jan1981?
nx = 294
ny = 348
;SM01_Noah2014_03.nc
smMO = fltarr(nx,ny,12)
SM = fltarr(294,348,12,34)*!values.f_nan
for m = 1,12 do begin &$
  ifile =  file_search(data_dir+STRING(FORMAT='(''/SM01_YRMO/SM01_Noah????_'',I2.2,''.nc'')',m)) &$
  for i = 0,n_elements(ifile)-1 do begin &$
  fileID = ncdf_open(ifile[i]) &$
  smID = ncdf_varid(fileID,'SoilMoist_tavg') &$
  ncdf_varget,fileID, smID, SM01 &$
  SM[*,*,m-1,i] =  SM01 &$
endfor &$
smMO[*,*,m-1] = mean(SM[*,*,m-1,*], dimension=4, /nan) &$
endfor
;;;;;;;calculate the soil moisture percentile
;this needs to be done for each month...
;1. MAM in 2011
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
per67 = fltarr(nx, ny, 12)
per33 = fltarr(nx, ny, 12)
permap = fltarr(nx, ny, 12, 4)
for m = 0,11 do begin &$
  for x = 0, nx-1 do begin &$
    for y = 0, ny-1 do begin &$
  ;skip nans
  test = where(finite(SM[x,y,m,*]),count) &$
  if count eq -1 then continue &$
  ;look at one pixel time series at a time
  pix = SM[x,y,m,*] &$
  ;then find the index of the Xth percentile, how would i fit a distribution?
  permap[x,y,m,*] = cgPercentiles(pix , PERCENTILES=[0.05,0.1,0.2,0.3]) &$
endfor  &$;x
endfor;

;map the percentile classes
;from US drought monitor (0-2 = exceptional; 3-5 = extreme [5]); 6-10=severe [4]; 11-20=moderate [3]; 21-30 = abnormal dry [2]; >30 not drought [1]
pc = sm*!values.f_nan
sm(where(sm lt -999.))=!values.f_nan

for m = 0,12-1 do begin &$
  for x = 0, nx-1 do begin &$
    for y = 0, ny-1 do begin &$
    ;skip nans
    test = where(finite(SM[x,y,m,*]),count) &$
    if count eq 0 then continue &$
    ;map the percentile bins for each year using the permap values
    ;go over each map 294x348x12x34 and replace values with bin, this can be a where statement....
    smvector = sm[x,y,m,*] &$
    smvector2=smvector*!values.f_nan &$
    ;change the values of the vector, how to do this...
    smvector2(where(smvector le permap[x,y,m,0])) = 5 &$
    smvector2(where(smvector gt permap[x,y,m,0] AND smvector le permap[x,y,m,1])) = 4 &$
    smvector2(where(smvector gt permap[x,y,m,1] AND smvector le permap[x,y,m,2])) = 3 &$
    smvector2(where(smvector gt permap[x,y,m,2] AND smvector le permap[x,y,m,3])) = 2 &$
    smvector2(where(smvector gt permap[x,y,m,3])) = 1 &$
    ;then put them back into the map
    pc[x,y,m,*] = smvector2 &$   
    endfor &$
  endfor &$
endfor



;read in the longrain/short rain mask:
ifile = file_search('/home/sandbox/people/mcnally/lis_input_wrsi.ea_oct2feb.nc') & print, ifile
fileID = ncdf_open(ifile, /nowrite) &$
  maskID = ncdf_varid(fileID,'WRSIMASK')
ncdf_varget,fileID, maskID, shortmask

;;;;;;Ethiopia-Yemen window;;;;;;;;
;ymap_ulx = 30.05  & ymap_lrx = 49.95
;ymap_uly = 20.15  & ymap_lry = 5.15

;Yemen window
ymap_ulx = 42. & ymap_lrx = 48.
ymap_uly = 18. & ymap_lry = 12.

mo = ['jan', 'feb', 'mar', 'apr', 'may', 'jun','jul','aug','sep','oct','nov','dec']
ncolors = 5

startyr=1981
for YOI = 1981,2014 do begin &$
w = WINDOW(WINDOW_TITLE=string(YOI),DIMENSIONS=[700,700]) &$
for i = 0,12-1 do begin &$
  p1 = image(pc[*,*,i,YOI-startyr], layout=[4,3,i+1],RGB_TABLE=65,FONT_SIZE=14, $
  AXIS_STYLE=0,MAP_PROJECTION='Geographic',LIMIT=[ymap_lry,ymap_ulx,ymap_uly,ymap_lrx], $
  IMAGE_DIMENSIONS=[map_lrx-map_ulx,map_uly-map_lry],IMAGE_LOCATION=[map_ulx,map_lry],/current )  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [200,200,200] &$
  p1.rgb_table = rgbdump &$
  p1.title = 'SM percentile'+string(mo[i]) &$
  p1.mapgrid.linestyle = 6 &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.FONT_SIZE = 0 &$
  p1.min_value=0 &$
  p1.max_value=5 &$
 ; m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.]) &$
  m1 = MAPCONTINENTS(/COUNTRIES, COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=[-40.,-20.,40.,55.]) &$

endfor  &$
cb = colorbar(target=p1,ORIENTATION=0,FONT_SIZE=12) &$
endfor

;;;;;;;;plot time series for the different masks (like Bala did). Can also do the livelihood zones. 
;these GIS tasks are good for ENVI...
;read in the livelihood raster for kenya
ifile = file_search('/home/sandbox/people/mcnally/AQUEDUCT/Kenya_livlihood_raster')
ingrid = bytarr(nx,ny)
openr,1,ifile
readu,1,ingrid
close,1
ingrid = reverse(ingrid,2)
;names = ['central_higlands','Marsabit_Marginal_Mixed_Farming',NW_Agropastoral', 'Southeastern Marginal Mixed Farming Zone &
;          'tinny5, Western High Potential Zone]
names = ['unclass', 'CentralHighlandsHigh',  'MarsabitMarginalMixed', 'NorthwesternAgropastoralZone',  'SoutheasternMarginalMixed',  $
          'TurkwellRiverineZone', 'WesternHighPotential','TanaRiverineZone'    ,  'SoutheasternMediumPotential',$
           'NorthernPastoralZone' , 'WesternMediumPotential', 'WesternLakeshoreMarginal',$
         'SouthernPastoralZone',  'NortheasternPastoralZone' , 'ManderaRiverineZone' ,'GrasslandsPastoralZone' , 'NortheasternAgropastoralZone',$
         'LakeTurkanaFishing',  'LakeVictoriaFishing', 'WesternAgropastoralZone', 'CoastalMediumPotential',$
         'CoastalMarginalAgricultural', 'SoutheasternPastoralZone', 'NorthwesternPastoralZone', 'SouthernAgropastoralZone']

;rather than pc (cube)
pcvect = reform(pc,nx,ny,12*34)

for r = 0, n_elements(names)-1 do begin

  ROI = r+1 &$
  LZ = ingrid &$
  LZ(where(ingrid eq ROI, complement=no))=1 &$
  LZ(no)=0 &$
  LZ = rebin(LZ, nx, ny, 12*34) &$
  w = WINDOW(WINDOW_TITLE=string('LZ_droughtTS'),DIMENSIONS=[1700,500]) &$

  ;w = WINDOW(WINDOW_TITLE=string('LZ_droughtTS'),DIMENSIONS=[1700,500]) &$
  ;ROI = where(ingrid[*,*,0] eq 0, complement=no)
  TS = mean(mean(pcvect*LZ, dimension=1, /nan),dimension=1,/nan) &$
  TS_sm = ts_smooth(TS,6) & help, ts_sm &$
  p1=plot(TS, /current) &$
  p2 = plot(TS_sm, /overplot, thick=2) &$
  p1.xrange=[1,408] &$
  p1.xmajor=34 &$
  p1.xtickname=string(indgen(34)+1981) &$
  p1.title = string(names[r]) &$
endfor 

;drought severity is number of months below 20th percentile (class ge 2 = 4,3,2).
;Percentiles=[0.05,0.1,0.2,0.3]....reform to a 12*34 vector then if x and x-1 are ge 2 then count else sum and reset to 0
;calculate length of drought
;to get the severity multiply length x average percentile (or class) 
drought = intarr(nx,ny,12*34)
severity = fltarr(nx,ny,12*34)
for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
  ts = pcvect[x,y,*] &$
  for z = 1, n_elements(ts)-1 do begin &$
    if ts[z] gt 2 AND ts[z-1] gt 2 then cnt++ else cnt = 0 &$
    severity[x,y,z] = cnt*ts[z] &$
    drought[x,y,z] = cnt &$
  endfor &$
 endfor &$
endfor   
years = ['81','84','87','90','93','96','99','02','05','08','11','14']
  cnt=0
  ;w = WINDOW(WINDOW_TITLE=string('LZ_droughtTS'),DIMENSIONS=[1000,600]) &$
  w = WINDOW(WINDOW_TITLE=string('LZ_droughtTS'),DIMENSIONS=[700,900]) &$

for r = 1, n_elements(names)-1 do begin &$
  ;R = 4,13,16,22
 ; for r = 1, 3 do begin &$
  ROI = 22 &$
  LZ = ingrid &$
  LZ(where(ingrid eq ROI, complement=no))=1 &$
  LZ(no)=0 &$
  LZ = rebin(LZ, nx, ny, 12*34) &$

;ROI = where(ingrid[*,*,0] eq 0, complement=no)
  TS = mean(mean(severity*LZ, dimension=1, /nan),dimension=1,/nan) &$
  ;TS_sm = ts_smooth(TS,6) & help, ts_sm
  ;p1=barplot(TS*100, layout=[3,8,r], /current) &$
  p1=barplot(TS*100, layout=[1,4,4], /current, FONT_SIZE=12) &$

 ;p2 = plot(TS_sm, /overplot, thick=2)
  p1.xrange=[0,395] &$
  p1.xmajor=12 &$
  p1.xtickname=string(years) &$
  p1.title = string(names[roi]) &$
endfor 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;look at the yemen livlihood zones
YE01 = 'Amran rainfed'

;ofile = '/home/sandbox/people/mcnally/EA_SM_droughtlength_294x348x408.bin'
;openw,1,ofile
;writeu,1,drought
;close,1

;**********how to i find a time series for a specific location?******
;East Africa WRSI/Noah window
kmap_ulx = 35.  & kmap_lrx = 41
kmap_uly = 0.  & kmap_lry = -3

;map_ulx = 22.  & map_lrx = 51.35
;map_uly = 22.95  & map_lry = -11.75

;uh, how does this work with the east africa subset
kulx = (kmap_ulx-22.)*10.  & klrx = (kmap_lrx-22.)*10.-1
kuly = (11.-kmap_uly)*10.   & klry = (11.-kmap_lry)*10.-1

;this sort of gets at what i want....
tmpplt=plot(mean(mean(a[kulx:klrx,kuly:klry,*], dimension=1,/nan),dimension=1,/nan), thick=3)
tmpplt.yTICKVALUES = [500000,1000000,1500000,200000,2500000]
tmpplt.yTICKNAME = ['Long Ago','Before','Mid-Century','Semi-Recent','Recent']
tmpplt.yTICKFONT_SIZE = 10
tmpplt.YTICKFONT_SIZE = 10


;East Africa WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

;Southern Africa WRSI/Noah window
;Southern Africa (37.85 S - 6.35 N; 6.05 E - 54.55 E) NX = 486 & NY = 443
;map_ulx = 6.05  & map_lrx = 54.55
;map_uly = 6.35  & map_lry = -37.85

; west africa domain
;map_ulx = -18.65 & map_lrx = 25.85
;map_uly = 17.65 & map_lry = 5.35





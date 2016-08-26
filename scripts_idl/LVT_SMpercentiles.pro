pro LVT_SMpercentiles

;08/13/15 percentiles computed in LVT moved from getSM_percentiles_EA
; this script makes plots based on the drought monitor and computes the drought severity index. 
; Not sure how this will be in the netcdf files, but the soil moisture percentiles for sure. Add other things like SPI later. 
; 9/29/15 does this include the USDM color scheme? yes. Update to use the FILES4GESDISC rather than the LVT_percentiles
; 10/9/15 compute drought severity index for ethiopia region of interest. 
; 12/9/15 update for AGU
; 01/7/15 update for southen africa
; 06/12/16 plot for data sci paper.
; 06/28/16 I could look at the rootzone, since i did compute thoes for rowland.

.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
.compile /home/almcnall/Scripts/scripts_idl/nve.pro
;.compile /home/almcnall/Scripts/scripts_idl/mve.pro
.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro

help, SMP ;from readin_chirps_noah_sm.pro
SM = SMP


indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/'
;ifile = file_search(indir+'lis_input.MODISmode_ea.nc');lis_input_wa_elev.nc
;ifile = file_search(indir+'lis_input_wa_elev_mode.nc');
ifile = file_search(indir+'lis_input_sa_elev_mode.nc')

;this mask isn't owrking the way that i want it to...
VOI = 'LANDCOVER'
LC = get_nc(VOI, ifile)
bare = where(LC[*,*,15] eq 1, complement=other)
water = where(LC[*,*,16] eq 1, complement=other); is this water or wooded tundra
veg = where(LC[*,*,1] eq 1, complement=other);


mask = fltarr(NX,NY)+1.0
mask(bare)=!values.f_nan
mask(water)=!values.f_nan
mask(veg)=!values.f_nan

ifile = file_search('/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/lis_input_wrsi.sa.nc')

fileID = ncdf_open(ifile)
qsID = ncdf_varid(fileID,'WRSIMASK'); WHC
ncdf_varget,fileID, qsID, landmask
NCDF_close, fileID
landmask(where(landmask gt 0))=1
landmask(where(landmask eq 0))=!values.f_nan


;for each month in the time series classify these using the USDM scheme
;from US drought monitor (0-2 = exceptional D4=5; 3-5 = extreme D3=4); 6-10=severe D2=[3];
;                         11-20=moderate D1=[2]; 21-30 = abnormal dry D0=[1]; >30 not drought D00[0]
;  npc = sm*!values.f_nan
;  npc(where(sm le 0.02)) = 5 &$
;  npc(where(sm gt 0.02 AND sm le 0.05)) = 4 &$
;  npc(where(sm gt 0.05 AND sm le 0.10)) = 3 &$
;  npc(where(sm gt 0.10 AND sm le 0.20)) = 2 &$
;  npc(where(sm gt 0.21 AND sm le 0.30)) = 1 &$
;  npc(where(sm gt 0.30 AND sm le 0.67)) = 0
;  npc(where(sm gt 0.67) = -1

;sort of like Wassila's criteria for abnormal dryness < 30th percentile, 
;drought 8 week SM <20th percentile, severe 12-week <10th percenitle
;funk doesn't love these either: Change ‘drought’ to 20-30th, severe drought <20, abnormal dry 30-45,  >45

  
    npc = sm*!values.f_nan
    npc(where(sm gt 0.001 AND sm le 0.20)) = 3 &$
    npc(where(sm gt 0.20 AND sm le 0.30)) = 2 &$
    npc(where(sm gt 0.30 AND sm le 0.45)) = 1 &$
    npc(where(sm gt 0.45 AND sm le 0.67)) = 0
    npc(where(sm gt 0.67)) = -1

;shapefile = '/home/code/idl_user_contrib/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'
;CLASS = [' > normal ', 'abnormally dry', 'moderate drought', 'severe drought', 'extreme drought', 'exceptional drought']
CLASS = [' > normal ', 'abnormally dry',  'drought', 'severe drought']

month = ['jan','feb','mar','apr','may','jun','jul','aug']
res=10
ncolors = n_elements(class)
index = [-0.5,0,1,2,3];
ct=colortable(65)
;w=window()
TIC
;;;;buffer is a million times faster for this! don't print to screen!;;;;
;;;FIGURE FOR PAPER - DON"T MESS UP;;;;;;
y=n_elements(NPC[0,0,0,*])-1
m=1;zero index 1=feb
tmptr = CONTOUR(NPC[*,*,m,y]*mask,FINDGEN(NX)/res+map_ulx, FINDGEN(NY)/res+map_lry, $
  RGB_TABLE=ct, ASPECT_RATIO=1, Xstyle=1,Ystyle=1, /BUFFER, $
  /FILL, C_VALUE=index,RGB_INDICES=FIX(FINDGEN(ncolors)*255./ncolors), dimensions=[NX*1.5, NY]) &$
  m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], horizon_thick=1, /overplot)
  m = MAPCONTINENTS(/COUNTRIES,  COLOR = 'black', THICK=1) &$
  tmptr.mapgrid.linestyle = 'none'  &$ ; could also use 6 here
  tmptr.mapgrid.FONT_SIZE = 0
tmptr.mapgrid.label_position = 0
cb = colorbar(target=tmptr,ORIENTATION=1,TAPER=0,/BORDER, POSITION=[0.78,0.25,0.80,0.75])
cb.tickvalues = [0,1,2,3] &$
  cb.tickname = CLASS &$
  cb.font_size=12
  cb.minor=0
  cb.TEXTPOS=1
tmptr.save,'/home/almcnall/figs4SciData/SM_percentiles_FEB.png' &$
TOC

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

pro paper2_plotsv2

;8/27/13 to deal with paths moving from /jabber to /jower and to address some of joel's comments.
;12/26-12/31/13: revisit and see what figures need to be made for this paper.
;1/17/14 so maybe i want to do this with FLDAS soil moisture rather than  the NSM since the reviewers don't like that yet
;1/27/14 going back and looking at the microwave data
;2/03/14 remake crop area plot.
;2/19/14 try the spatial correlation in Hain et al. 2011 & 2/25/14 make mutipanel plots
;6/17/14 back for revisions
;7/24-7/30 more revisions and change to v3 so I can delete all NSM stuff and Noah03
;8/18-8/25/14 additional edits
;
;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5) / 0.10)

;Belefoungou-Top 9.79506     1.71450  
bxind = FLOOR((1.7145 + 20.) / 0.10)
byind = FLOOR((9.79506 + 5) / 0.10)


;***********FIGURE 1 landcover mask********
;see "landcover_map.pro"

;*****************figure 2 SOIL MOISTURE CORRELATIONS**********************************
;check these out in ENVI e.g Why are Noah/Bucket and Noah/ECV well corerlated in BF but not bucket/ecv?
;maybe it should be done with rank correlation since it is such a short TS
rfile = file_search('/home/chg-mcnally/sahel_ubRFE_PAW36_2001-2012_LGP_WHC_PET.img') & print, rfile ;is this the one i used for regress?
lfile2 = file_search('/home/chg-mcnally/SM0X2_scaled4WRSI_720_350_396.img') & print, lfile2 ;did this move to /sandbox?
mfile =  file_search('/home/chg-mcnally/ECV_MW_scaled4WRSI.img')& print,mfile

nx = 720
ny = 350
nz = 396

;map info
map_ulx = -20.00 & map_lrx = 52
map_uly =  20.00 & map_lry = -5
;check the nx, nys
ulx = (180.+map_ulx)*10. & lrx = (180.+map_lrx)*10.
uly = (50.-map_uly)*10. & lry = (50.-map_lry)*10.
gNX = lrx - ulx
gNY = lry - uly

rpawgrid = fltarr(nx,ny,432)
mpawgrid = fltarr(nx,ny,nz)
lpawgrid2 = fltarr(nx,ny,nz)

mocube = fltarr(nx,350,36,10);

openr,1,rfile
readu,1,rpawgrid
close,1
rpawgrid(where(rpawgrid eq 0))=!values.f_nan
rpawgrid(where(rpawgrid gt 400))=400

rpawcube = reform(rpawgrid,nx,350,36,12)


openr,1,mfile
readu,1,mpawgrid
close,1
mpawgrid(where(mpawgrid eq 0))=!values.f_nan
mpawcube = reform(mpawgrid,nx,ny,36,11)

openr,1,lfile2
readu,1,lpawgrid2
close,1
lpaw2cube = reform(lpawgrid2,nx,ny,36,11)



out_rl2 = fltarr(720,250,2)
out_rm  = fltarr(720,250,2)
out_l2m = fltarr(720,250,2)
aout_rl2 = fltarr(720,250)

;I masked out the dry season ahead of time
;and these are the seasonal totals
for x = 0, 720-1 do begin &$
  for y = 0, 250-1 do begin &$
    r = total(rpawcube[x,y,*,0:10],3,/nan) &$
    l2 = total(lpaw2cube[x,y,*,*],3,/nan) &$
    m = total(mpawcube[x,y,*,*],3,/nan) &$
     
    rr = r(where(finite(r)))  &$
    ll2 = l2(where(finite(l2))) &$
    mm = m(where(finite(m))) &$
   
    out_rl2[x,y,*] = r_correlate(rr,ll2) &$
    out_rm[x,y,*] = r_correlate(rr,mm) &$
    out_l2m[x,y,*] = r_correlate(ll2,mm) &$
  
    ;anomalies
    ; aout_rl2[x,y] = correlate(rr-mean(rr),ll2-mean(ll2)) &$
           
  endfor &$
endfor

;Figure 3 - soil mositure correaltion
;the plot relevant domain
pmap_ulx = -18.65 & pmap_lrx = 25.85
pmap_uly =  17.65 & pmap_lry =  5.35

ncolors=20
w = WINDOW(WINDOW_TITLE='Plotting Stuff',DIMENSIONS=[500,700])

p1 = image(congrid(out_rl2[*,*,0], gnx*4, gny*4),layout=[1,3,1],image_dimensions=[gNX/10,gNY/10], image_location=[map_ulx,map_lry], $
             dimensions=[gnx,gny], RGB_TABLE=reverse(CONGRID(make_cmap(ncolors),3,256),2), min_value=-1, max_value=1, /CURRENT) &$ 
;p1 = image(mask,layout=[1,5,1],margin=0.1,image_dimensions=[gNX/10,gNY/10], image_location=[map_ulx,map_lry],dimensions=[nx,ny], $
;             RGB_TABLE=4, min_value=-1, max_value=1, /CURRENT, TRANSPARENCY=40)
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
;make this match the landcover map!
p1 = MAP('Geographic',LIMIT = [pmap_lry, pmap_ulx, pmap_uly, pmap_lrx], /overplot) &$
p1.mapgrid.linestyle = 6 &$
p1.mapgrid.label_show = 0
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)
t = TEXT(target=p1, -18, 6, '$\it a) Bucket/Noah$',/DATA, FONT_SIZE=18, fill_background=1, fill_color='light grey')

p1 = image(congrid(out_l2m[*,*,0], gNX*4, gNY*4),layout=[1,3,2], image_dimensions=[gNX/10,gNY/10],  image_location=[map_ulx,map_lry], $
             RGB_TABLE=reverse(CONGRID(make_cmap(ncolors),3,256),2), min_value=-1, max_value=1, /current, location  = [800, 25]) &$ 
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
p1 = MAP('Geographic',LIMIT = [pmap_lry, pmap_ulx, pmap_uly, pmap_lrx], /overplot)
p1.mapgrid.linestyle = 6 &$
p1.mapgrid.label_show = 0
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)
t = TEXT(target=p1, -18, 6, '$\it b) Noah/ECV$',/DATA, FONT_SIZE=18,fill_background=1, fill_color='light grey')

p1 = image(congrid(out_rm[*,*,0], gnx*4, gny*4),layout=[1,3,3],image_dimensions=[gNX/10,gNY/10], image_location=[map_ulx,map_lry], $
  RGB_TABLE=reverse(CONGRID(make_cmap(ncolors),3,256),2), min_value=-1, max_value=1, /current) &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
cb = COLORBAR(TARGET=p1,ORIENTATION=0, title = 'correlation', font_size=16, textpos=0)
p1 = MAP('Geographic',LIMIT = [pmap_lry, pmap_ulx, pmap_uly, pmap_lrx], /overplot)
p1.mapgrid.linestyle = 6 &$
  p1.mapgrid.label_show = 0
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)
t = TEXT(target=p1, -18, 6, '$\it c) Bucket/ECV$',/DATA, FONT_SIZE=18,fill_background=1, fill_color='light grey')
;  
;*********************FIGURE 3 WRSI FIGURES*********************
rfile = file_search('/home/chg-mcnally/EOS_WRSI_ubRFE2001_2012_staticSOS.img')
;l2file = file_search('/home/chg-mcnally/EOS_WRSI_SM0X2_2001_2010_staticSOS.img')
l2file = file_search('/home/sandbox/people/mcnally/SMAP_JHM_PAPER/EOS_WRSI_SM0X2_2001_2010_staticSOS.img')
mfile = file_search('/home/chg-mcnally/EOS_WRSI_MW_2001_2010_staticSOS.img')

nx = 720
ny = 350
nz = 11

l2grid = fltarr(nx,ny,nz)
mgrid = fltarr(nx,ny,nz)
rgrid = fltarr(nx,ny,nz)

openr,1,rfile
readu,1,rgrid
close,1
 
openr,1,l2file
readu,1,l2grid
close,1

openr,1,mfile
readu,1,mgrid
close,1

;what is going on in niger in 2004? this would be a good time to use ENVI
;2001 is the first year. correct?
;***************************************************
;***FIGURE 3 Percent of average map for 2002 **********
w = WINDOW(WINDOW_TITLE='Plotting Stuff',DIMENSIONS=[500,700])
;map_ulx = -20.00 & map_lrx = 52
;map_uly =  20.00 & map_lry = -5

ncolors=20
y = 1 ;1=2002 
;2002 mean
r02 = rgrid[*,0:249,y]/mean(rgrid[*,0:249,0:9], dimension=3, /nan)*100

p1 = image(byte(r02),layout=[1,4,1], image_dimensions=[gNX/10,gNY/10],image_location=[map_ulx,map_lry], $ 
              dimensions=[nx,750], RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), max_value=150, min_value=50, /CURRENT) &$ 
;c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100]) 
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
;p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
p1 = MAP('Geographic',LIMIT = [pmap_lry, pmap_ulx, pmap_uly, pmap_lrx], /overplot)
p1.mapgrid.linestyle = 6 &$
p1.mapgrid.color = [150, 150, 150] &$
p1.mapgrid.label_show = 0 &$
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)
t = TEXT(target=p1, -18, 6, '$\it a) Original WRSI % of normal$',/DATA, FONT_SIZE=18,fill_background=1, fill_color='light grey')


l02 = l2grid[*,0:249,y]/mean(l2grid[*,0:249,0:9], dimension=3, /nan)*100
p1 = image(byte(l02),layout=[1,4,2], image_dimensions=[gNX/10,gNY/10],image_location=[map_ulx,map_lry], $ 
           RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), max_value=150, min_value=50, /CURRENT) &$ 
;c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100]) 
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
p1 = MAP('Geographic',LIMIT = [pmap_lry, pmap_ulx, pmap_uly, pmap_lrx], /overplot)
p1.mapgrid.linestyle = 6 &$
p1.mapgrid.color = [150, 150, 150] &$
p1.mapgrid.label_show = 0 &$
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)
t = TEXT(target=p1, -18, 6, '$\it b) Noah WRSI % of normal$',/DATA, FONT_SIZE=18,fill_background=1, fill_color='light grey')


m02 = mgrid[*,0:249,y]/mean(mgrid[*,0:249,0:9], dimension=3, /nan)*100
p1 = image(byte(m02),layout=[1,4,3],image_dimensions=[gNX/10,gNY/10],image_location=[map_ulx,map_lry], $ 
           RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), max_value=150, min_value=50, /CURRENT) &$ 
;c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100]) 
cb = COLORBAR(TARGET=p1,ORIENTATION=0, title = '% of normal', font_size=16, textpos=0)

rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
p1 = MAP('Geographic',LIMIT = [pmap_lry, pmap_ulx, pmap_uly, pmap_lrx], /overplot)
p1.mapgrid.linestyle = 6 &$
p1.mapgrid.color = [150, 150, 150] &$
p1.mapgrid.label_show = 0 &$
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)
t = TEXT(target=p1, -18, 6, '$\it c) ECV WRSI % of normal$',/DATA, FONT_SIZE=18,fill_background=1, fill_color='light grey')

;;;;;;;;;;;;;;;;;figure 4 time series of niger;;;;;;;;;;;;;;;;;;;;;;;
ifile = file_search('/home/sandbox/people/mcnally/Niger_SM_2001_2010.csv')

indat = read_csv(ifile, n_table_header = 1)

yr = indat.(0)
mw = indat.(1)
rfe = indat.(2)
lis = indat.(3)

mwa = (mw/mean(mw))*100
rfea = (rfe/mean(rfe))*100
lisa = (lis/mean(lis))*100

block = [ transpose(mwa), transpose(rfea), transpose(lisa)] & help, block



;; third plot adding some bells and whistles
tmpplt1 = PLOT(yr,mwa,'-b',THICK=2,NAME='MW-WRSI', $
  TITLE="Southern Niger WRSI 2001-2010", FONT_SIZE=18, $
  YRANGE=[75.,125.], YTITLE = '$WRSI Anomaly $',YTICKFONT_SIZE=10, $
  XRANGE = [MIN(yr),MAX(yr)],XTITLE = 'Year',XTICKFONT_SIZE = 10, $
  /CURRENT)
zeroline = POLYLINE(tmpplt1.XRANGE,[100.0,100.0],'--',COLOR='Gray', $
  TARGET=tmpplt1,/DATA)
  
tmpplt2 = PLOT(yr,rfea,'-g',THICK=2,NAME='Original-WRSI', $
  TITLE="Southern Niger WRSI 2001-2010", FONT_SIZE=18, $
  YRANGE=[75.,125.0],YTITLE = '$WRSI Anomaly $',YTICKFONT_SIZE=10, $
  XRANGE = [MIN(yr),MAX(yr)],XTITLE = 'Year',XTICKFONT_SIZE = 10, $
  /CURRENT, /OVERPLOT)  

tmpplt3 = PLOT(yr,LISa,'-r',THICK=2,NAME='Noah-WRSI', $
  TITLE="Southern Niger WRSI 2001-2010", FONT_SIZE=18, $
  YRANGE=[75.,125.],YTITLE = '$WRSI Anomaly $',YTICKFONT_SIZE=10, $
  XRANGE = [MIN(yr),MAX(yr)],XTITLE = 'Year',XTICKFONT_SIZE = 10, $
  /CURRENT, /OVERPLOT)

  
tmpplt2.font_size=20
tmpplt2.yminor=0
tmpplt2.xminor=1



leg = LEGEND(TARGET=[tmpplt1,tmpplt2,tmpplt3],/DATA, $
  POSITION = [MAX(tmpplt1.XRANGE)-3,MIN(tmpplt1.YRANGE)+0.1])
leg.SHADOW = 0
leg.SAMPLE_WIDTH = .05
leg.HORIZONTAL_ALIGNMENT = 0.0
leg.HORIZONTAL_ALIGNMENT = 'Right'
leg.VERTICAL_ALIGNMENT = 'Bottom'
leg.font_size=20

 
;******plots with yield data. suggested to just show scatters, not map/scatter
;1/31/2014 redid these with the FAO production data. 
;***plot the N-WRSI, R-WRSI for Wankama and Agoufou****
mkfile = file_search('/home/chg-mcnally/WRSI_compare_mask.img')
cfile = file_search('/home/chg-mcnally/cz_mask_sahel.img')

rfile = file_search('/home/chg-mcnally/EOS_WRSI_ubRFE2001_2012_staticSOS.img')
mfile = file_search('/home/chg-mcnally/EOS_WRSI_MW_2001_2010_staticSOS.img')   
l2file = file_search('/home/chg-mcnally/EOS_WRSI_SM0X2_2001_2010_staticSOS.img')

nx = 720
ny = 350
nz = 10

cgrid = fltarr(nx,ny)
mkgrid = fltarr(nx,ny)

rgrid = fltarr(nx,ny,nz)
mgrid = fltarr(nx,ny,nz)
lgrid2 = fltarr(nx,ny,nz)

openr,1,cfile
readu,1,cgrid
close,1
;mask out the wet part of chad
cgrid[*,0:150]=!values.f_nan


;openr,1,mkfile
;readu,1,mkgrid
;close,1

openr,1,mfile
readu,1,mgrid
close,1

openr,1,rfile
readu,1,rgrid
close,1

openr,1,l2file
readu,1,lgrid2
close,1

;crop the cgrid like i did before in the landmask
;FEWS WAfr domain
map_ulx = -18.65 & map_lrx = 25.85
map_uly =  17.65 & map_lry =  5.35
;calculate NX and NY for the crop map..is this right?
culx = (20.+map_ulx)*10. & clrx = (20.+map_lrx)*10.
culy = (5.+map_uly)*10. & clry = (5.+map_lry)*10.
;this is off by one in the y-direction...
cNX = (clrx - culx)
cNY = (culy - clry)

;clip FEWS WA domain from Sahel domain
crop = cgrid

crop(where(crop gt 0))=100

;show the cropped areas by country
;dimensions= specify the window dimensions in pixels
;image dimensions = specify the image dimensions (in data units).
 
;show the cropped areas by country
  p1 = image(crop[*,0:249],image_dimensions=[72.0,25.0], image_location=[-20,-5], $ 
             dimensions=[nx,ny],title = 'crop zones', rgb_table=53) &$ 
  p1 = MAP('Geographic',LIMIT = [5, -18, 17, 25], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1.mapgrid.label_show = 0 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)

;****************looking at countries**6/11/2013, revisit 2/03/2014**************************
;read in yields data 2001-2011 anomalies
;yfile = file_search('/jabber/chg-mcnally/millet_yields_6_11_2013.csv'); these are anomalies.
;see old data in the excel Niger_2005_2008file 

;production stats from FAO:
BF=[1009044.00,  994661.00, 1184283.00 , 937630.00, 1196253.00,  1175040.00,  966016.00,  1255189.00,   970927.00, 1147894.00]
CH=[397608.00,   357425.00, 516341.00 ,  297529.00, 578303.00,   589754.00 ,  495486.00,   523162.00,   550000.00, 600000.00]
MA=[792548.00,   795146.00, 1260498.00 , 974673.00, 1157810.00,  1128773.00, 1175107.00,  1413908.00,  1390410.00,  1373342.00]
NG=[2414394.00,  2504000.00, 2744900.00, 2037700.00,2652400.00, 3008584.00 , 2781928.00,  3521727.00,  2677855.00,  3843351.00]
SG=[556655.00,   414820.00, 628426.00,   323752.00, 608551.00,  494345.00,   318822.00,   678171.00,    810121.00, 813294.98]

;remove trend from yield data...from Greg's code:
yield_mat = transpose([[bf],[ch], [ma],[ng],[sg]]) & help, yield_mat

trend = fltarr(n_elements(yield_mat[*,0]))
yld2 = FLTARR(SIZE(yield_mat,/DIMENSIONS)) * !VALUES.F_NAN

;use the detrended yields instead....detrended & mean zero-ish...but are these the anoms?
for i=0,n_elements(trend)-1 do begin &$
  yrind = WHERE(FINITE(yield_mat[i,*]),count) &$
  trend[i] = REGRESS(yrind,REFORM(yield_mat[i,yrind],count),yfit = tmp_est) &$
  yld2[i,yrind] = yield_mat[i,yrind]/tmp_est &$
endfor

burkina = where(cgrid eq 1, count) & print, count
chad = where(cgrid eq 2, count) & print, count
mali = where(cgrid eq 3, count) & print, count
niger = where(cgrid eq 4, count) & print, count
senegal = where(cgrid eq 5, count) & print, count

;sudan = where(cgrid eq 1005, count) & print, count
;southsudan = where(cgrid eq 1006, count) & print, count ;oops did i not rerun this? ignore sudan for now.
;I just use the 10 years of data...will this change my means?
NigerWRSI   = fltarr(3,10)
SenegalWRSI = fltarr(3,10)
MaliWRSI    = fltarr(3,10)
BurkinaWRSI = fltarr(3,10)
ChadWRSI    = fltarr(3,10)
;rain-WRSI  then NDVI-WRSI
for i = 0,n_elements(nigerWRSI[0,*])-1 do begin &$
    ryrgrid = rgrid[*,*,i] &$
    myrgrid = mgrid[*,*,i] &$    
    l2yrgrid = lgrid2[*,*,i] &$
    
    NigerWRSI[*,i]   =  [mean(ryrgrid(niger), /nan)  ,mean(myrgrid(niger), /nan)  ,mean(l2yrgrid(niger), /nan)  ] &$
    SenegalWRSI[*,i] =  [mean(ryrgrid(senegal), /nan),mean(myrgrid(senegal), /nan),mean(l2yrgrid(senegal), /nan)] &$
    MaliWRSI[*,i]    =  [mean(ryrgrid(mali), /nan)   ,mean(myrgrid(mali), /nan)   ,mean(l2yrgrid(mali), /nan)   ] &$
    BurkinaWRSI[*,i] =  [mean(ryrgrid(burkina), /nan),mean(myrgrid(burkina), /nan),mean(l2yrgrid(burkina), /nan)] &$
    ChadWRSI[*,i]    =  [mean(ryrgrid(chad), /nan)   ,mean(myrgrid(chad), /nan)   ,mean(l2yrgrid(chad), /nan)   ] &$   
endfor;i
;**************burkina faso*************************************

bYIELDanom = yld2[0,*]
bWRSIanom = [BurkinaWRSI[0,*]/mean(BurkinaWRSI[0,*]),  BurkinaWRSI[1,*]/mean(BurkinaWRSI[1,*]), BurkinaWRSI[2,*]/mean(BurkinaWRSI[2,*])]

print, r_correlate(bYIELDanom,bWRSIanom[0,*])
print, r_correlate(bYIELDanom,bWRSIanom[1,*])
print, r_correlate(bYIELDanom,bWRSIanom[2,*])


;***chad*****
cYIELDanom = yld2[1,*]
cWRSIanom = [ChadWRSI[0,*]/mean(ChadWRSI[0,*]),  ChadWRSI[1,*]/mean(ChadWRSI[1,*]), ChadWRSI[2,*]/mean(ChadWRSI[2,*]) ]


print, r_correlate(cYIELDanom,cWRSIanom[0,*])
print, r_correlate(cYIELDanom,cWRSIanom[1,*])
print, r_correlate(cYIELDanom,cWRSIanom[2,*])

;***MALI*****
mYIELDanom = yld2[2,*]
mWRSIanom = [MaliWRSI[0,*]/mean(MaliWRSI[0,*]),  MaliWRSI[1,*]/mean(MaliWRSI[1,*]), MaliWRSI[2,*]/mean(MaliWRSI[2,*]) ]

print, r_correlate(mYIELDanom,mWRSIanom[0,*])
print, r_correlate(mYIELDanom,mWRSIanom[1,*])
print, r_correlate(mYIELDanom,mWRSIanom[2,*])


;****NIGER*******
nYIELDanom = yld2[3,*]
;nWRSIanom = [NigerWRSI[0,*]-mean(NigerWRSI[0,*]),  NigerWRSI[1,*]-mean(NigerWRSI[1,*]), NigerWRSI[2,*]-mean(NigerWRSI[2,*]) ]
;wasn't i looking at percent of normal for the soil moisture plots, i wonder why I did addative anoms here.
nWRSIanom = [NigerWRSI[0,*]/mean(NigerWRSI[0,*]),  NigerWRSI[1,*]/mean(NigerWRSI[1,*]), NigerWRSI[2,*]/mean(NigerWRSI[2,*]) ]


print, r_correlate(nYIELDanom,nWRSIanom[0,*])
print, r_correlate(nYIELDanom,nWRSIanom[1,*])
print, r_correlate(nYIELDanom,nWRSIanom[2,*])

p1=plot(nYIELDanom)
p1=plot(nWRSIanom[1,*], /overplot,'b')

;what if i showed the time series for each country with the uncertainty bounds. 
;I think that i need to go back and perturn the orignial dataset, and then rescale it.

;****SENEGAL******
sYIELDanom = yld2[4,*]
sWRSIanom = [SenegalWRSI[0,*]/mean(SenegalWRSI[0,*]),  SenegalWRSI[1,*]/mean(SenegalWRSI[1,*]), SenegalWRSI[2,*]/mean(SenegalWRSI[2,*])]


print, r_correlate(sYIELDanom,sWRSIanom[0,*])
print, r_correlate(sYIELDanom,sWRSIanom[1,*])
print, r_correlate(sYIELDanom,sWRSIanom[2,*])


;*****************************************************
;ytitle='Yield Anomaly (% of normal)',$
;xtitle = 'WRSI anomaly'

WRSIanom = sWRSIanom
YIELDanom = sYIELDanom
;labels=['01','02','03','04','05', '06','07','08','09','10']
p1 = plot(WRSIanom[0,*],YIELDanom,'o',sym_size=2, name = '  Orig WRSI');
p2 = plot(WRSIanom[1,*],YIELDanom,'go',/overplot, sym_size=2,/SYM_FILLED, $
          yminor=0, xminor=0, name='  MW-WRSI')
p3 = plot(WRSIanom[2,*],YIELDanom,'co',/overplot, sym_size=2,/SYM_FILLED, $
          yminor=0, xminor=0,font_name='times', name='  NOAH-WRSI')  
onelinex = POLYLINE(p3.XRANGE,[1.0,1.0],'--',COLOR='Gray', $
          TARGET=p3,/DATA)  
oneliney = POLYLINE([1.0,1.0],p3.yRANGE,'--',COLOR='Gray', $
          TARGET=p3,/DATA) 
          
      ;YTITLE = '$Global Anomaly (\degC)$'
;p2.xrange=[-10,10]
;p2.yrange=[-3,3]
p1.title = 'Senegal'
p1.font_size = 30
;leg = LEGEND(TARGET=[P1,P2,P3],  FONT_SIZE=14, SAMPLE_WIDTH=0,shadow=0,linestyle=6) ;
;leg.HORIZONTAL_ALIGNMENT = 'Right'
;leg.VERTICAL_ALIGNMENT = 'Bottom'

;Senegal
p3=plot([1,1],[0.7,1.2],/overplot)
p3=plot([0.7,1.2],[1,1],/overplot)

;niger
p3=plot([1,1],[0.4,1.4],/overplot);x
p3=plot([0.7,1.2],[1,1],/overplot);y

;Mali, BF
p3=plot([1,1],[0.6,1.4],/overplot, /CURRENT);x
p3=plot([0.9,1.05],[1,1],/overplot);y


;**********Orange-green WRSI FIGURE PANEL***********
;.compile /home/source/mcnally/scripts_idl/make_wrsi_cmap.pro
;
;ncolors=256
;p1 = image(byte(rgrid[*,0:249,4]),layout=[1,4,1], image_dimensions=[72.0,25.0], image_location=[-20,-5], $
;              dimensions=[nx,750], RGB_TABLE=make_wrsi_cmap()) &$
;t = TEXT(target=p1, -18, 1, '$\it a) Original (bucket) WRSI$',/DATA, FONT_SIZE=18)
;;c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
;rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
;rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
;rgbdump[*,0] = [200,200,200]
;p1.rgb_table = rgbdump  ; reassign the colorbar to the image
;p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
;p1.mapgrid.linestyle = 6 &$
;p1.mapgrid.color = [150, 150, 150] &$
;p1.mapgrid.label_show = 0 &$
;p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)
;
;p1 = image(byte(l2grid[*,0:249,4]),layout=[1,4,2], image_dimensions=[72.0,25.0], image_location=[-20,-5], $
;           RGB_TABLE=make_wrsi_cmap(), /CURRENT) &$
;t = TEXT(target=p1, -18, 1, '$\it b) Noah (0-40cm) WRSI$',/DATA, FONT_SIZE=18)
;;c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
;rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
;rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
;rgbdump[*,0] = [200,200,200]
;p1.rgb_table = rgbdump  ; reassign the colorbar to the image
;p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
;p1.mapgrid.linestyle = 6 &$
;p1.mapgrid.color = [150, 150, 150] &$
;p1.mapgrid.label_show = 0 &$
;p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)
;
;
;p1 = image(byte(mgrid[*,0:249,4]),layout=[1,4,3], image_dimensions=[72.0,25.0], image_location=[-20,-5], $
;           RGB_TABLE=make_wrsi_cmap(), /CURRENT) &$
;t = TEXT(target=p1, -18, 1, '$\it c) ECV microwave WRSI$',/DATA, FONT_SIZE=18)
;c = COLORBAR(ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
;rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
;rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
;rgbdump[*,0] = [200,200,200]
;p1.rgb_table = rgbdump  ; reassign the colorbar to the image
;p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
;p1.mapgrid.linestyle = 6 &$
;p1.mapgrid.color = [150, 150, 150] &$
;p1.mapgrid.label_show = 0 &$
;p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)


;p1 = image(congrid(out_l2m, gNX*4, gNY*4),layout=[1,3,3], image_dimensions=[gNX/10,gNY/10],  image_location=[map_ulx,map_lry], $
;  RGB_TABLE=reverse(CONGRID(make_cmap(ncolors),3,256),2), min_value=-1, max_value=1, /current, location  = [800, 25]) &$
;  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
;  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
;  rgbdump[*,0] = [200,200,200]
;p1.rgb_table = rgbdump  ; reassign the colorbar to the image
;cb = COLORBAR(TARGET=p1,ORIENTATION=0, title = 'correlation', font_size=16, textpos=0)
;p1 = MAP('Geographic',LIMIT = [pmap_lry, pmap_ulx, pmap_uly, pmap_lrx], /overplot)
;p1.mapgrid.linestyle = 6 &$
;  p1.mapgrid.label_show = 0
;p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)
;t = TEXT(target=p1, -18, 6, '$\it c) Noah/ECV$',/DATA, FONT_SIZE=18,fill_background=1, fill_color='light grey')


;**********perturbation plots*****************
;the mean of these should be the orange-green WRSI map (check this)
;1. generate 100 soil moistures for 2002 and 2005 for MW and Noah
;2. run the WRSI for these two years x 100 simulations
;3. map the mean and percentiles


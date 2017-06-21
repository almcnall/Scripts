;the purpose of this script is to make the plots for the paper.
;KLEE 10/5/2011 - 11/14/2012 (Octdek1-Nov dek2) or one?
;COSMOS_50=MPALA 9/6/2011 (Sept dek1) - 10/27/2012 (Oct dek3)

;****************************************************************
;making a cute map of niger and the sites see:
;file:///usr/local/itt/idl/idl80/help/online_help/IDL/Content/GuideMe/text_annotations.html#Map

small_pos = [0.14,0.65,0.36,0.95]
othermap = map('Geographic',LIMIT=[-45,-25,55,65],POSITION=small_pos,/CURRENT)
grid2 = othermap.mapgrid
grid2.hide = 1
m3 = MAPCONTINENTS(/COUNTRIES)
m3['Niger'].FILL_COLOR = 'dark gray'
m3['Kenya'].FILL_COLOR = 'dark gray'
m_outline = POLYGON([small_pos[0],small_pos[0],small_pos[2],small_pos[2]], $
[small_pos[3],small_pos[1],small_pos[1],small_pos[3]],/NORMAL,LINESTYLE=0, $
   FILL_BACKGROUND=0)

; i think you need to click on the graphic window at this point, deactivating all graphics
m = map('Geographic',LIMIT=[11.,0.,24.,17.], /CURRENT); bottom,left,top,right 
;m = map('Geographic',LIMIT=[10.,0.,25.,20.])
grid = m.mapgrid
grid.linestyle = 6
grid.label_position = 0
grid.FONT_SIZE = 14
m2 = MAPCONTINENTS(/COUNTRIES,/HIDE)
m2['Niger'].HIDE = 0
m2['Niger'].FILL_COLOR = 'light gray'

; Label the state of Texas.==how am i supposed to know the positioning?

texas = TEXT(6, 16, /DATA, 'Niger', FONT_SIZE = 50,/CURRENT) ;then this is x,y
star = TEXT(2.6, 13.6, /DATA, '*', $
       FONT_SIZE=32, FONT_STYLE='Bold', $
       FONT_COLOR='yellow')
label = TEXT(2.6, 14.7, /DATA, $
       'Wankama', FONT_STYLE='Italic')

star = TEXT(2.7, 13.5, /DATA, '*', $
       FONT_SIZE=32, FONT_STYLE='Bold', $
       FONT_COLOR='yellow')
label = TEXT(2.7, 13.3, /DATA, $
       'Tondi Kiboro', FONT_STYLE='Italic')
      
      
; And now for Kenya
m = map('Geographic',LIMIT=[-5.,33.,5.,43.]); bottom,left,top,right 
grid = m.mapgrid
grid.linestyle = 6
grid.label_position = 0
grid.FONT_SIZE = 14
m2 = MAPCONTINENTS(/COUNTRIES,/HIDE)
m2['Kenya'].HIDE = 0
m2['Kenya'].FILL_COLOR = 'light gray'

; Label the state of Texas.==how am i supposed to know the positioning?

texas = TEXT(36, 2.5, /DATA, 'Kenya', FONT_SIZE = 50,/CURRENT) ;then this is x,y in data corrds
star = TEXT(37, 0.5, /DATA, '*', $
       FONT_SIZE=32, FONT_STYLE='Bold', $
       FONT_COLOR='yellow')
label = TEXT(37.5, 1, /DATA, $
       'Mpala', FONT_STYLE='Italic')

star = TEXT(37, 0.28, /DATA, '*', $
       FONT_SIZE=32, FONT_STYLE='Bold', $
       FONT_COLOR='yellow')
label = TEXT(37, 0, /DATA, $
       'KLEE', FONT_STYLE='Italic')



;;************FIGURE 1 ******************************************************

ifile = file_search('/jabber/chg-mcnally/AMMASOIL/observed_TKWK1WK2.csv')
soil = read_csv(ifile)
wk140 = float(soil.field1)
wk170 = float(soil.field2) ;the weird one
wk240 = float(soil.field3) 
wk270 = float(soil.field4) 
tk40 = float(soil.field5) 
tk70 = float(soil.field6)
avg144 = mean([transpose(wk140),transpose(wk170),transpose(wk240), transpose(wk270), transpose(tk40), transpose(tk70)],$
              /nan, dimension = 1)

avgwk140 = mean(reform(wk140,36,4), dimension = 2,/nan)
avgwk170 = mean(reform(wk170,36,4), dimension = 2,/nan)
avgwk240 = mean(reform(wk240,36,4), dimension = 2,/nan)
avgwk270 = mean(reform(wk270,36,4), dimension = 2,/nan)
avgtk40 = mean(reform(tk40,36,4), dimension = 2,/nan)
avgtk70 = mean(reform(tk70,36,4), dimension = 2,/nan)

;instead of colors i need to use different linestyles e.g. 
;p2 = PLOT(months, temp08, '--+2g', /OVERPLOT)
p1 = plot(avgwk140, thick = 3, 'r', font_size = 20, name = 'Wk1 40cm')
p2 = plot(avgwk170, thick = 3, /overplot, 'r', linestyle = 2, name = 'Wk1 70cm')
p3 = plot(avgwk240, thick = 3, /overplot,'b', name = 'Wk2 40cm')
p4 = plot(avgwk270, thick = 3, /overplot,'b', linestyle = 2, name = 'Wk1 70cm')
p5 = plot(avgtk40, thick = 3, /overplot,'g', name = 'TK 40cm')
p6 = plot(avgtk70, thick = 3, /overplot,'g', linestyle = 2, name = 'TK 70cm')
p4.title = 'Average dekadal soil mositure 2005-2008 '
p4.ytitle = 'soil moisture (mm)'
p4.xminor = 0
p4.yminor = 0
p4.xrange = [10, 35]
p4.xtickvalues = [10+2, 15+2, 20+2, 25+2, 30+2]
xticks = ['21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov']
p4.xtickname = xticks
p4.title.font_size = 24
null = legend(target=[p1,p2,p3,p4,p5,p6], position=[0.2,0.3],font_size=16) 

;******************FIGURE 2********************************************************
nfile = file_search('/jabber/chg-mcnally/AMMAVeg/avergeNDVI_WK12MF_TK.csv')
ifile = file_search('/jabber/chg-mcnally/AMMASOIL/observed_TKWK1WK2.csv')
ffile = file_search('/jabber/chg-mcnally/AMMASOIL/filteredNDVI_WK12TK.csv')
ndvi = read_csv(nfile)
soil = read_csv(ifile)
filter = read_csv(ffile)

wk1 = ndvi.field1
wk2 = ndvi.field3
tk = ndvi.field5
navg144 = mean([transpose(wk1), transpose(wk2), transpose(tk)], /nan, dimension = 1)
navg = mean(reform(navg144, 36,4), dimension = 2, /nan)

wk140 = float(soil.field1)
wk170 = float(soil.field2)
wk240 = float(soil.field3) 
wk270 = float(soil.field4) 
tk40 = float(soil.field5) 
tk70 = float(soil.field6)             
savg144 = mean([transpose(wk140), transpose(wk170), transpose(wk240), transpose(wk270),$
             transpose(tk40), transpose(tk70)], dimension = 1, /nan)

savg = reform(mean([transpose(wk140), transpose(wk170), transpose(wk240), transpose(wk270),$
             transpose(tk40), transpose(tk70)], dimension = 1, /nan),36,4)
savg = mean(savg,dimension = 2, /nan)   

p2 = plot(navg, thick = 3, 'g', name = 'NDVI', /overplot, $)
         xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'],$
         MARGIN = [0.15,0.2,0.15,0.1], $
         AXIS_STYLE=0, yminor = 0)
yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='NDVI', $
       TEXTDIR=0, TEXTPOS=1,font_size=16, yminor = 0, tickpos = 0)
p1 = plot(savg, thick = 3, 'orange', name = 'SM', xminor = 0, yminor = 0, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
         xtickname = ['11-Jan', '01-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'],$
         YTITLE='SM',AXIS_STYLE=1,/CURRENT,/NOERASE)
p3 = plot(filter.field1, thick = 3, linestyle = 2, 'g',name ='SM estimate', /overplot,tickpos=0)
lgr2 = LEGEND(TARGET=[p1, p2, p3], font_size=16)
p1.xtickfont_size = 16
p1.ytickfont_size = 16
p1.ytitle='soil moisture (mm)'

yfit = filter.field1
print, 100*(1-norm(savg-yfit)/norm(savg-mean(yfit, /nan))) ;why is it 72 here and 88 elsewhere

;******************FIGURE 3***********************************
;**********fit the longer time series************************
ffile = file_search('/jabber/chg-mcnally/AMMASOIL/filteredNDVI_WK12TK144.csv')
ifile = file_search('/jabber/chg-mcnally/AMMASOIL/observed_TKWK1WK2.csv')

soil = read_csv(ifile)
filter144 = read_csv(ffile)

wk140 = float(soil.field1)
wk170 = float(soil.field2)
wk240 = float(soil.field3) 
wk270 = float(soil.field4) 
tk40 = float(soil.field5) 
tk70 = float(soil.field6)  

savg144 = mean([transpose(wk140), transpose(wk170), transpose(wk240), transpose(wk270),$
             transpose(tk40), transpose(tk70)], dimension = 1, /nan)
est = filter144.field1

xticks = ['Jun-05','Jun-06','Jun-07','Jun-08']
p1 = plot(est, thick = 3, name = 'SM estimate', xminor = 0, yminor = 0,xrange = [0,144], $
 xtickvalues = [ 18, 54, 90, 126  ], xtickinterval = 36 ,font_size = 14, linestyle = 2)
 p1.xtickname= xticks
p1.xtickfont_size = 24
p1.ytickfont_size = 18
p2 = plot(savg144, thick = 2, name = 'observed SM', 'b', /overplot)
null = legend(target=[p1,p2], position=[0.2,0.3], font_size=18) ;
p1.ytitle = 'soil moisture (mm)'
;******************************************************************************************
;*****FIGURE 4 fit for the API************************
ifile = file_search('/jabber/chg-mcnally/AMMASOIL/observed_TKWK1WK2.csv')
afile = file_search('/jabber/chg-mcnally/AMMASOIL/API_ubrf_niger')

soil = read_csv(ifile)
api = read_csv(afile)

api = api.field1

wk140 = float(soil.field1)
wk170 = float(soil.field2)
wk240 = float(soil.field3) 
wk270 = float(soil.field4) 
tk40 = float(soil.field5) 
tk70 = float(soil.field6)  

savg144 = mean([transpose(wk140), transpose(wk170), transpose(wk240), transpose(wk270),$
             transpose(tk40), transpose(tk70)], dimension = 1, /nan)


xticks = ['Jun-05','Jun-06','Jun-07','Jun-08']
p1 = plot(api, thick = 3, name = 'ubrfe API', xminor = 0, yminor = 0,xrange = [0,144], $
          xtickvalues = [ 18, 54, 90, 126  ], xtickinterval = 36 ,font_size = 14, linestyle = 2)
p1.xtickname= xticks
p1.xtickfont_size = 24
p1.ytickfont_size = 18
p2 = plot(savg144, thick = 2, name = 'observed SM', 'b', /overplot)
null = legend(target=[p1,p2], position=[0.2,0.3], font_size=18) ;
p1.ytitle = 'soil moisture (mm)'

print, correlate(api, avg144)
p3 = plot(avg144, api,'*')
 print, 100*(1-norm(API-savg144)/norm(API-mean(savg144, /nan)))

;*******FIGURE 5/MAP 1 average soil moisture est from NDVI*************
;might want to update this to the one that goes to 2012>filterNDVI_soilmoisture_200101_2012.10.3.img
;nfile = file_search('/jabber/chg-mcnally/filterNDVI_soilmoisture_2001_2011.img');cube of filtered NDVI
nfile = file_search('/jabber/chg-mcnally/filterNDVI_soilmoisture_200101_2012.10.2.img');cube of filtered NDVI

nx = 720
ny = 350
nz = 425 ;396 ;this will be bigger with new file...425

filtered = fltarr(nx,ny,nz-6)
openr,1,nfile
readu,1,filtered
close,1

cap = where(filtered gt 0.15, count) & print, count
filtered(cap) = !values.f_nan
p1 = image(mean(filtered, dimension = 3, /nan), image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 20)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

;****FIGURE 6 average API map************************************
;might want to update this to the one that goes to 2012> sahel_API_200101_201232.img
;ifile = file_search('/jabber/chg-mcnally/API_soilmoisture_2001_2011.img')
ifile = file_search('/jabber/chg-mcnally/sahel_API_200101_201232.img')

nx = 720
ny = 350
nz = 428 ;396;this will be bigger with new file...428

apigrid = fltarr(nx,ny,nz)
openr,1,ifile
readu,1,apigrid
close,1
cap = where(apigrid gt 0.15, count) & print, count
apigrid(cap) = !values.f_nan
p1 = image(mean(apigrid,dimension = 3, /nan), image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 20)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  p1.title = 'Avg API'
  
;*****FIGURE 7 API-NDVI-SM correlation map***********
;cfile = file_search('/jabber/chg-mcnally/filterNDVI_APIcorr.img')
;I should find out what correlation is signficant and mask or set range accordingly. 
cfile = file_search('/jabber/chg-mcnally/filterNDVI_APIcorr_200101_201232.img')
nx = 720
ny = 350

ANcorr = fltarr(nx,ny)
;read in API-NDVI correlation
openr,1,cfile
readu,1,ANcorr
close,1
p1 = image(ANcorr, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 20)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  
 ;***************figure 8 precip-NDVI correlation Nicholson*******
 ;pretty sure this has not been re-done with 2012 data (12/14/12)
nichol = file_search('/jabber/chg-mcnally/NDVI_UBRFcorr.img') ;correlation between 8dek rain and NDVI
nx = 720
ny = 350
PNcorr = fltarr(nx,ny)
;read in Precip-NDVI correlation
openr,1,nichol
readu,1,PNcorr
close,1
p1 = image(PNcorr, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 20)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  
;********FIGURE 9 pull the klee and mpala sites from the ndvi filter and API maps******
;KLEE 10/5/2011 - 11/14/2012 (Octdek1-Nov dek2) or one?
;COSMOS_50=MPALA 9/6/2011 (Sept dek1) - 10/27/2012 (Oct dek3)
afile = file_search('/jabber/chg-mcnally/sahel_API_200101_201232.img')
ffile = file_search('/jabber/chg-mcnally/filterNDVI_soilmoisture_200101_2012.10.2.img')
kfile = file_search('/jabber/chg-mcnally/AMMASOIL/KLEE_dekad.csv')
mfile = file_search('/jabber/chg-mcnally/AMMASOIL/Mpala_dekad.csv')

nx = 720
ny = 350
nz = 428
nnz = 425

apigrid = fltarr(nx,ny,nz)
filter  = fltarr(nx,ny,nnz);this should be 426 no? or 425...why is it 424?
cormap = fltarr(nx,ny)

openr,1,afile
readu,1,apigrid
close,1

openr,1,ffile
readu,1,filter
close,1

apipad = fltarr(nx,ny,4)
apipad[*,*,*] = !values.f_nan
apifull = [[[apigrid]],[[apipad]]]
;apifull = apifull - mean(apifull,/nan)

filterpad = fltarr(nx,ny,7)
filterpad[*,*,*] = !values.f_nan
filterfull = [[[filter]],[[filterpad]]]
;filterfull = filterfull - mean(filterfull,/nan)

result = read_csv(mfile)
mpala = float(result.field1)
;mpalaN = float(result.field1)-mean(float(result.field1), /nan)
mpalaN = mpala

result = read_csv(kfile)
KLEE = float(result.field1)
KLEEN = float(result.field1)-mean(float(result.field1), /nan)

;Mpala Kenya:
mxind = FLOOR((36.8701 + 20.) / 0.10)
myind = FLOOR((0.4856 + 5) / 0.10)

;;KLEE Kenya
kxind = FLOOR((36.8669 + 20.) / 0.10)
kyind = FLOOR((0.2825 + 5) / 0.10)

;
;**********************the KLEE DATA************************************
xticks = ['oct-11','dec-11','feb-12','apr-12', 'jun-12','aug-12','oct-12']
;p3 = plot(KLEE,thick = 3,name = 'observ',/overplot,  $
;         MARGIN = [0.15,0.2,0.15,0.1], $
;         xtickvalues = [0,  6,  12,  18,  24,  30,  36], $
;         xtickname = xticks,$
;         AXIS_STYLE=0, yminor = 0,/CURRENT,/NOERASE)
;yax2 = AXIS('Y',LOCATION=[MAX(p3.xrange),0],TITLE='obs (VWC %)', $
;       TEXTDIR=0, TEXTPOS=1,YCHARSIZE=14)
p1 = plot(apifull[kxind,kyind,360+27:431-4]*100, thick = 3,  name = 'API',$
         xminor = 0, yminor = 0, linestyle = 2, 'orange', $
         MARGIN = [0.15,0.2,0.15,0.1], $
          xtickvalues = [0,  6,  12,  18,  24,  30,  36], $
         xtickname = xticks,$
         YTITLE='% volumetric SM',AXIS_STYLE=1)
         ;YTITLE='API & SM est',AXIS_STYLE=1,/CURRENT,/NOERASE)
p2 = plot(filterfull[kxind,kyind,360+27:431-4]*100, thick = 3, linestyle = 2,$
          'g', name='SM est from NDVI', /overplot)
p3 = plot(KLEE[27:67]-23.9, thick = 3,name = 'observ - WP',/overplot)

p1.xtickfont_size = 18
p1.ytickfont_size = 18
p1.title = 'Observed and estimated soil moisture at KLEE'
p1.title.font_size = 24 
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) ;
;             
;k = 0 ;@ KLEE
;print, 100*(1-norm((k+kleeN[27:67]/100)-filterfull[kxind,kyind,360+27:431-4])/norm((k+kleeN[27:67]/100)$
;             -mean(filterfull[kxind,kyind,360+27:431-4], /nan))) ;18
;print, 100*(1-norm((k+kleeN[27:67]/100)-apifull[kxind,kyind,360+27:431-4])/norm((k+kleeN[27:67]/100)$
;             -mean(apifull[kxind,kyind,360+27:431-4], /nan))) ;15

;turns out since these do have the same units they should be on the same scale...

;*******************the Mpala DATA*************************************
;xticks = ['sept-11','nov-11','jan-12','mar-12', 'may-12','jul-12','sept-12']
xticks = ['oct-11','dec-11','feb-12','apr-12', 'jun-12','aug-12','oct-12']
xvals = [0+3,  6+3,  12+3,  18+3,  24+3,  30+3,  36+3]

p1 = plot(apifull[mxind,myind,360+24:431-6]*100, thick = 3,  name = 'API', $
         xminor = 0, yminor = 0, linestyle = 2, 'orange', $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = xvals, $
         xtickname = xticks,$
         YTITLE='% volumetric SM',AXIS_STYLE = 1)
p2 = plot(filterfull[mxind,myind,360+24:431-6]*100, thick = 3, linestyle = 2, $
          'g', name='SM est from NDVI', /overplot)
p3 = plot(Mpala[24:65]-2,thick = 3,name = 'observ - WP',/overplot)  

p1.xtickfont_size = 16
p1.ytickfont_size = 18
yax2.font_size = 18
p1.title = 'Observed and estimated soil moisture at Mpala'
p1.title.font_size = 24 
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) ;

print, 100*(1-norm((mpala[24:65]-2)-apifull[mxind,myind,360+24:431-6]*100)/norm((mpala[24:65]-2)$
             -mean((apifull[mxind,myind,360+24:431-6]*100), /nan))) ;16
print, 100*(1-norm((mpala[24:65]-2)-filterfull[mxind,myind,360+24:431-6]*100)/norm((Mpala[24:65]-2)$
             -mean((filterfull[mxind,myind,360+24:431-6]*100), /nan))) ;42

;******FIGURE 10--plot of refit Mpala*************************** 
afile = file_search('/jabber/LIS/Data/ubRFE2/dekads/horn_API_2001_2012MP.img')
ffile = file_search('/jabber/chg-mcnally/filterNDVI_soilmoisture_2001_2012_Mpala.img')
kfile = file_search('/jabber/chg-mcnally/AMMASOIL/KLEE_dekad.csv')
mfile = file_search('/jabber/chg-mcnally/AMMASOIL/Mpala_dekad.csv')

nx = 250
ny = 350
anz = 428
nnz = 425

apigrid = fltarr(nx,ny,anz)
filter  = fltarr(nx,ny,nnz);this should be 426 no? or 425...why is it 424?
cormap = fltarr(nx,ny)

openr,1,afile
readu,1,apigrid
close,1

openr,1,ffile
readu,1,filter
close,1

apipad = fltarr(nx,ny,4)
apipad[*,*,*] = !values.f_nan
apifull = [[[apigrid]],[[apipad]]]
;apifull = apifull - mean(apifull,/nan)

filterpad = fltarr(nx,ny,7)
filterpad[*,*,*] = !values.f_nan
filterfull = [[[filter]],[[filterpad]]]
;filterfull = filterfull - mean(filterfull,/nan)

result = read_csv(mfile)
mpala = float(result.field1)
;mpalaN = float(result.field1)-mean(float(result.field1), /nan)

result = read_csv(kfile)
KLEE = float(result.field1)
;KLEEN = float(result.field1)-mean(float(result.field1), /nan)

mxind = FLOOR((36.8701 - 27.) / 0.10)
myind = FLOOR((0.4856 + 5) / 0.10)

;KLEE
kxind = FLOOR((36.8669 - 27.) / 0.10)
kyind = FLOOR((0.2825 + 5) / 0.10)


xticks = ['oct-11','dec-11','feb-12','apr-12', 'jun-12','aug-12','oct-12']
p1 = plot(apifull[kxind,kyind,360+27:431-4], thick = 3,  name = 'API',$
         xminor = 0, yminor = 0, linestyle = 2, 'orange', $
         MARGIN = [0.15,0.2,0.15,0.1], $
          xtickvalues = [0,  6,  12,  18,  24,  30,  36], $
         xtickname = xticks,$
         YTITLE='% volumetric SM',AXIS_STYLE=1)
p2 = plot(filterfull[kxind,kyind,360+27:431-4], thick = 3, linestyle = 2,$
          'g', name='SM est from NDVI', /overplot)
p3 = plot(KLEE[27:67]-22, thick = 3,name = 'observ',/overplot)

p1.xtickfont_size = 18
p1.ytickfont_size = 18
p1.title = 'Observed and estimated soil moisture at KLEE (Mpala refit)'
p1.title.font_size = 24 
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) ;



;*******************the Mpala DATA*************************************
xticks = ['oct-11','dec-11','feb-12','apr-12', 'jun-12','aug-12','oct-12']
xvals = [0+3,  6+3,  12+3,  18+3,  24+3,  30+3,  36+3]

p1 = plot(apifull[mxind,myind,360+24:431-6], thick = 3,  name = 'API', $
         xminor = 0, yminor = 0, linestyle = 2, 'orange', $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = xvals, $
         xtickname = xticks,$
         YTITLE='% volumetric SM',AXIS_STYLE = 1)
p2 = plot(filterfull[mxind,myind,360+24:431-6], thick = 3, linestyle = 2, $
          'g', name='SM est from NDVI', /overplot)
p3 = plot(Mpala[24:65],thick = 3,name = 'observ',/overplot)  
p1.xtickfont_size = 16
p1.ytickfont_size = 18
p1.title = 'Observed and estimated soil moisture at Mpala (Mpala refit)'
p1.title.font_size = 24 
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) ;

print, 100*(1-norm((mpala[24:65])-apifull[mxind,myind,360+24:431-6])/norm((mpala[24:65])$
             -mean((apifull[mxind,myind,360+24:431-6]), /nan))) ;43.1682
print, 100*(1-norm((mpala[24:65])-filterfull[mxind,myind,360+24:431-6])/norm((Mpala[24:65])$
             -mean((filterfull[mxind,myind,360+24:431-6]), /nan))) ;44.46
         

;*********************FIGURE 11********************************************************
;********new correlation map between filtered NDVI (fit to Mpala) and API(fit to Mpala)
afile = file_search('/jabber/LIS/Data/ubRFE2/dekads/horn/horn_API_2001_2012vMpala3v2.img')
nfile = file_search('what happened to the rest of this??')


;*******************FIGURE 1 on PAPER 2*****************************************
; FIGURE 1 for paper #2 
;************make cummulative precip at a point*****************************
;;orginal file made in 
rfile = file_search('/jabber/chg-mcnally/AMMARain/RFE_UBRFE_and_station_dekads.csv')
wfile = file_search('/jabber/chg-mcnally/AMMARain/wankamaWest_station_dekads.csv')
west = read_csv(wfile)
rain = read_csv(rfile)

;first cube into years
RFE = transpose(reform(rain.field1,36,4))
UBRFE = transpose(reform(rain.field2,36,4))
station = transpose(reform(rain.field3,36,4))
wstation = transpose(reform(west.field1,36,4))

rain = wstation

cum = fltarr(4,36)
for y = 0,n_elements(RFE[*,0])-1 do begin &$
  for i = 0,n_elements(RFE[0,*])-1 do begin &$
    cum[y,0] = rain[y,0] &$
    cum[y,i] = cum[y,i-1] + rain[y,i] &$
  endfor &$
endfor  

thick = 3
size = 14
yrange = [0,600]
;useful to use the rainfall stations since they should match soil best
temp1 = plot(cum[0,*],'r', layout = [3,1,3], thick = thick, name = '2005', /CURRENT)
temp2 = plot(cum[1,*],'orange', /overplot, thick = thick, name = '2006')
temp3 = plot(cum[2,*],'green', /overplot, thick = thick, name = '2007')
temp4 = plot(cum[3,*],'blue', /overplot, yrange = yrange,xtickfont_size = size, $
             ytickfont_size = size, thick = thick, name = '2008')

lgr2 = LEGEND(TARGET=[temp1, temp2, temp3, temp4])
temp1.title = 'Stations'
temp1.title.font_size = 14
;use these for wankama west
temp5 = plot(cum[0,*],'r', linestyle=2,/overplot)
temp6 = plot(cum[1,*],'orange', /overplot,linestyle=2)
temp7 = plot(cum[2,*],'green', /overplot,linestyle=2)
temp8 = plot(cum[3,*],'blue', /overplot,linestyle=2)

;******rainfall compare plot for SOS and WRSI***paper 2*******
;*****Get rainfall********rfe, ubrfe, sta from Wankama East
ifile = file_search('/jabber/chg-mcnally/AMMARain/RFE_UBRFE_and_station_dekads.csv')
wfile = file_search('/jabber/chg-mcnally/AMMARain/wankamaWest_station_dekads.csv')
west = read_csv(wfile)
rain = read_csv(ifile) 

ubrf = reform(rain.field2,36,4)
rfe2 = reform(rain.field1,36,4)
sta  = reform(rain.field3,36,4)
wsta = reform(west.field1,36,4)
avgsta = [[rain.field3],[west.field1]]
avgsta = reform(mean(avgsta,dimension=2,/nan),36,4)

ubrf = rain.field2
rfe2 = rain.field1
avgsta = [[rain.field3],[west.field1]]
avgsta = mean(avgsta,dimension=2,/nan)

xticks = ['2005','2006','2007','2008']
p1 = plot(avgsta, name = 'sta avg', thick = 3)
;p2 = plot(sta[*,3], 'b', /overplot, name = 'east', thick =3)
p3 = plot(rfe2,'g', /overplot, name = 'rfe2', thick = 3)
p4 = plot(ubrf, 'm', /overplot, name = 'ubrf', thick = 3, $
          xtickvalues = [18, 54, 90, 126], xtickinterval = 36)
p1.xtickname = xticks
p1.xtickfont_size = 24
p1.ytickfont_size = 18
lgr2 = LEGEND(TARGET = [p1, p3, p4])
p1.title = '2005-2008 Wankama'
p1.title.font_size = 16
p1.ytitle = '(mm)'

p1 = plot(wsta[*,3])
p2 = plot(sta[*,3], 'b', /overplot)
p2.title = '2008'







           


;********read in the UB RFE-API and filtered NDVI data *************
;ifile = file_search('/jabber/LIS/Data/API_sahel/APIsahel_*') ;individual ubrfe API files (not pre-stacked)
ifile = file_search('/jabber/chg-mcnally/API_soilmoisture_2001_2011.img')
vfile = file_search('/jabber/chg-mcnally/AMMAVeg/mask_bare75_sahel.img') ;bare soil mask
nfile = file_search('/jabber/chg-mcnally/filterNDVI_soilmoisture_2001_2011.img');cube of filtered NDVI
cfile = file_search('/jabber/chg-mcnally/filterNDVI_APIcorr.img') ;correlation between API and filtered NDVI
nichol = file_search('/jabber/chg-mcnally/NDVI_UBRFcorr.img') ;correlation between 8dek rain and NDVI
rfile = file_search('/jabber/chg-mcnally/FCLIMshael_rainmask4NDVI.img') ;masks 150-1200m of rainfall

nx = 720
ny = 350
nz = 396

apigrid = fltarr(nx,ny,nz-2)
filtered = fltarr(nx,ny,nz-6)
vegmask = fltarr(nx,ny)
ANcorr = fltarr(nx,ny)
PNcorr = fltarr(nx,ny)
rmask = intarr(nx,ny)

;read in veg mask and filteredNDVI outside o' loop
openr,1,vfile
readu,1,vegmask
close,1
vegmask(where(vegmask eq 0.))=!values.f_nan

;readin rain mask
openr,1,rfile
readu,1,rmask
close,1
rmask= float(rmask)
out = where(rmask eq 0)
rmask(out)=!values.f_nan
;read in API-NDVI correlation
openr,1,cfile
readu,1,ANcorr
close,1

;read in Precip-NDVI correlation
openr,1,nichol
readu,1,PNcorr
close,1

openr,1,nfile
readu,1,filtered
close,1

openr,1,ifile
readu,1,apigrid
close,1

;********************************************************************************

;plot the average NDVI and rainfall (stations and 250m too! just so i know how they vary)
; these axis are going to be unpleasent, no?
;rfile = file_search('/jabber/Data/mcnally/AMMARain/RFE_UBRFE_and_station_dekads.csv')
;rain = read_csv(rfile)
;ubrf = rain.field2
;ubrf = mean(reform(ubrf,36,4),dimension=2, /nan)

nfile = file_search('/jabber/chg-mcnally/AMMAVeg/avergeNDVI_WK12MF_TK.csv')
ndvi = read_csv(nfile)

wk1 = ndvi.field1
wk2 = ndvi.field3
tk = ndvi.field5
navg144 = mean([transpose(wk1), transpose(wk2), transpose(tk)], /nan, dimension = 1)
navg = mean(reform(navg144, 36,4), dimension = 2, /nan)
;from figure 1.....
savg144 = mean([transpose(wk140), transpose(wk170), transpose(wk240), transpose(wk270),$
             transpose(tk40), transpose(tk70)], dimension = 1, /nan)
savg = reform(mean([transpose(wk140), transpose(wk170), transpose(wk240), transpose(wk270),$
             transpose(tk40), transpose(tk70)], dimension = 1, /nan),36,4)
savg = mean(savg,dimension = 2, /nan)   

p2 = plot(savg, thick = 3, 'orange', name = 'soil moisture', /overplot, $)
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'],$
         AXIS_STYLE=0, yminor = 0)
yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='Average SM (mm)', $
       TEXTDIR=0, TEXTPOS=1,YCHARSIZE=14)
p1 = plot(navg, thick = 3, 'g', name = 'ndvi', xminor = 0, yminor = 0, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'],$
         YTITLE='NDVI',AXIS_STYLE=1,/CURRENT,/NOERASE)
lgr2 = LEGEND(TARGET=[p1, p2])
p2.yminor = 0
p1.xtickfont_size=14
p1.ytickfont_size=16

;now regress them...this needs to get moved out to a different script.
Y = savg[0:34]
X = [ transpose(navg[0:34]),transpose(navg[1:35]) ]
reg = regress(X,Y,const=const,correlation=corr,yfit=yfit) & print, const, corr

;p1 = plot(savg,thick = 3, 'orange', name = 'soil moisture', /overplot,$
;          xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
;         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'], yminor = 0)
p2 = plot(yfit,/overplot, linestyle=2,thick = 3,'g',xminor=0, name = 'filtered NDVI')
lgr2 = LEGEND(TARGET=[p1, p2], font_size=16)
p1.xtickfont_size=16
p1.ytickfont_size=16
;p1.ytitle='soil moisture (mm)'
print, 100*(1-norm(savg-yfit)/norm(savg-mean(yfit, /nan))) ;72

;*****combine the previous to plots with SM on the left axis and NDVI on the new right one.

p2 = plot(navg, thick = 3, 'g', name = 'NDVI', /overplot, $)
         xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'],$
         MARGIN = [0.15,0.2,0.15,0.1], $
         AXIS_STYLE=0, yminor = 0)
yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='NDVI', $
       TEXTDIR=0, TEXTPOS=1,YCHARSIZE=14)
p1 = plot(savg, thick = 3, 'orange', name = 'SM', xminor = 0, yminor = 0, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'],$
         YTITLE='SM',AXIS_STYLE=1,/CURRENT,/NOERASE)
p3 = plot(yfit, thick = 3, linestyle = 2, 'g',name ='filtered NDVI', /overplot)
lgr2 = LEGEND(TARGET=[p1, p2, p3], font_size=16)
p1.xtickfont_size=16
p1.ytickfont_size=16
p1.ytitle='soil moisture (mm)'
print, 100*(1-norm(savg-yfit)/norm(savg-mean(savg, /nan))) ;72


;***make map of filtered NDVI -- 9 yrs of data 2001-2011?***********
;*******check and see if my filter still works moving from matlab to IDL
  ndvi = file_search('/jabber/Data/mcnally/AMMAVeg/avergeNDVI_WK12MF_TK.csv')
  ndvi = read_csv(ndvi)
  b =   [0.0005, -0.3615, 0.5924]
  temp = ndvi.field1
  filtered = b[0]+ b[1]*temp[0:144-1] + b[2]*temp[1:144-2] 
  p1 = plot(ndvi.field1)
  p1 = plot(filtered,/overplot,'g')



 p1 = image((PNcorr-ANcorr)*rmask, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table=4)
;Mpala Kenya:
xind = FLOOR((36.8701 + 20.) / 0.10)
yind = FLOOR((0.4856 + 5) / 0.10)
print, PNcorr[xind,yind] ;Mpala - 0.65
print, ANcorr[xind,yind]; Mpala - 0.66
print, rmask[xind,yind]

;;KLEE Kenya
xind = FLOOR((36.8669 + 20.) / 0.10)
yind = FLOOR((0.2825 + 5) / 0.10)
print, PNcorr[xind,yind]; KLEE 0.73
print, ANcorr[xind,yind]; KLEE 0.74
print, rmask[xind,yind]

;Wankama Niger
xind = FLOOR((2.633 + 20.) / 0.10)
yind = FLOOR((13.6454 + 5) / 0.10)
print, PNcorr[xind,yind]; WK 0.87
print, ANcorr[xind,yind]; WK 0.85
print, rmask[xind,yind]

;;Joel's locations in Ethiopia: Interesting that these are the least predictable....
;joel's location is not within the 150-1200m threshold.
W = 36.25
N = -2
xind = FLOOR((W + 20.) / 0.10)
yind = FLOOR((N + 5) / 0.10)
print, PNcorr[xind,yind]; Joel 0.03
print, ANcorr[xind,yind]; Joel 0.12 
print, rmask[xind,yind]
;****check out regions in ethiopia and kenya where correspodance is low should be bimodal

mfile = file_search('/jabber/Data/mcnally/AMMASOIL/Mpala_dekad.csv') ;length 72 array change to 36 and compare with avg API and filtered
kfile = file_search('/jabber/Data/mcnally/AMMASOIL/KLEE_dekad.csv')
ifile = file_search('/jabber/LIS/Data/API_sahel/APIsahel_*') ;individual ubrfe API files (not pre-stacked)
afile = file_search('/jabber/Data/mcnally/API_soilmoisture_2001_2011.img'); prestacked!

;this is where i get my stacks of NDVI from (10/2/2013)
nfile = file_search('/raid/MODIS/eMODIS/01degree/sahel/data.{2005,2006,2007,2008}*.img')
ffile = file_search('/jabber/Data/mcnally/filterNDVI_soilmoisture_2001_2011.img');

nx = 720
ny = 350
nz = n_elements(ifile)
nnz = n_elements(nfile)

apigrid = fltarr(nx,ny,nz-2)
filter  = fltarr(nx,ny,nz-6)
;make a stack of NDVI to pull out the sites of interest...
veggrid = fltarr(nx,ny,nnz)
veggrid[*,*,*] = !values.f_nan
buffer = fltarr(nx,ny)
for i = 0,n_elements(nfile)-1 do begin &$
  openr,1,nfile[i] &$
  readu,1,buffer &$
  close,1 &$
  ;I should pad out rest of veg grid...I can just make the array bigger
  veggrid[*,*,i] = buffer &$
endfor

openr,1,afile
readu,1,apigrid
close,1

openr,1, ffile
readu,1,filter
close,1

result = read_csv(mfile)
mpala = float(result.field1)

result = read_csv(kfile)
KLEE = float(result.field1)

mpala = mean(reform(mpala,36,2), dimension =2, /nan);scale is totally off!
KLEE = mean(reform(KLEE,36,2), dimension =2, /nan);scale is totally off!

;Agoufou 15.35400    -1.47900
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.354 + 5) / 0.10)

;Mpala Kenya:
mxind = FLOOR((36.8701 + 20.) / 0.10)
myind = FLOOR((0.4856 + 5) / 0.10)

;;KLEE Kenya
kxind = FLOOR((36.8669 + 20.) / 0.10)
kyind = FLOOR((0.2825 + 5) / 0.10)

p1 = plot(veggrid[mxind,myind,*])
p2 = plot(veggrid[kxind,kyind,*], /overplot, 'g')
p1.title = 'NDVI at Mpala and KLEE (green)'

mveg = veggrid[mxind,myind,*]
kveg = veggrid[kxind,kyind,*]
nout = reform([mveg,kveg],2,72)

;ofile = '/jabber/Data/mcnally/AMMAVeg/NDVI_mpala_klee_2011_2012.csv'
;write_csv,ofile,nout

nout = veggrid[axind,ayind,*]
ofile = '/raid/chg-mcnally/NDVI_AgoufouMali_2005_2008.csv'
write_csv,ofile,nout

season = reform([[[apigrid[kxind,kyind,*]]],[[fltarr(1,1,2)]]],36,11)
season(where(season eq 0)) = !values.f_nan
seasonmean = mean(season,dimension = 2, /nan)

nfseason = reform([[[filtered[kxind,kyind,*]]],[[fltarr(1,1,6)]]],36,11)
nfseason(where(nfseason eq 0)) = !values.f_nan
nfseasonmean = mean(nfseason,dimension = 2, /nan)

;raw NDVI
;nseason = reform([[[cube[kxind,kyind,*]]],[[fltarr(1,1,4)]]],36,11)
;nseason(where(nseason eq 0)) = !values.f_nan
;nseasonmean = mean(nseason,dimension = 2, /nan)


p3 = plot(KLEE,thick = 3,name = 'observ',/overplot,  $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'],$
         AXIS_STYLE=0, yminor = 0,/CURRENT,/NOERASE)
yax2 = AXIS('Y',LOCATION=[MAX(p3.xrange),0],TITLE='obs (VWC %)', $
       TEXTDIR=0, TEXTPOS=1,YCHARSIZE=14)
p1 = plot(seasonmean, thick = 3,  name = 'API', xminor = 0, yminor = 0, linestyle = 2, 'orange', $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'],$
         YTITLE='API & filtered NDVI',AXIS_STYLE=1,/CURRENT,/NOERASE)
p2 = plot(nfseasonmean, thick = 3, linestyle = 2, 'g', name='filtered NDVI', /overplot)
p1.xtickfont_size = 16
p1.ytickfont_size = 18
p1.title = 'API & filtered NDVI vs Observed @ KLEE'
p4 = plot(nseasonmean, title='NDVI seasonal mean at Mpala, Kenya 2001-2011')
p1.title.font_size = 24

normKLEE = (KLEE-mean(KLEE, /nan))/stdev(KLEE)
normAPI = (seasonmean-mean(seasonmean,/nan))/stdev(seasonmean)
p1 = plot(normKLEE)
p1 = plot(normAPI, /overplot)
print, 100*(1-norm(normKLEE-normAPI)/norm(normKLEE-mean(normKLEE, /nan))) 

normfilter = (nfseasonmean-mean(nfseasonmean,/nan))/stdev(nfseasonmean)
p1 = plot(normKLEE)
p1 = plot(normfilter, /overplot)
print, 100*(1-norm(normKLEE-normfilter)/norm(normKLEE-mean(normKLEE, /nan))) 

;*************************************************************************
;find out where ndvi-precip doen't agree with ndvi-api
; temp=fltarr(nx,ny)
;;this is truncated a little becasue the NDVI is only goes to 390 (Nov 2011)
;for i = 0, n_elements(ifile)-7 do begin &$
;  openr,1,ifile[i] &$
;  readu,1,temp &$
;  close,1 &$
;  ;these were made in matlab (I think?) so need to be flipped.
;  temp = reverse(temp,2) &$
;  ;temp = temp*vegmask &$
;  ;test = image(temp, rgb_table = 4)
;  apigrid[*,*,i] = temp &$
;endfor
;
;;write out the apigrid so that i never have to run this section of code again
;ofile = '/jabber/Data/mcnally/API_soilmoisture_2001_2011.img'
;openw,1,ofile
;writeu,1,apigrid
;close,1

p1 = plot(apigrid[kxind,kyind,*])
p1 = plot(filtered[kxind,kyind,*])

cormap = fltarr(nx,ny) 
print, cormap[xind,yind]
;

;read in the big cube of rainfall data so i can check out the correponding timeseries.
;rainfall is not as variable as i had expected...
ifile=file_search('/jabber/LIS/Data/ubRFE2/dekads/sahel/sahel_200101_201232.img')
nx = 720
ny = 350
nz = 428
sahelarray = fltarr(nx,ny,nz)
openr,1,ifile
readu,1,sahelarray
close,1

cap = where(sahelarray gt 10000, count) & print, count
sahelarray(cap) = 10000
p1 = image(mean(sahelarray,/nan,dimension=3), rgb_table=20)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)

;might want to average this so i can see the typical seasonal cycle
p1 = plot(cube[xind,yind,*]*10, /overplot)
p2 = plot(sahelarray[xind,yind,*], /overplot,'b')

;add some spacers so i can cube the yr
pad = fltarr(1,1,4)
ethNDVI = mean(reform([[[cube[xind,yind,*]]], [[pad]]],36,11),dimension=2,/nan)
ethRFE = mean(reform(sahelarray[xind,yind,*],36,11),dimension=2,/nan)
p1.title = 'rainfall and NDVI climatology at 7N, 37E'
p1.title.font_size =24
ethNVI = transpose(reform(ethNDVI,36,11))



;**********************pull and total JAS dekads 16-24 for each year*******************************
;;**********************************************WRSI comparison***********************************
;reshape to nx,ny,36 * 11
pad = fltarr(nx,ny,2)
pad[*,*,*] = !values.f_nan
apipad = [[[apigrid]], [[pad]]]
pad = fltarr(nx,ny,6)
filterpad = [[[filtered]], [[pad]]]

apistack = reform(apipad,nx,ny,36,11)
filterstack = reform(filterpad,nx,ny,36,11)
;p1 = plot(apistack[xind,yind,19:27,0],'r', name = '2001') ;2001
;p2 = plot(apistack[xind,yind,19:27,1],'orange', /overplot,name = '2002');2002
;p3 = plot(apistack[xind,yind,19:27,2],'yellow',/overplot,name = '2003');2003 sort of wet...
;p4 = plot(apistack[xind,yind,19:27,3],'g', /overplot,name = '2004');2004
;p5 = plot(apistack[xind,yind,19:27,4],'b', /overplot,name = '2005');2005
;p6 = plot(apistack[xind,yind,19:27,5],'c', /overplot,name = '2006');2006
;p7 = plot(apistack[xind,yind,19:27,6],'m', /overplot,name = '2007');2007-- wet, yay!
;p8 = plot(apistack[xind,yind,19:27,7],'black', /overplot,name = '2008');2008
;p9 = plot(apistack[xind,yind,19:27,8],'r', linestyle = 2 ,/overplot,name = '2009');2009 supposed to be dry
;p10 = plot(apistack[xind,yind,19:27,9],'orange',linestyle = 2 , /overplot,name = '2010');2010
;p11 = plot(apistack[xind,yind,19:27,10],'g',linestyle = 2 , /overplot,name = '2011');2011 supposed to be dry?
;p12 = plot(mean(apistack[xind,yind,19:27,*], dimension = 4, /nan), thick = 3, /overplot,name = 'mean')
;p12.thick= 12
;p1.title = 'API 2001-2011 and mean'
;!null = legend(target=[p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12], position=[0.2,0.3]) ;
;xticks = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec' ]
;xticks = ['19','20','21','22','23','24','25','26','27']
;p1.xtickname = xticks

;get the totals for S
t1 = fltarr(nx,ny,11);API
t2 = fltarr(nx,ny,11);filtered NDVI
st1 = fltarr(nx,ny,11);API
st2 = fltarr(nx,ny,11);filtered NDVI
for y = 0,11-1 do begin &$
  t1[*,*,y] = mean(apistack[*,*,22:24,y],dimension=3,/nan) &$ ;API
  t2[*,*,y] = mean(filterstack[*,*,22:24,y],dimension=3,/nan) &$ ;filtered NDVI
  st1[*,*,y] = stddev(apistack[*,*,22:24,y],dimension=3,/nan) &$ ;API
  st2[*,*,y] = stddev(filterstack[*,*,22:24,y],dimension=3,/nan) &$ ;filtered NDVI
endfor 

temp = image(st2[*,*,9], rgb_table=10)

temp.title = 'stddev NDVI filter 2009'
x = indgen(11)
y = mean(total(apistack[xind,yind,19:27,*],3, /nan), dimension=3) & print, y
yy = fltarr(11)
yy[*] = y

p1 = plot(t1)
p1 = barplot(x,t1-yy)
p1.title = 'JAS API anomalies SW Niger 2001-2011'
p1.xtickinterval = 1
;p1.xminor = 0
xticks = ['','01','02','03','04','05','06','07','08','09','10','11','']
p1.xtickname = xticks

;map the years that chris suggested...2003,2009, hari's analysis is 2007
 diff1 = (t1[*,*,2])-(t1[*,*,8]);API
 diff2 = (t2[*,*,2])-(t2[*,*,8]);NDVI
 
 max1 = max(diff1(where(finite(diff1)))) & print, max1
 max2 = max(diff2(where(finite(diff2)))) & print, max2
 
 min1 = min(diff1(where(finite(diff1)))) & print, min1
 min2 = min(diff2(where(finite(diff2)))) & print, min2
 
 maxx = min([max1,max2]) & print, maxx
 ;minx = max([min1,min2]) & print, minx
 minx = -0.2
 ;messing with the data....
 diff1(where(diff1 ge maxx))= maxx
 diff2(where(diff2 ge maxx))= maxx
 
 diff1(where(diff1 le minx))= minx
 diff2(where(diff2 le minx))= minx
 
 ;color table 5 is pretty good. 
 p1 = image(diff1*wmask, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 10)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  p1.title = 'Aug API 2003(wet) - 2009(dry)'
  p1.title.font_size=14
;Joel's locations in Ethiopia:
xind = FLOOR((37 + 20.) / 0.10)
yind = FLOOR((7 + 5) / 0.10)

;*******************************************************************



;ndvi should pick up bimodal where as the 60day lag for API does't work.
p1 = plot(apigrid[xind,yind,*])
p2 = plot(filtered[xind,yind,*],/overplot,'g') 

p1.title = 'filtered-NDVI and API at Wankama'; Mpala,0.48N, 36.8E'
p1.title.font_size = 24
p1.xtickinterval = 36
p1.xminor = 0
p1.xtickvalues = [18, 54, 90,   126, 162, 198,   234, 270, 306,   342, 378]
xticks = ['01-Jun','02-Jun','03-Jun','04-Jun','05-Jun','06-Jun','07-Jun','08-Jun','09-Jun','10-Jun','11-Jun']
p1.xtickname = xticks
p1.ytitle = 'soil moisture (mm)'
p1.name = 'ubRFE2 API'
p2.name = 'filtered NDVI'
!null = legend(target=[p1,p2], position=[0.2,0.3]) ;


;p1 = plot(apigrid[xind,yind,*],filtered[xind,yind,*],'+')
print, correlate(apigrid[xind,yind,*],filtered[xind,yind,*])

;what are the indexes for october 2011-november 2012? Ah! I don't have data here! could pull from elsewhere.
;look at average seasonal cycle for now?

;scatter plot to show deviation from the mean is not much
p1 = plot(navg, wk1,'r+', name = 'wankama 1')
p2 = plot(navg, wk2,'b*', /overplot, name = 'wankama 2')
p3 = plot(navg, tk, '+',/overplot, name = 'tondi kiboro')
p4 = plot(navg, navg, '.', xminor = 0, yminor = 0,sym_size = 18,/overplot, $
          sym_filled = 1,title = 'correlation between sites and the mean ndvi', font_size = 18 )
p4.title.font_size = 20
p2.xtickfont_size = 16
null = legend(target=[p1,p2,p3], position=[0.2,0.3]) ;


p1 = plot(wk140, thick = 3, linestyle = 3, 'c', name = '40cm', $
          layout = [3,1,1], title = 'Wankama 1', font_size = fontsize, xminor = xminor, $
          xtickinterval = xtickinterval, xtickvalues = xtickvalues) & p1.xtickname = xticks
p2 = plot(wk170, thick = 3, linestyle = 5, 'b', name = '70cm', /overplot, $
          xrange = xrange, yrange = yrange, /PALATINO)

p3 = plot(wk240, thick = 3, linestyle = 3, 'c', name = 'Wankama 2 @ 40cm', $
           layout = [3,1,2], title = 'Wankama 2', font_size = fontsize, xminor = xminor, /current, $
           xtickinterval = xtickinterval, xtickvalues = xtickvalues) & p3.xtickname = xticks
p4 = plot(wk270, thick = 3, linestyle = 5, 'b', name = 'Wankama 2 @ 70cm', /overplot, $
          xrange = xrange, yrange = yrange) 

p5 = plot(tk40, thick = 3, linestyle = 3, 'c', name = 'Tondi Kiboro @ 40cm', $
           layout = [3,1,3], title = 'Tondi Kiboro', font_size = fontsize, xminor = xminor, /current, $
            xtickinterval = xtickinterval, xtickvalues = xtickvalues) & p5.xtickname = xticks
p6 = plot(tk70, thick = 3, linestyle = 5, 'b', name = 'Tondi Kibroro @ 70cm', /overplot, $
          xrange = xrange, yrange = yrange)
p1.SET_FONT='Palatino-Roman'

soilavg = mean([[soil.field1],[soil.field2], [soil.field3],[soil.field4], [soil.field5],[soil.field6]], dimension =2, /nan)
soilstm = mean(reform(soilavg,36,4),dimension = 2, /nan)

;*******************************************

;read in the wrsi anomaly (and soil water index anomaly?)

;check out the time series at wankama
p1 = plot(apistm[xind,yind,*])
p2 = plot(filterstm[xind,yind,*], 'g', /overplot)
p3 = plot(soilstm,'b',/overplot);plot the observed mean while i am at it.
p1.xtickinterval = 12
p1.xminor = 0
p1.xtickvalues = [0, 4-1, 7-1, 10-1, 13-1, 16-1, 19-1, 22-1, 25-1, 28-1,31-1, 34-1 ]
xticks = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec' ]
p1.xtickname = xticks
p1.title = 'averge seasonal API, filtered NDVI and observed soil moisture: SW Niger'
p1.name = 'API'
p2.name = 'filtered NDVI'
p3.name = 'observed SM'
!null = legend(target=[p1,p2,p3], position=[0.2,0.3]) ;
p1.title.font_size = 18


;************rainfall v rainfall plots****************************
temp = plot(rain.field1);RFE
temp2 = plot(rain.field2, /overplot, 'b');UBRFE
temp3 = plot(rain.field3, /overplot, 'g');station
temp.title = 'RFE, UBRFE and station rainfall SW Niger 2005-2008'
temp.ytitle = 'rainfall (mm/dekad)' 
temp.name = 'RFE'
temp2.name = 'UBRFE'
temp3.name = 'station'
!null = legend(target=[temp, temp2, temp3], position=[0.2,0.3]) 

temp = plot(rain.field1, rain.field2, '+', layout=[1,3,1], title='RFE v UBRF, RSQ=0.91')
temp1 = plot(rain.field1, rain.field3, '+', layout=[1,3,2], title='RFE v station, RSQ=0.76', /current)
temp2 = plot(rain.field2, rain.field3, '+', layout=[1,3,3], title='UBRFE v station, RSQ=0.76', /current)

temp.title = 'RFE vs UBRFE, RSQ = 0.91'
temp.xtitle = 'RFE'
temp.ytitle = 'UBRFE'
result=regress(rain.field1, rain.field2,correlation=rsq,yfit=yfit)
result=regress(rain.field2, rain.field3,correlation=rsq,yfit=yfit) & print, rsq

p1 = plot(data1, layout=[2,3,1])
p2 = plot(data2, layout=[2,3,2], /current)

;Wankama Niger
;xind = FLOOR((2.633 + 20.) / 0.10)
;yind = FLOOR((13.6454 + 5) / 0.10)

;;Joel's locations in Ethiopia:
;xind = FLOOR((37 + 20.) / 0.10)
;yind = FLOOR((7 + 5) / 0.10)


  
  ;*******what is the fit between KLEE and Mpala and the inial API and NDVI-filter?
  ;***********did not finish this section, I really wish that my code was not such a mess****
vfile = file_search('/jabber/Data/mcnally/filterNDVI_soilmoisture_2001_2011.img');cube of filtered NDVI
afile = file_search('/jabber/Data/mcnally/API_soilmoisture_2001_2011.img')

nx = long(720)
ny = long(350)
nz = long(390)
filtered = fltarr(nx,ny,nz)
apigrid  = fltarr(nx,ny,nz+2)

openr,1, vfile
readu,1, filtered
close,1

openr,1,afile
readu,1,apigrid
close,1

;Mpala Kenya:
xind = FLOOR((36.8701 + 20.) / 0.10)
yind = FLOOR((0.4856 + 5) / 0.10)
print, PNcorr[xind,yind] ;Mpala - 0.65
print, ANcorr[xind,yind]; Mpala - 0.66
print, rmask[xind,yind]

;;KLEE Kenya
xind = FLOOR((36.8669 + 20.) / 0.10)
yind = FLOOR((0.2825 + 5) / 0.10)

kfile = file_search('/jabber/Data/mcnally/AMMASOIL/KLEE_dekad.csv')
mfile = file_search('/jabber/Data/mcnally/AMMASOIL/Mpala_dekad.csv')




  
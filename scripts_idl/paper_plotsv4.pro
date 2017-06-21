;the purpose of this script is to make the plots for the paper.
;KLEE 10/5/2011 - 11/14/2012 (Octdek1-Nov dek2) or one?
;COSMOS_50=MPALA 9/6/2011 (Sept dek1) - 10/27/2012 (Oct dek3)

;****************************************************************

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



;;************FIGURE 2 ******************************************************

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

p1 = plot(avgwk140*100, thick = 3, 'black', font_size = 20, name = 'Wk1 40cm')
p2 = plot(avgwk170*100, thick = 3, /overplot, 'black', linestyle = 2, name = 'Wk1 70cm')
p3 = plot(avgwk240*100, thick = 3, /overplot,'grey', name = 'Wk2 40cm')
p4 = plot(avgwk270*100, thick = 3, /overplot,'grey', linestyle = 2, name = 'Wk2 70cm')
p5 = plot(avgtk40*100, thick = 3, /overplot,'light grey', name = 'Tk 40cm')
p6 = plot(avgtk70*100, thick = 3, /overplot,'light grey', linestyle = 2, name = 'Tk 70cm')
;p4.title = 'Average dekadal soil mositure 2005-2008 '
p4.ytitle = 'soil moisture (% VWC)'
p4.xminor = 0
p4.yminor = 0
p4.xrange = [10, 35]
p4.xtickvalues = [10+2, 15+2, 20+2, 25+2, 30+2]
xticks = ['21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov']
p4.xtickname = xticks
;p4.title.font_size = 16
null = legend(target=[p1,p2,p3,p4,p5,p6], position=[0.2,0.3],font_size=16) 

;******************FIGURE 3********************************************************
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

p2 = plot(navg, thick = 3, 'black', name = 'NDVI', /overplot, $)
         xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'],$
         MARGIN = [0.15,0.2,0.15,0.1], $
         AXIS_STYLE=0, yminor = 0)
yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='NDVI', $
       TEXTDIR=0, TEXTPOS=1,font_size=16, yminor = 0, tickpos = 0)
p1 = plot(savg*100, thick = 3, 'light grey', name = 'SM', xminor = 0, yminor = 0, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
         xtickname = ['11-Jan', '01-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'],$
         YTITLE='SM',AXIS_STYLE=1,/CURRENT,/NOERASE)
p3 = plot(filter.field1*100, thick = 3, linestyle = 2, 'grey',name ='SM estimate', /overplot,tickpos=0)
lgr2 = LEGEND(TARGET=[p1, p2, p3], font_size=16)
p1.xtickfont_size = 16
p1.ytickfont_size = 16
p1.ytitle='soil moisture (%VWC)'

yfit = filter.field1
print, 100*(1-norm(savg-yfit)/norm(savg-mean(yfit, /nan))) ;why is it 72 here and 88 elsewhere
;ok, switch over to nash-sutcliff i.e. R2 - answer is a little different than R2
print, 1-total((savg-yfit)^2)/(total((savg-mean(savg,/nan))^2)); 0.92


;******************FIGURE 4***********************************
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
est = [est,0]
xticks = ['Jun-05','Jun-06','Jun-07','Jun-08']
p1 = plot(est, thick = 3, 'grey',name = 'SM estimate', xminor = 0, yminor = 0,xrange = [0,144], $
 xtickvalues = [ 18, 54, 90, 126  ], xtickinterval = 36 ,font_size = 14, linestyle = 2)
 p1.xtickname= xticks
p1.xtickfont_size = 24
p1.ytickfont_size = 18
p2 = plot(savg144, thick = 2, name = 'observed SM', 'black', /overplot)
null = legend(target=[p1,p2], position=[0.2,0.3], font_size=18) ;
p1.ytitle = 'soil moisture (%VWC)'

;just plot the peaks
estcube = transpose(reform(est,36,4))
s144cube = transpose(reform(savg144,36,4)) 
estmax = [max(estcube[0,*]), max(estcube[1,*]),max(estcube[2,*]),max(estcube[3,*])] & print, estmax
s144max = [max(s144cube[0,*]), max(s144cube[1,*]),max(s144cube[2,*]),max(s144cube[3,*])] & print, s144max

;0.04-0.09
p4 = plot(estmax,s144max,'r*',SYM_SIZE = 2,xrange=[0.065, 0.1],yrange=[0.065, 0.1],xtitle='peak est', ytitle='peak obs' )
p5 = plot([0.065,0.1], [0.065,0.1], /overplot); the one2one line!
p4.xtickfont_size = 16
p4.ytickfont_size = 16
print, correlate(estmax,s144max);

print, 1-total((savg144-est)^2)/total((savg144-mean(savg144))^2);0.65

;******************************************************************************************
;*****FIGURE 5 fit for the API************************
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
p1 = plot(api*100, thick = 3, name = 'ubrfe API', xminor = 0, yminor = 0,xrange = [0,144], $
          xtickvalues = [ 18, 54, 90, 126  ], xtickinterval = 36 ,font_size = 14, 'grey',linestyle = 2)
p1.xtickname= xticks
p1.xtickfont_size = 16
p1.ytickfont_size = 16
p2 = plot(savg144*100, thick = 2, name = 'observed SM', 'black', /overplot)
null = legend(target=[p1,p2], position=[0.2,0.3], font_size=16) ;
p1.ytitle = 'soil moisture (%VWC)'

print, correlate(api,savg144)
p3 = plot(savg144, api,'*')

;just plot the peaks
apicube = transpose(reform(api,36,4))
s144cube = transpose(reform(savg144,36,4)) 
apimax = [max(apicube[0,*]), max(apicube[1,*]),max(apicube[2,*]),max(apicube[3,*])] & print, apimax
s144max = [max(s144cube[0,*]), max(s144cube[1,*]),max(s144cube[2,*]),max(s144cube[3,*])] & print, s144max

;0.04-0.09
p4 = plot(apimax,s144max,'r*',SYM_SIZE = 2,xrange=[0.065, 0.1],yrange=[0.065, 0.1],xtitle='peak api', ytitle='peak obs' )
p5 = plot([0.065,0.1], [0.065,0.1], /overplot); the one2one line!
p4.xtickfont_size = 16
p4.ytickfont_size = 16
print, correlate(apimax,s144max);



print, 100*(1-norm(API-savg144)/norm(API-mean(savg144, /nan)))

print, 1-total((savg144-API)^2)/total((savg144-mean(savg144))^2);0.83

;*****FIGURE 6 API-NDVI-SM correlation map***********
;cfile = file_search('/jabber/chg-mcnally/filterNDVI_APIcorr.img')
;I should find out what correlation is signficant and mask or set range accordingly. 
cfile = file_search('/jabber/chg-mcnally/filterNDVI_sahel/filterNDVI_APIcorr_200101_201232.img')
nx = 720
ny = 350

ANcorr = fltarr(nx,ny)
;read in API-NDVI correlation
openr,1,cfile
readu,1,ANcorr
close,1

;reduce the window down to 18N for the figures...
sahel = ANcorr[*, 0:230]

;reverse the black and white color bar for b/w figures
cgloadct, 0, /reverse, rgb_table = table

;mask out the non-significant regions? what is signficant?? gosh i should know this...
sahel(where(sahel lt 0.5)) = !values.f_nan


;p1 = image(ANcorr, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
;           rgb_table = table)
p1 = image(sahel, image_dimensions=[72.0,23.1], image_location=[-20,-5], dimensions=[nx/100,231/100], $
           rgb_table = table)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
;p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
p1 = MAP('Geographic',LIMIT = [-5, -20, 18, 52], /overplot)

p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  
;********FIGURE 7a&b pull the klee and mpala sites from the ndvi filter and API maps******
;KLEE 10/5/2011 - 11/14/2012 (Octdek1-Nov dek2) or one?
;COSMOS_50=MPALA 9/6/2011 (Sept dek1) - 10/27/2012 (Oct dek3)
afile = file_search('/jabber/chg-mcnally/sahel_API_200101_201232.img')
ffile = file_search('/jabber/chg-mcnally/filterNDVI_sahel/filterNDVI_soilmoisture_200101_2012.10.2.img')
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

filterpad = fltarr(nx,ny,7)
filterpad[*,*,*] = !values.f_nan
filterfull = [[[filter]],[[filterpad]]]

result = read_csv(mfile)
mpala = float(result.field1)

result = read_csv(kfile)
KLEE = float(result.field1)

;Mpala Kenya:
mxind = FLOOR((36.8701 + 20.) / 0.10)
myind = FLOOR((0.4856 + 5) / 0.10)

;;KLEE Kenya
kxind = FLOOR((36.8669 + 20.) / 0.10)
kyind = FLOOR((0.2825 + 5) / 0.10)


;*******************FIGURE 7A: the Mpala DATA*************************************
;I had to add in xrange, and adjusted the estimates rather than observations (e.g. +4 to API, not -4 from Mpala) 2/28/13
;looks like I should fix the y-ticks too so that figures 7&8 are identicle
;xticks = ['sept-11','nov-11','jan-12','mar-12', 'may-12','jul-12','sept-12']
xticks = ['oct-11','dec-11','feb-12','apr-12', 'jun-12','aug-12','oct-12']
xvals = [0,  6,  12,  18,  24,  30,  36]+3

p1 = plot((apifull[mxind,myind,360+24:431-6])*100+4, thick = 3,  name = 'API+WPdiff', $
         xminor = 0, yminor = 0, linestyle = 2, 'light grey', $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = xvals, $
         xtickname = xticks,$
         YTITLE='% volumetric SM',AXIS_STYLE = 1, $
         XRANGE = [0,n_elements(apifull[mxind,myind,360+24:431-6])-1], $
         YRANGE = [2,22])
p2 = plot(filterfull[mxind,myind,360+24:431-6]*100+4, thick = 3, linestyle = 2, $
          'grey', name='SM est from NDVI+WPdiff', /overplot)
p3 = plot(Mpala[24:65],thick = 3,name = 'observ',/overplot)  

;WPdiff = 0.067-0.028 & print, WPdiff

;p1.title.font_size = 24 
p1.xtickfont_size = 14
p1.ytickfont_size = 14
;yax2.font_size = 14
;p1.title = 'Observed and estimated soil moisture at Mpala'
;p1.title.font_size = 24 
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) ;

;print, 100*(1-norm((mpala[24:65]-2)-apifull[mxind,myind,360+24:431-6]*100)/norm((mpala[24:65]-2)$
;             -mean((apifull[mxind,myind,360+24:431-6]*100), /nan))) ;16
;print, 100*(1-norm((mpala[24:65]-2)-filterfull[mxind,myind,360+24:431-6]*100)/norm((Mpala[24:65]-2)$
;             -mean((filterfull[mxind,myind,360+24:431-6]*100), /nan))) ;42

;API fit             
vMPALA = (mpala[24:64]-4)/100
vAPI = (apifull[mxind,myind,360+24:431-7])
print, 1-total((vMpala-vAPI)^2)/total((vmpala-mean(vmpala))^2);-0.09 or 0.4069 (!)

;Filter Fit
vFilter = (filterfull[mxind,myind,360+24:431-7])
print, 1-total((vMpala-vfilter)^2)/total((vmpala-mean(vmpala))^2);0.67 ;0.418
;
;**********************FIG 7B: the KLEE DATA************************************
xticks = ['oct-11','dec-11','feb-12','apr-12', 'jun-12','aug-12','oct-12']
p1 = plot(apifull[kxind,kyind,360+27:431-4]*100+26, thick = 3,  name = 'API+WPdiff',$
         xminor = 0, yminor = 0, linestyle = 2, 'light grey', $
         MARGIN = [0.15,0.2,0.15,0.1], $
          xtickvalues = [0,  6,  12,  18,  24,  30,  36], $
         xtickname = xticks,$
         YTITLE='% volumetric SM',AXIS_STYLE=1)
         ;YTITLE='API & SM est',AXIS_STYLE=1,/CURRENT,/NOERASE)
p2 = plot(filterfull[kxind,kyind,360+27:431-4]*100+26, thick = 3, linestyle = 2,$
          'grey', name='SM est from NDVI+WPdiff', /overplot)
p3 = plot(KLEE[27:67], thick = 3,name = 'observ',/overplot)
;uh, i guess this shouldn't be 11...
p1.xtickfont_size = 16
p1.ytickfont_size = 16
;p1.title = 'Observed and estimated soil moisture at KLEE'
;p1.title.font_size = 24 
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) ;
;             
;print, 100*(1-norm((KLEE[27:67]-24)-apifull[kxind,kyind,360+27:431-4]*100)/norm((KLEE[27:67]-24)$
;             -mean((apifull[kxind,kyind,360+27:431-4]*100), /nan))) 
;print, 100*(1-norm((KLEE[27:67]-24)-filterfull[kxind,kyind,360+27:431-4]*100)/norm((KLEE[27:67]-24)$
;             -mean((filterfull[kxind,kyind,360+27:431-4]*100), /nan)))
;clay = 14 (FAO);  
WPdiff = 14-3

;API fit ...as the wilting point increases (i.e. shift the mean up!) so does the fit...maxes out at 30. 
;Haider's equation calculates it at 37% for ethipia black cotton clay. I should be able to justify this somehow.
;literature suggests that the wilting point of these clay soils is much higher, so we use the statsgo 28?         
for i = 22,37 do begin &$
  vKLEE = (KLEE[27:67]-(i-3))/100 &$
  vkAPI = (apifull[kxind,kyind,360+27:431-4])&$
  print, 'i= ', i, 1-total((vKLEE-vkAPI)^2)/total((vKLEE-mean(vKLEE))^2) &$ ;-0.037&$
endfor

;Filter Fit..so why don't I have the full time series avaialble??
vKLEE = (KLEE[27:64]-26)/100
vkFilter = (filterfull[kxind,kyind,360+27:431-7])
vkAPI = (apifull[kxind,kyind,360+27:431-4])
print, 1-total((vKLEE-vkfilter)^2)/total((vKLEE-mean(vKLEE))^2);0.38
print, 1-total((vKLEE-vkAPI)^2)/total((vKLEE-mean(vKLEE))^2);0.16


;******FIGURE 8--plot of refit Mpala*************************** 
afile = file_search('/jabber/LIS/Data/ubRFE2/dekads/horn_API_2001_2012MP.img')
ffile = file_search('/jabber/chg-mcnally/filterNDVI_sahel/filterNDVI_soilmoisture_2001_2012_Mpala.img')
kfile = file_search('/jabber/chg-mcnally/AMMASOIL/KLEE_dekad.csv')
mfile = file_search('/jabber/chg-mcnally/AMMASOIL/Mpala_dekad.csv')

nx = 250
ny = 350
anz = 428
nnz = 425

apigrid = fltarr(nx,ny,anz)
filter  = fltarr(nx,ny,nnz);this should be 426 no? or 425...why is it 424? I guess I fixed this...
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

filterpad = fltarr(nx,ny,7)
filterpad[*,*,*] = !values.f_nan
filterfull = [[[filter]],[[filterpad]]]

result = read_csv(mfile)
mpala = float(result.field1)

result = read_csv(kfile)
KLEE = float(result.field1)

mxind = FLOOR((36.8701 - 27.) / 0.10)
myind = FLOOR((0.4856 + 5) / 0.10)

;KLEE
kxind = FLOOR((36.8669 - 27.) / 0.10)
kyind = FLOOR((0.2825 + 5) / 0.10)


;*******************FIGURE 8A the Mpala DATA*************************************
xticks = ['oct-11','dec-11','feb-12','apr-12', 'jun-12','aug-12','oct-12']
xvals = [0+3,  6+3,  12+3,  18+3,  24+3,  30+3,  36+3]

p1 = plot(apifull[mxind,myind,360+24:431-6], thick = 3,  name = 'API', $
         xminor = 0, yminor = 0, linestyle = 2, 'light grey', $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = xvals, $
         xtickname = xticks,$
         YTITLE='% volumetric SM',AXIS_STYLE = 1,$
         XRANGE = [0,n_elements(apifull[mxind,myind,360+24:431-6])], $
         YRANGE = [2,24])
p2 = plot(filterfull[mxind,myind,360+24:431-6], thick = 3, linestyle = 2, $
          'grey', name='SM est from NDVI', /overplot)
p3 = plot(Mpala[24:65],thick = 3,name = 'observ',/overplot)  
p1.xtickfont_size = 14
p1.ytickfont_size = 14
;p1.title = 'Observed and estimated soil moisture at Mpala (Mpala refit)'
;p1.title.font_size = 24 
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) ;

;print, 100*(1-norm((mpala[24:65])-apifull[mxind,myind,360+24:431-6])/norm((mpala[24:65])$
;             -mean((apifull[mxind,myind,360+24:431-6]), /nan))) ;43.1682
;print, 100*(1-norm((mpala[24:65])-filterfull[mxind,myind,360+24:431-6])/norm((Mpala[24:65])$
;             -mean((filterfull[mxind,myind,360+24:431-6]), /nan))) ;44.46
;         
;print, correlate(apifull[mxind,myind,360+27:431-7], filterfull[mxind,myind,360+27:431-7]);0.89


;API fit             
vMPALA = (mpala[24:64])
vAPI = (apifull[mxind,myind,360+24:431-7])
print, 1-total((vMpala-vAPI)^2)/total((vmpala-mean(vmpala))^2);0.43

;Filter Fit
vFilter = (filterfull[mxind,myind,360+24:431-7])
print, 1-total((vMpala-vfilter)^2)/total((vmpala-mean(vmpala))^2);0.49

;*********FIGURE 8B********************************************************

xticks = ['oct-11','dec-11','feb-12','apr-12', 'jun-12','aug-12','oct-12']
p1 = plot(apifull[kxind,kyind,360+27:431-4]+22, thick = 3,  name = 'API+WPdiff',$
         xminor = 0, yminor = 0, linestyle = 2, 'light grey', $
         MARGIN = [0.15,0.2,0.15,0.1], $
          xtickvalues = [0,  6,  12,  18,  24,  30,  36], $
         xtickname = xticks,$
         YTITLE='% volumetric SM',AXIS_STYLE=1)
p2 = plot(filterfull[kxind,kyind,360+27:431-4]+22, thick = 3, linestyle = 2,$
          'grey', name='SM est from NDVI+WPdiff', /overplot)
p3 = plot(KLEE[27:67], thick = 3,name = 'observ',/overplot)

p1.xtickfont_size = 14
p1.ytickfont_size = 14
;p1.title = 'Observed and estimated soil moisture at KLEE (Mpala refit)'
;p1.title.font_size = 24 
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) ;

;print, 100*(1-norm((KLEE[27:67]-22)-apifull[kxind,kyind,360+27:431-4])/norm((KLEE[27:67]-22)$
;             -mean((apifull[kxind,kyind,360+27:431-4]), /nan))) 
;print, 100*(1-norm((KLEE[27:67]-22)-filterfull[kxind,kyind,360+27:431-4])/norm((KLEE[27:67]-22)$
;             -mean((filterfull[kxind,kyind,360+27:431-4]), /nan)))
;
;print, correlate(apifull[kxind,kyind,360+27:431-7], filterfull[kxind,kyind,360+27:431-7]);

;API fit             
vKLEE = (KLEE[27:67])
vkAPI = (apifull[kxind,kyind,360+27:431-4])
print, 1-total((vKLEE-vkAPI)^2)/total((vKLEE-mean(vKLEE))^2);0.48 -- really?

;Filter Fit..so why don't I have the full time series avaialble?? I hope that I have these correct....
vKLEE = (KLEE[27:64])
vkFilter = (filterfull[kxind,kyind,360+27:431-7])
print, 1-total((vKLEE-vkfilter)^2)/total((vKLEE-mean(vKLEE))^2);0.43


; go to Niger_yields.pro for the final figure with the yield data....and its the second plot of anomalies

;*************EXTRAS***************
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
           rgb_table = 1)
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
  



  
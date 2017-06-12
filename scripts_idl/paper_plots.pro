;the purpose of this script is to make the plots for the paper.

;****************************************************************
;read in the observed soil moisture data
ifile = file_search('/jabber/Data/mcnally/AMMASOIL/observed_TKWK1WK2.csv')
soil = read_csv(ifile)
wk140 = float(soil.field1)
wk170 = float(soil.field2) ;the weird one
wk240 = float(soil.field3) 
wk270 = float(soil.field4) 
tk40 = float(soil.field5) 
tk70 = float(soil.field6)
avg144 = mean([transpose(wk140),transpose(wk170),transpose(wk240), transpose(wk270), transpose(tk40), transpose(tk70)],$
              /nan, dimension = 1)
              
;p1 = plot(avg144,wk140,'c+', name = 'wankama 140')
;p2 = plot(avg144,wk170,'b+', /overplot,  name = 'wankama 170')
;p3 = plot(avg144,wk240,'*', /overplot, name = 'wankama 240')
;p4 = plot(avg144,wk270,'+', /overplot, name = 'wankama 270')
;p5 = plot(avg144,tk40,'m+', /overplot, name = 'tondi kiboro 40')
;p6 = plot(avg144,tk70,'r+', /overplot, name = 'tondi kiboro 70')
;p7 = plot(avg144,avg144,'.',sym_size = 28,sym_filled = 1,title = 'correlation between sites and the mean', /overplot, $
;          xminor = xminor, yminor = 0, font_size = 18)
;null = legend(target=[p1,p2,p3,p4,p5,p6,p7], position=[0.2,0.3]) ;

titlefont_size = 24
xtickinterval = 36
xminor = 0
xtickvalues = [ 18, 54, 90, 126  ]
xticks = ['05','06',  '07','08']
fontsize = 14
xrange = [0,144]
yrange = [0.015, 0.125]

;************figure 1 ******************************************************
;**************************************************************************
avgwk140 = mean(reform(wk140,36,4), dimension = 2,/nan)
avgwk170 = mean(reform(wk170,36,4), dimension = 2,/nan)
avgwk240 = mean(reform(wk240,36,4), dimension = 2,/nan)
avgwk270 = mean(reform(wk270,36,4), dimension = 2,/nan)
avgtk40 = mean(reform(tk40,36,4), dimension = 2,/nan)
avgtk70 = mean(reform(tk70,36,4), dimension = 2,/nan)

;p1 = plot(avgwk140, thick = 3, 'r', font_size = 16, name = 'Wk1 40cm')
;p2 = plot(avgwk170, thick = 3, /overplot, 'r', linestyle = 2, name = 'Wk1 70cm')
;p3 = plot(avgwk240, thick = 3, /overplot,'b', name = 'Wk2 40cm')
;p4 = plot(avgwk270, thick = 3, /overplot,'b', linestyle = 2, name = 'Wk1 70cm')
;p5 = plot(avgtk40, thick = 3, /overplot,'g', name = 'TK 40cm')
;p6 = plot(avgtk70, thick = 3, /overplot,'g', linestyle = 2, name = 'TK 70cm')
;p4.title = '2005-2008 average soil mositure at 3 sites'
;p4.xminor = 0
;p4.yminor = 0
;p4.xrange = [10, 35]
;p4.xtickvalues = [10+2, 15+2, 20+2, 25+2, 30+2]
;xticks = ['21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov']
;p4.xtickname = xticks
;p4.title.font_size = 18
;null = legend(target=[p1,p2,p3,p4,p5,p6], position=[0.2,0.3]) ;

;**********include a figure on fitting the API************
; use avg144
afile = file_search('/jabber/Data/mcnally/AMMASOIL/API_ubrf_niger')
api = read_csv(afile)
api = api.field1

xticks = ['Jun-05','Jun-06','Jun-07','Jun-08']
p1 = plot(api, thick = 3, name = 'ubrfe API', xminor = 0, yminor = 0,xrange = [0,144], $
 xtickvalues = [ 18, 54, 90, 126  ], xtickinterval = 36 ,font_size = 14, linestyle = 2)
 p1.xtickname= xticks
p1.xtickfont_size = 18
p1.ytickfont_size = 18
p2 = plot(avg144, thick = 2, name = 'observed SM', 'b', /overplot)
null = legend(target=[p1,p2], position=[0.2,0.3], font_size=18) ;

print, correlate(api, avg144)
p3 = plot(avg144, api,'*')
 print, 100*(1-norm(avg144-API)/norm(avg144-mean(avg144, /nan))) 
;********************************************************************************
;;*******************************************************************************
;plot the average NDVI and rainfall (stations and 250m too! just so i know how they vary)
; these axis are going to be unpleasent, no?
;rfile = file_search('/jabber/Data/mcnally/AMMARain/RFE_UBRFE_and_station_dekads.csv')
;rain = read_csv(rfile)
;ubrf = rain.field2
;ubrf = mean(reform(ubrf,36,4),dimension=2, /nan)

nfile = file_search('/jabber/Data/mcnally/AMMAVeg/avergeNDVI_WK12MF_TK.csv')
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

;p2 = plot(savg, thick = 3, 'orange', name = 'soil moisture', /overplot, $)
;         MARGIN = [0.15,0.2,0.15,0.1], $
;         xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
;         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'],$
;         AXIS_STYLE=0, yminor = 0)
;yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='Average SM (mm)', $
;       TEXTDIR=0, TEXTPOS=1,YCHARSIZE=14)
;p1 = plot(navg, thick = 3, 'g', name = 'ndvi', xminor = 0, yminor = 0, $
;         MARGIN = [0.15,0.2,0.15,0.1], $
;         xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
;         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'],$
;         YTITLE='NDVI',AXIS_STYLE=1,/CURRENT,/NOERASE)
;lgr2 = LEGEND(TARGET=[p1, p2])
;p2.yminor = 0
;p1.xtickfont_size=14
;p1.ytickfont_size=16

;now regress them...
Y = savg[0:34]
X = [ transpose(navg[0:34]),transpose(navg[1:35]) ]
reg = regress(X,Y,const=const,correlation=corr,yfit=yfit) & print, const, corr

;p1 = plot(savg,thick = 3, 'orange', name = 'soil moisture', /overplot,$
;          xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
;         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'], yminor = 0)
;p2 = plot(yfit,/overplot, linestyle=2,thick = 3,'g',xminor=0, name = 'filtered NDVI')
;lgr2 = LEGEND(TARGET=[p1, p2], font_size=16)
;p1.xtickfont_size=16
;p1.ytickfont_size=16
;p1.ytitle='soil moisture (mm)'
print, 100*(1-norm(savg-yfit)/norm(savg-mean(savg, /nan))) ;72

;*****combine the previous to plots with SM on the left axis and NDVI on the new right one.
p2 = plot(navg, thick = 3, 'g', name = 'NDVI', /overplot, $)
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = [0+2, 5+2,10+2, 15+2, 20+2, 25+2, 30+2], $
         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','11-Nov'],$
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

;**********fit the longer time series?************************
est = const+reg[0]*navg144[0:142]+reg[1]*navg144[1:143]
print, 100*(1-norm(savg144-est)/norm(savg144-mean(savg144, /nan))) ;40

xticks = ['Jun-05','Jun-06','Jun-07','Jun-08']
p1 = plot(est, thick = 3, name = 'filtered NDVI', xminor = 0, yminor = 0,xrange = [0,144], $
 xtickvalues = [ 18, 54, 90, 126  ], xtickinterval = 36 ,font_size = 14, linestyle = 2)
 p1.xtickname= xticks
p1.xtickfont_size = 18
p1.ytickfont_size = 18
p2 = plot(savg144, thick = 2, name = 'observed SM', 'b', /overplot)
null = legend(target=[p1,p2], position=[0.2,0.3], font_size=18) ;
p1.ytitle = 'soil moisture (mm)'
;************************************************************************************************************
;       
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
;************make cummulative precip at a point*****************************
;;orginal file made in 
rfile = file_search('/jabber/Data/mcnally/AMMARain/RFE_UBRFE_and_station_dekads.csv')
rain = read_csv(rfile)

;first cube into years
RFE = transpose(reform(rain.field1,36,4))
UBRFE = transpose(reform(rain.field2,36,4))
station = transpose(reform(rain.field3,36,4))

cum = fltarr(4,36)
for y = 0,n_elements(RFE[*,0])-1 do begin &$
  for i = 0,n_elements(RFE[0,*])-1 do begin &$
    cum[y,0] = RFE[y,0] &$
    cum[y,i] = cum[y,i-1] + RFE[y,i] &$
  endfor &$
endfor  

temp1 = plot(cum[0,*],'r', layout = [3,1,1] )
temp2 = plot(cum[1,*],'orange', /overplot)
temp3 = plot(cum[2,*],'green', /overplot)
temp4 = plot(cum[3,*],'blue', /overplot)

;********the standard NDVI cummulative rainfall correlation plot- repeat nicholson/others******
;map the 4 dek cummulative rainfall & ndvi, maybe check....
;read in UBRFE -- do I have this for RFE2 as well?
;read in the big cube of rainfall data so i can check out the correponding timeseries.
ifile = file_search('/jabber/LIS/Data/ubRFE2/dekads/sahel/*.img')
;ifile = file_search('/jabber/LIS/Data/CPCOriginalRFE2/dekads/sahel/*.img')

nx = 720
ny = 350
nz = 396

ingrid = fltarr(nx,ny)
ubcube = fltarr(nx,ny,nz)

for i = 0,n_elements(ifile)-1 do begin &$
  ;i = 0
  openr,1,ifile[i]  &$
  readu,1,ingrid &$
  close,1 &$
  
  ubcube[*,*,i] = ingrid &$
endfor

;add up the current + three previous dekads (nicholson says 3 previous months (9deks!)...how do i decide?)
sumrain = fltarr(nx,ny,nz)
sumrain[*,*,*] = !values.f_nan
;highest lag0 correlation at current+9 dekads of rainfall
for d = 7,nz-1 do begin &$
  sumrain[*,*,d] = total(ubcube[*,*,d-7:d],3,/nan) &$
endfor

;read in the NDVI cube to investigate correlation with cummulative rainfall
nfile = file_search('/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/sahel/data*.img')
ingrid = fltarr(nx,ny)
ncube = fltarr(nx,ny,nz)
for n = 0,n_elements(nfile)-1 do begin &$
  openr,1,nfile[n] &$
  readu,1,ingrid &$
  close,1  &$
  ncube[*,*,n] = ingrid &$
  
endfor

cor = fltarr(nx,ny)
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    cor[x,y] = correlate(sumrain[x,y,7:387],ncube[x,y,7:387]) &$
  endfor &$
endfor
;
;  p1 = image(cor, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
;           rgb_table=20)
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07])
;  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
;  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
;  p1.title = 'correlation between NDVI and current + 7 dekads of UBRFE2 rainfall'
;  p1.title.font_size = 14
;;test = image(ingrid, rgb_table = 4)
;xind = FLOOR((2.633 + 20.) / 0.10)
;yind = FLOOR((13.6454 + 5) / 0.10)
;temp = plot(ncube[xind,yind,*])

  
lag=[0,1,2,3,4,5]
print, c_correlate(sumrain[xind,yind,9:387],ncube[xind,yind,9:387],lag);
print, c_correlate(ubcube[xind,yind,3:390],ncube[xind,yind,3:390],lag); 5 lag for rain and ndvi

;read in FCLIM data to make annual rainfall total mask (how would I plot contours?)
fx = 1501
fy = 1601
fz = 12
climgrid = LONARR(fx,fy,fz)

climfile = file_search('/jabber/LIS/Data/FCLIM_Afr/*.img')
openr,1, climfile
readu,1, climgrid
close,1

climgrid = float(climgrid[*,*,*])
null = where(climgrid lt 0, count) & print, count
climgrid(null) = !values.f_nan
totclim = reverse(total(climgrid,3, /nan),2)
temp = image(totclim, rgb_table=20)

;matches up correctly
totclimCoarse = congrid(totclim, 751,801)
xrt = (751-1)-3/0.1  ;RFE goes to 55, sahel goes to 52 plus an extra pixel
ybot = (35/0.1)+1    ;sahel starts at -5S
ytop = (801-1)-10/0.1  ; &$sahel stops at 30N
xlt = 1.              ;and I guess sahel starts at 19W, rather than 20....
sahel = totclimcoarse[xlt:xrt,ybot:ytop] 

out = where(sahel gt 1200. OR sahel lt 150., complement = in, count) & print, count
mask = intarr(nx,ny)
mask(in) = 1
mask(out) = 0

maskedcor = cor*mask
;  p1 = image(maskedcor, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
;           rgb_table=20)
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07])
;  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
;  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
;  p1.title = 'correlation between NDVI and current + 7 dekads of UBRFE2 rainfall (150-1200mm annual rainfall)'
;  p1.title.font_size = 24



;***make map of filtered NDVI -- 9 yrs of data 2001-2011?***********
;*******check and see if my filter still works moving from matlab to IDL
  ndvi = file_search('/jabber/Data/mcnally/AMMAVeg/avergeNDVI_WK12MF_TK.csv')
  ndvi = read_csv(ndvi)
  b =   [0.0005, -0.3615, 0.5924]
  temp = ndvi.field1
  filtered = b[0]+ b[1]*temp[0:144-1] + b[2]*temp[1:144-2] 
  p1 = plot(ndvi.field1)
  p1 = plot(filtered,/overplot,'g')

;********read in the UB RFE-API and filtered NDVI data *************
ifile = file_search('/jabber/LIS/Data/API_sahel/APIsahel_*')
vfile = file_search('/jabber/Data/mcnally/AMMAVeg/mask_bare75_sahel.img')
nfile = file_search('/jabber/Data/mcnally/filterNDVI_soilmoisture_2001_2011.img')

nx = 720
ny = 350
nz = n_elements(ifile)

vegmask = fltarr(nx,ny)
apigrid = fltarr(nx,ny,nz-2)
filtered = fltarr(nx,ny,nz-6)
temp = fltarr(nx,ny)
;read in veg mask and filteredNDVI outside o' loop
openr,1,vfile
readu,1,vegmask
close,1
vegmask(where(vegmask eq 0.))=!values.f_nan

openr,1,nfile
readu,1,filtered
close,1




;this is truncated a little becasue the NDVI is. I guess i should figure out 
;how to fill in the rest of 2011-present.
for i = 0, n_elements(ifile)-7 do begin &$
  openr,1,ifile[i] &$
  readu,1,temp &$
  close,1 &$
  ;these were made in matlab (I think?) so need to be flipped.
  temp = reverse(temp,2) &$
  temp = temp*vegmask &$
  ;test = image(temp, rgb_table = 4)
  apigrid[*,*,i] = temp &$
endfor

;where are the big weird values that I can't see on the map?
;big = where(apigrid gt 0.16)
;better = apigrid
;better(big) = 0.1

p1 = plot(apigrid[xind,yind,*])

;****map it***********
;  p1 = image(mean(better,dimension=3, /nan), image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
;           rgb_table=20)
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07])
;  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
;  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

cormap = fltarr(nx,ny) 
;well correlate apigrid and filtered grid and see what we get....
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    rsq = correlate(apigrid[x,y,*], filtered[x,y,*]) &$
    ;rsq = correlate(apigrid[xind,yind,*], filtered[xind,yind,*]) &$
    cormap[x,y] = rsq &$
  endfor &$
endfor

print, cormap[xind,yind]
;****map it***********
;  p1 = image(cormap[*,*,0], image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
;           rgb_table=20)
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07])
;  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
;  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

;find out where ndvi-precip doen't agree with ndvi-api
mask=float(mask)
mask(out)=!values.f_nan
;p3=image((cor*vegmask-cormap)*mask,image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
;           rgb_table=4)
;c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;   POSITION=[0.3,0.04,0.7,0.07])
;p3 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
;p3 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
;p3.title = 'level of disagreement between API-NDVI filter correlation and the NDVI-precip'
  
;****check out regions in ethiopia and kenya where correspodance is low should be bimodal
;it would make sense that this won't work since API was fit to unimodal curve...
;Wankama Niger
xind = FLOOR((2.633 + 20.) / 0.10)
yind = FLOOR((13.6454 + 5) / 0.10)

;;Joel's locations in Ethiopia:
;xind = FLOOR((37 + 20.) / 0.10)
;yind = FLOOR((7 + 5) / 0.10)
;
;;Mpala Kenya:
;xind = FLOOR((36.8701 + 20.) / 0.10)
;yind = FLOOR((0.4856 + 5) / 0.10)
;
;;KLEE Kenya
;xind = FLOOR((36.8669 + 20.) / 0.10)
;yind = FLOOR((0.2825 + 5) / 0.10)

;ndvi should pick up bimodal where as the 60day lag for API does't work.
;p1 = plot(apigrid[xind,yind,*])
;p2 = plot(filtered[xind,yind,*],/overplot,'g') 
;p1.title = 'filtered-NDVI and API at Wankama'; Mpala,0.48N, 36.8E'
;p1.title.font_size = 24
;p1.xtickinterval = 36
;p1.xminor = 0
;p1.xtickvalues = [18, 54, 90,   126, 162, 198,   234, 270, 306,   342, 378]
;xticks = ['01-Jun','02-Jun','03-Jun','04-Jun','05-Jun','06-Jun','07-Jun','08-Jun','09-Jun','10-Jun','11-Jun']
;p1.xtickname = xticks
;p1.ytitle = 'soil moisture (mm)'
;p1.name = 'ubRFE2 API'
;p2.name = 'filtered NDVI'
;!null = legend(target=[p1,p2], position=[0.2,0.3]) ;


;p1 = plot(apigrid[xind,yind,*],filtered[xind,yind,*],'+')
print, correlate(apigrid[xind,yind,*],filtered[xind,yind,*])

;what are the indexes for october 2011-november 2012? Ah! I don't have data here! could pull from elsewhere.
;look at average seasonal cycle for now?
season = reform([[[apigrid[xind,yind,*]]],[[fltarr(1,1,6)]]],36,11)
season(where(season eq 0)) = !values.f_nan
seasonmean = mean(season,dimension = 2, /nan)
temp = plot(seasonmean, title='API seasonal mean at Mpala, Kenya 2001-2011')
temp.title.font_size = 24

nfseason = reform([[[filtered[xind,yind,*]]],[[fltarr(1,1,6)]]],36,11)
nfseason(where(nfseason eq 0)) = !values.f_nan
nfseasonmean = mean(nfseason,dimension = 2, /nan)
temp = plot(nfseasonmean, title='Filtered NDVI seasonal mean at Mpala, Kenya 2001-2011')
temp.title.font_size = 24

nseason = reform([[[cube[xind,yind,*]]],[[fltarr(1,1,4)]]],36,11)
nseason(where(nseason eq 0)) = !values.f_nan
nseasonmean = mean(nseason,dimension = 2, /nan)
temp = plot(nseasonmean, title='NDVI seasonal mean at Mpala, Kenya 2001-2011')
temp.title.font_size = 24

;read in the big cube of rainfall data so i can check out the correponding timeseries.
ifile=file_search('/jabber/LIS/Data/ubRFE2/dekads/sahel_2001_2011.img')
z = 396
sahelarray = fltarr(nx,ny,z)
openr,1,ifile
readu,1,sahelarray
close,1

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

;*********make short term mean maps for calculating anomalies**********************************
pad = fltarr(nx,ny,6)
pad[*,*,*] = !values.f_nan
apipad = [[[apigrid]], [[pad]]]
apistm = mean(reform(apipad,nx,ny,36,11),dimension=4,/nan)

filterpad = [[[filtered]], [[pad]]]
filterstm = mean(reform(filterpad,nx,ny,36,11),dimension=4,/nan)

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

;*****pull and total JAS dekads 16-24 for each year
;reshape to nx,ny,36 * 11
apistack = reform(apipad,nx,ny,36,11)
filterstack = reform(filterpad,nx,ny,36,11)
p1 = plot(apistack[xind,yind,19:27,0],'r', name = '2001') ;2001
p2 = plot(apistack[xind,yind,19:27,1],'orange', /overplot,name = '2002');2002
p3 = plot(apistack[xind,yind,19:27,2],'yellow',/overplot,name = '2003');2003 sort of wet...
p4 = plot(apistack[xind,yind,19:27,3],'g', /overplot,name = '2004');2004
p5 = plot(apistack[xind,yind,19:27,4],'b', /overplot,name = '2005');2005
p6 = plot(apistack[xind,yind,19:27,5],'c', /overplot,name = '2006');2006
p7 = plot(apistack[xind,yind,19:27,6],'m', /overplot,name = '2007');2007-- wet, yay!
p8 = plot(apistack[xind,yind,19:27,7],'black', /overplot,name = '2008');2008
p9 = plot(apistack[xind,yind,19:27,8],'r', linestyle = 2 ,/overplot,name = '2009');2009 supposed to be dry
p10 = plot(apistack[xind,yind,19:27,9],'orange',linestyle = 2 , /overplot,name = '2010');2010
p11 = plot(apistack[xind,yind,19:27,10],'g',linestyle = 2 , /overplot,name = '2011');2011 supposed to be dry?
p12 = plot(mean(apistack[xind,yind,19:27,*], dimension = 4, /nan), thick = 3, /overplot,name = 'mean')
p12.thick= 12
p1.title = 'API 2001-2011 and mean'
!null = legend(target=[p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12], position=[0.2,0.3]) ;
xticks = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec' ]
xticks = ['19','20','21','22','23','24','25','26','27']
p1.xtickname = xticks

;get the totals for JAS
t1 = fltarr(nx,ny,11)
t2 = fltarr(nx,ny,11)
for y = 0,11-1 do begin &$
  t1[*,*,y] = total(apistack[*,*,19:27,y],3) &$ ;API
  t2[*,*,y] = total(filterstack[*,*,19:27,y],3) &$ ;filtered NDVI
endfor 
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

;map the years that chris suggested...silly stuff to get them on same scale.
 diff1 = (t1[*,*,2]*mask)-(t1[*,*,8]*mask);API
 diff2 = (t2[*,*,2]*mask)-(t2[*,*,8]*mask);NDVI
 
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
 p1 = image(diff2, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 13)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  p1.title = 'JAS NDVI filter 2003(wet) - 2009(dry)'
;*********************this didn't work quite right....
full = 36*11
apianom = fltarr(nx,ny,nz)
filteranom = fltarr(nx,ny,nz)
dek = 0
for t = 0,nz-3 do begin &$
  apianom[*,*,t] = apistm[*,*,dek]-apigrid[*,*,t] &$
  filteranom[*,*,t] = filterstm[*,*,dek]-filtered[*,*,t] &$
  dek++ &$
  if dek eq 36 then dek=0 &$
endfor 

;Joel's locations in Ethiopia:
xind = FLOOR((37 + 20.) / 0.10)
yind = FLOOR((7 + 5) / 0.10)

p1 = plot(smooth(apianom[xind,yind,*],15))
p2 = plot(apistm[xind,yind,*])
xticks=['2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011']
p1.xtickname=xticks

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

;***I think most stuff below here is useless********************
;*********rainfall vs NDVI plot*********************************
nfile = file_search('/jabber/Data/mcnally/AMMAVeg/avergeNDVI_WK12MF_TK.csv')

ndvi = read_csv(nfile)

;but i wouldn't really expect 10 day rain and 10 day ndvi to align...it should be cummulative rain...
rfeWK1 = regress(rain.field1,ndvi.field1, correlation=rsq) & print, rsq ;0.33
ubrfeWK1 = regress(rain.field2,ndvi.field1, correlation=rsq) & print, rsq ;0.33
staWK1 = regress(rain.field3,ndvi.field1, correlation=rsq) & print, rsq ;0.41

temp = plot(rain.field1,ndvi.field1,'+', layout = [3,3,1], title = 'RFE v WK1, RSQ = 0.33')
temp = plot(rain.field2,ndvi.field1,'+', layout = [3,3,2], title = 'UBRFE v WK1, RSQ = 0.33', /current)
temp = plot(rain.field3,ndvi.field1,'+', layout = [3,3,3], title = 'station v WK1, RSQ = 0.41', /current)

;plot cummulative rainfall with ndvi...from when to when in the season? until the peak NDVI?
;how do the other studies do this and why haven't i? duh...see rainlag4nadviV2 for these plots...

;***********NDVI vs API*********************************
;somehow this relationship should be better/more infomative then the rainfall NDVI realtionship.
ifile = file_search('/jabber/Data/mcnally/AMMASOIL/API*TK.csv')
APIrfe = read_csv(ifile[1]); there are different ones because they were calibrated with different soil moisture values.
APIubrfe = read_csv(ifile[0])
APIsta = read_csv(ifile[2])

p1=plot(APIrfe.field1,'r')
p1=plot(APIubrfe.field1, /overplot, 'b')
p1=plot(APIsta.field1, /overplot, 'g')
p1.title = 'rfe/ubrfe/sta API calibrated at Wk1(red, blue, grn)'




lag = [0,1,2,3,4,5,6]; API uses 60 day rainfall with a decay coefficient 
apirfeWK1 = c_correlate(APIrfe.field1,ndvi.field1, lag) & p1 = plot(apirfewk1,'r', layout =[3,1,1]) & print, max(apirfewk1)
apiUBWK1 = c_correlate(APIubrfe.field1,ndvi.field1, lag) & p2 = plot(apiUBwk1,'orange', /overplot)& print, max(apiUBwk1)
apiSTWK1 = c_correlate(APIsta.field1,ndvi.field1, lag) & p3 = plot(apiSTwk1,'b', /overplot)& print, max(apiSTwk1)
p1.title = 'xcorrelation API and ndvi at WK1'
p1.name = 'RFE'
p2.name = 'UBRFE'
p3.name = 'station'
!null = legend(target=[p1,p2,p3], position=[0.2,0.3]) 
p1.title.font_size=16

apirfewk2 = c_correlate(APIrfe.field3,ndvi.field3, lag) & p1 = plot(apirfewk2,'r', layout = [3,1,2], /current) & print, max(apirfewk2)
apiUBwk2 = c_correlate(APIubrfe.field3,ndvi.field3, lag) & p2 = plot(apiUBwk2,'orange', /overplot)& print, max(apiUBwk2)
apiSTwk2 = c_correlate(APIsta.field3,ndvi.field3, lag) & p3 = plot(apiSTwk2,'b', /overplot)& print, max(apiSTwk2)

p1.title = 'xcorrelation API and ndvi at WK2'
p1.name = 'RFE'
p2.name = 'UBRFE'
p3.name = 'station'
!null = legend(target=[p1,p2,p3], position=[0.2,0.3]) 
p1.title.font_size=16

lag = [0,1,2,3,4,5,6]; API uses 60 day rainfall with a decay coefficient 
apirfeTK = c_correlate(APIrfe.field5,ndvi.field5, lag) & p1 = plot(apirfeTK,'r', layout = [3,1,3], /current) & print, max(apirfetk)
apiUBTK = c_correlate(APIubrfe.field5,ndvi.field5, lag) & p2 = plot(apiUBTK,'orange', /overplot)& print, max(apiUBtk)
apiSTTK = c_correlate(APIsta.field5,ndvi.field5, lag) & p3 = plot(apiSTTK,'b', /overplot)& print, max(apiSTtk)

p1.title = 'xcorrelation API and ndvi at TK'
p1.name = 'RFE'
p2.name = 'UBRFE'
p3.name = 'station'
!null = legend(target=[p1,p2,p3], position=[0.2,0.3]) 
p1.title.font_size=16

;*********************NDVI and API anomalies****************************************
;***********************************************************************************
apicube = transpose(reform(APIrfe.field1,36,4))

;just for the RFE2
temp = mean(apicube,dimension = 1)
curve = [temp, temp, temp, temp]
anom = APIrfe.field1 - curve

ndvi1 = transpose(reform(ndvi.field1,36,4))
temp = mean(ndvi1, dimension = 1)
ncurve = [temp, temp, temp, temp]
nanom = ndvi.field1 - ncurve

lag = [-3,-2,-1,0,1,2,3]
result=c_correlate(anom,nanom, lag)
p1=plot(result)
p1.title = 'xcorr of ndvi and API anomalies'
p1.name = 'RFE'

apicube2 = transpose(reform(APIubrfe.field1,36,4))
apicube3 = transpose(reform(APIsta.field1,36,4))

;do the soil mosisture and NDVI fit again.


;..ooops but not for the whole timeseries just for the average....
;savg144 = avg144
;Y = savg144[0:142]
;X = [transpose(navg144[0:142]),transpose(navg144[1:143])]
;navg144 = mean([transpose(wk1), transpose(wk2), transpose(tk)], /nan, dimension = 1)
;reg = regress(navg144,savg144,const=const, yfit=yfit, correlation=corr) & print, corr
;reg = regress(X,Y,const=const, yfit=yfit, correlation=corr) & print, corr
;p1=plot(yfit)
;p1=plot(savg144,/overplot,'b')


pro adjpaw
;the purpose of this program is to adjust the mean of the NDVI plant available water. 
;ugh, not sure how i'll feed this back into WRSI -- I guess I might need some fix in the fly. 
;but i can make a mean grid and then subtract that from the whole TS i guess...anyway
;cropped area mask from pete.

nfile = file_search('/jabber/chg-mcnally/PAW_NDVI_climSOS_sahel.img')

nx = 720
ny = 350
max_lgp = 22
nz = 11 ;nyrs

ngrid = fltarr(nx,ny,max_lgp,nz)

openr,1,nfile
readu,1,ngrid
close,1

rfile = file_search('/jabber/chg-mcnally/PAW_RFE_climSOS_sahel.img')
rgrid = fltarr(nx,ny,max_lgp,nz)

openr,1,rfile
readu,1,rgrid
close,1

ifile = file_search('/jabber/chg-mcnally/cropmask_01deg_sahel.img'); 1=8 bit byte
cropmask = fltarr(nx,ny)
openr,1,ifile
readu,1,cropmask
close,1

;the old wankama check...looks fine. 
;Wankama Niger for sahel window 720/350
xind = FLOOR((2.6496 + 20.) / 0.10)
yind = FLOOR((13.6496 + 5) / 0.10)
;print, transpose(ngrid[xind,yind,*,*])

;ok, so now I need the mean for each pixel's length of growing period.
;this is limiting my analysis but maybe a good place to start....
xticks = ['2001','2002','2003','2004', '2005','2006','2007','2008','2009','2010','2011']

rmeanyr = mean(rgrid,dimension=3, /nan)
nmeanyr = mean(ngrid,dimension=3, /nan)
;p1 = plot(nmeanyr[xind,yind,0:9],xtickname = xticks, title = 'Avg PAW Wankam')
;p2 = plot(rmeanyr[xind,yind,0:9], /overplot, 'b') ;eak! correspondance is pretty poor between the two....but these are means.

rmean = mean(rmeanyr, dimension=3,/nan)
nmean = mean(nmeanyr, dimension=3,/nan)

;write out the PAW map so I can make adjustments in the WRSI
;ofile = strcompress('/jabber/chg-mcnally/PAW_NDVI_clim.img')
;openw,1,ofile
;writeu,1,nmean
;close,1
;
;ofile = strcompress('/jabber/chg-mcnally/PAW_RFE_clim.img')
;openw,1,ofile
;writeu,1,rmean
;close,1

ndetrend = fltarr(nx,ny,max_lgp,nz)
nretrend = fltarr(nx,ny,max_lgp,nz)

;subtract the N-SM mean and add back in the rfe-SM mean....
for d = 0, n_elements(ngrid[0,0,*,0])-1 do begin &$
  for y = 0, n_elements(ngrid[0,0,0,*])-1 do begin &$
    ndetrend[*,*,d,y] = ngrid[*,*,d,y]-nmean &$
  endfor &$
endfor

;close to zero -- i think that is a good thing.
dmean = mean(ndetrend, dimension = 3, /nan)
dmean = mean(dmean, dimension = 3, /nan)

;add back in the RFE-SM mean
for d = 0, n_elements(ngrid[0,0,*,0])-1 do begin &$
  for y = 0, n_elements(ngrid[0,0,0,*])-1 do begin &$
    nretrend[*,*,d,y] = ndetrend[*,*,d,y]+rmean &$
  endfor &$
endfor

;well, that seemed to adjust the mean...they don't look anything alike at wankama...
;didn't i already check this -- i guess it is becasue i am looking at the annual mean?
;nadjmeanyr = mean(nretrend,dimension=3, /nan)
;p1 = plot(nadjmeanyr[xind,yind,0:9],xtickname = xticks, title = 'Avg PAW Wankam')
;p2 = plot(rmeanyr[xind,yind,0:9], /overplot, 'b') ;eak! correspondance is pretty poor between the two....but these are means.

;;plot 2005-2008 to double check....looks like what I had before...now what do i do?? do I make this a function can call it?
;p1 = plot(transpose(nretrend[xind,yind,*,4]), 'r')
;p1 = plot(transpose(nretrend[xind,yind,*,5]), 'orange', /overplot)
;p1 = plot(transpose(nretrend[xind,yind,*,6]), 'g', /overplot)
;p1 = plot(transpose(nretrend[xind,yind,*,7]), 'b', /overplot)

;I also wanted to see where the FAO mean was over/underpredicting -- not sure anything will show, given how speckly that other maps was.
;so, nretrend is my new 'good map' -- I need a yearly average, and compare that to the yearly average in nmeanyr
dmean = mean(nretrend, dimension = 3, /nan)

diff = nmeanyr - nadjmeanyr
avgdiff = mean(diff, dimension=3, /nan)

;do i have a mask for this?? I need my 200-1200 rainfall mask too to block out wet parts of ethiopia.
;rfile = file_search('/jabber/chg-mcnally/FCLIMshael_rainmask4NDVI.img') ;masks 150-1200m of rainfall
;rmask = intarr(nx,ny)
;;readin rain mask
;openr,1,rfile
;readu,1,rmask
;close,1
sahelmask = rmean
out = where(rmean eq 0, complement = good)
sahelmask(out) = !values.f_nan
sahelmask(good) = 1
;
;good = where(rmean gt 0, complement = bad)
;mask = rmean
;mask(good) = 1
;mask(bad) = !values.f_nan

high = where(avgdiff gt 100)
low = where(avgdiff gt -25 AND avgdiff lt 25)
avgdiff100 = avgdiff
avgdiff100(high) = 100 
avgdiff100(low) = !values.f_nan

diffmask = avgdiff100
keep = where(avgdiff100 gt 25 OR avgdiff100 lt -25, complement = other, count) & print, count
diffmask(keep)= 1
diffmask(other) = !values.f_nan

p1 = image(avgdiff100, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 6)
   c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [200, 200, 200])
  
  ;***********************************************************
  ;which soil types are most commonly in disagreement?
ifile = file_search('/jabber/chg-mcnally/AMMASOIL/soiltexture_STATSGO-FAO_10KMSahel.1gd4r')

nx = 720
ny = 350

ingrid = fltarr(nx,ny)

openr,1, ifile
readu,1, ingrid
close,1

p1 = image(ingrid*diffmask*cropmask, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table = 6)
   c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [200, 200, 200])
  
;also want to mask out WRSI region...which mask is this: sahelmask
cdiff = avgdiff*cropmask*sahelmask
Sarry = fltarr(5,12)
whisdat = fltarr(2,12)
xtickname = ['sand', 'loam_sand', 'sand_loam', 'silt_loam', 'silt', 'loam', 'sand_clay_loam', 'silt_clay_loam',$
             'clay_loam', 'sandy_clay', 'silty_clay', 'clay'] 
for i = 1,12 do begin  &$
  Sand = where(ingrid eq i)  &$
  Serr = cdiff(sand) & nve, Serr &$

  Serr = Serr(where(finite(Serr))) &$

  ;the lower quartile
  SortSand = Serr(sort(serr)) &$
  index = fix(n_elements(serr)/2) &$
  
  Sarry[0,i-1] = min(sortsand) &$
  Sarry[1,i-1] = SortSand(fix(index*0.25)) &$
  Sarry[2,i-1] = median(SortSand) &$
  Sarry[3,i-1] = SortSand(fix(index*0.75)) &$
  Sarry[4,i-1] = max(sortsand) &$
  whisdat[0,i-1] = (median(sortsand) / 2.0) - sortsand[0] &$     ; negative error bar
  whisdat[1,i-1] = sortsand[N_elements(sortsand)-1] - (median(sortsand) / 2.0) &$        ; positive error bar
endfor 

b = BARPLOT(REFORM(Sarry(3,*)),BOTTOM_VALUES=REFORM(Sarry(1,*)), $
      COLOR='green',NAME='Shape Value', FILL_COLOR='white', $
      XTITLE='soil type',xtickname = xtickname, $
      YTITLE='Parameter Value')
;eak, how does this work?
e = ERRORPLOT(INDGEN(N_ELEMENTS(xtickname)),REFORM(Sarry(2,*)),whisdat[*,*], $
      LINESTYLE=6, ERRORBAR_COLOR='green',ERRORBAR_CAPSIZE=0.25, $
      /OVERPLOT)
b.order,/SEND_TO_FRONT


;;;this is what cappelaere says and looks about right...
;LoamSnd = where(ingrid eq 2) 
;LSerr = cdiff(loamSnd) & nve, LSerr; 9487, 30/42
;;
;;;Wankama is a sandy loam according to FAO
;SndLoam = where(ingrid eq 3)
;SLerr = cdiff(SndLoam) & nve, SLerr; 39672, 27/49
;;
;Sltloam = where(ingrid eq 4)
;SlLerr = cdiff(SltLoam) & nve, SlLerr ;48/58
;;
;Silt = where(ingrid eq 5)
;Silterr = cdiff(Silt) & nve, silterr 
;;
;Loam = where(ingrid eq 6)
;LErr = cdiff(loam) & nve, LErr 
;;
;;;Mpala is a sandy clay loam...
;SndClyLoam = where(ingrid eq 7)
;SDCLerr = cdiff(SndClyLoam) & nve, SDCLErr 
;;
;sltClyLoam = where(ingrid eq 8)
;SLCLerr = cdiff(SltClyLoam) & nve, SLCLerr
;;
;ClyLoam = where(ingrid eq 9)
;CLerr = cdiff(ClyLoam) & nve, CLerr
;;
;SandCly = where(ingrid eq 10)
;SCerr = cdiff(SandCly) & nve, SCerr
;;
;SiltCly = where(ingrid eq 11);NONE?
;SLCerr = cdiff(SiltCly) & nve, SLCerr
;;
;Clay = where(ingrid eq 12)
;Cerr = cdiff(Clay) & nve, Cerr;we also know that this wiliting point is absurdly low. 
;
;OM = where(ingrid eq 13,count) & print, count
;OMerr = avgdiff(OM) & nve, OMerr
;
;Water = where(ingrid eq 14, count) & print, count
;WPgrid(Water) = 0
;
;BedRk = where(ingrid eq 15, count) & print, count
;;WPgrid(BedRk) = 0.006
;BRerr = avgdiff(BedRk) & nve, BRerr
;
;
;other = where(ingrid eq 16, count) & print, count
;WPgrid(other) = 0.028


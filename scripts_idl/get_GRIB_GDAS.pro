;10/9/2013 I snagged this code from laura to check out the GDAS data - thanks laura!
;
; this code is to open GDAS GRIB files and make plots of: April mean, selected year. Data is 6hrly -> monthly mean
; impt to note that wgrib and this code will not open files for 2008 in months 04-08. Something different about thes 
; files is they are ~3 x larger than the months that follow. However, that is also the case of march 2008 and those open fine.
; so as to why they are different is unknown to me for now. hope the LIS deals with that....
; also, my calc for monthly mean swdown for apr 2001 has values [0,1). why?

; variables to plot -- dude, what does this mean? crazy grib...get these from 'wgrib'
  ; lwdown
  ; 1:0:D=2010040806:DLWRF:sfc:kpds=205,1,0:0-6hr ave:winds are N/S:"Downward long wave flux [W/m^2] --> index 0 in idl

  ;swdown
  ; 3:2654376:D=2010040806:DSWRF:sfc:kpds=204,1,0:0-6hr ave:winds are N/S:"Downward short wave flux [W/m^2] --> index 2 in idl

pro get_GRIB_GDAS

; run at command line first, then comment out to run pro
; compile this: grib_read_ex is from http://www.exelisvis.com/docs/GRIB_GET_VALUES.html#top.
; laura's mappy function: .compile -v '/home/source/laura/zippybits/GRIB/map_GDAS_africa.pro'

; for each day of the month find mean of the 6hrly values.
;  then calculate the monthly mean
;  
;; GDAS fields have different resolutions
; for apr 1 year:
;year, xdim, ydim
;2001, 512, 256
;2002, 512, 256
;2003, 768, 384
;2004, 768, 384
;2005, 768, 384
;2006, 1152, 576
;2007, 1152, 576
;2008, see note at top. data issue?
;2009, 1152, 576
;2010, 1152, 576 
;2011, 1760, 880
;  
; declare info
year = 2011
month = 4
daysinmo = 30
nx = 1760.
ny = 880.
indir = '/raid/GDAS/'

;plotdir = '/raid/chg-laura/analyses_in_prog/land-atm-interactions/aug2013/SEB_examine/GDAS/'

foldername = strcompress(indir + STRING(year) + STRING(format='(I2.2)',month) + '/', /remove_all)
modays = indgen(daysinmo)+1
dates = strcompress(STRING(year) + STRING(format='(I2.2)',month) + STRING(format='(I2.2)',modays))

; storage for sub daily values
  var1 = fltarr(nx,ny,4)
  var2 = fltarr(nx,ny,4)
; storage for daily values 
  var1_dailymean = fltarr(nx,ny,daysinmo)
  var2_dailymean = fltarr(nx,ny,daysinmo)
  
cd, foldername

for d = 0,(daysinmo-1) do begin &$

  ; find the data for this day
  find = strcompress(string(dates[d]) + '*' + '.gdas1.sfluxgrbf00.sg', /remove_all) &$
  lsfind = strcompress('ls ' + find) &$
  SPAWN,lsfind,filelist &$
  ; open these 4 files, keep the vars of interest. calc daily mean
  for t = 0,3 do begin &$
   tmp=GRIB_READ_EX(filelist[t],header=header) &$
      var1[*,*,t] = *tmp[0] &$
      var2[*,*,t] = *tmp[2]   &$
      delvar,tmp &$
      endfor &$
   ;var1_dailymean[*,*,d] =  total(var1,3,/NaN) / 4.
   ;var2_dailymean[*,*,d] =  total(var2,3,/NaN) / 4.
endfor   


; now calc monthly mean 
    var1_monthlymean = total(var1_dailymean,3,/NaN) / daysinmo
    var2_monthlymean = total(var2_dailymean,3,/NaN) / daysinmo

; make plot for sahel window



      xdim = nx
      ydim= ny
  

;Plot a regional subset with country bounds. See (call) quick_afr_rfe_v2.pro for East Africa parameters
;
name = 'GDAS_SWdown_mean_Apr2011'
ingrid = reverse(var2_monthlymean,2)

tmppr=image(ingrid,RGB=55)  
cbar = COLORBAR(TARGET = tmppr, ORIENTATION=1,POSITION=[0.90, 0.2, 0.95, 0.75])
            
      ; Map data for all Africa: 

      tmp=map_GDAS_Africa(ingrid,NX=xdim,NY=ydim,RGBCT=13,MIN_VAL=80,MAX_VAL=315,MAP_TIT=name) 
      ;tmp=map_GDAS_Africa(ingrid,NX=xdim,NY=ydim,RGBCT=13,MIN_VAL=80,MAX_VAL=315,MAP_TIT=name) 

             
      OUTNAME=STRCOMPRESS(PLOTDIR + NAME + 'Afr.png')     
      TMP.SAVE, OUTNAME, BORDER=10, RESOLUTION=300, /TRANSPARENT
      tmp.close


name = 'GDAS_LWdown_mean_Apr2011'
ingrid = reverse(var1_monthlymean,2)
            
      ; Map data for all Africa: 
      ; why does 2009 have lower vals (by a lot)?
      TMP=MAP_GDAS_AFRICA(INGRID,NX=xdim,NY=ydim,RGBCT=13,MIN_VAL=300,MAX_VAL=450,MAP_TIT=NAME) 

             
      OUTNAME=STRCOMPRESS(PLOTDIR + NAME + 'Afr.png')     
      TMP.SAVE, OUTNAME, BORDER=10, RESOLUTION=300, /TRANSPARENT
      TMP.CLOSE



;; pretty sure the 00 03 06 09 are data/forecasts at each 00 06 12 18 interval. which reminds me... these are GMT times (probably). 
;; Q. for which does kenya have sw data aka daytime?
;; A. times 06, 12, and 18


end


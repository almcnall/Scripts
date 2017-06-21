;code from greg.

stn_dir = '/jabber/chg-mcnally/AMMARain/WankamaEast_grid/'
rfe_dir = '/jower/LIS/data/Biased_Orig/'

startyr = 2005
endyr = 2008
dperm = [31,28,31,30,31,30,31,31,30,31,30,31]

;; EXTRACT VALUES FOR RFE DATA 
; the station lon/lat is 13.6496N 2.64920E
stn_lat = 13.6496
stn_lon = 2.6492
xind = FLOOR((stn_lon + 20.05) * 10.0)
yind = FLOOR((stn_lat + 40.05) * 10.0) 

tmpgrid = FLTARR(751,801)
rfedat = FLTARR(3)
for y=startyr,endyr do begin
   dtag = 1
   for m=1,12 do begin
      for d=1,dperm[m-1] do begin
         fnames = FILE_SEARCH(rfe_dir+STRING(FORMAT='(I4.4,I2.2,''/rfe_gdas.bin.'',I4.4,I2.2,I2.2,''*'')',y,m,y,m,d))
	 if N_ELEMENTS(fnames) ne 4 then print,'We have a problem at:',y,m,d
         for i=0,N_ELEMENTS(fnames)-1 do begin
            close,1
	    openr,1,fnames[i]
	    readu,1,tmpgrid
	    close,1
	    rfedat = [[rfedat],[FLOAT(y),FLOAT(dtag),SWAP_ENDIAN(tmpgrid[xind,yind])]]
	 endfor
	 dtag = dtag+1
      endfor
   endfor
endfor
;clear the first row from rfedat
rfedat = rfedat[*,1:N_ELEMENTS(rfedat[0,*])-1]
close,1
;openw,1,'RFE_6hrly_2005_2008.flt'
;writeu,1,rfedat
;close,1

;fix negative values
tmpind = WHERE(rfedat[2,*] lt 0.00,count)
if count gt 0 then rfedat[2,tmpind] = 0.00

;; READ IN STATION DATA
startyr = 2005
endyr   = 2008 

infile = file_search('/jabber/chg-mcnally/AMMARain/wankamaEast_3hrly_2005_2008.dat')
;infile = file_search('/jabber/chg-mcnally/AMMARain/wankamaEast_3hrly_2005_2008.dat')
;infile = file_search('/jabber/chg-mcnally/AMMARain/wankamaWest_3hrly_2005_2008.dat')
stndat = fltarr(3,11680) ;year,doy,rain (mm/3hr)

close,1
openr,1,infile
readu,1,stndat
close,1

;; LOOK AT DAILY TOTALS daytots=yr,dy,rfe,station
daytots = FLTARR(4)
tmpvals = FLTARR(4)
for y=startyr,endyr do begin &$
   for d=1,365 do begin &$
      tmpvals[0] = y &$
      tmpvals[1] = d &$
      ;tmpind = WHERE(rfedat[0,*] eq FLOAT(y) AND rfedat[1,*] eq FLOAT(d)) &$
      ; calculate total daily rainfall (mm) from 6 hourly rates (mm/sec)
      ;tmpvals[2] = TOTAL(rfedat[2,tmpind] * 60.0 * 60.0 * 6.0) &$
      tmpind = WHERE(stndat[0,*] eq FLOAT(y) AND stndat[1,*] eq FLOAT(d)) &$
      ; calculate total daily rainfall (mm) from 3 hourly rates (mm/sec)
      ;tmpvals[3] = TOTAL(stndat[2,tmpind] * 60.0 * 60.0 * 3.0)
      tmpvals[3] = TOTAL(stndat[2,tmpind]) &$
      
      daytots = [[daytots],[tmpvals]] &$
   endfor &$
endfor
daytots = daytots[*,1:N_ELEMENTS(daytots[0,*])-1]

;write out daytots to file
ofile = strcompress('/jabber/chg-mcnally/AMMARain/wankamaEast_daily_2005_2008.csv', /remove_all)
write_csv,ofile,daytots

; make some plots of daily data
tmpgr = PLOT(daytots[2,0:364],'k',YRANGE=[0.0,MAX(daytots[2:3,*])])
tmpgr = [tmpgr, PLOT(daytots[2,365:729],'r',YRANGE=[0.0,MAX(daytots[2:3,*])],/CURRENT)]
tmpgr = [tmpgr, PLOT(daytots[2,730:1094],'g',YRANGE=[0.0,MAX(daytots[2:3,*])],/CURRENT)]
tmpgr = [tmpgr, PLOT(daytots[2,1095:1459],'b',YRANGE=[0.0,MAX(daytots[2:3,*])],/CURRENT)]

tmpgr2 = PLOT(daytots[3,0:364],'--k',YRANGE=[0.0,MAX(daytots[2:3,*])])
tmpgr2 = [tmpgr2, PLOT(daytots[3,365:729],'--r',YRANGE=[0.0,MAX(daytots[2:3,*])],/CURRENT)]
tmpgr2 = [tmpgr2, PLOT(daytots[3,730:1094],'--g',YRANGE=[0.0,MAX(daytots[2:3,*])],/CURRENT)]
tmpgr2 = [tmpgr2, PLOT(daytots[3,1095:1459],'--b',YRANGE=[0.0,MAX(daytots[2:3,*])],/CURRENT)]


;; MAKE PLOT WITH REGRESSION LINE FOR VALUES GREATER THAN ZERO
norind = WHERE(daytots[2,*] eq 0.000 AND daytots[3,*] eq 0.000,COMPLEMENT=rind,count)

b = REGRESS(TRANSPOSE(daytots[2,rind]),TRANSPOSE(daytots[3,rind]), CONST=b0, YFIT=yest, MCORRELATION=r);
coeffs = [b0, TRANSPOSE(b)]
regplot = plot(daytots[2,rind], daytots[3,rind], "b1o", $
  SYM_FILLED = 1)
regplot.xtitle = 'RFE Estimates'
regplot.ytitle = 'Station Value'
regplot.name = STRING(FORMAT='(''r^2 = '',F6.4)',r^2)

tx = [min(daytots[2,rind]), max(daytots[2,rind])]
ty = b0 + b[0] * tx

regline = plot(tx, ty, "r2-", /OVERPLOT)
regline.name = regplot.name
!null = legend(target=[regline],position=[0.2,0.8])

;; CREATE HISTOGRAM OF VALUES WITH CERTAIN RFE VALUES 
norind = WHERE(daytots[2,*] eq 0.000 AND daytots[3,*] eq 0.000,COMPLEMENT=rind,count)
rfemin = 0.00
rfemax = 5.00

; if rfemin == rfemax then do the following line, otherwise comment it out 
; in favor of the one after
;good_rows = where(daytots[2,rind] eq rfemax)
good_rows = where(daytots[2,rind] gt rfemin AND daytots[2,rind] le rfemax)

; set some histogram parameters and run the darn thing
binsz = 5		; binsize
binmn = 0.00		; binminimum
selstn = histogram(daytots[3,rind[good_rows]],MIN=binmn,BINSIZE=binsz,LOCATIONS=barstarts)
barstarts = barstarts + (0.5 * binsz)	; sets the center of the bars, rather than minimum
b1 = barplot(barstarts, selstn, Fill_Color='Green', YRANGE=[0,MAX(selstn)+2])
b1.xtitle = 'Station Rainfall'
b1.ytitle = 'Counts'

end

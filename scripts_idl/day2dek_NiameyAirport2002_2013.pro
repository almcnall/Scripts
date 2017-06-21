pro  daily2dekad_KLEErain

;modified from daily2dekad_KLEErain.pro for the niamey airport rainfall data from Marty. 


indir = strcompress('/raid/chg-mcnally/', /remove_all)
ifile = file_search(indir+'niger_precip_daily.csv');2006-2009

indat = read_csv(ifile) ; i wonder if the MW data could be crazy here since it is the airport? might have to look outside town.
year = float(strmid(indat.field2,0,4))
month = float(strmid(indat.field2,5,2))
day = float(strmid(indat.field2,8,2))
rain = float(indat.field3)


sbuffer = [transpose(year), transpose(month), transpose(day), transpose(rain),transpose(indat.field1)]
gts = where(sbuffer[4,*] eq 203844, count, complement=GSOD) & print, count
gtsbuffer = [transpose(year(gts)), transpose(month(gts)), transpose(day(gts)), transpose(rain(gts)) ]
;for each year and each month sum up the days that are lt10, between 10 and 21, gt21
;cal = year, month, doy, day, hr, min, soil

sdeks = fltarr(36*11) ;do I want other stuff in this array? how many dekads will there be in 4 years? 36*4
;sdeks = fltarr(216) ;do I want other stuff in this array? how many dekads will there be in 4 years? 36*4
      
cnt=0
emptydek=!VALUES.F_NAN

;find dekadal averages of soil moisture.
for y = 2002,2013 do begin &$
  for m = 1,12 do begin &$
    ;where year=year and month=month
    index = where(sbuffer[0,*] eq y AND sbuffer[1,*] eq m, count)  &$
    if count eq 0 then begin &$
      print, 'a whole month missing wtf?!' &$
      sdek1 = emptydek &$
      sdeks[cnt] = sdek1 & cnt++ &$
      sdek2 = emptydek &$
      sdeks[cnt] = sdek2 & cnt++ &$
      sdek3 = emptydek &$
      sdeks[cnt] = sdek3 & cnt++ &$
    continue  &$
    endif &$
    ;dekad1 are the days/hrs/mon where day (sbuffer(3)) is less than 11   
    d1 = where(gtsbuffer[2,index] lt 11, count) & print, count &$
     
    ;i need to do this for all three sites - not just one!
    ;take the average of the SM col (sbuffer6), ignoring nan's
    ;what is this i all about?
    if count gt 0 then sdek1 = total(gtsbuffer[3,index[d1]], /nan) else sdek1 = emptydek &$
    ;record this average for the dekad.
    sdeks[cnt] = sdek1 & cnt++ &$
    
    ;bad coding practice -- i added in an exception for one particular instance...but it works :p
    d2 = where(gtsbuffer[2,index] ge 11 AND gtsbuffer[2,index] le 20, count) & print, count &$
    ;if count eq 1 then sdek2=sbuffer[*,index[d2]] else $ 
    if count gt 0 then sdek2 = total(gtsbuffer[3,index[d2]],/nan) else sdek2 = emptydek &$
    sdeks[cnt] = sdek2 & cnt++ &$
    
    d3=where(gtsbuffer[2,index] ge 21, count) & print, count &$
    if count gt 0 then sdek3=total(gtsbuffer[3,index[d3]],/nan) else sdek3=emptydek &$
    sdeks[cnt]=sdek3  &$
    ;if cnt eq 141 then continue else cnt++
    ;if cnt eq 141 then continue else 
    cnt++ &$
    print, 'm='+string(m) &$
    print, 'cnt='+string(cnt) &$
    
   endfor  &$;m
   print, 'y='+string(y) &$
   print, 'cnt='+string(cnt) &$
 endfor;y
 
 good = where(finite(sdeks), complement=zeros)
 sdeks(zeros)=0
 
 ofile = strcompress(indir+'GTS.Niamey_Rainstation_dekad.csv', /remove_all) & print, ofile
 ;ofile = strcompress(outdir+strmid(ifile[i],50,36)+'_10dayavg_VWC.csv', /remove_all) & print, ofile
 write_csv, ofile, sdeks

;fill in missing values disabled for 05cm since all the nans are at the begining. 
;there is missing data in the TK gully at 70 and 135... 
;do i need to do this? it isn't working...2/28/2013
;good = where(finite(sdeks), complement=missing) & print, missing
;for i = 0,n_elements(missing)-1 do begin &$
;  if missing[i] eq 0 then continue &$
;  fill = mean([sdeks(missing[i]-1), sdeks(missing[i]+1)]) &$ 
;  sdeks(missing[i]) = fill &$
;  ;check this for different sites
;  if missing[i] gt 52 then begin &$
;   fill = mean([sdeks[74], sdeks[80]], /nan) &$
;   sdeks(missing[i]) = fill &$
;   endif &$
;endfor

p1=plot(sdeks)
numbers=indgen(36)+1
print, 'hold here'

;make a vector of years to match with my soil moisture dekads
;five=intarr(36) & five[*]=2005
;six=intarr(36) &  six[*]=2006
;seven=intarr(36) & seven[*]=2007
;eight=intarr(36) & eight[*]=2008
;
;numbers=indgen(36)+1
;yvector=[five,six,seven,eight]
;dekofyear=[numbers,numbers,numbers,numbers]

;quadratic conversion from the manual..this must be bad w/ very small numbers. is linear better?
;VWC=-0.0663-0.0063*sdeks+0.0007*sdeks^2
;
;LVWC = -0.4677+0.0283*sdeks

;convert to water potential 
;what are the differences between the banzoumba and bagoua sites where 
;these parameters come from. Should I be using one over another?
;Bagoua has a higher sand content. Campbell van Gnucten perform differently under dry/wet regime.
;I could try a range of the parameters but will probably continue on for now. 
 ;ψm = ψe (Ө/Өs)-b

;the AMMA 2013 data is already in WWC (although I think this is for water potential, might be handy later)
;0-30cm: ψe=0.69, b=2.17, Өs=0.42 
;TK05=0.69*(VWC/0.42)^(-2.17)
;;30-60cm: ψe=0.78, b=2.71, Өs=0.42 
;TK40=0.78*(VWC/0.42)^(-2.71)
;;psie=0.9, b=2.83, thetaS=0.4 >60cm
;TK70=0.9*(VWC/0.4)^(-2.83)

outarry=[transpose(yvector),transpose(dekofyear),transpose(sdeks)]
;outarry = [transpose(yvector),transpose(dekofyear),transpose(VWC), transpose(TK70)]

ofile = strcompress(strmid(ifile,0,48)+'_10dayavg_VWC.dat', /remove_all) & print, ofile
;ofile=('/jabber/Data/mcnally/AMMASOIL/WK2_field108_40cm_10dayavg_VWC.dat')
print,'hold here'
here = where(finite(outarry[2,*]), complement=missing) & print, missing

;openw,1,ofile
;writeu,1,outarry
;close,1

;i know I should do this elsewhere....
;ndvi=fltarr(3,2,144)
;
;  ;read in the ndvi data of interest
;nfile='/jabber/Data/mcnally/AMMAVeg/NDVI_at_MF110.dat' ;this is no longer the correct location but I wanted to do something....
;;how can I do this better per Wang?
;openu,1,nfile
;readu,1,ndvi
;close,1
;
;;work with the average of ndvi over the small box
;xmean=mean(ndvi, dimension=1)
;avgndvi=mean(xmean,dimension=1)
;
;;compare avgndvi with sdeks
;ndvianom=avgndvi-mean(avgndvi, /nan)
;sdeksanom=sdeks-mean(sdeks, /nan)
;;get rid of the pesky nan value
;good=where(finite(sdeksanom), complement=bad)
;sdeks(bad)=mean(sdeks(128:130),/nan)
;corr=correlate(sdeksanom, ndvianom) ;0.675397 (but this could just be the seasonal cycle....)
end

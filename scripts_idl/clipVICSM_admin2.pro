clipVICSM_admin2

;1/1/14 (happy new year). the purpose of this script is to extract the soil moisture time series 
;for the districts where we have yield data. 
;
;ifile1 = file_search('/home/chg-mcnally/SM2.nc')
;ifile2 = file_search('/home/chg-mcnally/SM.nc')

ifile1 = file_search('/home/chg-mcnally/mon_SM2.nc');can envi open these?
ifile2 = file_search('/home/chg-mcnally/mon_SM.nc')
ifile3 = file_search('/home/chg-mcnally/mon_PCP.nc')


fileID = ncdf_open(ifile1, /nowrite)
soilID = ncdf_varid(fileID,'SM2')
ncdf_varget,fileID,soilID,smdata  
smdata(where(smdata gt 2000))=!values.f_nan

ofile = '/home/chg-mcnally/mon_SM2.img'
openw,1,ofile
writeu,1,reverse(smdata,2)
close,1 
p1=image(smdata[*,*,0])

fileID = ncdf_open(ifile2, /nowrite)
soilID = ncdf_varid(fileID,'SM')
timeID = ncdf_varid(fileID,'time')
ncdf_varget,fileID,soilID,smdata3  

ncdf_varget,fileID,timeID,time


fileID = ncdf_open(ifile3, /nowrite)
rainID = ncdf_varid(fileID,'PCP')
ncdf_varget,fileID,rainID,raindata  
raindata(where(raindata gt 5000))=!values.f_nan

ofile = '/home/chg-mcnally/mon_PCP.img'
openw,1,ofile
writeu,1,raindata
close,1 
p1=image(mean(smdata, dimension=3, /nan))




;shrad's VIC soil data is daily 55x40 Jan 1982-present (or plus 9862 days from 1/1/82).
;-1.875 deg S to 7.875 deg N and 36.125 deg E and 49.625 deg E



; I abandoned this script since shrad was able to do this in CDO in 2min. I guesss I should learn how to use that....
; i dould write this out as daily files...(like rfe2)
;;leap yrs 1984  1988  1992  1996  2000  2004  2008  2012
;make a new matrix w. yrs on left

yr = indgen(32)+1982
diy = [365, 365, 366, 365, 365, 365, 366, 365, 365, 365, 366, 365, 365, 365, 366, $
       365, 365, 365, 366, 365, 365, 365, 366, 365, 365, 365, 366, 365, 365, 365, 366, 365]
array = fltarr(n_elements(yr),n_elements(smdata))
;I think i just need to write these out by year? or by day. that wouldn't kill me or break the bank.

for i = 0, n_elements(smdata[0,0,*])-1 do begin &$
  doy = 0 &$
 count = 0
  for y = 0, n_elements(yr)-1 do begin &$
    for d = 1, diy[y] do begin &$
    ;doy = doy+1 & print, STRING(format='(I2.2)', q) 
    ofile = strcompress('/home/chg-mcnally/VIC_sm12_'+string(yr[y])+'.'+string(format='(I3.3)',d)+'.img', /remove_all) &$
    print, ofile &$
    ;openw,1,ofile
    ;writeu,1,smdata[i]  
  count++ & print, count &$
  endfor &$
endfor


SM82 = smdata[   0: 364]
SM83 = smdata[ 365: 729]
SM84 = smdata[ 730:1095];leap
SM85 = smdata[1096:1460]
SM86 = smdata[1461:1825]
SM87 = smdata[1826:2190]
SM88 = smdata[2191:2556];leap
SM89 = smdata[2557:2921]
SM90 = smdata[2922:3286]
SM91 = smdata[3287:3652]
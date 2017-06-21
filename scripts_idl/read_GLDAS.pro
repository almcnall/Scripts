pro read_GLDAS

;The purpose of this script is to 
;1. organize the data then
;2. calculate some statitistics re: seasonal and interannual hydrology in Africa.
;I want to be able to agregate by month and by year so pull thoes out of the filenames 

ifile = file_search('/raid2/sandbox/people/mcnally/*.nc')
  ;fileID = ncdf_open(ifile[0], /nowrite) &$
  ;varname = ncdf_vardir(fileID)
 ;lon lat sm sm_noise flag sensor
  ;soilID = ncdf_varid(fileID,'sm') &$
  ;flagID = ncdf_varid(fileID,'flag') &$
  ;lonID = ncdf_varid(fileID,'lon')
  ;latID = ncdf_varid(fileID,'lat')
;  ncdf_varget,fileID,soilID,smdata
;  ncdf_varget,fileID,lonID,londata
;  ncdf_varget,fileID,latID,latdata
;  ncdf_varget,fileID,flagID,flagdata

nx = 1440
ny = 720
mo = ['01','02','03','04','05','06','07','08','09','10','11','12']
;yr =['1980','1981','1982','1983','1984','1985','1986','1987','1988','1989', '1990','1991','1992','1993','1994','1995','1996','1997','1998','1999']
;yr =['1990','1991','1992','1993','1994','1995','1996','1997','1998','1999']
yr = ['2000']

;yr =['2001','2002','2003','2004','2005','2006','2007','2008','2009','2010']
meangrid = fltarr([nx,ny,132]) ;why 132??
buffer = fltarr(nx,ny)
cnt = 0 
for y = 0,n_elements(yr)-1 do begin
  for m = 0,n_elements(mo)-1 do begin
    year = strmid(ifile,72,4) 
    month = strmid(ifile,117,2) 
    index = where(year eq yr[y] AND month eq mo[m], count)
    buffer = fltarr(nx,ny,n_elements(index))
    for i=0,n_elements(index)-1 do begin
      fileID = ncdf_open(ifile[index[i]], /nowrite) &$
      soilID = ncdf_varid(fileID,'sm')
      ncdf_varget,fileID,soilID,smdata     
      ;oh I have to deal with the flag values before i add/average, or at least replace with nan's that i can /nan
      buffer[*,*,i] = smdata
      if i eq n_elements(index)-1 then begin
        buffer(where(buffer lt 0))=!values.f_nan
        avg = mean(buffer,dimension=3, /nan)
        meangrid[*,*,cnt] = avg
      endif
    endfor
    ofile = '/raid/chg-mcnally/ECV_soil_moisture/monthly/ECV_SM_'+yr[y]+mo[m]+'.img' & print, ofile
    openw,1,ofile
    writeu,1,avg
    close,1
    cnt++
 endfor
endfor
print, 'hold'
;*******************************day to dek***********************************
;indir = '/raid/chg-mcnally/ECV_soil_moisture/ESACCI-L3S_SOILMOISTURE-SSMV-MERGED/'
;ifile = file_search(indir+'19{8,9}?/*nc')
;  ;fileID = ncdf_open(ifile[0], /nowrite) &$
;  ;varname = ncdf_vardir(fileID)
; ;lon lat sm sm_noise flag sensor
;  ;soilID = ncdf_varid(fileID,'sm') &$
;  ;flagID = ncdf_varid(fileID,'flag') &$
;  ;lonID = ncdf_varid(fileID,'lon')
;  ;latID = ncdf_varid(fileID,'lat')
;;  ncdf_varget,fileID,soilID,smdata
;;  ncdf_varget,fileID,lonID,londata
;;  ncdf_varget,fileID,latID,latdata
;;  ncdf_varget,fileID,flagID,flagdata
;
;nx = 1440
;ny = 720
;ingrid=fltarr(nx,ny)
;
;dek1   = fltarr(nx,ny)
;dek2   = fltarr(nx,ny)
;dek3   = fltarr(nx,ny)
;
;cnt1=0
;cnt2=0
;cnt3=0
;
;dek1=fltarr(nx,ny,11)*!values.f_nan
;dek2=fltarr(nx,ny,11)*!values.f_nan
;dek3=fltarr(nx,ny,11)*!values.f_nan
;
;mo = ['01','02','03','04','05','06','07','08','09','10','11','12']
;;yr =['1980','1981','1982','1983','1984','1985','1986','1987','1988','1989', '1990','1991','1992','1993','1994','1995','1996','1997','1998','1999']
;yr =['1990','1991','1992','1993','1994','1995','1996','1997','1998','1999']
;
;meangrid = fltarr([nx,ny,132])
;buffer = fltarr(nx,ny)
;cnt = 0 
;for y = 0,n_elements(yr)-1 do begin
;  for m = 0,n_elements(mo)-1 do begin
;    year = strmid(ifile,72,4) 
;    month = strmid(ifile,117,2) 
;    
;    index = where(year eq yr[y] AND month eq mo[m], count)
;    buffer = fltarr(nx,ny,n_elements(index))
;    for i=0,n_elements(index)-1 do begin
;      fileID = ncdf_open(ifile[index[i]], /nowrite) &$
;      soilID = ncdf_varid(fileID,'sm')
;      ncdf_varget,fileID,soilID,smdata     
;      ;oh I have to deal with the flag values before i add/average, or at least replace with nan's that i can /nan
;      ;buffer[*,*,i] = smdata
;      ingrid = smdata
;      ingrid(where(ingrid lt 0))=!values.f_nan
;      day = strmid(ifile[index[i]],119,2)
;      ;day=strmid(sdek[d],55,2)
;     
;       ;finally - i learned to nest these silly things...but i have to do these to deal with flag values...
;       if (float(day) lt 11.) then begin
;       dek1[*,*,cnt1] = ingrid & cnt1++ 
;       endif else if (float(day) gt 10.) AND  (float(day) lt 21.) then begin
;         dek2[*,*,cnt2] = ingrid & cnt2++  
;       endif else if (float(day) gt 20.) then begin
;         dek3[*,*,cnt3] = ingrid & cnt3++  
;       endif else begin
;         break 
;       endelse   
;  
;    endfor;d
;    ;what does this do? find the average?
;    print, cnt1,cnt2,cnt3
;     dek1 = mean(dek1, dimension=3, /nan)
;     dek2 = mean(dek2, dimension=3, /nan)
;     dek3 = mean(dek3, dimension=3, /nan)
;     
;     ;write out the dekad files
;     odir = '/raid/chg-mcnally/ECV_soil_moisture/dekads/ECV_'
;     ofile1 = strcompress(odir+strmid(ifile[index[0]],113,6)+'_01.img',/remove_all) & print, ofile1
;     ofile2 = strcompress(odir+strmid(ifile[index[0]],113,6)+'_02.img',/remove_all) & print, ofile2
;     ofile3 = strcompress(odir+strmid(ifile[index[0]],113,6)+'_03.img',/remove_all) & print, ofile3
;     
;     openw,1,ofile1
;     writeu,1,dek1
;     close,1
;     
;     openw,1,ofile2
;     writeu,1,dek2
;     close,1
;     
;     openw,1,ofile3
;     writeu,1,dek3
;     close,1    
;;reset the counter for averaging the dekads     
;  cnt1=0
;  cnt2=0
;  cnt3=0
;  
;  dek1=fltarr(nx,ny,11)*!values.f_nan
;  dek2=fltarr(nx,ny,11)*!values.f_nan
;  dek3=fltarr(nx,ny,11)*!values.f_nan
;
;  endfor;mm
;endfor;yr   
;   print, 'hold'
end
     
pro CHIRPS_SEASMEAN


startyr = 1992
endyr = 2013
nyrs = endyr-startyr+1

;re-do for all months
startmo = 3
endmo = 9
nmos = endmo - startmo+1

;East Africa WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

ulx = (180.+map_ulx)*10.  & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10.   & lry = (50.-map_lry)*10.-1
NX = lrx - ulx + 1.5
NY = lry - uly + 2

;;make seasonal cubes of CHIRPS MAM, JAS, OND
;these valuse coming out of LIS look wacky.
data_dir = '/home/sandbox/people/mcnally/NOAH_CHIRPS_MERRA_EA/CHIRPS_YRMO/' ;files look like CHIRPS_Noah2014_05.nc
CHIRPS = FLTARR(NX,NY,nmos,nyrs)
Ptot = FLTARR(NX,NY,nyrs)


;this loop reads in the selected months only
for yr=startyr,endyr do begin &$
  for i=0,nmos-1 do begin &$
  y = yr &$
  m = startmo + i &$
  if m gt 12 then begin &$
  m = m-12 &$
  y = y+1 &$
endif &$
fileID = ncdf_open(data_dir+STRING(FORMAT='(''CHIRPS_Noah'',I4.4,''_'',I2.2,''.nc'')',y,m), /nowrite) &$
rainID = ncdf_varid(fileID,'Rainf_f_inst') &$
ncdf_varget,fileID, rainID, P &$
CHIRPS[*,*,i,yr-startyr] = P &$

;generates the seasonal total for months of interest
Ptot[*,*,yr-startyr] =  Ptot[*,*,yr-startyr] +P &$
endfor &$
endfor
Ptot(where(Ptot lt 0))=!values.f_nan

;CHIRPS 1992-2013
;there seem to be some unusually large values coming out of there.
;it is possible that i am getting avg dekads or something.  
AVGP = MEAN(PTOT, DIMENSION=3, /NAN)
;AVGP(where(avgp gt 1000))=1000
STDP = STDDEV(PTOT, DIMENSION=3, /NAN)
;STDP(where(STDP gt 100))=100
;Standardize! i think this might be wrong?

;Standardize!
zp=fltarr(nx,ny,nyrs)
FOR Y = 0, NYRS-1 DO BEGIN &$
  ZP[*,*,Y] = (PTOT[*,*,Y]-AVGP)/STDP &$
  print, mean((PTOT[*,*,Y]-AVGP)/STDP, /nan) &$
ENDFOR

;plot time series with longrain mask, why is my magnitude off by x10
ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input_wrsi.ea_may2nov.nc') & print, ifile ;long mask
fileID = ncdf_open(ifile, /nowrite) &$
  maskID = ncdf_varid(fileID,'WRSIMASK')
ncdf_varget,fileID, maskID, longmask
longmask(where(longmask eq 0)) = !values.f_nan
p1 = plot(mean(mean(ZP,dimension=1, /nan), dimension=1, /nan), xrange=[0,nyrs-1], /overplot);*rebin(longmask,NX,NY,NYRS)
xticks = indgen(nyrs+1)+startyr & print, xticks
p1.xtickinterval = 1
p1.xTICKNAME = string(xticks)
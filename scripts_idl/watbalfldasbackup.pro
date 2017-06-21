this script is to investigate the water balance of Noah and VIC
; 1/16/16 

.compile /home/source/mcnally/scripts_idl/get_nc.pro

startyr = 1982 ;start with 1982 since no data in 1981
endyr = 2014
nyrs = endyr-startyr+1

;East Africa May-Sept, Aug-Dec, West Africa June-October
startmo = 1
endmo = 12
nmos = endmo - startmo+1

;West Africa (5.35 N - 17.65 N; 18.65 W - 25.85 E)
; west africa domain
;map_ulx = -18.65 & map_lrx = 25.85
;map_uly = 17.65 & map_lry = 5.35

;East Africa WRSI/Noah window
;map_ulx = 22.  & map_lrx = 51.35
;map_uly = 22.95  & map_lry = -11.75

;and for VIC...
; East africa domain
map_ulx = 21.875 & map_lrx = 51.125
map_uly = 23.125 & map_lry = -11.875


;Southern Africa WRSI/Noah window
;Southern Africa (37.85 S - 6.35 N; 6.05 E - 54.55 E) 
;NX = 486, NY = 443
;map_ulx = 6.05  & map_lrx = 54.55
;map_uly = 6.35  & map_lry = -37.85
res = 4. ;or 10. if its 0.1 degree

ulx = (180.+map_ulx)*res  & lrx = (180.+map_lrx)*res-1
uly = (50.-map_uly)*res   & lry = (50.-map_lry)*res-1
NX = lrx - ulx + 2 
NY = lry - uly + 2

;data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_RFE2_GDAS_SA/';FLDAS_NOAH01_B_SA_M.A201507.001.nc
;data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_CHIRPSv2.001_MERRA_SA/';FLDAS_NOAH01_B_SA_M.A201507.001.nc
;data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_CHIRPSv2.001_MERRA_WA/';FLDAS_NOAH01_B_SA_M.A201507.001.nc
;data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_CHIRPSv2.001_MERRA_EA/';FLDAS_NOAH01_B_SA_M.A201507.001.nc
data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/VIC_CHIRPSv2.001_MERRA_EA/';FLDAS_NOAH01_B_SA_M.A201507.001.nc

Evap = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
Rain = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
Qsuf = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
Qsub = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
SM01 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
SM02 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
SM03 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
SM04 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan


;this loop reads in the selected months only
for yr=startyr,endyr do begin &$
  for i=0,nmos-1 do begin &$
  y = yr &$
  m = startmo + i &$
  if m gt 12 then begin &$
    m = m-12 &$
    y = y+1 &$
  endif &$
  ;ifile = file_search(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_B_EA_M.A'',I4.4,I2.2,''.001.nc'')',y,m)) &$
  ifile = file_search(data_dir+STRING(FORMAT='(''FLDAS_VIC025_B_EA_M.A'',I4.4,I2.2,''.001.nc'')',y,m)) &$

  ;ifile = file_search(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_B_WA_M.A'',I4.4,I2.2,''.001.nc'')',y,m)) &$
  ;ifile = file_search(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_B_SA_M.A'',I4.4,I2.2,''.001.nc'')',y,m)) &$
  ;ifile = file_search(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_A_SA_M.A'',I4.4,I2.2,''.001.nc'')',y,m)) &$
  ;does this somehow not work?
  VOI = 'Qs_tavg' &$ ;variable of interest 'SoilMoist_v_Rainf', SoilMoist_v_NDVI
  Qs = get_nc(VOI, ifile) &$
  print, ifile, VOI &$
  Qsuf[*,*,i,yr-startyr] = Qs &$
    
  VOI = 'Qsb_tavg' &$ ;variable of interest 'SoilMoist_v_Rainf', SoilMoist_v_NDVI
  Qs = get_nc(VOI, ifile) &$
  print, ifile, VOI &$
  Qsub[*,*,i,yr-startyr] = Qs &$
 
  VOI = 'Evap_tavg' &$ ;variable of interest 'SoilMoist_v_Rainf', SoilMoist_v_NDVI
  Qs = get_nc(VOI, ifile) &$
  print, ifile, VOI &$
  Evap[*,*,i,yr-startyr] = Qs &$
  
  VOI = 'Rainf_f_tavg' &$ ;variable of interest 'SoilMoist_v_Rainf', SoilMoist_v_NDVI
  Qs = get_nc(VOI, ifile) &$
  Rain[*,*,i,yr-startyr] = Qs &$
 
;  VOI = 'SoilMoi00_10cm_tavg' &$ ;variable of interest 'SoilMoist_v_Rainf', SoilMoist_v_NDVI
;  Qs = get_nc(VOI, ifile) &$
;  SM01[*,*,i,yr-startyr] = Qs &$ 
;  
;  VOI = 'SoilMoi10_40cm_tavg' &$ ;variable of interest 'SoilMoist_v_Rainf', SoilMoist_v_NDVI
;  Qs = get_nc(VOI, ifile) &$
;  SM02[*,*,i,yr-startyr] = Qs &$
;  
;  VOI = 'SoilMoi40_100cm_tavg' &$ ;variable of interest 'SoilMoist_v_Rainf', SoilMoist_v_NDVI
;  Qs = get_nc(VOI, ifile) &$
;  SM03[*,*,i,yr-startyr] = Qs &$
;  
;  VOI = 'SoilMoi100_200cm_tavg' &$ ;variable of interest 'SoilMoist_v_Rainf', SoilMoist_v_NDVI
;  Qs = get_nc(VOI, ifile) &$
;  SM04[*,*,i,yr-startyr] = Qs &$
       
  endfor &$ 
endfor
;there is prob a better way to do this..
Evap(where(Evap lt 0)) = 0 
Qsub(where(Qsub lt 0)) = 0 
Qsuf(where(Qsuf lt 0)) = 0
SM01(where(SM01 lt 0)) = 0
SM02(where(SM02 lt 0)) = 0
SM03(where(SM03 lt 0)) = 0
SM04(where(SM04 lt 0)) = 0
rain(where(rain lt 0)) = 0

;Evapmm = Evap*86400*30

;I'd like a water mask and a landmask, which combo will do this?
;do i need the mask? if so i'll have to grad 0.25 vic ones too
;landmask will give water bodies+ocean, WHC will give land v ocean.
;ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input_ea_elev.nc');lis_input_wrsi.ea_oct2feb.nc
ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input_wrsi.ea_oct2feb.nc');lis_input_wrsi.sa.nc
;ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input_wrsi.sa.nc');lis_input_wrsi.wa.mode.nc
;ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input_wrsi.wa.mode.nc')
;ifile = file_search('/home/sandbox/people/mcnally/LIS_NETCDF_INPUT/lis_input_wa_elev.nc')

fileID = ncdf_open(ifile)
qsID = ncdf_varid(fileID,'WRSIMASK'); WHC
;qsID = ncdf_varid(fileID,'LANDMASK'); this does water bodies
ncdf_varget,fileID, qsID, landmask
landmask(where(landmask gt 0))=1
landmask(where(landmask eq 0))=!values.f_nan

;qsID = ncdf_varid(fileID,'WHC'); this does ocean
;ncdf_varget,fileID, qsID, whc
;NCDF_close, fileID
;
;whc(where(whc gt 0))=1
;whc(where(whc eq 0))=!values.f_nan

temp =image(landmask, min_value=0, layout=[2,1,1])
;temp =image(whc, min_value=0, layout=[2,1,2], /current)

;look at the average water balance for the mask area, i know i checked the P-ET=RO via map
;plot the mean cumulative rainfall time series
RO = qsuf+qsub
RainAVG = mean(mean(mean(rain, dimension=4, /nan), dimension=1, /nan), dimension=1, /nan) & help, rainavg
EvapAVG = mean(mean(mean(evap, dimension=4, /nan), dimension=1, /nan), dimension=1, /nan) & help, evapavg
ROAVG = mean(mean(mean(RO, dimension=4, /nan), dimension=1, /nan), dimension=1, /nan) & help, ROavg
SM01AVG = mean(mean(mean(SM01, dimension=4, /nan), dimension=1, /nan), dimension=1, /nan) & help, ROavg
SM02AVG = mean(mean(mean(SM02, dimension=4, /nan), dimension=1, /nan), dimension=1, /nan) & help, ROavg
SM03AVG = mean(mean(mean(SM03, dimension=4, /nan), dimension=1, /nan), dimension=1, /nan) & help, ROavg
SM04AVG = mean(mean(mean(SM04, dimension=4, /nan), dimension=1, /nan), dimension=1, /nan) & help, ROavg

p1=plot(total(rainavg,/cumulative)*86400*30) & print, stddev(rain)
p1=plot(total(evapavg,/cumulative)*86400*30, /overplot, 'b')
p1=plot(total(ROavg,/cumulative)*86400*30, /overplot, 'orange')
p1=plot(total(SM01avg,/cumulative)*300, /overplot, 'grey')
p1=plot(total(SM02avg,/cumulative)*100, /overplot, 'grey')
p1=plot(total(SM03avg,/cumulative)*100, /overplot, 'grey')
p1=plot(total(SM04avg,/cumulative)*100, /overplot, 'grey')

p1=plot((total(ROavg,/cumulative)*86400*30)+total(evapavg,/cumulative)*86400*30,/overplot,'-r')
total(reform(d,12*34), /cumulative)



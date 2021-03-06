pro readin_SMpercentile


  .compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
  .compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
  ;.compile /home/almcnall/Scripts/scripts_idl/nve.pro
  ;.compile /home/almcnall/Scripts/scripts_idl/mve.pro
  ;.compile /home/source/mcnally/scripts_idl/get_nc.pro

  startyr = 2017 ;start with 1982 since no data in 1981
  endyr = 2017
  nyrs = endyr-startyr+1

  ;re-do for all months
  startmo = 1
  endmo = 12
  nmos = endmo - startmo+1

  ;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
  params = get_domain01('EA')

  NX = params[0]
  NY = params[1]
  map_ulx = params[2]
  map_lrx = params[3]
  map_uly = params[4]
  map_lry = params[5]

  ;;;;;;use hymap runoff vs. non-routed;;;;
  data_dir='/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/post/'
  ;data_dir='/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_WA/post/'

  SMP = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
  ;this loop reads in the selected months only
;  for yr=startyr,endyr do begin &$
;    for i=0,nmos-1 do begin &$
;    y = yr &$
;    m = startmo + i &$
;    if m gt 12 then begin &$
;    m = m-12 &$
;    y = y+1 &$
;  endif &$
y = 2017
m = 4
  ifile = file_search(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_C_EA_M.A'',I4.4,I2.2,''.001.nc'')',y,m)) &$

  ;variable of interest
  VOI = 'SMRZ_Percentile' &$
  Qs = get_nc(VOI, ifile) &$
  ;print, ifile, VOI &$
;  SMP[*,*,i,yr-startyr] = Qs &$
;
;endfor &$
;endfor
Qs(where(Qs lt 0)) = 0
